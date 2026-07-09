import Foundation
import Photos

/// Bir inceleme oturumunun mantığı: hangi karttayız, silinmek üzere işaretlenenler,
/// geri alma geçmişi ve silmeyi onaylama.
@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var entries: [AssetEntry]
    @Published private(set) var index: Int = 0
    /// Silinmek üzere işaretlenenler (henüz silinmedi — önce onay ekranında görürsün).
    @Published private(set) var pendingDelete: [AssetEntry] = []
    @Published var isDeleting = false
    @Published var deleteError: String?

    private let service: PhotoLibraryService
    private let store: ReviewStore

    enum DecisionKind { case keep, delete, skip }
    private struct Decision { let entry: AssetEntry; let kind: DecisionKind }
    private var history: [Decision] = []

    init(entries: [AssetEntry], service: PhotoLibraryService, store: ReviewStore) {
        self.entries = entries
        self.service = service
        self.store = store
    }

    // MARK: - Durum

    var current: AssetEntry? { index < entries.count ? entries[index] : nil }
    var next: AssetEntry? { index + 1 < entries.count ? entries[index + 1] : nil }
    var isFinished: Bool { index >= entries.count }
    var totalCount: Int { entries.count }
    var reviewedCount: Int { index }
    var canUndo: Bool { index > 0 }

    var pendingBytes: Int64 { pendingDelete.reduce(0) { $0 + $1.byteSize } }
    var pendingCount: Int { pendingDelete.count }

    // MARK: - Kararlar

    func keepCurrent() {
        guard let current else { return }
        store.markKept(current.id)
        history.append(Decision(entry: current, kind: .keep))
        advance()
    }

    func deleteCurrent() {
        guard let current else { return }
        // Boyut henüz hesaplanmadıysa şimdi hesapla (yığın toplamı doğru olsun).
        var entry = current
        if entry.byteSize == 0 {
            entry.byteSize = service.computeSize(for: entry.asset)
        }
        pendingDelete.append(entry)
        history.append(Decision(entry: entry, kind: .delete))
        advance()
    }

    func skipCurrent() {
        guard let current else { return }
        history.append(Decision(entry: current, kind: .skip))
        advance()
    }

    func undo() {
        guard canUndo, let last = history.popLast() else { return }
        index -= 1
        switch last.kind {
        case .keep:
            store.unmarkKept(last.entry.id)
        case .delete:
            pendingDelete.removeAll { $0.id == last.entry.id }
        case .skip:
            break
        }
    }

    func removeFromPile(_ entry: AssetEntry) {
        pendingDelete.removeAll { $0.id == entry.id }
    }

    private func advance() {
        index += 1
    }

    // MARK: - Silmeyi onayla

    /// İşaretlenen tüm öğeleri siler. iOS kendi onay penceresini gösterir.
    /// Başarılı olursa istatistikler güncellenir ve yığın boşaltılır.
    func commitDeletions() async {
        guard !pendingDelete.isEmpty else { return }
        isDeleting = true
        deleteError = nil
        let assets = pendingDelete.map { $0.asset }
        let ids = pendingDelete.map { $0.id }
        let bytes = pendingBytes
        do {
            try await service.deleteAssets(assets)
            store.recordDeletion(ids: ids, bytes: bytes)
            pendingDelete.removeAll()
        } catch {
            deleteError = "Silme tamamlanmadı ya da iptal edildi."
        }
        isDeleting = false
    }
}
