# MSLR — Mobile App (Flutter)

The Flutter client for **MSLR (My Shangri-La Referendum)**. It lets citizens register
with a single-use **Secure Citizen Code (SCC)** — scanned via the in-app QR scanner —
authenticate with JWT, and vote on referendums. A separate flow lets the Election
Commission author and monitor referendums.

> 📄 For the full project overview, architecture, and API reference, see the
> [root README](../README.md).

## Architecture

The app follows a clean-architecture layering under `lib/`:

| Layer | Path | Responsibility |
|-------|------|----------------|
| Presentation | `lib/presentation` | Screens, reusable widgets, themes, helpers |
| Domain | `lib/domain` | Models & services (API calls) |
| Data | `lib/data` | Environment config & secure token storage |

## Getting Started

```bash
flutter pub get
flutter run
```

Set the API base URL in [`lib/data/env/environment.dart`](lib/data/env/environment.dart):

- Android emulator → `http://10.0.2.2:8000/api`
- iOS simulator → `http://127.0.0.1:8000/api`
- Physical device → your machine's LAN IP, e.g. `http://192.168.1.20:8000/api`

## Key Dependencies

- `http` — REST client
- `flutter_secure_storage` — secure on-device token storage
- `mobile_scanner` — QR code scanning for SCC verification
- `google_fonts`, `form_field_validator` — UI & form validation
