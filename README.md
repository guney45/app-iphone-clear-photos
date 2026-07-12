# ClearPhotos 🧹📸

Galerindeki fotoğraf ve videoları **tek tek** karşına getiren, **sağa kaydırınca sakla / sola kaydırınca sil** mantığıyla çalışan, tamamen **cihazında çalışan ve hiçbir veriyi internete göndermeyen** kişisel bir iPhone uygulaması.

En önemli özellik: dosyaları **boyuta göre (en büyükten en küçüğe) sıralayabilirsin** — yani "Video + Boyut ↓" seçtiğinde ilk kartta **en büyük videon** gelir. Telefonda en hızlı yer açmanın yolu budur.

---

## 🤔 Önce şu soru: "APK verebilir misin?"

**Hayır — ve bu bir eksiklik değil, imkânsızlık.** APK dosyaları **Android** içindir; iPhone (iOS) APK çalıştıramaz. iPhone uygulamaları Apple araçlarıyla derlenir. Ücretsizdir (Apple'a para vermene gerek yok).

## 🧭 İki kurulum yolu

Bu depoda **aynı uygulamanın iki sürümü** var; ikisinden birini seç:

| Yol | Ne gerekir | Nereye kurulur | Kimin için |
|-----|-----------|----------------|------------|
| **A. Xcode** (`ClearPhotos.xcodeproj`) | Mac + Xcode (büyük indirme) | Doğrudan **iPhone'una** | En garantili yol |
| **B. Swift Playgrounds** (`ClearPhotos.swiftpm`) | **iPad** (veya Mac) + Swift Playgrounds (küçük, ücretsiz) — **Xcode YOK** | iPad'de/Mac'te çalışır | Xcode kurmak istemeyenler |

> **Önemli (Yol B):** Swift Playgrounds uygulamayı iPad/Mac üzerinde çalıştırır, doğrudan iPhone'a kurmaz. Ama **iCloud Fotoğraflar açıksa galerin tüm cihazlarda aynıdır** — iPad'de sildiğin fotoğraf/video iPhone'dan da silinir. Yani iCloud kullanıyorsan Yol B ile de iPhone'unu boşaltmış olursun. iCloud Fotoğraflar kapalıysa Yol B yalnızca o cihazın (iPad'in) galerisini temizler.

---

## ✨ Özellikler

**Senin istediklerin**
- 📥 Kaynak seçme: Tüm Fotoğraflar, **Videolar**, Ekran Görüntüleri, Favoriler, Selfie'ler, Son Eklenenler, Seri Çekimler **ve kendi albümlerin**.
- 📏 **Boyuta göre sıralama (büyükten küçüğe / küçükten büyüğe)** — en çok istediğin özellik, uygulamanın merkezinde.
- 👉 Sağa kaydır = **Sakla**, 👈 Sola kaydır = **Sil listesine ekle**.
- 🔒 %100 cihazda çalışır. Hiçbir fotoğraf/video/bilgi dışarı gönderilmez (kodda ağ isteği yoktur).

**Senin de düşünmediğin, eklediğim özellikler**
- 🗑️ **Kalıcı sil listesi + toplu silme:** Sola kaydırdıkların hemen silinmez; bir "Sil listesi"nde birikir. Bu liste artık **kalıcıdır** — uygulamayı kapatsan, ana ekrana dönsen bile kaybolmaz. Ana ekranda **"X öğe silinmeyi bekliyor"** kartından her an girip **kaç GB** kazanacağını görür, tek dokunuşla hepsini silersin. (Silmediğin sürece "sil" etiketi kalıcı olarak durur; sadece sen onaylayınca gerçekten silinir.)
- 📅 **Yoğun gün önerisi:** Özel günlerde/etkinliklerde çok fotoğraf çekilir, çoğu da gereksizdir. Uygulama, bir günde eşiği (varsayılan **100**) aşan öğe varsa o günü ana ekranda **önerir** — "23 Haziran 2018 · 1000 öğe" gibi. Dokununca **sadece o günün** foto/videolarını incelersin. Eşiği **Ayarlar**'dan değiştirebilirsin.
- ⚙️ **Ayarlar ekranı:** Yoğun gün eşiği, "incelenenleri atla", sil listesini boşaltma, incelemeyi/istatistiği sıfırlama.
- ↩️ **Geri Al (Undo):** Yanlış kaydırdıysan bir önceki karta dön.
- ⏭️ **Atla (yukarı kaydır):** Kararsızsan öğeyi bırak, sonra tekrar gelsin.
- 🧠 **İncelenenleri hatırlama:** Karar verdiğin öğeler bir daha karşına çıkmaz (kapatılabilir). Böylece binlerce fotoğrafı birkaç oturumda bitirirsin.
- 📊 **Kazanç sayacı:** "Şimdiye kadar X GB yer açtın" — motive eder.
- ▶️ **Video oynatıcı:** Videolar sessiz ve döngüsel oynar; **ilerleme çubuğunu sürükleyip** videonun ilerisine bakabilir, oynat/duraklat ve sesi açıp kapatabilirsin. Kontroller kartın dışındadır, böylece kaydırma sorunsuz çalışır.
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

## 🚀 Yol A — Xcode ile kurulum (adım adım, hiç uygulama yapmamış biri için)

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

## 🟢 Yol B — Xcode olmadan: Swift Playgrounds

Xcode kurmak istemiyorsan bu yol tam sana göre. **Swift Playgrounds** ücretsizdir ve Xcode'a göre çok daha küçüktür.

### iPad ile (en pratik)
1. iPad'e App Store'dan **Swift Playgrounds**'u kur (ücretsiz).
2. Bu depodaki **`ClearPhotos.swiftpm`** klasörünü iPad'e aktar:
   - En kolayı: Mac'ten iPad'e **AirDrop** ile gönder (klasörü seç, AirDrop), ya da
   - iCloud Drive / Dosyalar uygulamasına koyup iPad'de aç.
3. `ClearPhotos.swiftpm`'e dokun → **Swift Playgrounds** ile açılır.
4. Sağ üstteki **▶ (Çalıştır / Run)** ile başlat. Fotoğraf izni ister → **Tam Erişim** ver.
5. Kaydırarak temizle. **iCloud Fotoğraflar açıksa** sildiklerin iPhone'undan da gider.

> Aktarırken klasör tek dosya gibi görünmezse: `ClearPhotos.swiftpm` klasörünü **zip'leyip** gönder, iPad'de Dosyalar'da açınca Swift Playgrounds tanır. (İstersen bunu senin için hazır zip olarak da verebilirim.)

### Mac ile
1. Mac App Store'dan **Swift Playgrounds**'u kur (Xcode'a göre çok küçük).
2. `ClearPhotos.swiftpm`'i Swift Playgrounds ile aç, **▶ Run**.
3. Uygulama Mac'te çalışır ve Mac'in Fotoğraflar kitaplığına erişir. **iCloud Fotoğraflar açıksa** yaptığın silmeler iPhone'a da yansır.

### Yol B'nin sınırları (dürüstçe)
- Uygulama **iPhone'un üstünde** çalışmaz; iPad/Mac'te çalışır. iPhone'u ancak **iCloud Fotoğraflar** üzerinden dolaylı temizler.
- iCloud Fotoğraflar kapalıysa yalnızca çalıştırdığın cihazın galerisi etkilenir.
- Uygulama simgesini Swift Playgrounds içinden (proje ayarları) sonradan ekleyebilirsin.

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
6. Sağ üstteki **🗑️ rozetine** (ya da ana ekrandaki **"silinmeyi bekliyor"** kartına) dokun → sil listesini gör, kazanacağın yeri kontrol et, **hepsini sil**.
7. Silinenler **Fotoğraflar → Albümler → Son Silinenler**'e gider; oradan hemen kalıcı silersen yer anında boşalır.

**Yoğun günler:** Ana ekranda, çok fotoğraf çektiğin günler önerilir (ör. "23 Haziran 2018 · 1000 öğe"). Dokununca sadece o günü incelersin. Kaç öğeden itibaren önerileceğini **⚙️ Ayarlar → Yoğun gün eşiği**'nden ayarla.

**Sil listesi kalıcı:** Sola kaydırıp "sil" dediklerin, sen onaylayana kadar **kaybolmaz** (uygulamayı kapatsan bile). Ana ekrandaki kırmızı karttan her an ulaşırsın. Fikrin değişirse Ayarlar'dan listeyi (silmeden) boşaltabilirsin.

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
ClearPhotos.xcodeproj      → Yol A: Xcode projesi (çift tıkla)
ClearPhotos.swiftpm/       → Yol B: Swift Playgrounds sürümü (Xcode gerekmez)
ClearPhotos/
  ClearPhotosApp.swift     → Uygulama girişi
  ContentView.swift        → İzin ekranları + yönlendirme
  HomeView.swift           → Ana ekran: kaynak/sıralama/filtre + istatistik
  SwipeDeckView.swift      → Kart destesi, kaydırma, butonlar
  CardView.swift           → Tek foto/video kartı
  TrashReviewView.swift    → Kalıcı sil listesi + toplu silme
  SettingsView.swift       → Ayarlar (yoğun gün eşiği, sıfırlamalar)
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
