import SwiftUI
import UIKit
import Photos
import AVFoundation

/// Bir öğe için küçük/orta boy önizleme görselini ve (gerekirse) dosya boyutunu yükler.
@MainActor
final class AssetImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var displaySize: Int64 = 0

    private var requestID: PHImageRequestID?
    private let manager = PHImageManager.default()

    func load(asset: PHAsset, targetSize: CGSize, knownSize: Int64, service: PhotoLibraryService) {
        // Boyut: sıralama sırasında hesaplanmadıysa arka planda hesapla.
        if knownSize > 0 {
            displaySize = knownSize
        } else {
            Task.detached { [weak self] in
                let size = service.computeSize(for: asset)
                await MainActor.run { self?.displaySize = size }
            }
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        // Not: Bu yalnızca senin KENDİ iCloud'undan (varsa) optimize edilmiş
        // fotoğrafın orijinalini indirir; hiçbir veri dışarı gönderilmez.
        options.isNetworkAccessAllowed = true

        requestID = manager.requestImage(for: asset,
                                         targetSize: targetSize,
                                         contentMode: .aspectFit,
                                         options: options) { [weak self] image, _ in
            guard let image else { return }
            Task { @MainActor in self?.image = image }
        }
    }

    func cancel() {
        if let requestID {
            manager.cancelImageRequest(requestID)
            self.requestID = nil
        }
    }
}

/// Üstteki karttaki video için sessiz, döngüsel oynatıcı hazırlar.
@MainActor
final class VideoLoader: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isMuted: Bool = true {
        didSet { player?.isMuted = isMuted }
    }

    private var endObserver: NSObjectProtocol?
    private var requestID: PHImageRequestID?

    func load(asset: PHAsset) {
        guard player == nil else { return }
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        requestID = PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { [weak self] item, _ in
            guard let item else { return }
            Task { @MainActor in
                guard let self else { return }
                let player = AVPlayer(playerItem: item)
                player.isMuted = self.isMuted
                self.player = player
                player.play()
                self.endObserver = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: item,
                    queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                }
            }
        }
    }

    func teardown() {
        player?.pause()
        player = nil
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }
}

/// AVPlayer'ı kendi kontrolleri olmadan gösteren katman.
/// Kontrol çubuğu olmadığı için üstündeki kaydırma hareketleri sorunsuz çalışır.
final class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspect
        }
    }
}

struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.backgroundColor = .black
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if uiView.player !== player {
            uiView.player = player
        }
    }
}
