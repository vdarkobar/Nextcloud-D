<p align="left">
  <a href="https://github.com/vdarkobar/home-cloud">Home</a>
  <br><br>
</p> 
  
# NextCloud 
  
Login to <a href="https://dash.cloudflare.com/">CloudFlare</a>, add *Subdomain* for your *NextCloud*. 
```
    CNAME | subdomain | @ (or example.com)
```
Add subdomain *code* for Collabora Office:
```
    CNAME | code | @ (or example.com)
```
#### *No need to add A record to put NextCloud on your Root Domain (already set by Argo Tunnel), just skip this step, including CNAME creation.*
  
---
  
#### *Decide what you will use for*:
```
Time Zone, Domain name, Subdomain (if planned),
Local IP Address, NextCloud Admin username,
Collabora username, NextCloud Port Number.
```
  
  
*Change Container names/Port numbers, before executing docker-compose up -d, if multiple instances are planed.*  
  
  
### *Run this command*:
```
RED='\033[0;31m'; echo -ne "${RED}Enter directory name: "; read NAME; mkdir -p "$NAME"; \
cd "$NAME" && git clone https://github.com/vdarkobar/NC.git . && \
chmod +x setup.sh && \
./setup.sh
```
  
### Log:
```
sudo docker-compose logs nextcloud-db
sudo docker-compose logs nextcloud
sudo docker-compose logs code
sudo docker logs -tf --tail="50" nextcloud-db
sudo docker logs -tf --tail="50" nextcloud
sudo docker logs -tf --tail="50" code
``` 
  
### Follow <i><a href="https://github.com/vdarkobar/home-cloud/blob/main/shared/NC%20Additional%20Settings.md">this link</a></i> for important NextCloud settings.
