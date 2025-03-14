# CityWayne News Deployment

This directory contains all the necessary files to deploy the CityWayne News website using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your server
- Domain names configured (citywayne.com and api.citywayne.com)
- SSL certificates for your domains

## Setup Instructions

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/citywayne.git
cd citywayne/deployment
```

2. **Run the setup script**

The easiest way to set up everything is to use the setup script:

```bash
# Make the script executable
chmod +x setup.sh

# Show help
./setup.sh --help

# Complete setup (environment variables, SSL certificates, build services)
./setup.sh --all

# Or run individual steps:
./setup.sh --env    # Generate environment variables
./setup.sh --ssl    # Setup SSL certificates
./setup.sh --build  # Build and start services
```

Alternatively, you can follow the manual setup steps below:

3. **Create environment file**

Copy the example environment file and update it with your secure values:

```bash
cp .env.example .env
nano .env
```

4. **SSL Certificates**

Place your SSL certificates in the `ssl` directory:

```bash
mkdir -p ssl
# Copy your certificates to the ssl directory
# For citywayne.com
cp /path/to/your/certificate.crt ssl/citywayne.com.crt
cp /path/to/your/private.key ssl/citywayne.com.key
# For api.citywayne.com
cp /path/to/your/api-certificate.crt ssl/api.citywayne.com.crt
cp /path/to/your/api-private.key ssl/api.citywayne.com.key
```

5. **Build and start the services**

```bash
docker-compose up -d
```

6. **Initialize Strapi (first time only)**

After the containers are running, you need to create an admin user for Strapi:

```bash
docker exec -it citywayne_backend npm run strapi admin:create-user
```

## Services

- **PostgreSQL**: Database for Strapi
- **Strapi Backend**: API and content management system
- **Next.js Frontend**: User-facing website
- **Nginx**: Web server and reverse proxy

## Maintenance

### Viewing logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs frontend
docker-compose logs nginx
```

### Monitoring Services

Use the monitoring script to check the status and logs of your services:

```bash
# Show help
./monitor.sh --help

# Show status of all services
./monitor.sh --all

# Show logs of all services
./monitor.sh --logs

# Follow logs of all services
./monitor.sh --logs --follow

# Show status of a specific service
./monitor.sh --service nginx

# Show logs of a specific service
./monitor.sh --logs-service backend

# Follow logs of a specific service
./monitor.sh --logs-service frontend --follow
```

### Updating the application

Use the update script to update your services:

```bash
# Show help
./update.sh --help

# Update all services
./update.sh --all

# Update all services and pull latest images
./update.sh --all --pull

# Update all services with database backup
./update.sh --all --backup

# Update a specific service
./update.sh --service frontend

# Update a specific service and pull latest image
./update.sh --service backend --pull
```

You can also update manually:

```bash
# Pull latest changes
git pull

# Rebuild and restart containers
docker-compose down
docker-compose up -d --build
```

### Database Management

Use the database tools script for database operations:

```bash
# Show help
./db-tools.sh --help

# Create a backup
./db-tools.sh --backup

# Restore from a backup
./db-tools.sh --restore backup_2023-05-15_12-30-00.sql

# List available backups
./db-tools.sh --list

# Clean up old backups (older than 30 days)
./db-tools.sh --clean 30
```

Manual database operations:

```bash
docker exec -t citywayne_postgres pg_dump -U ${DATABASE_USERNAME} ${DATABASE_NAME} > backup_$(date +%Y-%m-%d_%H-%M-%S).sql
```

### Restore database

```bash
cat backup_file.sql | docker exec -i citywayne_postgres psql -U ${DATABASE_USERNAME} -d ${DATABASE_NAME}
```

### SSL Certificate Management

Use the SSL setup script to generate and manage SSL certificates:

```bash
# Show help
./setup-ssl.sh --help

# Generate staging certificates (for testing)
./setup-ssl.sh --staging

# Generate production certificates
./setup-ssl.sh --production
```

## Troubleshooting

- **Check container status**: `docker-compose ps`
- **Check container logs**: `docker-compose logs [service_name]`
- **Restart a service**: `docker-compose restart [service_name]`
- **Rebuild a service**: `docker-compose up -d --build [service_name]` 

## Cleanup and Uninstallation

Use the cleanup script to stop services, remove containers, volumes, and images:

```bash
# Show help
./cleanup.sh --help

# Stop all services
./cleanup.sh --stop

# Remove containers and networks
./cleanup.sh --clean

# Create a backup before cleanup
./cleanup.sh --backup --clean

# Remove volumes (WARNING: This will delete all data!)
./cleanup.sh --volumes

# Remove Docker images
./cleanup.sh --images

# Complete cleanup (stop, clean, volumes, images)
./cleanup.sh --all
```

## License

MIT 