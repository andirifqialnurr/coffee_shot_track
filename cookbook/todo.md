# TODO

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
