#!/bin/bash

# this is a part of new-project.sh that runs commands as new user
# first argument - project name
# second - pip requirements (y/n)

cd /webapps/${1}
virtualenv .

# enter (activate) the virtual environment
source bin/activate

# create an SSH key
ssh-keygen

# show ssh key - copy and add to bitbucket
less .ssh/id_rsa.pub

# clone a repo
#echo 'please enter your repo ssh url'
# example git@bitbucket.org:bavovna/ukroppen.git
#read repoUrl
#git clone $repoUrl

# install requirements
#pip install -r requirements.txt

# create media and static dirs
mkdir media
#mkdir static

# create a folder for log files
mkdir logs

# create a log file for supervisor logs
touch logs/gunicorn_supervisor.log
touch logs/nginx-access.log
touch logs/nginx-error.log
touch logs/gunicorn-errors.log

deactivate
