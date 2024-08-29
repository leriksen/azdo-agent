default['ado-agent']['secrets_dir']    = '/var/data/ado-agent'
default['ado-agent']['secrets_file']   = 'ado.json'
default['ado-agent']['databag']        = 'ado_db_ado_agent'
default['ado-agent']['databagitem']    = 'ado-prd-secrets'
default['ado-agent']['agent-download'] = '/var/local/agent-download'
default['ado-agent']['agent-install']  = '/opt/ado-agent'

case node['platform_family']
when 'debian'
  default['packager'] = 'apt-get'
when 'rhel', 'fedora'
  default['packager'] = 'dnf'
end
