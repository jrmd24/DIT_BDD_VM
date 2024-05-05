#!/bin/bash
yes | sudo apt-get update

yes | sudo apt-get remove docker docker-engine docker.io containerd runc

yes | sudo rm -rf /var/lib/docker
yes | sudo rm -rf /var/lib/containerd

yes | sudo apt-get upgrade


if [[ !(-z "$ENABLE_ZSH")  &&  ($ENABLE_ZSH == "true") ]]
then
    echo "INFO : Installer zsh"
    sudo apt install zsh git
    echo "vagrant" | chsh -s /bin/zsh vagrant
    su - vagrant  -c  'echo "Y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    su - vagrant  -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    sed -i 's/^plugins=/#&/' /home/vagrant/.zshrc
    #echo "plugins=(git  docker docker-compose colored-man-pages aliases copyfile  copypath dotenv zsh-syntax-highlighting jsontools)" >> /home/vagrant/.zshrc
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME='agnoster'/g"  /home/vagrant/.zshrc
  else
    echo "ERROR : zsh n'est pas installe sur le serveur"    
fi

yes | sudo rm -rf /etc/ssh/sshd_config.d/*
sudo service ssh restart

yes | sudo adduser --disabled-password --gecos "" jrmd
yes | sudo echo "jrmd:ditpass" | chpasswd

yes | sudo usermod -aG sudo jrmd


yes | sudo apt-get install ufw

sudo ufw allow 22/tcp
sudo ufw allow 27200:27604/tcp
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow 27200:27604/tcp

