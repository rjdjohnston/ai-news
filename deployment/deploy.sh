#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Deployment Script"
  echo ""
  echo "Usage: ./deploy.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -i, --init       Initialize deployment (first time setup)"
  echo "  -u, --update     Update existing deployment"
  echo "  -b, --backup     Backup the database"
  echo "  -r, --restart    Restart all services"
  echo ""
}

# Check if .env file exists
function check_env {
  if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please create an .env file by copying .env.example and updating the values."
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
  fi
}

# Check if SSL certificates exist
function check_ssl {
  if [ ! -d "ssl" ] || [ ! -f "ssl/citywayne.com.crt" ] || [ ! -f "ssl/citywayne.com.key" ] || [ ! -f "ssl/api.citywayne.com.crt" ] || [ ! -f "ssl/api.citywayne.com.key" ]; then
    echo "Error: SSL certificates not found!"
    echo "Please place your SSL certificates in the ssl directory:"
    echo "  mkdir -p ssl"
    echo "  # Copy your certificates to the ssl directory"
    echo "  # For citywayne.com"
    echo "  cp /path/to/your/certificate.crt ssl/citywayne.com.crt"
    echo "  cp /path/to/your/private.key ssl/citywayne.com.key"
    echo "  # For api.citywayne.com"
    echo "  cp /path/to/your/api-certificate.crt ssl/api.citywayne.com.crt"
    echo "  cp /path/to/your/api-private.key ssl/api.citywayne.com.key"
    exit 1
  fi
}

# Initialize deployment
function init_deployment {
  echo "Initializing deployment..."
  check_env
  check_ssl
  
  echo "Building and starting containers..."
  docker-compose up -d
  
  echo "Waiting for services to start..."
  sleep 10
  
  echo "Creating Strapi admin user..."
  docker exec -it citywayne_backend npm run strapi admin:create-user
  
  echo "Deployment initialized successfully!"
}

# Update deployment
function update_deployment {
  echo "Updating deployment..."
  check_env
  check_ssl
  
  echo "Pulling latest changes..."
  cd ..
  git pull
  cd deployment
  
  echo "Rebuilding and restarting containers..."
  docker-compose down
  docker-compose up -d --build
  
  echo "Deployment updated successfully!"
}

# Backup database
function backup_database {
  echo "Backing up database..."
  check_env
  
  # Load environment variables
  source .env
  
  BACKUP_FILE="backup_$(date +%Y-%m-%d_%H-%M-%S).sql"
  echo "Creating backup: $BACKUP_FILE"
  docker exec -t citywayne_postgres pg_dump -U $DATABASE_USERNAME $DATABASE_NAME > $BACKUP_FILE
  
  echo "Database backup created successfully!"
}

# Restart services
function restart_services {
  echo "Restarting services..."
  check_env
  
  docker-compose restart
  
  echo "Services restarted successfully!"
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
    -i|--init)
      init_deployment
      exit 0
      ;;
    -u|--update)
      update_deployment
      exit 0
      ;;
    -b|--backup)
      backup_database
      exit 0
      ;;
    -r|--restart)
      restart_services
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