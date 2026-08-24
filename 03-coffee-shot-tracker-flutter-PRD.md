# PRD — Shot: Coffee Shot Tracker

**Platform:** Mobile — Flutter  
**Persistence:** `sqflite` / SQLite lokal  
**Mode:** Offline-first, single user  
**Prototype target:** Lovable

## 1. Ringkasan produk

Shot adalah logbook espresso pribadi untuk home barista. Pengguna menyimpan beans, recipe/parameter shot, hasil ekstraksi, rating, dan tasting notes sehingga dapat membandingkan percobaan dan menemukan resep terbaik untuk suatu beans.

## 2. Tujuan

- Mencatat satu espresso shot dengan cepat saat workflow brewing berlangsung.
- Menghitung brew ratio otomatis.
- Membuat perbandingan shot sebelumnya mudah dibaca.
- Memiliki identitas visual yang kuat dan berbeda dari tracker generik.

## 3. Scope MVP

Termasuk: Beans, shot log, dose, yield, time, temperature, grind note/value, brew ratio, rating, tasting notes, favorite/best shot, history, duplicate/Brew Again, simple stats.

Tidak termasuk: koneksi Bluetooth ke scale/grinder/machine, online roaster catalog, AI tasting, community recipes, cloud sync, cafe POS, inventory komersial.

## 4. Navigasi

Bottom navigation:

1. Home
2. Beans
3. New Shot
4. History

Settings melalui icon di Home.

## 5. Core flow

### First shot

`Add Beans → bean details → New Shot → parameters → rating/notes → Save`

### Daily repeat

`Home → Brew Again → prefilled last/best recipe → edit actual result → Save`

`Brew Again` adalah fitur kunci agar app terasa dibuat untuk workflow nyata.

## 6. Screen requirements

### Home

- Greeting singkat, tanpa gamification.
- Active/recent bean card.
- Last Shot: `18g → 36g · 28s · 1:2.0`.
- Rating dan note snippet.
- Primary CTA `Brew Again`.
- Secondary `New Shot`.
- Recent shots 3 item.

### Beans

- List bean dengan nama, roaster, roast level, roast date, status active/finished.
- Search.
- Add Bean.
- Optional filter Active / Finished.

### Bean Detail

- Name, roaster, origin, process, roast level/date.
- Best-rated shot summary.
- Shot history untuk bean tersebut.
- CTA New Shot.
- Mark beans as finished/archive.

### New / Edit Shot

Urutan form mengikuti brewing:

1. Bean
2. Dose in (g)
3. Yield out (g)
4. Extraction time (sec)
5. Grind setting — text/decimal karena skala grinder berbeda
6. Temperature (°C, optional)
7. Ratio otomatis/read-only
8. Rating
9. Tasting notes

Numeric fields menggunakan keypad sesuai tipe. Unit selalu terlihat.

### Shot Detail

- Parameter utama ditampilkan seperti recipe card.
- Ratio besar dan jelas.
- Rating + notes.
- Date/time.
- Actions: Brew Again, Edit, Delete.

### History

- Chronological list.
- Filter by bean, rating, date.
- Setiap row menampilkan dose → yield, time, ratio, rating.

### Simple Insights

- Total shots.
- Average rating.
- Most-used bean.
- Untuk bean aktif: highlight rentang time/ratio dari shot ber-rating tertinggi jika data mencukupi. Ini perhitungan lokal sederhana, bukan AI/rekomendasi medis/sains.

## 7. Business rules & calculations

- `ratio = yield_grams / dose_grams` dan ditampilkan `1 : x.xx`.
- Dose harus >0; yield tidak boleh negatif.
- Temperature, grind, rating, dan notes opsional.
- Grind disimpan sebagai text agar mendukung `4.2`, `12 clicks`, atau nama setting lain.
- Best Shot default = rating tertinggi; jika tie pilih yang terbaru. User boleh favorite sebuah shot secara manual.
- Menghapus beans yang punya shot tidak diizinkan; archive sebagai gantinya, kecuali seluruh related data secara eksplisit ikut dihapus.

## 8. Model data lokal

### beans
`id, name, roaster?, origin?, process?, roast_level?, roast_date?, notes?, status, created_at, updated_at`

### shots
`id, bean_id, dose_g, yield_g, extraction_sec?, temperature_c?, grind_setting?, rating?, tasting_notes?, is_favorite, brewed_at, created_at, updated_at`

Ratio sebaiknya dihitung dari dose/yield, bukan menjadi source of truth terpisah.

## 9. Arahan UI/UX Lovable

Karakter: craft, warm, precise. Gunakan palette espresso brown + warm cream untuk light mode dan deep charcoal + muted caramel untuk dark mode. Jangan membuat seluruh UI berwarna cokelat; neutral surfaces tetap dominan.

- Recipe numbers adalah hero visual.
- Gunakan unit chips/labels yang sangat jelas.
- Bentuk card clean seperti tasting/recipe card.
- Hindari ilustrasi coffee cup generik pada setiap layar.
- Rating dan tasting note dibuat mudah dibaca tetapi tidak mengambil alih flow input.

### Adaptive mobile

- Small 320–359dp: parameter recipe menjadi 2-column compact grid atau stack jika sempit.
- Medium 360–399dp: baseline.
- Large ≥400dp: spacing dan parameter card lebih lega.
- Portrait-first; keyboard numeric tidak boleh menutup Save/Next flow.

## 10. State wajib

No beans, no shots, active beans dengan beberapa shots, bean archived, missing optional parameters, validation error, delete confirmation, light/dark Home dan New Shot.

## 11. Acceptance criteria

- Beans dan shot tersimpan dan tersedia setelah app restart.
- Ratio selalu dihitung benar ketika dose/yield berubah.
- Brew Again mengisi recipe berdasarkan shot sumber tanpa mengubah record lama.
- Shot history dapat difilter berdasarkan bean.
- Aplikasi sepenuhnya berguna tanpa internet.

## 12. V2

Manual recipe templates, pressure/profile notes, grinder profiles, bean age indicator, extraction trend chart, data export, scale integration, backup/restore, dan cloud sync.

