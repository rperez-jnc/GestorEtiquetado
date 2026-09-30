unit JncBusqueda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, JvExDBGrids, JvDBGrid,
  JvDBUltimGrid, Maestro, dmMaestro, SQLServerDataModule, Vcl.ActnList, JNCSqlParametros,
  Data.DB, System.Actions, JncFraCxGrid, JncGridDx,  dmImagenes, Vcl.Buttons, cxGridCustomTableView,
  cxEdit,Registry, cxLocalization, cxStyles, cxClasses, FormTecladoBusqueda;

type
  TfrmSeleccion = class(TForm)
    edTextoBusqueda: TEdit;
    bttBuscar: TButton;
    pnInferior: TPanel;
    pnSuperior: TPanel;
    acList: TActionList;
    acFiltrar: TAction;
    bttAceptar: TBitBtn;
    bttCancelar: TBitBtn;
    btnSalir2: TBitBtn;
    GridBusqueda: TfraCxGrid;
    acAceptar: TAction;
    acCancelar: TAction;
    procedure bttCancelarClick(Sender: TObject);
    procedure AceptaSeleccion(Sender: TObject);
    procedure bttBuscarClick(Sender: TObject);
    procedure GridBusquedaantDblClick(Sender: TObject);
    procedure acFiltrarExecute(Sender: TObject);
    procedure edTextoBusquedaKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure GridBusquedadbtvDatosDblClick(Sender: TObject);
    procedure btnSalir2Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure acAceptarExecute(Sender: TObject);
    procedure acCancelarExecute(Sender: TObject);
    procedure GridBusquedadbtvDatosKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edTextoBusquedaClick(Sender: TObject);




  private
    FAccesoBD: TdmdMaestro;
    FTipoMaestro: TMaestro;
    FCondicion: String;
    FAdicionales: string;
    FRelacionados: string;
    FCamposBusquedaExtra: string;
    FTeclado: boolean;
  public
    constructor Create(AOwner: TComponent; lFicheroIni: TFileName; vTipoMaestro: TMaestro); reintroduce;overload;
    constructor Create(AOwner: TComponent; lFicheroIni: TFileName; vTipoMaestro: TMaestro; vTeclado:boolean); reintroduce; overload;
    property BD: TdmdMaestro read FAccesoBD write FAccesoBD;
    property TipoMaestro: TMaestro read FTipoMaestro write FTipoMaestro;
    property Teclado: boolean read FTeclado write FTeclado;

    property Condicion : String read FCondicion write FCondicion;
    property Adicionales: string read FAdicionales write FAdicionales;
    property Relacionados: string read FRelacionados write FRelacionados;
    property CamposBusquedaExtra: string read FCamposBusquedaExtra write FCamposBusquedaExtra;
    procedure Muestra; overload;
    procedure Muestra(vCondicion:string); overload;
    procedure Muestra(vCondicion:string; vAdicionales:String); overload;
    procedure Muestra(vCondicion:string; vAdicionales:String; vRelacionados:string); overload;
    procedure Muestra(vCondicion:string; vAdicionales:String; vRelacionados:string; vCamposBusquedaExtra:string); overload;
    procedure Muestra(vSQl:string;vNombreTabla:string;vPasoSQL:boolean); overload;

    procedure MuestraSinDatos; overload;
    procedure MuestraSinDatos(vCondicion:string); overload;
    procedure MuestraSinDatos(vCondicion:string; vAdicionales:String); overload;
    procedure MuestraSinDatos(vCondicion:string; vAdicionales:String; vRelacionados:string); overload;
    procedure MuestraSinDatos(vCondicion:string; vAdicionales:String; vRelacionados:string; vCamposBusquedaExtra:string); overload;
    procedure MuestraSinDatos(vSQl:string;vNombreTabla:string;vPasoSQL:boolean); overload;
    function HayBusqueda: boolean;
    function SinRegistros: boolean;
    function NombreMaestro(vCodigo: string): string; overload;
    function NombreMaestro(vCodigo, vSQL: string): string; overload;
    function NombreMaestro(vCodigo, vCondicion: string; vCondicional:boolean): string; overload;

    function BuscaPrimero:string;
    function BuscaUltimo:string;
    function BuscaPrimeroCondicion(vCondicion: string): string;
    function BuscaUltimoCondicion(vCondicion: string): string;

    procedure busca;  overload;
    procedure busca(vCondicion: string); overload;
    procedure busca(vCondicion: string; vAdicionales:string); overload;
    procedure busca(vCondicion: string; vAdicionales:string; vRelacionados:string); overload;
    procedure busca(vCondicion: string; vAdicionales:string; vRelacionados:string; vCamposBusquedaExtra:string); overload;
    procedure busca(vSQl:string;vPasoSQL:boolean); overload;

    procedure buscaSinDatos;  overload;
    procedure buscaSinDatos(vCondicion: string); overload;
    procedure buscaSinDatos(vCondicion: string; vAdicionales:string); overload;
    procedure buscaSinDatos(vCondicion: string; vAdicionales:string; vRelacionados:string); overload;
    procedure buscaSinDatos(vCondicion: string; vAdicionales:string; vRelacionados:string; vCamposBusquedaExtra:string); overload;
    procedure buscaSinDatos(vSQl:string;vPasoSQL:boolean); overload;



    function DevuelveCodigo():string;
    function ExisteCodigo(vCodigo:string):boolean;

    procedure MemoWin(Form:TForm);
    procedure RecallWin(Form:TForm);
  end;

var
  FrmBusqueda: TFrmSeleccion;
  TecladoFlotante : TFrmTecladoBusqueda;
implementation

uses
  uEstiloBusquedaTablet,
  uFrameTecladoVirtual;

{$R *.dfm}

const
  NOMBRE_TECLADO_VIRTUAL_BUSQUEDA = 'TecladoVirtualBusqueda';

function ObtenerTecladoVirtualBusqueda(
  AForm: TfrmSeleccion;
  ACrear: Boolean
): TFrameTecladoVirtual;
var
  C: TComponent;
  LAltura: Integer;
begin
  Result := nil;

  if not Assigned(AForm) then
    Exit;

  C := AForm.FindComponent(NOMBRE_TECLADO_VIRTUAL_BUSQUEDA);

  if C is TFrameTecladoVirtual then
    Result := TFrameTecladoVirtual(C);

  if Assigned(Result) or not ACrear then
    Exit;

  Result := TFrameTecladoVirtual.Create(AForm);
  Result.Name := NOMBRE_TECLADO_VIRTUAL_BUSQUEDA;
  Result.Parent := AForm;
  Result.Align := alBottom;

  { Mismo criterio de tamano que el teclado del formulario principal,
    pero evitando que una pantalla pequena se quede sin zona de grid. }
  LAltura := 410;
  if AForm.ClientHeight < 700 then
    LAltura := AForm.ClientHeight div 2;
  if LAltura < 280 then
    LAltura := 280;

  Result.Height := LAltura;
  Result.TamanoFuente := 18;
  Result.EspacioEntreTeclas := 5;

  { En la busqueda solo editamos edTextoBusqueda. No dejamos activo el
    detector automatico para que no reaparezca el teclado al enfocar el grid. }
  Result.DeteccionAutomatica := False;
  Result.AutoMostrar := False;
  Result.AutoOcultar := False;

  Result.AjustarVistaAutomaticamente := False;
  Result.RestaurarScrollAlOcultar := False;
  Result.MargenVisibilidad := 20;

  Result.PermitirNegativos := True;
  Result.EnterSiguienteControl := False;
  Result.EnterSaltoLineaMemo := False;
  Result.MostrarTeclasFuncion := True;

  { El campo de busqueda permanece visible encima del teclado, por lo que
    escribimos directamente en el Edit. Esto permite tambien pulsar el boton
    Buscar sin tener que confirmar previamente un buffer. }
  Result.MostrarVisorTexto := False;
  Result.UsarBufferTexto := False;

  { ENTER en nuestro teclado equivale al boton Buscar. }
  Result.OnEnterTeclado := AForm.bttBuscarClick;

  Result.Inicializar;
end;

procedure MostrarTecladoVirtualBusqueda(AForm: TfrmSeleccion);
var
  LTeclado: TFrameTecladoVirtual;
begin
  if not Assigned(AForm) or not AForm.Teclado then
    Exit;

  LTeclado := ObtenerTecladoVirtualBusqueda(AForm, True);
  if not Assigned(LTeclado) then
    Exit;

  AForm.edTextoBusqueda.SelectAll;
  LTeclado.MostrarPara(AForm.edTextoBusqueda, ttAlfanumerico);
end;

procedure OcultarTecladoVirtualBusqueda(AForm: TfrmSeleccion);
var
  LTeclado: TFrameTecladoVirtual;
begin
  LTeclado := ObtenerTecladoVirtualBusqueda(AForm, False);

  if not Assigned(LTeclado) then
    Exit;

  LTeclado.OcultarTeclado;
  LTeclado.ControlActivo := nil;
end;

function FormularioReferenciaBusqueda(AForm: TfrmSeleccion): TCustomForm;
var
  C: TComponent;
begin
  Result := nil;

  if not Assigned(AForm) then
    Exit;

  if AForm.Owner is TCustomForm then
    Result := TCustomForm(AForm.Owner)
  else if AForm.Owner is TControl then
    Result := GetParentForm(TControl(AForm.Owner));

  if not Assigned(Result) then
  begin
    C := AForm.Owner;
    while Assigned(C) do
    begin
      if C is TCustomForm then
      begin
        Result := TCustomForm(C);
        Break;
      end;

      if C is TControl then
      begin
        Result := GetParentForm(TControl(C));
        if Assigned(Result) then
          Break;
      end;

      C := C.Owner;
    end;
  end;

  if (not Assigned(Result)) and Assigned(Screen.ActiveCustomForm) and
     (Screen.ActiveCustomForm <> AForm) then
    Result := Screen.ActiveCustomForm;

  if Result = AForm then
    Result := nil;
end;

procedure AplicarAspectoBusquedaTablet(AForm: TfrmSeleccion);
const
  MARGEN_LATERAL = 24;
  SEPARACION = 16;
  ALTO_SUPERIOR = 96;
  ALTO_INFERIOR = 86;
  ALTO_BOTON = 54;
var
  FrmRef: TCustomForm;
  TotalBotones: Integer;
  X: Integer;
  StContenido: TcxStyle;
  StCabecera: TcxStyle;
begin
  if not Assigned(AForm) then
    Exit;

  FrmRef := FormularioReferenciaBusqueda(AForm);
  AplicarEstiloBusquedaTablet(AForm, FrmRef);

  AForm.pnSuperior.Height := ALTO_SUPERIOR;
  AForm.pnInferior.Height := ALTO_INFERIOR;

  AForm.edTextoBusqueda.ParentFont := False;
  AForm.edTextoBusqueda.Font.Name := AForm.Font.Name;
  AForm.edTextoBusqueda.Font.Size := 18;
  AForm.edTextoBusqueda.AutoSize := False;
  AForm.edTextoBusqueda.Left := MARGEN_LATERAL;
  AForm.edTextoBusqueda.Top := 21;
  AForm.edTextoBusqueda.Height := 50;

  AForm.bttBuscar.ParentFont := False;
  AForm.bttBuscar.Font.Name := AForm.Font.Name;
  AForm.bttBuscar.Font.Size := 16;
  AForm.bttBuscar.Font.Style := [fsBold];
  AForm.bttBuscar.Width := 190;
  AForm.bttBuscar.Height := ALTO_BOTON;
  AForm.bttBuscar.Top := 18;
  AForm.bttBuscar.Left := AForm.pnSuperior.ClientWidth -
    MARGEN_LATERAL - AForm.bttBuscar.Width;

  AForm.edTextoBusqueda.Width := AForm.bttBuscar.Left -
    AForm.edTextoBusqueda.Left - 18;

  AForm.bttAceptar.ParentFont := False;
  AForm.bttAceptar.Font.Name := AForm.Font.Name;
  AForm.bttAceptar.Font.Size := 15;
  AForm.bttAceptar.Font.Style := [fsBold];
  AForm.bttAceptar.Width := 190;
  AForm.bttAceptar.Height := ALTO_BOTON;

  AForm.bttCancelar.ParentFont := False;
  AForm.bttCancelar.Font.Name := AForm.Font.Name;
  AForm.bttCancelar.Font.Size := 15;
  AForm.bttCancelar.Font.Style := [fsBold];
  AForm.bttCancelar.Width := 210;
  AForm.bttCancelar.Height := ALTO_BOTON;

  AForm.btnSalir2.ParentFont := False;
  AForm.btnSalir2.Font.Name := AForm.Font.Name;
  AForm.btnSalir2.Font.Size := 15;
  AForm.btnSalir2.Font.Style := [fsBold];
  AForm.btnSalir2.Width := 150;
  AForm.btnSalir2.Height := ALTO_BOTON;

  TotalBotones := AForm.bttAceptar.Width +
    AForm.bttCancelar.Width + AForm.btnSalir2.Width +
    (SEPARACION * 2);

  X := (AForm.pnInferior.ClientWidth - TotalBotones) div 2;
  if X < MARGEN_LATERAL then
    X := MARGEN_LATERAL;

  AForm.bttAceptar.Left := X;
  AForm.bttAceptar.Top := (ALTO_INFERIOR - ALTO_BOTON) div 2;

  AForm.bttCancelar.Left := AForm.bttAceptar.Left +
    AForm.bttAceptar.Width + SEPARACION;
  AForm.bttCancelar.Top := AForm.bttAceptar.Top;

  AForm.btnSalir2.Left := AForm.bttCancelar.Left +
    AForm.bttCancelar.Width + SEPARACION;
  AForm.btnSalir2.Top := AForm.bttAceptar.Top;

  AForm.GridBusqueda.Font.Name := AForm.Font.Name;
  AForm.GridBusqueda.Font.Size := 15;

  StContenido := AForm.FindComponent('stBusquedaContenidoTablet') as TcxStyle;
  if not Assigned(StContenido) then
  begin
    StContenido := TcxStyle.Create(AForm);
    StContenido.Name := 'stBusquedaContenidoTablet';
  end;

  StContenido.Font.Name := AForm.Font.Name;
  StContenido.Font.Size := 15;
  StContenido.Color := clWindow;
  AForm.GridBusqueda.dbtvDatos.Styles.Content := StContenido;

  StCabecera := AForm.FindComponent('stBusquedaCabeceraTablet') as TcxStyle;
  if not Assigned(StCabecera) then
  begin
    StCabecera := TcxStyle.Create(AForm);
    StCabecera.Name := 'stBusquedaCabeceraTablet';
  end;

  StCabecera.Font.Name := AForm.Font.Name;
  StCabecera.Font.Size := 15;
  StCabecera.Font.Style := [fsBold];
  StCabecera.Color := clBtnFace;
  AForm.GridBusqueda.dbtvDatos.Styles.Header := StCabecera;
end;

procedure TfrmSeleccion.acAceptarExecute(Sender: TObject);
begin

   AceptaSeleccion(Sender);
end;

procedure TfrmSeleccion.acCancelarExecute(Sender: TObject);
begin
   OcultarTecladoVirtualBusqueda(Self);
   ModalResult := mrCancel;
end;

procedure TfrmSeleccion.AceptaSeleccion(Sender: TObject);
begin
  OcultarTecladoVirtualBusqueda(Self);

  if Assigned(GridBusqueda.dbtvDatos.DataController.DataSource) then
     if GridBusqueda.dbtvDatos.DataController.DataSource.DataSet.RecordCount > 0 then
          GridBusqueda.guardaGrid('\GridBusqueda' + aNombreTabla[TipoMaestro]);
  if HayBusqueda then
    ModalResult := mrOk;

end;

// Vuelve a buscar con las condiciones del texto busqueda
// Cambiamos el foco al grid, para que puedan moverse con las teclas de dirección.
procedure TfrmSeleccion.acFiltrarExecute(Sender: TObject);
begin
  OcultarTecladoVirtualBusqueda(Self);

  if (CamposBusquedaExtra <> '') then
      busca(condicion,adicionales,relacionados, camposBusquedaExtra)
  else
  if (relacionados <> '') then
      busca(condicion,adicionales,relacionados)
  else
    if (adicionales <> '') then
        busca(condicion,adicionales)
    else
        if Condicion <> '' then
            busca(condicion)
        else
            Busca;

   if Assigned(GridBusqueda.dbtvDatos.DataController.DataSource) then
     if GridBusqueda.dbtvDatos.DataController.DataSource.DataSet.RecordCount > 0 then
        TJncGridDx.Enfocargrid(gridBusqueda.dbtvDatos)
     else
        edTextoBusqueda.SetFocus;

end;

procedure TfrmSeleccion.btnSalir2Click(Sender: TObject);
begin
   OcultarTecladoVirtualBusqueda(Self);
   Close;
end;

procedure TfrmSeleccion.bttBuscarClick(Sender: TObject);
begin
  acFiltrarExecute(Sender);
end;

procedure TfrmSeleccion.bttCancelarClick(Sender: TObject);
begin
  OcultarTecladoVirtualBusqueda(Self);
  ModalResult := mrCancel;
end;

procedure TfrmSeleccion.busca(vSQl: string; vPasoSQL: boolean);
begin
  BD.ejecuta(BD.sqlConsulta, vSQL,NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

function TfrmSeleccion.buscaPrimero;
begin
  BD.ejecuta(BD.sqlconsulta, TSQL.PrimeroSQL(TipoMaestro),NIl,True);
  result := BD.sqlconsulta.fieldByName('codigo').asString;

end;

function TfrmSeleccion.BuscaPrimeroCondicion(vCondicion: string): string;
begin
   BD.ejecuta(BD.sqlconsulta, TSQL.PrimeroSQL(vCondicion,TipoMaestro),NIl,True);
  result := BD.sqlconsulta.fieldByName('codigo').asString;
end;

procedure TfrmSeleccion.busca(vCondicion, vAdicionales, vRelacionados,
  vCamposBusquedaExtra: string);
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestro(TipoMaestro,vCondicion, vAdicionales, vRelacionados,vCamposBusquedaExtra, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
  TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.buscaSinDatos(vCondicion: string);
begin
    BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestroSinDatos(TipoMaestro,vCondicion, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.buscaSinDatos;
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestroSinDatos(TipoMaestro, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
  TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;

end;

procedure TfrmSeleccion.buscaSinDatos(vCondicion, vAdicionales: string);
begin
   BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestroSinDatos(TipoMaestro,vCondicion, vAdicionales, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.buscaSinDatos(vSQl: string; vPasoSQL: boolean);
begin
  BD.ejecuta(BD.sqlConsulta, vSQL,NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

function TfrmSeleccion.BuscaUltimo: string;
begin
    BD.ejecuta(BD.sqlconsulta, TSQL.UltimoSQL(TipoMaestro),NIl,True);
  result := BD.sqlconsulta.fieldByName('codigo').asString;

end;

function TfrmSeleccion.BuscaUltimoCondicion(vCondicion: string): string;
begin
  BD.ejecuta(BD.sqlconsulta, TSQL.UltimoSQL(vCondicion,TipoMaestro),NIl,True);
  result := BD.sqlconsulta.fieldByName('codigo').asString;
end;

constructor TfrmSeleccion.Create(AOwner: TComponent; lFicheroIni: TFileName;
  vTipoMaestro: TMaestro; vTeclado: boolean);
begin
  inherited  Create(AOwner);
  Bd := TdmdMaestro.Create(self, lFicheroIni);
   try

        Bd.Conecta;
   except
       on e: Exception do
       begin
           Showmessage(e.Message);
           Application.Terminate;
       end;

   end;
 // Bd.Conecta;
  TipoMaestro := vTipoMaestro;
  Teclado := vTeclado;
end;

procedure TfrmSeleccion.buscaSinDatos(vCondicion, vAdicionales, vRelacionados,
  vCamposBusquedaExtra: string);
begin
   BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestroSinDatos(TipoMaestro,vCondicion, vAdicionales, vRelacionados, vCamposBusquedaExtra,edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.buscaSinDatos(vCondicion, vAdicionales,
  vRelacionados: string);
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestroSinDatos(TipoMaestro,vCondicion, vAdicionales, vRelacionados, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.busca(vCondicion, vAdicionales, vRelacionados: string);
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestro(TipoMaestro,vCondicion, vAdicionales, vRelacionados, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.busca(vCondicion: string);
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestro(TipoMaestro,vCondicion, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;


procedure TfrmSeleccion.busca;
begin

  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestro(TipoMaestro, edTextoBusqueda.Text),NIl,True);

  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda' + aNombreTabla[TipoMaestro]);
  TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

constructor TfrmSeleccion.Create(AOwner: TComponent; lFicheroIni: TFileName; vTipoMaestro: TMaestro);
begin
  inherited  Create(AOwner);
  Bd := TdmdMaestro.Create(self, lFicheroIni);
   try

        Bd.Conecta;
   except
       on e: Exception do
       begin
           Showmessage(e.Message);
           Application.Terminate;
       end;

   end;
 // Bd.Conecta;
  TipoMaestro := vTipoMaestro;
  Teclado := False;
end;

function TfrmSeleccion.DevuelveCodigo: string;
begin
   result := BD.sqlConsulta.fieldByName('Codigo').AsString;
end;

function TfrmSeleccion.NombreMaestro(vCodigo: string): string;
var
  lParametros: TListaSQLParametro;
begin
  lParametros := TListaSQLParametro.Create;
  lParametros.Introduce('PCODIGO', vCodigo);
  BD.ejecuta(BD.sqlconsulta, TSQL.descripcionSQL(TipoMaestro), lParametros);
  result := BD.sqlconsulta.fieldByName('nombre').asString;
  lParametros.Free;
end;

function TfrmSeleccion.SinRegistros: boolean;
begin
  result := BD.SinRegistros(BD.sqlConsulta);
end;

// Si se situa dentro del campo de texto de la busqueda, al pulsar intro, también busca.
procedure TfrmSeleccion.edTextoBusquedaClick(Sender: TObject);
begin
  if Teclado then
    MostrarTecladoVirtualBusqueda(Self);
end;

procedure TfrmSeleccion.edTextoBusquedaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    bttBuscarClick(Sender);
  end;
end;

function TfrmSeleccion.ExisteCodigo(vCodigo: string): boolean;
var
  lParametros: TListaSQLParametro;
begin
  lParametros := TListaSQLParametro.Create;
  lParametros.Introduce('PCODIGO', vCodigo);
  BD.ejecuta(BD.sqlconsulta, TSQL.ExisteCodigo(TipoMaestro), lParametros);
  result := BD.sqlconsulta.RecordCount > 0;
  lParametros.Free;
end;

procedure TfrmSeleccion.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  OcultarTecladoVirtualBusqueda(Self);

   if Assigned(GridBusqueda.dbtvDatos.DataController.DataSource) then
     if GridBusqueda.dbtvDatos.DataController.DataSource.DataSet.RecordCount > 0 then
          GridBusqueda.guardaGrid('\GridBusqueda' + aNombreTabla[TipoMaestro]);

  MemoWin(FrmBusqueda);

end;

procedure TfrmSeleccion.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key = #13) and (gridbusqueda.dbtvDatos.Focused)) then
     AceptaSeleccion(Sender);


end;



procedure TfrmSeleccion.FormShow(Sender: TObject);
begin
  { El aspecto se aplica ANTES de ShowModal.
    No modificar BorderStyle/Position/Bounds durante OnShow,
    porque VCL puede intentar recrear la ventana y lanzar:
    "Cannot change Visible in OnShow or OnHide". }
  edTextoBusqueda.SetFocus;
end;

// Al hacer doble click sobre un campo del grid, se tomará como si pulsa "Aceptar"
procedure TfrmSeleccion.GridBusquedaantDblClick(Sender: TObject);
begin
  AceptaSeleccion(Sender);
end;


procedure TfrmSeleccion.GridBusquedadbtvDatosDblClick(Sender: TObject);
begin
  AceptaSeleccion(Sender);
end;



procedure TfrmSeleccion.GridBusquedadbtvDatosKeyPress(Sender: TObject;
  var Key: Char);
var
  gposicion : integer;
begin


   gPosicion := gridbusqueda.dbtvDatos.Controller.FocusedRowIndex;
   gridbusqueda.dbtvDatos.Controller.FocusedRowIndex := gPosicion;// -1;
   if Key = #13 then
    AceptaSeleccion(Sender);

end;



// Devuelve un booleano si se ha seleccionado un item del grid.
function TfrmSeleccion.HayBusqueda: boolean;
begin

  with BD.sqlConsulta do
    result := Active and not(Bof and Eof) and (ModalResult <> mrCancel);

end;



// Inicializamos el grid, mostrando datos sin filtrar
procedure TfrmSeleccion.Muestra;
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];

  busca;
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;
procedure TfrmSeleccion.Muestra(vCondicion: string);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  busca(vCondicion);
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.Muestra(vCondicion, vAdicionales: String);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  Adicionales := vAdicionales;
   edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  busca(vCondicion, vAdicionales);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.busca(vCondicion: string; vAdicionales:string);
begin
  BD.ejecuta(BD.sqlConsulta, TSQL.buscaMaestro(TipoMaestro,vCondicion, vAdicionales, edTextoBusqueda.Text),NIl,True);
  gridBusqueda.DataSource := BD.dsConsulta;
  gridBusqueda.CargaDatosgrid(BD.dsConsulta,'\GridBusqueda'+ aNombreTabla[TipoMaestro]);
    TJncGridDx.PonerGridNoEditable(gridBusqueda.dbtvDatos);
  gridBusqueda.Repaint;
end;

procedure TfrmSeleccion.MemoWin(Form: TForm);
var
  Registro: TRegistry;
begin
  Registro := TRegistry.Create;
  Registro.OpenKey('\Software\Busqueda\WinPos\' + aNombreTabla[TipoMaestro], True);
  Registro.WriteInteger(Name + '_ScrWidth', Screen.Width);
  Registro.WriteInteger(Name + '_ScrHeight', Screen.Height);
  case WindowState of
    wsNormal: Registro.WriteInteger(Name + '_WindowState', 1);
    wsMinimized: Registro.WriteInteger(Name + '_WindowState', 2);
    wsMaximized: Registro.WriteInteger(Name + '_WindowState', 3);
  end;
  Registro.WriteInteger(Name+ '_Width', Width);
  Registro.WriteInteger(Name + '_Height', Height);
  Registro.WriteInteger(Name + '_Left', Left);
  Registro.WriteInteger(Name + '_Top', Top);
  Registro.WriteBool(Name, True);
  Registro.Free;

end;

procedure TfrmSeleccion.Muestra(vSQl: string; vNombreTabla:string; vPasoSQL: boolean);
begin
  Name := 'FrmBusqueda';
  RecallWin(FrmBusqueda);

  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + vNombreTabla;
  busca(vSQl,vPasoSQl);
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.Muestra(vCondicion, vAdicionales, vRelacionados,
  vCamposBusquedaExtra: string);
begin
  Name := 'FrmBusqueda';
  RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  Adicionales := vAdicionales;
  Relacionados := vRelacionados;
  CamposBusquedaExtra := vCamposBusquedaExtra;
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  busca(vCondicion, vAdicionales, vRelacionados,vCamposBusquedaExtra);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos(vCondicion: string);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  busca(vCondicion);
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos;
begin
  Name := 'FrmBusqueda';
  RecallWin(FrmBusqueda);
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  buscaSinDatos;
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos(vCondicion, vAdicionales: String);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);
  Condicion := vCondicion;
  Adicionales := vAdicionales;
  Relacionados := '';
  CamposBusquedaExtra := '';
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  buscaSinDatos(vCondicion, vAdicionales);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos(vSQl, vNombreTabla: string;
  vPasoSQL: boolean);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + vNombreTabla;
  buscaSinDatos(vSQl,vPasoSQl);
  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos(vCondicion, vAdicionales, vRelacionados,
  vCamposBusquedaExtra: string);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  Adicionales := vAdicionales;
  Relacionados := vRelacionados;
  CamposBusquedaExtra := vCamposBusquedaExtra;
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  buscaSinDatos(vCondicion, vAdicionales, vRelacionados, vCamposBusquedaExtra);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.MuestraSinDatos(vCondicion, vAdicionales,
  vRelacionados: string);
begin
   Name := 'FrmBusqueda';
   RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  Adicionales := vAdicionales;
  Relacionados := vRelacionados;
  CamposBusquedaExtra := '';
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  buscaSinDatos(vCondicion, vAdicionales, vRelacionados);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

procedure TfrmSeleccion.Muestra(vCondicion, vAdicionales,
  vRelacionados: string);
begin
  Name := 'FrmBusqueda';
  RecallWin(FrmBusqueda);

  Condicion := vCondicion;
  Adicionales := vAdicionales;
  Relacionados := vRelacionados;
  CamposBusquedaExtra :='';
  edTextoBusqueda.Text := '';
  Caption := ' Selección de ' + aNombreTabla[TipoMaestro];
  busca(vCondicion, vAdicionales, vRelacionados);

  AplicarAspectoBusquedaTablet(Self);
  ShowModal;
end;

function TfrmSeleccion.NombreMaestro(vCodigo, vSQL: string): string;
var
  lParametros: TListaSQLParametro;
begin
  lParametros := TListaSQLParametro.Create;
  lParametros.Introduce('PCODIGO', vCodigo);
  BD.ejecuta(BD.sqlconsulta, vSQl, lParametros);
  result := BD.sqlconsulta.fieldByName('nombre').asString;
  lParametros.Free;
end;

function TfrmSeleccion.NombreMaestro(vCodigo, vCondicion: string;
  vCondicional: boolean): string;
var
  lParametros: TListaSQLParametro;
begin
  lParametros := TListaSQLParametro.Create;
  lParametros.Introduce('PCODIGO', vCodigo);
  BD.ejecuta(BD.sqlconsulta, TSQL.descripcionSQL(TipoMaestro, vCondicion), lParametros);
  result := BD.sqlconsulta.fieldByName('nombre').asString;
  lParametros.Free;

end;


procedure TfrmSeleccion.RecallWin(Form: TForm);
var
  Registro: TRegistry;
begin
  Registro := TRegistry.Create;
  Registro.OpenKey('\Software\Busqueda\WinPos\' + aNombreTabla[TipoMaestro], True);
  if Registro.ValueExists(Name) then
  begin
    if (Registro.ReadInteger(Name + '_ScrWidth') = Screen.Width) or
       (Registro.ReadInteger(Name + '_ScrHeight') = Screen.Height) then
    begin
      case Registro.ReadInteger(Name + '_WindowState') of
        1: WindowState := wsNormal;
        2: WindowState := wsMinimized;
        3: WindowState := wsMaximized;
      end;
      if WindowState<>wsMaximized then
      begin
        Top := Registro.ReadInteger(Name+ '_Top');
        Left := Registro.ReadInteger(Name + '_Left');
        Width := Registro.ReadInteger(Name + '_Width');
        Height := Registro.ReadInteger(Name + '_Height');
      end;
    end;
  end
  else
    position := poMainFormCenter;

  Registro.Free;

end;

end.
