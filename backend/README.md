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

## Note

This is a demonstration project with development defaults (`DEBUG = True`, an in-repo
secret key, and fixed Election Commission credentials). See the
[Security Notes](../README.md#-security-notes) in the root README before deploying.
