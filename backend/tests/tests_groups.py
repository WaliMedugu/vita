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
        "admin_test@vita.com", "password123", "Admin User", "08011111111"
    )


@pytest.fixture
def member_token():
    return register_and_login(
        "member_test@vita.com", "password123", "Member User", "08022222222"
    )


@pytest.fixture
def group_id(admin_token):
    res = client.post("/groups", json={
        "name": "Test Group",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "passive"
    }, headers=auth_headers(admin_token))
    return res.json()["id"]


# ============================================================
# Group Creation
# ============================================================

def test_create_group_passive_mode(admin_token):
    res = client.post("/groups", json={
        "name": "Passive Group",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "passive"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["name"] == "Passive Group"
    assert data["contribution_mode"] == "passive"
    assert data["pool_id"] is not None
    assert data["member_count"] == 1


def test_create_group_scheduled_mode(admin_token):
    res = client.post("/groups", json={
        "name": "Scheduled Group",
        "spending_limit": 50000,
        "reserve_floor": 3000,
        "sweep_amount": 100,
        "contribution_mode": "scheduled",
        "contribution_frequency": "weekly",
        "scheduled_contribution_amount": 500
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["contribution_mode"] == "scheduled"
    assert data["contribution_frequency"] == "weekly"
    assert data["scheduled_contribution_amount"] == 500


def test_create_group_scheduled_missing_frequency(admin_token):
    res = client.post("/groups", json={
        "name": "Bad Group",
        "contribution_mode": "scheduled",
        "scheduled_contribution_amount": 500
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "frequency" in res.json()["detail"].lower()


def test_create_group_scheduled_missing_amount(admin_token):
    res = client.post("/groups", json={
        "name": "Bad Group",
        "contribution_mode": "scheduled",
        "contribution_frequency": "weekly"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "amount" in res.json()["detail"].lower()


def test_create_group_passive_with_frequency_rejected(admin_token):
    res = client.post("/groups", json={
        "name": "Bad Group",
        "contribution_mode": "passive",
        "contribution_frequency": "weekly",
        "scheduled_contribution_amount": 500
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "passive" in res.json()["detail"].lower()


def test_create_group_requires_auth():
    res = client.post("/groups", json={"name": "No Auth Group"})
    assert res.status_code == 401


# ============================================================
# Invite Member
# ============================================================

def test_invite_member(admin_token, member_token, group_id):
    res = client.post(f"/groups/{group_id}/invite", json={
        "email": "member_test@vita.com"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    assert "added" in res.json()["message"].lower()


def test_invite_nonexistent_user(admin_token, group_id):
    res = client.post(f"/groups/{group_id}/invite", json={
        "email": "ghost@vita.com"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 404


def test_invite_duplicate_member(admin_token, member_token, group_id):
    client.post(f"/groups/{group_id}/invite", json={
        "email": "member_test@vita.com"
    }, headers=auth_headers(admin_token))
    res = client.post(f"/groups/{group_id}/invite", json={
        "email": "member_test@vita.com"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 400
    assert "already" in res.json()["detail"].lower()


def test_non_admin_cannot_invite(member_token, group_id):
    res = client.post(f"/groups/{group_id}/invite", json={
        "email": "admin_test@vita.com"
    }, headers=auth_headers(member_token))
    assert res.status_code == 403


# ============================================================
# Get Group
# ============================================================

def test_get_group_as_member(admin_token, group_id):
    res = client.get(f"/groups/{group_id}",
        headers=auth_headers(admin_token))
    assert res.status_code == 200
    data = res.json()
    assert data["id"] == group_id
    assert data["pool_balance"] == 0.0


def test_get_group_as_non_member(member_token, group_id):
    res = client.get(f"/groups/{group_id}",
        headers=auth_headers(member_token))
    assert res.status_code == 403


def test_get_nonexistent_group(admin_token):
    res = client.get("/groups/00000000-0000-0000-0000-000000000000",
        headers=auth_headers(admin_token))
    assert res.status_code == 404


# ============================================================
# Get Members
# ============================================================

def test_get_members(admin_token, member_token, group_id):
    client.post(f"/groups/{group_id}/invite", json={
        "email": "member_test@vita.com"
    }, headers=auth_headers(admin_token))
    res = client.get(f"/groups/{group_id}/members",
        headers=auth_headers(admin_token))
    assert res.status_code == 200
    assert len(res.json()) == 2


def test_non_member_cannot_get_members(member_token, group_id):
    res = client.get(f"/groups/{group_id}/members",
        headers=auth_headers(member_token))
    assert res.status_code == 403


# ============================================================
# Contribution Change
# ============================================================

def test_contribution_change_to_scheduled(admin_token, group_id):
    res = client.patch(f"/groups/{group_id}/contribution", json={
        "contribution_mode": "scheduled",
        "contribution_frequency": "monthly",
        "scheduled_contribution_amount": 1000
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    assert res.json()["pending_mode"] == "scheduled"
    assert res.json()["pending_frequency"] == "monthly"


def test_contribution_change_to_passive(admin_token, group_id):
    res = client.patch(f"/groups/{group_id}/contribution", json={
        "contribution_mode": "passive"
    }, headers=auth_headers(admin_token))
    assert res.status_code == 200
    assert res.json()["pending_mode"] == "passive"


def test_non_admin_cannot_change_contribution(member_token, group_id):
    res = client.patch(f"/groups/{group_id}/contribution", json={
        "contribution_mode": "passive"
    }, headers=auth_headers(member_token))
    assert res.status_code == 403