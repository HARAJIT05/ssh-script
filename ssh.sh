#!/bin/bash

# Prompt the user for the port number
read -p "Enter the port number for SSH: " PORT

# Update package list and upgrade packages
echo "Updating package list..."
sudo apt update -y
sudo apt upgrade -y

# Install OpenSSH Server
echo "Installing OpenSSH Server..."
sudo apt install -y openssh-server

# Enable and start the SSH service
echo "Enabling and starting SSH service..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Backup the existing SSH configuration file
echo "Backing up the current SSH configuration..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the SSH configuration to listen on the chosen port
echo "Configuring SSH to listen on port $PORT..."
sudo sed -i "s/#Port 22/Port $PORT/" /etc/ssh/sshd_config

# Allow the new port through the firewall
echo "Allowing port $PORT through the firewall..."
sudo ufw allow $PORT/tcp

# Restart the SSH service to apply the changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Check the SSH service status
echo "Checking SSH service status..."
sudo systemctl status ssh

echo "OpenSSH server has been configured to listen on port $PORT."
