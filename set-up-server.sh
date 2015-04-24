#!/bin/bash

# install PostgreSQL database server
sudo apt-get -y install postgresql postgresql-contrib 

# install python dependencies for PostgreSQL
sudo apt-get -y install libpq-dev python-dev

# install mySQL
sudo apt-get -y install mysql-server
sudo apt-get -y install mysql-client
sudo apt-get -y install libmysqlclient-dev

# install supervisor, screen, nginx server, virtualenv
sudo apt-get -y install supervisor screen nginx python-virtualenv




