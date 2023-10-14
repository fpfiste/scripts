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

### SET Nightly Reboot
(crontab -l 2>/dev/null; echo "* 3 * * * /sbin/shutdown -r +2") | crontab -

### SET Nighlty Backups
FILE= ./ubuntu_server_backup.sh
if test -f "$FILE"; then
    echo "$FILE exists."
fi
