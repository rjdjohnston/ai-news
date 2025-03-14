# CityWayne News Deployment

This directory contains all the necessary files to deploy the CityWayne News website using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your server
- Domain names configured (citywayne.com and api.citywayne.com)
- SSL certificates for your domains

## Setup Instructions

### Local Development Setup

For local development environments:

```bash
# Make the script executable
chmod +x setup.sh

# Run the complete setup
./setup.sh --all
```

When prompted for SSL options, select option `1` for self-signed certificates:
```
SSL certificate options:
1) Self-signed certificates (for local development)
2) Let's Encrypt staging certificates (for testing)
3) Let's Encrypt production certificates (for production)
```

### Memory Issues During Build

If you encounter memory issues during the build process (such as "JavaScript heap out of memory" or "SIGKILL" errors), you can use the specialized build scripts:

```bash
# Build only the backend with increased memory allocation
./setup.sh --build-backend

# Build only the frontend with increased memory allocation
./setup.sh --build-frontend

# Or use the Docker build script with memory limits
./docker-build.sh --backend  # Build only the backend container
./docker-build.sh --frontend # Build only the frontend container
./docker-build.sh --all      # Build all containers
```

These scripts allocate more memory to the Node.js processes and can help resolve memory-related build failures.

### Production Setup

For production deployment:

```bash
# Make the script executable
chmod +x setup.sh

# Run the complete setup
./setup.sh --all
```

When prompted for SSL options, select option `3` for Let's Encrypt production certificates:
```
SSL certificate options:
1) Self-signed certificates (for local development)
2) Let's Encrypt staging certificates (for testing)
3) Let's Encrypt production certificates (for production)
4) Skip SSL certificate generation
```

When asked about local directories:
```
Do you want to use local directories (no sudo required)? (y/n):
```
- If you're running as a non-root user without sudo access, answer `y`
- If you have sudo access and want to use the standard system directories, answer `n` (you may need to run the entire command with sudo in this case)

#### Production Setup Requirements

For production deployment, ensure:
1. Your domains (citywayne.com and api.citywayne.com) properly point to your server
2. Ports 80 and 443 are open for Let's Encrypt verification and HTTPS traffic
3. You have sufficient permissions to write to `/etc/letsencrypt/` or use the local directories option

#### Step-by-Step Production Setup

If you prefer to run each step separately:

1. Generate environment variables:
   ```bash
   ./setup.sh --env
   ```

2. Set up SSL certificates:
   ```bash
   ./setup.sh --ssl
   ```
   Then select option `3` for production certificates.

3. Build and start services:
   ```bash
   ./setup.sh --build
   ```

4. Create an admin user for Strapi:
   ```bash
   docker exec -it citywayne_backend npm run strapi admin:create-user
   ```

### Manual Setup

Alternatively, you can follow the manual setup steps below:

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/citywayne.git
cd citywayne/deployment
```

2. **Create environment file**

Copy the example environment file and update it with your secure values:

```bash
cp .env.example .env
nano .env
```

3. **SSL Certificates**

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

4. **Build and start the services**

```bash
docker-compose up -d
```

5. **Initialize Strapi (first time only)**

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

# Generate self-signed certificates (for local development)
./setup-ssl.sh --self-signed

# Use local directories (no sudo required)
./setup-ssl.sh --local --staging

# Generate staging certificates (for testing)
./setup-ssl.sh --staging

# Generate production certificates
./setup-ssl.sh --production
```

If you encounter permission errors with certbot, you have three options:

1. Run the script with sudo:
   ```bash
   sudo ./setup-ssl.sh --staging
   ```

2. Use the `--local` option to use local directories:
   ```bash
   ./setup-ssl.sh --local --staging
   ```

3. Use self-signed certificates for local development:
   ```bash
   ./setup-ssl.sh --self-signed
   ```

## Troubleshooting

- **Check container status**: `docker-compose ps`
- **Check container logs**: `docker-compose logs [service_name]`
- **Restart a service**: `docker-compose restart [service_name]`
- **Rebuild a service**: `docker-compose up -d --build [service_name]` 

### Common Issues

#### Docker Connection Refused

If you see errors like:
```
ConnectionRefusedError: [Errno 61] Connection refused
docker.errors.DockerException: Error while fetching server API version: ('Connection aborted.', ConnectionRefusedError(61, 'Connection refused'))
```

This means Docker isn't running. To fix this:

**On macOS:**
1. Start Docker Desktop from your Applications folder
2. Wait for Docker to fully start (the whale icon in the menu bar should stop animating)
3. Try running the command again

**On Linux:**
1. Start the Docker service:
   ```bash
   sudo systemctl start docker
   ```
2. Verify Docker is running:
   ```bash
   sudo systemctl status docker
   ```
3. Try running the command again

#### Permission Denied for SSL Certificates

If you encounter permission errors with certbot:
```
[Errno 13] Permission denied: '/var/log/letsencrypt'
```

Use one of these solutions:
1. Run with sudo: `sudo ./setup-ssl.sh --staging`
2. Use local directories: `./setup-ssl.sh --local --staging`
3. Use self-signed certificates: `./setup-ssl.sh --self-signed`

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