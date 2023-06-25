#!/bin/bash

# Read the application name as an argument
APP_NAME=$1

# Create Nginx configuration file
sudo tee /etc/nginx/sites-available/$APP_NAME <<EOF
server {
    listen 80;
    server_name 35.154.170.167;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /staticfiles/ {
        root /home/trigger/project/demo;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}    
EOF

# Enable Nginx configuration
sudo ln -s /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

sudo ufw delete allow 8000
sudo ufw allow 'Nginx Full'sss