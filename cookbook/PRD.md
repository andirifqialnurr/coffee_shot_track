# PRD - Shot: Coffee Menu Order Tracker

## Ringkasan

Shot adalah aplikasi Flutter mobile offline-first untuk mencatat menu kopi yang dipesan atau diminum, termasuk menu, cafe, beans jika diketahui, foto, rating, tasting notes, dan riwayat konsumsi. Aplikasi tetap memakai identitas visual warm espresso yang sudah ada, tetapi domainnya tidak lagi terbatas pada espresso brewing.

Fokus baru aplikasi adalah logbook pesanan/minuman kopi pribadi: pengguna bisa mengingat menu apa yang pernah dicoba, di cafe mana, memakai beans apa jika tersedia, bagaimana rasanya, dan mana yang layak dipesan lagi.

## Target Pengguna

- Pengguna yang sering mencoba menu kopi di banyak cafe.
- Home brewer yang juga ingin mencatat menu kopi di luar rumah.
- Pengguna single-device yang membutuhkan riwayat lokal tanpa internet.
- Pengguna yang ingin membandingkan menu, cafe, beans, rating, foto, dan catatan rasa.

## Tujuan MVP Baru

- Mencatat satu coffee order dengan cepat.
- Memilih menu, cafe, dan beans saat menambahkan log.
- Menyimpan foto untuk bean, menu, cafe, dan order jika tersedia.
- Menampilkan placeholder visual yang tetap menarik saat foto tidak tersedia.
- Menampilkan order terakhir dan riwayat yang mudah dibaca.
- Menyimpan data master dan order secara lokal agar tetap tersedia setelah app restart.

## Non-Goals

- Cafe POS, pembayaran, inventory komersial, multi-user, dan reservasi.
- Online cafe catalog, community review, cloud sync, dan AI recommendation.
- Integrasi otomatis dengan mesin espresso, grinder, scale, atau loyalty platform.
- Klaim objektif kualitas rasa; rating dan notes bersifat personal.

## Navigasi MVP Baru

Bottom navigation:

1. Home
2. Beans
3. Menus
4. History

Floating action button global:

- Icon-only `New Order` / `Add` action untuk membuka form order baru.

Route tambahan:

- Cafe master dapat menjadi screen dari form order atau dari menu management entry point. Jika ruang navigasi diperlukan, `Cafes` bisa menjadi tab menggantikan `Beans` atau masuk ke menu/settings, tetapi versi pertama cukup sebagai master screen yang bisa dibuka dari form.

## Core Flow

### First Order

`Add Menu -> Add Cafe -> optional Add Bean -> New Order -> choose menu/cafe/bean -> add rating/notes/photo -> Save`

### Repeat Order

`Home -> Last Order -> Order Again -> prefilled menu/cafe/bean -> edit actual result -> Save`

`Order Again` menggantikan konsep `Brew Again`. Prefill harus membuat record baru, bukan mengubah record sumber.

## Screen Requirements

### Home

- Greeting singkat tanpa gamification.
- Tidak perlu active bean card di atas content utama.
- `Last Shot` boleh diganti menjadi `Last Orders` atau `Last Menu`.
- Section terakhir menampilkan maksimal 2 card horizontal dan bisa di-scroll tanpa indikator.
- `See all` sejajar kanan dengan label section dan menuju History.
- Hapus section `Recent Shots` agar tidak dobel dengan last/recent order cards.
- Card order menampilkan menu, cafe, bean jika ada, rating, waktu/tanggal, notes snippet, dan foto/placeholder.

### Beans

- List beans berisi nama, roaster, origin/process/roast level jika ada, status active/finished, dan image/placeholder.
- Search.
- Add Bean dengan optional photo upload.
- Filter Active / Finished.
- Archive/mark finished untuk beans yang sudah punya order/log terkait.

### Menus

- Master menu kopi yang bisa dipilih saat menambahkan order.
- List menu berisi nama, category, description/notes, dan image/placeholder.
- Contoh menu: Espresso, Americano, Latte, Cappuccino, V60, Aeropress, Japanese Iced Coffee, Manual Brew, Signature Drink.
- Add/Edit Menu dengan optional photo upload.
- Menu tidak boleh dihapus jika sudah dipakai order, kecuali diarsipkan.

### Cafes

- Master cafe yang bisa dipilih saat menambahkan order.
- List cafe berisi nama, area/address optional, notes, dan image/placeholder.
- Sediakan default cafe `Home` untuk order buatan sendiri.
- Add/Edit Cafe dengan optional photo upload.
- Cafe tidak boleh dihapus jika sudah dipakai order, kecuali diarsipkan.

### New / Edit Order

Urutan form mengikuti konteks pemesanan:

1. Menu, required
2. Cafe, required
3. Bean, optional jika diketahui
4. Photo, optional
5. Price, optional
6. Rating, optional
7. Tasting notes, optional
8. Ordered at, default now

Untuk espresso/manual brew yang ingin mencatat parameter teknis, field dose/yield/time/grind/temperature dapat dipertahankan sebagai optional advanced section, bukan field utama.

### Order Detail

- Foto atau placeholder visual di bagian atas card.
- Menu, cafe, bean jika ada, date/time, rating, notes, dan optional price.
- Optional brew parameters hanya tampil jika pernah diisi.
- Actions: Order Again, Edit, Delete.

### History

- Chronological list.
- Filter by menu, cafe, bean, rating, dan date.
- Row/card menampilkan menu, cafe, rating, tanggal, foto/placeholder, dan notes singkat.

### Stats

- Total orders.
- Average rating.
- Most-ordered menu.
- Most-visited cafe.
- Rating/order trend yang rapi tanpa informasi dobel.

## Business Rules

- Order wajib memiliki `menu_id` dan `cafe_id`.
- `bean_id` opsional karena pesanan cafe sering tidak diketahui beans-nya.
- Sediakan cafe default `Home`.
- Sediakan menu default awal agar user bisa langsung mencatat order.
- Foto disimpan sebagai local file path, bukan binary di SQLite.
- Jika foto tidak tersedia, UI wajib memakai placeholder visual reusable yang tidak polos.
- Delete master data yang sudah dipakai order harus dicegah atau diarahkan ke archive.
- Rating jika diisi harus 1 sampai 5.
- Price opsional dan tidak menjadi fitur finance utama.
- Ratio dan brew parameters hanya berlaku untuk order yang punya parameter brewing.

## Acceptance Criteria

- Menu, cafe, beans, dan orders tersimpan di SQLite lokal dan tetap ada setelah app restart.
- User bisa membuat order dengan menu dan cafe.
- User bisa membuat order tanpa bean jika bean tidak diketahui.
- User bisa upload foto untuk menu, cafe, bean, dan order.
- Placeholder visual muncul konsisten saat foto kosong.
- Home menampilkan maksimal 2 last order cards secara horizontal dan `See all` menuju History.
- History dapat difilter berdasarkan menu, cafe, bean, rating, dan date.
- Aplikasi tetap usable tanpa internet.
- Tema visual tetap mengikuti warm espresso design-system yang sudah ada.

## V2

- Map/location metadata untuk cafe.
- Favorite menu/cafe.
- Tag rasa terstruktur.
- Data export.
- Backup/restore.
- Cloud sync optional.
- Advanced brewing templates untuk home brew.
