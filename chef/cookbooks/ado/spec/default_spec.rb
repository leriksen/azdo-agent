require 'spec_helper'

describe 'ado::default' do
  platform 'ubuntu'

  context 'with secrets file' do
    override_attributes['ado-agent']['secrets_dir']  = './spec/fixtures'
    override_attributes['ado-agent']['secrets_file'] = 'good_databag.json'
    override_attributes['ado-agent']['agent-user']   = 'adminuser'

    describe 'includes recipe' do
      it {
        stub_data_bag_item("#node[ado-agent]['databag']", "#node[ado-agent]['databagitem']") do
          JSON.parse(File.read('./spec/fixtures/good_data_bag.json'))
        end

        is_expected.to include_recipe('ado::ado')
      }
    end
  end
end
