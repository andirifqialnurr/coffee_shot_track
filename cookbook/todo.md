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
