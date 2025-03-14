#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Cleanup Script"
  echo ""
  echo "Usage: ./cleanup.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -s, --stop       Stop all services"
  echo "  -c, --clean      Remove containers and networks"
  echo "  -v, --volumes    Remove volumes (WARNING: This will delete all data!)"
  echo "  -i, --images     Remove Docker images"
  echo "  -a, --all        Complete cleanup (stop, clean, volumes, images)"
  echo "  -b, --backup     Create a database backup before cleanup"
  echo ""
  echo "WARNING: The --volumes and --all options will delete all data!"
  echo "Make sure to create a backup before proceeding."
  echo ""
}

# Check if user wants to proceed with data deletion
function confirm_data_deletion {
  read -p "WARNING: This will delete all data! Are you sure you want to proceed? (y/n): " confirm
  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
  fi
}

# Create database backup
function backup_database {
  echo "Creating database backup..."
  ./db-tools.sh -b
  echo "Database backup created successfully!"
}

# Stop all services
function stop_services {
  echo "Stopping all services..."
  docker-compose stop
  echo "All services stopped successfully!"
}

# Remove containers and networks
function clean_containers {
  echo "Removing containers and networks..."
  docker-compose down
  echo "Containers and networks removed successfully!"
}

# Remove volumes
function clean_volumes {
  confirm_data_deletion
  echo "Removing volumes..."
  docker-compose down -v
  echo "Volumes removed successfully!"
}

# Remove Docker images
function clean_images {
  echo "Removing Docker images..."
  docker-compose down --rmi all
  echo "Docker images removed successfully!"
}

# Complete cleanup
function complete_cleanup {
  confirm_data_deletion
  echo "Performing complete cleanup..."
  docker-compose down -v --rmi all
  echo "Complete cleanup performed successfully!"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

BACKUP="no"

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -b|--backup)
      BACKUP="yes"
      shift
      ;;
    -s|--stop)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      stop_services
      exit 0
      ;;
    -c|--clean)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      clean_containers
      exit 0
      ;;
    -v|--volumes)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      clean_volumes
      exit 0
      ;;
    -i|--images)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      clean_images
      exit 0
      ;;
    -a|--all)
      if [ "$BACKUP" == "yes" ]; then
        backup_database
      fi
      complete_cleanup
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