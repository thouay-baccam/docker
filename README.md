# Docker Jobs 01 à 12 - README complet (Debian minimale)

Ce README regroupe toutes les instructions pas-à-pas pour mettre en place les jobs Docker 01 à 12 sur une VM Debian minimaliste (ex. en NAT avec VMware). Il inclut les commandes, tests et résultats attendus, avec l'adresse IP `172.16.1.141`.

---

## 🚀 JOB 01 — Installation Docker + Docker Compose

```bash
mkdir -p ~/docker-jobs/job01-installation
cd ~/docker-jobs/job01-installation

sudo apt update
sudo apt install -y docker.io curl
sudo systemctl enable docker
sudo systemctl start docker
```

### Installer Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Test

```bash
sudo docker version
sudo docker info
docker-compose version
```

---

## 🧰 JOB 02 — Hello World

```bash
mkdir ~/docker-jobs/job02-hello-world
cd ~/docker-jobs/job02-hello-world
sudo docker run hello-world
```

### Résultat attendu

```
Hello from Docker!
```

---

## 📝 JOB 03 — mon-hello (Dockerfile)

```bash
mkdir ~/docker-jobs/job03-helloworld
cd ~/docker-jobs/job03-helloworld
```

**Dockerfile** :

```Dockerfile
FROM debian:bookworm-slim
RUN apt update && apt install -y curl
CMD echo "Hello, World depuis mon Dockerfile !"
```

```bash
sudo docker build -t mon-hello .
sudo docker run mon-hello
```

---

## 🔐 JOB 04 — SSH root container

```bash
mkdir ~/docker-jobs/job04-ssh
cd ~/docker-jobs/job04-ssh
```

**Dockerfile** :

```Dockerfile
FROM debian:bookworm
RUN apt update && apt install -y openssh-server
RUN echo "root:root123" | chpasswd
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D"]
```

```bash
sudo docker build -t ssh-custom .
sudo docker run -d -p 2222:22 --name ssh-container ssh-custom
```

### Test SSH

```bash
ssh root@localhost -p 2222
# Mot de passe : root123
```

---

## ⚙️ JOB 05 — Aliases Docker

```bash
mkdir ~/docker-jobs/job05-aliases
cd ~/docker-jobs/job05-aliases
sudo nano ~/.bashrc
```

**Ajouter :**

```bash
alias dps='sudo docker ps -a'
alias drm='sudo docker rm'
alias drmi='sudo docker rmi'
alias db='sudo docker build -t'
alias dex='sudo docker exec -it'
```

```bash
source ~/.bashrc
```

---

## 🔀 JOB 06 — Volume partagé

```bash
mkdir ~/docker-jobs/job06-volumes
cd ~/docker-jobs/job06-volumes

sudo docker volume create partage
```

```bash
sudo docker run -it --name alpine1 -v partage:/data alpine sh
# echo "volume test" > /data/test.txt
exit

sudo docker run -it --name alpine2 -v partage:/data alpine sh
# cat /data/test.txt
```

---

## 🌍 JOB 07 — Nginx + FTP + FileZilla

```bash
mkdir ~/docker-jobs/job07-nginx-ftp
cd ~/docker-jobs/job07-nginx-ftp
```

**docker-compose.yml** :

```yaml
version: '3'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
    volumes:
      - webdata:/usr/share/nginx/html

  ftp:
    image: stilliard/pure-ftpd
    ports:
      - "2121:21"
      - "30000-30009:30000-30009"
    environment:
      FTP_USER_NAME: user
      FTP_USER_PASS: user123
      FTP_USER_HOME: /home/ftpusers/user
      ADDED_FLAGS: "--passiveportrange 30000:30009"
      PUBLICHOST: 172.16.1.141
    volumes:
      - webdata:/home/ftpusers/user

volumes:
  webdata:
```

```bash
sudo docker-compose up -d
```

### Accès

* FTP : FileZilla → `172.16.1.141:2121` (user/user123)
* Web : [http://172.16.1.141:8080](http://172.16.1.141:8080)

---

## 🌐 JOB 08 — Nginx personnalisé

```bash
mkdir ~/docker-jobs/job08-nginx-custom
cd ~/docker-jobs/job08-nginx-custom
```

**Dockerfile :**

```Dockerfile
FROM debian:bookworm
RUN apt update && apt install -y nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

```bash
sudo docker build -t nginx-perso .
sudo docker run -d -p 8080:8080 nginx-perso
```

---

## 📦 JOB 09 — Docker Registry + UI (avec CORS)

```bash
mkdir -p ~/docker-jobs/job09-registry/config
cd ~/docker-jobs/job09-registry/config
```

**config.yml** :

```yaml
version: 0.1
storage:
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    Access-Control-Allow-Origin:
      - http://172.16.1.141:8081
    Access-Control-Allow-Methods:
      - GET
      - HEAD
      - OPTIONS
    Access-Control-Allow-Headers:
      - Authorization
```

```bash
cd ..
sudo docker run -d -p 5000:5000 \
--name registry \
-v $(pwd)/config/config.yml:/etc/docker/registry/config.yml \
registry:2

sudo docker run -d -p 8081:80 \
-e REGISTRY_URL=http://172.16.1.141:5000 \
-e SINGLE_REGISTRY=true \
--name registry-ui \
joxit/docker-registry-ui
```

**Test :**

```bash
sudo docker tag mon-hello localhost:5000/mon-hello
sudo docker push localhost:5000/mon-hello
curl http://localhost:5000/v2/_catalog
```

---

## 🚼 JOB 10 — Scripts Docker

```bash
mkdir ~/docker-jobs/job10-scripts
cd ~/docker-jobs/job10-scripts
```

**install\_docker.sh**

```bash
#!/bin/bash
sudo apt update
sudo apt install -y docker.io curl
```

**remove\_docker.sh**

```bash
#!/bin/bash
sudo docker container prune -f
sudo docker image prune -a -f
sudo docker volume prune -f
sudo apt purge -y docker.io
sudo apt autoremove -y
```

```bash
chmod +x install_docker.sh remove_docker.sh
```

---

## 🖥️ JOB 11 — Installer Portainer (interface Web Docker)

```bash
mkdir ~/docker-jobs/job11-portainer
cd ~/docker-jobs/job11-portainer

sudo docker volume create portainer_data

sudo docker run -d -p 9000:9000 -p 8000:8000 \
--name portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
portainer/portainer-ce
```

### Accès Web :

```
http://172.16.1.141:9000
```

---

## 📀 JOB 12 — Stack XAMPP : PHP + MariaDB + phpMyAdmin + FTP

```bash
mkdir -p ~/docker-jobs/job12-xampp/www
cd ~/docker-jobs/job12-xampp
```

**docker-compose.yml** :

```yaml
version: '3.8'

services:
  php:
    image: php:8.2-apache
    ports:
      - "8082:80"
    volumes:
      - ./www:/var/www/html

  db:
    image: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: testdb
      MYSQL_USER: user
      MYSQL_PASSWORD: userpass
    volumes:
      - db_data:/var/lib/mysql

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    ports:
      - "8083:80"
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: rootpass

  ftp:
    image: stilliard/pure-ftpd
    ports:
      - "2122:21"
      - "31000-31009:31000-31009"
    environment:
      FTP_USER_NAME: user
      FTP_USER_PASS: user123
      FTP_USER_HOME: /home/ftpusers/user
      ADDED_FLAGS: "--passiveportrange 31000:31009"
      PUBLICHOST: 172.16.1.141
    volumes:
      - ./www:/home/ftpusers/user

volumes:
  db_data:
```

**Test PHP :**

```bash
echo "<?php phpinfo(); ?>" > www/index.php
sudo docker-compose up -d
```

**Accès :**

* PHP : [http://172.16.1.141:8082](http://172.16.1.141:8082)
* phpMyAdmin : [http://172.16.1.141:8083](http://172.16.1.141:8083)
* FTP : 172.16.1.141:2122 (user/user123, mode passif)

---

Fin ✔️
