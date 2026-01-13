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

# Install PHP, Nginx, and Node tools
RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-session \
    php83-json \
    nginx \
    && npm install -g pm2

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist
COPY printer-proxy-server.js ./

# Copy PHP utility files
COPY utils/log.php ./dist/api/
COPY utils/view-logs.php ./dist/api/
COPY utils/printer-proxy.php ./dist/api/printer.php

# Create logs directory with proper permissions for PHP-FPM (nobody user)
RUN mkdir -p /app/logs && chmod 777 /app/logs

# Configure Nginx
RUN mkdir -p /run/nginx && \
    echo 'server {' > /etc/nginx/http.d/default.conf && \
    echo '    listen 6198;' >> /etc/nginx/http.d/default.conf && \
    echo '    root /app/dist;' >> /etc/nginx/http.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/http.d/default.conf && \
    echo '    location / {' >> /etc/nginx/http.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '    location ~ \.php$ {' >> /etc/nginx/http.d/default.conf && \
    echo '        fastcgi_pass 127.0.0.1:9000;' >> /etc/nginx/http.d/default.conf && \
    echo '        fastcgi_index index.php;' >> /etc/nginx/http.d/default.conf && \
    echo '        include fastcgi.conf;' >> /etc/nginx/http.d/default.conf && \
    echo '    }' >> /etc/nginx/http.d/default.conf && \
    echo '}' >> /etc/nginx/http.d/default.conf

# Configure PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 127.0.0.1:9000/' /etc/php83/php-fpm.d/www.conf

# Expose ports
EXPOSE 6198 6199

# Set environment to production
ENV NODE_ENV=production
ENV WEB_PORT=6198
ENV PRINTER_PROXY_PORT=6199

# Create startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'php-fpm83 &' >> /app/start.sh && \
    echo 'nginx &' >> /app/start.sh && \
    echo 'pm2 start printer-proxy-server.js --name printer-proxy --no-daemon' >> /app/start.sh && \
    chmod +x /app/start.sh

# Start all servers
CMD ["/app/start.sh"]
