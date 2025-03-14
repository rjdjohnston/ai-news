#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News SSL Setup Script"
  echo ""
  echo "This script helps set up SSL certificates using Let's Encrypt certbot or self-signed certificates."
  echo ""
  echo "Usage: ./setup-ssl.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -s, --staging    Use Let's Encrypt staging environment (for testing)"
  echo "  -p, --production Use Let's Encrypt production environment"
  echo "  -l, --local      Use local directories (no sudo required)"
  echo "  -ss, --self-signed Generate self-signed certificates (for local development)"
  echo ""
  echo "Note: For Let's Encrypt certificates, certbot must be installed on your system."
  echo "      You can install it using: brew install certbot (macOS) or sudo apt-get install certbot (Linux)"
  echo ""
  echo "If you encounter permission errors, you can either:"
  echo "  1. Run this script with sudo: sudo ./setup-ssl.sh [options]"
  echo "  2. Use the --local option to use local directories: ./setup-ssl.sh --local [options]"
  echo "  3. Use the --self-signed option for local development: ./setup-ssl.sh --self-signed"
  echo ""
}

# Check if certbot is installed
function check_certbot {
  if ! command -v certbot &> /dev/null; then
    echo "Error: certbot is not installed!"
    echo "Please install certbot using your package manager."
    echo "For macOS: brew install certbot"
    echo "For Linux: sudo apt-get install certbot"
    exit 1
  fi
}

# Check if openssl is installed
function check_openssl {
  if ! command -v openssl &> /dev/null; then
    echo "Error: openssl is not installed!"
    echo "Please install openssl using your package manager."
    echo "For macOS: brew install openssl"
    echo "For Linux: sudo apt-get install openssl"
    exit 1
  fi
}

# Create SSL directory if it doesn't exist
function create_ssl_dir {
  if [ ! -d "ssl" ]; then
    mkdir -p ssl
    echo "Created ssl directory."
  fi
}

# Create local directories for certbot
function create_local_dirs {
  mkdir -p ./certbot/config
  mkdir -p ./certbot/work
  mkdir -p ./certbot/logs
  echo "Created local directories for certbot."
}

# Generate self-signed certificates
function generate_self_signed_certs {
  echo "Generating self-signed certificates for local development..."
  
  # Create SSL directory
  create_ssl_dir
  
  # Generate certificate for main domain
  echo "Generating self-signed certificate for citywayne.com and www.citywayne.com..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/citywayne.com.key -out ssl/citywayne.com.crt \
    -subj "/C=US/ST=State/L=City/O=CityWayne News/OU=Development/CN=citywayne.com"
  
  # Generate certificate for API domain
  echo "Generating self-signed certificate for api.citywayne.com..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/api.citywayne.com.key -out ssl/api.citywayne.com.crt \
    -subj "/C=US/ST=State/L=City/O=CityWayne News/OU=Development/CN=api.citywayne.com"
  
  echo "Self-signed certificates generated and saved to ssl directory."
}

# Generate certificates using Let's Encrypt staging environment
function generate_staging_certs {
  echo "Generating certificates using Let's Encrypt staging environment..."
  
  local CERTBOT_ARGS="--standalone --test-cert --agree-tos --no-eff-email -m admin@citywayne.com"
  
  if [ "$USE_LOCAL_DIRS" = "yes" ]; then
    create_local_dirs
    CERTBOT_ARGS="$CERTBOT_ARGS --config-dir ./certbot/config --work-dir ./certbot/work --logs-dir ./certbot/logs"
    CERT_PATH="./certbot/config/live"
  else
    CERT_PATH="/etc/letsencrypt/live"
  fi
  
  # Generate certificate for main domain
  echo "Generating certificate for citywayne.com and www.citywayne.com..."
  certbot certonly $CERTBOT_ARGS -d citywayne.com -d www.citywayne.com
  
  # Generate certificate for API domain
  echo "Generating certificate for api.citywayne.com..."
  certbot certonly $CERTBOT_ARGS -d api.citywayne.com
  
  # Copy certificates to ssl directory
  create_ssl_dir
  echo "Copying certificates to ssl directory..."
  cp "$CERT_PATH/citywayne.com/fullchain.pem" ssl/citywayne.com.crt
  cp "$CERT_PATH/citywayne.com/privkey.pem" ssl/citywayne.com.key
  cp "$CERT_PATH/api.citywayne.com/fullchain.pem" ssl/api.citywayne.com.crt
  cp "$CERT_PATH/api.citywayne.com/privkey.pem" ssl/api.citywayne.com.key
  
  echo "Certificates generated and copied to ssl directory."
}

# Generate certificates using Let's Encrypt production environment
function generate_production_certs {
  echo "Generating certificates using Let's Encrypt production environment..."
  
  local CERTBOT_ARGS="--standalone --agree-tos --no-eff-email -m admin@citywayne.com"
  
  if [ "$USE_LOCAL_DIRS" = "yes" ]; then
    create_local_dirs
    CERTBOT_ARGS="$CERTBOT_ARGS --config-dir ./certbot/config --work-dir ./certbot/work --logs-dir ./certbot/logs"
    CERT_PATH="./certbot/config/live"
  else
    CERT_PATH="/etc/letsencrypt/live"
  fi
  
  # Generate certificate for main domain
  echo "Generating certificate for citywayne.com and www.citywayne.com..."
  certbot certonly $CERTBOT_ARGS -d citywayne.com -d www.citywayne.com
  
  # Generate certificate for API domain
  echo "Generating certificate for api.citywayne.com..."
  certbot certonly $CERTBOT_ARGS -d api.citywayne.com
  
  # Copy certificates to ssl directory
  create_ssl_dir
  echo "Copying certificates to ssl directory..."
  cp "$CERT_PATH/citywayne.com/fullchain.pem" ssl/citywayne.com.crt
  cp "$CERT_PATH/citywayne.com/privkey.pem" ssl/citywayne.com.key
  cp "$CERT_PATH/api.citywayne.com/fullchain.pem" ssl/api.citywayne.com.crt
  cp "$CERT_PATH/api.citywayne.com/privkey.pem" ssl/api.citywayne.com.key
  
  echo "Certificates generated and copied to ssl directory."
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

USE_LOCAL_DIRS="no"
MODE=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -l|--local)
      USE_LOCAL_DIRS="yes"
      shift
      ;;
    -s|--staging)
      MODE="staging"
      shift
      ;;
    -p|--production)
      MODE="production"
      shift
      ;;
    -ss|--self-signed)
      MODE="self-signed"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Generate certificates based on mode
if [ "$MODE" = "staging" ]; then
  check_certbot
  generate_staging_certs
elif [ "$MODE" = "production" ]; then
  check_certbot
  generate_production_certs
elif [ "$MODE" = "self-signed" ]; then
  check_openssl
  generate_self_signed_certs
else
  show_help
  exit 1
fi 