#!/bin/sh
set -x

if grep Ubuntu /etc/lsb-release; then
    systemctl enable poweroff.target

	sudo apt-get update -y
	sudo apt-get install -y \
        build-essential \
        curl \
        curl \
        git \
        git \
        libffi-dev \
        libssl-dev \
        libxml2-dev \
        libxslt-dev \
        libxslt1-dev \
        open-vm-tools \
        open-vm-tools-dkms \
        python \
        python-dev \
        python-pip \
        rsync \
        sshpass \
        virt-what \
        zlib1g-dev

	sudo apt-get -y autoremove
	sudo apt-get clean
	sudo apt-get autoclean
fi


# install easy_install on the way to ansible
curl https://bootstrap.pypa.io/ez_setup.py | sudo python
sudo easy_install pip
sudo pip install ansible

# install repo
curl https://storage.googleapis.com/git-repo-downloads/repo > /tmp/repo
sudo mv /tmp/repo /bin/repo
sudo chmod a+x /bin/repo

[ -d /opt/chaperone ] || sudo mkdir -p /opt/chaperone
sudo chown root:vmware /opt/chaperone
sudo chmod 775 /opt/chaperone
cd /opt/chaperone
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
repo init -u https://github.com/vmware/chaperone -b master -g chaperone
repo sync

cd /opt/chaperone/ansible/playbooks/ansible
ansible-playbook -i inventory ansible.yml

exit 0