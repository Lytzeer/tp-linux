# Module 1 : Reverse Proxy

# I. Setup

🖥️ **VM `proxy.tp6.linux`**

🌞 **On utilisera NGINX comme reverse proxy**

```
[lukas@proxy ~]$ sudo dnf install nginx
```
```
[lukas@proxy ~]$ sudo systemctl start nginx
[lukas@proxy ~]$ sudo systemctl status nginx | grep Active
     Active: active (running) since Mon 2023-01-02 16:23:18 CET; 48s ago
```
```
[lukas@proxy ~]$ sudo ss -altnp4 | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11123,fd=6),("nginx",pid=11122,fd=6))
```
```
[lukas@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[lukas@proxy ~]$ sudo firewall-cmd --reload
success
[lukas@proxy ~]$ sudo firewall-cmd --list-all | grep ports -m1
  ports: 22/tcp 80/tcp
```
```
[lukas@proxy ~]$ ps -ef | grep nginx
nginx      11123   11122  0 16:27 ?        00:00:00 nginx: worker process
```
```
[lukas@proxy ~]$ curl 10.105.1.13:80 | head
!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
🌞 **Configurer NGINX**

```
[lukas@proxy ~]$ sudo nano /etc/nginx/conf.d/reverse.conf
```
```nginx
[lukas@proxy ~]$ sudo cat /etc/nginx/conf.d/reverse.conf
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp5.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```
```
[lukas@web ~]$ sudo nano /var/www/tp5_nextcloud/config/config.php
[lukas@web ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php | head | tail -n 5
  'trusted_domains' =>
  array (
    0 => 'web.tp5.linux',
    1 => '10.105.1.13',
  ),
```

🌞 **Faites en sorte de**

```
[lukas@web ~]$ sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="10.105.1.13" accept'
success
[lukas@web ~]$ sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source not address="10.105.1.13" reject'
success
[lukas@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Une fois que c'est en place**

```
PS C:\Users\lukas> ping 10.105.1.13

Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.13:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```
```
PS C:\Users\lukas> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
```
# II. HTTPS

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**
```
[lukas@proxy ~]$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/certificate

[lukas@proxy ~]$ sudo nano /etc/nginx/conf.d/reverse.conf
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp5.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.105.1.11;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;
    ssl_certificate /etc/ssl/certs/certificate;
    ssl_certificate_key /etc/ssl/private/nginx.key;
}

[lukas@proxy ~]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[lukas@proxy ~]$ sudo firewall-cmd --reload
success
[lukas@proxy ~]$ sudo systemctl restart nginx
```

# Module 2 : Sauvegarde du système de fichiers

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

```
[lukas@web ~]$ sudo nano /srv/tp6_backup.sh
#!/bin/bash

# Created 10/01/2023
# By Lytzeer
# Créer des backups de nextcloud

sed -i "s/'maintenance' => false,/'maintenance' => true,/" /var/www/tp5_nextcloud/config/config.php
mkdir -p /srv/backup
cd /srv/backup/
date=`date +"%Y%m%d%H%M%S"`
name="nextcloud_$date.zip"
zip $name /var/www/tp5_nextcloud/>/dev/null
echo "Backup effectué !"
sed -i "s/'maintenance' => true,/'maintenance' => false,/" /var/www/tp5_nextcloud/config/config.php
```

### 2. Clean it

➜ **Environnement d'exécution du script**

```
[lukas@web ~]$ sudo useradd -m -d /srv/backup/ -s /usr/sbin/nologin backup
```
```bash
[lukas@web ~]$ sudo -u backup /srv/tp6_backup.sh
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

```bash
[lukas@web ~]$ sudo nano /etc/systemd/system/backup.service
[Service]
Type=oneshot
ExecStart=/srv/tp6_backup.sh start
```
```bash
[lukas@web ~]$ sudo systemctl status backup
○ backup.service
     Loaded: loaded (/etc/systemd/system/backup.service; static)
     Active: inactive (dead)
[lukas@web ~]$ sudo systemctl start backup
[lukas@web ~]$ sudo systemctl status backup
○ backup.service
     Loaded: loaded (/etc/systemd/system/backup.service; static)
     Active: inactive (dead)

Jan 10 11:16:58 web systemd[1]: Starting backup.service...
Jan 10 11:16:58 web tp6_backup.sh[12507]: Backup effectué !
Jan 10 11:16:58 web systemd[1]: backup.service: Deactivated successfully.
Jan 10 11:16:58 web systemd[1]: Finished backup.service.
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

```systemd
[lukas@web ~]$ sudo nano /etc/systemd/system/backup.timer
[Unit]
Description=Run backup service

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

🌞 Activez l'utilisation du *timer*
```bash
[lukas@web ~]$ sudo systemctl daemon-reload
[lukas@web ~]$ sudo systemctl start backup.timer
[lukas@web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[lukas@web ~]$ sudo systemctl status backup.timer
● backup.timer - Run backup service
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor p>     Active: active (waiting) since Tue 2023-01-10 11:21:50 CET; 14s ago
      Until: Tue 2023-01-10 11:21:50 CET; 14s ago
    Trigger: Wed 2023-01-11 04:00:00 CET; 16h left
   Triggers: ● backup.service

Jan 10 11:21:50 web systemd[1]: Started Run backup service.
[lukas@web ~]$ sudo systemctl list-timers
NEXT                        LEFT          LAST                        PASSED       UNIT                         ACTIVATES
Tue 2023-01-10 13:15:10 CET 1h 52min left Tue 2023-01-10 11:21:42 CET 33s ago      dnf-makecache.timer          dnf-makecache.service
Wed 2023-01-11 00:00:00 CET 12h left      Tue 2023-01-10 09:07:55 CET 2h 14min ago logrotate.timer              logrotate.service
Wed 2023-01-11 04:00:00 CET 16h left      n/a                         n/a          backup.timer                 backup.service
Wed 2023-01-11 09:22:59 CET 22h left      Tue 2023-01-10 09:22:59 CET 1h 59min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

4 timers listed.
```
## II. NFS

### 1. Serveur NFS

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

```
[lukas@storage ~]$ sudo mkdir /srv/nfs_shares
[lukas@storage ~]$ sudo chown nobody /srv/nfs_shares/
```
```
[lukas@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux
[lukas@storage ~]$ sudo chown nobody /srv/nfs_shares/web.tp6.linux/
```

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)
```
[lukas@storage ~]$ sudo dnf install nfs-utils -y
```
```
[lukas@storage ~]$ sudo nano /etc/exports
/srv/nfs_shares/web.tp6.linux/    10.105.1.11(rw,sync,no_subtree_check)
```
```
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[lukas@storage ~]$ sudo firewall-cmd --reload
success
[lukas@storage ~]$ sudo firewall-cmd --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
```
[lukas@storage ~]$ sudo systemctl start nfs-server
[lukas@storage ~]$ sudo systemctl status nfs-server | grep Active
     Active: active (exited) since Tue 2023-01-10 11:49:24 CET; 35s ago
```
### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

```
[lukas@web ~]$ sudo mount 10.105.1.14:/srv/nfs_shares/web.tp6.linux/ /srv/backup/
```

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

![Backup everything](../pics/backup_everything.jpg)

# Module 3 : Fail2Ban

Fail2Ban c'est un peu le cas d'école de l'admin Linux, je vous laisse Google pour le mettre en place.

![Fail2Ban](./../pics/fail2ban.png)

C'est must-have sur n'importe quel serveur à peu de choses près. En plus d'enrayer les attaques par bruteforce, il limite aussi l'imact sur les performances de ces attaques, en bloquant complètement le trafic venant des IP considérées comme malveillantes

🌞 Faites en sorte que :

```
[lukas@db ~]$ sudo dnf install epel-release

[lukas@db ~]$ sudo dnf install fail2ban fail2ban-firewalld

[lukas@db ~]$ sudo systemctl start fail2ban
[lukas@db ~]$ sudo systemctl enable fail2ban
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service → /usr/lib/systemd/system/fail2ban.service.

[lukas@db ~]$ sudo systemctl status fail2ban | grep active
     Active: active (running) since Thu 2023-01-12 19:20:58 CET; 3min 52s ago


[lukas@db ~]$ sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
[lukas@db ~]$ sudo nano /etc/fail2ban/jail.local

```
```
[lukas@db ~]$ sudo cat /etc/fail2ban/jail.local | grep maxretry
# A host is banned if it has generated "maxretry" during the last "findtime"
# "maxretry" is the number of failures before a host get banned.
maxretry = 3


[lukas@db ~]$ sudo cat /etc/fail2ban/jail.local | grep bantime
bantime  = 1h

[lukas@db ~]$ sudo cat /etc/fail2ban/jail.local | grep findtime
# A host is banned if it has generated "maxretry" during the last "findtime"
findtime  = 1m



[lukas@db ~]$ sudo systemctl status fail2ban | grep Active
     Active: active (running) since Thu 2023-01-12 19:20:58 CET; 8min ago
```
```
[lukas@web ~]$ ssh lukas@10.105.1.12
lukas@10.105.1.12's password:
Permission denied, please try again.
lukas@10.105.1.12's password:
Permission denied, please try again.
lukas@10.105.1.12's password:
lukas@10.105.1.12: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
[lukas@web ~]$ ssh mat@10.105.1.12
ssh: connect to host 10.105.1.12 port 22: Connection refused
```
```
[lukas@db ~]$ sudo fail2ban-client status sshd | grep Banned
   `- Banned IP list:   10.105.1.11
```
```
[lukas@db ~]$ sudo firewall-cmd --list-all | grep rule
  rich rules:
        rule family="ipv4" source address="10.105.1.11" port port="ssh" protocol="tcp" reject type="icmp-port-unreachable"
```
```
[lukas@db ~]$ sudo fail2ban-client unban 10.105.1.11
1
```
# Module 4 : Monitoring

🌞 **Installer Netdata**

```
[lukas@web ~]$ sudo dnf install epel-release -y

[lukas@web ~]$ wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh

[lukas@web ~]$ sudo systemctl start netdata
[lukas@web ~]$ sudo systemctl enable netdata
[lukas@web ~]$ sudo systemctl status netdata | grep Active
     Active: active (running) since Thu 2023-01-12 21:59:46 CET; 36s ago
[lukas@web ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
success
[lukas@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

```
[lukas@web ~]$ ps -ef | grep netdata | head -n5 | tail -n-1
netdata     2760       1  3 22:02 ?        00:00:10 /usr/sbin/netdata -P /run/netdata/netdata.pid -D


[lukas@web ~]$ sudo ss -ltpnu | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=2760,fd=43))

udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=2760,fd=42))

tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=2760,fd=49))

tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=2760,fd=6))

tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=2760,fd=47))

tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=2760,fd=7))
```

🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 

```
[lukas@web ~]$ sudo nano /etc/netdata/health.d/cpu.conf
alarm: cpu_usage
on: system.cpu
lookup: average -3s percentage foreach user ,system
units: %
every: 10s
warn: $this > 50
crit: $this > 80
info: CPU utilization of users or the system itself.


[lukas@web ~]$ sudo nano /etc/netdata/health.d/ram-usage.conf
 alarm: ram_usage
    on: system.ram
lookup: average -1m percentage of used
 units: %
 every: 1m
  warn: $this > 80
  crit: $this > 90
  info: The percentage of RAM being used by the system.


[lukas@web ~]$ sudo cat /etc/netdata/health_alarm_notify.conf | tail -n 7
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://ptb.discord.com/api/webhooks/1068623772384501942/e4O2Xr_4TFYmCpeUG1B6gvLifGxWrbd-QD4ETkyekxt-un3pvv8oIGO60Gyp1v-W7biO_"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="tp6"
```

🌞 **Vérifier que les alertes fonctionnent**

```
[lukas@web ~]$ sudo dnf install epel-release
[lukas@web ~]$ sudo dnf install stress
```
- stress test

```
[lukas@web ~]$ sudo stress --cpu 8 --vm 2 --vm-bytes 2048M --timeout 10s
stress: info: [2040] dispatching hogs: 8 cpu, 0 io, 2 vm, 0 hdd
stress: FAIL: [2040] (415) <-- worker 2042 got signal 9
stress: WARN: [2040] (417) now reaping child worker processes
stress: FAIL: [2040] (421) kill error: No such process
stress: FAIL: [2040] (451) failed run completed in 11s
```