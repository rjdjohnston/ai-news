#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Database Tools"
  echo ""
  echo "Usage: ./db-tools.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help              Show this help message"
  echo "  -b, --backup            Backup the database"
  echo "  -r, --restore FILE      Restore the database from FILE"
  echo "  -l, --list              List available backups"
  echo "  -c, --clean DAYS        Remove backups older than DAYS days"
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

# Backup database
function backup_database {
  echo "Backing up database..."
  check_env
  
  # Create backups directory if it doesn't exist
  if [ ! -d "backups" ]; then
    mkdir -p backups
    echo "Created backups directory."
  fi
  
  # Load environment variables
  source .env
  
  BACKUP_FILE="backups/backup_$(date +%Y-%m-%d_%H-%M-%S).sql"
  echo "Creating backup: $BACKUP_FILE"
  docker exec -t citywayne_postgres pg_dump -U $DATABASE_USERNAME $DATABASE_NAME > $BACKUP_FILE
  
  echo "Database backup created successfully!"
}

# Restore database
function restore_database {
  echo "Restoring database from $1..."
  check_env
  
  if [ ! -f "$1" ]; then
    echo "Error: Backup file not found: $1"
    exit 1
  fi
  
  # Load environment variables
  source .env
  
  echo "Warning: This will overwrite the current database!"
  read -p "Are you sure you want to continue? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
  fi
  
  echo "Restoring database..."
  cat "$1" | docker exec -i citywayne_postgres psql -U $DATABASE_USERNAME -d $DATABASE_NAME
  
  echo "Database restored successfully!"
}

# List available backups
function list_backups {
  echo "Available database backups:"
  echo ""
  
  if [ ! -d "backups" ] || [ -z "$(ls -A backups 2>/dev/null)" ]; then
    echo "No backups found."
    exit 0
  fi
  
  ls -lh backups | grep -v "^total" | awk '{print $9 " (" $5 ")"}'
}

# Clean old backups
function clean_backups {
  echo "Cleaning backups older than $1 days..."
  
  if [ ! -d "backups" ] || [ -z "$(ls -A backups 2>/dev/null)" ]; then
    echo "No backups found."
    exit 0
  fi
  
  find backups -name "backup_*.sql" -type f -mtime +$1 -delete
  
  echo "Old backups cleaned successfully!"
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
    -b|--backup)
      backup_database
      exit 0
      ;;
    -r|--restore)
      if [ -z "$2" ]; then
        echo "Error: No backup file specified!"
        show_help
        exit 1
      fi
      restore_database "$2"
      exit 0
      ;;
    -l|--list)
      list_backups
      exit 0
      ;;
    -c|--clean)
      if [ -z "$2" ]; then
        echo "Error: No days specified!"
        show_help
        exit 1
      fi
      clean_backups "$2"
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