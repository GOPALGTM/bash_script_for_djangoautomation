#!/bin/bash

# Read the application name as an argument
LINUX_USER=$1
REPO_NAME=$2
PROJECT_NAME=$3

#create Gunicorn socket file
sudo tee /etc/systemd/system/gunicorn.socket <<EOF
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
EOF

# Create Gunicorn service file
sudo tee /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=$LINUX_USER
Group=www-data
WorkingDirectory=/home/$LINUX_USER/$REPO_NAME
ExecStart=/home/$LINUX_USER/$REPO_NAME/env/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          $PROJECT_NAME.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Gunicorn service
sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket
file /run/gunicorn.sock
sudo journalctl -u gunicorn.socket
curl --unix-socket /run/gunicorn.sock localhost
sudo journalctl -u gunicorn
sudo systemctl daemon-reload
sudo systemctl restart gunicorn