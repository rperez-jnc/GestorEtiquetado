unit DmDatos;

interface

uses
  System.SysUtils, System.Classes, DLL_dmEstandar, Data.DB, Data.Win.ADODB, JncLib;

type
  TdmdDatos = class(TdmDLL)
  private
    { Private declarations }
  public
    { Public declarations }
    function CalculaYGuardaFAO(vIdReg:double; Var vFao, vArte:string):boolean;
    procedure AsignarFAO(vIdReg:double;  vFao, vArte:string);

    procedure RecuperarPesadas(vListaIdPesos: TStringList);
    procedure BuscarFaoArte(vCodArt, vLote:string; Var vFaoC, vArteC:string );
  end;

var
  dmdDatos: TdmdDatos;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmdDatos }

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
