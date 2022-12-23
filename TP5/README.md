# Partie 1 : Mise en place et maîtrise du serveur Web

## 1. Installation

🌞 **Installer le serveur Apache**

```
[lukas@web ~]$ sudo dnf install -y httpd
```

🌞 **Démarrer le service Apache**

```
[lukas@web ~]$ sudo systemctl start httpd
[lukas@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2022-12-12 00:28:31 CET; 1min 55s ago
       Docs: man:httpd.service(8)
   Main PID: 1533 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 4638)
     Memory: 23.3M
        CPU: 88ms
     CGroup: /system.slice/httpd.service
             ├─1533 /usr/sbin/httpd -DFOREGROUND
             ├─1534 /usr/sbin/httpd -DFOREGROUND
             ├─1535 /usr/sbin/httpd -DFOREGROUND
             ├─1536 /usr/sbin/httpd -DFOREGROUND
             └─1537 /usr/sbin/httpd -DFOREGROUND
```
```
[lukas@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```
```
[lukas@web ~]$ sudo ss -alpnt | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=1831,fd=4),("httpd",pid=1830,fd=4),("httpd",pid=1829,fd=4),("httpd",pid=1827,fd=4))
```
```
[lukas@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[lukas@web ~]$ sudo firewall-cmd --reload
success
[lukas@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
🌞 **TEST**

```
[lukas@web ~]$ sudo systemctl is-active httpd
active
```
```
[lukas@web ~]$ sudo systemctl is-enabled httpd
enabled
```
```
[lukas@web ~]$ curl localhost | head
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
```
lukas@DESKTOP-URQ404I MINGW64 ~
$ curl 10.105.1.11 | head
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**
```
[lukas@web ~]$ cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```
🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[lukas@web ~]$ cat /etc/httpd/conf/httpd.conf | grep 'User '
User apache
```
```
[lukas@web ~]$ ps -ef | grep apache
apache      1828    1827  0 00:34 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1829    1827  0 00:34 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1830    1827  0 00:34 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1831    1827  0 00:34 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
```
[lukas@web ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Dec 12 00:10 .
drwxr-xr-x. 83 root root 4096 Dec 12 00:10 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```
[lukas@web ~]$ sudo useradd doge -d /usr/share/httpd/ -s /sbin/nologin -u 2000
```
```
[lukas@web ~]$ sudo nano /etc/httpd/conf/httpd.conf
```
```
[lukas@web ~]$ cat /etc/httpd/conf/httpd.conf | grep doge
User doge
```
```
[lukas@web ~]$ sudo systemctl restart httpd
```
```
[lukas@web ~]$ ps -ef | grep doge
doge        1526    1525  0 15:59 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
doge        1527    1525  0 15:59 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
doge        1528    1525  0 15:59 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
doge        1529    1525  0 15:59 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```
🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[lukas@web ~]$ sudo nano /etc/httpd/conf/httpd.conf
[lukas@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 6767
```
```
[lukas@web ~]$ sudo firewall-cmd --add-port=6767/tcp --permanent
success
[lukas@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[lukas@web ~]$ sudo firewall-cmd --reload
success
[lukas@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp 6767/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
```
[lukas@web ~]$ sudo systemctl restart httpd
```
```
[lukas@web ~]$ sudo ss -altpn | grep httpd
LISTEN 0      511                *:6767            *:*    users:(("httpd",pid=1813,fd=4),("httpd",pid=1812,fd=4),("httpd",pid=1811,fd=4),("httpd",pid=1809,fd=4))
```
```
[lukas@web ~]$ curl 10.105.1.11:6767 | head
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

# Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 **Install de MariaDB sur `db.tp5.linux`**
```
[lukas@db ~]$ sudo dnf install mariadb-server
[lukas@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
[lukas@db ~]$ sudo systemctl start mariadb
[lukas@db ~]$ sudo mysql_secure_installation
```

🌞 **Port utilisé par MariaDB**
```
[lukas@db ~]$ sudo ss -alpnt | grep mariadb
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=3454,fd=19))
```
```
[lukas@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[lukas@db ~]$ sudo firewall-cmd --reload
success
[lukas@db ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp 3306/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
🌞 **Processus liés à MariaDB**
```
mysql       3454       1  0 16:21 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

# Partie 3 : Configuration et mise en place de NextCloud

## 1. Base de données

🌞 **Préparation de la base pour NextCloud**
```
[lukas@db ~]$ sudo mysql -u root -p
```
```
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```
🌞 **Exploration de la base de données**
```
[lukas@web ~]$ sudo dnf install mysql -y
```
```
[lukas@web ~]$ mysql -u nextcloud -h 10.105.1.12 -p
```
```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud;
Database changed
mysql> show tables;
Empty set (0.01 sec)
```
🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**
```
[lukas@db ~]$ mysql -u root -p
MariaDB [(none)]> select user,host from mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.001 sec)
```
## 2. Serveur Web et NextCloud
🌞 **Install de PHP**
```
[lukas@web ~]$ sudo dnf config-manager --set-enabled crb
[lukas@web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[lukas@web ~]$ dnf module list php
[lukas@web ~]$ sudo dnf module enable php:remi-8.1 -y
[lukas@web ~]$ sudo dnf install -y php81-php
```
🌞 **Install de tous les modules PHP nécessaires pour NextCloud**
```
[lukas@web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**
```
[lukas@web ~]$ sudo mkdir /var/www/tp5_nextcloud -p
```
```
[lukas@web ~]$ curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip --output nextcloud.zip
```
```
[lukas@web ~]$ sudo dnf install unzip -y
```
```
[lukas@web ~]$ unzip nextcloud.zip
[lukas@web nextcloud]$ sudo mv * /var/www/tp5_nextcloud/
```
```
[lukas@web ~]$ ls -al /var/www/tp5_nextcloud/ | grep index.html
-rw-r--r--.  1 lukas lukas   156 Oct  6 14:42 index.html
```
```
[lukas@web ~]$ sudo chown apache /var/www/tp5_nextcloud/ 
[lukas@web ~]$ ls -al /var/www/ | grep tp5
drwxr-xr-x. 14 apache root 4096 Dec 12 17:05 tp5_nextcloud
```
```
[lukas@web ~]$ sudo chown apache /var/www/tp5_nextcloud/*
[lukas@web ~]$ ls -l /var/www/tp5_nextcloud/
total 128
drwxr-xr-x. 47 apache lukas  4096 Oct  6 14:47 3rdparty
drwxr-xr-x. 50 apache lukas  4096 Oct  6 14:44 apps
-rw-r--r--.  1 apache lukas 19327 Oct  6 14:42 AUTHORS
drwxr-xr-x.  2 apache lukas    67 Oct  6 14:47 config
-rw-r--r--.  1 apache lukas  4095 Oct  6 14:42 console.php
-rw-r--r--.  1 apache lukas 34520 Oct  6 14:42 COPYING
drwxr-xr-x. 23 apache lukas  4096 Oct  6 14:47 core
-rw-r--r--.  1 apache lukas  6317 Oct  6 14:42 cron.php
drwxr-xr-x.  2 apache lukas  8192 Oct  6 14:42 dist
-rw-r--r--.  1 apache lukas   156 Oct  6 14:42 index.html
-rw-r--r--.  1 apache lukas  3456 Oct  6 14:42 index.php
drwxr-xr-x.  6 apache lukas   125 Oct  6 14:42 lib
-rw-r--r--.  1 apache lukas   283 Oct  6 14:42 occ
drwxr-xr-x.  2 apache lukas    23 Oct  6 14:42 ocm-provider
drwxr-xr-x.  2 apache lukas    55 Oct  6 14:42 ocs
drwxr-xr-x.  2 apache lukas    23 Oct  6 14:42 ocs-provider
-rw-r--r--.  1 apache lukas  3139 Oct  6 14:42 public.php
-rw-r--r--.  1 apache lukas  5426 Oct  6 14:42 remote.php
drwxr-xr-x.  4 apache lukas   133 Oct  6 14:42 resources
-rw-r--r--.  1 apache lukas    26 Oct  6 14:42 robots.txt
-rw-r--r--.  1 apache lukas  2452 Oct  6 14:42 status.php
drwxr-xr-x.  3 apache lukas    35 Oct  6 14:42 themes
drwxr-xr-x.  2 apache lukas    43 Oct  6 14:44 updater
-rw-r--r--.  1 apache lukas   387 Oct  6 14:47 version.php
```
🌞 **Adapter la configuration d'Apache**
```apache
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```
```
[lukas@web ~]$ sudo nano /etc/httpd/conf.d/web.conf 
[lukas@web ~]$ cat /etc/httpd/conf.d/web.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```
🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf
```
[lukas@web ~]$ sudo systemctl restart httpd
```
🌞 **Exploration de la base de données**
```
[lukas@web ~]$ mysql -u nextcloud -h 10.105.1.12 -p
mysql> use nextcloud

Database changed
mysql> select count(*) from information_schema.tables where table_type = 'BASE TABLE';
+----------+
| count(*) |
+----------+
|       95 |
+----------+
1 row in set (0.00 sec)
```