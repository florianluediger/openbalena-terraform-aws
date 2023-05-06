#!/bin/bash

# Configure balena
export DOMAIN=your.domain.here
export USERNAME=your.username.here
export PASSWORD=your.password.here

# Wait for the server to start up completely
sleep 1m

# Install packages
sudo apt update
sudo apt install -y git docker.io libssl-dev nodejs npm

# Install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl start docker

# Create balena user
sudo adduser --disabled-password --gecos "" balena
sudo usermod -aG sudo balena
sudo usermod -aG docker balena

# Install balena
sudo su balena -c "git clone https://github.com/balena-io/open-balena.git ~/open-balena"
sudo su balena -c "~/open-balena/scripts/quickstart -U $USERNAME -P $PASSWORD -d $DOMAIN"

# Copy CA certificate to ubuntu home to enable copying with scp later
sudo cp /home/balena/open-balena/config/certs/root/ca.crt /home/ubuntu/ca.crt
sudo chown ubuntu /home/ubuntu/ca.crt

# Start balena
sudo su balena -c "~/open-balena/scripts/compose up -d"
