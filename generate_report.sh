#!/bin/bash

# =========================
# CONFIG
# =========================

PROJECT_KEY=$1
SONAR_URL="http://localhost:9000"
OUTPUT_JSON="sonar_issues.json"
PY_SCRIPT="generate_ai_report.py"

# =========================
# VALIDATION
# =========================

if [ -z "$PROJECT_KEY" ]; then
  echo "❌ Usage: ./generate_report.sh <project_key>"
  exit 1
fi

if [ ! -f "$PY_SCRIPT" ]; then
  echo "❌ Python script not found: $PY_SCRIPT"
  exit 1
fi

if [ -z "$SONAR_TOKEN" ]; then
  echo "❌ SONAR_TOKEN is not set"
  exit 1
fi

echo "======================================"
echo "📌 Project Key: $PROJECT_KEY"
echo "======================================"

# =========================
# STEP 1: EXPORT SONARQUBE ISSUES
# =========================

echo "🔄 Exporting SonarQube issues..."

curl -s -u $SONAR_TOKEN: \
"$SONAR_URL/api/issues/search?componentKeys=$PROJECT_KEY&ps=500" \
> $OUTPUT_JSON

if [ $? -ne 0 ]; then
  echo "❌ Failed to fetch SonarQube issues"
  exit 1
fi

echo "✅ Issues saved to $OUTPUT_JSON"

# =========================
# STEP 2: RUN AI REPORT GENERATOR
# =========================

echo "🤖 Generating AI report using Gemini..."

python3 $PY_SCRIPT

if [ $? -ne 0 ]; then
  echo "❌ Python script failed"
  exit 1
fi

echo "======================================"
echo "🎉 Report generation completed!"
echo "📄 Output: sonar_ai_report.md"
echo "======================================"
