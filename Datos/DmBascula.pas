unit DmBascula;

interface

uses
  System.SysUtils, System.Classes, CPort, Vcl.Dialogs, System.StrUtils, BasculaModelo, Vcl.ExtCtrls,
  Vcl.Forms,  JncLib;

type
  TaccesoBascula = class(TDataModule)
    Timer: TTimer;
    ComPort: TComPort;
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    
  private
    FPeso: Double;
    FPesoAnterior: Double; // Guardamos el peso anterior, para comprobar si la báscula está estable porque se ha cambiado
    // de peso o simplemente, no se ha hecho nada.
    FEstado: TEstadoBascula;
    FLecturaCom1: String;
    FTipoPeso: String;
    FDescarte: Double;
  public
    constructor Create(AOwner: TComponent; vTimer: TTimer; vDescarte:double); reintroduce; overload;
    destructor Destroy; override;
    property Peso: Double read FPeso write FPeso;
    property PesoAnterior: Double read FPesoAnterior write FPesoAnterior;
    property Estado: TEstadoBascula read FEstado write FEstado;
    property LecturaCom1 : String read FLecturaCom1 write FLecturaCom1;
    property TipoPeso : String read FTipoPeso write FTipoPeso;
    property Descarte: Double read FDescarte write FDescarte;

    procedure Configuracion;
    procedure abrePuerto;
    function textoEstado: string;
    procedure InicializaPesos;
    function calculaPeso(vRespuestaPeso: ansiString): Double;

    procedure enviaDatos;
  end;

implementation

{ %CLASSGROUP 'System.Classes.TPersistent' }

{$R *.dfm}
{ TaccesoBascula }

// Apertura del puerto com con los datos almacenados el un fichero ini
procedure TaccesoBascula.abrePuerto;
begin

  if not ComPort.Connected then
  begin

    ComPort.LoadSettings(stiniFile, ExtractFilepath(Paramstr(0)) + kArchivoBascula);
    try
      ComPort.Open;
      Estado := tePesando;

    except
      on E: Exception do
      begin
        ShowMessage('No existe el puerto de comunicaciones ' + ComPort.Port + ' o esta en uso');
        //LecturaCom1 := 'No existe el puerto de comunicaciones ' + ComPort.Port + ' o esta en uso';
        Estado := teInactivo;
      end;
    end;
  end
  else
    Estado := tePesando;

end;

// Calcula el peso con la cadena recibida.
function TaccesoBascula.calculaPeso(vRespuestaPeso: ansiString): Double;
begin

  // Los datos son correctos si la cadena comienza por '990'
  if ((AnsiLeftStr(string(vRespuestaPeso), 3) = '990') and (TipoPeso = 'Peso')) then
  begin
    // El peso se encuentra entre la posición 4-9
    result := strTofloat(AnsiMidStr(string(vRespuestaPeso), 4, 5)) / 1000;
    exit;
  end;

  if ((AnsiLeftStr(string(vRespuestaPeso), 3) = '990') and (TipoPeso = 'Minerva')) then
  begin
    // El peso se encuentra entre la posición 4-9
    result := strTofloat(AnsiMidStr(string(vRespuestaPeso), 4, 5)) / 1000;
    exit;
  end;

  if ((AnsiLeftStr(string(vRespuestaPeso), 3) = '991') and (TipoPeso = 'Minerva')) then
  begin
     result := Peso;
     exit;
  end;
  if TipoPeso = 'Baxtran' then
  begin
     //En la balanza Baxtran hay que configurar en los parámetros como en programacion de Balanzas de ATC
       result := Formateafloat(AnsiMidStr(string(vRespuestaPeso),1,7));

      exit;
  end;


  if TipoPeso = 'Visor' then
      result := formateafloat(AnsiMidStr(string(vRespuestaPeso),1,7))
  else
       result := -1;


end;

// Comprueba la lectura recibida para calcular el peso correcto
procedure TaccesoBascula.ComPortRxChar(Sender: TObject; Count: Integer);
var
  vLectura: String;
begin
  if Estado  <> teInactivo then
  begin

      ComPort.ReadStr(vLectura, Count);
      // Almacenamos el peso anterior, para no imprimir dos etiquetas iguales

        PesoAnterior := Peso;
        Peso := calculaPeso(vLectura);


      if (TipoPeso = 'Visor') then
      begin
         if Peso > Descarte then
          Estado := teEstable
        else
          Estado := tePesando;
      end
      else
      begin
          // No ha cambiado el peso, por lo que estamos en la misma bandeja. Si dos bandejas pesan lo mismo, no habría problema,
          // porque ha tenido que haber un cambio con peso negativo
          if Peso = PesoAnterior then
            Estado := teSinCambio
          else
          if Peso > Descarte then
            Estado := teEstable
          else
            Estado := tePesando;
      end;

      Timer.Enabled := True;
  end;
end;

// Si queremos modificar los datos del puerto de comunicación del puerto com
procedure TaccesoBascula.Configuracion;
begin
  ComPort.ShowSetupDialog;
end;

constructor TaccesoBascula.Create(AOwner: TComponent; vTimer: TTimer; vDescarte:double);
begin
  inherited Create(AOwner);
  Timer := vTimer;
  Descarte := vDescarte;
end;

destructor TaccesoBascula.Destroy;
begin

  Estado := teInactivo;
  if ComPort.Connected then
  begin
    //ComPort.StoreSettings(stiniFile, ExtractFilepath(Paramstr(0)) + kArchivoBascula);
    ComPort.Close;

  end;
  inherited Destroy;
end;

// Enviamos una cadena en hexadecimal a la báscula solicitando que nos dé la lectura
procedure TaccesoBascula.enviaDatos;
begin
  try
    ComPort.WriteStr('$');//kDatosEnvio);
    Timer.Enabled := False;
    sleep(100);
    // Application.Processmessages;
  except
    on E: Exception do
    begin

      Timer.Enabled := False;
      Estado := teInactivo;
    end;
  end;
end;

// Inicializamos los valores del peso
procedure TaccesoBascula.InicializaPesos;
begin
  Peso := 0;
  PesoAnterior := 0;
end;

// Muestra el estado de la báscula
function TaccesoBascula.textoEstado: string;
begin

  result := aEstado[Estado];

end;

end.
