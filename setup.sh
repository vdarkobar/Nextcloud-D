#!/bin/bash
clear
RED='\033[0;31m'
echo -ne "${RED}Enter Time Zone: "; read TZONE; \
echo -ne "${RED}Enter Domain name: "; read DNAME; \
echo -ne "${RED}Enter Subdomain with . (dot) at the end, or just press Enter to default to Domain name: "; read SDNAME; \
echo -ne "${RED}Enter Server(VM) Local IP Address: "; read LIP; \
echo -ne "${RED}Enter NextCloud Admin username: "; read NCUNAME; \
echo -ne "${RED}Enter Collabora username: "; read CUNAME; \
echo -ne "${RED}Enter NextCloud Port Number (NCPORTN:80): "; read NCPORTN; \
sed -i "s|01|${TZONE}|" .env && \
sed -i "s|02|${DNAME}|" .env && \
sed -i "s|03|${SDNAME}|" .env && \
sed -i "s|04|${LIP}|" .env && \
sed -i "s|05|${CUNAME}|" .env && \
sed -i "s|06|${NCPORTN}|" .env && \
echo ${NCUNAME} > secrets/nc_admin_user.secret && \
echo | openssl rand -base64 20 > secrets/nc_admin_password.secret && \
TOKEN=$(openssl rand -base64 20); sed -i "s|CHANGE_PASS|${TOKEN}|" .env && \
echo | openssl rand -base64 48 > secrets/mysql_root_password.secret && \
echo | openssl rand -base64 20 > secrets/nc_mysql_password.secret && \
sudo chown -R root:root secrets/ && \
rm README.md && \
sudo chmod -R 600 secrets/ && \
while true; do
    read -p "Execute 'docker-compose up -d' now? (y/n)" yn
    case $yn in
        [Yy]* ) sudo docker compose up -d; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
