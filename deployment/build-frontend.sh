#!/bin/bash

# Exit on error
set -e

echo "Building frontend with increased memory allocation..."

# Set environment variables
export NODE_OPTIONS="--max-old-space-size=8192"

# Navigate to the frontend directory (assuming it's at the root level)
cd ..

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Build the Next.js application
echo "Building Next.js application..."
npm run build

echo "Frontend build completed successfully!" 