#!/bin/bash

source ./common.sh

check_root

#Setup rabbitmq repo
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding RAbbitMQ repo"

#Installing Rabbitmq
dnf install erlang rabbitmq-server -y &>> $log_file
validate $? "Installing rabbitmq server" 

#Start & enable the RabbitMQ service
systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
validate $? "start and enable RabbitMQ server"

#checking RabbitMQ user exists or not ; if not then create user
rabbitmqctl list_users | grep "roboshop" &>> $log_file

if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    validate $? "Creating RabbitMQ user for roboshop"
else
    echo -e "$(timestamp) [INFO] Rabbitmq user already exists....${Y}SKIPPING${N}"
fi


rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
validate $? "Settingup permissions For RabbitMQ user "


total_time