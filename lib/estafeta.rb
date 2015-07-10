require "estafeta/version"
require 'httparty'

module Estafeta

  class API

    ENDPOINT = 'http://rastreo3.estafeta.com/RastreoWebInternet/consultaEnvio.do'
    attr_reader :query, :page

    def initialize(guia_numero: '')
      @query = {
        method: '',
        forward:  '',
        idioma: 'es',
        pickUpId: '',
        dispatch: 'doRastreoInternet',
        tipoGuia: 'ESTAFETA',
        guias: guia_numero,
        'image.x' => '55',
        'image.y' => '10'
      }
    end

    def post
      @page = HTTParty.post(ENDPOINT, :body => @query)
    end
  end
end
