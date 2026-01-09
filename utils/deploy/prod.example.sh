#!/bin/bash
set -e

# ============================================================================
# Production Deployment Script for 3D Printer Stream
# ============================================================================
# This script builds a Docker image locally, transfers it to the NAS,
# and deploys it using docker-compose.
# ============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - UPDATE THESE VALUES
NAS_USER="your_nas_username"
NAS_HOST="nas.yourdomain.com"
NAS_SSH_PORT="22"
NAS_DEPLOY_PATH="/volume1/web/3d-printer-stream"
CONTAINER_NAME="3d-printer-stream"
IMAGE_NAME="3d-printer-stream:latest"
HOST_PORT="6198"

# SSH configuration
SSH_KEY_PATH=""
USE_SSH_AGENT=false

# Timing variables
START_TIME=$(date +%s)
BUILD_START=0
BUILD_END=0
TRANSFER_START=0
TRANSFER_END=0

# ============================================================================
# Helper Functions - Logging
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

# ============================================================================
# SSH Key Detection
# ============================================================================

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
# Main Deployment Function
# ============================================================================

main() {
    # Display deployment banner
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║           3D Printer Stream - Production Deployment           ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    # Display configuration
    log_info "Deployment Configuration:"
    echo "  NAS Host:      ${NAS_HOST}:${NAS_SSH_PORT}"
    echo "  Deploy Path:   ${NAS_DEPLOY_PATH}"
    echo "  Container:     ${CONTAINER_NAME}"
    echo "  Image:         ${IMAGE_NAME}"
    echo "  Port:          ${HOST_PORT}"
    echo ""

    # Build Docker image
    log_info "Building Docker image..."
    BUILD_START=$(date +%s)
    docker build --platform linux/amd64 -t ${IMAGE_NAME} .
    BUILD_END=$(date +%s)
    log_success "Docker image built successfully"

    # Save and compress image
    log_info "Saving and compressing Docker image..."
    docker save ${IMAGE_NAME} | gzip > /tmp/${IMAGE_NAME//:/\_}.tar.gz
    log_success "Image saved to /tmp/${IMAGE_NAME//:/\_}.tar.gz"

    # Transfer to NAS
    log_info "Transferring image to NAS..."
    TRANSFER_START=$(date +%s)
    
    SSH_KEY=$(get_ssh_key)
    if [ -n "$SSH_KEY" ]; then
        scp -P ${NAS_SSH_PORT} -i ${SSH_KEY} /tmp/${IMAGE_NAME//:/\_}.tar.gz ${NAS_USER}@${NAS_HOST}:/tmp/
    else
        scp -P ${NAS_SSH_PORT} /tmp/${IMAGE_NAME//:/\_}.tar.gz ${NAS_USER}@${NAS_HOST}:/tmp/
    fi
    
    TRANSFER_END=$(date +%s)
    log_success "Image transferred to NAS"

    # Deploy on NAS
    log_info "Deploying on NAS..."
    # ... rest of deployment logic ...
    
    log_success "Deployment complete!"
}

# Run main function
main

