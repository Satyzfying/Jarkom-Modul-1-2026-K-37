#!/bin/bash
# SSH Server Setup
apt-get update
apt-get install openssh-server -y
service ssh start

# Create user for public key auth
useradd -m -s /bin/bash mika_admin
echo "mika_admin:123" | chpasswd

# Disable Password Authentication
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
service ssh restart
