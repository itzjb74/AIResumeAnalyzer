import re
from io import BytesIO
import os
import platform  # <--- ADDED IMPORT

import pdfplumber
from docx import Document
import pytesseract
from PIL import Image

# --- TESSERACT CONFIGURATION ---
# If on Windows, set the path. If on Linux (Docker), it finds it automatically.
if platform.system() == "Windows":
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Regexes for contact extraction
EMAIL_RE = re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
PHONE_RE = re.compile(r"(\+?\d[\d\s\-().]{8,}\d)")
LINKEDIN_RE = re.compile(r"(linkedin\.com/in/[A-Za-z0-9\-_]+)", re.I)
GITHUB_RE = re.compile(r"(github\.com/[A-Za-z0-9\-_]+)", re.I)

SUPPORTED_EXTENSIONS = (".pdf", ".docx", ".txt")


def extract_text(file_bytes: bytes, filename: str) -> str:
    """Extract plain text from a resume file."""
    name = (filename or "").lower()

    if name.endswith(".pdf"):
        text = _extract_pdf(file_bytes)
        # If no text was found (scanned PDF), run OCR
        if not text.strip():
            print("⚠️ No text found. Running OCR on scanned PDF...")
            text = _ocr_pdf(file_bytes)
        return text
        
    if name.endswith(".docx"):
        return _extract_docx(file_bytes)
    if name.endswith(".txt"):
        return file_bytes.decode("utf-8", errors="ignore")

    raise ValueError(
        f"Unsupported file type. Use one of: {', '.join(SUPPORTED_EXTENSIONS)}"
    )


def _extract_pdf(data: bytes) -> str:
    parts: list[str] = []
    with pdfplumber.open(BytesIO(data)) as pdf:
        for page in pdf.pages:
            parts.append(page.extract_text() or "")
    return "\n".join(parts)


def _ocr_pdf(data: bytes) -> str:
    """Convert PDF pages to images and extract text using Tesseract."""
    extracted_text = []
    with pdfplumber.open(BytesIO(data)) as pdf:
        for page in pdf.pages:
            # Render the PDF page to a high-res image
            im = page.to_image(resolution=300)
            # Extract text using OCR
            text = pytesseract.image_to_string(im.original)
            extracted_text.append(text)
    return "\n".join(extracted_text)


def _extract_docx(data: bytes) -> str:
    doc = Document(BytesIO(data))
    return "\n".join(p.text for p in doc.paragraphs)


def extract_contact_info(text: str) -> dict:
    """Extract email, phone, LinkedIn, GitHub from raw text."""
    email_match = EMAIL_RE.search(text)
    phone_match = PHONE_RE.search(text)
    li_match = LINKEDIN_RE.search(text)
    gh_match = GITHUB_RE.search(text)

    return {
        "email": email_match.group(0) if email_match else None,
        "phone": phone_match.group(0).strip() if phone_match else None,
        "linkedin": li_match.group(0) if li_match else None,
        "github": gh_match.group(0) if gh_match else None,
    }

def estimate_experience_years(text: str) -> float:
    """Smarter estimate looking for explicit date ranges (e.g., 2018-2022)."""
    ranges = re.findall(
        r"((?:19|20)\d{2})\s*(?:-|–|to)\s*((?:19|20)\d{2}|present|current)", 
        text.lower()
    )
    
    total_years = 0.0
    current_year = 2024
    
    for start, end in ranges:
        start_y = int(start)
        end_y = current_year if end in ("present", "current") else int(end)
        if end_y >= start_y:
            total_years += (end_y - start_y)
            
    return total_years

EDU_KEYWORDS = [
    "bachelor", "master", "phd", "b.sc", "m.sc", "mba", "b.tech",
    "m.tech", "university", "college", "institute", "degree",
]


def extract_education(text: str) -> list[str]:
    """Pick out up to 5 lines that look like education entries."""
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    hits = [l for l in lines if any(k in l.lower() for k in EDU_KEYWORDS)]
    return hits[:5]