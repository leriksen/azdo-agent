# frozen_string_literal: true

default['ado-agent']['secrets_dir']    = '/var/data/ado-agent'
default['ado-agent']['secrets_file']   = 'ado.json'
default['ado-agent']['databag']        = 'ado_db_ado_agent'
default['ado-agent']['databagitem']    = 'ado-prd-secrets'
default['ado-agent']['agent-download'] = '/var/local/agent-download'
default['ado-agent']['agent-install']  = '/opt/ado-agent'
default['ado-agent']['agent-user']     = 'ado-agent'
default['ado_agent']['vsts_url']       = 'https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz'
default['ado_agent']['vsts_file']      = 'vsts-agent-linux-x64-3.243.1.tar.gz'

case node['platform_family']
when 'debian'
  default['packager']  = 'apt-get'
  default['installer'] = 'dpkg'
  default['pwsh_url']  = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell_7.4.5-1.deb_amd64.deb'
  default['pwsh_file'] = 'powershell_7.4.5-1.deb_amd64.deb'
when 'rhel', 'fedora'
  default['packager']  = 'dnf'
  default['installer'] = 'dnf'
  default['pwsh_url']  = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell-7.4.5-1.rh.x86_64.rpm'
  default['pwsh_file'] = 'powershell-7.4.5-1.rh.x86_64.rpm'
end
