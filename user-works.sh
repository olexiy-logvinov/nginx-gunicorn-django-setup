#!/bin/bash

# this is a part of new-project.sh that runs commands as new user
# first argument - project name
# second - pip requirements (y/n)

cd /webapps/${5}
virtualenv .

# enter (activate) the virtual environment
source bin/activate

# let user install from requirements.txt instead of latest versions of packages
if [ $2 = 'y' ]
  then
    echo 'Installing requirements from requirements.txt'
    pip install -r requirements.txt
  else
    # install latest Django
    pip install django
    # install psycopg2 if this project will use PostgreSQL
    if [ $3 = 'y' ]; then
      pip install psycopg2;
    fi
    # install MySQL-python
    if [ $4 = 'y' ]; then
      pip install MySQL-python
    fi
fi

# create a django project in a virtual environment
django-admin.py startproject $1

# create media and static dirs
mkdir media
mkdir static


# install Gunicorn
pip install gunicorn

# install setproctitle to see project name instead of just gunicorn in top or ps
# pip install setproctitle

# install gevent library to enable async gunicorn workers
# pip install gevent

# create a folder for log files
mkdir logs

# create a log file for supervisor logs
touch logs/gunicorn_supervisor.log
touch logs/nginx-access.log
touch logs/nginx-error.log
touch logs/gunicorn-errors.log
