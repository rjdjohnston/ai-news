#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Docker Build Script"
  echo ""
  echo "Usage: ./docker-build.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -b, --backend    Build only the backend container"
  echo "  -f, --frontend   Build only the frontend container"
  echo "  -a, --all        Build all containers (default)"
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

# Build backend container
function build_backend {
  echo "Building backend container with increased memory..."
  docker build -t citywayne-backend -f backend.Dockerfile --memory=8g --memory-swap=8g ..
  echo "Backend container built successfully!"
}

# Build frontend container
function build_frontend {
  echo "Building frontend container with increased memory..."
  docker build -t citywayne-frontend -f frontend.Dockerfile --memory=8g --memory-swap=8g ..
  echo "Frontend container built successfully!"
}

# Build all containers
function build_all {
  build_backend
  build_frontend
  echo "All containers built successfully!"
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  check_docker
  build_all
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -b|--backend)
      check_docker
      build_backend
      exit 0
      ;;
    -f|--frontend)
      check_docker
      build_frontend
      exit 0
      ;;
    -a|--all)
      check_docker
      build_all
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