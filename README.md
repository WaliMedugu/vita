<div align="center">

```
██╗   ██╗██╗████████╗ █████╗ 
██║   ██║██║╚══██╔══╝██╔══██╗
██║   ██║██║   ██║   ███████║
╚██╗ ██╔╝██║   ██║   ██╔══██║
 ╚████╔╝ ██║   ██║   ██║  ██║
  ╚═══╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
```

### **Vital Identity & Trust Alliance**

*Health identity in your pocket. Community protection in your wallet.*

<br/>

[![Challenge](https://img.shields.io/badge/OPay%20|%20Google-Innovation%20Challenge%202026-1A6B4A?style=for-the-badge&logoColor=white)](https://www.opayweb.com/innovation-challenge)
[![Track](https://img.shields.io/badge/Track-Healthcare%20Technology-18A574?style=for-the-badge)](/)
[![Team](https://img.shields.io/badge/Team-VITA--NUN-D4A017?style=for-the-badge)](/)
[![University](https://img.shields.io/badge/Nile%20University-Abuja-1A1A2E?style=for-the-badge)](/)
[![Backend](https://img.shields.io/badge/Backend-Python%20%2B%20FastAPI-3776AB?style=for-the-badge&logo=python&logoColor=white)](/)
[![Frontend](https://img.shields.io/badge/Frontend-Flutter%20Web%20%2B%20Mobile-54C5F8?style=for-the-badge&logo=flutter&logoColor=white)](/)
[![Database](https://img.shields.io/badge/Database-Supabase%20PostgreSQL-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](/)

<br/>

</div>

---

## 🚨 The Problem

> *Every day in Nigeria, someone arrives at a hospital unconscious.*
> *The nurses ask three questions: blood type? allergies? who do we call?*
> *Nobody knows. Then comes the second problem — who's paying?*
> *Treatment waits. Sometimes it waits too long.*

<br/>

| Statistic | Reality |
|-----------|---------|
| **75%** | of all healthcare costs paid out of pocket |
| **< 5%** | of Nigerians actually covered by NHIS in practice |
| **2.9 / 10,000** | doctor-to-patient ratio — vs WHO minimum of 17 |
| **85%** | of Primary Healthcare Centres in distress |
| **133M+** | informal workers with zero health coverage |

<br/>

---

## 💡 What VITA Does

VITA is not an app. It is a **three-layer healthcare system** designed around how emergencies actually unfold in Nigeria — an unconscious patient, a panicked stranger, a family member three states away, and a hospital that needs payment before it begins.

<br/>

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                   │
│   LAYER 1 — VitaCard          LAYER 2 — VitaPool                │
│   ──────────────────          ─────────────────────             │
│   ₦300–500 NFC sticker        Purpose-locked community          │
│   card. Tap any Android       health fund on OPay.              │
│   phone. Instantly see        Passive ₦50–100 sweep             │
│   blood type, allergies,      per transaction. Sends            │
│   conditions, contacts.       exact bill amount only.           │
│   Works OFFLINE.              Group sees every naira.           │
│                                                                   │
│                 LAYER 3 — VitaVoice                             │
│                 ────────────────────                            │
│                 Gemini-powered SMS bot.                         │
│                 English, Pidgin, Hausa,                         │
│                 Yoruba, Igbo. No smartphone                     │
│                 needed. Costs ₦4.                               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

<br/>

---

## ⚡ The Emergency Flow

```
Adaobi collapses at her market stall in Kano
              │
              ▼
    Bystander sees VitaCard
    "EMERGENCY: Tap this card with any Android phone"
              │
              ▼
    ┌─────────────────────────────────┐
    │  Blood type: O+                 │
    │  Allergy: Penicillin ⚠️          │
    │  Condition: Hypertension        │
    │  Emergency contact: Sister      │
    │  ─────────────────────────────  │
    │  🩺 First Aid (WHO-sourced):    │
    │  Keep still. Loosen clothing.   │
    │  Do not give water.             │
    │  Get to hospital immediately.   │
    │                                 │
    │       [ 🚨 EMERGENCY ]          │
    └─────────────────────────────────┘
              │
              ▼
    App dials sister from bystander's phone
    Auto-SMS with GPS location fires to sister
              │
              ▼
    App shows 3 nearest open hospitals + directions
              │
              ▼
    Sister sends ₦500 transport now
    ₦1,000 more releases on arrival confirmation
              │
              ▼
    Bystander gets real bill at hospital: ₦7,500
    Sister enters ₦7,500 in VITA — sends exactly that
              │
         ┌────┴────┐
         ▼         ▼
    Hospital      Bystander wallet
    OPay account  (cash via OPay
    (if available) agent if needed)
         │
         ▼
    All 12 group members notified in real time
    Emergency receipt issued on close
    Remaining pool balance: untouched ✅
```

<br/>

---

## 🧠 Where Gemini Does the Work

> **Our rule: AI is used only where it cannot be replaced by any other approach at scale.**

<br/>

| Application | What Gemini does | Why nothing else works |
|-------------|-----------------|----------------------|
| **Health profile building** | Converts *"I get sugar, my blood dey high"* → `Type 2 Diabetes + Hypertension` | No human team serves millions across 5 languages at ₦4/session |
| **First aid card** | Surfaces WHO-grounded guidance for the patient's exact condition combination | Static scripts can't handle thousands of possible condition combinations |
| **VitaVoice SMS** | Navigates dialect switching, ambiguity, maps answers to clinical fields over SMS | No fixed script handles language variation at population scale |
| **Fraud detection** | Cross-references emergency claims against transaction behaviour before release | Rule-based logic is gameable; pattern recognition requires ML |
| **Contribution optimisation** | Personalises passive sweep so it never causes overdrafts | A fixed ₦100 is painless for some, harmful for others |

<br/>

---

## 🛡️ Community Governance

VitaPool belongs to the group — not just the person in crisis.

- 👁️ **Full transparency** — every member sees every transaction in real time via Supabase subscriptions
- 🔒 **Spending limits** — group admin sets a cap; breaches trigger a 30-minute group notification window
- 💰 **Exact amounts only** — emergency contact sends the real bill, nothing more, no overpayment
- 🚕 **Staged transport** — ₦500 upfront, ₦1,000 on GPS-confirmed hospital arrival
- 🏦 **Reserve floor** — last ₦3,000 always protected; pool never empties completely
- 📄 **Emergency receipt** — full summary sent to all members when emergency closes
- ⚖️ **Dispute window** — any member can raise a dispute within 7 days, resolved by group vote
- 📞 **Fallback contact** — if primary contact unreachable for 5 minutes, group admin takes over

<br/>

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                          VITA System                              │
│                                                                    │
│         One Flutter app — compiles to web AND mobile              │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                   Flutter App (Wali)                      │    │
│  │                                                           │    │
│  │   flutter build web  →  Web Dashboard (Vercel)           │    │
│  │   flutter build apk  →  Android NFC App (demo phone)     │    │
│  │                                                           │    │
│  │   NFC screens active on mobile only (kIsWeb check)       │    │
│  └──────────────────────────┬────────────────────────────────┘   │
│                             │  HTTP / REST                        │
│                             ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │               Python FastAPI Backend (me)                │    │
│  │                      (Render)                             │    │
│  └───┬──────────────┬──────────────┬────────────────────────┘    │
│      │              │              │                               │
│      ▼              ▼              ▼                               │
│  Supabase      Gemini API    Africa's Talking                     │
│  PostgreSQL    (profile,     SMS / USSD                           │
│  + Realtime    first aid,                                         │
│  subscriptions fraud, bot)                                        │
│      │                            │                               │
│      ▼                            ▼                               │
│  OPay Mock              Google Places API                         │
│  Webhook                (hospital finder)                         │
│                                                                    │
│  Physical: NTAG213 NFC sticker tags (₦300–500)                   │
└──────────────────────────────────────────────────────────────────┘
```

<br/>

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology |
|-------|-----------|
| **Frontend — Web Dashboard** | Flutter Web · Vercel |
| **Frontend — Mobile NFC App** | Flutter Android · nfc_manager |
| **Single Codebase** | One Flutter app — `flutter build web` / `flutter build apk` |
| **Backend** | Python · FastAPI · Render |
| **Database** | Supabase (PostgreSQL) · SQLAlchemy ORM |
| **Real-time** | Supabase Realtime subscriptions |
| **Auth** | FastAPI JWT · python-jose · passlib |
| **AI / Language** | Google Gemini API · google-generativeai |
| **SMS / USSD** | Africa's Talking Python SDK |
| **Payments** | OPay Payment Simulation (mock webhook) |
| **Hospital Finder** | Google Places API |
| **NFC Hardware** | NTAG213 sticker tags (₦300–500 each) |

</div>

<br/>

---

## 🗂️ Repo Structure

```
.
├── README.md
├── app/                              # Flutter — web + mobile (Wali)
│   └── (Flutter project files)
└── backend/
  ├── README.md
  ├── requirements.txt
  └── app/
    ├── __init__.py
    ├── config.py
    ├── database.py
    ├── main.py
    ├── models/
    │   ├── __init__.py
    │   ├── emergency.py
    │   ├── group.py
    │   ├── member.py
    │   ├── pool.py
    │   ├── profile.py
    │   ├── sms_registration.py
    │   ├── transaction.py
    │   └── user.py
    ├── routes/
    │   ├── __init__.py
    │   ├── auth.py
    │   ├── emergency.py
    │   ├── gemini.py
    │   ├── hospitals.py
    │   ├── pool.py
    │   ├── profile.py
    │   └── sms.py
    ├── schemas/
    │   ├── __init__.py
    │   ├── auth.py
    │   ├── emergency.py
    │   ├── hospital.py
    │   ├── pool.py
    │   └── profile.py
    ├── utils/
    │   ├── __init__.py
    │   ├── auth.py
    │   ├── notifications.py
    │   ├── opay_mock.py
    │   └── sweep.py
    └── tests/
      ├── __init__.py
      ├── test_auth.py
      ├── test_emergency.py
      └── test_pool.py

```

<br/>

---

## 🚀 Getting Started

### Prerequisites
- Python 3.11+
- Flutter 3.19+ (stable channel)
- Android device with NFC (for mobile testing)
- Supabase project (free at supabase.com)
- Google Gemini API key (free tier)
- Africa's Talking account (free sandbox)

### Backend Setup

```bash
# Clone the repo
git clone https://github.com/vita-nun/vita.git
cd vita/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env            # Fill in your keys

# Run the server
uvicorn app.main:app --reload
# API docs at http://localhost:8000/docs
```

### Flutter App Setup

```bash
cd ../app

# Install dependencies
flutter pub get

# Run as web (dashboard)
flutter run -d chrome

# Run as mobile (NFC)
flutter run -d <your-android-device-id>

# Build for deployment
flutter build web          # → web dashboard
flutter build apk          # → Android APK
```

### Environment Variables

```env
# backend/.env

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_anon_key
DATABASE_URL=postgresql://postgres:password@db.your-project.supabase.co:5432/postgres

# Google
GEMINI_API_KEY=your_gemini_key
GOOGLE_PLACES_API_KEY=your_places_key

# Africa's Talking
AT_API_KEY=your_key
AT_USERNAME=sandbox

# Auth
JWT_SECRET=your_secret_key_here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# OPay (mock in development)
OPAY_MOCK=true
```

### Flutter Dependencies

```yaml
# app/pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  nfc_manager: ^3.3.0          # NFC read/write (mobile only)
  http: ^1.2.0                 # API calls to FastAPI
  geolocator: ^12.0.0          # GPS for hospital finder
  url_launcher: ^6.3.0         # Native phone call intent
  supabase_flutter: ^2.5.0     # Realtime group notifications
  flutter_dotenv: ^5.1.0       # Environment variables
```

### Backend Dependencies

```txt
# backend/requirements.txt
fastapi
uvicorn[standard]
sqlalchemy
supabase
python-jose[cryptography]
passlib[bcrypt]
python-dotenv
google-generativeai
africastalking
httpx
pydantic
```

<br/>

---

## 📊 Why VITA Wins

| Existing Solution | What It Misses |
|------------------|----------------|
| Thrifto / WeSpare / CircleFunds | Not health-locked · no NFC · no emergency trigger · no bystander flow |
| NHIS | Covers <5% of Nigerians · days for approval · hospitals routinely reject it |
| OPay Savings | No community pool · no health lock · no NFC · no rural SMS channel |
| M-TIBA (Kenya) | Kenya only · no NFC · no bystander coordination · no community governance |
| Paper medical ID | Not linked to funds · no first aid · no coordination · useless offline |

> *The specific combination of NFC physical identity + purpose-locked community emergency fund +*
> *passive OPay sweep + Gemini SMS onboarding does not exist anywhere in West Africa.*

<br/>

---

## 💰 Business Model

| Stream | Mechanism | At Scale |
|--------|-----------|----------|
| VitaCard sales | ₦300–500/card at OPay agent points | ₦30M per 100k cards |
| VitaPool fee | 2% of every emergency payout | Self-sustaining from Day 1 |
| SMS triage | ₦4–6/SMS covered by pool sweep | Zero net cost to user |
| Health analytics | Anonymised population data — Phase 2 | Secondary revenue |

No government subsidy needed. No hospital integration required.
Runs on OPay's existing rails and Nigeria's GSM network.

<br/>

---

## 👥 Team VITA-NUN

| Role | Name | Owns |
|------|------|------|
| Backend · Team Lead | Jitubohh | Python FastAPI · Gemini · VitaPool · Emergency flow |
| Flutter · Web + Mobile | Wali | One Flutter app — web dashboard + Android NFC |
| Designer | TBA | Wireframes · Pitch deck · Canva concept note |
| Research · Health | TBA | User research · Business model · Essay |
| Wild Card | TBA | Video · Demo coordination · QA |

<br/>

---

<div align="center">

---

*"VITA gives every Nigerian a health identity in their pocket and a community*
*safety net in their wallet — activated by a tap, funded by their daily*
*transactions, accessible to anyone with a feature phone."*

---

**Team VITA-NUN · Nile University Abuja · OPay | Google National Innovation Challenge 2026**

</div>
