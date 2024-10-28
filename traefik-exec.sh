#!/bin/ash

# Get the action and DNS parameters
ACTION=$1
DNS_NAME=$2
VALIDATION=$3

# Logging function for easier maintenance and readability
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> /proc/1/fd/1
}

log "Running strato-exec"

# Update package index and install necessary packages
apk update && apk add --no-cache python3 py3-pip >> /proc/1/fd/1

# Create and activate the virtual environment
VENV_DIR="/traefik-strato/venv"
python3 -m venv "$VENV_DIR"
# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"

# Install required Python packages
pip install --no-cache-dir pyotp requests beautifulsoup4 >> /proc/1/fd/1

cd /traefik-strato/strato-certbot || { log "Failed to change directory to /strato"; exit 1; }

case "$ACTION" in
  "present")
    log "Creating DNS TXT record for validation."
    export CERTBOT_VALIDATION="$VALIDATION"
    export CERTBOT_DOMAIN=$(echo "$DNS_NAME" | sed 's/^_acme-challenge\.//; s/\.$//')

    log "CERTBOT_DOMAIN: $CERTBOT_DOMAIN"
    
    # Assuming auth-hook.py is implemented to handle creating the TXT record
    python3 ./auth-hook.py
    if [ $? -ne 0 ]; then
      log "Failed to create DNS TXT record"
      exit 1
    fi
    ;;

  "cleanup")
    log "Cleaning up DNS TXT record after validation."
    export CERTBOT_VALIDATION="$VALIDATION"
    export CERTBOT_DOMAIN=$(echo "$DNS_NAME" | sed 's/^_acme-challenge\.//; s/\.$//')

    # Assuming cleanup-hook.py is implemented to handle removing the TXT record
    python3 ./cleanup-hook.py
    if [ $? -ne 0 ]; then
      log "Failed to remove DNS TXT record"
      exit 1
    fi
    ;;

  *)
    log "Unknown action: $ACTION"
    exit 1
    ;;
esac

# Deactivate the virtual environment
deactivate
