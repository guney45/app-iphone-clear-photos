import Foundation

/// İncelenen öğeleri, silme listesini ve toplam kazanımları kalıcı olarak saklar
/// (yalnızca cihazda, UserDefaults).
@MainActor
final class ReviewStore: ObservableObject {
    /// Daha önce "sakla" kararı verilmiş öğelerin kimlikleri.
    @Published private(set) var reviewedIdentifiers: Set<String>

    /// SİL olarak işaretlenmiş ama HENÜZ SİLİNMEMİŞ öğeler (kalıcı; oturumlar arası korunur).
    @Published private(set) var pendingDeleteIDs: [String]
    private var pendingBytesByID: [String: Int64]

    /// Şimdiye kadar açılan toplam yer (byte).
    @Published private(set) var totalFreedBytes: Int64
    @Published private(set) var totalDeletedCount: Int
    @Published private(set) var totalKeptCount: Int

    /// Daha önce incelediklerimi tekrar gösterme.
    @Published var skipReviewed: Bool {
        didSet { defaults.set(skipReviewed, forKey: Keys.skipReviewed) }
    }

    /// Yoğun gün önerisi eşiği: bir günde bu sayıdan çok öğe varsa ana sayfada önerilir.
    @Published var busyDayThreshold: Int {
        didSet { defaults.set(busyDayThreshold, forKey: Keys.busyThreshold) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let reviewed = "reviewedIdentifiers"
        static let pendingIDs = "pendingDeleteIDs"
        static let pendingBytes = "pendingBytesByID"
        static let freed = "totalFreedBytes"
        static let deleted = "totalDeletedCount"
        static let kept = "totalKeptCount"
        static let skipReviewed = "skipReviewed"
        static let busyThreshold = "busyDayThreshold"
    }

    init() {
        reviewedIdentifiers = Set(defaults.array(forKey: Keys.reviewed) as? [String] ?? [])
        pendingDeleteIDs = defaults.array(forKey: Keys.pendingIDs) as? [String] ?? []
        pendingBytesByID = (defaults.dictionary(forKey: Keys.pendingBytes) as? [String: Int])?
            .mapValues { Int64($0) } ?? [:]
        totalFreedBytes = Int64(defaults.integer(forKey: Keys.freed))
        totalDeletedCount = defaults.integer(forKey: Keys.deleted)
        totalKeptCount = defaults.integer(forKey: Keys.kept)
        skipReviewed = defaults.object(forKey: Keys.skipReviewed) == nil
            ? true
            : defaults.bool(forKey: Keys.skipReviewed)
        let storedThreshold = defaults.integer(forKey: Keys.busyThreshold)
        busyDayThreshold = storedThreshold == 0 ? 100 : storedThreshold
    }

    // MARK: - Sakla / incele

    func isReviewed(_ id: String) -> Bool { reviewedIdentifiers.contains(id) }

    func markKept(_ id: String) {
        let (inserted, _) = reviewedIdentifiers.insert(id)
        if inserted { totalKeptCount += 1 }
        persist()
    }

    func unmarkKept(_ id: String) {
        if reviewedIdentifiers.remove(id) != nil {
            totalKeptCount = max(0, totalKeptCount - 1)
            persist()
        }
    }

    func resetReviewedHistory() {
        reviewedIdentifiers.removeAll()
        persist()
    }

    // MARK: - Silme listesi (kalıcı)

    func isPending(_ id: String) -> Bool { pendingBytesByID[id] != nil }

    var pendingCount: Int { pendingDeleteIDs.count }
    var pendingTotalBytes: Int64 { pendingDeleteIDs.reduce(0) { $0 + (pendingBytesByID[$1] ?? 0) } }
    func pendingBytes(for id: String) -> Int64? { pendingBytesByID[id] }

    func addPending(id: String, bytes: Int64) {
        guard pendingBytesByID[id] == nil else { return }
        pendingDeleteIDs.append(id)
        pendingBytesByID[id] = bytes
        persist()
    }

    func removePending(id: String) {
        pendingDeleteIDs.removeAll { $0 == id }
        pendingBytesByID[id] = nil
        persist()
    }

    /// Silme listesini boşalt (öğeleri SİLMEDEN yalnızca işareti kaldırır).
    func clearPending() {
        pendingDeleteIDs.removeAll()
        pendingBytesByID.removeAll()
        persist()
    }

    /// Var olmayan (dışarıda silinmiş) kimlikleri temizle.
    func prunePending(keepingOnly validIDs: Set<String>) {
        let before = pendingDeleteIDs.count
        pendingDeleteIDs.removeAll { !validIDs.contains($0) }
        for key in pendingBytesByID.keys where !validIDs.contains(key) {
            pendingBytesByID[key] = nil
        }
        if pendingDeleteIDs.count != before { persist() }
    }

    // MARK: - Silme onaylandığında

    func recordDeletion(ids: [String], bytes: Int64) {
        reviewedIdentifiers.formUnion(ids)
        totalDeletedCount += ids.count
        totalFreedBytes += bytes
        for id in ids {
            pendingDeleteIDs.removeAll { $0 == id }
            pendingBytesByID[id] = nil
        }
        persist()
    }

    func resetStats() {
        totalFreedBytes = 0
        totalDeletedCount = 0
        totalKeptCount = 0
        persist()
    }

    // MARK: - Kaydet

    private func persist() {
        defaults.set(Array(reviewedIdentifiers), forKey: Keys.reviewed)
        defaults.set(pendingDeleteIDs, forKey: Keys.pendingIDs)
        defaults.set(pendingBytesByID.mapValues { Int($0) }, forKey: Keys.pendingBytes)
        defaults.set(Int(totalFreedBytes), forKey: Keys.freed)
        defaults.set(totalDeletedCount, forKey: Keys.deleted)
        defaults.set(totalKeptCount, forKey: Keys.kept)
    }
}
