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

- [ ] Build custom Material 3 theme from `design-system.md`.
- [ ] Build bottom navigation shell.
- [ ] Implement Home with active bean, last shot, Brew Again, New Shot, recent shots, and insights.
- [ ] Implement Beans list, search, status filter, Add Bean, and Bean Detail.
- [ ] Implement New/Edit Shot form with live ratio and validation.
- [ ] Implement Shot Detail with Brew Again, Edit, Delete, and favorite action.
- [ ] Implement History with bean/rating filters.
- [ ] Commit and push Task 3 before final validation.

## Task 4 - Validation and Polish

- [ ] Update widget tests away from counter app.
- [ ] Add focused ratio/helper tests if practical.
- [ ] Run `flutter pub get`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test --concurrency=1`.
- [ ] Fix validation issues found during checks.
- [ ] Commit and push Task 4.

## Manual Acceptance Checklist

- [ ] Add beans, close app, reopen, and verify beans persist.
- [ ] Add shot, close app, reopen, and verify shots persist.
- [ ] Change dose/yield and verify ratio updates immediately.
- [ ] Use Brew Again and verify source shot remains unchanged.
- [ ] Filter history by bean.
- [ ] Archive bean with shots instead of deleting it.
- [ ] Confirm app remains usable without internet.
