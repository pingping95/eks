#!/bin/bash

os_type=$(cat /etc/*-release | uniq | head -1)

if [ "${os_type}" == "NAME=\"Amazon Linux\"" ];
    then sudo amazon-linux-extras install -y epel
else
    check_jdk=$(rpm -qa | grep jdk | head -1)
    if [ -n "$check_jdk" ];
        then sudo yum remove -y $check_jdk
    fi
fi

check_expect=$(rpm -qa | grep expect)
if [ -z "$check_expect" ];
    then sudo yum install -y expect
fi

id=jenkins
pw=jenkins1!

sudo userdel $id
sudo adduser $id

expect << EOF
spawn sudo passwd $id

expect "New password:"
send "$pw\r";    

expect "Retype new password:"
send "$pw\r";    

expect eof
EOF

num=$(sudo grep -n "## Allow root" /etc/sudoers | cut -d: -f1 | head -1)
num=$((num+1))
data=$(sudo cat /etc/sudoers | sed -n ${num}p)
data2=$(echo ${data} | sed -e "s/root.*/${id}\tALL=(ALL)\tNOPASSWD: ALL/g")
sudo sed -i "${num}s/${data}/${data}\n${data2}/g" /etc/sudoers
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo service sshd restart

sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date

sudo yum install -y python3
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install awscli

sudo yum install -y git
sudo yum install -y java-1.8.0-openjdk-devel.x86_64
rpm -qa java*jdk-devel
javac -version
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install -y jenkins

sudo chkconfig jenkins on

sudo service jenkins start

sudo systemctl enable jenkins