<h1 align="center">VITA</h1>

<p align="center">
  <strong>Vital Identity &amp; Trust Alliance</strong><br/>
  Health identity in your pocket. Community protection in your wallet.
</p>

<p align="center">
  <a href="https://vita-amber.vercel.app"><strong>Live web demo</strong></a> ·
  OPay | Google National Innovation Challenge 2026 · Healthcare Technology track · Team VITA-NUN, Nile University Abuja
</p>

<p align="center">
  Flutter (web + mobile) · Python FastAPI · Supabase PostgreSQL · Google Gemini · Africa's Talking
</p>

---

## The problem

When someone arrives at a hospital in Nigeria unconscious, staff need three answers fast: blood type, allergies, and who to call. Usually nobody knows. Then comes the second problem: who is paying? Most healthcare costs are paid out of pocket, and treatment can wait on payment.

## What it does

VITA is a three-layer system designed around how an emergency actually unfolds: an unconscious patient, a stranger who wants to help, a family member far away, and a hospital that needs payment.

```
┌───────────────────────────────────────────────────────────────┐
│  LAYER 1 · VitaCard          LAYER 2 · VitaPool               │
│  Low-cost NFC sticker card.  Purpose-locked community health  │
│  Tap with an Android phone   fund. Releases the exact bill    │
│  to see blood type,          amount only, and every member    │
│  allergies, conditions and   sees every naira.                │
│  emergency contacts.                                          │
│                                                               │
│                LAYER 3 · VitaVoice                            │
│                Gemini-assisted SMS bot, so people without a   │
│                smartphone can register a health profile.      │
└───────────────────────────────────────────────────────────────┘
```

### The emergency flow (as designed)

```
Patient collapses ─▶ Bystander taps the VitaCard with an Android phone
                          │
                          ▼
         Blood type, allergies, conditions, emergency contact
         + a first-aid card for that patient's conditions
                          │
                          ▼
         [ EMERGENCY ] ─▶ emergency contact is called and gets an SMS
                          with the location; nearest open hospitals shown
                          │
                          ▼
         Emergency contact releases the exact hospital bill from VitaPool
                          │
                          ▼
         Group members notified · receipt issued when the emergency closes
```

## Key features

**Flutter app (web dashboard + mobile UI)**
- Onboarding, sign-in and a dashboard with pool balance and activity feed.
- Health profile view and editor (blood type, allergies, conditions, contacts).
- VitaCard NFC write, read and result screens, with a simulated tap for the demo.
- Emergency confirmation, nearby hospital finder and emergency receipt screens.
- Group creation, member list and admin screens for a VitaPool.
- VitaVoice web screen that simulates the SMS registration conversation.
- Declarative routing with `go_router`, built to web and deployed on Vercel.

**FastAPI backend**
- JWT auth (`/auth/register`, `/auth/login`) with bcrypt password hashing via passlib.
- Health profiles, including a public `/profile/nfc/{user_id}` view for a card tap.
- Groups with invites, members and contribution settings; pools with contributions and history.
- Emergency lifecycle: public `/emergency/trigger` from a card tap with GPS, a signed access token for the emergency contact, fund release that enforces the group's reserve floor, close, and receipt.
- Gemini endpoints for a condition-specific first-aid card (with a cached fallback) and for turning plain-language or Pidgin descriptions into structured health-profile fields.
- Africa's Talking `/sms/incoming` webhook that walks a new user through registration by SMS, with English/Pidgin detection.
- `/hospitals/nearby` using the Google Places API.
- OPay payment simulation (mock) for releases.

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart 3), `go_router`, `google_fonts`; one codebase for web and Android |
| Web hosting | Vercel (`vercel.json` + `build.sh` install Flutter and run `flutter build web`) |
| Backend | Python, FastAPI, Uvicorn, Pydantic |
| Database | Supabase PostgreSQL, SQLAlchemy |
| Auth | JWT (`python-jose`), `passlib[bcrypt]` |
| AI | Google Gemini (`google-generativeai`, `gemini-2.0-flash`) |
| SMS | Africa's Talking |
| Maps | Google Places API |
| Payments | OPay simulation (mock) |
| Tests | pytest |

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Flutter app (vita/)                                         │
│    flutter build web  →  web dashboard (Vercel)              │
│    flutter build apk  →  Android app                         │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTP / REST
                            ▼
┌──────────────────────────────────────────────────────────────┐
│  FastAPI backend (backend/)                                  │
│  auth · profile · groups · pool · emergency · gemini ·       │
│  sms · hospitals                                             │
└──┬──────────────┬──────────────┬──────────────┬──────────────┘
   ▼              ▼              ▼              ▼
Supabase      Gemini API    Africa's Talking  Google Places
PostgreSQL                  SMS               (hospital finder)
   │
   ▼
OPay mock (fund release)
```

```
.
├── vita/            Flutter app (lib/screens, lib/widgets, lib/router, lib/theme)
├── backend/         FastAPI app (app/routes, app/models, app/schemas, app/utils, tests/)
├── Docs/            Concept note and backend briefs (PDF)
├── VITA BUILD PLAN.pdf, VITA CONCEPT NOTE.pdf, VITA DATABASE ARCHITECTURE.pdf
├── vercel.json      Vercel config for the Flutter web build
└── build.sh         Installs Flutter and builds vita/ for the web
```

## Getting started

### Prerequisites

- Python 3.11+
- Flutter (stable channel)
- A Supabase project, a Google Gemini API key, a Google Places API key and an Africa's Talking sandbox account

### Backend

```bash
git clone https://github.com/WaliMedugu/vita.git
cd vita/backend

python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

cp .env.example .env            # fill in your keys
uvicorn app.main:app --reload   # API docs at http://localhost:8000/docs

pytest                          # backend tests
```

Environment variables read by `backend/app/config.py` (`backend/.env`):

```env
SUPABASE_URL=
SUPABASE_KEY=
DATABASE_URL=
SUPABASE_JWT_SECRET=            # used to sign JWTs (.env.example still lists JWT_SECRET)
GEMINI_API_KEY=
GOOGLE_PLACES_API_KEY=
AT_API_KEY=
AT_USERNAME=sandbox
FRONTEND_URL=
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
OPAY_MOCK=true
```

### Flutter app

```bash
cd vita                         # from the repo root
flutter pub get

flutter run -d chrome           # web dashboard
flutter run -d <android-device> # mobile

flutter build web               # what Vercel deploys
flutter build apk
```

## Project status

This is a competition prototype. The backend implements the API described above. The Flutter app is a UI prototype: its screens use sample data, the NFC tap and map navigation are simulated, and it does not yet call the backend. The passive transaction sweep into VitaPool is designed in the docs but not implemented.

## Project context

Built by **Team VITA-NUN** from Nile University, Abuja, for the **OPay | Google National Innovation Challenge 2026**, Healthcare Technology track. The concept note and build plan are in [`Docs/`](Docs/) and the repo root.

## Team

| Name | Role |
|---|---|
| Jitubohh | Backend, team lead (FastAPI, Gemini, VitaPool, emergency flow) |
| Wali | Flutter web and mobile app |

## Author

**Medugu Wali**, Blue Particle Studios
[github.com/WaliMedugu](https://github.com/WaliMedugu) · [linkedin.com/in/meduguwali](https://www.linkedin.com/in/meduguwali)
