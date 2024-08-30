export fq=$(az network public-ip show -g azdo-agent -n public | jq -r '.ipAddress')
echo "${fq}"
knife bootstrap "adminuser@${fq}" --node-name ado --ssh-identity-file ~/.ssh/id_rsa --yes --sudo
rsync -zavuh -e ssh ./cookbooks "adminuser@${fq}":~
ssh "adminuser@${fq}" -i ~/.ssh/id_rsa "sudo mkdir -p /var/data/ado-agent; sudo cp cookbooks/ado/databags/ado.json /var/data/ado-agent/ado.json"
ssh "adminuser@${fq}" -i ~/.ssh/id_rsa "sudo chef-client -zr 'recipe[ado]'"
