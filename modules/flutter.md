# Module FL: Flutter apps

Applies to projects with Flutter mobile or desktop apps. Part of the Engineering Constitution; the
version is in `core.md`. Defaults, rules and recipes are used as CORE-02 defines them: a bullet without
SHOULD, SHOULD NOT or MAY is a MUST.

## Defaults

The addendum copies this table into its module parameters and keeps or replaces each value (CORE-06).

| Parameter | Default |
|---|---|
| State management | Riverpod |
| Navigation | a declarative router (for example go_router) |

## Rules

### FL-02 · Gate

- `flutter analyze`, `dart format --output=none --set-exit-if-changed .` and `flutter test` run in CI
  (CORE-62), not only locally.

*Why*: a local-only gate is skipped exactly when it matters.
*Check*: the CI workflow runs all three.

### FL-03 · Offline and honest feedback

- SHOULD: what the user entered is not lost because of the network. It is kept locally until the server
  confirms it.
- SHOULD: the UI never shows a success that the server has not confirmed.

*Why*: mobile networks fail often; users must be able to trust what the app tells them.
*Check*: a test with the network off keeps the user's input and shows a pending state.

## Recipes

- **Structure.** Folders are organised by feature, so that each feature stays self-contained and
  testable.
- **Pinned Flutter.** Pin the Flutter version for CORE-60 in one file (for example `.fvmrc` for FVM)
  and let CI read it.
