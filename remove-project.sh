#!/bin/bash

echo 'please enter a project name'
read projectName

echo 'please enter a username of a user associated with this project (virtualenv)'
read userName

# Remove the virtual server from Nginx sites-enabled folder
rm /etc/nginx/sites-enabled/${projectName}

# Restart nginx
service nginx restart

# Remove nginx config file
rm /etc/nginx/sites-available/${projectName}

# Stop the application with Supervisor
supervisorctl stop $projectName

# Remove the application from Supervisor’s control scripts directory
rm /etc/supervisor/conf.d/${projectName}.conf

# Remove project directory from /webapps
rm -r /webapps/${projectName}_django

# Remove user
userdel $userName

echo 'The End!'
