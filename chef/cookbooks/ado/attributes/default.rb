# frozen_string_literal: true

default['ado-agent']['secrets_dir']    = '/var/data/ado-agent'
default['ado-agent']['secrets_file']   = 'ado.json'
default['ado-agent']['databag']        = 'ado_db_ado_agent'
default['ado-agent']['databagitem']    = 'ado-prd-secrets'
default['ado-agent']['agent-download'] = '/var/local/agent-download'
default['ado-agent']['agent-install']  = '/opt/ado-agent'
default['ado-agent']['agent-user']     = 'ado-agent'
default['ado_agent']['vsts_url']       = 'https://vstsagentpackage.azureedge.net/agent/4.248.0/vsts-agent-linux-x64-4.248.0.tar.gz'
default['ado_agent']['vsts_file']      = 'vsts-agent-linux-x64-4.248.0.tar.gz'
default['pwsh_url']                    = 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/powershell-7.4.5-1.rh.x86_64.rpm'
default['pwsh_file']                   = 'powershell-7.4.5-1.rh.x86_64.rpm'
default['azcli_url']                   = 'https://packages.microsoft.com/yumrepos/azure-cli/Packages/a/azure-cli-2.38.2-1.el7.x86_64.rpm'
default['azcli_file']                  = 'azure-cli-2.38.2-1.el7.x86_64.rpm'
default['authV2_url']                  = 'https://azcliprod.blob.core.windows.net/cli-extensions/authV2-0.1.3-py3-none-any.whl'
default['authV2_file']                 = 'authV2-0.1.3-py3-none-any.whl'
default['nodejs_version']              = 20

case node['platform_family']
when 'debian'
  default['packager']    = 'apt-get'
  default['installer']   = 'dpkg'
when 'rhel', 'fedora'
  default['packager']    = 'dnf'
  default['installer']   = 'dnf'
end
