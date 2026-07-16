# Hospital routes - GET /hospitals/nearby

from fastapi import APIRouter, Depends, HTTPException #type: ignore
from pydantic import BaseModel #type: ignore
from typing import List, Optional
import httpx    #type: ignore   
from app.config import settings
from app.utils.auth import get_current_user
from app.schemas.hospital import (
    Hospital, 
    HospitalResponse
)

router = APIRouter()

#Helpers

def calculate_distance(lat1, lng1, lat2, lng2) -> float:
    """Haversine formula — returns distance in km."""
    import math
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = (math.sin(dlat/2)**2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlng/2)**2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return round(R * c, 1)


#Endpoint

@router.get("/nearby", response_model=HospitalResponse)
def get_nearby_hospitals(
    lat: float,
    lng: float,
):
    """
    Returns 3 nearest open hospitals from bystander GPS coordinates.
    Uses Google Places API.
    Called by hospital_finder.dart after emergency is triggered.
    """
    url = "https://places.googleapis.com/v1/places:searchNearby"

    # Replace the params and request with this:
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": settings.GOOGLE_PLACES_API_KEY,
        "X-Goog-FieldMask": "places.displayName,places.formattedAddress,places.location,places.currentOpeningHours,places.id"
    }

    payload = {
        "includedTypes": ["hospital"],
        "maxResultCount": 10,
        "locationRestriction": {
            "circle": {
                "center": {"latitude": lat, "longitude": lng},
                "radius": 10000.0
            }
        }
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.post(url, json=payload, headers=headers)
            data = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Google Places API error: {str(e)}")

    results = data.get("places", [])

    hospitals = []
    for place in results:
        place_lat = place["location"]["latitude"]
        place_lng = place["location"]["longitude"]
        distance = calculate_distance(lat, lng, place_lat, place_lng)
        open_now = place.get("currentOpeningHours", {}).get("openNow")

        hospitals.append(Hospital(
            name=place["displayName"]["text"],
            address=place.get("formattedAddress", "Address not available"),
            distance_km=distance,
            open_now=open_now,
            lat=place_lat,
            lng=place_lng,
            maps_link=f"https://maps.google.com/?q={place_lat},{place_lng}",
        ))

    # Sort by distance and return top 3
    hospitals.sort(key=lambda h: h.distance_km)
    top_3 = hospitals[:3]

    return HospitalResponse(
        hospitals=top_3,
        bystander_lat=lat,
        bystander_lng=lng,
    )
