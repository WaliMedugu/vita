# Emergency token utility - generate and verify sister access tokens
from jose import jwt, JWTError # type: ignore
from app.config import settings
from datetime import datetime


def generate_emergency_token(emergency_id: str, phone: str) -> str:
    """
    Generates a signed token for the emergency contact.
    Token is tied to emergency_id + phone number.
    Valid until emergency is closed — no expiry set here,
    expiry is enforced by checking emergency.status == 'active'.
    """
    payload = {
        "emergency_id": emergency_id,
        "phone": phone,
        "iat": datetime.utcnow().timestamp(),
    }
    return jwt.encode(
        payload,
        settings.SUPABASE_JWT_SECRET,
        algorithm=settings.JWT_ALGORITHM
    )


def verify_emergency_token(token: str, emergency_id: str) -> dict:
    """
    Verifies the emergency token.
    Returns payload if valid, raises ValueError if invalid.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM]
        )
        if payload.get("emergency_id") != emergency_id:
            raise ValueError("Token does not match this emergency")
        return payload
    except JWTError:
        raise ValueError("Invalid or expired token")