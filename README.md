# ClearPhotos 🧹📸

Galerindeki fotoğraf ve videoları **tek tek** karşına getiren, **sağa kaydırınca sakla / sola kaydırınca sil** mantığıyla çalışan, tamamen **cihazında çalışan ve hiçbir veriyi internete göndermeyen** kişisel bir iPhone uygulaması.

En önemli özellik: dosyaları **boyuta göre (en büyükten en küçüğe) sıralayabilirsin** — yani "Video + Boyut ↓" seçtiğinde ilk kartta **en büyük videon** gelir. Telefonda en hızlı yer açmanın yolu budur.

---

## 🤔 Önce şu soru: "APK verebilir misin?"

**Hayır — ve bu bir eksiklik değil, imkânsızlık.** APK dosyaları **Android** içindir; iPhone (iOS) APK çalıştıramaz. iPhone uygulamaları **Xcode** ile derlenir ve senin Mac'in bunun için yeterli. Aşağıda hiç uygulama yapmamış biri için adım adım anlattım. Ücretsizdir (Apple'a para vermene gerek yok).

---

## ✨ Özellikler

**Senin istediklerin**
- 📥 Kaynak seçme: Tüm Fotoğraflar, **Videolar**, Ekran Görüntüleri, Favoriler, Selfie'ler, Son Eklenenler, Seri Çekimler **ve kendi albümlerin**.
- 📏 **Boyuta göre sıralama (büyükten küçüğe / küçükten büyüğe)** — en çok istediğin özellik, uygulamanın merkezinde.
- 👉 Sağa kaydır = **Sakla**, 👈 Sola kaydır = **Sil listesine ekle**.
- 🔒 %100 cihazda çalışır. Hiçbir fotoğraf/video/bilgi dışarı gönderilmez (kodda ağ isteği yoktur).

**Senin de düşünmediğin, eklediğim özellikler**
- 🗑️ **Toplu silme + önizleme:** Sola kaydırdıkların hemen silinmez; bir "Sil listesi"nde birikir. Silmeden önce **kaç öğe / kaç GB** kazanacağını görürsün, sonra tek dokunuşla hepsini silersin. (Kazara silmeyi önler.)
- ↩️ **Geri Al (Undo):** Yanlış kaydırdıysan bir önceki karta dön.
- ⏭️ **Atla (yukarı kaydır):** Kararsızsan öğeyi bırak, sonra tekrar gelsin.
- 🧠 **İncelenenleri hatırlama:** Karar verdiğin öğeler bir daha karşına çıkmaz (kapatılabilir). Böylece binlerce fotoğrafı birkaç oturumda bitirirsin.
- 📊 **Kazanç sayacı:** "Şimdiye kadar X GB yer açtın" — motive eder.
- ▶️ **Videolar otomatik, sessiz ve döngüsel oynar** (dokununca sesi açarsın); kaydırma bu sırada sorunsuz çalışır.
- 🎞️ Her kartta **boyut**, tür, çözünürlük, tarih ve video süresi görünür.
- 📳 Kararlarda hafif **titreşim (haptik)** geri bildirimi.
- 🌙 Şık koyu tema.
- 🛡️ Silinenler kalıcı gitmez; iOS'un **"Son Silinenler"** albümüne düşer (30 gün geri alma süresi). Oradan istersen hemen kalıcı silip yeri boşaltırsın.

> Silme sırasında iOS kendi güvenlik onay penceresini de gösterir — yani asla "yanlışlıkla toplu silme" olmaz.

---

## 🧰 Gereksinimler

- **Mac** (sende var ✅) — üzerinde **Xcode** kurulu (Mac App Store'dan ücretsiz).
- **iPhone** + Mac'e bağlamak için **kablo** (ilk kurulum için kablo en kolayı).
- Bir **Apple ID** (App Store'da kullandığın hesap yeterli — ücretsiz).

> Xcode büyük bir indirmedir (birkaç GB). Mac App Store'dan "Xcode" aratıp kur, bir kez açıp lisansı kabul et.

---

## 🚀 Kurulum — Adım Adım (hiç uygulama yapmamış biri için)

### 1) Projeyi Mac'e indir
Bu depoyu Mac'ine indir:
- GitHub sayfasında yeşil **Code → Download ZIP** ile indirip aç, **veya**
- Terminal'de:
  ```bash
  git clone <bu-deponun-adresi>
  ```

### 2) Projeyi Xcode'da aç
`ClearPhotos.xcodeproj` dosyasına **çift tıkla**. Xcode açılır.

### 3) İmzalama (Signing) — kendi Apple ID'ni ekle
Bu adım "bu uygulama bana ait" demektir; ücretsizdir.
1. Sol üstteki mavi **ClearPhotos** proje simgesine tıkla.
2. Ortadaki **TARGETS > ClearPhotos**'u seç.
3. Üstten **Signing & Capabilities** sekmesine geç.
4. **Automatically manage signing** işaretli olsun.
5. **Team** açılır menüsünden Apple ID'ni seç. Görünmüyorsa **Add an Account…** de, Apple ID'nle giriş yap (bu "Personal Team" olur, ücretsizdir).
6. **Bundle Identifier**'ı **benzersiz** yap. Örn: `com.adin.ClearPhotos` (com.example... yerine kendi adını yaz). Kırmızı hata çıkarsa burayı değiştirmen yeterli.

### 4) iPhone'unu bağla ve seç
1. iPhone'u kabloyla Mac'e tak. iPhone'da "**Bu bilgisayara güven**" çıkarsa **Güven** de.
2. Xcode'un üst ortasındaki cihaz menüsünden (çalıştır ▶ butonunun yanında) **kendi iPhone'unu** seç.

### 5) Çalıştır
Sol üstteki **▶ (Run)** butonuna bas. Xcode uygulamayı derler ve iPhone'una yükler.

### 6) iPhone'da geliştiriciye güven (ilk seferde bir kez)
İlk açılışta iPhone "Güvenilmeyen Geliştirici" diyebilir:
1. iPhone'da **Ayarlar → Genel → VPN ve Cihaz Yönetimi**'ne git.
2. Kendi Apple ID'ni bul, **Güven** de.
3. Uygulamayı tekrar aç.

### 7) İlk açılış izni
Uygulama fotoğraf izni ister. **"Tam Erişim"** ver (tüm fotoğrafları yönetmek ve silmek için gerekir).

🎉 Bitti! Artık kaydırarak temizleyebilirsin.

---

## ⏳ Önemli: Ücretsiz hesap sınırı (7 gün)

Ücretsiz Apple ID ("Personal Team") ile kurduğun uygulamalar **7 gün** sonra "süresi doldu" der ve açılmaz. Çözüm çok basit:
- iPhone'u tekrar Mac'e bağla, Xcode'da yine **▶ Run**'a bas. Sayaç sıfırlanır, verilerin (istatistikler) korunur.

Bu senin gibi "sadece kendim kullanacağım" biri için tamamen yeterli. **7 gün sınırını kaldırmak** istersen (yılda bir yenileme yeter):
- **Apple Developer Program** (yılda **99 USD**) üyesi olursan uygulama **1 yıl** boyunca çalışır. Zorunlu değil; sen bilirsin.

---

## 📱 Nasıl kullanılır

1. **Kaynak** seç (ör. *Videolar* ya da *Tüm Fotoğraflar* ya da bir albüm).
2. **Sıralama** seç → yer açmak için **Boyut ↓ (büyükten)**.
3. **Tür** seç (Hepsi / Fotoğraf / Video).
4. **Başla**'ya bas (boyuta göre sıralarken dosya boyutları okunurken kısa bir "Hazırlanıyor" beklemesi olur).
5. Kartlarda:
   - 👉 **Sağa kaydır** = Sakla
   - 👈 **Sola kaydır** = Sil listesine ekle
   - 👆 **Yukarı kaydır** = Atla (sonra tekrar gelsin)
   - Alttaki butonlarla da aynısını yapabilir, **Geri Al**'a basabilirsin.
6. Sağ üstteki **🗑️ rozetine** dokun → sil listesini gör, kazanacağın yeri kontrol et, **hepsini sil**.
7. Silinenler **Fotoğraflar → Albümler → Son Silinenler**'e gider; oradan hemen kalıcı silersen yer anında boşalır.

---

## 🔐 Gizlilik / Güvenlik

- Uygulama **hiçbir sunucuya bağlanmaz**, hesap istemez, reklam/analiz içermez. Kodun tamamı bu depoda; ağ isteği yoktur.
- Her şey iPhone'unda kalır. "Kendim için yapıyorum, kimseye vermek istemiyorum" derken kastettiğin şey birebir budur.
- Fotoğraflar iCloud'da "optimize" saklanıyorsa, önizleme için gerektiğinde **senin kendi iCloud'undan** indirilir — yine hiçbir veri üçüncü tarafa gitmez.

---

## 🛠️ Sık karşılaşılan sorunlar

- **"Signing for ClearPhotos requires a development team"** → 3. adımdaki **Team** seçimini yap.
- **"Failed to register bundle identifier"** → Bundle Identifier'ı benzersiz yap (ör. `com.adin.ClearPhotos2`).
- **Uygulama açılmıyor / "Untrusted Developer"** → 6. adım (Ayarlar → VPN ve Cihaz Yönetimi → Güven).
- **"7 gün sonra açılmadı"** → Normal. Tekrar ▶ Run ile yükle.
- **Boyut sıralaması yavaş** → İlk seferde tüm öğelerin boyutu okunur; sonraki oturumlarda aynı seansta önbelleğe alınır. Çok büyük kütüphanelerde ilk hazırlık biraz sürebilir.

---

## 🗂️ Proje yapısı

```
ClearPhotos.xcodeproj      → Xcode projesi (çift tıkla)
ClearPhotos/
  ClearPhotosApp.swift     → Uygulama girişi
  ContentView.swift        → İzin ekranları + yönlendirme
  HomeView.swift           → Ana ekran: kaynak/sıralama/filtre + istatistik
  SwipeDeckView.swift      → Kart destesi, kaydırma, butonlar
  CardView.swift           → Tek foto/video kartı
  TrashReviewView.swift    → Sil listesi + toplu silme
  SwipeDeckViewModel.swift → Oturum mantığı (sakla/sil/atla/geri al)
  PhotoLibraryService.swift→ PhotoKit: izin, boyut hesabı, sıralama, silme
  ReviewStore.swift        → İstatistik ve "incelendi" kaydı (cihazda)
  Loaders.swift            → Görsel/video yükleyiciler
  Models.swift / Theme.swift → Tipler ve renkler
  Assets.xcassets          → Uygulama simgesi ve renk
```

---

## ℹ️ Notlar

- Hedef: **iOS 16+**. Uygulama iPhone'da (ve iPad'de) çalışır.
- Dosya boyutu, iOS'un `PHAssetResource` bilgisinden okunur. Bu, App Store'a yükleme için değil, **kişisel kullanım** içindir.
- İstersen `PRODUCT_BUNDLE_IDENTIFIER`, uygulama adı ve simgeyi kolayca değiştirebilirsin.

Kolay gelsin — telefonun bir an önce ferahlasın! 🧹
