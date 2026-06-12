import os
import json
import time  # Import time for handling backoff delays
from google import genai
from google.genai import types

# ======================
# CONFIG
# ======================
if not os.getenv("GEMINI_API_KEY"):
    raise Exception("❌ Error: GEMINI_API_KEY environment variable is not set.")

# FIX 1: Explicitly force the production 'v1' API version to bypass the v1beta 404 bug
client = genai.Client(http_options={'api_version': 'v1'})

# ======================
# LOAD SONARQUBE DATA
# ======================
if not os.path.exists("sonar_issues.json"):
    raise FileNotFoundError("❌ Error: sonar_issues.json not found. Run the bash script first.")

with open("sonar_issues.json", "r") as f:
    data = json.load(f)

issues = data.get("issues", [])

# Strip unnecessary tokens
clean_issues = []
for i in issues:
    clean_issues.append({
        "file": i.get("component"),
        "line": i.get("line"),
        "severity": i.get("severity"),
        "type": i.get("type"),
        "message": i.get("message"),
        "rule": i.get("rule"),
    })

# ======================
# PROMPT
# ======================
prompt = f"""
You are an expert senior security code reviewer.

Generate a PROFESSIONAL, comprehensive Markdown report from this SonarQube analysis data. 
The report must be structured professionally as it is intended for a university project submission.

Rules:
1. Group issues logically into: Security, Bugs, Code Smells, and Accessibility.
2. Explain what each category means briefly before listing the issues.
3. Prioritize visibility: Highlight 'HIGH', 'CRITICAL', and 'BLOCKER' issues at the very top of their respective sections.
4. Provide concrete, actionable fix recommendations or code snippets where applicable.
5. Keep the design clean, using tables or markdown blockquotes to make it highly readable.

SonarQube Data (JSON):
{json.dumps(clean_issues, indent=2)}

Output Format Layout:
# SonarQube Security & Code Quality Report

## Summary
...

## Security Issues
...

## Bugs
...

## Code Smells
...

## Recommendations & Next Steps
...
"""

# ======================
# CALL GEMINI API WITH RETRY LOGIC
# ======================
print("🤖 Sending data to Gemini...")

MAX_RETRIES = 5
INITIAL_DELAY = 2  # Start with a 2-second delay

for attempt in range(1, MAX_RETRIES + 1):
    try:
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
        )
        
        # ======================
        # SAVE MARKDOWN
        # ======================
        with open("sonar_ai_report.md", "w", encoding="utf-8") as f:
            f.write(response.text)

        print("✅ AI Report successfully generated: sonar_ai_report.md")
        break  # Success! Break out of the retry loop.

    except Exception as e:
        # Check if it is a 503 error or overloaded service
        if "503" in str(e) or "UNAVAILABLE" in str(e):
            if attempt == MAX_RETRIES:
                print(f"❌ Failed after {MAX_RETRIES} attempts due to high server demand. Please try again in a few minutes.")
                break
            
            sleep_time = INITIAL_DELAY * (2 ** (attempt - 1))  # Exponential backoff: 2s, 4s, 8s, 16s...
            print(f"⚠️ Gemini is experiencing high demand (Attempt {attempt}/{MAX_RETRIES}). Retrying in {sleep_time} seconds...")
            time.sleep(sleep_time)
        else:
            # If it's a completely different error (e.g., Auth, Invalid data), don't retry, just crash.
            print(f"❌ Failed to generate report due to a critical API error: {e}")
            break
