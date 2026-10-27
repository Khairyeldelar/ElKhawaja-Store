# ElKhawaja Store | الخواجة ستور

## Reconstruction status
This is a **partial clean-room Flutter reconstruction**, not a byte-for-byte migration of the original app.

Implemented:
- Arabic storefront with category filters and product details
- Email/password sign in, registration and password reset
- Create, edit and delete listings (with ownership checks in the client)
- My products screen
- Firestore collection names matching original source: `Products`, `Users`, `Categories`, `Reports`

Original archive inspection confirms the app also had onboarding, profile editing, image uploads, reports, and additional screens. These features and original assets are **not yet migrated**.

## Firebase setup
This repository intentionally excludes Firebase credentials and signing keys. Restore the **authorized** Firebase app configuration through FlutterFire CLI or platform configuration before expecting live data.

**Security:** Firestore and Storage security rules must enforce user ownership server-side. Client checks alone are not authorization.

## Build
1. Install a current compatible Flutter SDK.
2. Run `flutter pub get`.
3. Configure Firebase for Android/iOS.
4. Run `flutter analyze` and `flutter run`.

No successful build or runtime test has yet been performed. Android and iOS platform scaffolding is not yet restored.

## Original model compatibility
Original Firestore collections use PascalCase names. Original product model fields include `productId`, `images`, `title`, `price`, `category`, `currency`, `description`, `countryName`, `countryCode`, `phoneNumber`, `uid` and `dateTime`.

## Never commit
Signing keystores, private keys, passwords, service account JSON, and local Firebase configuration files.
