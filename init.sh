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
sudo su balena -c "~/open-balena/scripts/quickstart -c -U $USERNAME -P $PASSWORD -d $DOMAIN"
sudo /home/balena/open-balena/scripts/patch-hosts $DOMAIN

# Start balena
sudo su balena -c "~/open-balena/scripts/compose up -d"

# Fix cert provider
sudo su balena -c "docker exec $(sudo su balena -c "~/open-balena/scripts/compose ps -q cert-provider") /bin/bash -c \"grep -v 'Unable to acquire a staging certificate' cert-provider.sh > cert-provider.sh.temp\""
sudo su balena -c "docker exec $(sudo su balena -c "~/open-balena/scripts/compose ps -q cert-provider") /bin/bash -c \"grep -v 'Unable to detect certificate change over. Cannot issue a production certificate' cert-provider.sh.temp > cert-provider.sh\""
sudo su balena -c "docker stop $(sudo su balena -c "~/open-balena/scripts/compose ps -q cert-provider")"
sudo su balena -c "docker start $(sudo su balena -c "~/open-balena/scripts/compose ps -q cert-provider")"
