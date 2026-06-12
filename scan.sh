# run export SONAR_TOKEN="sqp_xxxxx" for a new shell, with the token got from sonarqube > my account > security

# token : squ_185d50205850559a822b9c0e3ad792ab9d8f8323 (11 june, expire:30 days)

#!/bin/bash

PROJECT_PATH="$1"

if [ -z "$PROJECT_PATH" ]; then
  echo "Usage: ./scan.sh <project-path>"
  exit 1
fi

# Convert to absolute path (important for Docker mounting)
PROJECT_PATH=$(realpath "$PROJECT_PATH")

IMAGE="sonarsource/sonar-scanner-cli:12.1.0.3233_8.0.1"

# Check SONAR_TOKEN
if [ -z "$SONAR_TOKEN" ]; then
  echo "ERROR: SONAR_TOKEN is not set"
  exit 1
fi

# Check sonar-project.properties exists
if [ ! -f "$PROJECT_PATH/sonar-project.properties" ]; then
  echo "ERROR: sonar-project.properties not found in:"
  echo "$PROJECT_PATH"
  exit 1
fi

echo "Using project: $PROJECT_PATH"

# Ensure image exists locally
docker image inspect "$IMAGE" >/dev/null 2>&1 || {
  echo "Pulling SonarScanner image..."
  docker pull "$IMAGE" || {
    echo "Failed to pull image"
    exit 1
  }
}

# Run scanner
docker run --rm \
  --network sonarqube-docker_default \
  -e SONAR_HOST_URL="http://sonarqube:9000" \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -v "$PROJECT_PATH:/usr/src" \
  -w /usr/src \
  "$IMAGE"
