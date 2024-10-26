#!/bin/bash

ACTION=$1
DNS_NAME=$2
VALIDATION=$3

case "$ACTION" in
  "present")
    echo "Creating DNS TXT record for validation."
    # Command to add the TXT record, replace with your DNS provider's specific command
    #DNS name without _acme-challenge
    export CERTBOT_VALIDATION="$VALIDATION"
    export CERTBOT_DOMAIN=$(echo $DNS_NAME | sed 's/^_acme-challenge\.//; s/\.$//')
    echo "CERTBOT_DOMAIN: $CERTBOT_DOMAIN"
    python3 ./auth-hook.py
    ;;

  "cleanup")
    echo "Cleaning up DNS TXT record after validation."
    # Command to remove the TXT record
    export CERTBOT_VALIDATION="$VALIDATION"
    export CERTBOT_DOMAIN="lk01.de"
    python3 ./cleanup-hook.py
    ;;

  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
