FROM node:18-alpine as base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY backend/package.json backend/package-lock.json* ./
RUN npm install

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY backend .

# Set environment variables
ENV NODE_ENV=production
ENV DATABASE_CLIENT=postgres
ENV DATABASE_HOST=postgres
ENV DATABASE_PORT=5432
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}
ENV API_TOKEN_SALT=${API_TOKEN_SALT}
ENV APP_KEYS=${APP_KEYS}
ENV JWT_SECRET=${JWT_SECRET}
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Build the Strapi application with increased memory allocation
RUN NODE_OPTIONS="--max-old-space-size=8192" npm run build 

# Production image, copy all the files and run the app
FROM base AS runner
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV DATABASE_CLIENT=postgres
ENV DATABASE_HOST=postgres
ENV DATABASE_PORT=5432
ENV DATABASE_NAME=${DATABASE_NAME}
ENV DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD}
ENV ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}
ENV API_TOKEN_SALT=${API_TOKEN_SALT}
ENV APP_KEYS=${APP_KEYS}
ENV JWT_SECRET=${JWT_SECRET}
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Create a non-root user
RUN addgroup --system --gid 1001 strapi && \
    adduser --system --uid 1001 --ingroup strapi strapi

# Copy built files from builder stage
COPY --from=builder --chown=strapi:strapi /app/node_modules ./node_modules
COPY --from=builder --chown=strapi:strapi /app/package.json ./package.json
COPY --from=builder --chown=strapi:strapi /app/dist ./dist
COPY --from=builder --chown=strapi:strapi /app/public ./public
COPY --from=builder --chown=strapi:strapi /app/src ./src
COPY --from=builder --chown=strapi:strapi /app/config ./config
COPY --from=builder --chown=strapi:strapi /app/.env ./.env

# Create uploads directory and set permissions
RUN mkdir -p /app/public/uploads && \
    chown -R strapi:strapi /app/public/uploads

# Switch to non-root user
USER strapi

# Expose the port Strapi runs on
EXPOSE 1337

# Start the Strapi application
CMD ["npm", "run", "start"] 