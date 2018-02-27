#!/bin/bash
# System update
sudo apt-get update -y

# install required package
sudo apt-get install apt-transport-httpsi -y 
sudo apt-get install ca-certificates -y
sudo apt-get install curl -y 
sudo apt-get install software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install docker-ce -y
sudo usermod -aG docker ubuntu
sudo apt-get install mysql-client -y
mysql -u ${DBUSER} -p -D ${DATABASE} -h ${DBHOST} -P 3306 < sql/fixtures.sql

# run docker
sudo docker run -d -p 8080:80 -e DBHOST=${DBHOST} -e DATABASE=${DATABASE} -e DBUSER=${DBUSER} -e DBPASSWORD=${DBPASSWORD} d2si/php-simple-app