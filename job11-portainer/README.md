
---

### 📁 `job11-portainer`

```markdown
# Job 11 — Portainer

```bash
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -p 8000:8000 \\
--name portainer \\
--restart=always \\
-v /var/run/docker.sock:/var/run/docker.sock \\
-v portainer_data:/data \\
portainer/portainer-ce

Accès via navigateur : 
http://192.168.234.130:9000
