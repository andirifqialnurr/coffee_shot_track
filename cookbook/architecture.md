# Architecture

## Prinsip

- Offline-first dan single user.
- SQLite lokal sebagai source of truth.
- Ratio dihitung dari field shot, bukan disimpan sebagai source of truth.
- UI dibuat dengan Flutter Material 3 yang dikustomisasi, bukan tampilan Material default.
- Struktur file dipisah per tanggung jawab: app shell, domain, data store, feature screens, dan shared widgets.

## Stack

- Flutter stable sesuai repo.
- `sqflite` untuk database lokal.
- `path` untuk resolusi path database.
- State MVP menggunakan GetX (`GetMaterialApp`, `Bindings`, `GetxController`, `Rx`, dan `Obx`) agar state global beans/shots reactive tanpa menambah layer UI yang berat.

## Struktur Folder

```text
lib/
  main.dart
  app/
    shot_app.dart
    shot_binding.dart
    shot_theme.dart
  domain/
    coffee_bean.dart
    espresso_shot.dart
    shot_metrics.dart
  data/
    shot_database.dart
    shot_store.dart
  features/
    shell/
      shot_shell.dart
    home/
      home_page.dart
    beans/
      beans_page.dart
      bean_detail_page.dart
      bean_form_sheet.dart
    shots/
      shot_form_page.dart
      shot_detail_page.dart
    history/
      history_page.dart
  shared/
    widgets/
      shot_card.dart
      shot_empty_state.dart
      shot_metric_tile.dart
```

Implementasi boleh digabung lebih ringkas jika masih menjaga boundary di atas.

## Data Flow

1. `ShotApp` memakai `GetMaterialApp` dan `ShotBinding` untuk mendaftarkan `ShotController`.
2. UI mengambil controller dengan `Get.find<ShotController>()`.
3. UI yang membaca beans/shots/loading dibungkus `Obx`.
4. `ShotController` menjalankan query/mutation melalui `ShotDatabase`.
5. `ShotController` menyimpan snapshot reactive untuk beans, shots, loading, dan error dengan `RxBool`, `RxnString`, `RxList<CoffeeBean>`, dan `RxList<EspressoShot>`.
6. Setelah mutation berhasil, `ShotController.refresh()` membaca ulang SQLite dan mengisi ulang Rx list sehingga UI rebuild otomatis.

## Routing MVP

- Bottom navigation tetap di `ShotShell`.
- Screen utama: Home, Beans, New Shot, History.
- Detail dan form edit dibuka via `Navigator.push`.
- Add Bean dapat memakai modal bottom sheet agar alur input tetap cepat.

## Error Handling

- Validasi input dilakukan sebelum mutation.
- SQLite exception ditampilkan sebagai SnackBar ringkas.
- Delete shot selalu memakai confirmation dialog.
- Bean yang punya shot tidak dihapus; action mengubah status menjadi `finished`.

## Testing Strategy

- Unit/widget smoke: app boot, home empty state, ratio calculation, dan form validation utama.
- Manual validation: tambah beans, tambah shot, Brew Again, edit/delete shot, archive bean, restart app.
