# PRD - Shot: Coffee Menu Order Tracker

**Platform:** Mobile - Flutter
**Persistence:** `sqflite` / local SQLite
**Mode:** Offline-first, single user
**Design direction:** Keep the existing warm espresso visual system

## 1. Product Summary

Shot is a personal coffee menu order tracker. It helps users record coffee drinks they ordered or drank, including menu, cafe, optional bean, photo, rating, tasting notes, and history.

The product is no longer espresso-only. Espresso brew parameters can remain as optional advanced data, but the main workflow is tracking coffee menu orders across cafes and home brewing.

## 2. Goals

- Record a coffee order quickly.
- Track what menu was ordered, where it was ordered, and which bean was used when known.
- Store local photos for beans, menus, cafes, and orders.
- Show non-plain default placeholders when no photo is uploaded.
- Make order history easy to scan and filter.
- Preserve the app's existing warm cream, espresso brown, and caramel visual identity.

## 3. MVP Scope

Included:

- Beans master data.
- Menus master data.
- Cafes master data.
- Coffee order log.
- Optional bean per order.
- Optional image per bean/menu/cafe/order.
- Rating and tasting notes.
- Last orders on Home.
- History filters.
- Simple stats.
- Offline SQLite persistence.

Not included:

- Cafe POS, payments, inventory, multi-user workflows, online cafe catalog, AI recommendations, cloud sync, loyalty integrations, or automatic device integrations.

## 4. Navigation

Bottom navigation:

1. Home
2. Beans
3. Menus
4. History

Global floating action button:

- Icon-only add action for creating a new order.

Additional routes:

- New/Edit Order.
- Order Detail.
- Menu Detail/Add/Edit.
- Cafe master screen/Add/Edit.
- Settings.
- Stats may remain as a Home action or become a tab later if navigation is rebalanced.

## 5. Core Flow

### First Order

`Add Menu -> Add Cafe -> optional Add Bean -> New Order -> choose menu/cafe/bean -> add photo/rating/notes -> Save`

### Repeat Order

`Home -> Last Order -> Order Again -> prefilled menu/cafe/bean -> edit actual result -> Save`

`Order Again` creates a new order from the source order. It must not mutate the previous record.

## 6. Screen Requirements

### Home

- Greeting and compact page title.
- No active bean card above the main order section.
- `Last Shot` should be renamed in implementation to `Last Orders` or another order-oriented label.
- Last order area shows at most 2 horizontally scrollable cards.
- No separate `Recent Shots` section.
- `See all` aligns with the right edge of the `Last Orders` label row and opens History.
- Each card shows menu, cafe, optional bean, rating, date/time, notes snippet, and image/placeholder.

### Beans

- List beans with name, roaster/origin/process/roast level where available, active/finished status, image/placeholder, and order count.
- Search.
- Add/Edit Bean.
- Optional image upload.
- Active/Finished filters.
- Archive instead of hard delete when related orders exist.

### Menus

- Master data for drink/menu names.
- List menu cards with image/placeholder, name, category, notes, and usage count.
- Add/Edit Menu.
- Optional image upload.
- Archive instead of hard delete when related orders exist.
- Starter menu examples may include Espresso, Americano, Latte, Cappuccino, V60, Aeropress, Japanese Iced Coffee, Manual Brew, and Signature Drink.

### Cafes

- Master data for cafe/place names.
- List cafe cards with image/placeholder, name, area/address, notes, and visit/order count.
- Add/Edit Cafe.
- Optional image upload.
- Include default `Home` cafe for home-brewed drinks.
- Archive instead of hard delete when related orders exist.

### New / Edit Order

Primary fields:

1. Menu, required
2. Cafe, required
3. Bean, optional
4. Photo, optional
5. Price, optional
6. Rating, optional
7. Tasting notes, optional
8. Ordered at, default now

Advanced brewing fields:

- Dose in (g), optional
- Yield out (g), optional
- Extraction time (sec), optional
- Grind setting, optional
- Temperature (C), optional
- Ratio, derived only when dose and yield are present

### Order Detail

- Image or placeholder at the top of the detail card.
- Menu, cafe, optional bean, date/time, rating, notes, and optional price.
- Advanced brewing details only when filled.
- Actions: Order Again, Edit, Delete.

### History

- Chronological list.
- Filter by menu, cafe, bean, rating, and date.
- Row/card displays image/placeholder, menu, cafe, date, rating, and notes snippet.

### Stats

- Total orders.
- Average rating.
- Most-ordered menu.
- Most-visited cafe.
- Trend chart with no duplicate information.

## 7. Business Rules

- Every order must have a menu and cafe.
- Bean is optional because cafe orders often do not expose bean information.
- Default cafe `Home` should exist.
- Default starter menus should exist.
- Photo paths are stored locally; SQLite stores file paths, not binary image data.
- Placeholder visuals are mandatory for empty images and must use the existing design language.
- Master data used by orders should be archived instead of deleted.
- Rating must be 1 to 5 when present.
- Price is optional and informational only.
- Brew ratio is derived, not stored as source of truth.

## 8. Local Data Model

### beans

`id, name, roaster?, origin?, process?, roast_level?, roast_date?, notes?, image_path?, status, created_at, updated_at`

### menus

`id, name, category?, description?, notes?, image_path?, status, created_at, updated_at`

### cafes

`id, name, area?, address?, notes?, image_path?, status, created_at, updated_at`

### orders

`id, menu_id, cafe_id, bean_id?, image_path?, price?, rating?, tasting_notes?, ordered_at, created_at, updated_at`

Advanced brewing columns may remain on `orders`:

`dose_g?, yield_g?, extraction_sec?, temperature_c?, grind_setting?, is_favorite`

## 9. UI/UX Direction

The domain expands to all coffee menus, but the visual identity must stay consistent with the existing app:

- Warm cream background.
- Espresso brown primary color.
- Caramel accent.
- White/surface cards.
- Compact, polished mobile layout.
- Rounded but controlled card radii.
- Icon-led controls.
- No generic Material default look.
- No plain empty image boxes; use designed placeholders.

## 10. Required States

- No menu.
- No cafe.
- No beans.
- No orders.
- Order with menu and cafe only.
- Order with menu, cafe, and bean.
- Order with uploaded photo.
- Order with placeholder image.
- Archived menu/cafe/bean.
- Validation error.
- Delete confirmation.
- Light/dark mode.

## 11. Acceptance Criteria

- Menu, cafe, beans, and orders persist after app restart.
- New order requires menu and cafe.
- New order can be saved without bean.
- Image upload works for menu, cafe, bean, and order.
- Placeholder appears when no image is uploaded.
- Home shows at most 2 last order cards horizontally.
- History filters by menu, cafe, bean, rating, and date.
- App remains usable offline.
- Existing visual theme is preserved.

## 12. V2

- Favorite menu and cafe.
- Location/map metadata.
- Taste tag analytics.
- Export.
- Backup/restore.
- Optional cloud sync.
- Brewing templates for advanced home brew users.
