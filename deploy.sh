#!/bin/bash
#install all this dependencies
sudo apt update
sudo apt install python3-venv python3-dev libpq-dev postgresql postgresql-contrib nginx curl -y

# Read PostgreSQL database name, username, and password
read -p "Enter Your Linux Username: " Linux_USER
read -p "Enter Your Project name: " PROJECT_NAME
read -p "Enter PostgreSQL database name: " DB_NAME
read -p "Enter PostgreSQL username: " DB_USER
read -sp "Enter PostgreSQL password: " DB_PASSWORD

# Create PostgreSQL database and user
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE $DB_USER SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

#change directory
PROJECT_DIR=/home/trigger
python3 -m venv env
source env/bin/activate
cd $PROJECT_DIR/$PROJECT_NAME

# Configure Django project settings
echo "import os" >> $PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME/settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['*']/" $PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME/settings.py
sed -i "s/'ENGINE': 'django.db.backends.sqlite3',/'ENGINE': 'django.db.backends.postgresql_psycopg2',\n        'NAME': '$DB_NAME',\n        'USER': '$DB_USER',\n        'PASSWORD': '$DB_PASSWORD',\n   'HOST': 'localhost',\n        'PORT': '',/" $PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME/settings.py
sed -i "/'NAME'\s*:\s*BASE_DIR\s*\/\s*'db.sqlite3',/d" $PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME/settings.py
echo "STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')" >> $PROJECT_DIR/$PROJECT_NAME/$PROJECT_NAME/settings.py

# Perform initial project setup
pip install -r requirements.txt
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput

# Deactivate virtual environment
deactivate

# Call Gunicorn setup script
bash gunicorn_setup.sh $Linux_USER $PROJECT_NAME

# Call Nginx setup script
bash nginx_setup.sh $Linux_USER $PROJECT_NAME