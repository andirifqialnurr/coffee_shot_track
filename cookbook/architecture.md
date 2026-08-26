# Architecture

## Prinsip

- Offline-first dan single user.
- SQLite lokal sebagai source of truth.
- Domain utama adalah coffee menu order log, bukan espresso-only shot log.
- Menu dan cafe adalah master data yang dipilih saat membuat order.
- Bean bersifat optional pada order karena pesanan cafe sering tidak mencantumkan beans.
- Foto disimpan sebagai local file path; SQLite tidak menyimpan binary image.
- Ratio dan brew parameters adalah optional advanced brewing fields.
- UI tetap memakai Flutter Material 3 yang dikustomisasi sesuai warm espresso design-system yang sudah ada.
- Struktur file dipisah per tanggung jawab: app shell, domain, data store, feature screens, dan shared widgets.

## Stack

- Flutter stable sesuai repo.
- `sqflite` untuk database lokal.
- `path` untuk resolusi path database.
- Image picker/file storage dependency dapat ditambahkan pada batch implementasi upload gambar.
- State menggunakan GetX (`Bindings`, `GetxController`, `Rx`, dan `Obx`) agar state global reactive tanpa menambah layer UI yang berat.

## Struktur Folder Target

```text
lib/
  main.dart
  app/
    shot_app.dart
    shot_binding.dart
    shot_theme.dart
  domain/
    coffee_bean.dart
    coffee_menu.dart
    cafe.dart
    coffee_order.dart
    order_metrics.dart
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
    menus/
      menus_page.dart
      menu_detail_page.dart
      menu_form_sheet.dart
    cafes/
      cafes_page.dart
      cafe_form_sheet.dart
    orders/
      order_form_page.dart
      order_detail_page.dart
    history/
      history_page.dart
    stats/
      stats_page.dart
  shared/
    widgets/
      shot_ui.dart
      image_placeholder.dart
```

Existing names such as `ShotController`, `ShotShell`, and `shot_theme.dart` may remain during migration to avoid unnecessary churn. New user-facing labels should move toward `Order`, `Menu`, and `Cafe`.

## Data Flow

1. `ShotApp` builds the Material root and injects the app theme.
2. `ShotBinding` registers the main GetX controller.
3. UI reads the controller through `Get.find<ShotController>()`.
4. UI sections that depend on orders, beans, menus, cafes, loading, or errors use `Obx`.
5. `ShotController` queries/mutates SQLite through `ShotDatabase`.
6. After mutation succeeds, `ShotController.refresh()` reads SQLite and refreshes reactive lists.
7. Image upload stores the selected file under app-local storage and persists only its path.

## Routing Target

- Bottom navigation remains in `ShotShell`.
- Main tabs: Home, Beans, Menus, History.
- Global icon-only floating action opens New Order.
- Detail/edit screens use `Navigator.push`.
- Add/Edit Bean, Menu, and Cafe may use modal bottom sheets for fast entry.
- Cafe master can be opened from New Order until it needs a primary tab.

## Domain Boundaries

### Master Data

- `CoffeeBean`: bean identity and optional photo.
- `CoffeeMenu`: menu/drink identity and optional photo.
- `Cafe`: place identity and optional photo.

### Transaction Data

- `CoffeeOrder`: one consumed/ordered drink.
- Required links: menu and cafe.
- Optional links: bean.
- Optional order image, price, rating, tasting notes, and advanced brewing fields.

## Error Handling

- Required menu/cafe validation happens before order mutation.
- Rating is validated as 1 to 5 when present.
- SQLite exceptions surface as short SnackBar messages.
- Delete order always uses confirmation dialog.
- Master data used by existing orders is archived instead of deleted.
- Missing images always render a designed placeholder.

## Testing Strategy

- Unit tests: model mapping, order validation, optional bean behavior, derived ratio when brew fields exist.
- Store tests: menu/cafe/bean/order persistence, legacy shot migration, archive rules.
- Widget tests: app boot, Home last orders, New Order required fields, History filters.
- Manual validation: add menu, add cafe, add bean with/without image, add order with/without bean, upload image, verify placeholder, restart app, filter history.
