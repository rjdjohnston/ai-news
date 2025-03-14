#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Setup Script"
  echo ""
  echo "Usage: ./setup.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -e, --env        Generate environment variables"
  echo "  -s, --ssl        Setup SSL certificates"
  echo "  -b, --build      Build and start all services"
  echo "  -a, --all        Complete setup (env, ssl, build)"
  echo ""
}

# Generate environment variables
function generate_env {
  echo "Generating environment variables..."
  ./generate-env.sh
  echo "Environment variables generated successfully!"
}

# Setup SSL certificates
function setup_ssl {
  echo "Setting up SSL certificates..."
  
  read -p "Do you want to generate staging certificates? (y/n): " staging
  if [[ $staging =~ ^[Yy]$ ]]; then
    ./setup-ssl.sh --staging
  else
    read -p "Do you want to generate production certificates? (y/n): " production
    if [[ $production =~ ^[Yy]$ ]]; then
      ./setup-ssl.sh --production
    else
      echo "Skipping SSL certificate generation."
    fi
  fi
}

# Build and start all services
function build_services {
  echo "Building and starting all services..."
  docker-compose up -d --build
  echo "All services built and started successfully!"
}

# Complete setup
function complete_setup {
  generate_env
  setup_ssl
  build_services
  
  echo ""
  echo "Setup completed successfully!"
  echo "You can now access your website at https://citywayne.com"
  echo "Admin panel is available at https://api.citywayne.com/admin"
  echo ""
  echo "Don't forget to create an admin user for Strapi:"
  echo "docker exec -it citywayne_backend npm run strapi admin:create-user"
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
    -e|--env)
      generate_env
      exit 0
      ;;
    -s|--ssl)
      setup_ssl
      exit 0
      ;;
    -b|--build)
      build_services
      exit 0
      ;;
    -a|--all)
      complete_setup
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