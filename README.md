<div align="center">

# 🗳️ MSLR — My Shangri-La Referendum

**A full-stack digital referendum (e‑voting) platform.**
Secure citizen onboarding with single‑use verification codes, role‑based access for an Election Commission, and tamper‑resistant, real‑time vote tallying.

[![Flutter](https://img.shields.io/badge/Flutter-3.9-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Django](https://img.shields.io/badge/Django-4.2+-092E20?logo=django&logoColor=white)](https://www.djangoproject.com)
[![DRF](https://img.shields.io/badge/DRF-3.14+-A30000?logo=django&logoColor=white)](https://www.django-rest-framework.org)
[![JWT](https://img.shields.io/badge/Auth-JWT-000000?logo=jsonwebtokens&logoColor=white)](https://jwt.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📖 Overview

**MSLR** is an end‑to‑end voting system for running national referendums for the (fictional) nation of *Shangri‑La*. It pairs a **Flutter** mobile client with a **Django REST Framework** API and models a realistic election workflow with two distinct actors:

- **🧑‍🤝‍🧑 Voters** — citizens who register using a single‑use **Secure Citizen Code (SCC)**, then browse and vote on referendums.
- **🏛️ Election Commission (EC)** — administrators who author referendums, publish them, and monitor live results.

The project was built as a **portfolio piece** to demonstrate full‑stack product engineering: a clean‑architecture mobile app, a secured REST API with JWT auth, role‑based access control, QR‑based identity verification, and self‑documenting API endpoints.

---

## ✨ Features

### 🧑‍🤝‍🧑 Voter
- **Gated registration** — each sign‑up requires a valid, **single‑use SCC code** (one citizen, one identity).
- **In‑app QR scanner** — citizens scan their SCC code with the device camera instead of typing it.
- **Eligibility checks** — server‑side **18+ age validation** at registration.
- **JWT authentication** with access/refresh tokens, stored securely on‑device via the platform keystore/keychain.
- **Vote with integrity** — browse open & closed referendums, cast **one vote per referendum**, and review the option you chose.

### 🏛️ Election Commission
- **Dedicated admin login** separate from the voter flow.
- **Author referendums** with a title, description, and multiple options.
- **Immutable once live** — a referendum **locks automatically when opened**, preventing post‑publication tampering with its questions or options.
- **Live monitoring** of per‑option vote tallies.

### ⚙️ Platform
- **Automatic closing** — a referendum closes itself once an option crosses **50% of all registered voters**.
- **Public read‑only API** for fetching referendums and results, filterable by status.
- **Self‑documenting API** via **Swagger UI** and **ReDoc** (powered by `drf-yasg`).

---

## 🏗️ Architecture

This is a **monorepo** containing two independently runnable components:

```
┌──────────────────────────┐         HTTPS / JSON          ┌──────────────────────────┐
│      Flutter App         │  ───────────────────────────► │     Django REST API      │
│   (iOS · Android)        │      JWT (Bearer tokens)       │   (DRF · SimpleJWT)      │
│                          │ ◄───────────────────────────  │                          │
│  Clean Architecture:     │                                │  Roles: Voter · EC       │
│  presentation / domain   │                                │  Swagger · ReDoc docs    │
│  / data                  │                                │  SQLite (dev)            │
└──────────────────────────┘                                └──────────────────────────┘
```

The Flutter client follows a **clean‑architecture** layering:

| Layer | Path | Responsibility |
|-------|------|----------------|
| **Presentation** | `app/lib/presentation` | Screens, reusable widgets, themes, helpers |
| **Domain** | `app/lib/domain` | Models & service interfaces (business logic) |
| **Data** | `app/lib/data` | API environment config & secure token storage |

---

## 🧰 Tech Stack

| Area | Technologies |
|------|--------------|
| **Mobile** | Flutter, Dart, `http`, `flutter_secure_storage`, `mobile_scanner` (QR), `google_fonts`, `form_field_validator` |
| **Backend** | Python, Django, Django REST Framework, SimpleJWT, `drf-yasg` (OpenAPI), `django-cors-headers`, Pillow |
| **Auth** | JWT (access/refresh), role‑based permissions |
| **Database** | SQLite (development default) |
| **Docs** | Swagger UI · ReDoc |

---

## 📁 Project Structure

```
mslr/
├── app/                         # Flutter mobile client
│   ├── lib/
│   │   ├── data/                # environment config + secure storage
│   │   ├── domain/             # models + services (API calls)
│   │   └── presentation/       # screens, components, themes, helpers
│   │       └── screens/        # auth · voter · ec (election commission)
│   ├── android/ · ios/         # native platform projects
│   ├── assets/                 # app icon & assets
│   └── pubspec.yaml
│
├── backend/                     # Django REST API
│   ├── mslr/                   # project settings, URLs, WSGI/ASGI
│   ├── main_application/       # models, serializers, views, permissions, urls
│   ├── manage.py
│   └── requirements.txt
│
├── README.md
└── LICENSE
```

---

## 🚀 Getting Started

### Prerequisites
- **Python** 3.10+
- **Flutter** SDK 3.9+ (with Dart 3.9+)
- An Android emulator / iOS simulator or a physical device

### 1 — Backend (Django API)

```bash
cd backend

# create & activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate

# install dependencies
pip install -r requirements.txt

# set up the database
python manage.py migrate

# create an admin user for the Django admin panel
python manage.py createsuperuser

# run the server
python manage.py runserver
```

The API is now available at **http://127.0.0.1:8000/**.

> **Seed an SCC code (required for voter registration).** Registration is gated by a single‑use Secure Citizen Code. Create one via the Django admin (`/admin/` → *SCC codes*) or the shell:
> ```bash
> python manage.py shell -c "from main_application.models import SCC; SCC.objects.create(code='SCC12345')"
> ```

### 2 — Mobile app (Flutter)

```bash
cd app
flutter pub get
flutter run
```

### 3 — Point the app at your API

The client's base URL lives in [`app/lib/data/env/environment.dart`](app/lib/data/env/environment.dart):

```dart
static String baseUrl = "http://127.0.0.1:8000/api";
```

- **Android emulator:** use `http://10.0.2.2:8000/api`
- **Physical device:** use your machine's LAN IP, e.g. `http://192.168.1.20:8000/api`

---

## 🔑 Demo Credentials

The Election Commission uses fixed demo credentials (defined in the backend for this showcase):

| Role | Email | Password |
|------|-------|----------|
| Election Commission | `ec@referendum.gov.sr` | `Shangrilavote&2025@` |

Voters create their own accounts through the in‑app registration flow (a seeded SCC code is required — see the backend setup above).

---

## 📚 API Reference

Interactive documentation is served by the backend once it's running:

- **Swagger UI** → http://127.0.0.1:8000/swagger/
- **ReDoc** → http://127.0.0.1:8000/redoc/

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| `POST` | `/api/voter/register/` | Public | Register a voter (requires a valid SCC code) |
| `POST` | `/api/voter/login/` | Public | Voter login → JWT tokens |
| `POST` | `/api/voter/token/refresh/` | Public | Refresh an access token |
| `GET`  | `/api/voter/referendums/` | Voter | List referendums for the voter dashboard |
| `POST` | `/api/voter/vote/` | Voter | Cast a vote |
| `GET`  | `/api/voter/vote-status/{id}/` | Voter | Check if the voter has already voted |
| `POST` | `/api/ec/login/` | Public | Election Commission login |
| `GET`  | `/api/ec/referendums/` | EC | List all referendums |
| `POST` | `/api/ec/referendums/create/` | EC | Create a referendum |
| `PUT`  | `/api/ec/referendums/{id}/update/` | EC | Update a referendum |
| `GET`  | `/api/mslr/referendums` | Public | Public results, filterable by `?status=open\|closed` |
| `GET`  | `/api/mslr/referendum/{id}` | Public | Public results for a single referendum |

---

## 🔒 Security Notes

This repository is a **demonstration / portfolio project** and ships with development‑friendly defaults. Before any real deployment you should:

- Move `SECRET_KEY` and the JWT signing key out of `settings.py` into environment variables.
- Replace the **hard‑coded Election Commission credentials** with proper hashed, database‑backed auth.
- Set `DEBUG = False`, restrict `ALLOWED_HOSTS`, and tighten `CORS_ALLOW_ALL_ORIGINS`.
- Switch from SQLite to a production database (e.g. PostgreSQL) and serve over HTTPS.

The development database (`db.sqlite3`) is intentionally **not** committed.

---

## 🗺️ Roadmap

- [ ] Environment‑based configuration & secret management
- [ ] Database‑backed EC accounts with hashed passwords
- [ ] Automated test suite (backend + widget tests)
- [ ] Live hosted demo (API + web results dashboard)
- [ ] CI/CD pipeline

---

## 👤 Author

**Saeed Alskaf**
[![GitHub](https://img.shields.io/badge/GitHub-saeedskaf-181717?logo=github&logoColor=white)](https://github.com/saeedskaf)

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.
