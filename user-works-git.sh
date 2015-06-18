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

# create a folder for log files
mkdir logs

# create a log file for supervisor logs
touch logs/gunicorn_supervisor.log
touch logs/nginx-access.log
touch logs/nginx-error.log
touch logs/gunicorn-errors.log

mkdir repo

# create media and static dirs
mkdir repo/media
mkdir repo/static
mkdir repo/cookies

# initialize an empty git repo in bare
mkdir bare
cd bare
git init --bare

# move post receive hook from home dir to hooks dir and rename to 'post-receive'
mv ~/git-post-receive-hook ~/bare/hooks/post-receive
# make it executable
chmod +x ~/bare/hooks/post-receive

deactivate
