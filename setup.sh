#!/bin/bash

clear

######################################################
# Define ANSI escape sequences for colors and reset  #
######################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


#################
# Intro message #
#################

echo
echo -e "${GREEN} Before you begin:${NC}"
echo
echo -e "${GREEN} Login to${NC} CloudFlare ${GREEN}and set Domain name, or Domain name and Subdomain for your NextCloud:${NC}"
echo
echo "        A   | example.com | YOUR WAN IP"
echo
echo -e "${GREEN} or:${NC}"
echo
echo "        A   | example.com | YOUR WAN IP"
echo
echo "      CNAME |  subdomain  | @ (or example.com)"
echo
echo
echo -e "${GREEN} Add subdomain${NC} code ${GREEN}for Collabora Office:${NC}"
echo
echo "      CNAME |     code    | @ (or example.com)"
echo
echo 
echo -e "${GREEN} Decide what you will use for:${NC}"
echo
echo "      - Time Zone, NextCloud Admin username, NextCloud Admin password, NextCloud Port Number."
echo
echo

while true; do
    echo -e "${GREEN} Continue? ${NC} (yes/no)"
    echo
    read choice
    echo

    # Convert choice to lowercase
    choice=${choice,,} # This makes the script case insensitive

    # Check if user entered "yes"
    if [[ "$choice" == "yes" || "$choice" == "y" ]]; then

        # Execute first command and echo -e message when done
        echo
        clear
        echo -e "${GREEN} Executing script... ${NC}"
        echo
        break

    # If user entered "no"
    elif [[ "$choice" == "no" || "$choice" == "n" ]]; then
        echo -e "${RED} Aborting script. ${NC}"
        exit

    # If user entered anything else, ask them to correct it
    else
        echo
        echo -e "${YELLOW} Invalid input. Please enter${NC} 'yes' or 'no'"
    fi
done

###########################################
# Function for displaying status messages #
###########################################

status_message() {
  local status="$1"  # "success", "error"
  local message="$2"
  local color="${GREEN}" # Default to success (green)

  if [[ $status == "error" ]]; then
    color="${RED}"
  fi

  echo -e "${color}${message}${NC}"
}


#########################################
# Function to check command exit status #
#########################################

check_exit_status() {
  if [[ $1 -ne 0 ]]; then
    status_message "error" "$2"
    exit 1
  fi
}


#######################################################
# Start the installation of Docker and Docker Compose #
#######################################################

echo
echo -e "${GREEN}Starting the installation of Docker and Docker Compose (v2)...${NC}"
echo

# Update apt package index
sudo apt-get update
check_exit_status $? "Failed to update apt package index."

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release
check_exit_status $? "Failed to install prerequisites."

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
check_exit_status $? "Failed to add Docker GPG key."

# Set up the Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
check_exit_status $? "Failed to set up the Docker repository."

# Update the apt package index again
sudo apt-get update
check_exit_status $? "Failed to update package index after setting up the repository."

# Install Docker Engine, CLI, containerd, and Compose plugin
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_exit_status $? "Failed to install Docker."

# Verify installation
sudo docker --version && docker compose version
check_exit_status $? "Docker installation might have issues."

clear
echo
echo -e "${GREEN}Docker and Docker Compose(v2) installation completed successfully.${NC}"
echo


#############
# Nextcloud #
#############

# Prompt user for input
echo -ne "${GREEN}Enter Time Zone (e.g. Europe/Berlin):${NC} "; read TZONE;
echo
# Check if the entered time zone is valid
TZONES=$(timedatectl list-timezones) # Get list of time zones
VALID_TZ=0 # Flag to check if TZONE is valid
for tz in $TZONES; do
    if [[ "$TZONE" == "$tz" ]]; then
        VALID_TZ=1 # The entered time zone is valid
        break
    fi
done

# Prompt user until a valid time zone is entered
while [[ $VALID_TZ -eq 0 ]]; do
    echo -e "${RED}Invalid Time Zone. Please enter a valid time zone (e.g., Europe/Berlin).${NC}"
    echo
    echo -ne "${GREEN}Enter Time Zone:${NC} "; read TZONE;
    for tz in $TZONES; do
        if [[ "$TZONE" == "$tz" ]]; then
            VALID_TZ=1 # The entered time zone is valid
            break
        fi
    done
done

echo -ne "${GREEN}Enter Domain name (e.g. example.com): ${NC}"; read DNAME
echo
echo -ne "${GREEN}Enter Subdomain with . (dot) at the end, or just press Enter to default to Domain name: ${NC}"; read SDNAME
echo
echo -ne "${GREEN}Enter NextCloud Admin username: ${NC}"; read NCUNAME
echo
read -s -p "Enter Nextcloud Admin password: " NAPASS
echo
echo
echo -ne "${GREEN}Enter Collabora username: ${NC}"; read CUNAME
echo
echo -ne "${GREEN}Enter NextCloud Port Number(49152-65535):${NC} "; read NCPORTN;
# Check if the port number is within the specified range
while [[ $NCPORTN -lt 49152 || $NCPORTN -gt 65535 ]]; do
    echo -e "${RED}Port number is out of the allowed range. Please enter a number between 49152 and 65535.${NC}"
    echo -ne "${GREEN}Enter NPM Port Number(49152-65535):${NC} "; read NCPORTN;
done
echo
# Get the primary local IP address of the machine more reliably
LIP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')

# Update .env file with user input, checking for errors
sed -i "s|01|${TZONE}|" .env || { echo -e "${RED}Failed to update Time Zone in .env file.${NC}"; exit 1; }
sed -i "s|02|${DNAME}|" .env || { echo -e "${RED}Failed to update Domain Name in .env file.${NC}"; exit 1; }
sed -i "s|03|${SDNAME}|" .env || { echo -e "${RED}Failed to update Subdomain in .env file.${NC}"; exit 1; }
sed -i "s|04|${LIP}|" .env || { echo -e "${RED}Failed to update Local IP Address in .env file.${NC}"; exit 1; }
sed -i "s|05|${CUNAME}|" .env || { echo -e "${RED}Failed to update Collabora username in .env file.${NC}"; exit 1; }
sed -i "s|06|${NCPORTN}|" .env || { echo -e "${RED}Failed to update NextCloud Port Number in .env file.${NC}"; exit 1; }

# Generate and store secrets, ensuring .secrets directory exists before generating secrets
mkdir -p .secrets || { echo -e "${RED}Failed to create secrets directory.${NC}"; exit 1; }

echo $NCUNAME > .secrets/nc_admin_user.secret || { echo -e "${RED}Failed to store NextCloud admin username.${NC}"; exit 1; }
echo $NAPASS > .secrets/nc_admin_password.secret || { echo -e "${RED}Failed to store NextCloud admin password.${NC}"; exit 1; }
echo $CUNAME > .secrets/collabora_admin_user.secret || { echo -e "${RED}Failed to store Collabora admin username.${NC}"; exit 1; }
sed -i "s|CHANGE_ME|${NAPASS}|" .env || { echo -e "${RED}Failed to update .env file with NextCloud admin password.${NC}"; exit 1; }
echo | openssl rand -base64 48 > .secrets/mysql_root_password.secret || { echo -e "${RED}Failed to generate MySQL root password.${NC}"; exit 1; }
echo | openssl rand -base64 20 > .secrets/nc_mysql_password.secret || { echo -e "${RED}Failed to generate NextCloud MySQL password.${NC}"; exit 1; }

# Update permissions
sudo chown -R root:root .secrets/ && sudo chmod -R 600 .secrets/ || { echo -e "${RED}Failed to update secrets directory permissions.${NC}"; exit 1; }

# Clean up, with checks for existence
[[ -f README.md ]] && rm README.md

# Main loop for docker compose up command
while true; do
    echo -ne "${GREEN}Execute docker compose now?${NC} (yes/no) "; read yn
    echo
    yn=$(echo "$yn" | tr '[:upper:]' '[:lower:]') # Convert input to lowercase
    case $yn in
        yes )
            if ! sudo docker compose up -d; then
                echo -e "${RED}Docker compose up failed. Check docker and docker compose installation.${NC}"
                exit 1
            fi
            break;;
        no ) exit;;
        * ) echo -e "${RED}Please answer${NC} yes or no";;
    esac
done


#######
# UFW #
#######
echo
echo -e "${GREEN}Preparing firewall for local access...${NC}"
sleep 0.5 # delay for 0.5 seconds
echo

# Use the PORTN variable for the UFW rule
sudo ufw allow "${NCPORTN}/tcp" comment "Nextcloud custom port"
sudo systemctl restart ufw
echo


##########
# Access #
##########
clear
echo -e "${GREEN}Access Nextcloud instance at${NC}"
sleep 0.5 # delay for 0.5 seconds

# Get the primary local IP address of the machine more reliably
LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
# Get the short hostname directly
HOSTNAME=$(hostname -s)
# Use awk more efficiently to extract the domain name from /etc/resolv.conf
DOMAIN_LOCAL=$(awk '/^search/ {print $2; exit}' /etc/resolv.conf)
# Directly concatenate HOSTNAME and DOMAIN, leveraging shell parameter expansion for conciseness
LOCAL_DOMAIN="${HOSTNAME}${DOMAIN_LOCAL:+.$DOMAIN_LOCAL}"

# Display access instructions
echo
echo -e "${GREEN} Local access:${NC} $LOCAL_IP:$NCPORTN"
echo -e "${GREEN}             :${NC} $LOCAL_DOMAIN:$NCPORTN"
echo
echo -e "${GREEN} External access:${NC} $SDNAME$DNAME"
echo
echo
echo -e "${GREEN} Set Collabora Office url in the Nextcloud office app:${NC} https://code.$DNAME"
echo -e "${RED} Configure Reverse proxy (NPM) for external access.${NC}"
echo


#####################################
# Remove the Script from the system #
#####################################
echo
echo -e "${RED} This Script Will Self Destruct!${NC}"
echo
# VERY LAST LINE OF THE SCRIPT:
rm -- "$0"
