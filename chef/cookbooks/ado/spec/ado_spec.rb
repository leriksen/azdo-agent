require 'spec_helper'
require 'pathname'

describe "ado::ado" do
  platform 'ubuntu'

  context 'with secrets file' do
    override_attributes['ado-agent']['secrets_dir']  = './spec/fixtures'
    override_attributes['ado-agent']['secrets_file'] = 'good_databag.json'

    describe 'check overrides' do
      it { is_expected.to write_log("secrets_dir  is ./spec/fixtures") }
      it { is_expected.to write_log("secrets_file is good_databag.json") }
    end

    describe 'check path' do
      it{
        expect(Pathname.new("./spec/fixtures/good_databag.json")).to exist
        expect(Pathname.new("./spec/fixtures/good_databag.json")).to be_file
        expect(Pathname.new("./spec/fixtures")).to be_directory
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

    packages = %w(
      apt-transport-https
      ca-certificates
      curl
      gpg
      podman
    )
    packages.each do |package|
      describe "installs #{package} package" do

        it {
          stub_data_bag_item("#node[ado-agent]['databag']", "#node[ado-agent]['databagitem']") {
            JSON.parse(File.read('./spec/fixtures/good_data_bag.json'))
          }

          is_expected.to install_package(package)
        }
      end
    end

    describe 'creates directory for agent download' do
      it { is_expected.to create_directory('/var/local/agent-download') }
    end

    describe 'creates directory for agent install' do
      it { is_expected.to create_directory('/opt/ado-agent') }
    end

    describe 'executes the get-ado-linux-agent' do
      it { is_expected.to run_execute('get-ado-linux-agent').with(
        cwd:     '/var/local/agent-download',
        command: 'curl -LO https://vstsagentpackage.azureedge.net/agent/3.243.1/vsts-agent-linux-x64-3.243.1.tar.gz &&   tar zxvf vsts-agent-linux-x64-3.243.1.tar.gz --directory /opt/ado-agent'
      ) }
    end

    describe 'logs databag' do
      it { is_expected.to write_log("databag object is created")}
      it { is_expected.to write_log("organization = good_organization")}
      it { is_expected.to write_log("pool         = good_pool"        )}
    end

    describe 'executes the install-ado-agent' do
      it { is_expected.to run_execute('install-ado-agent').with(
        cwd:     '/opt/ado-agent',
        command: "./config.sh     --unattended     --url good_organization     --auth pat     --token good_pat     --acceptTeeEula     --pool good_pool     --agent Fauxhai"
      ) }
    end

    describe 'executes the run-ado-agent' do
      it { is_expected.to run_execute('run-ado-agent').with(
        cwd:     '/opt/ado-agent',
        command: "./run.sh"
      ) }
    end
  end

  context 'with databag' do
    # do these later
  end

end

