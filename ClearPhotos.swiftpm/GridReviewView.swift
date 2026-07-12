import SwiftUI
import UIKit
import Photos

/// Izgara modu: küçük fotoğrafları hızlıca göz gezdirip birden çok seçerek silersin.
/// Bir öğeye basılı tutunca büyük önizleme açılır. (Örneğin yoğun bir günde
/// başkalarına ait fotoğrafları gözünle ayıklamak için idealdir.)
struct GridReviewView: View {
    @EnvironmentObject private var service: PhotoLibraryService
    @EnvironmentObject private var store: ReviewStore
    @Environment(\.dismiss) private var dismiss

    @State private var entries: [AssetEntry]
    @State private var selected: Set<String> = []
    @State private var previewEntry: AssetEntry?
    @State private var isDeleting = false
    @State private var errorText: String?

    init(entries: [AssetEntry]) {
        _entries = State(initialValue: entries)
    }

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 6)]

    private var selectedEntries: [AssetEntry] { entries.filter { selected.contains($0.id) } }
    private var selectedBytes: Int64 { selectedEntries.reduce(0) { $0 + $1.byteSize } }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            if entries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 6) {
                        ForEach(entries) { entry in
                            cell(entry)
                        }
                    }
                    .padding(8)
                    Color.clear.frame(height: 90)
                }

                if !selected.isEmpty {
                    VStack {
                        Spacer()
                        deleteBar
                    }
                }
            }
        }
        .navigationTitle("\(entries.count) öğe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selected.isEmpty {
                    Button("Tümünü Seç") { selected = Set(entries.map { $0.id }) }
                } else {
                    Button("Bırak") { selected.removeAll() }
                }
            }
        }
        .fullScreenCover(item: $previewEntry) { entry in
            PreviewView(entry: entry,
                        service: service,
                        onDelete: { Task { await deleteEntries([entry]) } })
        }
        .alert("Bir sorun oldu", isPresented: Binding(
            get: { errorText != nil },
            set: { if !$0 { errorText = nil } })) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorText ?? "")
        }
    }

    // MARK: - Hücre

    private func cell(_ entry: AssetEntry) -> some View {
        let isSel = selected.contains(entry.id)
        return ThumbnailView(asset: entry.asset)
            .aspectRatio(1, contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .bottomLeading) {
                if entry.byteSize > 0 {
                    Text(formattedBytes(entry.byteSize))
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.55), in: Capsule())
                        .foregroundStyle(.white)
                        .padding(4)
                }
            }
            .overlay(alignment: .topLeading) {
                if entry.isVideo {
                    Image(systemName: "video.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.white)
                        .padding(4)
                        .shadow(radius: 2)
                }
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: isSel ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isSel ? .white : .white.opacity(0.85),
                                     isSel ? Theme.delete : .black.opacity(0.25))
                    .padding(4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSel ? Theme.delete : .clear, lineWidth: 3)
            )
            .opacity(isSel ? 0.85 : 1)
            .contentShape(Rectangle())
            .onTapGesture { toggle(entry) }
            .onLongPressGesture(minimumDuration: 0.35) { previewEntry = entry }
    }

    private func toggle(_ entry: AssetEntry) {
        if selected.contains(entry.id) {
            selected.remove(entry.id)
        } else {
            selected.insert(entry.id)
        }
    }

    // MARK: - Silme çubuğu

    private var deleteBar: some View {
        Button {
            Task { await deleteEntries(selectedEntries) }
        } label: {
            HStack {
                if isDeleting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "trash.fill")
                }
                Text(isDeleting
                     ? "Siliniyor…"
                     : "\(selected.count) Öğeyi Sil  ·  \(formattedBytes(selectedBytes))")
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

    private func deleteEntries(_ items: [AssetEntry]) async {
        guard !items.isEmpty else { return }
        isDeleting = true
        errorText = nil
        // Boyut hesaplanmadıysa (tarih/rastgele sıralamada) şimdi hesapla.
        let sized = items.map { item -> AssetEntry in
            var e = item
            if e.byteSize == 0 { e.byteSize = service.computeSize(for: e.asset) }
            return e
        }
        let ids = sized.map { $0.id }
        let bytes = sized.reduce(0) { $0 + $1.byteSize }
        do {
            try await service.deleteAssets(sized.map { $0.asset })
            store.recordDeletion(ids: ids, bytes: bytes)
            service.invalidateDayCache()
            let idSet = Set(ids)
            entries.removeAll { idSet.contains($0.id) }
            selected.subtract(idSet)
            previewEntry = nil
            isDeleting = false
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
            Text("Hepsi bitti")
                .font(.title3.bold())
            Button("Ana Ekrana Dön") { dismiss() }
                .padding(.top, 8)
        }
        .padding(24)
    }
}

/// Basılı tutunca açılan büyük önizleme.
struct PreviewView: View {
    let entry: AssetEntry
    let service: PhotoLibraryService
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var imageLoader = AssetImageLoader()
    @StateObject private var videoLoader = VideoLoader()

    private var isVideo: Bool { entry.isVideo }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }
            if isVideo, let player = videoLoader.player {
                PlayerLayerView(player: player).ignoresSafeArea()
            }
            if imageLoader.image == nil && videoLoader.player == nil {
                ProgressView().tint(.white)
            }

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .padding(12)
                            .background(.black.opacity(0.5), in: Circle())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Text(formattedBytes(max(entry.byteSize, imageLoader.displaySize)))
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.black.opacity(0.5), in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding()

                Spacer()

                if isVideo {
                    videoScrubber
                }

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Kapat", systemImage: "chevron.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    Button {
                        onDelete()
                    } label: {
                        Label("Sil", systemImage: "trash.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.delete, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            imageLoader.load(asset: entry.asset,
                             targetSize: CGSize(width: 1600, height: 2000),
                             knownSize: entry.byteSize,
                             service: service)
            if isVideo { videoLoader.load(asset: entry.asset) }
        }
        .onDisappear { videoLoader.teardown() }
    }

    private var videoScrubber: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { min(videoLoader.currentTime, max(videoLoader.duration, 0.1)) },
                    set: { videoLoader.seek(to: $0) }
                ),
                in: 0...max(videoLoader.duration, 1),
                onEditingChanged: { editing in videoLoader.isScrubbing = editing }
            )
            .tint(Theme.accent)
            HStack {
                Button { videoLoader.togglePlayPause() } label: {
                    Image(systemName: videoLoader.isPlaying ? "pause.fill" : "play.fill")
                }
                Text("\(formattedDuration(videoLoader.currentTime)) / \(formattedDuration(videoLoader.duration))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Button { videoLoader.isMuted.toggle() } label: {
                    Image(systemName: videoLoader.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                }
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }
}
