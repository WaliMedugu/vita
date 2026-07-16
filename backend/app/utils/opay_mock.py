# OPay mock - simulated OPay payment webhook
import random
import string
from datetime import datetime


def generate_opay_reference() -> str:
    """
    Generates a realistic OPay-format transaction reference.
    Format: OPAY-YYYY-XXXXXXXXXX
    Example: OPAY-2026-A3F9K2XQ1B
    """
    chars = string.ascii_uppercase + string.digits
    suffix = ''.join(random.choices(chars, k=10))
    year = datetime.utcnow().year
    return f"OPAY-{year}-{suffix}"


def generate_opay_response(
    amount: float,
    opay_phone: str,
    transaction_amount: float = None,
    destination: str = "pool"
) -> dict:
    """
    Simulates a full OPay webhook/transaction response.
    In production this would come from OPay's API.
    """
    reference = generate_opay_reference()
    now = datetime.utcnow()

    return {
        "reference": reference,
        "status": "SUCCESS",
        "amount": amount,
        "currency": "NGN",
        "opay_phone": opay_phone,
        "transaction_amount": transaction_amount,
        "destination": destination,
        "timestamp": now.isoformat(),
        "message": "Transaction successful",
        "provider": "OPay",
    }