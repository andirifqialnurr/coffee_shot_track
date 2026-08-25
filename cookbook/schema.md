# Schema

## Database

SQLite lokal dengan nama database `shot_tracker.db`.

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
| status | TEXT | Yes | `active` or `finished` |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

## Table: shots

| Column | Type | Required | Notes |
| --- | --- | --- | --- |
| id | INTEGER PRIMARY KEY AUTOINCREMENT | Yes | Local id |
| bean_id | INTEGER | Yes | FK to `beans.id` |
| dose_g | REAL | Yes | Must be > 0 |
| yield_g | REAL | Yes | Must be >= 0 |
| extraction_sec | INTEGER | No | Espresso time in seconds |
| temperature_c | REAL | No | Brew temperature |
| grind_setting | TEXT | No | Flexible grinder setting |
| rating | INTEGER | No | 1 to 5 |
| tasting_notes | TEXT | No | Free text |
| is_favorite | INTEGER | Yes | 0 or 1 |
| brewed_at | TEXT | Yes | ISO-8601 datetime |
| created_at | TEXT | Yes | ISO-8601 datetime |
| updated_at | TEXT | Yes | ISO-8601 datetime |

## Indexes

- `idx_shots_bean_id` on `shots(bean_id)`
- `idx_shots_brewed_at` on `shots(brewed_at DESC)`
- `idx_beans_status` on `beans(status)`

## Derived Values

### Ratio

```text
ratio = yield_g / dose_g
display = 1:x.xx
```

Ratio is derived at read/render time.

### Best Shot

Priority:

1. Favorite shot for that bean, newest first if multiple.
2. Highest rating, newest first if tie.
3. Latest shot if rating is missing.

## Delete Rules

- Shot can be deleted after confirmation.
- Bean without shots can be deleted.
- Bean with shots must be archived or marked `finished`.
