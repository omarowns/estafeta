require "estafeta/version"
require 'httparty'
require 'nokogiri'
require 'byebug'

module Estafeta

  class API

    ENDPOINT = 'http://rastreo3.estafeta.com/RastreoWebInternet/consultaEnvio.do'
    attr_reader :query, :page, :doc

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

    def retrieve_page
      @doc = Nokogiri::HTML(@page.body)
    end

    def parse
      rows = @doc.css('form > table tr')
      keys = {
        "Guía"=>"guia",
        "Código de Rastreo"=>"codigo_rastro",
        "Guías envíos múltiples"=>"guia_multiples",
        "Guía documento de retorno"=>"guia_documento",
        "Servicio"=>"servicio",
        "Fecha programada  de entrega"=>"fecha_programada",
        "Guía internacional"=>"guia_internacional",
        "Origen"=>"origen",
        "Fecha de recolección"=>"recoleccion",
        "Destino"=>"destino",
        "CP Destino"=>"cp",
        "Estatus del envío"=>"status",
        "Fecha y hora de entrega"=>"fecha_actual",
        "Recibió"=>'recibio',
        "Tipo de envío"=>"tipo",
        "Dimensiones cm"=>"dimensiones",
        "Peso kg"=>"peso",
        "Peso volumétrico kg"=>"peso_vol",
        "Referencia cliente"=>"referencia",
        "Número de orden de recolección"=>"orden_recoleccion",
        "Orden de Rastreo*"=>"orden_rastreo"
      }

      if rows[1].css('td')[0].text =~ /no hay información disponible/i then
        # Add a no response here
      else
        # Fuuuuuu
      end
    end
  end
end
