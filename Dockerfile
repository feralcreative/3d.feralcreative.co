# Multi-stage build for 3D Printer Stream application
# Build stage
FROM --platform=linux/amd64 node:20-slim AS builder

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
FROM --platform=linux/amd64 node:20-slim

WORKDIR /app

# Install system dependencies
# Add Sury PHP repository for PHP 8.3
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    gnupg2 \
    lsb-release \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    php8.3 \
    php8.3-fpm \
    php8.3-cli \
    nginx \
    python3 \
    python3-pip \
    libgl1 \
    libgomp1 \
    libopengl0 \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g pm2

# Install PyMeshLab for STL repair
RUN pip3 install --no-cache-dir pymeshlab --break-system-packages

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist
COPY printer-proxy-server.js ./

# Copy utils directory (needed for stl-repair.js and other utilities)
COPY utils ./utils

# Copy PHP utility files to dist/api
COPY utils/log.php ./dist/api/
COPY utils/view-logs.php ./dist/api/
COPY utils/printer-proxy.php ./dist/api/printer.php

# Create logs directory with proper permissions for PHP-FPM (nobody user)
RUN mkdir -p /app/logs && chmod 777 /app/logs

# Configure Nginx
RUN mkdir -p /var/run/nginx && \
    echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen 6198;' >> /etc/nginx/sites-available/default && \
    echo '    root /app/dist;' >> /etc/nginx/sites-available/default && \
    echo '    index index.html;' >> /etc/nginx/sites-available/default && \
    echo '    # Proxy /api/notify to Node.js server on port 6199' >> /etc/nginx/sites-available/default && \
    echo '    location /api/notify {' >> /etc/nginx/sites-available/default && \
    echo '        proxy_pass http://127.0.0.1:6199;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header X-Real-IP $remote_addr;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header X-Forwarded-Proto $scheme;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '    location ~ \.php$ {' >> /etc/nginx/sites-available/default && \
    echo '        fastcgi_pass 127.0.0.1:9000;' >> /etc/nginx/sites-available/default && \
    echo '        fastcgi_index index.php;' >> /etc/nginx/sites-available/default && \
    echo '        include fastcgi.conf;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '}' >> /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Configure PHP-FPM to listen on 127.0.0.1:9000
RUN sed -i 's|listen = /run/php/php8.3-fpm.sock|listen = 127.0.0.1:9000|' /etc/php/8.3/fpm/pool.d/www.conf

# Expose ports
EXPOSE 6198 6199

# Set environment to production
ENV NODE_ENV=production
ENV WEB_PORT=6198
ENV PRINTER_PROXY_PORT=6199

# Create startup script
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'service php8.3-fpm start' >> /app/start.sh && \
    echo 'nginx &' >> /app/start.sh && \
    echo 'pm2 start printer-proxy-server.js --name printer-proxy --no-daemon' >> /app/start.sh && \
    chmod +x /app/start.sh

# Start all servers
CMD ["/app/start.sh"]
