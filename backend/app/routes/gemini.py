# Gemini routes - POST /gemini/first-aid, POST /gemini/build-profile
# Gemini routes - first aid card + health profile builder
from fastapi import APIRouter, Depends, HTTPException #type: ignore
from pydantic import BaseModel #type: ignore
from typing import List, Optional
import google.generativeai as genai
from app.config import settings
from app.utils.auth import get_current_user
from app.schemas.gemini import (
    FirstAidRequest, 
    FirstAidResponse, 
    ProfileBuilderRequest, 
    ProfileBuilderResponse
)

router = APIRouter()

# Configure Gemini
genai.configure(api_key=settings.GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-2.0-flash")

# Pre-cached responses for demo — avoids live API calls
FIRST_AID_CACHE = {
    "hypertension": """1. Keep the patient still and calm — do not move them unnecessarily.
2. Loosen any tight clothing around the neck and chest.
3. If conscious, help them sit or lie in a comfortable position.
4. Do not give any food, water, or medication.
5. Get to hospital immediately.""",

    "type 2 diabetes": """1. If conscious and able to swallow, give sugar or a sweet drink immediately.
2. If unconscious, do not put anything in their mouth.
3. Lay the patient on their side to prevent choking.
4. Keep them warm and still.
5. Get to hospital immediately.""",

    "sickle cell": """1. Keep the patient warm and comfortable.
2. Give water to drink if they are conscious.
3. Do not apply pressure to painful areas.
4. Keep them calm and still.
5. Get to hospital immediately.""",

    "asthma": """1. Help the patient sit upright — do not lay them down.
2. If they have an inhaler, help them use it immediately.
3. Loosen any tight clothing around the chest and neck.
4. Keep them calm and encourage slow steady breathing.
5. Get to hospital immediately.""",

    "epilepsy": """1. Clear the area around them of any hard or sharp objects.
2. Do not restrain them or put anything in their mouth.
3. Place something soft under their head.
4. Turn them on their side after the seizure stops.
5. Get to hospital immediately.""",

    "malaria": """1. Keep the patient cool if they have a fever — use a damp cloth.
2. Give water to drink if they are conscious.
3. Do not give aspirin — use paracetamol only if available.
4. Keep them still and comfortable.
5. Get to hospital immediately.""",

    "default": """1. Keep the patient still and do not move them unnecessarily.
2. Loosen any tight clothing around the neck and chest.
3. Check if they are breathing — if not, begin CPR if you are trained.
4. Do not give any food, water, or medication.
5. Get to hospital immediately."""
}

def get_cached_first_aid(conditions: list) -> str:
    conditions_lower = [c.lower() for c in conditions]
    for condition in conditions_lower:
        for key in FIRST_AID_CACHE:
            if key in condition:
                return FIRST_AID_CACHE[key]
    return FIRST_AID_CACHE["default"]


# Endpoints

@router.post("/first-aid", response_model=FirstAidResponse)
def get_first_aid(req: FirstAidRequest):
    if not req.conditions:
        raise HTTPException(status_code=400, detail="At least one condition is required")

    # Use cache for demo — avoids Gemini API quota issues
    guidance = get_cached_first_aid(req.conditions)

    # Try Gemini live — fall back to cache if it fails
    try:
        conditions_str = ", ".join(req.conditions)
        allergies_str = ", ".join(req.allergies) if req.allergies else "None known"
        prompt = f"""You are an emergency first aid assistant. A bystander has found an unconscious patient 
with the following medical conditions: {conditions_str}
Known allergies: {allergies_str}

Provide clear, simple, actionable first aid steps for a bystander with no medical training.
Base your guidance strictly on WHO first aid guidelines.

Rules:
- Maximum 5 steps
- Each step must be one short sentence
- Use simple English — no medical jargon
- Do NOT suggest any medication
- If the patient has penicillin allergy, explicitly warn: DO NOT give penicillin
- End with: Get to hospital immediately

Format your response as a numbered list of steps only. Nothing else."""
        response = model.generate_content(prompt)
        guidance = response.text.strip()
    except Exception:
        pass  # Fall back to cached response silently

    return FirstAidResponse(
        guidance=guidance,
        disclaimer="AI-generated guidance based on WHO first aid guidelines. Seek professional medical help immediately.",
        conditions_addressed=req.conditions,
    )

@router.post("/profile-builder", response_model=ProfileBuilderResponse)
def build_profile(
    req: ProfileBuilderRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Converts natural language health description into structured profile fields.
    Called by VitaVoice SMS flow and health_profile.dart for assisted entry.
    Supports English and Pidgin.
    """
    if not req.raw_text.strip():
        raise HTTPException(status_code=400, detail="raw_text cannot be empty")

    prompt = f"""You are a medical data extraction assistant for a Nigerian health app.
A user has described their health information in natural language ({req.language}).
Extract structured medical data from their description.

User input: "{req.raw_text}"

Extract the following fields if present:
- blood_type: one of A+, A-, B+, B-, O+, O-, AB+, AB- (or null if not mentioned)
- allergies: list of allergies mentioned (empty list if none)
- conditions: list of medical conditions (translate Nigerian/Pidgin terms to standard medical terms)
- emergency_contact: phone number if mentioned (or null)

Common Nigerian/Pidgin translations:
- "sugar" or "I get sugar" = Type 2 Diabetes
- "pressure" or "my blood dey high" = Hypertension  
- "asthma" = Asthma
- "fits" or "epilepsy" = Epilepsy
- "sickle cell" = Sickle Cell Disease
- "malaria wey dey always come" = Recurrent Malaria

Respond ONLY with a valid JSON object in this exact format, nothing else:
{{
  "blood_type": "O+" or null,
  "allergies": ["item1", "item2"] or [],
  "conditions": ["Condition 1", "Condition 2"] or [],
  "emergency_contact": "08012345678" or null,
  "confidence_note": "one sentence about extraction confidence"
}}"""

    try:
        response = model.generate_content(prompt)
        raw = response.text.strip()

        # Strip markdown code fences if present
        if raw.startswith("```"):
            raw = raw.split("```")[1]
            if raw.startswith("json"):
                raw = raw[4:]
            raw = raw.strip()

        import json
        data = json.loads(raw)

        return ProfileBuilderResponse(
            blood_type=data.get("blood_type"),
            allergies=data.get("allergies", []),
            conditions=data.get("conditions", []),
            emergency_contact=data.get("emergency_contact"),
            confidence_note=data.get("confidence_note", ""),
        )
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500,
            detail="Gemini returned invalid JSON. Try rephrasing your input."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gemini API error: {str(e)}")
