#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Update Tools"
  echo ""
  echo "Usage: ./update.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -a, --all        Update all services"
  echo "  -s, --service    Update a specific service (postgres, backend, frontend, nginx)"
  echo "  -p, --pull       Pull latest images before updating"
  echo "  -b, --backup     Create a database backup before updating"
  echo ""
}

# Check if .env file exists
function check_env {
  if [ ! -f ../.env ]; then
    echo "Error: .env file not found!"
    echo "Please create a .env file in the root directory."
    exit 1
  fi
}

# Pull latest images
function pull_images {
  echo "Pulling latest images..."
  docker-compose pull
}

# Create database backup
function backup_database {
  echo "Creating database backup..."
  ./db-tools.sh -b
}

# Update all services
function update_all {
  echo "Updating all services..."
  docker-compose down
  if [ "$1" == "pull" ]; then
    pull_images
  fi
  docker-compose up -d
  echo "All services updated successfully!"
}

# Update a specific service
function update_service {
  echo "Updating $1 service..."
  docker-compose stop $1
  if [ "$2" == "pull" ]; then
    docker-compose pull $1
  fi
  docker-compose up -d $1
  echo "$1 service updated successfully!"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

# Check if .env file exists
check_env

PULL="no"
BACKUP="no"

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -p|--pull)
      PULL="pull"
      shift
      ;;
    -b|--backup)
      BACKUP="yes"
      shift
      ;;
    -a|--all)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      update_all $PULL
      exit 0
      ;;
    -s|--service)
      if [ -z "$2" ]; then
        echo "Error: No service specified!"
        show_help
        exit 1
      fi
      if [ "$2" == "postgres" ] && [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      update_service "$2" $PULL
      shift
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