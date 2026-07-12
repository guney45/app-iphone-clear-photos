import Foundation
import Photos

/// Kartların hangi sıraya göre geleceği.
enum SortOption: String, CaseIterable, Identifiable {
    case sizeDescending   // Boyut: büyükten küçüğe  (senin en çok istediğin özellik)
    case sizeAscending    // Boyut: küçükten büyüğe
    case dateNewest       // Tarih: en yeni
    case dateOldest       // Tarih: en eski
    case random           // Rastgele

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sizeDescending: return "Boyut ↓ (büyükten)"
        case .sizeAscending:  return "Boyut ↑ (küçükten)"
        case .dateNewest:     return "En yeni"
        case .dateOldest:     return "En eski"
        case .random:         return "Rastgele"
        }
    }

    var systemImage: String {
        switch self {
        case .sizeDescending: return "arrow.down.to.line"
        case .sizeAscending:  return "arrow.up.to.line"
        case .dateNewest:     return "clock"
        case .dateOldest:     return "clock.arrow.circlepath"
        case .random:         return "shuffle"
        }
    }

    /// Bu sıralama için her öğenin dosya boyutunu hesaplamamız gerekiyor mu?
    var requiresSize: Bool {
        self == .sizeDescending || self == .sizeAscending
    }
}

/// Fotoğraf / video filtresi.
enum MediaKindFilter: String, CaseIterable, Identifiable {
    case all
    case photos
    case videos

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:    return "Hepsi"
        case .photos: return "Fotoğraf"
        case .videos: return "Video"
        }
    }

    var systemImage: String {
        switch self {
        case .all:    return "square.grid.2x2"
        case .photos: return "photo"
        case .videos: return "video"
        }
    }

    /// Photos sorgusunda kullanılacak medya türü. `nil` ise filtre uygulanmaz.
    var mediaType: PHAssetMediaType? {
        switch self {
        case .all:    return nil
        case .photos: return .image
        case .videos: return .video
        }
    }
}

/// Bir fotoğraf/video ve (hesaplandıysa) dosya boyutu.
struct AssetEntry: Identifiable, Equatable {
    let asset: PHAsset
    var byteSize: Int64

    var id: String { asset.localIdentifier }
    var isVideo: Bool { asset.mediaType == .video }

    static func == (lhs: AssetEntry, rhs: AssetEntry) -> Bool {
        lhs.id == rhs.id
    }
}

/// Kartların çekileceği kaynak (tüm kütüphane, bir albüm ya da akıllı albüm).
struct MediaSource: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    /// `nil` ise tüm fotoğraf kütüphanesi kullanılır.
    let collection: PHAssetCollection?
    /// Doluysa yalnızca bu tarih aralığındaki öğeler getirilir (ör. tek bir gün).
    var dateInterval: DateInterval? = nil
}

/// Belirli bir günde çekilen/kaydedilen öğe sayısı (yoğun gün önerisi için).
struct DaySummary: Identifiable {
    let dayStart: Date
    let count: Int

    var id: Double { dayStart.timeIntervalSince1970 }

    var dayEnd: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
    }

    var interval: DateInterval {
        DateInterval(start: dayStart, end: dayEnd)
    }

    var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: dayStart)
    }
}
