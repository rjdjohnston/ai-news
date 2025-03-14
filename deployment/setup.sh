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
  echo "  --build-backend  Build only the backend with increased memory"
  echo "  --build-frontend Build only the frontend with increased memory"
  echo ""
}

# Check if Docker is running
function check_docker {
  echo "Checking if Docker is running..."
  if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running!"
    echo ""
    echo "Please start Docker and try again:"
    echo "- On macOS: Start Docker Desktop from your Applications folder"
    echo "- On Linux: Run 'sudo systemctl start docker'"
    echo ""
    exit 1
  fi
  echo "Docker is running."
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
  
  echo "SSL certificate options:"
  echo "1) Self-signed certificates (for local development)"
  echo "2) Let's Encrypt staging certificates (for testing)"
  echo "3) Let's Encrypt production certificates (for production)"
  echo "4) Skip SSL certificate generation"
  
  read -p "Select an option (1-4): " ssl_option
  
  case $ssl_option in
    1)
      echo "Generating self-signed certificates..."
      ./setup-ssl.sh --self-signed
      ;;
    2)
      echo "Generating Let's Encrypt staging certificates..."
      read -p "Do you want to use local directories (no sudo required)? (y/n): " local_dirs
      if [[ $local_dirs =~ ^[Yy]$ ]]; then
        ./setup-ssl.sh --local --staging
      else
        ./setup-ssl.sh --staging
      fi
      ;;
    3)
      echo "Generating Let's Encrypt production certificates..."
      read -p "Do you want to use local directories (no sudo required)? (y/n): " local_dirs
      if [[ $local_dirs =~ ^[Yy]$ ]]; then
        ./setup-ssl.sh --local --production
      else
        ./setup-ssl.sh --production
      fi
      ;;
    4)
      echo "Skipping SSL certificate generation."
      ;;
    *)
      echo "Invalid option. Skipping SSL certificate generation."
      ;;
  esac
}

# Build and start all services
function build_services {
  echo "Building and starting all services..."
  check_docker
  docker-compose up -d --build
  echo "All services built and started successfully!"
}

# Build backend with increased memory
function build_backend {
  echo "Building backend with increased memory..."
  ./build-backend.sh
  echo "Backend built successfully!"
}

# Build frontend with increased memory
function build_frontend {
  echo "Building frontend with increased memory..."
  ./build-frontend.sh
  echo "Frontend built successfully!"
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
    --build-backend)
      build_backend
      exit 0
      ;;
    --build-frontend)
      build_frontend
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