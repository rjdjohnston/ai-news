#!/bin/bash

# Exit on error
set -e

echo "Building backend with increased memory allocation..."

# Set environment variables
export NODE_OPTIONS="--max-old-space-size=8192"

# Navigate to the backend directory
cd ../backend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Build the Strapi application
echo "Building Strapi application..."
npm run build

echo "Backend build completed successfully!" 