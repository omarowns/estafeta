require 'spec_helper'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

module EstafetaVcr
  def self.api_post
    VCR.use_cassette('estafeta_api_post_successful') do
      yield
    end
  end
end

describe Estafeta do

  it 'has a version number' do
    expect(Estafeta::VERSION).not_to be nil
  end

  describe 'API' do

    let(:numero_guia_exitoso) { 6659999999061710015592 }

    it 'responds to an endpoint variable' do
      expect(Estafeta::API::ENDPOINT).not_to be nil
    end

    it 'has a query instance variable' do
      api = Estafeta::API.new()
      expect(api.query).not_to be nil
    end

    it 'can set the query key guias' do
      api = Estafeta::API.new guia_numero: numero_guia_exitoso
      expect(api.query[:guias]).not_to be nil
      expect(api.query[:guias]).to eq numero_guia_exitoso
    end

    it 'should be more friendly to call' do
      pending "Make it so I dont have to instantiate a class and stuff"
    end

    describe 'making HTTP requests' do

      let(:api) { Estafeta::API.new(guia_numero: numero_guia_exitoso) }

      it 'can make a HTTP post to endpoint' do
        EstafetaVcr.api_post do
          expect(api.post).not_to be nil
        end
      end

      it 'saves the resulting POST to an instance variable' do
        EstafetaVcr.api_post do
          api.post
          expect(api.page).not_to be nil
        end
      end
    end

    describe 'retrieving a doc page' do

      let(:api) { Estafeta::API.new(guia_numero: numero_guia_exitoso) }

      before do
        EstafetaVcr.api_post { api.post }
        api.retrieve_page
      end

      it 'has a doc instance variable' do
        expect(api.doc).not_to be nil
      end

      it 'can parse the web page' do
        expect(api.doc.css('html')).not_to be nil
      end

      it 'parses the web page' do
        api.parse
      end
    end
  end
end
