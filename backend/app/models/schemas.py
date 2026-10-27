from typing import Optional
from pydantic import BaseModel


class ParseResponse(BaseModel):
    filename: str
    text: str
    char_count: int
    word_count: int
    contact_info: dict[str, Optional[str]]

class ResumeAnalysis(BaseModel):
    score: int
    match_percentage: float
    matched_skills: list[str]
    missing_skills: list[str]
    extra_skills: list[str]
    experience_years: float
    education: list[str]
    suggestions: list[str]
    keyword_density: dict[str, int]
    ats_score: int
    word_count: int
    contact_info: dict[str, Optional[str]]