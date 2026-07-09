import Foundation
import Photos
import UIKit

/// Farklı thread'lerden güvenle kullanılabilen basit boyut önbelleği.
final class SizeCache {
    private var storage: [String: Int64] = [:]
    private let lock = NSLock()

    func get(_ key: String) -> Int64? {
        lock.lock(); defer { lock.unlock() }
        return storage[key]
    }

    func set(_ key: String, _ value: Int64) {
        lock.lock(); defer { lock.unlock() }
        storage[key] = value
    }
}

/// Fotoğraf kütüphanesiyle ilgili tüm işler burada:
/// izin, kaynakları listeleme, boyut hesaplama, sıralama, görsel/video yükleme ve silme.
///
/// ÖNEMLİ: Bu sınıf hiçbir yere ağ isteği göndermez. Her şey cihazda kalır.
@MainActor
final class PhotoLibraryService: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus
    @Published var sources: [MediaSource] = []

    private let sizeCache = SizeCache()

    init() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .authorized || authorizationStatus == .limited {
            loadSources()
        }
    }

    var hasAccess: Bool {
        authorizationStatus == .authorized || authorizationStatus == .limited
    }

    // MARK: - İzin

    func requestAuthorization() async {
        let status: PHAuthorizationStatus = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
        if hasAccess {
            loadSources()
        }
    }

    // MARK: - Kaynaklar

    func loadSources() {
        var result: [MediaSource] = []

        // Tüm kütüphane
        result.append(MediaSource(id: "all",
                                  title: "Tüm Fotoğraflar",
                                  systemImage: "photo.on.rectangle.angled",
                                  collection: nil))

        func addSmart(_ subtype: PHAssetCollectionSubtype, title: String, image: String) {
            let fetched = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                 subtype: subtype,
                                                                 options: nil)
            if let collection = fetched.firstObject {
                result.append(MediaSource(id: collection.localIdentifier,
                                          title: title,
                                          systemImage: image,
                                          collection: collection))
            }
        }

        addSmart(.smartAlbumVideos,        title: "Videolar",          image: "video")
        addSmart(.smartAlbumScreenshots,   title: "Ekran Görüntüleri", image: "camera.viewfinder")
        addSmart(.smartAlbumFavorites,     title: "Favoriler",         image: "heart")
        addSmart(.smartAlbumSelfPortraits, title: "Selfie'ler",        image: "person.crop.square")
        addSmart(.smartAlbumRecentlyAdded, title: "Son Eklenenler",    image: "clock")
        addSmart(.smartAlbumBursts,        title: "Seri Çekimler",     image: "square.stack.3d.down.right")

        // Kullanıcının kendi albümleri
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        userAlbums.enumerateObjects { collection, _, _ in
            let title = collection.localizedTitle ?? "Albüm"
            result.append(MediaSource(id: collection.localIdentifier,
                                      title: title,
                                      systemImage: "rectangle.stack",
                                      collection: collection))
        }

        sources = result
    }

    // MARK: - Boyut hesaplama

    /// Bir öğenin diskte kapladığı yaklaşık byte değeri.
    /// Live Photo veya düzenlenmiş öğelerde birden fazla kaynak olabilir; hepsini toplarız.
    nonisolated func computeSize(for asset: PHAsset) -> Int64 {
        let key = asset.localIdentifier
        if let cached = sizeCache.get(key) { return cached }

        var total: Int64 = 0
        let resources = PHAssetResource.assetResources(for: asset)
        for resource in resources {
            if let number = resource.value(forKey: "fileSize") as? NSNumber {
                total += number.int64Value
            }
        }
        sizeCache.set(key, total)
        return total
    }

    // MARK: - Kart listesini oluşturma

    /// Seçilen kaynak + filtre + sıralamaya göre tüm öğeleri hazırlar.
    /// Boyut gereken sıralamalarda ilerlemeyi `progress` ile bildirir.
    func buildEntries(source: MediaSource,
                      filter: MediaKindFilter,
                      sort: SortOption,
                      progress: @escaping (Int, Int) -> Void) async -> [AssetEntry] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let options = PHFetchOptions()
                if let mediaType = filter.mediaType {
                    options.predicate = NSPredicate(format: "mediaType == %d", mediaType.rawValue)
                }
                switch sort {
                case .dateNewest:
                    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                case .dateOldest:
                    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                default:
                    break
                }

                let fetchResult: PHFetchResult<PHAsset>
                if let collection = source.collection {
                    fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                } else {
                    fetchResult = PHAsset.fetchAssets(with: options)
                }

                var assets: [PHAsset] = []
                assets.reserveCapacity(fetchResult.count)
                fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }

                let total = assets.count
                let needSize = sort.requiresSize
                var entries: [AssetEntry] = []
                entries.reserveCapacity(total)

                var processed = 0
                for asset in assets {
                    let size = needSize ? self.computeSize(for: asset) : 0
                    entries.append(AssetEntry(asset: asset, byteSize: size))
                    processed += 1
                    if needSize && processed % 40 == 0 {
                        let snapshot = processed
                        DispatchQueue.main.async { progress(snapshot, total) }
                    }
                }

                switch sort {
                case .sizeDescending: entries.sort { $0.byteSize > $1.byteSize }
                case .sizeAscending:  entries.sort { $0.byteSize < $1.byteSize }
                case .random:         entries.shuffle()
                default:              break
                }

                DispatchQueue.main.async {
                    progress(total, total)
                    continuation.resume(returning: entries)
                }
            }
        }
    }

    // MARK: - Silme

    /// Seçilen öğeleri siler. iOS kendi onay penceresini gösterir; onaylanınca
    /// öğeler "Son Silinenler" albümüne taşınır (30 gün sonra kalıcı silinir).
    func deleteAssets(_ assets: [PHAsset]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? NSError(domain: "ClearPhotos.delete", code: -1))
                }
            }
        }
    }
}
