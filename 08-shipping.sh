#!/bin/bash

app_name=shipping
source ./common.sh
check_root

app_setup
java_setup

#installing mysql client
dnf install mysql -y &>> $log_file
validate $? "Installing mysql client"

#loading master data
count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file )
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
    mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
    validate $? "Loading shipping data"
else
    echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi

#Creating APP user
mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $log_file
validate $? "Creating APP user"

#Restarting/Starting shipping
systemctl daemon-reload &>> $log_file
systemctl enable shipping &>> $log_file
systemctl restart shipping &>> $log_file
validate $? "Restarting/Starting shipping"



systemd_setup

restart
total_time
