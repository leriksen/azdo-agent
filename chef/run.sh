#!/usr/bin/env bash

set -euo pipefail

# mange.chfe.io is misbehaving - install chef-client directly
# knife bootstrap "adminuser@ado.australiasoutheast.cloudapp.azure.com" --node-name ado --ssh-identity-file ~/.ssh/id_rsa --yes --sudo
rsync -zavuh -e ssh ~/downloads/chef-14.15.6-1.el7.x86_64.rpm "adminuser@ado.australiasoutheast.cloudapp.azure.com":~
rsync -zavuh -e ssh ./cookbooks "adminuser@ado.australiasoutheast.cloudapp.azure.com":~
ssh "adminuser@ado.australiasoutheast.cloudapp.azure.com" -i ~/.ssh/id_rsa "sudo dnf install -y ./chef-14.15.6-1.el7.x86_64.rpm"
ssh "adminuser@ado.australiasoutheast.cloudapp.azure.com" -i ~/.ssh/id_rsa "sudo mkdir -p /var/data/ado-agent; sudo chmod 777 /var/data/ado-agent"
rsync -zavuh -e ssh ./cookbooks/ado/databags/ado.json "adminuser@ado.australiasoutheast.cloudapp.azure.com":/var/data/ado-agent/ado.json
ssh "adminuser@ado.australiasoutheast.cloudapp.azure.com" -i ~/.ssh/id_rsa "sudo chef-client -zr 'recipe[ado]'"
