#!/bin/bash

log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
domain_name="saipavan.store"
script_dir=$(dirname "$(realpath "$0")")
R="\e[31m"  #adding colours to specific words
G="\e[32m"
Y="\e[33m"
N="\e[0m"   

user_id=$(id -u)

check_root(){
   if [ $user_id -ne 0 ]; then
      echo "please run this script with sudo access"
      exit 1
   fi
}

#Adding time stamp
timestamp(){
    date "+%F %T"
}

mkdir -p $log_folder                                                  #creating log_folder if not

#Starting Time
echo  "$(timestamp) [INFO] ===== script started Execution =====" | tee -a $log_file

#function

validate(){
     if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] $2 is ${R}FAILED....${N}" | tee -a $log_file         #to print status on screen use tee cmd
        exit 1                                                                             #exit status
    else 
        echo -e "$(timestamp) [INFO] $2 is ${G}SUCCESS....${N}" | tee -a $log_file        # "-e" is to execute colours
    fi
}

#nodejs_setup
nodejs_setup(){
    dnf module disable nodejs -y &>> $log_file
    dnf module enable nodejs:24 -y &>> $log_file
    dnf install nodejs -y &>> $log_file
    validate $? "Installing nodejs 24"

    npm install &>> $log_file
    validate $? "Install dependencies"
}

#java_setup

java_setup(){
    #install Java And Maven
    dnf module enable maven:3.9 -y &>> $log_file
    dnf install maven java-25-openjdk-devel -y &>> $log_file
    validate $? "Installing Java And Maven"

    #Setuping Java25 Version
    alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
    validate $? "Setting Java25 as default version"

    #Setting JAVA_HOME for maven
    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "Setting JAVA_HOME for maven"

    #Installing dependencies
    mvn clean package &>> $log_file
    validate $? "Installing dependencies"

    #Moving shipping.jar file
    mv target/shipping.jar shipping.jar
    validate $? "Moving shipping.jar file"
}

#python_setup

python_setup(){
    #Installing python
    dnf install python3.14 python3.14-pip -y &>> $log_file
    validate $? "Installing python 3.14"

    #Installing dependencies
    python3.14 -m venv /app/.venv &>> $log_file
    validate $? "Creating virtual environment"


    /app/.venv/bin/pip install -r requirements.txt &>> $log_file
    validate $? "Installing dependencies"
}

#app_setup

app_setup(){
    id roboshop &>> $log_file  #checking syatem user
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    validate $? "creating system user"
    else
    echo -e "$(timestamp) [INFO] System user already exists....${Y}SKIPPING${N}"
    fi

    #create app directory (-p if exists not create )
    rm -rf /app
    validate $? "Removing old code"

    mkdir -p /app
    validate $? "Creating app directory"

    #Download application
    curl -L -o "tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $log_file
    validate $? "Downloading $app_name"

    cd /app
    unzip "/tmp/$app_name.zip" &>> $log_file
    validate $? "Unzip $app_name"
}

systemd_setup(){
    sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/$app_name.service"
    cp "$script_dir/$app_name.service" /etc/systemd/system/$app_name.service 

    systemctl daemon-reload &>> $log_file
    systemctl enable $app_name &>> $log_file
    systemctl start $app_name &>> $log_file
    validate $? "Start and enable $app_name"
}

restart(){
    systemctl restart $app_name
    validate $? "restarting $app_name"
}

#End Time

total_time(){
  echo -e "$(timestamp) [INFO] Script completed in $SECONDS seconds"
  echo -e "$(timestamp) [INFO] ===== script completed execution =====" | tee -a $log_file
}      

