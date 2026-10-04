# Module FL: Flutter apps

Applies to projects with Flutter mobile or desktop apps. Part of the Engineering Constitution; the
version is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet without SHOULD,
SHOULD NOT or MAY is a MUST.

### FL-01 · Structure

- Folders are organised by feature; navigation uses a declarative router.
- SHOULD: state is managed with Riverpod.

*Why*: features stay self-contained and testable.
*Check*: review.

### FL-02 · Gate

- `flutter analyze` and `flutter test` run in CI (CORE-62), not only locally.

*Why*: a local-only gate is skipped exactly when it matters.
*Check*: the CI workflow runs both.

### FL-03 · Offline and honest feedback

- SHOULD: what the user entered is not lost because of the network. It is kept locally until the server
  confirms it.
- SHOULD: the UI never shows a success that the server has not confirmed.

*Why*: mobile networks fail often; users must be able to trust what the app tells them.
*Check*: a test with the network off keeps the user's input and shows a pending state.
