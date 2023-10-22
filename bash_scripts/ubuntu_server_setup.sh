#! /bin/bash

apt upgrade

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


##### Install Docker engine with addons
# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

##### Install Cockpit as server managment tool
sudo apt-get install cockpit -y
sudo systemctl enable --now cockpit.socket
sudo usermod -aG sudo $USER


#### Install Portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=until_stopped -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

### Install firewalld
apt-get -y install firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
ufw disable

crontab -r
### SET Nightly Reboot
SHUTDOWN_JOB="* 3 * * * /sbin/shutdown -r +2"
#if [ ! crontab -l |  grep -q "/sbin/shutdown -r +2"]
#then
   (crontab -l 2>/dev/null; echo "$SHUTDOWN_JOB") | crontab -
#fi


### SET Nighlty Backups
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


BACKUP_SCRIPT="$SCRIPT_DIR/ubuntu_server_backup.sh" 
BACKUP_JOB="* 1 * * * $BACKUP_SCRIPT"


if [ -f "$BACKUP_SCRIPT" ];
  then
    echo "$BACKUP_SCRIPT exists."
    (crontab -l 2>/dev/null; echo "$BACKUP_JOB") | crontab -
   
fi

