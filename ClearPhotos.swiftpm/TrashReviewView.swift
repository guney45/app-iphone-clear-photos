import SwiftUI
import UIKit
import Photos

/// Silinmek üzere işaretlenen öğelerin listesi. Buradan tek tek çıkarabilir
/// ya da hepsini birden silebilirsin. Silme sırasında iOS kendi onayını gösterir.
struct TrashReviewView: View {
    @ObservedObject var vm: SwipeDeckViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                if vm.pendingCount == 0 {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        header
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(vm.pendingDelete) { entry in
                                    cell(entry)
                                }
                            }
                            .padding(12)
                            Color.clear.frame(height: 90)
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
            .alert("Bir sorun oldu", isPresented: Binding(
                get: { vm.deleteError != nil },
                set: { if !$0 { vm.deleteError = nil } })) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(vm.deleteError ?? "")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(formattedBytes(vm.pendingBytes))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.delete)
            Text("\(vm.pendingCount) öğe silmeye hazır")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }

    private func cell(_ entry: AssetEntry) -> some View {
        ZStack(alignment: .topTrailing) {
            ThumbnailView(asset: entry.asset)
                .aspectRatio(1, contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
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
                withAnimation { vm.removeFromPile(entry) }
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
            Task {
                await vm.commitDeletions()
                if vm.deleteError == nil && vm.pendingCount == 0 {
                    dismiss()
                }
            }
        } label: {
            HStack {
                if vm.isDeleting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "trash.fill")
                }
                Text(vm.isDeleting ? "Siliniyor…" : "\(vm.pendingCount) Öğeyi Sil  ·  \(formattedBytes(vm.pendingBytes))")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.delete, in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white)
        }
        .disabled(vm.isDeleting)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
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
