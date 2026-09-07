import SwiftUI
import UIKit
import Photos

/// Kalıcı silme listesi. Ana ekrandan da, inceleme sırasında da açılabilir.
/// Buradan tek tek çıkarabilir ya da hepsini birden silebilirsin.
/// Silme sırasında iOS kendi onayını gösterir.
struct TrashReviewView: View {
    @EnvironmentObject private var service: PhotoLibraryService
    @EnvironmentObject private var store: ReviewStore
    @Environment(\.dismiss) private var dismiss

    @State private var entries: [AssetEntry] = []
    @State private var isDeleting = false
    @State private var errorText: String?

    private let gridSpacing: CGFloat = 10
    private let gridPadding: CGFloat = 12
    private let minCellWidth: CGFloat = 100

    private var totalBytes: Int64 { entries.reduce(0) { $0 + $1.byteSize } }

    private func columnCount(for width: CGFloat) -> Int {
        max(1, Int((width - gridPadding * 2 + gridSpacing) / (minCellWidth + gridSpacing)))
    }

    private func cellSide(for width: CGFloat) -> CGFloat {
        let count = CGFloat(columnCount(for: width))
        let usableWidth = width - gridPadding * 2 - gridSpacing * (count - 1)
        return usableWidth / count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                if entries.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        header
                        GeometryReader { geo in
                            let side = cellSide(for: geo.size.width)
                            let gridColumns = Array(
                                repeating: GridItem(.fixed(side), spacing: gridSpacing),
                                count: columnCount(for: geo.size.width)
                            )

                            ScrollView {
                                LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                                    ForEach(entries) { entry in
                                        cell(entry, side: side)
                                    }
                                }
                                .padding(gridPadding)
                                Color.clear.frame(height: 90)
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        deleteButton
                    }
                }
            }
            .navigationTitle("Silinecekler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { dismiss() }
                }
            }
            .onAppear(perform: reload)
            .alert("Bir sorun oldu", isPresented: Binding(
                get: { errorText != nil },
                set: { if !$0 { errorText = nil } })) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorText ?? "")
            }
        }
    }

    private func reload() {
        entries = service.pendingEntries(store: store)
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(formattedBytes(totalBytes))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.delete)
            Text("\(entries.count) öğe silmeye hazır")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }

    private func cell(_ entry: AssetEntry, side: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            ThumbnailView(asset: entry.asset)
                .frame(width: side, height: side)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottomLeading) {
                    Text(formattedBytes(entry.byteSize))
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.6), in: Capsule())
                        .foregroundStyle(.white)
                        .padding(6)
                }
                .overlay(alignment: .topLeading) {
                    if entry.isVideo {
                        Image(systemName: "video.fill")
                            .font(.caption2)
                            .padding(6)
                            .foregroundStyle(.white)
                    }
                }

            Button {
                store.removePending(id: entry.id)
                withAnimation { reload() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.6))
            }
            .padding(4)
        }
    }

    private var deleteButton: some View {
        Button {
            Task { await commit() }
        } label: {
            HStack {
                if isDeleting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "trash.fill")
                }
                Text(isDeleting ? "Siliniyor…" : "\(entries.count) Öğeyi Sil  ·  \(formattedBytes(totalBytes))")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.delete, in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white)
        }
        .disabled(isDeleting)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func commit() async {
        guard !entries.isEmpty else { return }
        isDeleting = true
        errorText = nil
        let assets = entries.map { $0.asset }
        let ids = entries.map { $0.id }
        let bytes = totalBytes
        do {
            try await service.deleteAssets(assets)
            store.recordDeletion(ids: ids, bytes: bytes)
            service.invalidateDayCache()
            reload()
            isDeleting = false
            dismiss()
        } catch {
            errorText = "Silme tamamlanmadı ya da iptal edildi."
            isDeleting = false
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.keep)
            Text("Silme listesi boş")
                .font(.title3.bold())
            Text("Öğeleri sola kaydırarak buraya ekleyebilirsin.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Kapat") { dismiss() }
                .padding(.top, 8)
        }
        .padding(24)
    }
}

/// Küçük kare önizleme.
struct ThumbnailView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.white.opacity(0.08)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView().tint(.white)
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: CGSize(width: 240, height: 240),
                                              contentMode: .aspectFill,
                                              options: options) { img, _ in
            if let img { image = img }
        }
    }
}
