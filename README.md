# 🤖 AI Resume Analyzer

**🔴 [Live Demo](https://airesumeanalyzer-frontend.vercel.app)** *(Note: The free backend server goes to sleep after 15 mins of inactivity. The first request may take 45-60 seconds to wake up).*

A full-stack, AI-powered application that analyzes resumes against job descriptions. Built with **Flutter** (Frontend), **FastAPI** (Backend), and **Groq LLM** (AI Feedback). 

It calculates an ATS score, matches skills, extracts contact info, uses OCR to read scanned PDFs, and generates highly specific, actionable feedback to help candidates land their dream job.

## ✨ Features

- **📄 Multi-Format Support:** Parses PDF, DOCX, and TXT files.
- **📸 Built-in OCR:** If a user uploads a scanned/image-based PDF, the backend automatically uses Tesseract OCR to extract the text.
- **🧠 Real AI Feedback:** Integrates with the **Groq API (Llama 3)** to generate custom, recruiter-level suggestions based on the specific resume and job description.
- **📊 Intelligent Scoring:** 
  - **ATS Score:** Checks for formatting, contact info, and section headers.
  - **Match Percentage:** Uses TF-IDF and Cosine Similarity to calculate semantic overlap between the resume and JD.
- **📱 Cross-Platform:** The Flutter frontend runs seamlessly on Web, Android, and iOS.
- **📑 PDF Export:** Users can download a beautifully formatted PDF report of their analysis.

## 🛠️ Tech Stack

**Frontend (Flutter)**
- `dio` (REST API communication)
- `file_picker` (File selection)
- `percent_indicator` (Dynamic circular charts)
- `pdf` & `printing` (PDF report generation)

**Backend (Python / FastAPI)**
- `FastAPI` & `Uvicorn` (REST API)
- `pdfplumber` & `python-docx` (Text extraction)
- `pytesseract` & `Pillow` (OCR for scanned images)
- `scikit-learn` (NLP & TF-IDF similarity)
- `groq` (LLM integration for AI suggestions)

**Cloud & DevOps**
- **Docker:** For containerizing the backend with Linux dependencies (Tesseract & Poppler).
- **Render:** Hosting the live FastAPI backend.
- **Vercel:** Hosting the live Flutter Web frontend.

## 🚀 Getting Started (Local Development)

### 1. Backend Setup (FastAPI)

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
# Mac/Linux: source .venv/bin/activate

pip install -r requirements.txt
