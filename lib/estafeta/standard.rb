require 'httparty'
require 'nokogiri'

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
        "Estatus del servicio": "servicio_status",
        "Fecha de recolección": "fecha_recoleccion",
        "Fecha programada  de entrega": "fecha_programada",
        "Fecha y hora de entrega": "fecha_actual",
        "Guía documento de retorno": "guia_documento",
        "Guía internacional": "guia_internacional",
        "Guías envíos múltiples": "guia_multiples",
        "Número de guía": "guia",
        "Número de orden de recolección": "orden_recoleccion",
        "Orden de rastreo*": "orden_rastreo",
        "Origen": "origen",
        "Peso kg": "peso",
        "Peso volumétrico kg": "peso_vol",
        "Recibió": 'recibio',
        "Referencia cliente": "referencia",
        "Servicio": "servicio",
        "Tipo de envío": "tipo",
        "Historia": 'historia',
        "Fecha - Hora": 'fecha_hora',
        "Lugar - Movimiento": 'lugar_movimiento',
        "Comentarios": 'comentarios'
      }

      if rows[1].css('td').text =~ /no hay información disponible/i then
        # Add a no response here
      else
        # Fuuuuuu
        result = {}
        rows.each_with_index do |row, index|

          next if index.even?

          titulos = row.css('td.titulos').map(&:text).map(&:strip)
          respuestas = row.css('td.respuestas').map(&:text).map(&:strip)
          next if titulos.empty?


          if titulos.include? 'Destino' then
            temp_row = row.css('td.respuestas > table td').map(&:text).map(&:strip)
            respuestas = [] << respuestas[0] << temp_row[0] << temp_row[2]
          end

          if titulos.include? 'Estatus del servicio' then
            temp_row = row.css('td.respuestasazul').map(&:text).map(&:strip).reject(&:empty?)
            respuestas.unshift temp_row[0]
            titulos << row.css('td.style1 > div.titulos').text.strip
            respuestas << row.css('td.style1 > div.respuestas').text.strip
          end

          if titulos[0] =~ /\Aservicio/i then
            titulos[0] = "Servicio"
            respuestas << row.css('td.style1 > div.respuestas').text.strip
          end

          if titulos.include? 'Guías envíos múltiples' then
            respuestas += rows.at(index + 2).css('td.style1').map(&:text).map(&:strip)
            respuestas += rows.at(index + 2).css('td.respuestas').map(&:text).map(&:strip)
          end

          historial = false
          if titulos.include? 'Características del envío' then
            temp_rows = rows[index..rows.count]
            temp_rows.each do |temp_row|
              otros_titulos = temp_row.css('span.titulos').map(&:text).map(&:strip)
              otras_respuestas = temp_row.css('td.titulos').map(&:text).map(&:strip)
              if (otros_titulos.include? 'Historia' and otros_titulos.count == 1) or historial then
                historial = true
                match = temp_row.text.strip.match(/\A\d{2}\/\d{2}\/\d{4}\s\d{2}\:\d{2}\s[A|P]M/)
                if match then
                  otras_respuestas = temp_row.css('td.style1').map(&:text).map(&:strip) + temp_row.css('td.respuestasNormal').map(&:text).map(&:strip)
                  fecha_hora = otras_respuestas[0]
                  lugar_movimiento = otras_respuestas[2]
                  comentarios = otras_respuestas[1]
                  respuestas += ['fecha_hora': fecha_hora, 'lugar_movimiento': lugar_movimiento, 'comentarios': comentarios]
                end
              end
            end
            titulos = ["Historia"]
          end
          respuestas = [respuestas] if historial

          Hash[titulos.zip respuestas].each  do |key, value|
            result[keys[:"#{key}"]] = value
          end
        end # End Rows
      end # End else
    end # End parse
  end # End Standard
end # End module
