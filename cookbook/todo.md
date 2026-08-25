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
- Offline readiness is source-verified: app dependencies are local Flutter, `sqflite`, and `path`; no runtime network package or network image usage exists in `lib/`.

## Task 7 - GetX State Management Migration Plan

### Batch 7.1 - Dependency and App Bootstrap

- [ ] Add `get` dependency to `pubspec.yaml`.
- [ ] Replace `MaterialApp` with `GetMaterialApp` in `ShotApp`.
- [ ] Add an app-level GetX binding, for example `ShotBinding`, to register the state controller.
- [ ] Keep `WidgetsFlutterBinding.ensureInitialized()` in `main.dart`.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter analyze`.
- [ ] Commit and push Batch 7.1.

### Batch 7.2 - Controller Boundary

- [ ] Convert state ownership from `ShotStore extends ChangeNotifier` to a GetX controller, for example `ShotController extends GetxController`.
- [ ] Replace `_isLoading`, `_errorMessage`, `_beans`, and `_shots` with GetX reactive state (`RxBool`, `RxnString`, `RxList<CoffeeBean>`, `RxList<EspressoShot>`).
- [ ] Move initial loading into `onInit()` or an explicit bootstrap method that tests can bypass.
- [ ] Preserve current public actions: `load`, `refresh`, `addBean`, `saveBean`, `markBeanFinished`, `deleteBeanOrArchive`, `addShot`, `saveShot`, `deleteShot`, and `toggleFavorite`.
- [ ] Preserve derived getters: active beans, recent shots, last shot, total shots, average rating, most-used bean, active/recent bean, shots by bean, best shot by bean.
- [ ] Keep SQLite persistence in `ShotDatabase`; do not replace persistence with GetX.
- [ ] Run focused store/controller acceptance tests.
- [ ] Commit and push Batch 7.2.

### Batch 7.3 - Remove InheritedNotifier Scope From UI

- [ ] Remove `ShotScope` usage from app and feature screens.
- [ ] Replace `ShotScope.of(context)` reads with `Get.find<ShotController>()`.
- [ ] Wrap reactive UI sections with `Obx` where beans/shots/loading/error changes need rebuilds.
- [ ] Keep form-local state such as selected bean, text controllers, rating selection, search query, and filters inside each widget unless it must be shared globally.
- [ ] Replace navigation that benefits from GetX with `Get.to`, `Get.back`, and `Get.snackbar` only where it reduces boilerplate; keep standard Flutter navigation if it is clearer.
- [ ] Remove `lib/app/shot_scope.dart` after all usages are gone.
- [ ] Run `flutter analyze`.
- [ ] Commit and push Batch 7.3.

### Batch 7.4 - Test Harness Migration

- [ ] Replace `ShotStore.seeded` test setup with a GetX test binding or injectable `ShotController`.
- [ ] Ensure each widget test calls `Get.reset()` in teardown to avoid leaked controllers.
- [ ] Update widget smoke test to pump `ShotApp` with test controller injection.
- [ ] Update workflow tests for `Obx` rebuilds and GetX navigation.
- [ ] Keep SQLite acceptance tests using temporary FFI database.
- [ ] Run `flutter test --concurrency=1`.
- [ ] Commit and push Batch 7.4.

### Batch 7.5 - Final Cleanup and Documentation

- [ ] Update `cookbook/architecture.md` so state management is documented as GetX.
- [ ] Update `cookbook/design-system.md` only if UI interaction behavior changes during migration.
- [ ] Search repo for leftover `ChangeNotifier`, `InheritedNotifier`, `ShotScope`, and `notifyListeners`.
- [ ] Verify no runtime network dependency is introduced.
- [ ] Run final `flutter pub get`, `flutter analyze`, and `flutter test --concurrency=1`.
- [ ] Mark Task 7 checklist complete after validation.
- [ ] Commit and push Batch 7.5.
