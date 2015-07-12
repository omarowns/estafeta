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

  def self.post_entregado
    VCR.use_cassette('estafeta_post_successful_entregado') do
      yield
    end
  end

  def self.post_fail
    VCR.use_cassette('estafeta_post_unsuccessful') do
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

    describe 'states' do
      subject(:std) { Estafeta::Standard.new(guia_numero: numero_guia) }

      it { should respond_to :status }

      describe 'life cycle' do

        it 'should evolve as the program continues' do

          expect(std.status).to eq :new
          EstafetaVcr.post { std.post }
          expect(std.status).to eq :post_sent
          std.retrieve_page
          expect(std.status).to eq :page_retrieved
          std.parse
          expect(std.status).to eq :parsing_ended_ok
        end
      end

      context 'when an incorrect tracking is entered' do

        context 'when it belonged to a shipment but no longer exists' do
          it 'should expect a failure status' do
            std = Estafeta::Standard.new(guia_numero: 1234567890123456789012)
            EstafetaVcr.post_fail { std.post }
            std.retrieve_page
            std.parse
            expect(std.status).to eq :parsing_ended_failed
          end
        end

        context "when it doesn't exists at all" do
          it 'should expect a failure status' do
            std = Estafeta::Standard.new(guia_numero: 1122334455667788990011)
            EstafetaVcr.post_fail { std.post }
            std.retrieve_page
            std.parse
            expect(std.status).to eq :parsing_ended_failed
          end
        end
      end
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
        let(:json_result) { {"guia"=>"8058606738655781217161", "codigo_rastreo"=>"1099674276", "origen"=>"AGUASCALIENTES", "destino"=>"Zamora", "cp"=>" 60300", "servicio_status"=>"Pendiente en transito", "recibio"=>"", "servicio"=>"Entrega garantizada al segundo día hábil", "fecha_actual"=>"", "tipo"=>"PAQUETE", "fecha_programada"=>"13/07/2015", "orden_recoleccion"=>"11422245", "fecha_recoleccion"=>"09/07/2015 06:06 PM", "orden_rastreo"=>"Su envío se encuentra en tiempo para ser entregado el día 13/07/2015, para cualquier duda o comentario  favor de  comunicarse al 01-800-37823382", "guia_multiples"=>" ", "guia_documento"=>" ", "guia_internacional"=>nil, "historia"=>[{:fecha_hora=>"09/07/2015 09:29 PM", :lugar_movimiento=>"AGUASCALIENTES Llegada a centro de distribucion AGU AGUASCALIENTES", :comentarios=>" "}, {:fecha_hora=>"09/07/2015 09:29 PM", :lugar_movimiento=>"AGUASCALIENTES En ruta foranea  hacia ZRA-Zamora", :comentarios=>" "}]} }

        before do
          EstafetaVcr.post { std.post }
          std.retrieve_page
          std.parse
        end

        it 'completes OK' do
          expect(std.json).to eq json_result
        end

        describe 'json result' do
          pending 'add all the validations of fields that it must have'
        end
      end

      context 'with a package that has been delivered' do
        let(:numero_guia_entregado) { '0018649684780680729892' }
        let(:std) { Estafeta::Standard.new(guia_numero: numero_guia_entregado) }
        let(:json_result) { {"guia"=>"0018649684780680729892", "codigo_rastreo"=>"3327678855", "origen"=>"ZACATECAS", "destino"=>"Culiacan", "cp"=>" 80430", "servicio_status"=>"Entregado", nil=>"", "servicio"=>"Entrega garantizada al siguiente dia habil (lunes a viernes)", "fecha_actual"=>"25/02/2015 03:00 PM", "tipo"=>"PAQUETE", "fecha_programada"=>"Garantía adquirida no aplica, revisar cobertura, clic aquí", "orden_recoleccion"=>"10679692", "fecha_recoleccion"=>"24/02/2015 01:32 PM", "orden_rastreo"=>"Haga clic  aquí para levantar una orden de rastreo.", "guia_multiples"=>" ", "guia_documento"=>" ", "guia_internacional"=>nil, "historia"=>[{:fecha_hora=>"25/02/2015 01:55 PM", :lugar_movimiento=>"Culiacan En proceso de entrega CUL Culiacan", :comentarios=>" "}, {:fecha_hora=>"25/02/2015 10:19 AM", :lugar_movimiento=>"Culiacan Movimiento en centro de distribucion SAB", :comentarios=>"Envio en proceso de entrega conforme a frecuencia"}, {:fecha_hora=>"25/02/2015 08:56 AM", :lugar_movimiento=>"Culiacan Llegada a centro de distribucion", :comentarios=>"Demora por mal tiempo bloqueo o manifestacion"}, {:fecha_hora=>"25/02/2015 07:15 AM", :lugar_movimiento=>"ESTACION AEREA CUL En ruta foranea  hacia CUL-Culiacan", :comentarios=>" "}, {:fecha_hora=>"25/02/2015 07:14 AM", :lugar_movimiento=>"ESTACION AEREA CUL Llegada a centro de distribucion ACL ESTACION AEREA CUL", :comentarios=>" "}, {:fecha_hora=>"25/02/2015 12:50 AM", :lugar_movimiento=>"Centro de Int. SLP En proceso de entrega", :comentarios=>"Embarque aereo Estafeta"}, {:fecha_hora=>"24/02/2015 08:50 PM", :lugar_movimiento=>"ZACATECAS En ruta foranea  hacia CUL-Culiacan", :comentarios=>" "}, {:fecha_hora=>"24/02/2015 08:20 PM", :lugar_movimiento=>"ZACATECAS Llegada a centro de distribucion ZCL ZACATECAS", :comentarios=>" "}, {:fecha_hora=>"24/02/2015 07:12 PM", :lugar_movimiento=>"Recoleccion en oficina por ruta local", :comentarios=>" "}, {:fecha_hora=>"24/02/2015 01:32 PM", :lugar_movimiento=>"Envio recibido en oficina", :comentarios=>"Garantia de entrega no aplica en destino"}]} }

        before do
          EstafetaVcr.post_entregado { std.post }
          std.retrieve_page
          std.parse
        end

        it 'completes OK' do
          expect(std.json).to eq json_result
        end

        describe 'json result' do
          pending 'add all the validations of fields that it must have'
        end
      end
    end
  end
end
