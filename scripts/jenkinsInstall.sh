#!/bin/bash
#-- Simple script to install Jenkins on CentOS 7 
#-- Do Work
# Download repo
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
# Import Key
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
# Install Jenkins and Java 
yum install -y jenkins java-11-openjdk-devel 
# Verify default java
if [[ $(java --version |grep "openjdk 11.*"|wc -l) -ge 1 ]]; then
    echo "Default Java: Java 11"
else
    echo "Error: please set your default java version to Java 11."
fi
# Start & Enable jenkins on boot
sudo systemctl enable jenkins && sudo systemctl start jenkins
# Open Firewall Ports for Jenkins
firewall-cmd --permanent --add-service=jenkins
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload
# Turn off SELinux
sudo setenforce 0
# Set SELinux to Permissive on reboot
sudo sed -i '/SELINUX=enforcing/c\SELINUX=permissive' /etc/selinux/config
# Add Jenkins config to Nginx Proxy Server
# Redirect all traffic from port 443 -> port 8080

# Give jenkins user /bin/bash access
usermod -s /bin/bash jenkins
# Give jenkins user a password
#passwd jenkins
# Give jenkins user ssh access
su - jenkins
ssh-keygen
ssh-copy-id jenkins@localhost
# Add jenkins to sudo w/o password
echo -e "Please add the following to your sudoers file:\njenkins ALL=(ALL)       NOPASSWD"
