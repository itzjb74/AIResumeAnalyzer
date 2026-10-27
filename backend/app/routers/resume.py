from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from app.config import settings
from app.models.schemas import ParseResponse, ResumeAnalysis
from app.services.analyzer import analyze_resume
from app.services.parser import extract_contact_info, extract_text

router = APIRouter(prefix="/api", tags=["resume"])


@router.post("/parse", response_model=ParseResponse)
async def parse_resume(file: UploadFile = File(...)):
    """Extract text from an uploaded resume (no analysis yet)."""
    content = await file.read()

    max_bytes = settings.MAX_FILE_SIZE_MB * 1024 * 1024
    if len(content) > max_bytes:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Max {settings.MAX_FILE_SIZE_MB} MB.",
        )

    if len(content) == 0:
        raise HTTPException(status_code=400, detail="File is empty.")

    try:
        text = extract_text(content, file.filename or "")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Parse error: {e}")

    if not text.strip():
        raise HTTPException(
            status_code=422,
            detail="No text could be extracted (file may be a scanned image).",
        )

    return ParseResponse(
        filename=file.filename or "unknown",
        text=text,
        char_count=len(text),
        word_count=len(text.split()),
        contact_info=extract_contact_info(text),
    )


@router.post("/analyze", response_model=ResumeAnalysis)
async def analyze(
    file: UploadFile = File(...),
    job_description: str = Form(...),
):
    """Upload a resume + paste a JD → full AI analysis."""
    if not job_description.strip():
        raise HTTPException(
            status_code=400, detail="Job description is required."
        )

    content = await file.read()

    max_bytes = settings.MAX_FILE_SIZE_MB * 1024 * 1024
    if len(content) > max_bytes:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Max {settings.MAX_FILE_SIZE_MB} MB.",
        )

    if len(content) == 0:
        raise HTTPException(status_code=400, detail="File is empty.")

    try:
        text = extract_text(content, file.filename or "")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Parse error: {e}")

    if not text.strip():
        raise HTTPException(
            status_code=422,
            detail="No text could be extracted from the file.",
        )

    return analyze_resume(text, job_description.strip())