#!/bin/bash

echo "----------------------------------------"
echo " Updating system and installing Java..."
echo "----------------------------------------"

sudo apt update -y
sudo apt install -y fontconfig openjdk-21-jre

echo " Java installed:"
java -version

echo "----------------------------------------"
echo "  Installing Jenkins..."
echo "----------------------------------------"

# Import Jenkins GPG key and repo
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

echo "----------------------------------------"
echo " Enabling and starting Jenkins service..."
echo "----------------------------------------"

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo " Jenkins status:"
sudo systemctl status jenkins --no-pager

echo "----------------------------------------"
echo " Configuring firewall for Jenkins..."
echo "----------------------------------------"

sudo apt install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

YOURPORT=8080
PERM="--permanent"
SERV="$PERM --service=jenkins"

if ! sudo firewall-cmd --list-services | grep -q "jenkins"; then
  sudo firewall-cmd $PERM --new-service=jenkins
  sudo firewall-cmd $SERV --set-short="Jenkins ports"
  sudo firewall-cmd $SERV --set-description="Jenkins port exceptions"
  sudo firewall-cmd $SERV --add-port=$YOURPORT/tcp
  sudo firewall-cmd $PERM --add-service=jenkins
fi

sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload

echo "----------------------------------------"
echo " Installation complete!"
echo "----------------------------------------"

echo "You can now access Jenkins via: http://<your-public-ip>:8080"
echo ""
echo "Initial admin password (copy this):"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
