# PRD - Shot: Coffee Shot Tracker

## Ringkasan

Shot adalah aplikasi Flutter mobile offline-first untuk home barista yang ingin mencatat beans, parameter espresso, hasil ekstraksi, rating, dan tasting notes. Aplikasi harus terasa seperti logbook brewing yang cepat dipakai saat workflow espresso berlangsung, bukan tracker generik.

## Target Pengguna

- Home barista yang melakukan banyak percobaan espresso.
- Pengguna single-device yang membutuhkan riwayat lokal tanpa internet.
- Pengguna yang ingin membandingkan recipe dan menemukan shot terbaik untuk beans tertentu.

## Tujuan MVP

- Mencatat espresso shot dengan input cepat dan urutan sesuai proses brewing.
- Menghitung brew ratio otomatis dari dose dan yield.
- Menampilkan shot terakhir, shot terbaik, dan riwayat yang mudah dibaca.
- Mendukung workflow `Brew Again` untuk mengulang shot lama tanpa mengubah record sumber.
- Menyimpan data beans dan shots secara lokal agar tetap tersedia setelah app restart.

## Non-Goals

- Integrasi scale, grinder, atau espresso machine.
- Online roaster catalog, komunitas, AI tasting, cloud sync, dan backup.
- Inventory komersial, cafe POS, atau workflow multi-user.

## Navigasi MVP

1. Home
2. Beans
3. New Shot
4. History

Settings belum menjadi screen penuh di MVP. Icon settings di Home boleh menjadi stub non-destruktif jika belum ada requirement detail.

## Core Flow

### First Shot

`Add Beans -> bean details -> New Shot -> parameters -> rating/notes -> Save`

### Daily Repeat

`Home -> Brew Again -> prefilled last/best recipe -> edit actual result -> Save`

`Brew Again` adalah workflow penting. Prefill harus membuat record baru, bukan mengubah shot sumber.

## Screen Requirements

### Home

- Greeting singkat tanpa gamification.
- Active atau recent bean card.
- Last Shot dalam format ringkas, contoh: `18g -> 36g * 28s * 1:2.00`.
- Rating dan snippet tasting note.
- Primary CTA `Brew Again`.
- Secondary CTA `New Shot`.
- Recent shots maksimal 3 item.
- Simple insights: total shots, average rating, most-used bean.

### Beans

- List beans berisi nama, roaster, roast level, roast date, dan status active/finished.
- Search.
- Add Bean.
- Filter Active / Finished.
- Archive/mark finished untuk beans yang sudah punya shot.

### Bean Detail

- Detail beans: name, roaster, origin, process, roast level/date, notes, status.
- Best-rated shot summary.
- Shot history untuk beans tersebut.
- CTA New Shot.
- Mark finished/archive.

### New / Edit Shot

Urutan form harus mengikuti brewing:

1. Bean
2. Dose in (g)
3. Yield out (g)
4. Extraction time (sec)
5. Grind setting
6. Temperature (C)
7. Ratio otomatis/read-only
8. Rating
9. Tasting notes

Numeric field memakai keyboard numeric dan unit harus terlihat.

### Shot Detail

- Parameter utama tampil sebagai recipe card.
- Ratio besar dan jelas.
- Rating, tasting notes, dan date/time.
- Actions: Brew Again, Edit, Delete.

### History

- Chronological list.
- Filter by bean, rating, dan date sederhana.
- Row menampilkan dose -> yield, time, ratio, rating.

## Business Rules

- `ratio = yield_g / dose_g`, ditampilkan sebagai `1:x.xx`.
- Dose harus lebih dari 0.
- Yield tidak boleh negatif.
- Temperature, grind, extraction time, rating, dan notes opsional.
- Grind disimpan sebagai text karena skala grinder berbeda.
- Best Shot default adalah rating tertinggi; jika tie pilih yang terbaru.
- User boleh favorite shot manual; favorite mengalahkan best-rated untuk highlight UI.
- Menghapus beans yang punya shot tidak diizinkan di MVP; gunakan archive/finished.

## Acceptance Criteria

- Beans dan shots tersimpan di SQLite lokal dan tetap ada setelah app restart.
- Ratio berubah otomatis saat dose/yield berubah.
- Brew Again membuat shot baru dari prefilled source shot.
- Shot history dapat difilter berdasarkan beans.
- Aplikasi usable tanpa internet.
- Empty state, validation error, delete confirmation, active beans, archived beans, dan missing optional parameters tersedia.

## V2

- Manual recipe templates.
- Pressure/profile notes.
- Grinder profiles.
- Bean age indicator.
- Extraction trend chart.
- Data export.
- Scale integration.
- Backup/restore.
- Cloud sync.
