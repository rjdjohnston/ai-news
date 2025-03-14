#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News SSL Setup Script"
  echo ""
  echo "This script helps set up SSL certificates using Let's Encrypt certbot."
  echo ""
  echo "Usage: ./setup-ssl.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -s, --staging    Use Let's Encrypt staging environment (for testing)"
  echo "  -p, --production Use Let's Encrypt production environment"
  echo ""
  echo "Note: This script requires certbot to be installed on your system."
  echo "      You can install it using: sudo apt-get install certbot"
  echo ""
}

# Check if certbot is installed
function check_certbot {
  if ! command -v certbot &> /dev/null; then
    echo "Error: certbot is not installed!"
    echo "Please install certbot using your package manager."
    echo "For example: sudo apt-get install certbot"
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

# Generate certificates using Let's Encrypt staging environment
function generate_staging_certs {
  echo "Generating certificates using Let's Encrypt staging environment..."
  
  # Generate certificate for main domain
  certbot certonly --standalone --test-cert \
    --agree-tos --no-eff-email \
    -m admin@citywayne.com \
    -d citywayne.com -d www.citywayne.com
  
  # Generate certificate for API domain
  certbot certonly --standalone --test-cert \
    --agree-tos --no-eff-email \
    -m admin@citywayne.com \
    -d api.citywayne.com
  
  # Copy certificates to ssl directory
  create_ssl_dir
  cp /etc/letsencrypt/live/citywayne.com/fullchain.pem ssl/citywayne.com.crt
  cp /etc/letsencrypt/live/citywayne.com/privkey.pem ssl/citywayne.com.key
  cp /etc/letsencrypt/live/api.citywayne.com/fullchain.pem ssl/api.citywayne.com.crt
  cp /etc/letsencrypt/live/api.citywayne.com/privkey.pem ssl/api.citywayne.com.key
  
  echo "Certificates generated and copied to ssl directory."
}

# Generate certificates using Let's Encrypt production environment
function generate_production_certs {
  echo "Generating certificates using Let's Encrypt production environment..."
  
  # Generate certificate for main domain
  certbot certonly --standalone \
    --agree-tos --no-eff-email \
    -m admin@citywayne.com \
    -d citywayne.com -d www.citywayne.com
  
  # Generate certificate for API domain
  certbot certonly --standalone \
    --agree-tos --no-eff-email \
    -m admin@citywayne.com \
    -d api.citywayne.com
  
  # Copy certificates to ssl directory
  create_ssl_dir
  cp /etc/letsencrypt/live/citywayne.com/fullchain.pem ssl/citywayne.com.crt
  cp /etc/letsencrypt/live/citywayne.com/privkey.pem ssl/citywayne.com.key
  cp /etc/letsencrypt/live/api.citywayne.com/fullchain.pem ssl/api.citywayne.com.crt
  cp /etc/letsencrypt/live/api.citywayne.com/privkey.pem ssl/api.citywayne.com.key
  
  echo "Certificates generated and copied to ssl directory."
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -s|--staging)
      check_certbot
      generate_staging_certs
      exit 0
      ;;
    -p|--production)
      check_certbot
      generate_production_certs
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
  shift
done 