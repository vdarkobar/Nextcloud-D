<p align="left">
  <a href="https://github.com/vdarkobar/Home-Cloud/blob/main/README.md#create-nextcloud-docker">Home</a>
  <br><br>
</p> 
  
# NextCloud (Docker)
  
Login to <a href="https://dash.cloudflare.com/">CloudFlare</a> and set Domain name, or Domain name and Subdomain for your NextCloud.
```
    A | example.com | YOUR WAN IP
```
or:
```
    A | example.com | YOUR WAN IP
```
```
    CNAME | subdomain | @ (or example.com)
```
Add subdomain *code* for Collabora Office:
```
    CNAME | code | @ (or example.com)
```
  
---
  
#### *Decide what you will use for*:
```
Time Zone, Domain name, Subdomain (if planned),
NextCloud Admin username, NextCloud Admin password,
Collabora username, NextCloud Port Number.
```
  
  
*Change Container names/Port numbers, before executing docker compose up -d for multiple instances.*  
  
  
### *Run this command*:
```
RED='\033[0;31m'; NC='\033[0m'; echo -ne "${RED}Enter directory name: ${NC}"; read NAME; mkdir -p "$NAME"; \
cd "$NAME" && git clone https://github.com/vdarkobar/Nextcloud-D.git . && \
chmod +x setup.sh && \
./setup.sh
```
  
### Log:
```
sudo docker compose logs nextcloud-db
sudo docker compose logs nextcloud
sudo docker compose logs code
sudo docker logs -tf --tail="50" nextcloud-db
sudo docker logs -tf --tail="50" nextcloud
sudo docker logs -tf --tail="50" code
``` 
  
*Follow <i><a href="https://github.com/vdarkobar/home-cloud/blob/main/shared/NC%20Additional%20Settings.md">this link</a></i> for important NextCloud settings.*
