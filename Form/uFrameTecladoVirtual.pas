unit uFrameTecladoVirtual;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Math,
  System.Generics.Collections,
  Data.DB,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.DBCtrls;

const
  WM_TECLADO_CAMBIAR_MODO = WM_USER + 501;

type
  TTipoTeclado = (
    ttAlfanumerico,
    ttNumerico
  );

  TTipoTecla = (
    tkTexto,
    tkMayusculas,
    tkNumerico,
    tkAlfanumerico,
    tkBorrar,
    tkLimpiar,
    tkEspacio,
    tkEnter,
    tkDecimal,
    tkSigno,
    tkFuncion
  );

  TWinControlAccess = class(TWinControl)
  end;

  TCustomFormAccess = class(TCustomForm)
  end;

  TBotonTeclado = class(TSpeedButton)
  public
    TipoTecla: TTipoTecla;
    Valor: string;
    Peso: Integer;
    EsLetra: Boolean;
  end;

  TFrameTecladoVirtual = class(TPanel)
  private
    FInicializado: Boolean;
    FControlActivo: TWinControl;

    FTipoTeclado: TTipoTeclado;
    FMayusculas: Boolean;
    FSeparadorDecimal: Char;
    FPermitirNegativos: Boolean;
    FMostrarTeclasFuncion: Boolean;

    { Visor/buffer opcional para tablet }
    FMostrarVisorTexto: Boolean;
    FUsarBufferTexto: Boolean;
    FAlturaVisorTexto: Integer;
    FPanelVisor: TPanel;
    FEditVisor: TEdit;
    FBufferTexto: string;
    FBufferCursorPos: Integer;
    FBufferSelStart: Integer;
    FBufferSelLength: Integer;
    FBufferModificado: Boolean;
    FReemplazarBufferEnPrimeraEntrada: Boolean;

    FEnterSiguienteControl: Boolean;
    FEnterSaltoLineaMemo: Boolean;

    FTamanoFuente: Integer;
    FEspacioEntreTeclas: Integer;

    FOnEnterTeclado: TNotifyEvent;

    FTimerDeteccion: TTimer;
    FDeteccionAutomatica: Boolean;
    FAutoMostrar: Boolean;
    FAutoOcultar: Boolean;
    FTipoPorDefecto: TTipoTeclado;

    FConfiguracionControles: TDictionary<TWinControl, TTipoTeclado>;

    FAjustarVistaAutomaticamente: Boolean;
    FRestaurarScrollAlOcultar: Boolean;
    FMargenVisibilidad: Integer;

    FContenedorScrollActual: TScrollingWinControl;
    FPosicionScrollOriginal: Integer;
    FScrollOriginalGuardado: Boolean;

    FFilas: array of TPanel;

    procedure LimpiarTeclado;
    procedure CrearVisorTexto;
    function CrearFila: TPanel;

    function CrearTecla(
      AFila: TPanel;
      const ACaption: string;
      const AValor: string;
      ATipo: TTipoTecla;
      APeso: Integer = 1;
      AEsLetra: Boolean = False
    ): TBotonTeclado;

    procedure CrearTecladoAlfanumerico;
    procedure CrearTecladoNumerico;
    procedure ReconstruirTeclado;

    procedure DistribuirFilas;
    procedure DistribuirTeclas(AFila: TPanel);

    procedure TeclaClick(Sender: TObject);
    procedure WMCambiarModo(var Msg: TMessage); message WM_TECLADO_CAMBIAR_MODO;

    procedure InsertarTexto(const ATexto: string);
    procedure InsertarCaracter(AChar: Char);

    procedure Borrar;
    procedure Limpiar;
    procedure InsertarEspacio;
    procedure ProcesarEnter;
    procedure InsertarDecimal;
    procedure CambiarSigno;
    procedure EnviarTeclaFuncion(AVirtualKey: Word);

    procedure SetTipoTeclado(const Value: TTipoTeclado);
    procedure SetControlActivo(const Value: TWinControl);
    procedure SetMayusculas(const Value: Boolean);
    procedure SetSeparadorDecimal(const Value: Char);
    procedure SetPermitirNegativos(const Value: Boolean);
    procedure SetMostrarTeclasFuncion(const Value: Boolean);
    procedure SetMostrarVisorTexto(const Value: Boolean);
    procedure SetUsarBufferTexto(const Value: Boolean);
    procedure SetAlturaVisorTexto(const Value: Integer);
    procedure SetTamanoFuente(const Value: Integer);
    procedure SetEspacioEntreTeclas(const Value: Integer);
    procedure SetDeteccionAutomatica(const Value: Boolean);

    procedure ActualizarMayusculas;

    function BufferActivo: Boolean;
    procedure CargarBufferDesdeControl;
    procedure ActualizarVisor;
    procedure ConfirmarBuffer;
    procedure PrepararPrimeraEntradaBuffer;
    procedure InsertarEnBuffer(const ATexto: string);
    procedure BorrarBuffer;
    procedure LimpiarBuffer;
    procedure InsertarDecimalBuffer;
    procedure CambiarSignoBuffer;

    function ObtenerEditActivo: TCustomEdit;
    function ControlValido: Boolean;
    procedure DarFocoControlActivo;

    procedure ObtenerSeleccion(
      AEdit: TCustomEdit;
      out AInicio: Integer;
      out AFin: Integer
    );

    function SeparadorDecimalSeleccionado(
      AEdit: TCustomEdit
    ): Boolean;

    procedure TimerDeteccionTimer(Sender: TObject);

    function ObtenerControlConFoco: TWinControl;
    function EsControlEditable(AControl: TWinControl): Boolean;
    function EstaDentroDelTeclado(AControl: TControl): Boolean;

    function DeterminarTipoTeclado(
      AControl: TWinControl
    ): TTipoTeclado;

    function CampoDBEsNumerico(
      AControl: TWinControl
    ): Boolean;

    function BuscarContenedorScroll(
      AControl: TWinControl
    ): TScrollingWinControl;

    procedure PrepararContenedorScroll(
      AContenedor: TScrollingWinControl
    );

    procedure AjustarVistaAlControl(
      AControl: TWinControl
    );

    procedure RestaurarVista;
    procedure MostrarInterno;

  protected
    procedure Resize; override;

    procedure Notification(
      AComponent: TComponent;
      Operation: TOperation
    ); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Inicializar;

    procedure MostrarPara(
      AControl: TWinControl;
      ATipo: TTipoTeclado = ttAlfanumerico
    );

    procedure MostrarAlfanumerico;
    procedure MostrarNumerico;
    procedure OcultarTeclado;

    procedure RegistrarControl(
      AControl: TWinControl;
      ATipo: TTipoTeclado
    );

    procedure RegistrarNumerico(AControl: TWinControl);
    procedure RegistrarAlfanumerico(AControl: TWinControl);
    procedure QuitarConfiguracion(AControl: TWinControl);
    procedure LimpiarConfiguracionControles;

    property ControlActivo: TWinControl
      read FControlActivo
      write SetControlActivo;

    property TipoTeclado: TTipoTeclado
      read FTipoTeclado
      write SetTipoTeclado;

    property Mayusculas: Boolean
      read FMayusculas
      write SetMayusculas;

    property SeparadorDecimal: Char
      read FSeparadorDecimal
      write SetSeparadorDecimal;

    property PermitirNegativos: Boolean
      read FPermitirNegativos
      write SetPermitirNegativos;

    property MostrarTeclasFuncion: Boolean
      read FMostrarTeclasFuncion
      write SetMostrarTeclasFuncion;

    { Si se activa, aparece una caja grande encima de las teclas con el valor
      que se esta introduciendo. Con UsarBufferTexto=True, el Edit real no se
      modifica hasta pulsar ENTER. }
    property MostrarVisorTexto: Boolean
      read FMostrarVisorTexto
      write SetMostrarVisorTexto;

    property UsarBufferTexto: Boolean
      read FUsarBufferTexto
      write SetUsarBufferTexto;

    property AlturaVisorTexto: Integer
      read FAlturaVisorTexto
      write SetAlturaVisorTexto;

    property EnterSiguienteControl: Boolean
      read FEnterSiguienteControl
      write FEnterSiguienteControl;

    property EnterSaltoLineaMemo: Boolean
      read FEnterSaltoLineaMemo
      write FEnterSaltoLineaMemo;

    property TamanoFuente: Integer
      read FTamanoFuente
      write SetTamanoFuente;

    property EspacioEntreTeclas: Integer
      read FEspacioEntreTeclas
      write SetEspacioEntreTeclas;

    property DeteccionAutomatica: Boolean
      read FDeteccionAutomatica
      write SetDeteccionAutomatica;

    property AutoMostrar: Boolean
      read FAutoMostrar
      write FAutoMostrar;

    property AutoOcultar: Boolean
      read FAutoOcultar
      write FAutoOcultar;

    property TipoPorDefecto: TTipoTeclado
      read FTipoPorDefecto
      write FTipoPorDefecto;

    property AjustarVistaAutomaticamente: Boolean
      read FAjustarVistaAutomaticamente
      write FAjustarVistaAutomaticamente;

    property RestaurarScrollAlOcultar: Boolean
      read FRestaurarScrollAlOcultar
      write FRestaurarScrollAlOcultar;

    property MargenVisibilidad: Integer
      read FMargenVisibilidad
      write FMargenVisibilidad;

    property OnEnterTeclado: TNotifyEvent
      read FOnEnterTeclado
      write FOnEnterTeclado;
  end;

implementation

{ TFrameTecladoVirtual }

constructor TFrameTecladoVirtual.Create(AOwner: TComponent);
var
  FS: TFormatSettings;
begin
  inherited Create(AOwner);

  FInicializado := False;

  BevelOuter := bvNone;
  Caption := '';
  Align := alBottom;
  Height := 350;
  Constraints.MinHeight := 220;
  DoubleBuffered := True;
  Color := clBtnFace;

  FTipoTeclado := ttAlfanumerico;
  FTipoPorDefecto := ttAlfanumerico;
  FMayusculas := True;
  FPermitirNegativos := True;
  FMostrarTeclasFuncion := True;

  { Por seguridad se deja desactivado por defecto. Asi formularios como
    ValidacionUsuario no muestran la clave en un visor adicional. }
  FMostrarVisorTexto := False;
  FUsarBufferTexto := False;
  FAlturaVisorTexto := 56;
  FPanelVisor := nil;
  FEditVisor := nil;
  FBufferTexto := '';
  FBufferCursorPos := 0;
  FBufferSelStart := 0;
  FBufferSelLength := 0;
  FBufferModificado := False;
  FReemplazarBufferEnPrimeraEntrada := False;

  FEnterSiguienteControl := True;
  FEnterSaltoLineaMemo := True;

  FTamanoFuente := 16;
  FEspacioEntreTeclas := 4;

  FS := TFormatSettings.Create;
  FSeparadorDecimal := FS.DecimalSeparator;

  FConfiguracionControles :=
    TDictionary<TWinControl, TTipoTeclado>.Create;

  FDeteccionAutomatica := True;
  FAutoMostrar := True;
  FAutoOcultar := True;

  FAjustarVistaAutomaticamente := True;
  FRestaurarScrollAlOcultar := True;
  FMargenVisibilidad := 20;

  FContenedorScrollActual := nil;
  FPosicionScrollOriginal := 0;
  FScrollOriginalGuardado := False;

  { El panel todavia no tiene Parent durante el constructor.
    No se crean aqui los botones/paneles hijos porque XE10 intentaria
    crear el handle del control antes de tener una ventana padre. }
  Visible := False;

  FTimerDeteccion := TTimer.Create(Self);
  FTimerDeteccion.Interval := 100;
  FTimerDeteccion.OnTimer := TimerDeteccionTimer;
  FTimerDeteccion.Enabled := False;
end;

destructor TFrameTecladoVirtual.Destroy;
begin
  if Assigned(FTimerDeteccion) then
    FTimerDeteccion.Enabled := False;

  FreeAndNil(FConfiguracionControles);

  inherited Destroy;
end;

procedure TFrameTecladoVirtual.Inicializar;
begin
  if FInicializado then
    Exit;

  if not Assigned(Parent) then
    raise Exception.Create(
      'TFrameTecladoVirtual.Inicializar: asigne Parent antes de inicializar el teclado'
    );

  { Ahora el TPanel ya pertenece a una ventana y es seguro crear
    todos los controles hijos. }
  CrearVisorTexto;
  ReconstruirTeclado;
  FInicializado := True;

  Visible := False;

  if Assigned(FTimerDeteccion) then
    FTimerDeteccion.Enabled := FDeteccionAutomatica;
end;

procedure TFrameTecladoVirtual.Notification(
  AComponent: TComponent;
  Operation: TOperation
);
begin
  inherited;

  if Operation <> opRemove then
    Exit;

  if AComponent = FControlActivo then
  begin
    FControlActivo := nil;
    FBufferTexto := '';
    FBufferModificado := False;
    FReemplazarBufferEnPrimeraEntrada := False;
    if Assigned(FEditVisor) then
      FEditVisor.Text := '';
  end;

  if AComponent = FContenedorScrollActual then
  begin
    FContenedorScrollActual := nil;
    FPosicionScrollOriginal := 0;
    FScrollOriginalGuardado := False;
  end;

  if Assigned(FConfiguracionControles) and
     (AComponent is TWinControl) then
  begin
    FConfiguracionControles.Remove(TWinControl(AComponent));
  end;
end;

procedure TFrameTecladoVirtual.Resize;
begin
  inherited Resize;
  DistribuirFilas;
end;

procedure TFrameTecladoVirtual.LimpiarTeclado;
var
  I: Integer;
begin
  { Solo se destruyen las filas de teclas. El visor es persistente para
    conservar el buffer al cambiar ABC <-> 123. }
  for I := 0 to High(FFilas) do
    FFilas[I].Free;

  SetLength(FFilas, 0);
end;

procedure TFrameTecladoVirtual.CrearVisorTexto;
begin
  if Assigned(FPanelVisor) then
    Exit;

  FPanelVisor := TPanel.Create(Self);
  FPanelVisor.Parent := Self;
  FPanelVisor.Align := alNone;
  FPanelVisor.BevelOuter := bvNone;
  FPanelVisor.Caption := '';
  FPanelVisor.ParentColor := True;
  FPanelVisor.Visible := FMostrarVisorTexto;

  FEditVisor := TEdit.Create(FPanelVisor);
  FEditVisor.Parent := FPanelVisor;
  FEditVisor.ReadOnly := True;
  FEditVisor.TabStop := False;
  FEditVisor.HideSelection := False;
  FEditVisor.Font.Size := 22;
  FEditVisor.Font.Style := [fsBold];
  FEditVisor.Text := '';
end;

function TFrameTecladoVirtual.CrearFila: TPanel;
var
  L: Integer;
begin
  Result := TPanel.Create(Self);
  Result.Parent := Self;
  Result.Align := alNone;
  Result.BevelOuter := bvNone;
  Result.Caption := '';
  Result.ParentColor := True;

  L := Length(FFilas);
  SetLength(FFilas, L + 1);
  FFilas[L] := Result;
end;

function TFrameTecladoVirtual.CrearTecla(
  AFila: TPanel;
  const ACaption: string;
  const AValor: string;
  ATipo: TTipoTecla;
  APeso: Integer;
  AEsLetra: Boolean
): TBotonTeclado;
begin
  Result := TBotonTeclado.Create(AFila);
  Result.Parent := AFila;
  Result.Caption := ACaption;
  Result.Valor := AValor;
  Result.TipoTecla := ATipo;
  Result.Peso := Max(1, APeso);
  Result.EsLetra := AEsLetra;
  Result.Font.Size := FTamanoFuente;
  Result.Font.Style := [];
  Result.OnClick := TeclaClick;
end;

procedure TFrameTecladoVirtual.ReconstruirTeclado;
begin
  LimpiarTeclado;

  case FTipoTeclado of
    ttAlfanumerico:
      CrearTecladoAlfanumerico;

    ttNumerico:
      CrearTecladoNumerico;
  end;

  DistribuirFilas;
  ActualizarMayusculas;
end;

procedure TFrameTecladoVirtual.CrearTecladoAlfanumerico;
var
  F: TPanel;
begin
  { Fila de teclas de funcion. Se puede ocultar en formularios
    que no las necesiten, como la validacion de usuario. }
  if FMostrarTeclasFuncion then
  begin
    F := CrearFila;

    CrearTecla(F, 'F1',  IntToStr(VK_F1),  tkFuncion);
    CrearTecla(F, 'F2',  IntToStr(VK_F2),  tkFuncion);
    CrearTecla(F, 'F3',  IntToStr(VK_F3),  tkFuncion);
    CrearTecla(F, 'F4',  IntToStr(VK_F4),  tkFuncion);
    CrearTecla(F, 'F5',  IntToStr(VK_F5),  tkFuncion);
    CrearTecla(F, 'F6',  IntToStr(VK_F6),  tkFuncion);
    CrearTecla(F, 'F7',  IntToStr(VK_F7),  tkFuncion);
    CrearTecla(F, 'F8',  IntToStr(VK_F8),  tkFuncion);
    CrearTecla(F, 'F9',  IntToStr(VK_F9),  tkFuncion);
    CrearTecla(F, 'F10', IntToStr(VK_F10), tkFuncion);
    CrearTecla(F, 'F11', IntToStr(VK_F11), tkFuncion);
    CrearTecla(F, 'F12', IntToStr(VK_F12), tkFuncion);
  end;

  { Fila 1 }
  F := CrearFila;

  CrearTecla(F, '1', '1', tkTexto);
  CrearTecla(F, '2', '2', tkTexto);
  CrearTecla(F, '3', '3', tkTexto);
  CrearTecla(F, '4', '4', tkTexto);
  CrearTecla(F, '5', '5', tkTexto);
  CrearTecla(F, '6', '6', tkTexto);
  CrearTecla(F, '7', '7', tkTexto);
  CrearTecla(F, '8', '8', tkTexto);
  CrearTecla(F, '9', '9', tkTexto);
  CrearTecla(F, '0', '0', tkTexto);

  { Fila 2 }
  F := CrearFila;

  CrearTecla(F, 'Q', 'q', tkTexto, 1, True);
  CrearTecla(F, 'W', 'w', tkTexto, 1, True);
  CrearTecla(F, 'E', 'e', tkTexto, 1, True);
  CrearTecla(F, 'R', 'r', tkTexto, 1, True);
  CrearTecla(F, 'T', 't', tkTexto, 1, True);
  CrearTecla(F, 'Y', 'y', tkTexto, 1, True);
  CrearTecla(F, 'U', 'u', tkTexto, 1, True);
  CrearTecla(F, 'I', 'i', tkTexto, 1, True);
  CrearTecla(F, 'O', 'o', tkTexto, 1, True);
  CrearTecla(F, 'P', 'p', tkTexto, 1, True);

  { Fila 3 }
  F := CrearFila;

  CrearTecla(F, 'A', 'a', tkTexto, 1, True);
  CrearTecla(F, 'S', 's', tkTexto, 1, True);
  CrearTecla(F, 'D', 'd', tkTexto, 1, True);
  CrearTecla(F, 'F', 'f', tkTexto, 1, True);
  CrearTecla(F, 'G', 'g', tkTexto, 1, True);
  CrearTecla(F, 'H', 'h', tkTexto, 1, True);
  CrearTecla(F, 'J', 'j', tkTexto, 1, True);
  CrearTecla(F, 'K', 'k', tkTexto, 1, True);
  CrearTecla(F, 'L', 'l', tkTexto, 1, True);
  CrearTecla(F, 'Ñ', 'ñ', tkTexto, 1, True);

  { Fila 4 }
  F := CrearFila;

  CrearTecla(F, 'MAYUS', '', tkMayusculas, 2);
  CrearTecla(F, 'Z', 'z', tkTexto, 1, True);
  CrearTecla(F, 'X', 'x', tkTexto, 1, True);
  CrearTecla(F, 'C', 'c', tkTexto, 1, True);
  CrearTecla(F, 'V', 'v', tkTexto, 1, True);
  CrearTecla(F, 'B', 'b', tkTexto, 1, True);
  CrearTecla(F, 'N', 'n', tkTexto, 1, True);
  CrearTecla(F, 'M', 'm', tkTexto, 1, True);
  CrearTecla(F, 'BORRAR', '', tkBorrar, 2);

  { Fila 5 }
  F := CrearFila;

  CrearTecla(F, '123', '', tkNumerico, 2);
  CrearTecla(F, '@', '@', tkTexto);
  CrearTecla(F, '.', '.', tkTexto);
  CrearTecla(F, '-', '-', tkTexto);
  CrearTecla(F, '/', '/', tkTexto);
  CrearTecla(F, 'ESPACIO', ' ', tkEspacio, 5);
  CrearTecla(F, 'ENTER', '', tkEnter, 2);
end;

procedure TFrameTecladoVirtual.CrearTecladoNumerico;
var
  F: TPanel;
  B: TBotonTeclado;
begin
  { Fila de teclas de funcion. Se puede ocultar en formularios
    que no las necesiten, como la validacion de usuario. }
  if FMostrarTeclasFuncion then
  begin
    F := CrearFila;

    CrearTecla(F, 'F1',  IntToStr(VK_F1),  tkFuncion);
    CrearTecla(F, 'F2',  IntToStr(VK_F2),  tkFuncion);
    CrearTecla(F, 'F3',  IntToStr(VK_F3),  tkFuncion);
    CrearTecla(F, 'F4',  IntToStr(VK_F4),  tkFuncion);
    CrearTecla(F, 'F5',  IntToStr(VK_F5),  tkFuncion);
    CrearTecla(F, 'F6',  IntToStr(VK_F6),  tkFuncion);
    CrearTecla(F, 'F7',  IntToStr(VK_F7),  tkFuncion);
    CrearTecla(F, 'F8',  IntToStr(VK_F8),  tkFuncion);
    CrearTecla(F, 'F9',  IntToStr(VK_F9),  tkFuncion);
    CrearTecla(F, 'F10', IntToStr(VK_F10), tkFuncion);
    CrearTecla(F, 'F11', IntToStr(VK_F11), tkFuncion);
    CrearTecla(F, 'F12', IntToStr(VK_F12), tkFuncion);
  end;

  { Fila 1 }
  F := CrearFila;

  CrearTecla(F, '7', '7', tkTexto);
  CrearTecla(F, '8', '8', tkTexto);
  CrearTecla(F, '9', '9', tkTexto);
  CrearTecla(F, 'BORRAR', '', tkBorrar, 2);

  { Fila 2 }
  F := CrearFila;

  CrearTecla(F, '4', '4', tkTexto);
  CrearTecla(F, '5', '5', tkTexto);
  CrearTecla(F, '6', '6', tkTexto);
  CrearTecla(F, 'LIMPIAR', '', tkLimpiar, 2);

  { Fila 3 }
  F := CrearFila;

  CrearTecla(F, '1', '1', tkTexto);
  CrearTecla(F, '2', '2', tkTexto);
  CrearTecla(F, '3', '3', tkTexto);

  B := CrearTecla(F, '+/-', '', tkSigno, 2);
  B.Enabled := FPermitirNegativos;

  { Fila 4 }
  F := CrearFila;

  CrearTecla(F, 'ABC', '', tkAlfanumerico, 2);
  CrearTecla(F, '0', '0', tkTexto, 2);
  CrearTecla(F, FSeparadorDecimal, FSeparadorDecimal, tkDecimal);
  CrearTecla(F, 'ENTER', '', tkEnter, 2);
end;

procedure TFrameTecladoVirtual.DistribuirFilas;
var
  I: Integer;
  Y: Integer;
  AltoFila: Integer;
  Alto: Integer;
  AltoDisponible: Integer;
  Margen: Integer;
begin
  Y := 0;
  Margen := FEspacioEntreTeclas;

  if Assigned(FPanelVisor) then
  begin
    FPanelVisor.Visible := FMostrarVisorTexto;

    if FMostrarVisorTexto then
    begin
      FPanelVisor.SetBounds(0, 0, ClientWidth, FAlturaVisorTexto);

      if Assigned(FEditVisor) then
        FEditVisor.SetBounds(
          Margen,
          Margen,
          Max(1, FPanelVisor.ClientWidth - (Margen * 2)),
          Max(1, FPanelVisor.ClientHeight - (Margen * 2))
        );

      Y := FAlturaVisorTexto;
    end;
  end;

  if Length(FFilas) = 0 then
    Exit;

  AltoDisponible := ClientHeight - Y;
  if AltoDisponible < Length(FFilas) then
    AltoDisponible := Length(FFilas);

  AltoFila := AltoDisponible div Length(FFilas);

  for I := 0 to High(FFilas) do
  begin
    if I = High(FFilas) then
      Alto := ClientHeight - Y
    else
      Alto := AltoFila;

    FFilas[I].SetBounds(0, Y, ClientWidth, Alto);
    DistribuirTeclas(FFilas[I]);

    Inc(Y, Alto);
  end;
end;

procedure TFrameTecladoVirtual.DistribuirTeclas(AFila: TPanel);
var
  I: Integer;
  PesoTotal: Integer;
  AnchoDisponible: Integer;
  AnchoTecla: Integer;
  X: Integer;
  B: TBotonTeclado;
  Espacio: Integer;
begin
  if AFila.ControlCount = 0 then
    Exit;

  Espacio := FEspacioEntreTeclas;
  PesoTotal := 0;

  for I := 0 to AFila.ControlCount - 1 do
  begin
    if AFila.Controls[I] is TBotonTeclado then
    begin
      B := TBotonTeclado(AFila.Controls[I]);
      Inc(PesoTotal, B.Peso);
    end;
  end;

  if PesoTotal = 0 then
    Exit;

  AnchoDisponible :=
    AFila.ClientWidth -
    (Espacio * (AFila.ControlCount + 1));

  if AnchoDisponible <= 0 then
    Exit;

  X := Espacio;

  for I := 0 to AFila.ControlCount - 1 do
  begin
    B := TBotonTeclado(AFila.Controls[I]);

    if I = AFila.ControlCount - 1 then
      AnchoTecla := AFila.ClientWidth - X - Espacio
    else
      AnchoTecla := Round((AnchoDisponible / PesoTotal) * B.Peso);

    B.SetBounds(
      X,
      Espacio,
      AnchoTecla,
      Max(1, AFila.ClientHeight - (Espacio * 2))
    );

    Inc(X, AnchoTecla + Espacio);
  end;
end;

procedure TFrameTecladoVirtual.TeclaClick(Sender: TObject);
var
  B: TBotonTeclado;
  Texto: string;
begin
  if not (Sender is TBotonTeclado) then
    Exit;

  B := TBotonTeclado(Sender);

  case B.TipoTecla of
    tkTexto:
      begin
        Texto := B.Valor;

        if B.EsLetra then
        begin
          if FMayusculas then
            Texto := UpperCase(Texto)
          else
            Texto := LowerCase(Texto);
        end;

        InsertarTexto(Texto);
      end;

    tkMayusculas:
      Mayusculas := not Mayusculas;

    { El cambio de distribucion se hace de forma diferida.
      No debemos destruir el boton que esta ejecutando su OnClick. }
    tkNumerico:
      PostMessage(Handle, WM_TECLADO_CAMBIAR_MODO, Ord(ttNumerico), 0);

    tkAlfanumerico:
      PostMessage(Handle, WM_TECLADO_CAMBIAR_MODO, Ord(ttAlfanumerico), 0);

    tkBorrar:
      Borrar;

    tkLimpiar:
      Limpiar;

    tkEspacio:
      InsertarEspacio;

    tkEnter:
      ProcesarEnter;

    tkDecimal:
      InsertarDecimal;

    tkSigno:
      CambiarSigno;

    tkFuncion:
      EnviarTeclaFuncion(
        Word(StrToIntDef(B.Valor, 0))
      );
  end;
end;

procedure TFrameTecladoVirtual.WMCambiarModo(var Msg: TMessage);
begin
  if Msg.WParam = Ord(ttNumerico) then
    SetTipoTeclado(ttNumerico)
  else
    SetTipoTeclado(ttAlfanumerico);

  MostrarInterno;
end;

procedure TFrameTecladoVirtual.SetControlActivo(const Value: TWinControl);
begin
  if FControlActivo = Value then
    Exit;

  { Si se cambia de campo sin ENTER, el buffer anterior se descarta
    deliberadamente: solo ENTER confirma el valor. }
  if Assigned(FControlActivo) then
    FControlActivo.RemoveFreeNotification(Self);

  FControlActivo := Value;
  FBufferModificado := False;
  FReemplazarBufferEnPrimeraEntrada := False;

  if Assigned(FControlActivo) then
    FControlActivo.FreeNotification(Self);

  if BufferActivo then
    CargarBufferDesdeControl
  else if Assigned(FEditVisor) then
    FEditVisor.Text := '';
end;

procedure TFrameTecladoVirtual.SetTipoTeclado(const Value: TTipoTeclado);
begin
  if FTipoTeclado = Value then
    Exit;

  FTipoTeclado := Value;

  if FInicializado then
    ReconstruirTeclado;
end;

procedure TFrameTecladoVirtual.SetMayusculas(const Value: Boolean);
begin
  if FMayusculas = Value then
    Exit;

  FMayusculas := Value;
  ActualizarMayusculas;
end;

procedure TFrameTecladoVirtual.SetSeparadorDecimal(const Value: Char);
begin
  if FSeparadorDecimal = Value then
    Exit;

  FSeparadorDecimal := Value;

  if FInicializado and (FTipoTeclado = ttNumerico) then
    ReconstruirTeclado;
end;

procedure TFrameTecladoVirtual.SetPermitirNegativos(const Value: Boolean);
begin
  if FPermitirNegativos = Value then
    Exit;

  FPermitirNegativos := Value;

  if FInicializado and (FTipoTeclado = ttNumerico) then
    ReconstruirTeclado;
end;

procedure TFrameTecladoVirtual.SetMostrarTeclasFuncion(const Value: Boolean);
begin
  if FMostrarTeclasFuncion = Value then
    Exit;

  FMostrarTeclasFuncion := Value;

  if FInicializado then
    ReconstruirTeclado;
end;

procedure TFrameTecladoVirtual.SetMostrarVisorTexto(const Value: Boolean);
begin
  if FMostrarVisorTexto = Value then
    Exit;

  FMostrarVisorTexto := Value;

  if Assigned(FPanelVisor) then
    FPanelVisor.Visible := Value;

  if Value and FUsarBufferTexto and ControlValido then
    CargarBufferDesdeControl;

  DistribuirFilas;
end;

procedure TFrameTecladoVirtual.SetUsarBufferTexto(const Value: Boolean);
begin
  if FUsarBufferTexto = Value then
    Exit;

  FUsarBufferTexto := Value;
  FBufferModificado := False;
  FReemplazarBufferEnPrimeraEntrada := False;

  if Value and FMostrarVisorTexto and ControlValido then
    CargarBufferDesdeControl
  else if Assigned(FEditVisor) and not Value then
    FEditVisor.Text := '';
end;

procedure TFrameTecladoVirtual.SetAlturaVisorTexto(const Value: Integer);
begin
  if Value < 36 then
    FAlturaVisorTexto := 36
  else
    FAlturaVisorTexto := Value;

  DistribuirFilas;
end;

procedure TFrameTecladoVirtual.SetTamanoFuente(const Value: Integer);
var
  I: Integer;
  J: Integer;
begin
  if Value < 8 then
    Exit;

  FTamanoFuente := Value;

  for I := 0 to High(FFilas) do
  begin
    for J := 0 to FFilas[I].ControlCount - 1 do
    begin
      if FFilas[I].Controls[J] is TBotonTeclado then
      begin
        TBotonTeclado(FFilas[I].Controls[J]).Font.Size := FTamanoFuente;
      end;
    end;
  end;
end;

procedure TFrameTecladoVirtual.SetEspacioEntreTeclas(const Value: Integer);
begin
  if Value < 0 then
    Exit;

  FEspacioEntreTeclas := Value;
  DistribuirFilas;
end;

procedure TFrameTecladoVirtual.SetDeteccionAutomatica(const Value: Boolean);
begin
  FDeteccionAutomatica := Value;

  if Assigned(FTimerDeteccion) then
    FTimerDeteccion.Enabled := Value and FInicializado;
end;

procedure TFrameTecladoVirtual.ActualizarMayusculas;
var
  I: Integer;
  J: Integer;
  B: TBotonTeclado;
begin
  if FTipoTeclado <> ttAlfanumerico then
    Exit;

  for I := 0 to High(FFilas) do
  begin
    for J := 0 to FFilas[I].ControlCount - 1 do
    begin
      if not (FFilas[I].Controls[J] is TBotonTeclado) then
        Continue;

      B := TBotonTeclado(FFilas[I].Controls[J]);

      if B.EsLetra then
      begin
        if FMayusculas then
          B.Caption := UpperCase(B.Valor)
        else
          B.Caption := LowerCase(B.Valor);
      end;

      if B.TipoTecla = tkMayusculas then
      begin
        if FMayusculas then
          B.Font.Style := [fsBold]
        else
          B.Font.Style := [];
      end;
    end;
  end;
end;

function TFrameTecladoVirtual.BufferActivo: Boolean;
begin
  Result :=
    FInicializado and
    FMostrarVisorTexto and
    FUsarBufferTexto and
    ControlValido;
end;

procedure TFrameTecladoVirtual.CargarBufferDesdeControl;
var
  E: TCustomEdit;
begin
  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  FBufferTexto := E.Text;
  FBufferSelStart := E.SelStart;
  FBufferSelLength := E.SelLength;
  FBufferCursorPos := FBufferSelStart;

  if FBufferCursorPos < 0 then
    FBufferCursorPos := 0;
  if FBufferCursorPos > Length(FBufferTexto) then
    FBufferCursorPos := Length(FBufferTexto);

  FBufferModificado := False;

  { El valor actual se muestra solo como referencia. La primera tecla de
    contenido sustituira completamente este valor. }
  FReemplazarBufferEnPrimeraEntrada := True;

  ActualizarVisor;
end;

procedure TFrameTecladoVirtual.ActualizarVisor;
begin
  if not Assigned(FEditVisor) then
    Exit;

  FEditVisor.Text := FBufferTexto;

  if FBufferSelStart < 0 then
    FBufferSelStart := 0;
  if FBufferSelStart > Length(FBufferTexto) then
    FBufferSelStart := Length(FBufferTexto);

  if FBufferSelLength < 0 then
    FBufferSelLength := 0;
  if FBufferSelStart + FBufferSelLength > Length(FBufferTexto) then
    FBufferSelLength := Length(FBufferTexto) - FBufferSelStart;

  FEditVisor.SelStart := FBufferSelStart;
  FEditVisor.SelLength := FBufferSelLength;
end;

procedure TFrameTecladoVirtual.ConfirmarBuffer;
var
  E: TCustomEdit;
begin
  if not BufferActivo then
    Exit;

  E := ObtenerEditActivo;
  if not Assigned(E) then
    Exit;

  { Una unica asignacion: el Edit real recibe el valor solo al confirmar. }
  E.Text := FBufferTexto;
  E.SelStart := Length(E.Text);
  E.SelLength := 0;

  FBufferCursorPos := Length(FBufferTexto);
  FBufferSelStart := FBufferCursorPos;
  FBufferSelLength := 0;
  FBufferModificado := False;
  FReemplazarBufferEnPrimeraEntrada := False;
  ActualizarVisor;
end;

procedure TFrameTecladoVirtual.PrepararPrimeraEntradaBuffer;
begin
  if not FReemplazarBufferEnPrimeraEntrada then
    Exit;

  { La primera tecla de contenido reemplaza por completo el valor que el
    control ya tenia al recibir el foco. }
  FBufferTexto := '';
  FBufferCursorPos := 0;
  FBufferSelStart := 0;
  FBufferSelLength := 0;
  FReemplazarBufferEnPrimeraEntrada := False;
end;

procedure TFrameTecladoVirtual.InsertarEnBuffer(const ATexto: string);
var
  P: Integer;
begin
  if ATexto = '' then
    Exit;

  PrepararPrimeraEntradaBuffer;

  P := FBufferSelStart;
  if P < 0 then P := 0;
  if P > Length(FBufferTexto) then P := Length(FBufferTexto);

  if FBufferSelLength > 0 then
    Delete(FBufferTexto, P + 1, FBufferSelLength);

  Insert(ATexto, FBufferTexto, P + 1);

  FBufferCursorPos := P + Length(ATexto);
  FBufferSelStart := FBufferCursorPos;
  FBufferSelLength := 0;
  FBufferModificado := True;
  ActualizarVisor;
end;

procedure TFrameTecladoVirtual.BorrarBuffer;
var
  P: Integer;
begin
  { Si BORRAR es la primera accion, entendemos que el usuario quiere editar
    el valor existente, no sustituirlo automaticamente. }
  FReemplazarBufferEnPrimeraEntrada := False;

  P := FBufferSelStart;

  if FBufferSelLength > 0 then
  begin
    Delete(FBufferTexto, P + 1, FBufferSelLength);
    FBufferSelLength := 0;
    FBufferCursorPos := P;
  end
  else if P > 0 then
  begin
    Delete(FBufferTexto, P, 1);
    Dec(P);
    FBufferCursorPos := P;
    FBufferSelStart := P;
  end;

  FBufferModificado := True;
  ActualizarVisor;
end;

procedure TFrameTecladoVirtual.LimpiarBuffer;
begin
  FReemplazarBufferEnPrimeraEntrada := False;
  FBufferTexto := '';
  FBufferCursorPos := 0;
  FBufferSelStart := 0;
  FBufferSelLength := 0;
  FBufferModificado := True;
  ActualizarVisor;
end;

procedure TFrameTecladoVirtual.InsertarDecimalBuffer;
var
  PosSep: Integer;
  HaySeparador: Boolean;
  SepSeleccionado: Boolean;
begin
  PrepararPrimeraEntradaBuffer;

  PosSep := Pos(FSeparadorDecimal, FBufferTexto);
  HaySeparador := PosSep > 0;
  SepSeleccionado := False;

  if HaySeparador then
  begin
    Dec(PosSep); { posicion base 0 }
    SepSeleccionado :=
      (FBufferSelLength > 0) and
      (PosSep >= FBufferSelStart) and
      (PosSep < FBufferSelStart + FBufferSelLength);
  end;

  if HaySeparador and not SepSeleccionado then
    Exit;

  InsertarEnBuffer(FSeparadorDecimal);
end;

procedure TFrameTecladoVirtual.CambiarSignoBuffer;
begin
  if not FPermitirNegativos then
    Exit;

  PrepararPrimeraEntradaBuffer;

  if (FBufferTexto <> '') and (FBufferTexto[1] = '-') then
  begin
    Delete(FBufferTexto, 1, 1);
    if FBufferSelStart > 0 then
      Dec(FBufferSelStart);
  end
  else
  begin
    Insert('-', FBufferTexto, 1);
    Inc(FBufferSelStart);
  end;

  FBufferCursorPos := FBufferSelStart;
  FBufferSelLength := 0;
  FBufferModificado := True;
  ActualizarVisor;
end;

function TFrameTecladoVirtual.ControlValido: Boolean;
begin
  Result :=
    Assigned(FControlActivo) and
    (FControlActivo is TCustomEdit) and
    FControlActivo.Enabled and
    FControlActivo.Visible and
    not TCustomEdit(FControlActivo).ReadOnly;
end;

function TFrameTecladoVirtual.ObtenerEditActivo: TCustomEdit;
begin
  Result := nil;

  if ControlValido then
    Result := TCustomEdit(FControlActivo);
end;

procedure TFrameTecladoVirtual.DarFocoControlActivo;
begin
  if not Assigned(FControlActivo) then
    Exit;

  if FControlActivo.CanFocus then
    FControlActivo.SetFocus;
end;

procedure TFrameTecladoVirtual.InsertarCaracter(AChar: Char);
var
  E: TCustomEdit;
begin
  if BufferActivo then
  begin
    InsertarEnBuffer(AChar);
    Exit;
  end;

  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  DarFocoControlActivo;

  SendMessage(
    E.Handle,
    WM_CHAR,
    WPARAM(Ord(AChar)),
    0
  );
end;

procedure TFrameTecladoVirtual.InsertarTexto(const ATexto: string);
var
  I: Integer;
begin
  if ATexto = '' then
    Exit;

  for I := 1 to Length(ATexto) do
    InsertarCaracter(ATexto[I]);
end;

procedure TFrameTecladoVirtual.Borrar;
var
  E: TCustomEdit;
begin
  if BufferActivo then
  begin
    BorrarBuffer;
    Exit;
  end;

  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  DarFocoControlActivo;

  SendMessage(
    E.Handle,
    WM_CHAR,
    VK_BACK,
    0
  );
end;

procedure TFrameTecladoVirtual.Limpiar;
var
  E: TCustomEdit;
begin
  if BufferActivo then
  begin
    LimpiarBuffer;
    Exit;
  end;

  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  DarFocoControlActivo;

  SendMessage(
    E.Handle,
    EM_SETSEL,
    0,
    LPARAM(-1)
  );

  SendMessage(
    E.Handle,
    WM_CHAR,
    VK_BACK,
    0
  );
end;

procedure TFrameTecladoVirtual.InsertarEspacio;
begin
  InsertarCaracter(' ');
end;

procedure TFrameTecladoVirtual.ProcesarEnter;
var
  E: TCustomEdit;
  F: TCustomForm;
begin
  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  DarFocoControlActivo;

  if (E is TCustomMemo) and FEnterSaltoLineaMemo then
  begin
    if BufferActivo then
      InsertarEnBuffer(sLineBreak)
    else
      SendMessage(
        E.Handle,
        WM_CHAR,
        VK_RETURN,
        0
      );

    Exit;
  end;

  { El valor temporal se vuelca al Edit antes de ejecutar cualquier
    validacion asociada a ENTER/OnExit. }
  if BufferActivo then
    ConfirmarBuffer;

  if Assigned(FOnEnterTeclado) then
    FOnEnterTeclado(Self);

  if FEnterSiguienteControl then
  begin
    F := GetParentForm(FControlActivo);

    if Assigned(F) then
      TWinControlAccess(F).SelectNext(FControlActivo, True, True);
  end;
end;

procedure TFrameTecladoVirtual.ObtenerSeleccion(
  AEdit: TCustomEdit;
  out AInicio: Integer;
  out AFin: Integer
);
var
  Inicio: DWORD;
  Fin: DWORD;
begin
  Inicio := 0;
  Fin := 0;

  SendMessage(
    AEdit.Handle,
    EM_GETSEL,
    WPARAM(@Inicio),
    LPARAM(@Fin)
  );

  AInicio := Integer(Inicio);
  AFin := Integer(Fin);
end;

function TFrameTecladoVirtual.SeparadorDecimalSeleccionado(
  AEdit: TCustomEdit
): Boolean;
var
  Inicio: Integer;
  Fin: Integer;
  PosSeparador: Integer;
begin
  Result := False;

  PosSeparador := Pos(FSeparadorDecimal, AEdit.Text);

  if PosSeparador = 0 then
    Exit;

  ObtenerSeleccion(AEdit, Inicio, Fin);

  Dec(PosSeparador);

  Result :=
    (PosSeparador >= Inicio) and
    (PosSeparador < Fin);
end;

procedure TFrameTecladoVirtual.InsertarDecimal;
var
  E: TCustomEdit;
begin
  if BufferActivo then
  begin
    InsertarDecimalBuffer;
    Exit;
  end;

  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  if Pos(FSeparadorDecimal, E.Text) > 0 then
  begin
    if not SeparadorDecimalSeleccionado(E) then
      Exit;
  end;

  InsertarCaracter(FSeparadorDecimal);
end;

procedure TFrameTecladoVirtual.EnviarTeclaFuncion(AVirtualKey: Word);
var
  Inputs: array[0..1] of TInput;
begin
  if AVirtualKey = 0 then
    Exit;

  { F12 y el resto de teclas de funcion deben trabajar con lo que el usuario
    acaba de escribir, por lo que se confirma el buffer antes de enviarlas. }
  if BufferActivo then
    ConfirmarBuffer;

  { El clic sobre una tecla virtual puede haber movido el foco al boton.
    Lo devolvemos al control que estaba editandose para que Windows procese
    F1..F12 igual que si procedieran de un teclado fisico. }
  DarFocoControlActivo;

  FillChar(Inputs, SizeOf(Inputs), 0);

  Inputs[0].Itype := INPUT_KEYBOARD;
  Inputs[0].ki.wVk := AVirtualKey;
  Inputs[0].ki.wScan := 0;
  Inputs[0].ki.dwFlags := 0;
  Inputs[0].ki.time := 0;
  Inputs[0].ki.dwExtraInfo := 0;

  Inputs[1].Itype := INPUT_KEYBOARD;
  Inputs[1].ki.wVk := AVirtualKey;
  Inputs[1].ki.wScan := 0;
  Inputs[1].ki.dwFlags := KEYEVENTF_KEYUP;
  Inputs[1].ki.time := 0;
  Inputs[1].ki.dwExtraInfo := 0;

  SendInput(
    Length(Inputs),
    Inputs[0],
    SizeOf(TInput)
  );
end;

procedure TFrameTecladoVirtual.CambiarSigno;
var
  E: TCustomEdit;
  Inicio: Integer;
  Fin: Integer;
begin
  if not FPermitirNegativos then
    Exit;

  if BufferActivo then
  begin
    CambiarSignoBuffer;
    Exit;
  end;

  E := ObtenerEditActivo;

  if not Assigned(E) then
    Exit;

  DarFocoControlActivo;
  ObtenerSeleccion(E, Inicio, Fin);

  if E.Text <> '' then
  begin
    if E.Text[1] = '-' then
    begin
      SendMessage(E.Handle, EM_SETSEL, 0, 1);
      SendMessage(E.Handle, WM_CHAR, VK_BACK, 0);

      if Inicio > 0 then
        Dec(Inicio);

      if Fin > 0 then
        Dec(Fin);

      SendMessage(E.Handle, EM_SETSEL, Inicio, Fin);
    end
    else
    begin
      SendMessage(E.Handle, EM_SETSEL, 0, 0);
      InsertarCaracter('-');

      Inc(Inicio);
      Inc(Fin);

      SendMessage(E.Handle, EM_SETSEL, Inicio, Fin);
    end;
  end
  else
    InsertarCaracter('-');
end;

function TFrameTecladoVirtual.ObtenerControlConFoco: TWinControl;
var
  H: HWND;
  C: TWinControl;
  FormTeclado: TCustomForm;
  FormControl: TCustomForm;
begin
  Result := nil;

  H := GetFocus;

  if H = 0 then
    Exit;

  C := FindControl(H);

  if not Assigned(C) then
    Exit;

  FormTeclado := GetParentForm(Self);
  FormControl := GetParentForm(C);

  if Assigned(FormTeclado) and
     Assigned(FormControl) and
     (FormTeclado = FormControl) then
  begin
    Result := C;
  end;
end;

function TFrameTecladoVirtual.EstaDentroDelTeclado(
  AControl: TControl
): Boolean;
var
  C: TControl;
begin
  Result := False;
  C := AControl;

  while Assigned(C) do
  begin
    if C = Self then
    begin
      Result := True;
      Exit;
    end;

    C := C.Parent;
  end;
end;

function TFrameTecladoVirtual.EsControlEditable(
  AControl: TWinControl
): Boolean;
begin
  Result :=
    Assigned(AControl) and
    (AControl is TCustomEdit) and
    AControl.Enabled and
    AControl.Visible;

  if not Result then
    Exit;

  if TCustomEdit(AControl).ReadOnly then
    Result := False;
end;

function TFrameTecladoVirtual.DeterminarTipoTeclado(
  AControl: TWinControl
): TTipoTeclado;
var
  TipoRegistrado: TTipoTeclado;
begin
  Result := FTipoPorDefecto;

  if not Assigned(AControl) then
    Exit;

  { 1. Configuracion explicita }
  if FConfiguracionControles.TryGetValue(AControl, TipoRegistrado) then
  begin
    Result := TipoRegistrado;
    Exit;
  end;

  { 2. TDBEdit: se mira el tipo de TField }
  if AControl is TDBEdit then
  begin
    if CampoDBEsNumerico(AControl) then
      Result := ttNumerico
    else
      Result := ttAlfanumerico;

    Exit;
  end;

  { 3. TEdit normal con NumbersOnly }
  if AControl is TEdit then
  begin
    if TEdit(AControl).NumbersOnly then
    begin
      Result := ttNumerico;
      Exit;
    end;
  end;

  Result := FTipoPorDefecto;
end;

function TFrameTecladoVirtual.CampoDBEsNumerico(
  AControl: TWinControl
): Boolean;
var
  DBEdit: TDBEdit;
  Campo: TField;
begin
  Result := False;

  if not (AControl is TDBEdit) then
    Exit;

  DBEdit := TDBEdit(AControl);

  if not Assigned(DBEdit.DataSource) then
    Exit;

  if not Assigned(DBEdit.DataSource.DataSet) then
    Exit;

  if DBEdit.DataField = '' then
    Exit;

  Campo := DBEdit.DataSource.DataSet.FindField(DBEdit.DataField);

  if not Assigned(Campo) then
    Exit;

  Result := Campo.DataType in [
    ftSmallint,
    ftInteger,
    ftWord,
    ftFloat,
    ftCurrency,
    ftBCD,
    ftAutoInc,
    ftLargeint,
    ftFMTBcd
  ];
end;

procedure TFrameTecladoVirtual.TimerDeteccionTimer(Sender: TObject);
var
  ControlFoco: TWinControl;
  NuevoTipo: TTipoTeclado;
begin
  if not FDeteccionAutomatica then
    Exit;

  ControlFoco := ObtenerControlConFoco;

  { Si se esta pulsando una tecla del teclado, no cambiamos
    ni ocultamos el teclado. }
  if Assigned(ControlFoco) and EstaDentroDelTeclado(ControlFoco) then
    Exit;

  if Assigned(ControlFoco) and EsControlEditable(ControlFoco) then
  begin
    NuevoTipo := DeterminarTipoTeclado(ControlFoco);

    if FControlActivo <> ControlFoco then
      SetControlActivo(ControlFoco)
    else if BufferActivo and not FBufferModificado and
            (TCustomEdit(ControlFoco).Text <> FBufferTexto) then
      CargarBufferDesdeControl;

    if FTipoTeclado <> NuevoTipo then
      SetTipoTeclado(NuevoTipo);

    if FAutoMostrar then
    begin
      if not Visible then
      begin
        Visible := True;

        if Assigned(Parent) then
          Parent.Realign;
      end;

      BringToFront;
    end;

    if Visible then
      AjustarVistaAlControl(ControlFoco);
  end
  else
  begin
    if FAutoOcultar then
    begin
      OcultarTeclado;
      SetControlActivo(nil);
    end;
  end;
end;

procedure TFrameTecladoVirtual.RegistrarControl(
  AControl: TWinControl;
  ATipo: TTipoTeclado
);
begin
  if not Assigned(AControl) then
    Exit;

  FConfiguracionControles.Remove(AControl);
  FConfiguracionControles.Add(AControl, ATipo);

  AControl.FreeNotification(Self);
end;

procedure TFrameTecladoVirtual.RegistrarNumerico(AControl: TWinControl);
begin
  RegistrarControl(AControl, ttNumerico);
end;

procedure TFrameTecladoVirtual.RegistrarAlfanumerico(AControl: TWinControl);
begin
  RegistrarControl(AControl, ttAlfanumerico);
end;

procedure TFrameTecladoVirtual.QuitarConfiguracion(AControl: TWinControl);
begin
  if not Assigned(AControl) then
    Exit;

  FConfiguracionControles.Remove(AControl);
end;

procedure TFrameTecladoVirtual.LimpiarConfiguracionControles;
begin
  FConfiguracionControles.Clear;
end;

function TFrameTecladoVirtual.BuscarContenedorScroll(
  AControl: TWinControl
): TScrollingWinControl;
var
  C: TWinControl;
  F: TCustomForm;
begin
  Result := nil;

  if not Assigned(AControl) then
    Exit;

  C := AControl.Parent;

  while Assigned(C) do
  begin
    if C is TScrollBox then
    begin
      Result := TScrollingWinControl(C);
      Exit;
    end;

    C := C.Parent;
  end;

  { Alternativa: formulario con AutoScroll activado }
  F := GetParentForm(AControl);

  if Assigned(F) and TCustomFormAccess(F).AutoScroll then
    Result := F;
end;

procedure TFrameTecladoVirtual.PrepararContenedorScroll(
  AContenedor: TScrollingWinControl
);
begin
  if not Assigned(AContenedor) then
    Exit;

  if FContenedorScrollActual = AContenedor then
    Exit;

  RestaurarVista;

  FContenedorScrollActual := AContenedor;
  FPosicionScrollOriginal := AContenedor.VertScrollBar.Position;
  FScrollOriginalGuardado := True;

  AContenedor.FreeNotification(Self);
end;

procedure TFrameTecladoVirtual.AjustarVistaAlControl(
  AControl: TWinControl
);
var
  Contenedor: TScrollingWinControl;
  PosControl: TPoint;
  PosContenedor: TPoint;
  PosTeclado: TPoint;
  ControlTop: Integer;
  ControlBottom: Integer;
  VisibleTop: Integer;
  VisibleBottom: Integer;
  Delta: Integer;
  NuevaPosicion: Integer;
begin
  if not FAjustarVistaAutomaticamente then
    Exit;

  if not Visible then
    Exit;

  if not Assigned(AControl) then
    Exit;

  Contenedor := BuscarContenedorScroll(AControl);

  if not Assigned(Contenedor) then
    Exit;

  PrepararContenedorScroll(Contenedor);

  PosControl := AControl.ClientToScreen(Point(0, 0));

  ControlTop := PosControl.Y;
  ControlBottom := PosControl.Y + AControl.Height;

  PosContenedor := Contenedor.ClientToScreen(Point(0, 0));

  VisibleTop := PosContenedor.Y + FMargenVisibilidad;
  VisibleBottom :=
    PosContenedor.Y +
    Contenedor.ClientHeight -
    FMargenVisibilidad;

  PosTeclado := ClientToScreen(Point(0, 0));

  if PosTeclado.Y < VisibleBottom then
    VisibleBottom := PosTeclado.Y - FMargenVisibilidad;

  Delta := 0;

  if ControlBottom > VisibleBottom then
    Delta := ControlBottom - VisibleBottom
  else if ControlTop < VisibleTop then
    Delta := ControlTop - VisibleTop;

  if Delta = 0 then
    Exit;

  NuevaPosicion :=
    Contenedor.VertScrollBar.Position + Delta;

  if NuevaPosicion < 0 then
    NuevaPosicion := 0;

  Contenedor.VertScrollBar.Position := NuevaPosicion;
end;

procedure TFrameTecladoVirtual.RestaurarVista;
begin
  if not FScrollOriginalGuardado then
    Exit;

  if Assigned(FContenedorScrollActual) and
     FRestaurarScrollAlOcultar then
  begin
    FContenedorScrollActual.VertScrollBar.Position :=
      FPosicionScrollOriginal;
  end;

  FContenedorScrollActual := nil;
  FPosicionScrollOriginal := 0;
  FScrollOriginalGuardado := False;
end;

procedure TFrameTecladoVirtual.MostrarInterno;
begin
  if not FInicializado then
    Inicializar;

  if not Visible then
  begin
    Visible := True;

    if Assigned(Parent) then
      Parent.Realign;
  end;

  BringToFront;
  DarFocoControlActivo;

  if Assigned(FControlActivo) then
    AjustarVistaAlControl(FControlActivo);
end;

procedure TFrameTecladoVirtual.MostrarPara(
  AControl: TWinControl;
  ATipo: TTipoTeclado
);
begin
  SetControlActivo(AControl);
  SetTipoTeclado(ATipo);
  MostrarInterno;
end;

procedure TFrameTecladoVirtual.MostrarAlfanumerico;
begin
  SetTipoTeclado(ttAlfanumerico);
  MostrarInterno;
end;

procedure TFrameTecladoVirtual.MostrarNumerico;
begin
  SetTipoTeclado(ttNumerico);
  MostrarInterno;
end;

procedure TFrameTecladoVirtual.OcultarTeclado;
begin
  if Visible then
  begin
    Visible := False;

    if Assigned(Parent) then
      Parent.Realign;
  end;

  { Ocultar no confirma datos pendientes. Solo ENTER o una tecla de funcion
    confirma el buffer. }
  FBufferModificado := False;
  if Assigned(FEditVisor) then
    FEditVisor.Text := '';

  RestaurarVista;
end;

end.
