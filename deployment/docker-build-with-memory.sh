#!/bin/bash

# Exit on error
set -e

# Display help message
function show_help {
  echo "CityWayne News Docker Build Script with Memory Limits"
  echo ""
  echo "Usage: ./docker-build-with-memory.sh [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Show this help message"
  echo "  -b, --backend    Build only the backend container"
  echo "  -f, --frontend   Build only the frontend container"
  echo "  -a, --all        Build all containers (default)"
  echo "  -m, --memory     Memory limit in GB (default: 8)"
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

# Set default memory limit
MEMORY_LIMIT=8

# Parse command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      show_help
      exit 0
      ;;
    -b|--backend)
      BUILD_BACKEND=true
      shift
      ;;
    -f|--frontend)
      BUILD_FRONTEND=true
      shift
      ;;
    -a|--all)
      BUILD_BACKEND=true
      BUILD_FRONTEND=true
      shift
      ;;
    -m|--memory)
      MEMORY_LIMIT="$2"
      shift
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

# If no specific build option is provided, build all
if [[ -z $BUILD_BACKEND && -z $BUILD_FRONTEND ]]; then
  BUILD_BACKEND=true
  BUILD_FRONTEND=true
fi

# Check Docker
check_docker

# Build backend container
if [[ $BUILD_BACKEND == true ]]; then
  echo "Building backend container with ${MEMORY_LIMIT}GB memory limit..."
  
  # Set Docker memory limits
  export DOCKER_BUILDKIT=1
  
  # Build with memory limits
  docker build \
    --memory=${MEMORY_LIMIT}g \
    --memory-swap=${MEMORY_LIMIT}g \
    -t citywayne-backend \
    -f backend.Dockerfile \
    ..
  
  echo "Backend container built successfully!"
fi

# Build frontend container
if [[ $BUILD_FRONTEND == true ]]; then
  echo "Building frontend container with ${MEMORY_LIMIT}GB memory limit..."
  
  # Set Docker memory limits
  export DOCKER_BUILDKIT=1
  
  # Build with memory limits
  docker build \
    --memory=${MEMORY_LIMIT}g \
    --memory-swap=${MEMORY_LIMIT}g \
    -t citywayne-frontend \
    -f frontend.Dockerfile \
    ..
  
  echo "Frontend container built successfully!"
fi

echo "Build process completed!" 