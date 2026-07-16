import pytest
from unittest.mock import patch
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


# ============================================================
# Auto-use fixtures
# ============================================================

@pytest.fixture(autouse=True)
def mock_sms():
    with patch("app.routes.emergency.send_emergency_sms") as mock1, \
         patch("app.routes.emergency.send_emergency_closed_sms") as mock2:
        mock1.return_value = True
        mock2.return_value = True
        yield


@pytest.fixture(autouse=True)
def clean_db():
    from app.database import SessionLocal
    from app.models.emergency import Emergency
    from app.models.profile import HealthProfile
    from app.models.member import GroupMember
    from app.models.pool import Pool
    from app.models.group import Group
    from app.models.transaction import Transaction
    db = SessionLocal()
    db.query(Transaction).delete()
    db.query(Emergency).delete()
    db.query(HealthProfile).delete()
    db.query(GroupMember).delete()
    db.query(Pool).delete()
    db.query(Group).delete()
    db.commit()
    db.close()
    yield


# ============================================================
# Helpers
# ============================================================

def register_and_login(email, password, full_name, phone):
    client.post("/auth/register", json={
        "email": email,
        "password": password,
        "full_name": full_name,
        "phone": phone
    })
    res = client.post("/auth/login", json={
        "email": email,
        "password": password
    })
    return res.json()["access_token"]


def auth_headers(token):
    return {"Authorization": f"Bearer {token}"}


def get_token_for_emergency(emergency_id: str, phone: str) -> str:
    from app.utils.emergency_token import generate_emergency_token
    return generate_emergency_token(emergency_id, phone)


# ============================================================
# Fixtures
# ============================================================

@pytest.fixture
def admin_token():
    return register_and_login(
        "emergency_admin@vita.com", "password123", "Emergency Admin", "08011111111"
    )


@pytest.fixture
def group_and_pool(admin_token):
    res = client.post("/groups", json={
        "name": "Emergency Test Group",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "passive"
    }, headers=auth_headers(admin_token))
    return {
        "group_id": res.json()["id"],
        "pool_id": res.json()["pool_id"]
    }


@pytest.fixture
def patient_with_profile(admin_token, group_and_pool):
    import jwt
    payload = jwt.decode(admin_token, options={"verify_signature": False})
    user_id = payload["sub"]

    client.post("/profile", json={
        "blood_type": "O+",
        "allergies": ["Penicillin"],
        "conditions": ["Hypertension"],
        "emergency_contact": "+2348011111111",
        "emergency_contact_2": "",
        "pool_id": group_and_pool["pool_id"]
    }, headers=auth_headers(admin_token))

    return {
        "user_id": user_id,
        "pool_id": group_and_pool["pool_id"],
        "group_id": group_and_pool["group_id"]
    }


@pytest.fixture
def active_emergency(patient_with_profile):
    res = client.post("/emergency/trigger", json={
        "user_id": patient_with_profile["user_id"],
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert res.status_code == 200, f"Trigger failed: {res.json()}"
    return {
        "emergency_id": res.json()["id"],
        "pool_id": res.json()["pool_id"],
        "user_id": patient_with_profile["user_id"],
        "group_id": patient_with_profile["group_id"]
    }


# ============================================================
# POST /emergency/trigger
# ============================================================

def test_trigger_emergency_success(patient_with_profile):
    res = client.post("/emergency/trigger", json={
        "user_id": patient_with_profile["user_id"],
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "active"
    assert data["pool_id"] == patient_with_profile["pool_id"]
    assert data["lat"] == 11.9804
    assert data["lng"] == 8.5158


def test_trigger_emergency_no_auth_required(patient_with_profile):
    res = client.post("/emergency/trigger", json={
        "user_id": patient_with_profile["user_id"],
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert res.status_code == 200


def test_trigger_emergency_invalid_user():
    res = client.post("/emergency/trigger", json={
        "user_id": "00000000-0000-0000-0000-000000000000",
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert res.status_code == 404


def test_trigger_emergency_duplicate(patient_with_profile, active_emergency):
    res = client.post("/emergency/trigger", json={
        "user_id": patient_with_profile["user_id"],
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert res.status_code == 400
    assert "active emergency" in res.json()["detail"].lower()


# ============================================================
# GET /emergency/{id}
# ============================================================

def test_get_emergency_valid_token(active_emergency):
    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    res = client.get(
        f"/emergency/{active_emergency['emergency_id']}?token={token}"
    )
    assert res.status_code == 200
    data = res.json()
    assert data["emergency_id"] == active_emergency["emergency_id"]
    assert data["status"] == "active"
    assert data["patient_blood_type"] == "O+"
    assert "Penicillin" in data["patient_allergies"]
    assert len(data["pools"]) > 0


def test_get_emergency_invalid_token(active_emergency):
    res = client.get(
        f"/emergency/{active_emergency['emergency_id']}?token=invalidtoken"
    )
    assert res.status_code == 403


def test_get_emergency_wrong_emergency_token(active_emergency):
    token = get_token_for_emergency(
        "00000000-0000-0000-0000-000000000000",
        "+2348011111111"
    )
    res = client.get(
        f"/emergency/{active_emergency['emergency_id']}?token={token}"
    )
    assert res.status_code == 403


def test_get_emergency_not_found():
    token = get_token_for_emergency(
        "00000000-0000-0000-0000-000000000000",
        "+2348011111111"
    )
    res = client.get(
        "/emergency/00000000-0000-0000-0000-000000000000?token=" + token
    )
    assert res.status_code == 404


# ============================================================
# POST /emergency/{id}/release
# ============================================================

def test_release_funds_to_bystander(active_emergency, admin_token):
    client.post(f"/pool/{active_emergency['pool_id']}/contribute", json={
        "amount": 10000,
        "opay_phone": "08011111111",
        "transaction_amount": 20000
    }, headers=auth_headers(admin_token))

    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token={token}",
        json={
            "amount": 5000,
            "note": "Transport money"
        }
    )
    assert res.status_code == 200
    data = res.json()
    assert data["amount_released"] == 5000
    assert data["destination"] == "bystander"
    assert data["opay_reference"].startswith("OPAY-")
    assert data["new_total_spent"] == 5000


def test_release_enforces_reserve_floor(active_emergency, admin_token):
    client.post(f"/pool/{active_emergency['pool_id']}/contribute", json={
        "amount": 5000,
        "opay_phone": "08011111111",
        "transaction_amount": 20000
    }, headers=auth_headers(admin_token))

    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token={token}",
        json={"amount": 4000}
    )
    assert res.status_code == 400
    assert "reserve floor" in res.json()["detail"].lower()


def test_release_zero_amount(active_emergency):
    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token={token}",
        json={"amount": 0}
    )
    assert res.status_code == 400


def test_release_invalid_token(active_emergency):
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token=badtoken",
        json={"amount": 1000}
    )
    assert res.status_code == 403


# ============================================================
# POST /emergency/{id}/close
# ============================================================

def test_close_emergency(active_emergency):
    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/close?token={token}"
    )
    assert res.status_code == 200
    data = res.json()
    assert data["message"] == "Emergency closed"
    assert "closed_at" in data


def test_close_already_closed(active_emergency):
    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    client.post(
        f"/emergency/{active_emergency['emergency_id']}/close?token={token}"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/close?token={token}"
    )
    assert res.status_code == 400
    assert "already closed" in res.json()["detail"].lower()


def test_cannot_release_after_close(active_emergency, admin_token):
    client.post(f"/pool/{active_emergency['pool_id']}/contribute", json={
        "amount": 10000,
        "opay_phone": "08011111111",
        "transaction_amount": 20000
    }, headers=auth_headers(admin_token))

    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    client.post(
        f"/emergency/{active_emergency['emergency_id']}/close?token={token}"
    )
    res = client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token={token}",
        json={"amount": 1000}
    )
    assert res.status_code == 400


# ============================================================
# GET /emergency/{id}/receipt
# ============================================================

def test_get_receipt(active_emergency, admin_token):
    client.post(f"/pool/{active_emergency['pool_id']}/contribute", json={
        "amount": 10000,
        "opay_phone": "08011111111",
        "transaction_amount": 20000
    }, headers=auth_headers(admin_token))

    token = get_token_for_emergency(
        active_emergency["emergency_id"],
        "+2348011111111"
    )
    client.post(
        f"/emergency/{active_emergency['emergency_id']}/release?token={token}",
        json={"amount": 5000, "note": "Hospital bill"}
    )
    client.post(
        f"/emergency/{active_emergency['emergency_id']}/close?token={token}"
    )
    res = client.get(
        f"/emergency/{active_emergency['emergency_id']}/receipt?token={token}"
    )
    assert res.status_code == 200
    data = res.json()
    assert data["total_spent"] == 5000
    assert data["status"] == "closed"
    assert len(data["payments"]) == 1
    assert data["payments"][0]["amount"] == 5000
    assert data["payments"][0]["destination"] == "bystander"
    assert data["payments"][0]["opay_reference"].startswith("OPAY-")
    assert data["reserve_floor"] == 3000


def test_get_receipt_invalid_token(active_emergency):
    res = client.get(
        f"/emergency/{active_emergency['emergency_id']}/receipt?token=badtoken"
    )
    assert res.status_code == 403