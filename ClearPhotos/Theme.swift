import SwiftUI

/// Uygulama genelinde kullanılan renkler ve küçük yardımcılar.
enum Theme {
    static let keep = Color(red: 0.13, green: 0.77, blue: 0.37)   // yeşil
    static let delete = Color(red: 0.95, green: 0.26, blue: 0.31) // kırmızı
    static let skip = Color(red: 0.98, green: 0.72, blue: 0.18)   // sarı
    static let accent = Color(red: 0.29, green: 0.40, blue: 0.88) // indigo

    static let backgroundTop = Color(red: 0.07, green: 0.07, blue: 0.12)
    static let backgroundBottom = Color(red: 0.02, green: 0.02, blue: 0.05)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

/// Byte değerini "1,2 GB" gibi okunur bir metne çevirir.
func formattedBytes(_ bytes: Int64) -> String {
    guard bytes > 0 else { return "—" }
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}

/// Video süresini "1:23" biçiminde döndürür.
func formattedDuration(_ seconds: Double) -> String {
    guard seconds.isFinite, seconds > 0 else { return "" }
    let total = Int(seconds.rounded())
    let m = total / 60
    let s = total % 60
    return String(format: "%d:%02d", m, s)
}
