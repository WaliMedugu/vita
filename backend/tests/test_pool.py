# Tests for pool routes and logic
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

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


# ============================================================
# Fixtures
# ============================================================

@pytest.fixture
def admin_token():
    return register_and_login(
        "pool_admin@vita.com", "password123", "Pool Admin", "08011111111"
    )


@pytest.fixture
def member_token():
    return register_and_login(
        "pool_member@vita.com", "password123", "Pool Member", "08022222222"
    )


@pytest.fixture
def pool_data(admin_token):
    res = client.post("/groups", json={
        "name": "Pool Test Group",
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
def scheduled_pool_data(admin_token):
    res = client.post("/groups", json={
        "name": "Scheduled Pool Group",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "scheduled",
        "contribution_frequency": "weekly",
        "scheduled_contribution_amount": 500
    }, headers=auth_headers(admin_token))
    return {
        "group_id": res.json()["id"],
        "pool_id": res.json()["pool_id"]
    }


# ============================================================
# GET /pool/{id}
# ============================================================

def test_get_pool(admin_token, pool_data):
    res = client.get(f"/pool/{pool_data['pool_id']}",
        headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["balance"] == 0.0
    assert data["contribution_mode"] == "passive"
    assert data["sweep_amount"] == 100.0


def test_get_pool_non_member(member_token, pool_data):
    res = client.get(f"/pool/{pool_data['pool_id']}",
        headers=auth_headers(member_token))
    assert res.status_code == 403


def test_get_pool_not_found(admin_token):
    res = client.get("/pool/00000000-0000-0000-0000-000000000000",
        headers=auth_headers(admin_token))
    assert res.status_code == 404


def test_get_pool_requires_auth(pool_data):
    res = client.get(f"/pool/{pool_data['pool_id']}")
    assert res.status_code == 401


# ============================================================
# POST /pool/{id}/contribute — passive mode
# ============================================================

def test_passive_contribution_success(admin_token, pool_data):
    res = client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 2000
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["amount_swept"] == 100
    assert data["new_balance"] == 100
    assert data["opay_reference"].startswith("OPAY-")
    assert data["message"] == "Contribution successful"


def test_passive_contribution_updates_balance(admin_token, pool_data):
    client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 2000
    }, headers=auth_headers(admin_token))
    client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 3000
    }, headers=auth_headers(admin_token))
    res = client.get(f"/pool/{pool_data['pool_id']}",
        headers=auth_headers(admin_token))
    assert res.json()["balance"] == 200.0


def test_passive_contribution_below_threshold(admin_token, pool_data):
    res = client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 400
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["amount_swept"] == 0
    assert "threshold" in data["message"].lower()


def test_passive_contribution_below_threshold_no_db_record(admin_token, pool_data):
    balance_before = client.get(f"/pool/{pool_data['pool_id']}",
        headers=auth_headers(admin_token)).json()["balance"]
    client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 400
    }, headers=auth_headers(admin_token))
    balance_after = client.get(f"/pool/{pool_data['pool_id']}",
        headers=auth_headers(admin_token)).json()["balance"]
    assert balance_before == balance_after


def test_passive_contribution_missing_transaction_amount(admin_token, pool_data):
    res = client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "transaction_amount" in res.json()["detail"].lower()


def test_passive_contribution_zero_amount(admin_token, pool_data):
    res = client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 0,
        "opay_phone": "08012345678",
        "transaction_amount": 2000
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400


def test_passive_contribution_non_member(member_token, pool_data):
    res = client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 2000
    }, headers=auth_headers(member_token))
    assert res.status_code == 403


# ============================================================
# POST /pool/{id}/contribute — scheduled mode
# ============================================================

def test_scheduled_contribution_success(admin_token, scheduled_pool_data):
    res = client.post(f"/pool/{scheduled_pool_data['pool_id']}/contribute", json={
        "amount": 500,
        "opay_phone": "08012345678"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["amount_swept"] == 500
    assert data["new_balance"] == 500
    assert data["opay_reference"].startswith("OPAY-")


def test_scheduled_contribution_wrong_amount(admin_token, scheduled_pool_data):
    res = client.post(f"/pool/{scheduled_pool_data['pool_id']}/contribute", json={
        "amount": 300,
        "opay_phone": "08012345678"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "500" in res.json()["detail"]


# ============================================================
# GET /pool/{id}/contributions
# ============================================================

def test_get_contributions_empty(admin_token, pool_data):
    res = client.get(f"/pool/{pool_data['pool_id']}/contributions",
        headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["total_contributions"] == 0
    assert data["contributions"] == []


def test_get_contributions_after_contribution(admin_token, pool_data):
    client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
        "amount": 100,
        "opay_phone": "08012345678",
        "transaction_amount": 2000
    }, headers=auth_headers(admin_token))
    res = client.get(f"/pool/{pool_data['pool_id']}/contributions",
        headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["total_contributions"] == 1
    assert data["contributions"][0]["amount"] == 100
    assert data["contributions"][0]["opay_reference"].startswith("OPAY-")
    assert data["contributions"][0]["contributed_by_name"] == "Pool Admin"


def test_get_contributions_non_member(member_token, pool_data):
    res = client.get(f"/pool/{pool_data['pool_id']}/contributions",
        headers=auth_headers(member_token))
    assert res.status_code == 403


def test_get_contributions_ordered_newest_first(admin_token, pool_data):
    for i in range(3):
        client.post(f"/pool/{pool_data['pool_id']}/contribute", json={
            "amount": 100,
            "opay_phone": "08012345678",
            "transaction_amount": 2000
        }, headers=auth_headers(admin_token))
    res = client.get(f"/pool/{pool_data['pool_id']}/contributions",
        headers=auth_headers(admin_token))
    contributions = res.json()["contributions"]
    assert len(contributions) == 3
    dates = [c["created_at"] for c in contributions]
    assert dates == sorted(dates, reverse=True)