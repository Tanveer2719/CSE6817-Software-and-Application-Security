# Project Description

This project is an automated DevSecOps-style pipeline that integrates **SonarQube static code analysis** with **AI-powered reporting using Google Gemini**. It is designed to analyze a software project, extract security and code quality issues, and generate a human-readable professional report.

---

## Overview of What This Project Does

The system works in four main stages:

1. **Infrastructure Setup**
   - Launches SonarQube and PostgreSQL using Docker Compose.
   - Ensures a fully containerized and reproducible environment.

2. **Code Analysis**
   - Uses SonarScanner (running inside Docker) to analyze a given project.
   - Sends results to the SonarQube server.

3. **Issue Extraction**
   - Fetches detected issues from SonarQube using its REST API.
   - Stores the results in a structured JSON format.

4. **AI Report Generation**
   - Sends the extracted issues to Google Gemini API.
   - Generates a structured Markdown security and code quality report.

---

## File Descriptions

### `docker-compose.yml`
Defines the complete container setup for the system.

- Starts **SonarQube Community Edition**
- Starts a **PostgreSQL database** for SonarQube
- Configures:
  - Ports (`9000:9000`)
  - Environment variables for database connection
  - Persistent volumes for data, logs, and extensions
- Includes health checks to ensure the database is ready before SonarQube starts

---

### `sonarqube.sh`
A lifecycle management script for SonarQube.

It provides four main commands:

- `start`
  - Starts Docker (if not running)
  - Launches SonarQube containers
  - Waits until SonarQube is fully ready
  - Opens the web UI automatically in the browser

- `stop`
  - Stops SonarQube containers
  - Optionally stops Docker service

- `restart`
  - Restarts the full SonarQube stack

- `status`
  - Displays whether Docker and SonarQube are running

---

### `scan.sh`
Runs SonarScanner against a target project.

Key functions:
- Accepts a project path as input
- Ensures a valid `sonar-project.properties` file exists
- Uses the official SonarScanner Docker image
- Connects to the SonarQube server using Docker networking
- Sends analysis results using `SONAR_TOKEN` authentication

Output:
- Uploads analysis results to SonarQube for processing

---

### `generate_report.sh`
Automates the full report generation pipeline.

Steps:
1. Takes a **SonarQube project key** as input
2. Fetches issues using SonarQube REST API
3. Saves the results into `sonar_issues.json`
4. Executes the Python script to generate AI report

Output:
- `sonar_ai_report.md` (final report)

---

### `generate_ai_report.py`
The AI report generation engine using Google Gemini.

Functionality:
- Loads `sonar_issues.json`
- Cleans and extracts relevant fields (severity, file, message, rule, etc.)
- Builds a structured prompt for Gemini
- Sends data to `gemini-2.5-flash`
- Implements retry logic with exponential backoff (for API overload handling)
- Generates a professional Markdown report

Key features:
- Groups issues into Security, Bugs, Code Smells, and Accessibility
- Prioritizes HIGH / CRITICAL / BLOCKER issues
- Provides actionable recommendations
- Produces a clean Markdown report suitable for academic submission

---

## Output Files

- `sonar_issues.json`
  - Raw issues exported from SonarQube API

- `sonar_ai_report.md`
  - Final AI-generated security and code quality report

---

## Summary

This project creates a fully automated pipeline:

**Codebase → SonarScanner → SonarQube → Issue API → Gemini AI → Markdown Report**

It is useful for:
- Security analysis automation
- Academic software engineering projects
- DevSecOps learning demonstrations
- AI-assisted code review systems
