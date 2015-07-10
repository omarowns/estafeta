require 'httparty'
require 'nokogiri'
require 'byebug'

module Estafeta

  class Standard

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
      "CP Destino": "cp",
      "Código de rastreo": "codigo_rastreo",
      "Destino": "destino",
      "Dimensiones cm": "dimensiones",
      "Estatus del envío": "status",
      "Estatus del servicio": "servicio_status"
      "Fecha de recolección": "recoleccion",
      "Fecha programada de entrega": "fecha_programada",
      "Fecha y hora de entrega": "fecha_actual",
      "Guía documento de retorno": "guia_documento",
      "Guía internacional": "guia_internacional",
      "Guías envíos múltiples": "guia_multiples",
      "Número de guía": "guia",
      "Número de orden de recolección": "orden_recoleccion",
      "Orden de Rastreo*": "orden_rastreo",
      "Origen": "origen",
      "Peso kg": "peso",
      "Peso volumétrico kg": "peso_vol",
      "Recibió": 'recibio',
      "Referencia cliente": "referencia",
      "Servicio": "servicio",
      "Tipo de envío": "tipo",
    }

    if rows[1].css('td').text =~ /no hay información disponible/i then
        # Add a no response here
    else
      # Fuuuuuu
      info = {}
      rows.each do |row|

        titulos = row.css('td.titulos')
        respuestas = row.css('td.respuestas')
      end
      byebug
    end

  end # End parse
end
