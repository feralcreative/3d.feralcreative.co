#!/bin/bash
set -e

# ============================================================================
# Deployment Utilities for 3D Printer Stream
# ============================================================================
# This script provides utility commands for managing the deployed container
# on the NAS, including logs, status, restart, stop, start, shell access,
# backup, and restore operations.
# ============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration (must match prod.sh) - UPDATE THESE VALUES
NAS_USER="your_nas_username"
NAS_HOST="nas.yourdomain.com"
NAS_SSH_PORT="22"
NAS_DEPLOY_PATH="/volume1/web/3d-printer-stream"
CONTAINER_NAME="3d-printer-stream"

# SSH configuration
SSH_KEY_PATH=""
USE_SSH_AGENT=false

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

get_ssh_key() {
    if [ -n "$SSH_KEY_PATH" ]; then
        echo "$SSH_KEY_PATH"
        return
    fi
    
    # Check for common SSH key locations
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo "$HOME/.ssh/id_ed25519"
    elif [ -f "$HOME/.ssh/id_rsa" ]; then
        echo "$HOME/.ssh/id_rsa"
    else
        echo ""
    fi
}

# ============================================================================
# Utility Commands
# ============================================================================

show_logs() {
    log_info "Showing container logs (Ctrl+C to exit)..."
    SSH_KEY=$(get_ssh_key)
    if [ -n "$SSH_KEY" ]; then
        ssh -p ${NAS_SSH_PORT} -i ${SSH_KEY} ${NAS_USER}@${NAS_HOST} "docker logs -f ${CONTAINER_NAME}"
    else
        ssh -p ${NAS_SSH_PORT} ${NAS_USER}@${NAS_HOST} "docker logs -f ${CONTAINER_NAME}"
    fi
}

show_status() {
    log_info "Checking container status..."
    SSH_KEY=$(get_ssh_key)
    if [ -n "$SSH_KEY" ]; then
        ssh -p ${NAS_SSH_PORT} -i ${SSH_KEY} ${NAS_USER}@${NAS_HOST} "docker ps -a | grep ${CONTAINER_NAME}"
    else
        ssh -p ${NAS_SSH_PORT} ${NAS_USER}@${NAS_HOST} "docker ps -a | grep ${CONTAINER_NAME}"
    fi
}

restart_container() {
    log_info "Restarting container..."
    SSH_KEY=$(get_ssh_key)
    if [ -n "$SSH_KEY" ]; then
        ssh -p ${NAS_SSH_PORT} -i ${SSH_KEY} ${NAS_USER}@${NAS_HOST} "docker restart ${CONTAINER_NAME}"
    else
        ssh -p ${NAS_SSH_PORT} ${NAS_USER}@${NAS_HOST} "docker restart ${CONTAINER_NAME}"
    fi
    log_success "Container restarted"
}

# ============================================================================
# Main
# ============================================================================

case "$1" in
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    restart)
        restart_container
        ;;
    *)
        echo "Usage: $0 {logs|status|restart}"
        exit 1
        ;;
esac

