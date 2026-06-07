# MSLR — Backend (Django REST API)

The REST API for **MSLR (My Shangri-La Referendum)**, built with Django REST Framework
and JWT authentication. It exposes endpoints for voter registration/login, voting, and
Election Commission management of referendums, with interactive Swagger/ReDoc docs.

> 📄 For the full project overview and architecture, see the [root README](../README.md).

## Quick Start

```bash
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env               # optional locally; edit before deploying
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

The API runs at `http://127.0.0.1:8000/`.

### Seed an SCC code (required for voter registration)

Voter registration is gated by a single-use Secure Citizen Code. Create one via the
Django admin (`/admin/` → *SCC codes*) or the shell:

```bash
python manage.py shell -c "from main_application.models import SCC; SCC.objects.create(code='SCC12345')"
```

## API Docs

- Swagger UI → http://127.0.0.1:8000/swagger/
- ReDoc → http://127.0.0.1:8000/redoc/

See the [root README](../README.md#-api-reference) for the full endpoint table.

## Layout

```
backend/
├── mslr/                 # project settings, URLs, WSGI/ASGI
├── main_application/      # models, serializers, views, permissions, urls
├── manage.py
└── requirements.txt
```

## Configuration

All secrets and environment-specific settings — `DJANGO_SECRET_KEY`, JWT signing key,
`DEBUG`, `ALLOWED_HOSTS`, CORS, and the Election Commission credentials — are read from
environment variables (loaded from a git-ignored `.env`). See [`.env.example`](.env.example)
for the full list. Development defaults keep the project runnable out of the box; override
them before deploying. See the [Security Notes](../README.md#-security-notes) in the root
README for the production checklist.
