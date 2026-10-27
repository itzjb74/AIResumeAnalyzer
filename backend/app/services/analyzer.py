import re
from collections import Counter

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from app.services.parser import (
    extract_contact_info,
    extract_education,
    estimate_experience_years,
)
from app.services.skills import SOFT_SKILLS, SKILL_DB
from app.services.llm import get_ai_suggestions # <--- ADDED IMPORT

STOPWORDS = {
    "and", "or", "the", "a", "an", "to", "of", "in", "for", "on", "with",
    "is", "are", "as", "at", "by", "be", "from", "that", "this", "it",
    "we", "you", "your", "will", "have", "has", "using", "used", "use",
    "can", "should", "must", "experience", "work", "working", "team",
    "years", "year", "strong", "good", "plus", "etc",
}


# ---------- helpers ----------

def _tokenize(text: str) -> list[str]:
    words = re.findall(r"[a-zA-Z][a-zA-Z+#.\-]{1,}", text.lower())
    return [w for w in words if w not in STOPWORDS and len(w) > 1]


def _find_skills(text: str) -> set[str]:
    """Word-boundary-safe skill detection (handles c++, c#, next.js, ...)."""
    text_lower = " " + re.sub(r"[^a-z0-9+.# ]", " ", text.lower()) + " "
    found = set()
    for skill in SKILL_DB:
        pattern = r"(?<![a-z0-9])" + re.escape(skill) + r"(?![a-z0-9])"
        if re.search(pattern, text_lower):
            found.add(skill)
    return found


def _tfidf_similarity(resume: str, jd: str) -> float:
    """0..1 semantic overlap between resume and JD."""
    if not resume.strip() or not jd.strip():
        return 0.0
    try:
        vec = TfidfVectorizer(
            stop_words="english",
            ngram_range=(1, 2),
            min_df=1,
        )
        matrix = vec.fit_transform([resume, jd])
        return float(cosine_similarity(matrix[0:1], matrix[1:2])[0][0])
    except ValueError:
        return 0.0


def _keyword_density(text: str, top_n: int = 15) -> dict[str, int]:
    counts = Counter(_tokenize(text))
    return dict(counts.most_common(top_n))


def _ats_score(text: str, contact: dict) -> int:
    """Heuristic ATS-friendliness score 0..100."""
    score = 0
    if contact.get("email"):
        score += 20
    if contact.get("phone"):
        score += 10
    if contact.get("linkedin"):
        score += 10
    if contact.get("github"):
        score += 5

    wc = len(text.split())
    if 250 <= wc <= 900:
        score += 25
    elif 150 <= wc < 250 or 900 < wc <= 1200:
        score += 15

    if re.search(r"(education|qualification)", text, re.I):
        score += 10
    if re.search(r"(experience|employment|work history)", text, re.I):
        score += 10
    if re.search(r"(skills|technologies|expertise)", text, re.I):
        score += 10
    return min(score, 100)


# ---------- public API ----------

def analyze_resume(resume_text: str, job_description: str) -> dict:
    contact = extract_contact_info(resume_text)
    exp_years = estimate_experience_years(resume_text)
    education = extract_education(resume_text)

    resume_skills = _find_skills(resume_text)
    jd_skills = _find_skills(job_description)

    matched = resume_skills & jd_skills
    missing = jd_skills - resume_skills
    extra = resume_skills - jd_skills

    skill_cov = (len(matched) / len(jd_skills)) if jd_skills else 0.0
    tfidf_sim = _tfidf_similarity(resume_text, job_description)
    match_pct = round((skill_cov * 0.7 + tfidf_sim * 0.3) * 100, 2)

    ats = _ats_score(resume_text, contact)
    word_count = len(resume_text.split())

    score = int(round(
        match_pct * 0.5
        + ats * 0.3
        + min(exp_years / 5, 1.0) * 100 * 0.2
    ))

    # --- REPLACED WITH AI GENERATION ---
    print("🤖 Asking Groq for AI suggestions...")
    suggestions = get_ai_suggestions(
        resume_text=resume_text,
        job_description=job_description,
        matched=list(matched),
        missing=list(missing)
    )

    return {
        "score": max(0, min(score, 100)),
        "match_percentage": match_pct,
        "matched_skills": sorted(matched),
        "missing_skills": sorted(missing),
        "extra_skills": sorted(extra),
        "experience_years": exp_years,
        "education": education,
        "suggestions": suggestions, # <--- USING AI OUTPUT
        "keyword_density": _keyword_density(resume_text),
        "ats_score": ats,
        "word_count": word_count,
        "contact_info": contact,
    }