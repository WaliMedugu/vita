from fastapi import FastAPI
from app.routes import auth, pool, emergency, profile, gemini, sms, hospitals, group

app = FastAPI(title="VITA API", version="1.0.0")

app.include_router(auth.router,       prefix="/auth",      tags=["Auth"])
app.include_router(pool.router,       prefix="/pool",      tags=["Pool"])
app.include_router(emergency.router,  prefix="/emergency", tags=["Emergency"])
app.include_router(profile.router,    prefix="/profile",   tags=["Profile"])
app.include_router(gemini.router,     prefix="/gemini",    tags=["Gemini"])
app.include_router(sms.router,        prefix="/sms",       tags=["SMS"])
app.include_router(hospitals.router,  prefix="/hospitals", tags=["Hospitals"])
app.include_router(group.router,      prefix="/groups",    tags=["Groups"])

@app.get("/")
def root():
    return {"status": "VITA API running"}
