"""
End-to-end integration test — The Adaobi Scenario
Tests the complete 90-second demo flow from NFC tap to receipt.
If this test passes, the demo works.
"""
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


def get_user_id(token):
    import jwt
    payload = jwt.decode(token, options={"verify_signature": False})
    return payload["sub"]


def get_emergency_token(emergency_id, phone):
    from app.utils.emergency_token import generate_emergency_token
    return generate_emergency_token(emergency_id, phone)


# ============================================================
# THE ADAOBI SCENARIO — Full end-to-end
# ============================================================

def test_adaobi_scenario():
    """
    Full 90-second demo flow:
    1.  Adaobi registers and sets up her health profile
    2.  Her group is created with a VitaPool
    3.  Members contribute to the pool
    4.  Bystander taps NFC card — gets health profile + first aid
    5.  Bystander triggers emergency with GPS
    6.  Emergency contact opens VITA link — sees patient info + pool balance
    7.  Emergency contact releases funds to bystander
    8.  Emergency is closed
    9.  Receipt is verified
    10. Pool balance is correct after everything
    """

    # ── STEP 1: Adaobi registers ──────────────────────────────
    adaobi_token = register_and_login(
        "adaobi@vita.com", "password123", "Adaobi Okonkwo", "+2348011111111"
    )
    adaobi_id = get_user_id(adaobi_token)
    assert adaobi_token is not None, "Adaobi registration failed"

    # ── STEP 2: Group member registers ───────────────────────
    member_token = register_and_login(
        "chidi@vita.com", "password123", "Chidi Obi", "+2348022222222"
    )
    assert member_token is not None, "Member registration failed"

    # ── STEP 3: Adaobi creates a VitaPool group ───────────────
    group_res = client.post("/groups", json={
        "name": "Kano Market Traders Pool",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "passive"
    }, headers=auth_headers(adaobi_token))
    assert group_res.status_code == 200, f"Group creation failed: {group_res.json()}"
    group_id = group_res.json()["id"]
    pool_id = group_res.json()["pool_id"]
    assert pool_id is not None, "Pool was not created with group"

    # ── STEP 4: Invite member to group ───────────────────────
    invite_res = client.post(f"/groups/{group_id}/invite", json={
        "email": "chidi@vita.com"
    }, headers=auth_headers(adaobi_token))
    assert invite_res.status_code == 200, f"Invite failed: {invite_res.json()}"

    # ── STEP 5: Verify group has 2 members ───────────────────
    members_res = client.get(f"/groups/{group_id}/members",
        headers=auth_headers(adaobi_token))
    assert members_res.status_code == 200
    assert len(members_res.json()) == 2, "Group should have 2 members"

    # ── STEP 6: Adaobi creates her health profile ─────────────
    profile_res = client.post("/profile", json={
        "blood_type": "O+",
        "allergies": ["Penicillin"],
        "conditions": ["Hypertension"],
        "emergency_contact": "+2348033333333",
        "emergency_contact_2": "+2348044444444",
        "pool_id": pool_id
    }, headers=auth_headers(adaobi_token))
    assert profile_res.status_code == 200, f"Profile creation failed: {profile_res.json()}"
    assert profile_res.json()["blood_type"] == "O+"
    assert "Penicillin" in profile_res.json()["allergies"]

    # ── STEP 7: Members contribute to pool ───────────────────
    # Adaobi contributes
    contrib_res = client.post(f"/pool/{pool_id}/contribute", json={
        "amount": 100,
        "opay_phone": "+2348011111111",
        "transaction_amount": 5000
    }, headers=auth_headers(adaobi_token))
    assert contrib_res.status_code == 200
    assert contrib_res.json()["amount_swept"] == 100
    assert contrib_res.json()["opay_reference"].startswith("OPAY-")

    # Chidi contributes
    contrib_res2 = client.post(f"/pool/{pool_id}/contribute", json={
        "amount": 100,
        "opay_phone": "+2348022222222",
        "transaction_amount": 3000
    }, headers=auth_headers(member_token))
    assert contrib_res2.status_code == 200

    # Add more funds for the emergency
    for _ in range(10):
        client.post(f"/pool/{pool_id}/contribute", json={
            "amount": 1000,
            "opay_phone": "+2348011111111",
            "transaction_amount": 10000
        }, headers=auth_headers(adaobi_token))

    # ── STEP 8: Verify pool balance ───────────────────────────
    pool_res = client.get(f"/pool/{pool_id}",
        headers=auth_headers(adaobi_token))
    assert pool_res.status_code == 200
    pool_balance_before = pool_res.json()["balance"]
    assert pool_balance_before == 10200.0, f"Expected 10200, got {pool_balance_before}"

    # ── STEP 9: Bystander gets NFC profile (public) ───────────
    nfc_res = client.get(f"/profile/nfc/{adaobi_id}")
    assert nfc_res.status_code == 200
    nfc_data = nfc_res.json()
    assert nfc_data["name"] == "Adaobi Okonkwo"
    assert nfc_data["blood_type"] == "O+"
    assert "Penicillin" in nfc_data["allergies"]
    assert "Hypertension" in nfc_data["conditions"]
    assert nfc_data["pool_id"] == pool_id

    # ── STEP 10: Bystander gets first aid (public) ────────────
    first_aid_res = client.post("/gemini/first-aid", json={
        "conditions": ["Hypertension"],
        "allergies": ["Penicillin"]
    })
    assert first_aid_res.status_code == 200
    assert len(first_aid_res.json()["guidance"]) > 0
    assert "disclaimer" in first_aid_res.json()

    # ── STEP 11: Bystander triggers emergency (public) ────────
    emergency_res = client.post("/emergency/trigger", json={
        "user_id": adaobi_id,
        "lat": 11.9804,
        "lng": 8.5158
    })
    assert emergency_res.status_code == 200, f"Emergency trigger failed: {emergency_res.json()}"
    emergency_id = emergency_res.json()["id"]
    assert emergency_res.json()["status"] == "active"
    assert emergency_res.json()["pool_id"] == pool_id

    # ── STEP 12: Emergency contact opens VITA link (public) ───
    ec_token = get_emergency_token(emergency_id, "+2348033333333")
    ec_view_res = client.get(
        f"/emergency/{emergency_id}?token={ec_token}"
    )
    assert ec_view_res.status_code == 200, f"EC view failed: {ec_view_res.json()}"
    ec_data = ec_view_res.json()
    assert ec_data["patient_name"] == "Adaobi Okonkwo"
    assert ec_data["patient_blood_type"] == "O+"
    assert "Penicillin" in ec_data["patient_allergies"]
    assert ec_data["status"] == "active"
    assert len(ec_data["pools"]) > 0
    assert ec_data["pools"][0]["balance"] == pool_balance_before

    # ── STEP 13: Emergency contact releases transport money ───
    release_res = client.post(
        f"/emergency/{emergency_id}/release?token={ec_token}",
        json={
            "amount": 2000,
            "note": "Transport to hospital"
        }
    )
    assert release_res.status_code == 200, f"Release failed: {release_res.json()}"
    assert release_res.json()["amount_released"] == 2000
    assert release_res.json()["destination"] == "bystander"
    assert release_res.json()["opay_reference"].startswith("OPAY-")
    assert release_res.json()["new_total_spent"] == 2000
    balance_after_transport = release_res.json()["new_pool_balance"]

    # ── STEP 14: Emergency contact releases hospital bill ─────
    release_res2 = client.post(
        f"/emergency/{emergency_id}/release?token={ec_token}",
        json={
            "amount": 5000,
            "note": "Hospital bill payment"
        }
    )
    assert release_res2.status_code == 200, f"Hospital release failed: {release_res2.json()}"
    assert release_res2.json()["new_total_spent"] == 7000
    final_pool_balance = release_res2.json()["new_pool_balance"]

    # ── STEP 15: Verify reserve floor is protected ────────────
    # Try to release more than available (balance - reserve_floor)
    over_release_res = client.post(
        f"/emergency/{emergency_id}/release?token={ec_token}",
        json={
            "amount": final_pool_balance,  # this would breach reserve floor
            "note": "Trying to drain pool"
        }
    )
    assert over_release_res.status_code == 400
    assert "reserve floor" in over_release_res.json()["detail"].lower()

    # ── STEP 16: Close emergency ──────────────────────────────
    close_res = client.post(
        f"/emergency/{emergency_id}/close?token={ec_token}"
    )
    assert close_res.status_code == 200
    assert close_res.json()["message"] == "Emergency closed"
    assert close_res.json()["total_spent"] == 7000

    # ── STEP 17: Get receipt ──────────────────────────────────
    receipt_res = client.get(
        f"/emergency/{emergency_id}/receipt?token={ec_token}"
    )
    assert receipt_res.status_code == 200, f"Receipt failed: {receipt_res.json()}"
    receipt = receipt_res.json()
    assert receipt["status"] == "closed"
    assert receipt["total_spent"] == 7000
    assert receipt["patient_name"] == "Adaobi Okonkwo"
    assert len(receipt["payments"]) == 2
    assert receipt["payments"][0]["amount"] == 2000
    assert receipt["payments"][0]["note"] == "Transport to hospital"
    assert receipt["payments"][1]["amount"] == 5000
    assert receipt["payments"][1]["note"] == "Hospital bill payment"
    assert receipt["reserve_floor"] == 3000
    assert receipt["remaining_balance"] == final_pool_balance

    # ── STEP 18: Verify contribution history ─────────────────
    contrib_history = client.get(f"/pool/{pool_id}/contributions",
        headers=auth_headers(adaobi_token))
    assert contrib_history.status_code == 200
    assert contrib_history.json()["total_contributions"] == 12

    # ── STEP 19: Verify final pool balance ───────────────────
    final_pool_res = client.get(f"/pool/{pool_id}",
        headers=auth_headers(adaobi_token))
    assert final_pool_res.status_code == 200
    assert final_pool_res.json()["balance"] == final_pool_balance

    print("\n✅ ADAOBI SCENARIO COMPLETE")
    print(f"   Pool started at:    N{pool_balance_before}")
    print(f"   Total released:     N7,000")
    print(f"   Transport payment:  N2,000")
    print(f"   Hospital payment:   N5,000")
    print(f"   Pool remaining:     N{final_pool_balance}")
    print(f"   Reserve floor:      N3,000 protected")
    print(f"   Payments recorded:  2")
    print(f"   Contributions:      12")
    print("   Demo is ready. 🚀")