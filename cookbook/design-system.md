# Design System

## Source of Truth

Task 11 uses `main2.dart` as the UI source of truth. That file is a single-file Flutter prototype with mock in-memory data, so implementation must copy the visual language and interaction structure while preserving the real app boundaries: GetX state management, SQLite persistence, existing domain models, and current workflow behavior.

The previous neutral shadcn-styled surface is deprecated for this app. `shadcn_ui` may remain available for support utilities, but screens and shared components should match the warm espresso prototype instead of generic shadcn defaults.

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
- Recipe hero number: 30sp, weight 800.
- Brew ratio: 26-28sp, weight 800.
- Section label: 12sp, weight 700, uppercase, letter spacing 0.
- Body: 14sp, weight 400-600 depending on hierarchy.
- Captions and metadata: 11-13sp.
- Do not scale font size with viewport width.

## Spacing and Radius

- Page gutter: 20dp.
- Vertical rhythm: 8-18dp.
- Inputs and parameter tiles: 14dp radius.
- Rows, buttons, stat cards, and rating panels: 16dp radius.
- Bean detail cards: 18dp radius.
- Recipe cards and active bean cards: 20dp radius.
- Bottom sheets: 24dp top radius with a visible drag handle.
- Bottom navigation: full-width bottom surface with four icon-led destinations.

## Component Map

- `ShotShell`: full-screen `Scaffold`, `SafeArea(top: false)`, one active tab body, and custom bottom nav for Home, Beans, New Shot, History.
- Shared primitives: section labels, star rating display/input, unit chips, status pills, recipe card, hero numbers, empty state, primary/secondary buttons, filter chips, stat cards, and shot rows.
- Home: greeting, `Shot` title, Insights action, Settings action, active bean gradient card, Last Shot recipe card, tasting notes quote, Brew Again/New Shot actions, and Recent Shots rows.
- Beans: page title, rounded search field, horizontal status filters, bordered bean rows, status pills, and extended Add Bean action.
- Add Bean: bottom sheet with drag handle, labeled fields, roast-level chips, and full-width save action.
- Bean Detail: app bar action menu, top bean info card, metadata chips, Best Shot recipe card, Shot History rows, archive action, and bottom New Shot button.
- New/Edit Shot: app bar, bean selector, parameter grid, live Brew Ratio panel, star rating input, tasting notes box, and sticky save bar.
- Shot Detail: date header, RecipeCard, Rating & Notes card, sticky Brew Again/Edit/Delete action area, and themed confirmation dialog.
- History: page title, horizontal bean filter chips, horizontal rating filter chips, bordered shot rows, and preserved date filtering where already implemented.
- Insights: real local data for total shots, average rating, most-used bean, and active-bean highlight ranges.
- Settings: dark-mode switch wired to app theme state.

## Replacement Rule

Replace conflicting old helpers in `lib/shared/widgets/shot_ui.dart` instead of restyling them piecemeal. In particular, old neutral shadcn cards, badges, metric tiles, dropdown-heavy filters, and centered card-based nav should be removed where they conflict with `main2.dart`.

## Accessibility and Responsiveness

- Tap targets should stay at least 44dp.
- Text must remain readable against warm cream and dark charcoal surfaces.
- Bottom nav labels, bean names, recipe numbers, filter chips, CTA buttons, and parameter tiles must not overflow on 320dp-wide screens.
- Status cannot rely on color alone; keep visible `Active` / `Finished` labels.
- Ratio, date, and rating values need visible text context.
