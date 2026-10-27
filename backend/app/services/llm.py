import os
import json
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

# Initialize the Groq client
client = Groq(api_key=os.getenv("GROQ_API_KEY", "").strip())

def get_ai_suggestions(resume_text: str, job_description: str, matched: list, missing: list) -> list[str]:
    """Uses Groq to generate personalized resume feedback."""
    
    # We use llama3-70b-8192 because it's much smarter and handles JSON perfectly
    model = "openai/gpt-oss-120b" 
    
    system_prompt = """
    You are an expert technical recruiter. Analyze the resume and job description.
    Provide 3-4 highly specific, actionable suggestions to improve the resume for this specific job.
    Do not give generic advice. Reference the actual skills and projects.
    Return ONLY a valid JSON object with a single key "suggestions" containing a list of strings.
    Example format: {"suggestions": ["Suggestion 1", "Suggestion 2"]}
    """
    
    user_prompt = f"""
    RESUME TEXT:
    {resume_text[:3000]}
    
    JOB DESCRIPTION:
    {job_description}
    
    MATCHED SKILLS: {', '.join(matched)}
    MISSING SKILLS: {', '.join(missing)}
    """

    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            temperature=0.5,
            max_tokens=800
        )
        
        content = response.choices[0].message.content.strip()
        
        # Sometimes the LLM wraps JSON in markdown blocks like ```json ... ```
        # We need to strip that out before parsing.
        if content.startswith("```json"):
            content = content.replace("```json\n", "").replace("```", "").strip()
        elif content.startswith("```"):
            content = content.replace("```\n", "").replace("```", "").strip()
            
        data = json.loads(content)
        return data.get("suggestions", [])
        
    except json.JSONDecodeError:
        # If the AI didn't return JSON, just split the text into sentences
        print("⚠️ Groq returned text instead of JSON. Parsing manually...")
        return [line.strip() for line in content.split('\n') if line.strip()][:4]
        
    except Exception as e:
        print(f"❌ Groq API Error: {e}")
        return ["Could not generate AI suggestions at this time. Please check your API key."]