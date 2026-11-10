#!/bin/bash

app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup

#installing MongoDB client

cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo &>> $log_file
validate $? "Adding Mongo repo"

dnf install mongodb-mongosh -y &>> $log_file
validate $? "Installing MongoDB Client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $log_file)
validate $? "Connecting to MongoDB"

if [ "$product_count" -eq 0 ]; then          #0 means No data or products
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $log_file
    validate $? "Loading products"
else
   echo -e "$(timestamp) [INFO] Products already loaded....${Y}SKIPPING${N}"
fi

restart

#Health checking
#systemctl status catalogue
#journalctl -u catalogue -f
#curl http://localhost:8080/health
#curl http://localhost:8080/products

total_time
