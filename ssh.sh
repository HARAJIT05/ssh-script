#!/bin/bash

# Function to install and configure OpenSSH
install_ssh() {
  # Update package list
  echo "Updating package list..."
  case "$PACKAGE_MANAGER" in
    apt)
      sudo apt update -y
      sudo apt upgrade -y
      echo "Installing OpenSSH Server..."
      sudo apt install -y openssh-server
      ;;
    pacman)
      sudo pacman -Syu --noconfirm
      echo "Installing OpenSSH Server..."
      sudo pacman -S --noconfirm openssh
      ;;
    termux)
      pkg update
      pkg upgrade
      echo "Installing OpenSSH Server..."
      pkg install -y openssh
      ;;
    *)
      echo "Unsupported package manager: $PACKAGE_MANAGER"
      exit 1
      ;;
  esac

  # Enable and start the SSH service
  echo "Enabling and starting SSH service..."
  sudo systemctl enable sshd
  sudo systemctl start sshd

  # Backup the existing SSH configuration file
  echo "Backing up the current SSH configuration..."
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  # Modify the SSH configuration to listen on the chosen port
  echo "Configuring SSH to listen on port $PORT..."
  sudo sed -i "s/#Port 22/Port $PORT/" /etc/ssh/sshd_config

  # Allow the new port through the firewall
  echo "Allowing port $PORT through the firewall..."
  case "$PACKAGE_MANAGER" in
    apt)
      sudo ufw allow $PORT/tcp
      ;;
    pacman)
      sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
      ;;
    termux)
      # Termux uses its own firewall settings
      echo "Note: Termux does not require firewall configuration for SSH"
      ;;
  esac

  # Restart the SSH service to apply the changes
  echo "Restarting SSH service..."
  sudo systemctl restart sshd

  # Check the SSH service status
  echo "Checking SSH service status..."
  sudo systemctl status sshd

  echo "OpenSSH server has been configured to listen on port $PORT."
}

# Prompt the user for the package manager and port number
read -p "Enter your package manager (apt/pacman/termux): " PACKAGE_MANAGER
read -p "Enter the port number for SSH: " PORT

install_ssh
