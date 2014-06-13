gem "minitest"
require 'minitest/autorun'

class Pedido
  attr_accessor :origen, :destino

  def initialize(origen_latitud, origen_longitud, destino_latitud, destino_longitud)
    @origen = Posicion.new(origen_latitud, origen_longitud)
    @destino = Posicion.new(destino_latitud, destino_longitud)
  end

  def distancia
    @origen.distanciaA(@destino)
  end
end

class Posicion
  attr_accessor :latitud, :longitud

  def initialize(latitud, longitud)
    @latitud = latitud
    @longitud = longitud
  end

  def distanciaA(otraPosicion)
    Math.sqrt((@latitud - otraPosicion.latitud) ** 2 +
                  (@longitud - otraPosicion.longitud) ** 2)
  end
end

class Pasajero

  attr_accessor :saldo

  def initialize
    @saldo = 1000
    @condiciones = []
  end

  def agregar_condicion(&condicion)
    agregar_objeto_condicion condicion
  end

  def agregar_objeto_condicion(condicion)
    @condiciones.push condicion
  end

  def es_valido?(pedido)
    @condiciones.all? do |condicion|
      condicion.call(self, pedido)
    end
    #validar_pedido(pedido) && validar_saldo()
  end

end

class CondicionSaldoPositivo
  def call(pasajero, pedido)
    pasajero.saldo > 0
  end
end

class CondicionDistancia
  def call(pasajero, pedido)
    pedido.distancia <= 10
  end
end

def implementar(cosa)
  raise "Hay que implementar #{cosa}"
end

class TaxisTest < MiniTest::Unit::TestCase

  def test_si_pido_taxi_deberia_encontrar_los_cercanos
    buscador = implementar 'como instanciar un buscador'
    taxiCercano = implementar 'como crear un taxi en una posicion cercana a 3,3'
    implementar 'como agregar taxiCercano y mas taxis al buscador'

    pasajero = Pasajero.new
    pedido = Pedido.new(1, 1, 2, 2)

    taxisEncontrados = implementar 'que el buscador busque los taxis'
    assert taxisEncontrados.include?(taxiCercano)
  end

  def test_si_un_taxi_esta_lejos_no_aparece_entre_los_encontrados
    buscador = implementar 'como instanciar un buscador'
    taxiCercano = implementar 'como crear un taxi en una posicion cercana a 500,500'
    implementar 'como agregar taxiCercano y mas taxis al buscador'

    pasajero = Pasajero.new
    pedido = Pedido.new(1, 1, 2, 2)

    taxisEncontrados = implementar 'que el buscador busque los taxis'
    assert !taxisEncontrados.include?(taxiCercano)
  end

  def test_pedido_coordenadas
    pasajero = Pasajero.new

    pasajero.agregar_condicion do |pasajero, pedido|
      pedido.origen.latitud > 0 && pedido.origen.latitud < 2
    end
    #-------------------------------------
    pedido = Pedido.new(1, 1, 2, 2)
    assert pasajero.es_valido?(pedido)
  end


  def test_pedido_valido_por_distancia
    pasajero = Pasajero.new
    pasajero.agregar_condicion do |pasajero, pedido|
      pedido.distancia <= 10
    end
    pedido = Pedido.new(1, 1, 2, 2)

    assert pasajero.es_valido?(pedido)
  end

  def test_pedido_no_valido_considerando_saldo
    pasajero = Pasajero.new
    pasajero.agregar_condicion do |pasajero, pedido|
      pasajero.saldo > 0
    end
    pasajero.saldo = 0
    pedido = Pedido.new(1, 1, 2, 2)

    assert !pasajero.es_valido?(pedido)
  end


  def test_calcular_distancia_pedido
    pedido = Pedido.new(1, 1, 2, 2)

    self.assert_equal Math.sqrt(2), pedido.distancia

  end

  def test_para_ver_si_ruby_nos_sorprende
    pasajero = Pasajero.new
    pasajero.agregar_objeto_condicion CondicionSaldoPositivo.new
    pasajero.agregar_condicion do |pasajero, pedido|
      pasajero.saldo < 100
    end
    pasajero.saldo = 10
    pedido = Pedido.new(1, 1, 2, 2)

    assert pasajero.es_valido?(pedido)

    pasajero.saldo = 300
    assert !pasajero.es_valido?(pedido)


    pasajero.saldo = -300
    assert !pasajero.es_valido?(pedido)

  end

end