#!/bin/bash

# Exit on error
set -e

# Function to generate a random string
function generate_random_string {
  openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

# Function to generate multiple random strings separated by commas
function generate_app_keys {
  echo "$(generate_random_string),$(generate_random_string),$(generate_random_string),$(generate_random_string)"
}

# Check if .env file already exists
if [ -f .env ]; then
  echo "Warning: .env file already exists!"
  read -p "Do you want to overwrite it? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
  fi
fi

# Create .env file with secure random values
cat > .env << EOF
# Database Configuration
DATABASE_NAME=citywayne
DATABASE_USERNAME=citywayne_user
DATABASE_PASSWORD=$(generate_random_string)

# Strapi Security Keys
ADMIN_JWT_SECRET=$(generate_random_string)
API_TOKEN_SALT=$(generate_random_string)
APP_KEYS=$(generate_app_keys)
JWT_SECRET=$(generate_random_string)

# Frontend Configuration
NEXT_PUBLIC_API_URL=https://api.citywayne.com
NEXT_PUBLIC_SITE_URL=https://citywayne.com
NEXT_PUBLIC_SITE_NAME=CityWayne News
EOF

echo ".env file generated successfully with secure random values!"
echo "Please review the file and update any values as needed." 