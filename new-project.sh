#!/bin/bash

# this is a shell script to automate server setup procedures described in 
# http://michal.karzynski.pl/blog/2013/06/09/django-nginx-gunicorn-virtualenv-supervisor/
# first argument - new project name
# second argument - new user name

# get information from user
echo 'please enter a name for your new project:'
read projectName

echo 'please enter virtualenv folder name'
read virtualenv

echo 'please enter a domain name of your site, i.e. example.com'
read domainName

echo 'please enter a username for a new user (no spaces please):'
read userName

echo 'would you like pip to use a requirements.txt file to install specific version of packages? y/n'
read pipRequirements

if [ $pipRequirements = 'n' ]
  then
    echo 'will you use postgreSQL in this project (whould we install psycopg2)?  y/n:'
    read postgres

    echo 'will you use mySQL? (y/n)'
    read mysql
fi

# create a webapps group
echo 'creating the webapps group'
groupadd --system webapps

# create a new user and assign to webapps group
useradd --system --gid webapps --shell /bin/bash --home /webapps/${virtualenv} $userName

# create and activate an environment for a new application
mkdir -p /webapps/${virtualenv}
chown $userName /webapps/${virtualenv}
chown -R ${userName}:webapps /webapps/${virtualenv}
# give write permissions to group
chmod -R g+w /webapps/${virtualenv}

# copy requirements.txt to new user's home directory
cp requirements.txt /webapps/${virtualenv}/requirements.txt

# as the application user create a virtual Python environment in the application directory
sudo -u $userName ./user-works.sh $projectName $pipRequirements $postgres $mysql $virtualenv


# copy a gunicorn-start bash script template to project folder and modify it
cp gunicorn-start-template /webapps/${virtualenv}/bin/gunicorn_start
sed -i -e "s/hello/$projectName/g" /webapps/${virtualenv}/bin/gunicorn_start
sed -i -e "s/username/$userName/g" /webapps/${virtualenv}/bin/gunicorn_start

# calculate number of gunicorn workers
# http://stackoverflow.com/questions/14735366/cannot-assign-the-output-of-python-v-to-a-variable-in-bash
# gWorkers='python gunicorn-workers.py 2>&1'
gWorkers=3
sed -i -e "s/num_cpu_cores/${gWorkers}/g" /webapps/${virtualenv}/bin/gunicorn_start

# make gunicorn-start executable
chmod u+x /webapps/${virtualenv}/bin/gunicorn_start

# create a supervisor configuration file for our application (copy template and modify)
cp supervisor-template.conf /etc/supervisor/conf.d/${projectName}.conf
sed -i -e "s/hello/$projectName/g" /etc/supervisor/conf.d/${projectName}.conf
sed -i -e "s/username/$userName/g" /etc/supervisor/conf.d/${projectName}.conf


# ask supervisor to reread configuration files and update (this will start your newly registered app)
supervisorctl reread
supervisorctl update

# create a new nginx server configuration file for your Django application running on example.com
cp nginx-template.conf /etc/nginx/sites-available/${projectName}
# modify configuration file
sed -i -e "s/hello/$projectName/g" /etc/nginx/sites-available/${projectName}
sed -i -e "s/example.com/$domainName/g" /etc/nginx/sites-available/${projectName}

# Create a symbolic link in the sites-enabled folder
ln -s /etc/nginx/sites-available/${projectName} /etc/nginx/sites-enabled/${projectName}

# copy html error pages templates to static folder
cp 500.html /webapps/${virtualenv}/static/500.html

# once again
chown -R ${userName}:webapps /webapps/${virtualenv}

echo "###########"
echo "End of new-project.sh"
echo "Now your should create a database for your Django app and edit settings.py"
echo "Then run sudo -u ${userName} supervisorctl start ${projectName}"
