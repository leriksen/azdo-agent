# frozen_string_literal: true

require 'spec_helper'
require 'pathname'

describe 'ado::ado' do
  platform 'ubuntu'

  context 'with secrets file' do
    override_attributes['ado-agent']['secrets_dir']  = './spec/fixtures'
    override_attributes['ado-agent']['secrets_file'] = 'good_databag.json'
    override_attributes['ado-agent']['agent-user']   = 'ado-agent'

    describe 'check overrides' do
      it { is_expected.to write_log('secrets_dir  is ./spec/fixtures') }
      it { is_expected.to write_log('secrets_file is good_databag.json') }
    end

    describe 'check path' do
      it {
        expect(Pathname.new('./spec/fixtures/good_databag.json')).to exist
        expect(Pathname.new('./spec/fixtures/good_databag.json')).to be_file
        expect(Pathname.new('./spec/fixtures')).to be_directory
      }
    end
    context 'ubuntu attributes' do
      # only write tests for attributes that have some logic
      it { is_expected.to write_log('packager     is apt-get') }
    end

    context 'redhat attributes' do
      platform 'redhat'

      # ony write tests for attributes that have some logic
      it { is_expected.to write_log('packager     is dnf') }
    end

    describe 'executes the reset_nodejs_stream' do
      it {
        is_expected.to run_execute('reset_nodejs_stream').with(
          command: 'dnf module reset -y nodejs'
        )
      }
    end

    describe 'executes the enable_nodejs_20_stream' do
      it {
        is_expected.to run_execute('enable_nodejs_20_stream').with(
          command: 'dnf module enable -y nodejs:20'
        )
      }
    end

    packages = %w(
      curl
      git
      gpg
      podman
      nodejs
    )
    packages.each do |package|
      describe "installs #{package} package" do
        it {
          stub_data_bag_item("#node[ado-agent]['databag']", "#node[ado-agent]['databagitem']") do
            JSON.parse(File.read('./spec/fixtures/good_data_bag.json'))
          end

          is_expected.to install_package(package)
        }
      end
    end

    packages = %w(
      newman
    )
    packages.each do |package|
      describe "executes npm install global package #{package}" do
        it {
          is_expected.to run_execute("install_global_npm_package_#{package}").with(
            command: "npm install -g #{package}"
          )
        }
      end
    end

    #     describe 'creates directory for agent download' do
    #       it { is_expected.to create_directory('/var/local/agent-download') }
    #     end
    #
    #     describe 'creates directory for agent install' do
    #       it { is_expected.to create_directory('/opt/ado-agent') }
    #     end
    #
    #     describe 'executes the get-ado-linux-agent' do
    #       it {
    #         is_expected.to run_execute('get-ado-linux-agent').with(
    #           cwd: '/var/local/agent-download',
    #           command: 'curl -LO https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz'
    #         )
    #       }
    #     end
    #
    #     describe 'logs databag' do
    #       it { is_expected.to write_log('databag object is created') }
    #       it { is_expected.to write_log('organization = good_organization') }
    #       it { is_expected.to write_log('pool         = good_pool') }
    #       it { is_expected.to write_log('user         = good_user') }
    #     end
    #
    #     describe 'executes the unconfigure-ado-agent' do
    #       it {
    #         is_expected.to run_execute('unconfigure-ado-agent').with(
    #           user: 'ado-agent',
    #           cwd: '/opt/ado-agent',
    #           command: [
    #             './config.sh',
    #             'remove',
    #             '--unattended',
    #             '--auth pat',
    #             '--token good_pat'
    #           ].join(' ')
    #         )
    #       }
    #     end
    #
    #     describe 'executes the configure-ado-agent' do
    #       it {
    #         is_expected.to run_execute('configure-ado-agent').with(
    #           user: 'ado-agent',
    #           cwd: '/opt/ado-agent',
    #           command: [
    #             './config.sh',
    #             '--unattended',
    #             '--url good_organization',
    #             '--auth pat',
    #             '--token good_pat',
    #             '--acceptTeeEula',
    #             '--pool good_pool',
    #             '--agent Fauxhai',
    #             '--replace'
    #           ].join(' ')
    #         )
    #       }
    #     end
    #
    #     describe 'executes the install-ado-agent-svc' do
    #       it {
    #         is_expected.to run_execute('install-ado-agent-svc').with(
    #           cwd: '/opt/ado-agent',
    #           command: './svc.sh install ado-agent'
    #         )
    #       }
    #     end
    #
    #     describe 'executes the start-ado-agent-svc' do
    #       it {
    #         is_expected.to run_execute('start-ado-agent-svc').with(
    #           cwd: '/opt/ado-agent',
    #           command: './svc.sh start'
    #         )
    #       }
    #     end
    #   end
    #
    #   context 'with databag' do
    #     before do
    #       stub_data_bag_item('ado_db_ado_agent', 'ado-prd-secrets').and_return(
    #         {
    #           organization: 'databag_organization',
    #           pool: 'databag_pool',
    #           user: 'databag_user',
    #           password: 'databag_password',
    #           pat: 'databag_pat'
    #         }
    #       )
    #     end
    #
    #     describe 'check overrides' do
    #       it { is_expected.to write_log('secrets_dir  is /var/data/ado-agent') }
    #       it { is_expected.to write_log('secrets_file is ado.json') }
    #     end
    #
    #     describe 'logs databag' do
    #       it { is_expected.to write_log('native databag is created') }
    #       it { is_expected.to write_log('organization = databag_organization') }
    #       it { is_expected.to write_log('pool         = databag_pool') }
    #       it { is_expected.to write_log('user         = databag_user') }
    #     end
    #     packages = %w[
    #       ca-certificates
    #       curl
    #       gpg
    #       podman
    #     ]
    #     packages.each do |package|
    #       describe "installs #{package} package" do
    #         it {
    #           is_expected.to install_package(package)
    #         }
    #       end
    #     end
    #
    #     describe 'creates directory for agent download' do
    #       it { is_expected.to create_directory('/var/local/agent-download') }
    #     end
    #
    #     describe 'creates directory for agent install' do
    #       it { is_expected.to create_directory('/opt/ado-agent') }
    #     end
    #
    #     describe 'executes the get-ado-linux-agent' do
    #       it {
    #         is_expected.to run_execute('get-ado-linux-agent').with(
    #           cwd: '/var/local/agent-download',
    #           command: 'curl -LO https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz'
    #         )
    #       }
    #     end
    #
    #     describe 'executes the unconfigure-ado-agent' do
    #       it {
    #         is_expected.to run_execute('unconfigure-ado-agent').with(
    #           user: 'ado-agent',
    #           cwd: '/opt/ado-agent',
    #           command: [
    #             './config.sh',
    #             'remove',
    #             '--unattended',
    #             '--auth pat',
    #             '--token databag_pat'
    #           ].join(' ')
    #         )
    #       }
    #     end
    #
    #     describe 'downloads the azure-cli' do
    #       it {
    #         is_expected.to create_remote_file('/var/local/agent-download/azure-cli-2.38.2-1.el7.x86_64.rpm')
    #       }
    #     end
    #
    #     describe 'downloads the authV2 extension' do
    #       it {
    #         is_expected.to create_remote_file('/var/local/agent-download/authV2-0.1.3-py3-none-any.whl')
    #       }
    #     end
    #
    #     describe 'executes the rpm install azure-cli' do
    #       it {
    #         is_expected.to install_rpm_package('azure-cli').with(
    #           package_name: 'azure-cli',
    #           source: '/var/local/agent-download/azure-cli-2.38.2-1.el7.x86_64.rpm'
    #         )
    #       }
    #     end
    #
    #     describe 'executes the authV2 extension install' do
    #       it {
    #         is_expected.to run_execute('install-authV2-extension').with(
    #           cwd: '/var/local/agent-download',
    #           command: [
    #             'az',
    #             'extension',
    #             'add',
    #             '--yes',
    #             '--system',
    #             '--source',
    #             '/var/local/agent-download/authV2-0.1.3-py3-none-any.whl'
    #           ].join(' ')
    #         )
    #       }
    #     end
    #
    #     describe 'executes the configure-ado-agent' do
    #       it {
    #         is_expected.to run_execute('configure-ado-agent').with(
    #           user: 'ado-agent',
    #           cwd: '/opt/ado-agent',
    #           command: [
    #             './config.sh',
    #             '--unattended',
    #             '--url databag_organization',
    #             '--auth pat',
    #             '--token databag_pat',
    #             '--acceptTeeEula',
    #             '--pool databag_pool',
    #             '--agent Fauxhai',
    #             '--replace'
    #           ].join(' ')
    #         )
    #       }
    #     end
    #
    #     describe 'executes the install-ado-agent-svc' do
    #       it {
    #         is_expected.to run_execute('install-ado-agent-svc').with(
    #           cwd: '/opt/ado-agent',
    #           command: './svc.sh install ado-agent'
    #         )
    #       }
    #     end
    #
    #     describe 'executes the start-ado-agent-svc' do
    #       it {
    #         is_expected.to run_execute('start-ado-agent-svc').with(
    #           cwd: '/opt/ado-agent',
    #           command: './svc.sh start'
    #         )
    #       }
    #     end
  end
end
