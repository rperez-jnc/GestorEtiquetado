unit DmDatos;

interface

uses
  System.SysUtils, System.Classes, DLL_dmEstandar, Data.DB, Data.Win.ADODB, JncLib, Dialogs, System.UITypes;

type
  TdmdDatos = class(TdmDLL)
    sqlLotes: TADOQuery;
    DsLotes: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
    function CalculaYGuardaFAO(vIdReg:double; Var vFao, vArte:string):boolean;
    procedure AsignarFAO(vIdReg:double;  vFao, vArte:string);

    procedure RecuperarPesadas(vListaIdPesos: TStringList);
    procedure BuscarFaoArte(vCodArt, vLote:string; Var vFaoC, vArteC:string );
    procedure ObtenerUnidadesPesoArticulo(vCodArt, VLote:string; Var vUnidades: integer; Var vKilos:double);
    function ArticuloDobleUnidad(vCodArt:string):boolean;
    procedure BuscarLotes(vCodart:string; Var vDescripcion:string);
  end;

var
  dmdDatos: TdmdDatos;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmdDatos }

function TdmdDatos.ArticuloDobleUnidad(vCodArt: string): boolean;
begin
   with query do
  begin
    close;
    sql.Clear;
    sql.add('Select coalesce(Sal_2Unidad,''F'') Unidad from articulo with(nolock)');
    sql.Add(' where codart = ' + quotedstr(vCodArt));

    open;

    result := fieldbyname('Unidad').AsString = 'T';

  end;
end;

procedure TdmdDatos.AsignarFAO(vIdReg: double;  vFao, vArte:string);
begin
  with query do
  begin
    close;
    sql.Clear;

    sql.Add('Update lineregu set Sal_Fao = ' + quotedstr(vFao));
    sql.Add(', sal_ArtePesca = ' + quotedstr(vArte));
    sql.Add(' where idreg = ' + formateafloatsql(vIdReg));
    sql.Add(' and Unidades > 0');

    execsql;
  end;
end;


procedure TdmdDatos.BuscarFaoArte(vCodArt, vLote: string; var vFaoC,
  vArteC: string);
begin
    with query do
  begin
    close;
    sql.Clear;

    sql.Add('select  coalesce(SAL_ARTEPESCA,'''') Arte, coalesce(SAL_FAO,'''') Fao  from linealba with(nolock) ');
    sql.Add(' where codart = ' +  quotedstr(cuadrasiesnumerico(vCodart,15)));
    sql.Add(' and lote = ' + quotedstr(cuadrasiesnumerico(vLote,25)));
    sql.Add(' and IDALBC is not null');

    open;

    vFaoC := fieldbyname('FAo').AsString;
    vArteC:= fieldbyname('Arte').AsString;
  end;
end;

procedure TdmdDatos.BuscarLotes(vCodart: string; Var vDescripcion:string);
var
  CodFamEst: string;
  CodTipo: string;
  Lote: string;
begin
  with query do
  begin
    close;
    sql.Clear;

    sql.Add('SELECT TOP 1 ');
    sql.Add(' LTRIM(RTRIM(A.DescArt)) AS DescArt, ');
    sql.Add(' LTRIM(RTRIM(A.CodFamEst)) AS CodFamEst, ');
    sql.Add('LTRIM(RTRIM(T.sal_codtipo)) AS CodTipo ');
    sql.Add('FROM Articulo A WITH (NOLOCK) ');
    sql.Add('LEFT JOIN SAL_TipoArticulos T WITH (NOLOCK) ');
    sql.Add(' ON LTRIM(RTRIM(T.sal_descripcion)) = LTRIM(RTRIM(A.CodFamEst)) ');
    sql.Add('WHERE A.CodArt = ' + quotedstr(cuadrasiesnumerico(vCodArt,15)));

    open;

    if recordcount = 0 then
    begin
      MessageDlg('No se ha encontrado el articulo ' + Trim(vCodArt) + '.', mtInformation, [mbOK], 0);
      Exit;
    end;
    vDescripcion := Trim(FieldByName('DescArt').AsString);
    CodFamEst := Trim(FieldByName('CodFamEst').AsString);
    CodTipo := Trim(FieldByName('CodTipo').AsString);

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

    with sqlLotes do
    begin
      close;
      sql.Clear;

      sql.Add('SELECT DISTINCT LTRIM(RTRIM(C.Param3)) AS Lote ');
      sql.Add('FROM CABEREGU C WITH (NOLOCK) ');
      sql.Add('WHERE ((ISNULL(C.ge_cerrado, ''F'') = ''F'') or (C.ge_cerrado = '''')) ');
      sql.Add(' AND NULLIF(LTRIM(RTRIM(C.Param3)), '''') IS NOT NULL ');
      sql.Add( ' AND LTRIM(RTRIM(C.Param3)) LIKE ' + quotedstr(CodTipo + '%'));
      sql.Add('ORDER BY Lote');

      open;
    end;
  end;
end;

function TdmdDatos.CalculaYGuardaFAO(vIdReg: double; Var vFao, vArte:string):boolean;

begin
  vFao := '';
  vArte := '';
  result := true;
  with query do
  begin
    close;
    sql.Clear;

    Sql.Add('select top 1 Sum(Unidades) unidades, coalesce(SAl_Fao,'''') sal_fao from lineregu with(nolock) ');
    sql.Add(' where idreg = ' + formateafloatsql(vIdReg));
    sql.Add(' and unidades < 0 ');
    sql.Add(' group by Sal_Fao');
    sql.Add(' order by unidades');

    open;

    if recordcount = 0 then
    begin
       result := False;
       exit;
    end;
    vFao := fieldbyname('Sal_fao').AsString;

  end;
  with query do
  begin
    close;
    sql.Clear;

    Sql.Add('select top 1 Sum(Unidades) unidades, coalesce(SAL_ARTEPESCA,'''') SAL_ARTEPESCA from lineregu with(nolock) ');
    sql.Add(' where idreg = ' + formateafloatsql(vIdReg));
    sql.Add(' and unidades < 0 ');
    sql.Add(' group by SAL_ARTEPESCA');
    sql.Add(' order by unidades');

    open;

    vArte := fieldbyname('SAL_ARTEPESCA').AsString;

  end;
  with query do
  begin
    close;
    sql.Clear;

    sql.Add('Update caberegu set Param1 = ' + quotedstr(vFao));
    sql.Add(', Param2 = ' + quotedstr(vArte));
    sql.Add(' where idreg = ' + formateafloatsql(vIdReg));

    execsql;

  end;

end;

procedure TdmdDatos.ObtenerUnidadesPesoArticulo(vCodArt, VLote: string;
  var vUnidades: integer; var vKilos: double);
begin
  with query do
  begin
    close;
    sql.Clear;

    sql.Add('Select sum(coalesce(ge_unidadespesadas,0)) Unidades, sum(unidades) kilos ');
    sql.Add(' from lineregu with(nolock)');
    sql.Add(' where codart = ' + quotedstr(vCodart));
    sql.Add(' and lote = ' + quotedstr(vLote));

    open;

    vUnidades :=  fieldbyname('unidades').AsInteger;
    vKilos := fieldbyname('kilos').AsFloat;
  end;
end;

procedure TdmdDatos.RecuperarPesadas(vListaIdPesos: TStringList);
var
  lId: double;
  li : integer;
begin
  for li := 0 to vListaIdPesos.Count - 1 do
  begin


      with query do
      begin
        close;
        sql.Clear;

        sql.Add('Update ge_pesadas set ge_idregu = null where ge_id = ' + vListaIdPesos[li]);

        execsql;
      end;

  end;
end;

end.
