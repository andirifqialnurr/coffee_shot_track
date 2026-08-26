# Design System

## Source of Truth

The app keeps the warm espresso visual system introduced by the `main2.dart` UI migration. The domain is now broader than espresso, but the visual identity must not drift into a generic cafe directory, POS app, or plain Material tracker.

Implementation must preserve the real app boundaries: GetX state management, SQLite persistence, local-first behavior, and reusable shared widgets.

`shadcn_ui` may remain available for support utilities, but screens and shared components should match the custom warm espresso Flutter style instead of generic shadcn defaults.

## Product Tone

- Personal coffee logbook.
- Warm, compact, precise, and premium.
- Built for quickly recording what was ordered or brewed.
- Visual language should feel like a thoughtful coffee journal, not a marketplace, review app, or cafe POS.

## Color Tokens

### Light

- Background: `#FBF3E8`
- Surface: `#FFFFFF`
- Surface alternative: `#F2E4D3`
- Primary: `#4E3221`
- On primary: `#FBF3E8`
- Accent: `#C5854A`
- Text primary: `#2B211C`
- Text secondary: `#8A7B6E`
- Border: `#E7D8C4`
- Danger: `#B3492F`
- Success: `#3F7A55`

### Dark

- Background: `#19140F`
- Surface: `#241D17`
- Surface alternative: `#2D241C`
- Primary/accent: `#DFAA6D`
- On primary: `#241A10`
- Text primary: `#F3E9DC`
- Text secondary: `#AA9C8C`
- Border: `#3A2F25`
- Danger: `#E07B5C`
- Success: `#7EC195`

Warm cream, white, espresso brown, charcoal, and caramel are the app identity. Avoid reverting to the old zinc-neutral look. Surfaces must remain readable and bordered in both light and dark mode.

## Typography

- Font family: Montserrat across Material and Shad theme layers.
- Page title: 24-26sp, weight 800.
- Main card title: 15-18sp, weight 700-800.
- Section label: 12-14sp, weight 700, uppercase, letter spacing 0.
- Body: 14sp, weight 400-600 depending on hierarchy.
- Captions and metadata: 10-13sp.
- Do not scale font size with viewport width.

Recipe hero numbers are no longer the default focus for every card because the domain is now menu/order tracking. Use large recipe/ratio typography only when advanced brewing data is present.

## Spacing and Radius

- Page gutter: 20dp.
- Vertical rhythm: 8-18dp.
- Inputs and parameter tiles: 14dp radius.
- Rows, buttons, stat cards, and rating panels: 16dp radius.
- Detail cards: 18dp radius.
- Featured order/menu cards: 16-20dp radius.
- Bottom sheets: 24dp top radius with a visible drag handle.
- Bottom navigation: floating pill, not flush to the bottom edge.
- Global add action: icon-only floating action button.

## Image and Placeholder Rules

Bean, menu, cafe, and order surfaces must support images.

When no image is uploaded, use a designed placeholder instead of a plain empty box:

- Warm surfaceAlt or caramel-tinted background.
- Subtle diagonal/texture/pattern layer.
- Context icon: bean, menu/drink, cafe/place, or order cup.
- Optional initial or short name label.
- Same radius as the containing card image area.
- Works in light and dark mode.

Do not use remote network images for default placeholders. Placeholder rendering must be local and offline-safe.

## Component Map Target

- `ShotShell`: full-screen `Scaffold`, safe-area-aware body, floating bottom navigation for Home, Beans, Menus, History, and icon-only global add FAB for New Order.
- Shared primitives: section labels, image/placeholder tile, star rating display/input, unit chips, status pills, order/menu/cafe cards, empty state, primary/secondary buttons, filter chips, stat cards, and compact list rows.
- Home: greeting, title, settings/stats actions where needed, `Last Orders` horizontal rail with maximum 2 cards, aligned `See all`, and no duplicate recent section.
- Beans: page title, add action, search field, horizontal status filters, image/placeholder rows, centered status pills, and order count.
- Menus: page title, add action, menu category filters, image/placeholder cards, and usage count.
- Cafes: page title, add action, image/placeholder cards, area/address metadata, and visit/order count.
- New/Edit Order: app bar, menu selector, cafe selector, optional bean selector, optional photo, rating, notes, date/time, and optional advanced brewing section.
- Order Detail: image/placeholder hero, menu/cafe/bean metadata, rating, notes, date/time, optional price, optional brew parameters, and Order Again/Edit/Delete actions.
- History: filters by menu, cafe, bean, rating, and date; list rows/cards with image/placeholder and compact metadata.
- Stats: real local data for total orders, average rating, most-ordered menu, most-visited cafe, and trend chart.
- Settings: dark-mode switch wired to app theme state.

## Replacement Rule

Replace conflicting old espresso-only helpers instead of layering new labels on top of them. In particular:

- `Shot` user-facing labels should migrate to `Order` where the screen represents a coffee order.
- `Brew Again` should migrate to `Order Again`.
- Ratio/dose/yield UI should move to optional advanced brewing sections.
- Home should not show an active bean card as the primary context.

Keep file/class names temporarily if that reduces migration risk, but visible copy and data contracts should move toward the new product model.

## Accessibility and Responsiveness

- Tap targets should stay at least 44dp.
- Text must remain readable against warm cream and dark charcoal surfaces.
- Bottom nav labels, bean/menu/cafe names, filter chips, CTA buttons, and card metadata must not overflow on 320dp-wide screens.
- Status cannot rely on color alone; keep visible labels such as `Active`, `Archived`, or `Finished`.
- Images need semantic context through nearby text; do not rely on image alone.
- Placeholder visuals must not reduce text contrast.
