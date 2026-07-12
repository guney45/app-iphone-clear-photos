import SwiftUI
import UIKit
import Photos
import AVFoundation

/// Tek bir fotoğraf/video kartı: görsel/video + boyut ve bilgiler.
/// Video oynatıcı (varsa) dışarıdan verilir; kontroller kart dışındadır,
/// böylece kaydırma hareketiyle çakışmaz.
struct CardView: View {
    let entry: AssetEntry
    let isTop: Bool
    /// Yalnızca üstteki video kart için dolu olur.
    var player: AVPlayer? = nil

    @EnvironmentObject private var service: PhotoLibraryService
    @StateObject private var imageLoader = AssetImageLoader()

    private var isVideo: Bool { entry.isVideo }
    private var sizeToShow: Int64 { max(entry.byteSize, imageLoader.displaySize) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                if let image = imageLoader.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                }

                if let player {
                    PlayerLayerView(player: player)
                }

                if imageLoader.image == nil && player == nil {
                    ProgressView().tint(.white)
                }

                VStack {
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
            }
            .onDisappear {
                imageLoader.cancel()
            }
        }
    }

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
