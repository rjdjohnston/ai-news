#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Monitoring Tools"
  echo ""
  echo "Usage: ./monitor.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -a, --all        Show status of all services"
  echo "  -l, --logs       Show logs of all services"
  echo "  -s, --service    Show status of a specific service (postgres, backend, frontend, nginx)"
  echo "  -ls, --logs-service Show logs of a specific service (postgres, backend, frontend, nginx)"
  echo "  -f, --follow     Follow logs (use with -l or -ls)"
  echo ""
}

# Show status of all services
function show_all_status {
  echo "Status of all services:"
  echo ""
  docker-compose ps
}

# Show logs of all services
function show_all_logs {
  if [ "$1" == "follow" ]; then
    docker-compose logs -f
  else
    docker-compose logs
  fi
}

# Show status of a specific service
function show_service_status {
  echo "Status of $1 service:"
  echo ""
  docker-compose ps $1
}

# Show logs of a specific service
function show_service_logs {
  if [ "$2" == "follow" ]; then
    docker-compose logs -f $1
  else
    docker-compose logs $1
  fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

FOLLOW="no"

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -f|--follow)
      FOLLOW="follow"
      shift
      ;;
    -a|--all)
      show_all_status
      exit 0
      ;;
    -l|--logs)
      show_all_logs $FOLLOW
      exit 0
      ;;
    -s|--service)
      if [ -z "$2" ]; then
        echo "Error: No service specified!"
        show_help
        exit 1
      fi
      show_service_status "$2"
      shift
      exit 0
      ;;
    -ls|--logs-service)
      if [ -z "$2" ]; then
        echo "Error: No service specified!"
        show_help
        exit 1
      fi
      show_service_logs "$2" $FOLLOW
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