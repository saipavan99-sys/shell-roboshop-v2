#!/bin/bash

source ./common.sh
check_root

#Installing nginx
dnf module disable nginx -y &>> $log_file
dnf module enable nginx:1.26 -y &>> $log_file
dnf install nginx -y &>> $log_file
validate $? "Installing nginx"

#Start and enable nginx
systemctl enable nginx &>> $log_file
systemctl start nginx &>> $log_file
validate $? "Start and enable nginx"

#Removing default content
rm -rf /usr/share/nginx/html/* &>> $log_file
validate $? "Removing default content in html"

#downloading and unziping front end code
curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $log_file
cd /usr/share/nginx/html &>> $log_file
unzip /tmp/frontend.zip &>> $log_file
validate $? "Downloding and unziping frontend code"

#updating roboshop.cong file
sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/roboshop.conf" &>> $log_file
cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf &>> $log_file
validate $? "Copied roboshop.conf"

#nginx config
nginx -t &>> $log_file
validate $? "nginx configuration"

#Restart nginx
systemctl restart nginx &>> $log_file
validate $? "Restartig Nginx"

restart
total_time
