# TP2 : Appréhender l'environnement Linux

# I. Service SSH

## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**
```
[lukas@TP2linux ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-11-22 15:31:13 CET; 12min ago
```
🌞 **Analyser les processus liés au service SSH**

```
[lukas@TP2linux ~]$ ps -ef | grep sshd
root         708       1  0 15:31 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         849     708  0 15:32 ?        00:00:00 sshd: lukas [priv]
lukas        854     849  0 15:32 ?        00:00:00 sshd: lukas@pts/0
lukas        912     855  0 15:48 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**
```
[lukas@TP2linux ~]$ sudo ss -alnpt |grep sshd

LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=708,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=708,fd=4))
```

🌞 **Consulter les logs du service SSH**

```
[lukas@TP2linux ~]$ journalctl -xe -u sshd |tail -n 10
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit sshd.service has finished successfully.
░░
░░ The job identifier is 229.
Nov 22 15:32:43 TP2linux unix_chkpwd[851]: password check failed for user (lukas)
Nov 22 15:32:43 TP2linux sshd[849]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=10.4.1.1  user=lukas
Nov 22 15:32:45 TP2linux sshd[849]: Failed password for lukas from 10.4.1.1 port 58293 ssh2
Nov 22 15:32:51 TP2linux sshd[849]: Accepted password for lukas from 10.4.1.1 port 58293 ssh2
Nov 22 15:32:51 TP2linux sshd[849]: pam_unix(sshd:session): session opened for user lukas(uid=1000) by (uid=0)
```
```
[lukas@TP2linux ~]$ sudo cat /var/log/secure | grep sshd | tail -n 10
Nov 22 15:21:19 localhost sshd[707]: Server listening on :: port 22.
Nov 22 15:24:05 localhost sshd[708]: Server listening on 0.0.0.0 port 22.
Nov 22 15:24:05 localhost sshd[708]: Server listening on :: port 22.
Nov 22 15:31:13 TP2linux sshd[708]: Server listening on 0.0.0.0 port 22.
Nov 22 15:31:13 TP2linux sshd[708]: Server listening on :: port 22.
Nov 22 15:32:43 TP2linux sshd[849]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=10.4.1.1  user=lukas
Nov 22 15:32:45 TP2linux sshd[849]: Failed password for lukas from 10.4.1.1 port 58293 ssh2
Nov 22 15:32:51 TP2linux sshd[849]: Accepted password for lukas from 10.4.1.1 port 58293 ssh2
Nov 22 15:32:51 TP2linux sshd[849]: pam_unix(sshd:session): session opened for user lukas(uid=1000) by (uid=0)
Nov 22 15:58:04 TP2linux sudo[926]:   lukas : TTY=pts/0 ; PWD=/home/lukas ; USER=root ; COMMAND=/bin/journalctl -xe -u sshd
```

## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**
```
[lukas@TP2linux ~]$ ls /etc/ssh/ | grep sshd
sshd_config
sshd_config.d
```
🌞 **Modifier le fichier de conf**

  ```
  [lukas@TP2linux ~]$ echo $RANDOM

  6180
  ```
  ```
  [lukas@TP2linux ~]$ sudo cat /etc/ssh/sshd_config | grep "Port "

  Port 6180
  ```
  ```
  [lukas@TP2linux ~]$ sudo firewall-cmd --remove-port=22/tcp

  success
  ```
  ```
  [lukas@TP2linux ~]$ sudo firewall-cmd --add-port=6180/tcp --permanent

  success
  ```
  ```
  [lukas@TP2linux ~]$ sudo firewall-cmd --add-port=6180/tcp

  success
  ```
  ```
  [lukas@TP2linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports

  ports: 6180/tcp
  ```

🌞 **Redémarrer le service**
```
[lukas@TP2linux ~]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**
```
PS C:\WINDOWS\system32> ssh lukas@10.4.1.12 -p 6180
lukas@10.4.1.12's password:
Last login: Tue Nov 22 16:18:18 2022 from 10.4.1.1
[lukas@TP2linux ~]$
```
✨ **Bonus : affiner la conf du serveur SSH**
```
[lukas@TP2linux ~]$ sudo nano /etc/ssh/sshd_config

PermitRootLogin no
```
```
[lukas@TP2linux ~]$  sudo systemctl restart sshd
```
# II. Service HTTP

## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**
```
[lukas@TP2linux ~]$ sudo dnf install nginx -y
```

🌞 **Démarrer le service NGINX**
```
[lukas@TP2linux ~]$ sudo systemctl enable nginx

Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[lukas@TP2linux ~]$ sudo systemctl start nginx
```
```
[lukas@TP2linux ~]$ sudo systemctl start nginx
```
🌞 **Déterminer sur quel port tourne NGINX**
```
[lukas@TP2linux ~]$ sudo ss -alpnt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1422,fd=6),("nginx",pid=1421,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1422,fd=7),("nginx",pid=1421,fd=7))
```
>Le service tourne sur le port 80
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=80/tcp

success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=80/tcp --permanent

success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports

ports: 22/tcp 80/tcp
```
🌞 **Déterminer les processus liés à l'exécution de NGINX**
```
[lukas@TP2linux ~]$ ps -ef | grep nginx
root        1421       1  0 16:38 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1422    1421  0 16:38 ?        00:00:00 nginx: worker process
lukas       1450    1190  0 16:43 pts/0    00:00:00 grep --color=auto nginx
```
🌞 **Euh wait**
```bash
$ curl 10.4.1.12:80 | head -n 7
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```
## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[lukas@TP2linux ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 May 16  2022 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**
```
[lukas@TP2linux ~]$ cat /etc/nginx/nginx.conf | grep -m 1 "server {" -A 16
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```
```
[lukas@TP2linux ~]$ cat /etc/nginx/nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**
```
[lukas@TP2linux ~]$ sudo mkdir /var/www
```
```
[lukas@TP2linux ~]$ sudo mkdir /var/www/tp2_linux
```
```
[lukas@TP2linux ~]$ sudo touch /var/www/tp2_linux/index.hmtl
```
```
[lukas@TP2linux ~]$ sudo nano /var/www/tp2_linux/index.html

<h1>MEOW mon premier serveur web</h1>
```
🌞 **Adapter la conf NGINX**
```
[lukas@TP2linux ~]$ echo $RANDOM

27815
```
```
[lukas@TP2linux ~]$ sudo nano /etc/nginx/conf.d/tp2.conf

server {
  listen 27815;

  root /var/www/tp2_linux;
}
```
```
[lukas@TP2linux ~]$ sudo systemctl restart nginx
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=27815/tcp --permanent

success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=27815/tcp 

success
```
```
[lukas@TP2linux ~]$ sudo systemctl restart firewalld
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --remove-port=80/tcp 

success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --reload

success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports

ports: 22/tcp 27815/tcp
```
🌞 **Visitez votre super site web**
```bash
lukas@DESKTOP-URQ404I MINGW64 ~
$ curl 10.4.1.12:27815

<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

## 1. Au cas où vous auriez oublié

## 2. Analyse des services existants
🌞 **Afficher le fichier de service SSH**
```
[lukas@TP2linux ~]$ systemctl status sshd

#On peut récupérer grâce à cette commande l'emplacement du fichier du service sshd (/usr/lib/systemd/system/sshd.service).

● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-11-26 14:59:45 CET; 4min 18s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 696 (sshd)
      Tasks: 1 (limit: 5907)
     Memory: 5.6M
        CPU: 50ms
     CGroup: /system.slice/sshd.service
             └─696 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Nov 26 14:59:44 tp2-linux systemd[1]: Starting OpenSSH server daemon...
Nov 26 14:59:44 tp2-linux sshd[696]: Server listening on 0.0.0.0 port 16341.
Nov 26 14:59:44 tp2-linux sshd[696]: Server listening on :: port 16341.
Nov 26 14:59:45 tp2-linux systemd[1]: Started OpenSSH server daemon.
Nov 26 15:02:03 tp2-linux sshd[913]: Accepted password for mat from 10.4.1.1 port 61306 ssh2
```
```
[lukas@TP2linux ~]$ sudo cat /usr/lib/systemd/system/sshd.service | grep ExecStart

ExecStart=/usr/sbin/sshd -D $OPTIONS
```
🌞 **Afficher le fichier de service NGINX**
```
[lukas@TP2linux ~]$ sudo cat /usr/lib/systemd/system/nginx.service | grep ExecStart=

#Qaund on démarre le service nginx on exécute la commande suivante: /usr/sbin/nginx

ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**
```
[lukas@TP2linux ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[sudo] password for lukas:
```
```service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 8888
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=8888/tcp
success
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
```
```
[lukas@TP2linux ~]$ sudo systemctl restart firewalld
```
```
[lukas@TP2linux ~]$ sudo firewall-cmd --list-all | grep 13923
  ports: 22/tcp 27815/tcp 8888/tcp
```
🌞 **Indiquer au système qu'on a modifié les fichiers de service**
```
[lukas@TP2linux ~]$ sudo systemctl daemon-reload
```
🌞 **Démarrer notre service de ouf**

```
[lukas@TP2linux ~]$ sudo systemctl start tp2_nc
```
🌞 **Vérifier que ça fonctionne**
```
[lukas@TP2linux ~]$ systemctl status tp2_nc

● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Sat 2022-11-26 15:25:35 CET; 1min 28s ago
   Main PID: 1023 (nc)
      Tasks: 1 (limit: 5907)
     Memory: 776.0K
        CPU: 3ms
     CGroup: /system.slice/tp2_nc.service
             └─1023 /usr/bin/nc -l 8888

Nov 26 15:25:35 tp2-linux systemd[1]: Started Super netcat tout fou.
```
```
[lukas@TP2linux ~]$ sudo ss -alnpt | grep 8888

LISTEN 0      10           0.0.0.0:8888      0.0.0.0:*    users:(("nc",pid=1023,fd=4))                 
LISTEN 0      10              [::]:8888         [::]:*    users:(("nc",pid=1023,fd=3))   

```
🌞 **Les logs de votre service**
```
[lukas@TP2linux ~]$ sudo journalctl -xe -u tp2_nc | grep start
░░ Subject: A start job for unit tp2_nc.service has finished successfully
```
```
[lukas@TP2linux ~]$ sudo journalctl -xe -u tp2_nc | grep "test"
░░ Nov 26 15:26:22 tp2 nc[1023]: test
```
```
[lukas@TP2linux ~]$ sudo journalctl -xe -u tp2_nc | grep exit
░░ Nov 26 15:28:41 tp2 systemd[1]: tp2_nc.service: Failed with result 'exit-code'.
```
🌞 **Affiner la définition du service**

```
[lukas@TP2linux ~]$ sudo nano /etc/systemd/system/tp2_nc.service
```
```
[lukas@TP2linux ~]$ sudo systemctl daemon-reload
```
```
[lukas@TP2linux ~]$ journalctl -xe -u tp2_nc

Nov 27 13:09:44 tp2-linux systemd[1]: tp2_nc.service: Scheduled restart job, restart counter is at 1.
░░ Subject: Automatic restarting of a unit has been scheduled
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ Automatic restarting of the unit tp2_nc.service has been scheduled, as the result for
░░ the configured Restart= setting for the unit..
```