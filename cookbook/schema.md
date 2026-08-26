# Schema

## Database

SQLite lokal dengan nama database `shot_tracker.db`.

Dokumen ini mendeskripsikan target schema baru untuk perubahan domain dari espresso shot tracker menjadi coffee menu order tracker. Implementasi saat ini masih memakai tabel `beans` dan `shots`; migrasi berikutnya harus menjaga data lama dan memetakan `shots` ke konsep `orders`.

## Table: beans

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Yes | Local id |
| name | TEXT | Yes | Bean name |
| roaster | TEXT | No | Roaster name |
| origin | TEXT | No | Country/farm/region |
| process | TEXT | No | Washed, natural, honey, etc |
| roast_level | TEXT | No | Light, medium, dark, or custom |
| roast_date | TEXT | No | ISO-8601 date |
| notes | TEXT | No | Bean notes |
| image_path | TEXT | No | Local photo path |
| status | TEXT | Yes | `active`, `archived`, or `finished` for legacy compatibility |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

## Table: menus

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Yes | Local id |
| name | TEXT | Yes | Menu name, for example Espresso, Americano, Latte, V60 |
| category | TEXT | No | Espresso-based, milk-based, manual brew, signature, other |
| description | TEXT | No | Short display description |
| notes | TEXT | No | Internal notes |
| image_path | TEXT | No | Local photo path |
| status | TEXT | Yes | `active` or `archived` |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

## Table: cafes

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Yes | Local id |
| name | TEXT | Yes | Cafe/place name |
| area | TEXT | No | Short area label |
| address | TEXT | No | Optional address |
| notes | TEXT | No | Personal notes |
| image_path | TEXT | No | Local photo path |
| status | TEXT | Yes | `active` or `archived` |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

## Table: orders

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Yes | Local id |
| menu_id | INTEGER | Yes | FK to `menus.id` |
| cafe_id | INTEGER | Yes | FK to `cafes.id` |
| bean_id | INTEGER | No | FK to `beans.id`, optional when unknown |
| image_path | TEXT | No | Local order/drink photo path |
| price | REAL | No | Optional informational price |
| rating | INTEGER | No | 1 to 5 |
| tasting_notes | TEXT | No | Free text |
| ordered_at | TEXT | Yes | ISO-8601 datetime |
| is_favorite | INTEGER | Yes | 0 or 1 |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

### Optional advanced brewing columns on orders

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| dose_g | REAL | No | Optional for home brew/espresso tracking |
| yield_g | REAL | No | Optional for home brew/espresso tracking |
| extraction_sec | INTEGER | No | Optional espresso time |
| temperature_c | REAL | No | Optional brew temperature |
| grind_setting | TEXT | No | Flexible grinder setting |

## Indexes

- `idx_orders_menu_id` on `orders(menu_id)`
- `idx_orders_cafe_id` on `orders(cafe_id)`
- `idx_orders_bean_id` on `orders(bean_id)`
- `idx_orders_ordered_at` on `orders(ordered_at DESC)`
- `idx_menus_status` on `menus(status)`
- `idx_cafes_status` on `cafes(status)`
- `idx_beans_status` on `beans(status)`

## Seeds

- Menus: Espresso, Americano, Latte, Cappuccino, V60, Aeropress, Japanese Iced Coffee, Manual Brew, Signature Drink.
- Cafes: Home.

## Derived Values

### Ratio

```text
ratio = yield_g / dose_g
display = 1:x.xx
```

Ratio is derived only when `dose_g` and `yield_g` exist and `dose_g > 0`.

### Best/Favorite Order

Priority:

1. Favorite order, newest first if multiple.
2. Highest rating, newest first if tie.
3. Latest order if rating is missing.

## Delete Rules

- Order can be deleted after confirmation.
- Bean/menu/cafe without orders can be deleted.
- Bean/menu/cafe with orders must be archived.

## Migration Notes

- Existing `shots` rows should become `orders`.
- Existing `shots.bean_id` maps to `orders.bean_id`.
- A default menu such as `Espresso` and default cafe `Home` can be assigned to legacy rows during migration.
- Existing dose/yield/time/grind/temperature columns become optional advanced brewing fields on `orders`.
