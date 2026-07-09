import SwiftUI
import UIKit
import Photos

/// Tek bir fotoğraf/video kartı: görsel/video + boyut ve bilgiler.
struct CardView: View {
    let entry: AssetEntry
    let isTop: Bool

    @EnvironmentObject private var service: PhotoLibraryService
    @StateObject private var imageLoader = AssetImageLoader()
    @StateObject private var videoLoader = VideoLoader()

    private var isVideo: Bool { entry.isVideo }
    private var sizeToShow: Int64 { max(entry.byteSize, imageLoader.displaySize) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // Önizleme görseli (video için de poster görevi görür)
                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                // Üstteki kartsa ve videoysa oynatıcıyı görselin üzerine koy
                if isVideo, isTop, let player = videoLoader.player {
                    PlayerLayerView(player: player)
                }

                if imageLoader.image == nil && videoLoader.player == nil {
                    ProgressView().tint(.white)
                }

                // Bilgi çubuğu
                VStack {
                    HStack {
                        Spacer()
                        if isVideo {
                            controlBadges
                        }
                    }
                    Spacer()
                    infoBar
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 18, y: 10)
            .onAppear {
                imageLoader.load(asset: entry.asset,
                                 targetSize: CGSize(width: geo.size.width * 2, height: geo.size.height * 2),
                                 knownSize: entry.byteSize,
                                 service: service)
                if isVideo, isTop {
                    videoLoader.load(asset: entry.asset)
                }
            }
            .onChange(of: isTop) { nowTop in
                if nowTop, isVideo {
                    videoLoader.load(asset: entry.asset)
                }
            }
            .onDisappear {
                imageLoader.cancel()
                videoLoader.teardown()
            }
        }
    }

    // MARK: - Bilgi çubuğu

    private var infoBar: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedBytes(sizeToShow))
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: isVideo ? "video.fill" : "photo.fill")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(18)
        .background(
            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.75)],
                          startPoint: .top, endPoint: .bottom)
        )
    }

    private var controlBadges: some View {
        Button {
            videoLoader.isMuted.toggle()
        } label: {
            Image(systemName: videoLoader.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.subheadline)
                .padding(10)
                .background(.black.opacity(0.5), in: Circle())
                .foregroundStyle(.white)
        }
        .padding(14)
    }

    private var subtitle: String {
        var parts: [String] = []
        if isVideo {
            let d = formattedDuration(entry.asset.duration)
            if !d.isEmpty { parts.append(d) }
        }
        parts.append("\(entry.asset.pixelWidth)×\(entry.asset.pixelHeight)")
        if let date = entry.asset.creationDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.locale = Locale(identifier: "tr_TR")
            parts.append(df.string(from: date))
        }
        return parts.joined(separator: "  ·  ")
    }
}
