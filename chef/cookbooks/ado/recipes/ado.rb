execute 'package-update' do
  command "apt-get update --yes"
end

package "apt-transport-https"
package "ca-certificates"
package "curl"
package "gpg"

directory "/agent"

execute 'get-ado-linux-agent' do
  command "curl -LO https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz && \
  tar zxvf vsts-agent-linux-x64-3.243.1.tar.gz"
  cwd '/agent'
end

execute 'install-ado-agent' do
  command "./config.sh \
    --unattended \
    --url 'https://dev.azure.com/leiferiksenau' \
    --auth pat \
    --acceptTeeEula \
    --userName 'here' \
    --password 'there'
    --pool 'pool' \
    --agent 'agentname'
  "
  cwd '/agent'
end
