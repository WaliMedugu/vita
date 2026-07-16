# SMS routes - POST /sms/webhook (Africa's Talking inbound)
from fastapi import APIRouter, Form, Depends #type: ignore
from fastapi.responses import PlainTextResponse #type: ignore
from sqlalchemy.orm import Session #type: ignore
from sqlalchemy.orm.attributes import flag_modified #type: ignore
from app.database import get_db
from app.models.sms_registration import SmsRegistration
from app.models.user import User
from app.models.profile import HealthProfile
from app.services.sms_service import send_sms
from app.utils.gemini_parser import parse_health_input
from datetime import datetime
import uuid

router = APIRouter()

STAGES = [
    "welcome",
    "name",
    "blood_type",
    "allergies",
    "conditions",
    "emergency_contact",
    "complete"
]

BLOOD_TYPES = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]


def reply(message: str) -> PlainTextResponse:
    return PlainTextResponse(content=message)


async def send_next_question(phone: str, stage: str, language: str = "english"):
    questions = {
        "english": {
            "welcome": "Welcome to VITA — Vital Identity & Trust Alliance. Reply with your FULL NAME to begin registration.",
            "blood_type": "What is your blood type? Reply with one of: A+, A-, B+, B-, O+, O-, AB+, AB-. Or reply SKIP.",
            "allergies": "Do you have any allergies? (e.g. Penicillin, Aspirin). Reply NONE if you have no allergies.",
            "conditions": "Do you have any medical conditions? (e.g. Hypertension, Diabetes). Reply NONE if you have none.",
            "emergency_contact": "What is your emergency contact phone number? (e.g. 08012345678)",
            "complete": "Registration complete! Your VITA health profile has been created. In an emergency, anyone can tap your VitaCard to access your profile. Stay safe!",
        },
        "pidgin": {
            "welcome": "Welcome to VITA! Reply with your FULL NAME to start.",
            "blood_type": "Wetin be your blood group? Reply one of: A+, A-, B+, B-, O+, O-, AB+, AB-. Or reply SKIP.",
            "allergies": "You get any allergy? (e.g. Penicillin). Reply NONE if you no get any.",
            "conditions": "You get any sickness wey you dey manage? (e.g. sugar, high blood pressure). Reply NONE if you no get.",
            "emergency_contact": "Wetin be your emergency contact number? (e.g. 08012345678)",
            "complete": "E don do! We don create your VITA profile. If emergency happen, anybody fit tap your VitaCard see your information. Stay safe!",
        },
        "hausa": {
            "welcome": "Barka da zuwa VITA! Amsawa da SUNAN KA na cikakke don fara rajista.",
            "blood_type": "Menene nau'in jinin ka? Amsa daya daga: A+, A-, B+, B-, O+, O-, AB+, AB-. Ko amsa SKIP.",
            "allergies": "Kana da wani abin da yake cutar da kai? (misali Penicillin). Amsa BABU in ba ka da shi.",
            "conditions": "Kana da wata cuta da kake magancewa? (misali, ciwon sukari, hawan jini). Amsa BABU in ba ka da shi.",
            "emergency_contact": "Menene lambar waya na gaggawa? (misali 08012345678)",
            "complete": "Rajista ta kammala! An ƙirƙiri bayanin VITA ɗinka. A lokacin gaggawa, kowa zai iya karanta katunan ka. Ka kasance lafiya!",
        },
        "yoruba": {
            "welcome": "Kaabo si VITA! Dahun pelu ORUKO RE ni kikun lati bere iforukosile.",
            "blood_type": "Kini iru ẹjẹ rẹ? Dahun pelu ọkan ninu: A+, A-, B+, B-, O+, O-, AB+, AB-. Tabi dahun SKIP.",
            "allergies": "Nje o ni nkan ti o fa aisan fun o? (fun apere Penicillin). Dahun KOKAN ti o ko ni.",
            "conditions": "Nje o ni aisan eyikeyi ti o n gbe pẹlu? (fun apere, titẹ ẹjẹ giga). Dahun KOKAN ti o ko ni.",
            "emergency_contact": "Kini nọmba foonu pajawiri rẹ? (fun apere 08012345678)",
            "complete": "Iforukosile ti pari! A ti ṣẹda profaili VITA rẹ. Ni pajawiri, ẹnikẹni le ka kaadi rẹ. Jẹ ki o wa ni aabo!",
        },
        "igbo": {
            "welcome": "Nnọọ na VITA! Zaghachi aha gị nke zuru oke iji malite ndebanye aha.",
            "blood_type": "Kedu ụdị ọbara gị? Zaghachi otu n'ime: A+, A-, B+, B-, O+, O-, AB+, AB-. Ma ọ bụ zaghachi SKIP.",
            "allergies": "Ị nwere ihe ọ bụla na-eme gị ọjọọ? (dịka Penicillin). Zaghachi ỌHỤỤ ma ọ bụrụ na ị nweghị.",
            "conditions": "Ị nwere ọrịa ọ bụla ị na-elekọta? (dịka shuga, ọbara dị elu). Zaghachi ỌHỤỤ ma ọ bụrụ na ị nweghị.",
            "emergency_contact": "Kedu nọmba ekwentị ihe mberede gị? (dịka 08012345678)",
            "complete": "Ndebanye aha agwụla! Emepụtara profaịlụ VITA gị. N'ihe mberede, onye ọ bụla nwere ike ịgụ kaadị gị. Dị mma!",
        }
    }

    lang = language if language in questions else "english"
    message = questions[lang].get(stage, questions["english"].get(stage, ""))
    if message:
        send_sms(phone, message)


def detect_language(text: str) -> str:
    text_lower = text.lower()
    hausa_words = ["ina", "na", "da", "mai", "kuma", "babu", "sunana", "menene", "sannu"]
    yoruba_words = ["mo", "ni", "mi", "ati", "si", "fun", "nje", "kini", "kaabo"]
    igbo_words = ["m", "na", "ya", "nke", "kedu", "ọ", "bụ", "gị", "nnọọ"]
    pidgin_words = ["wetin", "dey", "don", "no", "fit", "make", "sef", "wahala"]

    for word in hausa_words:
        if word in text_lower:
            return "hausa"
    for word in yoruba_words:
        if word in text_lower:
            return "yoruba"
    for word in igbo_words:
        if word in text_lower:
            return "igbo"
    for word in pidgin_words:
        if word in text_lower:
            return "pidgin"
    return "english"


@router.post("/incoming", response_class=PlainTextResponse)
async def incoming_sms(
    from_: str = Form(alias="from"),
    text: str = Form(),
    date: str = Form(default=""),
    db: Session = Depends(get_db),
):
    phone = from_.strip()
    text = text.strip()
    now = datetime.utcnow()

    # Get or create SMS registration state
    reg = db.query(SmsRegistration).filter(
        SmsRegistration.phone == phone
    ).first()

    # New user — start registration
    if not reg:
        language = detect_language(text)
        reg = SmsRegistration(
            id=uuid.uuid4(),
            phone=phone,
            stage="name",
            partial_profile={"language": language},
            created_at=now,
            updated_at=now,
        )
        db.add(reg)
        db.commit()
        await send_next_question(phone, "name", language)
        return reply("ok")

    # Get current state
    profile = dict(reg.partial_profile or {})
    language = profile.get("language", "english")
    current_stage = reg.stage

    # Already complete
    if current_stage == "complete":
        send_sms(phone, "Your VITA profile is already registered. Visit vita.app to manage your profile.")
        return reply("ok")

    # Process answer based on current stage
    if current_stage == "name":
        profile["full_name"] = text.title()
        next_stage = "blood_type"

    elif current_stage == "blood_type":
        text_upper = text.upper().strip()
        if text_upper == "SKIP":
            profile["blood_type"] = None
        elif text_upper in BLOOD_TYPES:
            profile["blood_type"] = text_upper
        else:
            send_sms(phone, "Invalid blood type. Please reply with one of: A+, A-, B+, B-, O+, O-, AB+, AB-. Or reply SKIP.")
            return reply("ok")
        next_stage = "allergies"

    elif current_stage == "allergies":
        text_upper = text.upper().strip()
        if text_upper in ["NONE", "BABU", "KOKAN", "ỌHỤỤ"]:
            profile["allergies"] = []
        else:
            parsed = await parse_health_input(text, "allergies", language)
            profile["allergies"] = parsed if parsed else [text.title()]
        next_stage = "conditions"

    elif current_stage == "conditions":
        text_upper = text.upper().strip()
        if text_upper in ["NONE", "BABU", "KOKAN", "ỌHỤỤ"]:
            profile["conditions"] = []
        else:
            parsed = await parse_health_input(text, "conditions", language)
            profile["conditions"] = parsed if parsed else [text.title()]
        next_stage = "emergency_contact"

    elif current_stage == "emergency_contact":
        cleaned = text.replace(" ", "").replace("-", "")
        if len(cleaned) >= 10:
            profile["emergency_contact"] = cleaned
        else:
            send_sms(phone, "Please send a valid phone number (e.g. 08012345678)")
            return reply("ok")
        next_stage = "complete"

    else:
        next_stage = "complete"

    # Save updated state — flag_modified forces SQLAlchemy to detect JSONB change
    reg.partial_profile = profile
    flag_modified(reg, "partial_profile")
    reg.stage = next_stage
    reg.updated_at = now
    db.commit()

    # If complete — create user account and health profile
    if next_stage == "complete":
        existing_user = db.query(User).filter(User.phone == phone).first()

        if not existing_user:
            import secrets
            from passlib.context import CryptContext
            pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
            temp_password = secrets.token_urlsafe(12)

            user = User(
                id=uuid.uuid4(),
                email=f"{phone.replace('+', '')}@vita.sms",
                password_hash=pwd_context.hash(temp_password),
                full_name=profile.get("full_name", "VITA User"),
                phone=phone,
                created_at=now,
            )
            db.add(user)
            db.flush()

            health_profile = HealthProfile(
                id=uuid.uuid4(),
                user_id=user.id,
                blood_type=profile.get("blood_type"),
                allergies=profile.get("allergies", []),
                conditions=profile.get("conditions", []),
                emergency_contact=profile.get("emergency_contact"),
                created_at=now,
                updated_at=now,
            )
            db.add(health_profile)
            db.commit()

        await send_next_question(phone, "complete", language)

    else:
        await send_next_question(phone, next_stage, language)

    return reply("ok")