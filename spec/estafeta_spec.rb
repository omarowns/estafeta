require 'spec_helper'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

module EstafetaVcr
  def self.post
    VCR.use_cassette('estafeta_post_successful') do
      yield
    end
  end
end

describe Estafeta do

  it 'has a version number' do
    expect(Estafeta::VERSION).not_to be nil
  end

  describe 'Standard' do

    let(:numero_guia) { 8058606738655781217161 }

    it 'responds to an endpoint variable' do
      expect(Estafeta::Standard::ENDPOINT).not_to be nil
    end

    it 'has a key-value mapping' do
      expect(Estafeta::Standard::KEYS).not_to be nil
    end

    it 'has a query instance variable' do
      std = Estafeta::Standard.new()
      expect(std.query).not_to be nil
    end

    it 'can set the query key guias' do
      std = Estafeta::Standard.new guia_numero: numero_guia
      expect(std.query[:guias]).not_to be nil
      expect(std.query[:guias]).to eq numero_guia
    end

    describe 'making HTTP requests' do

      let(:std) { Estafeta::Standard.new(guia_numero: numero_guia) }

      it 'can make a HTTP post to endpoint' do
        EstafetaVcr.post do
          expect(std.post).not_to be nil
        end
      end

      it 'saves the resulting POST to an instance variable' do
        EstafetaVcr.post do
          std.post
          expect(std.page).not_to be nil
        end
      end
    end

    describe 'retrieving a doc page' do

      let(:std) { Estafeta::Standard.new(guia_numero: numero_guia) }

      before do
        EstafetaVcr.post { std.post }
        std.retrieve_page
      end

      it 'has a doc instance variable' do
        expect(std.doc).not_to be nil
      end

      it 'can parse the web page' do
        expect(std.doc.css('html')).not_to be nil
      end

      it 'parses the web page' do
        expect(std.parse).not_to be nil
      end

      it 'returns a json object' do
        std.parse
        expect(std.json).not_to be nil
        expect(std.json.class).to eq Hash
      end

      context 'with a package in transit' do
        let(:numero_guia_en_transito) { 8058606738655781217161 }
        let(:std) { Estafeta::Standard.new(guia_numero: numero_guia_en_transito) }

        before do
          EstafetaVcr.post { std.post }
          std.retrieve_page
          std.parse
        end

        it 'completes OK' do
          pending "Add a STATUS to the Class"
        end
      end
    end
  end
end
