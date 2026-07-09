import Foundation

/// İncelenen öğeleri ve toplam kazanımları kalıcı olarak saklar (yalnızca cihazda, UserDefaults).
@MainActor
final class ReviewStore: ObservableObject {
    /// Daha önce "sakla" ya da "sil" kararı verilmiş öğelerin kimlikleri.
    @Published private(set) var reviewedIdentifiers: Set<String>
    /// Şimdiye kadar açılan toplam yer (byte).
    @Published private(set) var totalFreedBytes: Int64
    @Published private(set) var totalDeletedCount: Int
    @Published private(set) var totalKeptCount: Int
    /// Daha önce incelediklerimi tekrar gösterme.
    @Published var skipReviewed: Bool {
        didSet { defaults.set(skipReviewed, forKey: Keys.skipReviewed) }
    }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let reviewed = "reviewedIdentifiers"
        static let freed = "totalFreedBytes"
        static let deleted = "totalDeletedCount"
        static let kept = "totalKeptCount"
        static let skipReviewed = "skipReviewed"
    }

    init() {
        let ids = defaults.array(forKey: Keys.reviewed) as? [String] ?? []
        reviewedIdentifiers = Set(ids)
        totalFreedBytes = Int64(defaults.integer(forKey: Keys.freed))
        totalDeletedCount = defaults.integer(forKey: Keys.deleted)
        totalKeptCount = defaults.integer(forKey: Keys.kept)
        // skipReviewed varsayılanı: açık
        if defaults.object(forKey: Keys.skipReviewed) == nil {
            skipReviewed = true
        } else {
            skipReviewed = defaults.bool(forKey: Keys.skipReviewed)
        }
    }

    func isReviewed(_ id: String) -> Bool {
        reviewedIdentifiers.contains(id)
    }

    func markKept(_ id: String) {
        let (inserted, _) = reviewedIdentifiers.insert(id)
        if inserted { totalKeptCount += 1 }
        persist()
    }

    /// "Sakla" kararını geri al (undo için).
    func unmarkKept(_ id: String) {
        if reviewedIdentifiers.remove(id) != nil {
            totalKeptCount = max(0, totalKeptCount - 1)
            persist()
        }
    }

    /// Silme onaylandıktan sonra istatistikleri günceller.
    func recordDeletion(ids: [String], bytes: Int64) {
        reviewedIdentifiers.formUnion(ids)
        totalDeletedCount += ids.count
        totalFreedBytes += bytes
        persist()
    }

    /// Tüm "incelendi" kayıtlarını sıfırla (istatistikler korunur).
    func resetReviewedHistory() {
        reviewedIdentifiers.removeAll()
        persist()
    }

    private func persist() {
        defaults.set(Array(reviewedIdentifiers), forKey: Keys.reviewed)
        defaults.set(Int(totalFreedBytes), forKey: Keys.freed)
        defaults.set(totalDeletedCount, forKey: Keys.deleted)
        defaults.set(totalKeptCount, forKey: Keys.kept)
    }
}
