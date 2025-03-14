# CityWayne News Website

A local news website with admin capabilities, RSS feed, and a modern design inspired by NBC News.

## Project Structure

- **frontend**: Next.js application for the public-facing website
- **backend**: Strapi headless CMS for content management

## Features

- Modern, responsive design
- Admin interface for content management
- RSS feed for content syndication
- Article categories and tags
- Featured articles and breaking news
- Search functionality
- User comments (optional)

## Tech Stack

- **Frontend**: Next.js, TypeScript, Tailwind CSS
- **Backend**: Strapi Headless CMS
- **Database**: SQLite (development), PostgreSQL (production recommended)

## Getting Started

### Backend Setup

```bash
cd backend
npm run develop
```

This will start the Strapi admin at http://localhost:1337/admin

### Frontend Setup

```bash
cd frontend
npm run dev
```

This will start the Next.js development server at http://localhost:3000

## Content Types

The Strapi backend includes the following content types:

- Articles
- Categories
- Tags
- Authors
- Media
- Pages

## Deployment

For production deployment:

1. Set up a PostgreSQL database
2. Configure environment variables
3. Build and deploy both frontend and backend

## License

MIT 