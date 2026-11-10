#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

# installing MongoDB
dnf install mongodb-org -y &>> $log_file
validate $? "install MongoDB"

# start and enable MongoDb
systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validate $? "enable and start MongoDB"

#updating remort connections
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "updating remort connection to MongoDB"

#restaring mongod
systemctl restart mongod
validate $? "restarting MongoDB"

total_time