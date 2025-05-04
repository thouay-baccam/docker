
---

### 📁 `job05-aliases`

```markdown
# Job 05 — Aliases Docker

Éditez votre `.bashrc` :
```bash
sudo nano ~/.bashrc

Puis ajoutez :

alias dps='sudo docker ps -a'
alias drm='sudo docker rm'
alias drmi='sudo docker rmi'
alias db='sudo docker build -t'
alias dex='sudo docker exec -it'

Et rechargez : 

source ~/.bashrc
