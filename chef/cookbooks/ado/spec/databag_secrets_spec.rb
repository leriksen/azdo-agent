# frozen_string_literal: true

require './lib/databag_secrets'

describe DatabagSecrets do
  context 'good databag' do
    databag = DatabagSecrets.new './spec/fixtures/good_databag.json'

    context 'hash' do
      it 'handles a key' do
        expect(databag['organization']).to eq('good_organization')
      end
    end
  end

  context 'bad databag' do
    it 'rejects incorrect databag secret files' do
      expect do
        DatabagSecrets.new './spec/fixtures/bad_databag.json'
      end.to raise_error(DatabagSecrets::BadSecrets,
                         './spec/fixtures/bad_databag.json is missing required fields')
    end
  end

  context 'bad json' do
    it 'rejects incorrect json files' do
      expect { DatabagSecrets.new './spec/fixtures/bad_json.json' }.to raise_error(JSON::ParserError)
    end
  end

  # fix later
  context 'no file' do
    xit 'handles no file' do
      expect { DatabagSecrets.new './no_file.json' }.to raise_error(DatabagSecrets::BadSecrets)
    end
  end
end
