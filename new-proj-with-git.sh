#!/bin/bash

# this is a shell script to automate server setup procedures described in 
# http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/
# first argument - new project name
# second argument - new user name

# get information from user
#echo 'please enter a name of the  project that will be cloned with git:'
#read projectName

echo 'please enter virtualenv folder name'
read virtualenv

echo 'Python version? 2 or 3?'
read pythonVersion

echo 'please enter a domain name of your site, i.e. example.com'
read domainName

echo 'please enter a username for a new user (no spaces please):'
read userName

echo 'Django project name:'
read djangoAppName

#echo 'would you like pip to use a requirements.txt file to install specific version of packages? y/n'
#read pipRequirements

# create a webapps group
echo 'creating the webapps group'
groupadd --system webapps

# create a new user and assign to webapps group
useradd --system --gid webapps --shell /bin/bash --home /webapps/${virtualenv} $userName

# create and activate an environment for a new application
mkdir -p /webapps/${virtualenv}

# copy files that new user will need in home dir
cp git-post-receive-hook /webapps/$virtualenv/

#chown $userName /webapps/${virtualenv}
chown -R ${userName}:webapps /webapps/${virtualenv}
# give write permissions to group
chmod -R g+w /webapps/${virtualenv}

# copy requirements.txt to new user's home directory
cp requirements.txt /webapps/${virtualenv}/requirements.txt

# as the application user create a virtual Python environment in the application directory
sudo -u $userName ./user-works-git.sh $virtualenv $djangoAppName $pythonVersion


# copy a gunicorn-start bash script template to project folder and modify it
cp gunicorn-start-template /webapps/${virtualenv}/env/bin/gunicorn_start
sed -i -e "s/hello/$virtualenv/g" /webapps/${virtualenv}/env/bin/gunicorn_start
sed -i -e "s/username/$userName/g" /webapps/${virtualenv}/env/bin/gunicorn_start
# ATTENTION! replace 'ukroppen' with your actual app's name
sed -i -e "s/my_app/$djangoAppName/g" /webapps/${virtualenv}/env/bin/gunicorn_start

# TODO - calculate number of gunicorn workers
# http://stackoverflow.com/questions/14735366/cannot-assign-the-output-of-python-v-to-a-variable-in-bash
# gWorkers='python gunicorn-workers.py 2>&1'
gWorkers=3
sed -i -e "s/num_cpu_cores/${gWorkers}/g" /webapps/${virtualenv}/env/bin/gunicorn_start

# make gunicorn-start executable
chmod u+x /webapps/${virtualenv}/env/bin/gunicorn_start

# create a supervisor configuration file for our application (copy template and modify)
cp supervisor-template.conf /etc/supervisor/conf.d/${virtualenv}.conf
sed -i -e "s/hello/$virtualenv/g" /etc/supervisor/conf.d/${virtualenv}.conf
sed -i -e "s/username/$userName/g" /etc/supervisor/conf.d/${virtualenv}.conf

# create a new nginx server configuration file for your Django application running on example.com
cp nginx-template.conf /etc/nginx/sites-available/${virtualenv}
# modify configuration file
sed -i -e "s/hello/$virtualenv/g" /etc/nginx/sites-available/${virtualenv}
sed -i -e "s/example.com/$domainName/g" /etc/nginx/sites-available/${virtualenv}

# Create a symbolic link in the sites-enabled folder
ln -s /etc/nginx/sites-available/${virtualenv} /etc/nginx/sites-enabled/${virtualenv}

# copy html error pages templates to static folder
#cp 500.html /webapps/${virtualenv}/repo/static/500.html

if [ $pythonVersion = 3 ]
  then
    pythonFolder='python3.4'
  else
    pythonFolder='python2.7'
fi
# copy liqpay library to python libs directory
cp -r liqpay /webapps/${virtualenv}/env/lib/${pythonFolder}/site-packages/

# copy mysecrets.py template to libs directory
cp mysecrets.py /webapps/${virtualenv}/env/lib/${pythonFolder}/site-packages/
sed -i -e "s/envFolder/$virtualenv/g" /webapps/${virtualenv}/env/lib/${pythonFolder}/site-packages/ 

# once again
chown -R ${userName}:webapps /webapps/${virtualenv}
chmod go-w /webapps/${virtualenv} # for successfull ssh - https://help.ubuntu.com/community/SSH/OpenSSH/Keys

# ask supervisor to reread configuration files and update (this will start your newly registered app)
#supervisorctl reread
#supervisorctl update


echo "###########"
echo "The End!"
echo "Now you should create a database for your Django app and edit settings.py"
#echo "Then run sudo -u ${userName} supervisorctl start ${virtualenv}"
echo "Then run supervisorctl reread, supervisorctl update, service nginx restart"
echo "And import mysecrets to settings.py"
