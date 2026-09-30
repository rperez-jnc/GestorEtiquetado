unit FormLotesDisponibles;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Data.Win.ADODB,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Buttons,
  Vcl.Dialogs,
  cxGrid,
  cxGridLevel,
  cxGridTableView,
  cxStyles,
  uEstiloBusquedaTablet;

const
  WM_ACEPTAR_LOTE = WM_USER + 701;

type
  TFrmLotesDisponibles = class(TForm)
  private
    FPanelTitulo: TPanel;
    FLblTitulo: TLabel;
    FGrid: TcxGrid;
    FView: TcxGridTableView;
    FLevel: TcxGridLevel;
    FPnlBotones: TPanel;
    FBtnAceptar: TBitBtn;
    FBtnCancelar: TBitBtn;
    FListaLotes: TStringList;
    FLoteSeleccionado: string;
    FEstiloContenido: TcxStyle;
    FEstiloCabecera: TcxStyle;

    procedure CrearControles;
    procedure CargarLista(const ADescripcionArticulo: string; ALotes: TStrings);
    procedure AceptarSeleccion;
    procedure BtnAceptarClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WMAceptarLote(var Msg: TMessage); message WM_ACEPTAR_LOTE;

    class function ConsultarLotes(AConexion: TADOConnection;
      const ACodArt: string; ALotes: TStrings;
      out ADescripcionArticulo: string): Boolean; static;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function SeleccionarLote(AOwner: TComponent;
      AConexion: TADOConnection; const ACodArt: string;
      out ALote: string): Boolean;

    property LoteSeleccionado: string read FLoteSeleccionado;
  end;

implementation

constructor TFrmLotesDisponibles.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);

  FListaLotes := TStringList.Create;

  Caption := 'Lotes disponibles';
  Color := clBtnFace;
  KeyPreview := True;

  CrearControles;

  if AOwner is TCustomForm then
    AplicarEstiloBusquedaTablet(Self, TCustomForm(AOwner))
  else
    AplicarEstiloBusquedaTablet(Self, nil);
end;

destructor TFrmLotesDisponibles.Destroy;
begin
  FreeAndNil(FListaLotes);
  inherited Destroy;
end;

procedure TFrmLotesDisponibles.CrearControles;
var
  ColLote: TcxGridColumn;
begin
  FPanelTitulo := TPanel.Create(Self);
  FPanelTitulo.Parent := Self;
  FPanelTitulo.Align := alTop;
  FPanelTitulo.Height := 72;
  FPanelTitulo.BevelOuter := bvNone;
  FPanelTitulo.ParentColor := True;

  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FPanelTitulo;
  FLblTitulo.Align := alClient;
  FLblTitulo.Alignment := taCenter;
  FLblTitulo.Layout := tlCenter;
  FLblTitulo.AutoSize := False;
  FLblTitulo.Caption := 'Lotes disponibles';
  FLblTitulo.Font.Style := [fsBold];
  FLblTitulo.Font.Size := 18;

  FPnlBotones := TPanel.Create(Self);
  FPnlBotones.Parent := Self;
  FPnlBotones.Align := alBottom;
  FPnlBotones.Height := 86;
  FPnlBotones.BevelOuter := bvNone;
  FPnlBotones.ParentColor := True;
  FPnlBotones.Padding.Left := 8;
  FPnlBotones.Padding.Top := 10;
  FPnlBotones.Padding.Right := 8;
  FPnlBotones.Padding.Bottom := 10;

  FBtnCancelar := TBitBtn.Create(Self);
  FBtnCancelar.Parent := FPnlBotones;
  FBtnCancelar.Align := alRight;
  FBtnCancelar.Width := 210;
  FBtnCancelar.Caption := 'Cancelar';
  FBtnCancelar.ModalResult := mrCancel;
  FBtnCancelar.Cancel := True;
  FBtnCancelar.Height := 54;
  FBtnCancelar.Font.Size := 15;
  FBtnCancelar.Font.Style := [fsBold];

  FBtnAceptar := TBitBtn.Create(Self);
  FBtnAceptar.Parent := FPnlBotones;
  FBtnAceptar.Align := alRight;
  FBtnAceptar.Width := 190;
  FBtnAceptar.Caption := 'Aceptar';
  FBtnAceptar.Default := True;
  FBtnAceptar.Height := 54;
  FBtnAceptar.Font.Size := 15;
  FBtnAceptar.Font.Style := [fsBold];
  FBtnAceptar.OnClick := BtnAceptarClick;

  FGrid := TcxGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := alClient;
  FGrid.Font.Size := 16;

  FView := FGrid.CreateView(TcxGridTableView) as TcxGridTableView;

  FLevel := FGrid.Levels.Add;
  FLevel.GridView := FView;

  FView.OptionsData.Editing := False;
  FView.OptionsSelection.CellSelect := False;
  FView.OptionsView.GroupByBox := False;
  FView.OptionsView.ColumnAutoWidth := True;
  FView.OptionsCustomize.ColumnSorting := False;
  FView.OptionsCustomize.ColumnMoving := False;
  FView.OptionsCustomize.ColumnGrouping := False;

  FEstiloContenido := TcxStyle.Create(Self);
  FEstiloContenido.Font.Name := Font.Name;
  FEstiloContenido.Font.Size := 15;
  FEstiloContenido.Color := clWindow;
  FView.Styles.Content := FEstiloContenido;

  FEstiloCabecera := TcxStyle.Create(Self);
  FEstiloCabecera.Font.Name := Font.Name;
  FEstiloCabecera.Font.Size := 15;
  FEstiloCabecera.Font.Style := [fsBold];
  FEstiloCabecera.Color := clBtnFace;
  FView.Styles.Header := FEstiloCabecera;

  ColLote := FView.CreateColumn;
  ColLote.Caption := 'LOTE DISPONIBLE';
  ColLote.Width := 700;

  FView.OnDblClick := GridDblClick;
  FView.OnKeyDown := GridKeyDown;
end;

class function TFrmLotesDisponibles.ConsultarLotes(
  AConexion: TADOConnection; const ACodArt: string;
  ALotes: TStrings; out ADescripcionArticulo: string): Boolean;
var
  Q: TADOQuery;
  CodFamEst: string;
  CodTipo: string;
  Lote: string;
begin
  Result := False;
  ADescripcionArticulo := '';
  CodFamEst := '';
  CodTipo := '';

  if Assigned(ALotes) then
    ALotes.Clear;

  if not Assigned(AConexion) then
    raise Exception.Create('No se ha informado la conexion a la base de datos.');

  if Trim(ACodArt) = '' then
  begin
    MessageDlg('Seleccione primero un articulo.', mtInformation, [mbOK], 0);
    Exit;
  end;

  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConexion;

    Q.SQL.Text :=
      'SELECT TOP 1 ' +
      ' LTRIM(RTRIM(A.DescArt)) AS DescArt, ' +
      ' LTRIM(RTRIM(A.CodFamEst)) AS CodFamEst, ' +
      ' LTRIM(RTRIM(T.sal_codtipo)) AS CodTipo ' +
      'FROM Articulo A WITH (NOLOCK) ' +
      'LEFT JOIN SAL_TipoArticulos T WITH (NOLOCK) ' +
      ' ON LTRIM(RTRIM(T.sal_descripcion)) = LTRIM(RTRIM(A.CodFamEst)) ' +
      'WHERE LTRIM(RTRIM(A.CodArt)) = LTRIM(RTRIM(:PCodArt))';

    Q.Parameters.ParamByName('PCodArt').Value := Trim(ACodArt);
    Q.Open;

    if Q.IsEmpty then
    begin
      MessageDlg('No se ha encontrado el articulo ' + Trim(ACodArt) + '.', mtInformation, [mbOK], 0);
      Exit;
    end;

    ADescripcionArticulo := Trim(Q.FieldByName('DescArt').AsString);
    CodFamEst := Trim(Q.FieldByName('CodFamEst').AsString);
    CodTipo := Trim(Q.FieldByName('CodTipo').AsString);

    if CodFamEst = '' then
    begin
      MessageDlg('El articulo no tiene informada la familia estadistica (CodFamEst).', mtInformation, [mbOK], 0);
      Exit;
    end;

    if CodTipo = '' then
    begin
      MessageDlg(
        'No existe un tipo de articulo en SAL_TipoArticulos cuya descripcion coincida con la familia estadistica "' +
        CodFamEst + '".',
        mtInformation,
        [mbOK],
        0
      );
      Exit;
    end;

    Q.Close;
    Q.SQL.Text :=
      'SELECT DISTINCT LTRIM(RTRIM(C.Param3)) AS Lote ' +
      'FROM CABEREGU C WITH (NOLOCK) ' +
      'WHERE ISNULL(C.ge_cerrado, 0) = 0 ' +
      ' AND NULLIF(LTRIM(RTRIM(C.Param3)), '''') IS NOT NULL ' +
      ' AND LTRIM(RTRIM(C.Param3)) LIKE :PPrefijo ' +
      'ORDER BY Lote';

    Q.Parameters.ParamByName('PPrefijo').Value := CodTipo + '%';
    Q.Open;

    while not Q.Eof do
    begin
      Lote := Trim(Q.FieldByName('Lote').AsString);
      if (Lote <> '') and Assigned(ALotes) then
        ALotes.Add(Lote);
      Q.Next;
    end;
  finally
    if Q.Active then
      Q.Close;
    Q.Connection := nil;
    Q.Free;
  end;

  if (not Assigned(ALotes)) or (ALotes.Count = 0) then
  begin
    MessageDlg(
      'No hay lotes disponibles para el articulo ' + ADescripcionArticulo + '.',
      mtInformation,
      [mbOK],
      0
    );
    Exit;
  end;

  Result := True;
end;

procedure TFrmLotesDisponibles.CargarLista(
  const ADescripcionArticulo: string; ALotes: TStrings);
var
  I: Integer;
begin
  FLoteSeleccionado := '';
  FListaLotes.Assign(ALotes);

  Caption := 'Lotes disponibles (' + ADescripcionArticulo + ')';
  FLblTitulo.Caption := Caption;

  FView.DataController.RecordCount := 0;
  FView.DataController.RecordCount := FListaLotes.Count;

  for I := 0 to FListaLotes.Count - 1 do
    FView.DataController.Values[I, 0] := FListaLotes[I];

  if FListaLotes.Count > 0 then
    FView.DataController.FocusedRecordIndex := 0;
end;

procedure TFrmLotesDisponibles.AceptarSeleccion;
var
  I: Integer;
begin
  I := FView.DataController.FocusedRecordIndex;

  if (I < 0) or (I >= FListaLotes.Count) then
    Exit;

  FLoteSeleccionado := Trim(FListaLotes[I]);

  if FLoteSeleccionado = '' then
    Exit;

  ModalResult := mrOk;
end;

procedure TFrmLotesDisponibles.BtnAceptarClick(Sender: TObject);
begin
  AceptarSeleccion;
end;

procedure TFrmLotesDisponibles.GridDblClick(Sender: TObject);
begin
  PostMessage(Handle, WM_ACEPTAR_LOTE, 0, 0);
end;

procedure TFrmLotesDisponibles.GridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    PostMessage(Handle, WM_ACEPTAR_LOTE, 0, 0);
  end
  else if Key = VK_ESCAPE then
  begin
    Key := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TFrmLotesDisponibles.WMAceptarLote(var Msg: TMessage);
begin
  AceptarSeleccion;
end;

class function TFrmLotesDisponibles.SeleccionarLote(
  AOwner: TComponent; AConexion: TADOConnection;
  const ACodArt: string; out ALote: string): Boolean;
var
  Frm: TFrmLotesDisponibles;
  Lista: TStringList;
  DescripcionArticulo: string;
begin
  Result := False;
  ALote := '';

  Lista := TStringList.Create;
  try
    if not ConsultarLotes(AConexion, ACodArt, Lista, DescripcionArticulo) then
      Exit;

    Frm := TFrmLotesDisponibles.Create(AOwner);
    try
      Frm.CargarLista(DescripcionArticulo, Lista);

      if Frm.ShowModal = mrOk then
      begin
        ALote := Frm.LoteSeleccionado;
        Result := ALote <> '';
      end;
    finally
      Frm.Free;
    end;
  finally
    Lista.Free;
  end;
end;

end.
