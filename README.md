Project Setup

# Follow these steps to set up the project:

# Create a new user to run the project:

sudo adduser username
# Replace username with your desired username.

# Grant sudo privileges to the user:

# Run the command:
sudo visudo

# Scroll down to the "User privilege specification" section.
# Add the following line at the end, replacing username with your chosen username:
username ALL=(ALL) NOPASSWD: ALL

# Save the file.

# clone the project
git clone https://github.com/GOPALGTM/bash_script_for_djangoautomation.git
cd bash_script_for_djangoautomation

# Navigate to the directory where the deployment script is located.
# Make the script executable:
sudo chmod +x deploy.sh

# Run the script:
./deploy.sh

# Follow the prompts and enter the requested information:
Linux username: Enter your Linux username (the one you created earlier).
Project repo: Enter the name of your project repo. (bash_script_for_djangoautomation)
Project name: Enter the name of your project. (backend_project)
PostgreSQL database name: Enter the name for your PostgreSQL database.
PostgreSQL username: Enter the username for your PostgreSQL database.
PostgreSQL password: Enter the password for your PostgreSQL database.
The script will execute and perform the necessary actions to set up your project.

