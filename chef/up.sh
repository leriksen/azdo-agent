export fq=$(az network public-ip show -g azdo-agent -n public | jq -r '.ipAddress')
echo "${fq}"
rsync -zavuh -e ssh ./cookbooks "adminuser@${fq}":~
ssh "adminuser@${fq}" -i ~/.ssh/id_rsa "sudo chef-client -zr 'recipe[ado]'"
