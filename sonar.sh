#!/bin/bash

set -e

PROJECT_DIR="$HOME/sonarqube-docker"

# ---- Dependency checks ----
command -v curl >/dev/null 2>&1 || { echo "❌ curl is required"; exit 1; }
command -v xdg-open >/dev/null 2>&1 || { echo "❌ xdg-open is required"; exit 1; }

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_docker() {
    if ! systemctl is-active --quiet docker; then
        log "🐳 Docker is not running. Starting Docker..."
        systemctl start docker

        until systemctl is-active --quiet docker; do
            sleep 1
        done

        log "✔ Docker started"
    else
        log "🐳 Docker is already running"
    fi
}

check_dir() {
    if [ ! -d "$PROJECT_DIR" ]; then
        log "❌ ERROR: Project directory not found: $PROJECT_DIR"
        exit 1
    fi
}

start() {
    log "🚀 Starting SonarQube..."

    check_docker
    check_dir

    cd "$PROJECT_DIR"

    if [ -n "$(docker ps --filter "name=sonarqube" --filter "status=running" -q)" ]; then
        log "✔ SonarQube is already running. No action needed."
    else
        log "📦 Starting containers..."
        docker compose up -d
        log "✔ Containers started"
    fi

    log "⏳ Waiting for SonarQube to be ready..."

    until curl -s http://localhost:9000/api/system/status | grep -q '"status":"UP"'; do
        sleep 3
    done

    log "✔ SonarQube is READY!"

    log "🌐 Opening SonarQube in browser..."
    xdg-open http://localhost:9000 >/dev/null 2>&1 &
}

stop() {
    log "🛑 Stopping SonarQube..."

    check_dir
    cd "$PROJECT_DIR"

    if [ -n "$(docker ps --filter "name=sonarqube" -q)" ]; then
        log "📦 Stopping containers..."
        docker compose down
        log "✔ SonarQube stopped"
    else
        log "✔ SonarQube already stopped. No action needed."
    fi

    if systemctl is-active --quiet docker; then
        log "🐳 Stopping Docker engine..."
        systemctl stop docker
        log "✔ Docker engine stopped"
    else
        log "✔ Docker engine already stopped. No action needed."
    fi
}

restart() {
    log "🔄 Restarting SonarQube..."
    stop
    sleep 2
    start
}

status() {
    log "📊 Checking status..."

    if systemctl is-active --quiet docker; then
        echo "✔ Docker is running"
    else
        echo "❌ Docker is NOT running"
    fi

    echo ""

    docker compose -f "$PROJECT_DIR/docker-compose.yml" ps || echo "⚠ SonarQube not running"
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
