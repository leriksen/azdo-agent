require_relative '../lib/databag_secrets'

# establish some values for introspection
log "packager     is #{node['packager']}"
log "secrets_dir  is #{node['ado-agent']['secrets_dir']}"
log "secrets_file is #{node['ado-agent']['secrets_file']}"
log "databag      is #{node['ado-agent']['databag']}"
log "databagitem  is #{node['ado-agent']['databagitem']}"

execute 'package-update' do
  command "apt-get update --yes"
end

package "apt-transport-https"
package "ca-certificates"
package "curl"
package "gpg"

directory "#{node['ado-agent']['agent-download']}"
directory "#{node['ado-agent']['agent-install']}"

execute 'get-ado-linux-agent' do
  command "curl -LO https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz && \
  tar zxvf vsts-agent-linux-x64-3.243.1.tar.gz --directory #{node['ado-agent']['agent-install']}"
  cwd "#{node['ado-agent']['agent-download']}"
end

if File.exist? "#{node['ado-agent']['secrets_dir']}/#{node['ado-agent']['secrets_file']}"
  log "databag_object is created"
  databag      = DatabagSecrets.new "#{node['ado-agent']['secrets_dir']}/#{node['ado-agent']['secrets_file']}"
else
  log "native databag is created"
  databag      = data_bag_item("#node['ado-agent']['databag']", "#{node['ado-agent']['databagitem']}")
end

log "pat          = #{databag.pat}"
log "organization = #{databag.organization}"
log "pool         = #{databag.pool}"

execute 'install-ado-agent' do
  command "./config.sh \
    --unattended \
    --url #{databag.organization} \
    --auth pat \
    --token #{databag.pat} \
    --acceptTeeEula \
    --pool #{databag.pool} \
    --agent #{node['hostname']}"
  cwd "#{node['ado-agent']['agent-install']}"
end

# replace with svc creation later
execute 'run-ado-agent' do
  command "./run.sh"
  cwd "#{node['ado-agent']['agent-install']}"
end
