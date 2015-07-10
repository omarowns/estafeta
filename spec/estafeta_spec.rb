require 'spec_helper'

describe Estafeta do

  it 'has a version number' do
    expect(Estafeta::VERSION).not_to be nil
  end

  describe 'API' do

    let(:numero_guia_exitoso) { 6659999999061710015592 }
    let(:codigo_rastreo_exitoso) { 1749215347 }

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

    describe 'making HTTP requests' do

      let(:api) { Estafeta::API.new(guia_numero: numero_guia_exitoso) }

      it 'can make a HTTP post to endpoint' do
        expect(api.post).not_to be nil
      end

      it 'saves the resulting POST to an instance variable' do
        api.post
        expect(api.page).not_to be nil
      end
    end
  end
end
