# Development workflow

## Branch roles

- `main`: production-ready code only.
- `develop`: integration branch for day-to-day development. New features and fixes should target this branch first.
- `feature/*`: create from `develop`, then merge back into `develop` through a pull request.
- `fix/*`: create from `develop` for normal bug fixes.
- `hotfix/*`: create from `main` only for urgent production fixes, then merge the same fix back into `develop`.

Do not develop directly on `main`.

## Related template repository

`markweft_simple_book` depends on `Markweft/markweft_template_simple`.

Development branches are aligned:

- `Markweft/markweft_simple_book:develop`
- `Markweft/markweft_template_simple:develop`

The app `develop` branch should reference the template `develop` branch in `pubspec.yaml`.

## Local setup

```bash
git checkout develop
git pull origin develop
flutter clean
flutter pub get
dart run slang
flutter analyze
flutter test
flutter run -d macos
```

## GitHub Actions private dependency access

The template repository is private, so the app CI needs a repository secret named:

```text
MARKWEFT_REPO_TOKEN
```

Use a fine-grained GitHub token with read-only Contents access to `Markweft/markweft_template_simple`.

The token is used only by CI to let `flutter pub get` clone the private template dependency. Do not commit the token to the repository.

## Pull request flow

Normal work:

```text
feature/* -> develop -> main
```

Before merging `develop` to `main`, require:

1. `flutter pub get`
2. `dart run slang`
3. `flutter analyze`
4. `flutter test`
5. macOS debug build
6. manual smoke test for creating, opening, editing, saving, previewing and exporting a `.mdw` book

## Book settings regression checks

When changing Book Settings UI, verify that:

- text fields retain focus while typing;
- numeric fields retain focus while typing;
- changing a template or paragraph preset refreshes displayed values;
- invalid numeric input does not overwrite the last valid setting;
- Arabic and RTL values can be entered without cursor jumps;
- Save returns the final edited settings.
