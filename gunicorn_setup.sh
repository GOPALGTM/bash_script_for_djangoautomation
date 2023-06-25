#!/bin/bash

# Read the application name as an argument
APP_NAME=$1

#create Gunicorn socke6 file
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
User=trigger
Group=www-data
WorkingDirectory=/home/trigger/project/$APP_NAME
ExecStart=/home/trigger/project/env/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          demo.wsgi:application

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