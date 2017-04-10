Chaperone Setup
===============
Development and deployment of Chaperone tools require two VMs based on
[VMware Photon OS](https://vmware.github.io/photon) or
[Ubuntu Linux 64-bit](http://www.ubuntu.com/download/server):

- **Development Environment (DE)** is the environment where the source code is
  downloaded, modified and built. This could be your laptop. In this document it will
  be an external ubuntu machine. See the
  [devbox setup](https://github.com/vmware/ansible-playbooks-chaperone/blob/master/devbox)
  for more automated means of setting up on Photon OS or a Mac.
  
- **Chaperone Deployment Server (CDS)** is the build target for the development environment.
  All ansible playbooks will run from this machine, so its placement in the network
  physically and with regard to security rules should allow direct access to the machines
  being operated on. 

### Worth repeating:
To simply build and deploy the Chaperone GUI(s), any Ubuntu 64-bit
instance is sufficient. However, in order to run the Chaperone and to set
up the vCenter environment, the CDS must have access to, or be installed
within, the vCenter Server environment. Additional information on
deployment options and vCenter Server requirements is available [here](env.md)


Getting Started
---------------

## Setting up the Chaperone Deployment Server

### Assumptions
- For a CDS server built from an Ubuntu Linux 64-bit machine

### Add a vmware user
    sudo adduser vmware
    sudo adduser vmware sudo

### Get the IP address of the CDS:

If the CDS is running in the same environment as the DE, simply get the
ip address:

    ip address

If the CDS is running in a vCenter environment and the DE is not, the
CDS will need to be exposed through an external ip. See [Environments](env.md)


## Setting up the Development Environment

### Assumptions
- The DE is an Ubuntu Linux 64-bit machine

### Add a vmware user
    sudo adduser vmware
    sudo adduser vmware sudo

*Complete the rest of the steps as the vmware user*

### Setup For Github Access

Install [google repo](https://source.android.com/source/downloading.html) in the
development environment

Install and configure git

    sudo apt-get install git
    git config --global user.email "your@email.com"
    git config --global user.name "Your Name"

Where your email and name are replaced with those associated with your github id

*Note: Be aware that the ansible playbooks that setup the DE will
create ssh keys and place them in the default location (~/.ssh/id_rsa)
for the vmware user.*

### Install Ansible
Run these commands on the DE server:

    sudo apt-get install -y python-pip python-dev
    sudo easy_install pip
    sudo pip install ansible

*Note: If an existing environment is being used and ansible has been installed
through other means, it may be necessary to remove it and reinstall using pip.*

### Pull the Chaperone Code to the DE
Once Gerrit access is working, you can pull the code base on to your
development host:

```
mkdir chaperone
cd chaperone
repo init -u https://github.com/vmware/chaperone -b master -g chaperone
repo sync
```

### Setup the DE with basic tools

For a non-X11 based, pure terminal VM with vim installed:

```
cd ansible/playbooks/ansible
ansible-playbook --ask-sudo-pass -i inventory ansible.yml
```

For a setup with LXDE (X11) and the Geany editor:

```
cd ansible/playbooks/ansible
ansible-playbook --ask-sudo-pass -i inventory ansible-lxde.yml
```

### Setup the DE /etc/hosts with the CDS IP address

Chaperone requires a DNS resolvable address for
chaperone servers. In case you cannot obtain one, add a line in the
`/etc/hosts` file within the DE server with the following:

```
CDS_IP_ADDRESS chaperone-ui.corp.local chaperone-admin-ui.corp.local
```

where CDS_IP_ADDRESS is the actual dotted quad address of the CDS.

#### Special Note about Domains:

The default domain name for most things Chaperone is "corp.local" for
development VMs or containers. However, at times (arguably often) work
will occur on remote vCenter server environments, which generally use a
other domain names (such as "corp.local").

Given that, take care to understand the actual domain names your DNS server
serves in the event it is providing local domains, for example,
chaperone-ui.corp.local.

### Assure Ansible Inventory file correctness:

An example inventory file for Ansible playbook runs within the
[ansible-playbooks-chaperone](https://github.com/vmware/ansible-playbooks-chaperone.git)
project runs generally exist at "examples/inventory" in that project. You can
reference that directly in the ansible-playbook runs as in:

```
ansible-playbook -i examples/inventory someplaybook.yml
```

If you need to modify the inventory you can just copy that file to the
playbooks directory where you will run ansible-playbook, for example from within the
path "ansible/playbooks/chaperone-ui" within your repo synced work area:

```
cp examples/inventory .
```

You can then modify the copied inventory for your local modifications. There
is a .gitignore file in place that will ignore your changes when committing
code, so you need not worry about others getting affected by your changes.

An example for modifying the inventory file might be where your CDS is exposed
on a port other the 22 for SSH access. In that case you would need to add the
port to the inventory file in playbook project that will be built.

For example, the file (assuming ~/chaperone is your working tree for repo sync),
the file:

```
~/chaperone/ansible/playbooks/chaperone-ui/inventory
```

would contain your local modification to contain something similar to:

```
[chaperone-ui]
chaperone-ui.corp.local ssh_port=8422
```

so that thereafter playbook runs will use port 8422 when connecting via SSH.

*See http://docs.ansible.com/ansible/intro_inventory.html for more details on special
considerations of the inventory file.*


#### Special Note about Variables:

There are variables in some of the playbooks, and inventory files, that
require care and attention if the target environment has a domain
different from the default.

## Deploy the CDS GUIs and tools

To setup the Chaperone UI on the CDS, run the following playbooks from the DE: 

```
cd ~/chaperone/ansible/playbooks/chaperone-ui

# be sure to update the inventory and /etc/hosts files to
# use the correct address of the CDS
ansible-playbook -i examples/inventory site.yml
```


## Configure and deploy

Chaperone is a tool that allows for creating a multitude of user interfaces
by adding ansible templates. Each Chaperone tool is accessed through a
descriptive DNS name in the format "(XXX)-ui.corp.local" where XXX might be
something like "mycooltool", sddc or even something as simple as cna to denote
the package configuration the tool you want to create and later deploy.
Entries for each tool deployed need to either be added to the /etc/hosts or in
the dns table of the system running the browser that accesses the application.

Open a browser to http://(XXX)-ui.corp.local and
http://(XXX)-admin-ui.corp.local, thereafter you should see the Web UIs.
Fill in the forms with environment specific data, and 'Save' will store the
answers in an answerfile.yml later used by the ansible playbooks.

Alternatively, you can create an answerfile.yml by cutting and pasting the
contents of a sample file into the answerfile.yml located at /var/lib/(XXX)
on the Chaperone Deployment server.

TODO: Link to sample answer files for each package tool

## Next Step: Running the Chaperone Tool
See [Running Chaperone](run.md)
