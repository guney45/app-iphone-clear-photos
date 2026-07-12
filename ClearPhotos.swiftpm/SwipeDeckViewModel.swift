import Foundation
import Photos

/// Bir inceleme oturumunun mantığı: hangi karttayız, geri alma geçmişi.
/// SİL kararları kalıcı silme listesine (ReviewStore) yazılır.
@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var entries: [AssetEntry]
    @Published private(set) var index: Int = 0

    let service: PhotoLibraryService
    let store: ReviewStore

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

    // MARK: - Kararlar

    func keepCurrent() {
        guard let current else { return }
        store.markKept(current.id)
        history.append(Decision(entry: current, kind: .keep))
        advance()
    }

    func deleteCurrent() {
        guard let current else { return }
        var size = current.byteSize
        if size == 0 { size = service.computeSize(for: current.asset) }
        store.addPending(id: current.id, bytes: size)
        history.append(Decision(entry: current, kind: .delete))
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
            store.removePending(id: last.entry.id)
        case .skip:
            break
        }
    }

    private func advance() {
        index += 1
    }
}
