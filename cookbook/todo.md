# TODO

## Current Direction

The completed tasks below describe the original espresso shot MVP and later UI replacement work. The product direction has changed to a coffee menu order tracker: orders require Menu and Cafe, Bean is optional, and espresso brew parameters become optional advanced fields.

Keep the existing warm espresso design system. Do not turn the UI into a generic cafe directory, POS app, or plain Material tracker.

## Task 12 - Coffee Menu Order Tracker Reframe

### Batch 12.1 - Documentation Reframe

- [x] Update root PRD from espresso-only shot tracking to coffee menu order tracking.
- [x] Update `cookbook/PRD.md` with Menu, Cafe, optional Bean, image upload, placeholders, and order history.
- [x] Update `cookbook/schema.md` with target `menus`, `cafes`, and `orders` tables.
- [x] Update `cookbook/architecture.md` with new domain boundaries and migration notes.
- [x] Update `cookbook/design-system.md` without changing the established warm espresso visual identity.
- [ ] Commit and push documentation reframe.

### Batch 12.2 - Home Cleanup

- [x] Remove the active bean card above the last order section.
- [x] Rename `Last Shot` to an order-oriented label such as `Last Orders`.
- [x] Show maximum 2 horizontal order cards.
- [x] Keep current useful card information while reducing width for horizontal scrolling.
- [x] Align `See all` with the section label and route it to History.
- [x] Remove the duplicate `Recent Shots` section.
- [x] Run `flutter analyze` and `flutter test --concurrency=1`.
- [x] Commit and push Home cleanup.

### Batch 12.3 - Menu Master Data

- [x] Add `CoffeeMenu` domain model.
- [x] Add `menus` SQLite table and seed starter menus.
- [x] Add menu CRUD/archive behavior in the store/controller.
- [x] Build Menus tab using the existing warm espresso card style.
- [x] Add menu image path support and default placeholder.
- [x] Run focused persistence and widget tests.
- [x] Commit and push Menu master data.

### Batch 12.4 - Cafe Master Data

- [x] Add `Cafe` domain model.
- [x] Add `cafes` SQLite table and seed default `Home`.
- [x] Add cafe CRUD/archive behavior in the store/controller.
- [x] Build Cafe master screen or entry point from New Order.
- [x] Add cafe image path support and default placeholder.
- [x] Run focused persistence and widget tests.
- [x] Commit and push Cafe master data.

### Batch 12.5 - Order Migration and New Order Form

- [x] Add `CoffeeOrder` domain model.
- [x] Migrate or map current `shots` data into `orders` without losing existing records.
- [x] Require Menu and Cafe when saving a new order.
- [x] Make Bean optional.
- [x] Move dose/yield/time/grind/temperature into optional advanced brewing fields.
- [x] Rename visible `Brew Again` flow to `Order Again`.
- [x] Run migration, persistence, and workflow tests.
- [x] Commit and push order migration.

### Batch 12.6 - Image Upload and Placeholder System

- [x] Add image picker/local file persistence dependency if needed.
- [x] Implement reusable image/placeholder widget for bean, menu, cafe, and order cards.
- [x] Add image upload to Add/Edit Bean.
- [x] Add image upload to Add/Edit Menu.
- [x] Add image upload to Add/Edit Cafe.
- [x] Add image upload to New/Edit Order.
- [x] Verify all empty image states use designed placeholders.
- [x] Run `flutter analyze` and `flutter test --concurrency=1`.
- [ ] Commit and push image support.

### Batch 12.7 - History and Stats Reframe

- [x] Update History filters to menu, cafe, optional bean, rating, and date.
- [x] Update History rows/cards to show menu/cafe-first order context.
- [x] Update Stats to total orders, average rating, most-ordered menu, most-visited cafe, and trend chart.
- [x] Remove duplicate espresso-only metrics from primary UI.
- [x] Run full sequential validation.
- [ ] Commit and push final reframe.

## Task 1 - Cookbook Foundation

- [x] Create `cookbook/PRD.md`.
- [x] Create `cookbook/architecture.md`.
- [x] Create `cookbook/schema.md`.
- [x] Create `cookbook/design-system.md`.
- [x] Create `cookbook/todo.md`.
- [x] Commit and push Task 1 before implementation.

## Task 2 - Domain, Persistence, and App State

- [x] Add dependencies for SQLite local persistence.
- [x] Create domain models for beans and espresso shots.
- [x] Create ratio/best-shot helpers.
- [x] Create SQLite database tables and indexes.
- [x] Create `ShotStore` with refresh and CRUD operations.
- [x] Replace demo counter bootstrap with `ShotApp`.
- [x] Commit and push Task 2 before UI task.

## Task 3 - MVP UI and Workflows

- [x] Build custom Material 3 theme from `design-system.md`.
- [x] Build bottom navigation shell.
- [x] Implement Home with active bean, last shot, Brew Again, New Shot, recent shots, and insights.
- [x] Implement Beans list, search, status filter, Add Bean, and Bean Detail.
- [x] Implement New/Edit Shot form with live ratio and validation.
- [x] Implement Shot Detail with Brew Again, Edit, Delete, and favorite action.
- [x] Implement History with bean/rating filters.
- [x] Commit and push Task 3 before final validation.

## Task 4 - Validation and Polish

- [x] Update widget tests away from counter app.
- [x] Add focused ratio/helper tests if practical.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test --concurrency=1`.
- [x] Fix validation issues found during checks.
- [x] Commit and push Task 4.

## Manual Acceptance Checklist

- [x] Add beans, close app, reopen, and verify beans persist.
- [x] Add shot, close app, reopen, and verify shots persist.
- [x] Change dose/yield and verify ratio updates immediately.
- [x] Use Brew Again and verify source shot remains unchanged.
- [x] Filter history by bean.
- [x] Archive bean with shots instead of deleting it.
- [x] Confirm app remains usable without internet.

## Acceptance Evidence

- Persistence and restart-read behavior are covered by `test/shot_store_acceptance_test.dart`.
- Brew Again source immutability and bean archive behavior are covered by `test/shot_store_acceptance_test.dart`.
- Live ratio update and History bean filtering are covered by `test/workflow_acceptance_test.dart`.
- Offline readiness is source-verified: app code has no HTTP, URI request, `Image.network`, or `NetworkImage` usage in `lib/`; `shadcn_ui` dependencies are UI-only from this app's runtime usage.

## Task 8 - Shadcn UI Visual Upgrade

### Commit Policy for Task 8

- [x] Split Task 8 into several meaningful commits and push each commit before continuing.
- [x] Keep GetX as the state management layer; shadcn is only for UI/theming.
- [x] Run `flutter analyze` and `flutter test --concurrency=1` after visual batches.

### Batch 8.1 - Shadcn Foundation and Debug Banner

- [x] Add `shadcn_ui` dependency.
- [x] Wrap the GetX app with `ShadApp.custom` so Shad components receive `ShadTheme`.
- [x] Keep `GetMaterialApp` and `ShotBinding` as the app bootstrap.
- [x] Disable the Flutter debug banner.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Commit and push 8.1: dependency, Shad theme provider, and debug banner fix.

### Batch 8.2 - Shared Component Reskin

- [x] Replace shared cards, badges, empty states, metric tiles, and shot list rows with shadcn-styled primitives.
- [x] Use tighter borders, neutral surfaces, clear focus/hover affordances, and icon-first controls.
- [x] Keep text readable and stable across narrow screens.
- [x] Run focused widget tests.
- [x] Commit and push 8.2a: shared surface and badge reskin.
- [x] Commit and push 8.2b: list rows, metric tiles, and empty states.

### Batch 8.3 - Screen-Level Polish

- [x] Upgrade the shell navigation to feel like a modern app surface instead of default Material navigation.
- [x] Polish Home, Beans, History, Shot Detail, and forms with consistent spacing and component hierarchy.
- [x] Replace obvious Material-only buttons with Shad buttons where it improves the UI without breaking tests.
- [x] Run `flutter analyze`.
- [x] Run `flutter test --concurrency=1`.
- [x] Commit and push 8.3a: shell and page layout polish.
- [x] Commit and push 8.3b: form/action polish and validation.

## Task 9 - Shadcn UI Consistency Repair

### Commit Policy for Task 9

- [x] Keep this repair split into multiple commits and push each commit.
- [x] Preserve GetX state management and existing data workflows.
- [x] Validate analyzer and full tests before marking complete.

### Batch 9.1 - Unified Theme, Font, and Light/Dark Tokens

- [x] Add direct `google_fonts` dependency for Montserrat typography.
- [x] Align Material and Shad color palettes to the same neutral/accent tokens.
- [x] Configure Shad `ShadTextTheme`, card, and button themes from one source.
- [x] Keep light and dark mode available through `ThemeMode.system`.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Commit and push 9.1: theme/token/font repair.

### Batch 9.2 - Layout and Component Consistency

- [x] Replace remaining default chips with shadcn-style filter/rating pills.
- [x] Center/constrain shell navigation and page content consistently.
- [x] Make card borders, spacing, and row affordances visibly consistent.
- [x] Run focused widget tests.
- [x] Commit and push 9.2: shadcn layout/component repair.

### Batch 9.3 - Final Validation

- [x] Run `flutter analyze`.
- [x] Run `flutter test --concurrency=1`.
- [x] Verify `HEAD` matches `origin/main` after final push.
- [x] Commit and push 9.3: final validation evidence.

## Task 10 - Visible Body Bugfix

- [x] Replace nested `ShadApp`/GetX app wiring with a stable `MaterialApp` root.
- [x] Inject `ShadTheme` as an inherited theme around the app content.
- [x] Register `ShotController` in GetX before loading data so `Get.find` and `Obx` remain the state layer.
- [x] Render only the active shell tab instead of keeping all tab pages in a stack.
- [x] Use `Scaffold(body: Column(...))` with `Expanded` page content and nav below it.
- [x] Run `flutter analyze`.
- [x] Run `flutter test --concurrency=1`.
- [x] Commit and push the visible body fix.

## Task 11 - Full UI Replacement From `main2.dart`

### Reference Snapshot

- [x] Inspect `main2.dart` as the requested UI reference.
- [x] Confirm `main2.dart` is now populated (`104390` bytes, `3083` lines) and can be used as the UI source of truth.
- [x] Identify `main2.dart` as a single-file Flutter prototype with in-memory mock data, custom Material widgets, and no SQLite/GetX integration.
- [x] Extract primary navigation: Home, Beans, New Shot, and History as bottom tabs, with Insights and Settings opened from Home header actions.
- [x] Extract visual language: warm cream/espresso light mode, deep charcoal/caramel dark mode, 20px page gutters, 14-20px radii, bordered white/surface cards, soft shadows only on hero recipe cards, icon-led actions, uppercase section labels, and compact list rows.
- [x] Extract component set: `_ShotBottomNav`, `SectionLabel`, `StarRating`, `StarRatingInput`, `UnitChip`, `StatusPill`, `RecipeCard`, `_HeroNumber`, `EmptyState`, `PrimaryButton`, `SecondaryButton`, `_FilterChip`, `AddBeanSheet`, `_LabeledField`, `_BeanSelector`, `_ParamGrid`, `_NumberField`, `_TextParamField`, `_StatCard`, and `_MiniStat`.
- [x] Record typography decision: keep `main2.dart` scale and weights, but use Montserrat instead of the prototype's `Roboto` to satisfy the previous UI correction.
- [x] Record implementation decision: use `shadcn_ui` only where it can faithfully match `main2.dart`; rewrite or delete previous shadcn/Material surfaces that conflict with the prototype.

### Commit Policy for Task 11

- [ ] Split implementation into multiple meaningful commits and push each commit.
- [ ] For every Task 11 batch with more than three implementation items, split the batch into at least two commits and push both.
- [x] Do not keep any old UI surface that conflicts with `main2.dart`.
- [x] Preserve GetX state management and SQLite persistence.
- [x] Keep the app root stable so the full page body and bottom navigation both render; do not reintroduce nested app wrappers that hide the body.
- [x] Keep light and dark mode support using the `main2.dart` palette.
- [x] Run focused validation after each batch and full validation at the end.

### Batch 11.1 - Reference Extraction and Design-System Rewrite

- [x] Read the refreshed `main2.dart` via full-file pass and targeted UI extraction for this TODO update.
- [x] Replace `cookbook/design-system.md` so it names `main2.dart` as the design source of truth.
- [x] Document palette tokens exactly:
  - [x] Light: background `#FBF3E8`, surface `#FFFFFF`, surfaceAlt `#F2E4D3`, primary `#4E3221`, onPrimary `#FBF3E8`, accent `#C5854A`, textPrimary `#2B211C`, textSecondary `#8A7B6E`, border `#E7D8C4`, danger `#B3492F`, success `#3F7A55`.
  - [x] Dark: background `#19140F`, surface `#241D17`, surfaceAlt `#2D241C`, primary/accent `#DFAA6D`, onPrimary `#241A10`, textPrimary `#F3E9DC`, textSecondary `#AA9C8C`, border `#3A2F25`, danger `#E07B5C`, success `#7EC195`.
- [x] Document typography using Montserrat with `main2.dart` sizing: page title 24-26/800, recipe hero number 30/800, ratio 26-28/800, section label 12/700 uppercase, body 14/400, captions 11-13.
- [x] Document spacing/radius rules from the prototype: 20px page gutter, 8-18px vertical rhythm, 14px inputs, 16px rows/buttons/stat cards, 18px bean detail cards, 20px recipe/active bean cards, 24px sheet top radius.
- [x] Map every current app screen to the prototype pattern: Home, Beans, Bean Detail, New/Edit Shot, Shot Detail, History, plus add or expose Insights and Settings from Home.
- [x] Identify existing `lib/shared/widgets/shot_ui.dart` widgets that must be replaced instead of restyled.
- [ ] Commit and push 11.1a: refreshed TODO from `main2.dart`.
- [ ] Commit and push 11.1b: design-system rewrite and migration map.

### Batch 11.2 - App Shell and Shared UI Replacement

- [x] Replace `ShotShell` with the `main2.dart` structure: full-screen `Scaffold`, `SafeArea(top: false)`, active tab body, and custom bottom nav items Home/Beans/New Shot/History.
- [x] Keep tab state in the existing GetX/local shell boundary as appropriate; keep domain data in `ShotController`.
- [x] Rebuild shared UI around `main2.dart` primitives: section labels, star rating display/input, unit chips, status pills, recipe card, hero numbers, empty state, primary/secondary buttons, filter chips, stat cards, and number/text parameter fields.
- [x] Use `shadcn_ui` components only when their output can match the prototype's card/input/button behavior and tokens.
- [x] Remove or rewrite old shadcn/Material helper components that no longer belong to the `main2.dart` visual system.
- [x] Ensure body and bottom navigation render correctly on mobile dimensions, with no centered-only nav bug and no debug banner.
- [x] Run `flutter analyze`.
- [x] Run focused widget smoke tests.
- [ ] Commit and push 11.2a: shell and shared UI foundation.
- [ ] Commit and push 11.2b: remove obsolete shared UI leftovers.

### Batch 11.3 - Home and Beans UI Replacement

- [x] Replace Home header with the prototype pattern: greeting, `Shot` title, Insights icon action, and Settings icon action.
- [x] Replace Home content with active bean gradient card, Last Shot recipe card, tasting notes quote, Brew Again/New Shot stacked actions, and Recent Shots rows.
- [x] Add or wire Insights route from Home using real GetX/SQLite data: total shots, average rating, most-used bean, and active-bean highlight range.
- [x] Replace Beans page with title, rounded search field, horizontal status filters, bordered bean rows, status pills, and extended Add Bean FAB.
- [x] Replace Add Bean bottom sheet with top drag handle, 24px top radius, labeled fields, roast-level chips, and full-width save action.
- [x] Replace Bean Detail with app bar actions, top bean info card, UnitChip metadata, Best Shot recipe card, Shot History rows, archive action, and bottom New Shot button.
- [x] Preserve all existing Home and Beans workflows.
- [x] Run Home/Beans focused tests or update tests to match the new UI contract.
- [ ] Commit and push 11.3a: Home replacement.
- [ ] Commit and push 11.3b: Insights route and data mapping.
- [ ] Commit and push 11.3c: Beans, Add Bean sheet, and Bean Detail replacement.

### Batch 11.4 - Shot Form, Shot Detail, and History UI Replacement

- [x] Replace New/Edit Shot form with prototype structure: app bar, Bean selector, Parameter Shot grid, live Brew Ratio panel, StarRatingInput, Tasting Notes box, and sticky save bar.
- [x] Preserve live ratio calculation, validation, save, update, and Brew Again behavior.
- [x] Replace Shot Detail with date header, RecipeCard, Rating & Notes card, sticky Brew Again/Edit/Delete action area, and confirmation dialog styling.
- [x] Replace History with title, horizontal bean filter chips, horizontal rating filter chips, and bordered `ShotRow` list.
- [x] Preserve bean filter, rating filter, date filter, delete, favorite, and navigation behavior.
- [x] Run workflow acceptance tests and update assertions only where visual text/structure intentionally changes.
- [ ] Commit and push 11.4a: Shot form and Shot Detail replacement.
- [ ] Commit and push 11.4b: History replacement and workflow test updates.

### Batch 11.5 - Light/Dark, Responsiveness, and Final Validation

- [x] Add Settings route from Home with a dark-mode switch matching the prototype, wired to the app theme state without replacing GetX domain state.
- [x] Verify `main2.dart` visual tokens work in both light and dark mode.
- [x] Replace any remaining old one-note palette, inconsistent font sizing, unclear card boundary, or uneven left/right spacing.
- [x] Fix text overflow in bottom nav labels, bean names, recipe numbers, filter chips, CTA buttons, and compact parameter grid.
- [x] Verify no debug banner is shown.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Run `flutter test --concurrency=1`.
- [x] Verify no unintended runtime network usage is introduced.
- [x] Verify `HEAD` matches `origin/main` after final push.
- [ ] Commit and push 11.5a: settings/dark-mode polish.
- [ ] Commit and push 11.5b: final UI replacement validation.

## Task 7 - GetX State Management Migration Plan

### Commit Policy for Task 7

- [x] Every Batch 7.x must be split into at least 2 meaningful commits when it contains more than 3 implementation checklist items.
- [x] Each sub-batch commit must be pushed before continuing to the next sub-batch.
- [x] Validation-only or documentation-only sub-batches may be one commit if they do not include behavior changes.
- [x] Commit messages must describe the sub-batch scope, not only the parent batch number.

### Batch 7.1 - Dependency and App Bootstrap

- [x] Add `get` dependency to `pubspec.yaml`.
- [x] Replace `MaterialApp` with `GetMaterialApp` in `ShotApp`.
- [x] Add an app-level GetX binding, for example `ShotBinding`, to register the state controller.
- [x] Keep `WidgetsFlutterBinding.ensureInitialized()` in `main.dart`.
- [x] Run `flutter pub get`.
- [x] Run `flutter analyze`.
- [x] Commit and push 7.1a: dependency and `GetMaterialApp` bootstrap.
- [x] Commit and push 7.1b: app binding registration and bootstrap validation.

### Batch 7.2 - Controller Boundary

- [x] Convert state ownership from `ShotStore extends ChangeNotifier` to a GetX controller, for example `ShotController extends GetxController`.
- [x] Replace `_isLoading`, `_errorMessage`, `_beans`, and `_shots` with GetX reactive state (`RxBool`, `RxnString`, `RxList<CoffeeBean>`, `RxList<EspressoShot>`).
- [x] Move initial loading into `onInit()` or an explicit bootstrap method that tests can bypass.
- [x] Preserve current public actions: `load`, `refresh`, `addBean`, `saveBean`, `markBeanFinished`, `deleteBeanOrArchive`, `addShot`, `saveShot`, `deleteShot`, and `toggleFavorite`.
- [x] Preserve derived getters: active beans, recent shots, last shot, total shots, average rating, most-used bean, active/recent bean, shots by bean, best shot by bean.
- [x] Keep SQLite persistence in `ShotDatabase`; do not replace persistence with GetX.
- [x] Run focused store/controller acceptance tests.
- [x] Commit and push 7.2a: introduce GetX controller state and lifecycle.
- [x] Commit and push 7.2b: migrate mutations and derived getters.
- [x] Commit and push 7.2c: focused controller acceptance tests.

### Batch 7.3 - Remove InheritedNotifier Scope From UI

- [x] Remove `ShotScope` usage from app and feature screens.
- [x] Replace `ShotScope.of(context)` reads with `Get.find<ShotController>()`.
- [x] Wrap reactive UI sections with `Obx` where beans/shots/loading/error changes need rebuilds.
- [x] Keep form-local state such as selected bean, text controllers, rating selection, search query, and filters inside each widget unless it must be shared globally.
- [x] Replace navigation that benefits from GetX with `Get.to`, `Get.back`, and `Get.snackbar` only where it reduces boilerplate; keep standard Flutter navigation if it is clearer.
- [x] Remove `lib/app/shot_scope.dart` after all usages are gone.
- [x] Run `flutter analyze`.
- [x] Commit and push 7.3a: migrate app/home/shell state reads to GetX.
- [x] Commit and push 7.3b: migrate beans/history screens to GetX.
- [x] Commit and push 7.3c: migrate shot form/detail, navigation cleanup, and remove `ShotScope`.

### Batch 7.4 - Test Harness Migration

- [x] Replace `ShotStore.seeded` test setup with a GetX test binding or injectable `ShotController`.
- [x] Ensure each widget test calls `Get.reset()` in teardown to avoid leaked controllers.
- [x] Update widget smoke test to pump `ShotApp` with test controller injection.
- [x] Update workflow tests for `Obx` rebuilds and GetX navigation.
- [x] Keep SQLite acceptance tests using temporary FFI database.
- [x] Run `flutter test --concurrency=1`.
- [x] Commit and push 7.4a: migrate widget test harness and controller injection.
- [x] Commit and push 7.4b: migrate workflow and SQLite acceptance tests.
- [x] Commit and push 7.4c: full sequential test validation fixes.

### Batch 7.5 - Final Cleanup and Documentation

- [x] Update `cookbook/architecture.md` so state management is documented as GetX.
- [x] Review `cookbook/design-system.md`; no UI interaction behavior change required a design-system edit.
- [x] Search repo for leftover `ChangeNotifier`, `InheritedNotifier`, `ShotScope`, and `notifyListeners`.
- [x] Verify no runtime network dependency is introduced.
- [x] Run final `flutter pub get`, `flutter analyze`, and `flutter test --concurrency=1`.
- [x] Mark Task 7 checklist complete after validation.
- [x] Commit and push 7.5a: documentation updates.
- [x] Commit and push 7.5b: final cleanup, checklist completion, and validation evidence.
