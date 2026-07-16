# Gemini parser - converts freeform health text to structured data
import google.generativeai as genai
from app.config import settings
import json

genai.configure(api_key=settings.GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-2.0-flash")

# Cached condition translations for common Nigerian terms
CONDITION_CACHE = {
    "sugar": "Type 2 Diabetes",
    "i get sugar": "Type 2 Diabetes",
    "ciwon sukari": "Type 2 Diabetes",
    "diabetes": "Type 2 Diabetes",
    "pressure": "Hypertension",
    "high blood": "Hypertension",
    "hawan jini": "Hypertension",
    "titẹ ẹjẹ giga": "Hypertension",
    "ọbara dị elu": "Hypertension",
    "sickle cell": "Sickle Cell Disease",
    "ẹjẹ": "Sickle Cell Disease",
    "asthma": "Asthma",
    "fits": "Epilepsy",
    "epilepsy": "Epilepsy",
    "malaria": "Malaria",
    "typhoid": "Typhoid Fever",
    "ulcer": "Peptic Ulcer",
}

ALLERGY_CACHE = {
    "penicillin": "Penicillin",
    "aspirin": "Aspirin",
    "ibuprofen": "Ibuprofen",
    "peanut": "Peanuts",
    "groundnut": "Peanuts",
    "latex": "Latex",
    "sulfa": "Sulfonamides",
}


def check_cache(text: str, field_type: str) -> list:
    """Check local cache before calling Gemini."""
    text_lower = text.lower()
    cache = CONDITION_CACHE if field_type == "conditions" else ALLERGY_CACHE
    results = []
    for key, value in cache.items():
        if key in text_lower and value not in results:
            results.append(value)
    return results


async def parse_health_input(text: str, field_type: str, language: str = "english") -> list:
    """
    Converts freeform health text to structured list.
    Tries cache first, falls back to Gemini.
    field_type: 'conditions' or 'allergies'
    """
    # Try cache first
    cached = check_cache(text, field_type)
    if cached:
        return cached

    # Try Gemini
    try:
        if field_type == "conditions":
            prompt = f"""Extract medical conditions from this text written in {language}.
Text: "{text}"

Common Nigerian/Pidgin translations:
- "sugar" or "ciwon sukari" or "I get sugar" = Type 2 Diabetes
- "pressure" or "blood dey high" or "hawan jini" = Hypertension
- "sickle cell" or "ẹjẹ" = Sickle Cell Disease
- "fits" = Epilepsy
- "asthma" = Asthma
- "malaria" = Malaria

Return ONLY a JSON array of standardised medical condition names in English.
Example: ["Hypertension", "Type 2 Diabetes"]
If none found, return: []
Nothing else — just the JSON array."""
        else:
            prompt = f"""Extract allergies from this text written in {language}.
Text: "{text}"

Return ONLY a JSON array of allergy names in English.
Example: ["Penicillin", "Aspirin"]
If none found, return: []
Nothing else — just the JSON array."""

        response = model.generate_content(prompt)
        raw = response.text.strip()

        # Strip markdown fences
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]
            raw = raw.strip()

        result = json.loads(raw)
        return result if isinstance(result, list) else []

    except Exception:
        # Gemini failed — return the raw text as a single item
        return [text.title()]