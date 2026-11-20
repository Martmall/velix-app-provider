# Velix Partner app

Flutter app for Velix partners (fleet owners): listings, booking requests, pickups and returns,
earnings.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api-staging.velix.ng/api
```

## Shared code: `velix_core`

The theme, models, network client and shared widgets live in **one** place:
`velix-app-user/packages/velix_core` (the customer app repo). This app depends on it as a git
package (see `pubspec.yaml`); `pubspec.lock` pins the exact commit.

- **Pick up the latest `velix_core`:** merge the change into `velix-app-user` `develop` first,
  then here run `flutter pub upgrade velix_core` and commit the updated `pubspec.lock`.
- **Working on both at once:** create `pubspec_overrides.yaml` here (it's gitignored) pointing at
  your local checkout, then run `flutter pub get`:

  ```yaml
  dependency_overrides:
    velix_core:
      path: ../velix-app-user/packages/velix_core
  ```

  Delete it before committing a `pubspec.lock`.
