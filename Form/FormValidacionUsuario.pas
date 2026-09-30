unit FormValidacionUsuario;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  DmDatos,
  uFrameTecladoVirtual;

type
  TFrmValidacion = class(TForm)
    lblError: TLabel;
    ledClave: TLabeledEdit;
    bAcceder: TButton;
    cbUsuario: TComboBox;
    Label1: TLabel;

    procedure bAccederClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ledClaveClick(Sender: TObject);
    procedure ledClaveEnter(Sender: TObject);

  private
    FValido: Boolean;
    FBd: TdmdDatos;
    FTeclado: TFrameTecladoVirtual;

    { Tamano original del dialogo antes de mostrar el teclado }
    FClientWidthOriginal: Integer;
    FClientHeightOriginal: Integer;
    FTamanoOriginalGuardado: Boolean;

    procedure CrearTecladoVirtual;
    procedure TecladoEnter(Sender: TObject);
    procedure GuardarTamanoOriginal;
    procedure AjustarFormularioParaTeclado;

  public
    procedure Inicializa(vBd: TdmdDatos);
    function GetIDComputerName: String;
    procedure CargaComboUsuarios;

    property Valido: Boolean read FValido write FValido;
    property Bd: TdmdDatos read FBd write FBd;
  end;

var
  FrmValidacion: TFrmValidacion;

implementation

{$R *.dfm}

procedure TFrmValidacion.CrearTecladoVirtual;
begin
  if Assigned(FTeclado) then
    Exit;

  { El formulario es el propietario del teclado. Se liberara automaticamente
    cuando se destruya TFrmValidacion. }
  FTeclado := TFrameTecladoVirtual.Create(Self);

  { IMPORTANTE para Delphi XE10:
    primero se asigna Parent y despues se llama a Inicializar. }
  FTeclado.Parent := Self;
  FTeclado.Align := alBottom;
  { En validacion no necesitamos F1-F12. El teclado alfanumerico queda
    en 5 filas y por tanto puede ser bastante mas compacto. }
  FTeclado.MostrarTeclasFuncion := False;
  FTeclado.Height := 300;

  { Aspecto }
  FTeclado.TamanoFuente := 17;
  FTeclado.EspacioEntreTeclas := 4;

  { En este dialogo controlamos manualmente cuando aparece el teclado.
    Esto permite ampliar primero el formulario y mostrar despues el teclado,
    evitando que se superponga sobre los controles. }
  FTeclado.DeteccionAutomatica := False;
  FTeclado.AutoMostrar := False;
  FTeclado.AutoOcultar := False;

  { Aqui no necesitamos desplazar un ScrollBox: ampliamos el propio dialogo. }
  FTeclado.AjustarVistaAutomaticamente := False;
  FTeclado.RestaurarScrollAlOcultar := False;
  FTeclado.MargenVisibilidad := 20;

  FTeclado.PermitirNegativos := True;

  { En este formulario ENTER no debe saltar a otro campo:
    debe validar usuario/clave. }
  FTeclado.EnterSiguienteControl := False;
  FTeclado.EnterSaltoLineaMemo := True;
  FTeclado.OnEnterTeclado := TecladoEnter;

  { La clave puede contener letras y numeros. }
  FTeclado.RegistrarAlfanumerico(ledClave);

  { Crear las teclas solo cuando el panel ya tiene Parent. }
  FTeclado.Inicializar;
end;

procedure TFrmValidacion.GuardarTamanoOriginal;
begin
  if FTamanoOriginalGuardado then
    Exit;

  FClientWidthOriginal := ClientWidth;
  FClientHeightOriginal := ClientHeight;
  FTamanoOriginalGuardado := True;
end;

procedure TFrmValidacion.AjustarFormularioParaTeclado;
const
  { 10 teclas por fila en el QWERTY. 760 px da teclas suficientemente
    grandes en una tablet, pero nunca se supera el FormPrincipal. }
  ANCHO_RECOMENDADO = 760;
  ALTO_TECLADO = 300;
  MARGEN_FORM_PRINCIPAL = 8;
var
  FormReferencia: TCustomForm;
  AreaLimite: TRect;
  MonitorActual: TMonitor;

  AnchoArea: Integer;
  AltoArea: Integer;
  AnchoBordes: Integer;
  AltoBordes: Integer;

  AnchoMaxCliente: Integer;
  AltoMaxCliente: Integer;
  NuevoAnchoCliente: Integer;
  NuevoAltoCliente: Integer;
  AltoDisponibleTeclado: Integer;
begin
  if not Assigned(FTeclado) then
    Exit;

  GuardarTamanoOriginal;

  { Normalmente Owner es FrmPrincipal porque se crea con:
      TFrmValidacion.Create(Self)
    Por tanto usamos el propio FormPrincipal como limite fisico. }
  FormReferencia := nil;

  if Owner is TCustomForm then
    FormReferencia := TCustomForm(Owner);

  if Assigned(FormReferencia) then
  begin
    AreaLimite := FormReferencia.BoundsRect;
  end
  else
  begin
    { Fallback por si alguna vez el dialogo se crea sin FormPrincipal. }
    MonitorActual := Screen.MonitorFromWindow(Handle, mdNearest);

    if Assigned(MonitorActual) then
      AreaLimite := MonitorActual.WorkareaRect
    else
      AreaLimite := Screen.WorkAreaRect;
  end;

  AnchoArea := AreaLimite.Right - AreaLimite.Left;
  AltoArea := AreaLimite.Bottom - AreaLimite.Top;

  { ClientWidth/ClientHeight no incluyen bordes ni barra de titulo. }
  AnchoBordes := Width - ClientWidth;
  AltoBordes := Height - ClientHeight;

  AnchoMaxCliente :=
    AnchoArea - AnchoBordes - (MARGEN_FORM_PRINCIPAL * 2);

  AltoMaxCliente :=
    AltoArea - AltoBordes - (MARGEN_FORM_PRINCIPAL * 2);

  if AnchoMaxCliente < 1 then
    AnchoMaxCliente := 1;

  if AltoMaxCliente < 1 then
    AltoMaxCliente := 1;

  { No hacemos el dialogo mas ancho de lo necesario, pero si el DFM es
    estrecho lo ampliamos para que las diez teclas de cada fila sean comodas. }
  NuevoAnchoCliente := FClientWidthOriginal;

  if NuevoAnchoCliente < ANCHO_RECOMENDADO then
    NuevoAnchoCliente := ANCHO_RECOMENDADO;

  if NuevoAnchoCliente > AnchoMaxCliente then
    NuevoAnchoCliente := AnchoMaxCliente;

  { El teclado de validacion no tiene F1-F12: solo necesita 5 filas. }
  FTeclado.Height := ALTO_TECLADO;

  AltoDisponibleTeclado :=
    AltoMaxCliente - FClientHeightOriginal;

  { Regla estricta: el formulario de validacion nunca puede superar
    el alto del FormPrincipal. Si no caben 300 px, el teclado se reduce. }
  if FTeclado.Height > AltoDisponibleTeclado then
  begin
    if AltoDisponibleTeclado > 0 then
      FTeclado.Height := AltoDisponibleTeclado
    else
      FTeclado.Height := 1;
  end;

  NuevoAltoCliente :=
    FClientHeightOriginal + FTeclado.Height;

  if NuevoAltoCliente > AltoMaxCliente then
    NuevoAltoCliente := AltoMaxCliente;

  Position := poDesigned;
  ClientWidth := NuevoAnchoCliente;
  ClientHeight := NuevoAltoCliente;

  { Centramos el dialogo dentro de FormPrincipal, no respecto al monitor. }
  Left :=
    AreaLimite.Left +
    ((AnchoArea - Width) div 2);

  Top :=
    AreaLimite.Top +
    ((AltoArea - Height) div 2);

  { Seguridad adicional: nunca salir del rectangulo del principal. }
  if Left < AreaLimite.Left + MARGEN_FORM_PRINCIPAL then
    Left := AreaLimite.Left + MARGEN_FORM_PRINCIPAL;

  if Top < AreaLimite.Top + MARGEN_FORM_PRINCIPAL then
    Top := AreaLimite.Top + MARGEN_FORM_PRINCIPAL;

  if Left + Width > AreaLimite.Right - MARGEN_FORM_PRINCIPAL then
    Left := AreaLimite.Right - MARGEN_FORM_PRINCIPAL - Width;

  if Top + Height > AreaLimite.Bottom - MARGEN_FORM_PRINCIPAL then
    Top := AreaLimite.Bottom - MARGEN_FORM_PRINCIPAL - Height;
end;

procedure TFrmValidacion.TecladoEnter(Sender: TObject);
begin
  { ENTER del teclado virtual equivale a pulsar ACCEDER. }
  bAccederClick(bAcceder);
end;

procedure TFrmValidacion.bAccederClick(Sender: TObject);
begin
  { Evitamos acceder a Items[-1] si todavia no hay usuario seleccionado. }
  if cbUsuario.ItemIndex < 0 then
  begin
    lblError.Caption := 'Seleccione un usuario';
    lblError.Visible := True;
    cbUsuario.SetFocus;
    Exit;
  end;

  if Bd.UsuarioValido(
       cbUsuario.Items[cbUsuario.ItemIndex],
       ledClave.Text
     ) then
  begin
    lblError.Visible := False;
    Valido := True;

    Bd.Equipo := GetIDComputerName;
    Bd.GuardaLog(
      'Acceso del operario: ' + Bd.UsuarioLog
    );

    Close;
  end
  else
  begin
    lblError.Visible := True;
    Valido := False;

    Bd.GuardaLog(
      'Intento de acceso con usuario: ' +
      cbUsuario.Items[cbUsuario.ItemIndex] +
      ' y clave : ' + ledClave.Text
    );

    { Dejamos preparada la clave para volver a escribirla. }
    ledClave.SetFocus;
    ledClave.SelectAll;
  end;
end;

procedure TFrmValidacion.CargaComboUsuarios;
begin
  cbUsuario.Items.BeginUpdate;
  try
    cbUsuario.Items.Clear;

    Bd.BuscaUsuarios;

    with Bd.sqlUsuarios do
    begin
      First;

      while not Eof do
      begin
        cbUsuario.Items.Add(
          FieldByName('ge_usuario').AsString
        );

        Next;
      end;
    end;

    { Dejamos un usuario seleccionado por defecto para evitar ItemIndex = -1. }
    if cbUsuario.Items.Count > 0 then
      cbUsuario.ItemIndex := 0;
  finally
    cbUsuario.Items.EndUpdate;
  end;
end;

procedure TFrmValidacion.FormClose(
  Sender: TObject;
  var Action: TCloseAction
);
begin
  { El formulario se libera despues del ShowModal desde FormPrincipal. }
  Action := caHide;
end;

procedure TFrmValidacion.FormShow(Sender: TObject);
begin
  { Primero se selecciona el usuario. El teclado aparecera automaticamente
    cuando el foco llegue a ledClave. }
  cbUsuario.SetFocus;
end;

function TFrmValidacion.GetIDComputerName: String;
begin
  { Para Terminal Server primero intentamos CLIENTNAME.
    En local utilizamos COMPUTERNAME. }
  Result := GetEnvironmentVariable('CLIENTNAME');

  if Length(Result) = 0 then
    Result := GetEnvironmentVariable('COMPUTERNAME');
end;

procedure TFrmValidacion.Inicializa(vBd: TdmdDatos);
begin
  Bd := vBd;
  Valido := False;

  { Guardamos el tamano del DFM antes de que el teclado pueda modificarlo. }
  FTamanoOriginalGuardado := False;
  GuardarTamanoOriginal;

  CargaComboUsuarios;
  CrearTecladoVirtual;
end;

procedure TFrmValidacion.ledClaveClick(Sender: TObject);
begin
  ledClave.SelectAll;
end;

procedure TFrmValidacion.ledClaveEnter(Sender: TObject);
begin
  if Assigned(FTeclado) then
  begin
    { Primero hacemos sitio fisico debajo de los controles del dialogo. }
    AjustarFormularioParaTeclado;

    { Despues mostramos el teclado. Al estar Align = alBottom, aparecera
      debajo del contenido original y no encima de los controles. }
    FTeclado.MostrarPara(
      ledClave,
      ttAlfanumerico
    );
  end;
end;

end.
