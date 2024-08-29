require './lib/databag_secrets'

describe DatabagSecrets do
  context 'good databag' do
    databag = DatabagSecrets.new './spec/fixtures/good_databag.json'

    it 'builds a new instance' do
      expect(databag).to be_an_instance_of(DatabagSecrets)
    end

    it 'expects pat' do
      expect(databag.pat).to eq('good_pat')
    end

    it 'expects organization' do
      expect(databag.organization).to eq('good_organization')
    end

    it 'expects pool' do
      expect(databag.pool).to eq('good_pool')
    end

    it 'expects agentName' do
      expect(databag.agentName).to eq('good_agentName')
    end
  end

  context 'bad databag' do
    it 'rejects incorrect databag secret files' do
      expect { DatabagSecrets.new './spec/fixtures/bad_databag.json' }.to raise_error(DatabagSecrets::BadSecrets, './spec/fixtures/bad_databag.json is missing required fields')
    end
  end

  context 'bad json' do
    it 'rejects incorrect json files' do
      expect { DatabagSecrets.new './spec/fixtures/bad_json.json' }.to raise_error(JSON::ParserError)
    end
  end
end
