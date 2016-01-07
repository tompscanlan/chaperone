# Testing Chaperone in a vPOD

* create a vpod based on chaperone-v1
* attach the vpod to the public network

## Prepare the vpod
* On your laptop:
```
mkdir chaperone
cd chaperone
repo init -u https://github.com/vmware/chaperone -b master -g chaperone
repo sync

cd ansible/playbooks/chaperone-vpod

# add vpod public address to the inventory file:
cat << EOF > inventory
[router]
1.2.3.4 ansible_user=vmware ansible_ssh_pass=VMware1! ansible_become_pass=VMware1!
EOF
```




cd ansible/playbooks/devops-pipeline

# add the chaperone server into hosts file
cat << EOF >> /etc/hosts
10.153.252.254 chaperone chaperone.corp.local chaperone-ui.corp.local chaperone-ui chaperone-admin-ui.corp.local chaperone-admin-ui
EOF

# add chaperone CDS to the inventory file:
cat << EOF > inventory
[chaperone]
chaperone.corp.local ansible_port=19022 ansible_user=vmware ansible_ssh_pass=VMware1! ansible_become_pass=VMware1!
EOF

ansible-playbook vpod.yml -i inventory

cd ../chaperone-ui
ansible-playbook -i inventory site.yml
ansible-playbook -i inventory -e 'sshkeys_remote_group=vmware' -e 'sshkeys_user=vmware' site.yml -v
ansible-playbook -i inventory -e 'sshkeys_remote_group=vmware' -e 'sshkeys_user=vmware' -e 'new_priv_key=/Users/tscanlan/.ssh/chaperone.key' base.yml


```
