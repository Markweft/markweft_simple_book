# Markweft Simple Book

A desktop-first Flutter MVP for creating and editing compressed Markweft book projects.

## Current workflow

When the app opens, it shows a welcome page with:

- **New book** — creates a new `.mdw` project.
- **Open book** — opens an existing `.mdw` project.
- **Import Markdown** — converts a `.md` or `.markdown` file into a new `.mdw` project.
- **Recent books** — opens previously used projects.

Only one project is edited at a time, but any number of `.mdw` books can be created and stored.

## `.mdw` file format

A `.mdw` file is a ZIP-compatible compressed project with a custom extension:

```text
my-book.mdw
├── manifest.yaml
├── content/
│   └── book.md
└── assets/
    └── images/
```

When opened, the project is extracted to a temporary workspace. Markdown edits are written to the workspace and the complete workspace is automatically compressed back into the original `.mdw` file.

The application validates archive paths before extraction to prevent files from escaping the temporary workspace.

## Page syntax

Start a new page:

```markdown
<!-- page -->
```

Override the next page:

```markdown
<!-- page
layout: test.dart
size: a3
orientation: landscape
margin: 20
padding: 48
template:
  title: Test
  description: Description
  image: assets/images/test.png
-->
```

Supported sizes: `a3`, `a4`, `a5`, `letter`.

Supported orientations: `portrait`, `landscape`.

## Setup

If this ZIP does not include generated Flutter platform folders, run:

```bash
flutter create \
  --org dev.markweft \
  --project-name markweft_simple_book \
  --platforms macos,windows,linux \
  .
```

Then:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d macos
```

## MVP boundaries

This version does not yet include:

- PDF export
- image import UI
- automatic content pagination
- template packages
- multiple simultaneously open editor tabs
- recovery after force-quitting during an active save

## Architecture

The app now uses a feature-first Clean Architecture foundation:

```text
lib/
  app/
  features/
    book_library/
      domain/
      data/
      presentation/
    book_editor/
      domain/
      application/
      presentation/
```

`BookProjectRepository` is the domain boundary. `MdwBookProjectRepository` owns ZIP/file-system details, while the editor and app shell depend on the repository contract.
