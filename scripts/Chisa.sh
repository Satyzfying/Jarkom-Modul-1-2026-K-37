#!/bin/bash
# FTP Server Setup
apt-get update
apt-get install vsftpd -y
mkdir -p /var/wired/data

useradd -d /var/wired/data -s /bin/bash alice
echo "alice:123" | chpasswd
useradd -d /var/wired/data -s /bin/bash mika
echo "mika:123" | chpasswd
useradd -d /var/wired/data -s /bin/bash eiri
echo "eiri:123" | chpasswd

chown alice:alice /var/wired/data
chmod 755 /var/wired/data

cat << 'VEOF' > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=YES
VEOF

echo "eiri" > /etc/vsftpd.userlist
service vsftpd restart

# Telnet Server Setup
apt-get install telnetd -y
useradd -m -s /bin/bash phantom_user
echo "phantom_user:wired_ghost" | chpasswd
echo "telnet stream tcp nowait root /usr/sbin/telnetd" > /etc/inetd.conf
service inetutils-inetd restart
