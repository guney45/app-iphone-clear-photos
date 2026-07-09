import SwiftUI
import UIKit
import Photos

/// Kök görünüm: izin durumuna göre doğru ekrana yönlendirir.
struct ContentView: View {
    @EnvironmentObject private var service: PhotoLibraryService

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            switch service.authorizationStatus {
            case .authorized, .limited:
                HomeView()
            case .notDetermined:
                PermissionView()
            default:
                DeniedView()
            }
        }
    }
}

/// İlk açılışta izin isteyen tanıtım ekranı.
struct PermissionView: View {
    @EnvironmentObject private var service: PhotoLibraryService

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)

            VStack(spacing: 12) {
                Text("Fotoğrafların senin, kararların senin")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Bu uygulama fotoğraf ve videolarını tek tek gösterir; sağa kaydırınca saklarsın, sola kaydırınca silmek için işaretlersin.\n\nHer şey telefonunda kalır. Hiçbir fotoğraf, video ya da bilgi internete gönderilmez.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)

            Spacer()

            Button {
                Task { await service.requestAuthorization() }
            } label: {
                Text("Fotoğraflara Eriş")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

/// İzin reddedilmişse Ayarlar'a yönlendiren ekran.
struct DeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.delete)
            Text("Fotoğraf erişimi kapalı")
                .font(.title2.bold())
            Text("Uygulamanın çalışması için Ayarlar > ClearPhotos bölümünden fotoğraf erişimine izin ver. En iyi sonuç için \"Tam Erişim\" seç.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Ayarları Aç")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
