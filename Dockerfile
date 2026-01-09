# Multi-stage build for 3D Printer Stream application
# Build stage
FROM --platform=linux/amd64 node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy application code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM --platform=linux/amd64 node:20-alpine

WORKDIR /app

# Install a simple HTTP server to serve static files
RUN npm install -g serve pm2

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist
COPY printer-proxy-server.js ./

# Expose ports
EXPOSE 6198 6199

# Set environment to production
ENV NODE_ENV=production
ENV WEB_PORT=6198
ENV PRINTER_PROXY_PORT=6199

# Create startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'pm2 start printer-proxy-server.js --name printer-proxy --no-daemon &' >> /app/start.sh && \
    echo 'serve -s dist -l ${WEB_PORT:-6198}' >> /app/start.sh && \
    chmod +x /app/start.sh

# Start both servers
CMD ["/app/start.sh"]
