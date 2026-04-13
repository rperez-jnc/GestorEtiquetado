unit BasculaModelo;

interface

type
  // Estados por lo que pasa la bascula
  // teSinCambio, es cuando está pesando y no cambiamos el peso
  TEstadoBascula = (teNada, teInactivo, tePesando, teEstable, teSinCambio);

const
  aEstado: Array [TEstadoBascula] of string = ('', 'Inactivo', 'Pesando...', 'Estable', 'Estable...');
  // Diferenciamos estable de sin cambio por los "tres puntos"

  // Cadena con los valores: 98000001 - Retorno de carro - Nueva línea
  kDatosEnvio = #$39#$38#$30#$30#$30#$30#$30#$31#$0D#$0A;
  // Fichero donde irá la configuración del puerto com. Tiene que llamarse así, en próximas versiones, lo modificaremos.
  kArchivoBascula = 'ComSetup.ini';

implementation

end.
