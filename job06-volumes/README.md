
---

### 📁 `job06-volumes`

```markdown
# Job 06 — Volume partagé

```bash
sudo docker volume create partage
sudo docker run -it --name alpine1 -v partage:/data alpine sh

Dans Alpine1 : 
echo "test volume" > /data/fichier.txt
exit

Puis : 
sudo docker run -it --name alpine2 -v partage:/data alpine sh
cat /data/fichier.txt
