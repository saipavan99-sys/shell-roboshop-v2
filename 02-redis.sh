#!/bin/bash


source ./common.sh

check_root

#installing redis
dnf module disable redis -y &>> log_file
dnf module enable redis:7 -y &>> log_file
dnf install redis -y &>> log_file
validate $? "Installing redis"

#Updating remort connections
sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remort connections to Redis"

#start and enable redis
systemctl enable redis &>> log_file
systemctl start redis
validate $? "start and enable Redis"

#checking
systemctl status redis &>> log_file
ss -lntp | grep 6379 &>> log_file
redis-cli ping &>> log_file
validate $? "checking Status"


total_time


