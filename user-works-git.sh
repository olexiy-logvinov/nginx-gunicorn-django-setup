#!/bin/bash

# this is a part of new-project.sh that runs commands as new user
# first argument - project name
# second - pip requirements (y/n)

cd /webapps/${1}
virtualenv .

# enter (activate) the virtual environment
source bin/activate

# create an SSH key
#ssh-keygen

# show ssh key - copy and add to bitbucket
#less .ssh/id_rsa.pub

# create authorized_keys file where public key from our development environment will be stored
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys

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
mv /webapps/${1}/git-post-receive-hook /webapps/${1}/bare/hooks/post-receive
# replace 'hello' with actual project name
sed -i -e "s/hello/${1}/g" /webapps/${1}/bare/hooks/post-receive
# make it executable
chmod +x /webapps/${1}/bare/hooks/post-receive

deactivate
