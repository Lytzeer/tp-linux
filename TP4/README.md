# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**
```
[lukas@storage ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[lukas@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[lukas@storage ~]$ sudo lvcreate -l 100%FREE storage -n storage-TP4
  Logical volume "storage-TP4" created.
```
🌞 **Formater la partition**
```
[lukas@storage ~]$ sudo mkfs -t ext4 /dev/storage/storage-TP4
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: ccdd5e82-ea4b-43be-9a72-acf6502913ad
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
🌞 **Monter la partition**
```
[lukas@storage ~]$ sudo mkdir /storage
[lukas@storage ~]$ sudo mount /dev/storage/storage-TP4 /storage/
[lukas@storage ~]$ df -h | grep 'storage'
/dev/mapper/storage-storage--TP4  2.0G   24K  1.9G   1% /mnt/storage
[lukas@storage ~]$ sudo vim /etc/fstab
/dev/storage/storage-TP4 /mnt/storage ext4 defaults 0 0
[lukas@storage ~]$ sudo umount /storage/
[lukas@storage /]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/storage                 : successfully mounted
```
# Partie 2 : Serveur de partage de fichiers
🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**
``` 
[lukas@storage ~]$ sudo mkdir /storage/site_web_1
[lukas@storage ~]$ sudo mkdir /storage/site_web_2 
[lukas@storage ~]$ sudo mkdir /var/nfs/general -p
[lukas@storage ~]$ sudo nano /etc/exports
/storage 10.4.1.21(rw,sync,no_root_squash,no_subtree_check)
[lukas@storage ~]$ cat /etc/exports
/storage 10.4.1.21(rw,sync,no_root_squash,no_subtree_check)
[lukas@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[lukas@storage ~]$ sudo systemctl start nfs-server
[lukas@storage ~]$ systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; v>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2022-12-06 14:41:46 CET; 1min 3s ago
    Process: 1335 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0>
    Process: 1336 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCE>
    Process: 1353 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; >
   Main PID: 1353 (code=exited, status=0/SUCCESS)
        CPU: 14ms

Dec 06 14:41:46 storage systemd[1]: Starting NFS server and services...
Dec 06 14:41:46 storage systemd[1]: Finished NFS server and services.
[lukas@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client ssh
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[lukas@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[lukas@storage ~]$ sudo firewall-cmd --reload
success
[lukas@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**
```
[lukas@web ~]$ sudo mkdir /var/www/site_web_1 -p
[lukas@web ~]$ sudo mkdir /var/www/site_web_2 -p
[lukas@web ~]$ sudo mount 10.4.1.20:/storage/site_web_1 /var/www/site_web_1
[lukas@web ~]$ sudo mount 10.4.1.20:/storage/site_web_2 /var/www/site_web_2
[lukas@web ~]$ df -h | grep storage
10.4.1.20:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
10.4.1.20:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
[lukas@web ~]$ sudo nano /etc/fstab
[lukas@web ~]$ cat /etc/fstab | grep storage
10.4.1.20:/storage/site_web_1 /var/www/site_web_1 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.4.1.20:/storage/site_web_2 /var/www/site_web_2 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
[lukas@web ~]$ sudo umount /var/www/site_web_1
[lukas@web ~]$ sudo umount /var/www/site_web_2
[lukas@web ~]$ df -h | grep storage
```
# Partie 3 : Serveur web
🌞 **Installez NGINX**

```
[lukas@web ~]$ sudo dnf install nginx
[lukas@web ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[lukas@web ~]$ sudo systemctl start nginx
```
🌞 **Analysez le service NGINX**

```
[lukas@web ~]$ ps -ef | grep nginx
lukas      11723    1188  0 15:26 pts/0    00:00:00 grep --color=auto nginx
[lukas@web ~]$ sudo ss -alnpt4 | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11780,fd=6),("nginx",pid=11779,fd=6))
[lukas@web ~]$ cat /etc/nginx/nginx.conf | grep /html
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;
[lukas@web ~]$ ls -l /usr/share/nginx/html/
total 12
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec  6 15:16 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

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

🌞 **Accéder au site web**

```
[lukas@web ~]$ curl http://10.4.1.21 | head
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/
```

🌞 **Vérifier les logs d'accès**

```
[lukas@web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
10.4.1.1 - - [06/Dec/2022:15:41:30 +0100] "GET /icons/poweredby.png HTTP/1.1" 200 15443 "http://10.4.1.21/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 OPR/92.0.0.0" "-"
10.4.1.1 - - [06/Dec/2022:15:41:30 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.4.1.21/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 OPR/92.0.0.0" "-"
10.4.1.1 - - [06/Dec/2022:15:41:30 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://10.4.1.21/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36 OPR/92.0.0.0" "-"
```

🌞 **Changer le port d'écoute**

```
[lukas@web ~]$ sudo nano /etc/nginx/nginx.conf
        listen       8080;
        listen       [::]:8080
```
```
[lukas@web ~]$ sudo systemctl restart nginx
```
```
[lukas@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor pre>
     Active: active (running) since Tue 2022-12-06 15:48:31 CET; 21s ago
    Process: 11874 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, sta>
    Process: 11875 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCE>
    Process: 11876 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 11877 (nginx)
      Tasks: 2 (limit: 4638)
     Memory: 1.9M
        CPU: 11ms
     CGroup: /system.slice/nginx.service
             ├─11877 "nginx: master process /usr/sbin/nginx"
             └─11878 "nginx: worker process"
```
```
[lukas@web ~]$ sudo ss -alnpt4 | grep nginx
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=11878,fd=6),("nginx",pid=11877,fd=6))
```
```
[lukas@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[lukas@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
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
  ports: 22/tcp 8080/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
```
[lukas@web ~]$ curl http://10.4.1.21:8080 | head -n 7
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

🌞 **Changer l'utilisateur qui lance le service**
```
[lukas@web ~]$ sudo useradd web -m
[lukas@web ~]$ sudo passwd web
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
[lukas@web ~]$ sudo nano /etc/nginx/nginx.conf
[lukas@web ~]$ cat /etc/nginx/nginx.conf | grep web
user web;
[lukas@web ~]$ sudo systemctl restart nginx
[lukas@web ~]$ ps -ef | grep web | grep nginx
web        12019   12018  0 16:04 ?        00:00:00 nginx: worker process
```
🌞 **Changer l'emplacement de la racine Web**

```
[lukas@web ~]$ sudo nano /var/www/site_web_1/index.html
<h1>Hello There !</h1>
[lukas@web ~]$ sudo nano /etc/nginx/nginx.conf
[lukas@web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1/;
[lukas@web ~]$ sudo systemctl restart nginx
[lukas@web ~]$ curl http://10.4.1.21:8080
<h1>Hello There !</h1>
```
🌞 **Repérez dans le fichier de conf**
```
[lukas@web ~]$ cat /etc/nginx/nginx.conf | grep /conf.d/
    include /etc/nginx/conf.d/*.conf;
```
🌞 **Créez le fichier de configuration pour le premier site**

```
[lukas@web ~]$ sudo nano /etc/nginx/conf.d/site_web_1.conf
    server {
        listen       8080;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_1/;

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

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[lukas@web ~]$ sudo nano /etc/nginx/conf.d/site_web_2.conf
    server {
        listen       8888;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_2/;

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
[lukas@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[lukas@web ~]$ sudo firewall-cmd --reload
success
```
🌞 **Prouvez que les deux sites sont disponibles**
```
[lukas@web ~]$ curl http://10.4.1.21:8080
<h1>Hello There !</h1>
[lukas@web ~]$ curl http://10.4.1.21:8888
<h1>I'm the boss</h1>
```