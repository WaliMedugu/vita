# SMS service - Africa's Talking integration
import africastalking
from app.config import settings

# Initialize Africa's Talking
africastalking.initialize(
    username=settings.AT_USERNAME,
    api_key=settings.AT_API_KEY
)

sms = africastalking.SMS


def send_emergency_sms(phone: str, patient_name: str, emergency_link: str, lat: float, lng: float) -> bool:
    """
    Sends emergency SMS to the patient's emergency contact.
    Returns True if sent successfully, False otherwise.
    """
    maps_link = f"https://maps.google.com/?q={lat},{lng}"

    message = (
        f"VITA EMERGENCY ALERT\n"
        f"{patient_name} needs help.\n"
        f"Location: {maps_link}\n"
        f"Tap to coordinate emergency:\n"
        f"{emergency_link}"
    )

    try:
        response = sms.send(message, [phone])
        recipients = response.get("SMSMessageData", {}).get("Recipients", [])
        if recipients and recipients[0].get("status") == "Success":
            print(f"[SMS] Sent to {phone}: {message}")
            return True
        else:
            print(f"[SMS] Failed to send to {phone}: {response}")
            return False
    except Exception as e:
        print(f"[SMS] Error sending to {phone}: {e}")
        return False


def send_emergency_closed_sms(phone: str, patient_name: str, total_spent: float, remaining_balance: float) -> bool:
    """
    Notifies emergency contact that emergency has been closed.
    """
    message = (
        f"VITA: Emergency for {patient_name} has been closed.\n"
        f"Total spent: N{total_spent:.2f}\n"
        f"Remaining pool balance: N{remaining_balance:.2f}\n"
        f"Full receipt available on VITA."
    )

    try:
        response = sms.send(message, [phone])
        recipients = response.get("SMSMessageData", {}).get("Recipients", [])
        if recipients and recipients[0].get("status") == "Success":
            print(f"[SMS] Closed alert sent to {phone}")
            return True
        else:
            print(f"[SMS] Failed to send closed alert to {phone}: {response}")
            return False
    except Exception as e:
        print(f"[SMS] Error sending closed alert to {phone}: {e}")
        return False


def send_sms(phone: str, message: str) -> bool:
    """
    Simple SMS send function used by VitaVoice registration flow.
    """
    try:
        response = sms.send(message, [phone])
        recipients = response.get("SMSMessageData", {}).get("Recipients", [])
        if recipients and recipients[0].get("status") == "Success":
            print(f"[SMS] Sent to {phone}: {message}")
            return True
        else:
            print(f"[SMS] Failed to send to {phone}: {response}")
            return False
    except Exception as e:
        print(f"[SMS] Error sending to {phone}: {e}")
        return False