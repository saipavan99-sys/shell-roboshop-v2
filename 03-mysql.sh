#!/bin/bash

source ./common.sh

check_root

#Installing mysql server
dnf module enable mysql:8.4 -y &>> log_file
dnf install mysql-server -y &>> log_file
validate $? "Installing mysql server"

#Start and enable
systemctl enable mysqld &>> log_file
systemctl start mysqld
validate $? "start and enable mysql"

#Setup root password
mysql_secure_installation --set-root-pass RoboShop@1 &>> log_file
validate $? "Setup MySql root password"


total_time
