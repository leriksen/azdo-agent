rsync -zavuh -e ssh ./cookbooks "adminuser@ado.australiasoutheast.cloudapp.azure.com":~
ssh "adminuser@ado.australiasoutheast.cloudapp.azure.com" -i ~/.ssh/id_rsa "sudo chef-client -zr 'recipe[ado]'"
