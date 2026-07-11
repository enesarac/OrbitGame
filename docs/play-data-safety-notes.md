# Google Play Data Safety Notları

Bu dosya, Play Console'daki **Data safety** formunu doldururken kullanılacak teknik kontrol listesidir. Formu gönderirken son uygulama kodu ve kullanılan SDK sürümleriyle tekrar kontrol edilmelidir.

## Kullanılan servisler

- Google AdMob
- Firebase Analytics
- Firebase Crashlytics
- SharedPreferences ile yerel cihaz depolaması

## Uygulama izinleri

- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`

## Hesap ve doğrudan kişisel veri

- Kullanıcı hesabı yok.
- Geliştirici doğrudan ad, e-posta, telefon, adres, fotoğraf, kişi listesi, kamera, mikrofon veya konum izni istemiyor.
- GPS/hassas konum izni yok.

## Play Console'da işaretlenmesi muhtemel veri türleri

AdMob ve Firebase SDK'ları nedeniyle aşağıdaki kategoriler kontrol edilmelidir:

- **Device or other IDs:** reklam kimliği, uygulama örneği kimliği veya benzeri tanımlayıcılar.
- **App activity:** uygulama etkileşimleri, oyun olayları, reklam etkileşimleri.
- **App info and performance:** çökme günlükleri, tanılama ve performans bilgileri.
- **Approximate location:** AdMob IP adresinden genel konum çıkarımı yapabildiği için bu kategori dikkatle değerlendirilmelidir. Uygulama GPS konumu istemez.

## Veri paylaşımı

Google AdMob, Firebase Analytics ve Firebase Crashlytics kullanıldığı için veriler Google servisleriyle işlenebilir/paylaşılabilir. Formda "data shared" soruları Google'ın SDK açıklamalarına göre cevaplanmalıdır.

## Güvenlik ve silme

- SDK verileri Google servisleri tarafından aktarım sırasında şifrelenir.
- Yerel oyun verileri cihazda tutulur.
- Kullanıcı uygulamayı kaldırarak veya uygulama verilerini temizleyerek yerel verileri silebilir.
- Reklam kimliği Android ayarlarından sıfırlanabilir veya silinebilir.

## Play Console'a girilecek gizlilik politikası URL'si

GitHub Pages aktif edildikten sonra beklenen URL:

`https://enesarac.github.io/OrbitGame/privacy-policy.html`

Bu URL aktif, herkese açık, PDF olmayan ve düzenlenemez bir HTML sayfası olmalıdır.
