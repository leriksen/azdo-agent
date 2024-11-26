# frozen_string_literal: true

require_relative '../lib/databag_secrets'

# establish some values for introspection
log "packager     is #{node['packager']}"
log "secrets_dir  is #{node['ado-agent']['secrets_dir']}"
log "secrets_file is #{node['ado-agent']['secrets_file']}"
log "databag      is #{node['ado-agent']['databag']}"
log "databagitem  is #{node['ado-agent']['databagitem']}"

# execute 'package-update' do
#   command "#{node['packager']} upgrade --assumeyes"
# end

# package 'apt-transport-https'
package 'ca-certificates'
package 'curl'
package 'gpg'
package 'podman'
package 'git'
# package 'cntlm'

directory (node['ado-agent']['agent-download']).to_s

execute 'get-ado-linux-agent' do
  command "curl -LO #{node['ado_agent']['vsts_url']}"
  cwd (node['ado-agent']['agent-download']).to_s
end


execute 'get-powershell-core' do
  command "curl -LO #{node['pwsh_url']}"
  cwd (node['ado-agent']['agent-download']).to_s
  creates node['pwsh_file']
end

execute 'install-powershell-core' do
  command "#{node['installer']} install #{node['pwsh_file']} --assumeyes"
  cwd (node['ado-agent']['agent-download']).to_s
  creates '/usr/bin/pwsh'
end

file '/opt/microsoft/powershell/7/profile.ps1' do
  content <<-EOF
    $env:http_proxy  = 'http://localhost:3128'
    $env:https_proxy = 'http://localhost:3128'
  EOF
  mode '0755'
  action :create_if_missing
end

file '/etc/bashrc' do
  content <<-EOF
    $env:http_proxy  = 'http://localhost:3128'
    $env:https_proxy = 'http://localhost:3128'
  EOF
  mode '0755'
  action :create_if_missing
end

if File.exist? "#{node['ado-agent']['secrets_dir']}/#{node['ado-agent']['secrets_file']}"
  log 'databag object is created'
  databag = DatabagSecrets.new "#{node['ado-agent']['secrets_dir']}/#{node['ado-agent']['secrets_file']}"
else
  log 'native databag is created'
  databag = data_bag_item((node['ado-agent']['databag']).to_s, (node['ado-agent']['databagitem']).to_s)
end

log "organization = #{databag['organization']}"
log "pool         = #{databag['pool']}"
log "user         = #{databag['user']}"
log "thing        = #{databag['thing']}"

# might have an already running agent
# stop, remove then reconfigure
execute 'stop-ado-agent-svc' do
  command './svc.sh stop'
  cwd (node['ado-agent']['agent-install']).to_s
  ignore_failure true
end

execute 'uninstall-ado-agent-svc' do
  command './svc.sh uninstall'
  cwd (node['ado-agent']['agent-install']).to_s
  ignore_failure true
end

# might have an already running agent
# stop, remove then reconfigure
execute 'unconfigure-ado-agent' do
  command [
    './config.sh',
    'remove',
    '--unattended',
    '--auth pat',
    "--token #{databag['pat']}"
  ].join(' ')
  cwd (node['ado-agent']['agent-install']).to_s
  user node['ado-agent']['agent-user']
  ignore_failure true
end

directory (node['ado-agent']['agent-install']).to_s do
  action :delete
  recursive true
end

# cleanup for a previous error
user 'ado-agent' do
  action :remove
end

# restore
user 'ado-agent' do
  home '/home/ado-agent'
  manage_home true
  action :create
end

directory (node['ado-agent']['agent-install']).to_s do
  mode '0775'
  owner node['ado-agent']['agent-user']
  group node['ado-agent']['agent-user']
  recursive true
end

execute 'unpack-ado-linux-agent' do
  command [
    "tar zxvf #{node['ado_agent']['vsts_file']} --directory #{node['ado-agent']['agent-install']}"
  ].join(';')
  cwd (node['ado-agent']['agent-download']).to_s
  user node['ado-agent']['agent-user']
end

directory (node['ado-agent']['agent-install']).to_s do
  mode '0775'
  owner node['ado-agent']['agent-user']
  group node['ado-agent']['agent-user']
  recursive true
end

remote_file "#{node['ado-agent']['agent-download']}/#{node['azcli_file']}" do
  source node['azcli_url']
  action :create
end

rpm_package 'azure-cli' do
  package_name 'azure-cli'
  source       "#{node['ado-agent']['agent-download']}/#{node['azcli_file']}"
end

remote_file "#{node['ado-agent']['agent-download']}/#{node['authV2_file']}" do
  source node['authV2_url']
  action :create
end

# cleanup authV2 previous install variants
execute 'uninstall-authV2-extension-user' do
  command [
    'az',
    'extension',
    'remove',
    '--yes',
    '--name',
    'authV2'
  ].join(' ')
  cwd (node['ado-agent']['agent-download']).to_s
  user node['ado-agent']['agent-user']
  ignore_failure true
end

execute 'uninstall-authV2-extension-root' do
  command [
    'az',
    'extension',
    'remove',
    '--yes',
    '--name',
    'authV2'
  ].join(' ')
  cwd (node['ado-agent']['agent-download']).to_s
  ignore_failure true
end

execute 'uninstall-authV2-extension-system' do
  command [
    'az',
    'extension',
    'remove',
    '--yes',
    '--system',
    '--name',
    'authV2'
  ].join(' ')
  cwd (node['ado-agent']['agent-download']).to_s
  ignore_failure true
end

directory '/root/.azure/cliextensions/authV2' do
  action :delete
  recursive true
  ignore_failure true
end

execute 'install-authV2-extension' do
  command [
    'az',
    'extension',
    'add',
    '--yes',
    '--system',
    '--source',
    "#{node['ado-agent']['agent-download']}/#{node['authV2_file']}"
  ].join(' ')
  cwd (node['ado-agent']['agent-download']).to_s
  creates '/usr/lib/python3.6/site-packages/azure-cli-extensions/authV2'
end

execute 'configure-ado-agent' do
  command [
    './config.sh',
    '--unattended',
    "--url #{databag['organization']}",
    '--auth pat',
    "--token #{databag['pat']}",
    '--acceptTeeEula',
    "--pool #{databag['pool']}",
    "--agent #{node['hostname']}",
    '--replace'
  ].join(' ')
  cwd (node['ado-agent']['agent-install']).to_s
  user node['ado-agent']['agent-user']
end

execute 'install-ado-agent-svc' do
  command "./svc.sh install #{node['ado-agent']['agent-user']}"
  cwd (node['ado-agent']['agent-install']).to_s
end

execute 'start-ado-agent-svc' do
  command './svc.sh start'
  cwd (node['ado-agent']['agent-install']).to_s
end
