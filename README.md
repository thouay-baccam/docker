# Documentation Docker RT

## Contexte

Cette documentation détaille les différents jobs Docker exécutés dans un environnement Debian minimal, en ligne de commande, au sein d'une machine virtuelle VMware Workstation configurée en réseau NAT, ce qui explique l’utilisation d’adresses IP locales explicites dans les exemples

Tous les projets sont organisés dans le dossier `~/docker-jobs/`.

---

## Job 01 — Installation de Docker

```bash
sudo apt update
sudo apt install -y docker.io curl
sudo systemctl enable docker
sudo systemctl start docker
```

**Test :**

```bash
sudo docker version
sudo docker info
```

---

## Job 02 — Test de Docker avec hello-world

```bash
sudo docker run hello-world
```

**Test :**

```bash
sudo docker ps -a
```

---

## Job 03 — Création d’une image Docker de test

**Fichier : `Dockerfile`**

```docker
FROM debian:bookworm-slim
RUN apt update && apt install -y curl
CMD echo "Hello, World depuis mon Dockerfile !"
```

**Commandes :**

```bash
sudo docker build -t mon-hello .
sudo docker run mon-hello
```

---

## Job 04 — Conteneur SSH avec accès root

**Fichier : `Dockerfile`**

```docker
FROM debian:bookworm
RUN apt update && apt install -y openssh-server
RUN echo "root:root123" | chpasswd
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
EXPOSE 2222
CMD ["/usr/sbin/sshd", "-D"]
```

**Commandes :**

```bash
sudo docker build -t ssh-custom .
sudo docker run -d -p 2222:22 --name ssh-container ssh-custom
```

**Connexion :**

```bash
ssh root@localhost -p 2222
```

---

## Job 05 — Ajout d'alias utiles dans `.bashrc`

```bash
sudo nano ~/.bashrc
```

**Ajoutez :**

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

## Job 06 — Partage de volume entre conteneurs

```bash
sudo docker volume create partage
sudo docker run -it --name alpine1 -v partage:/data alpine sh
```

Dans le conteneur :

```bash
echo "test volume" > /data/fichier.txt
exit
```

```bash
sudo docker run -it --name alpine2 -v partage:/data alpine sh
```

Dans le conteneur :

```bash
cat /data/fichier.txt
```

---

## Job 07 — Nginx + FTP + FileZilla

**Fichier : `docker-compose.yml`**

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
      PUBLICHOST: 192.168.234.130
    volumes:
      - webdata:/home/ftpusers/user

volumes:
  webdata:
```

**Commandes :**

```bash
sudo docker-compose up -d
```

**Test via navigateur :** `http://192.168.234.130:8080`

**Accès FTP via FileZilla :**

- Hôte : 192.168.234.130
- Port : 2121
- Identifiant : user
- Mot de passe : user123
- Mode passif

---

## Job 08 — Nginx sans image officielle

**Fichier : `Dockerfile`**

```docker
FROM debian:bookworm
RUN apt update && apt install -y nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

**Commandes :**

```bash
sudo docker build -t nginx-perso .
sudo docker run -d -p 8080:8080 nginx-perso
```

**Test :**

```bash
curl http://localhost:8080
```

---

## Job 09 — Registry Docker + UI avec config CORS

**Fichier : `config.yml`**

```yaml
version: 0.1
storage:
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    Access-Control-Allow-Origin:
      - http://192.168.234.130:8081
    Access-Control-Allow-Methods:
      - GET
      - HEAD
      - OPTIONS
    Access-Control-Allow-Headers:
      - Authorization
```

**Commandes :**

```bash
sudo docker run -d -p 5000:5000 \
--name registry \
-v $(pwd)/config.yml:/etc/docker/registry/config.yml \
registry:2

sudo docker run -d -p 8081:80 \
-e REGISTRY_URL=http://192.168.234.130:5000 \
--name registry-ui \
joxit/docker-registry-ui
```

**Push image :**

```bash
sudo docker tag mon-hello localhost:5000/mon-hello
sudo docker push localhost:5000/mon-hello
```

**Accès UI :** http://192.168.234.130:8081

---

## Job 10 — Scripts d'installation et nettoyage

**Fichier : `install_docker.sh`**

```bash
#!/bin/bash
sudo apt update
sudo apt install -y docker.io curl
```

**Fichier : `remove_docker.sh`**

```bash
#!/bin/bash
sudo docker container prune -f
sudo docker image prune -a -f
sudo docker volume prune -f
sudo apt purge -y docker.io
sudo apt autoremove -y
```

**Rendre exécutables :**

```bash
chmod +x install_docker.sh remove_docker.sh
```

---

## Job 11 — Interface Portainer

```bash
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 8000:8000 \
--name portainer \
--restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer_data:/data \
portainer/portainer-ce
```

**Accès UI :** http://192.168.234.130:9000