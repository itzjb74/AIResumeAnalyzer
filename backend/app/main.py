from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.routers import resume

app = FastAPI(title=settings.APP_NAME, debug=settings.DEBUG)

# Allow Flutter web/mobile to communicate with the backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, change "*" to your actual domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(resume.router)

@app.get("/health")
def health():
    return {"status": "ok", "app": settings.APP_NAME}