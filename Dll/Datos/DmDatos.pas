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
    procedure CalculaYGuardaFAO(vIdReg:double; Var vFao, vArte:string);
    procedure AsignarFAO(vIdReg:double;  vFao, vArte:string);

    procedure RecuperarPesadas(vListaIdPesos: TStringList);
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


procedure TdmdDatos.CalculaYGuardaFAO(vIdReg: double; Var vFao, vArte:string);

begin
  with query do
  begin
    close;
    sql.Clear;

    Sql.Add('select top 1 Sum(Unidades) unidades, SAl_Fao from lineregu with(nolock) ');
    sql.Add(' where idreg = ' + formateafloatsql(vIdReg));
    sql.Add(' and unidades < 0 ');
    sql.Add(' group by Sal_Fao');
    sql.Add(' order by unidades');

    open;

    vFao := fieldbyname('Sal_fao').AsString;

  end;
  with query do
  begin
    close;
    sql.Clear;

    Sql.Add('select top 1 Sum(Unidades) unidades, SAL_ARTEPESCA from lineregu with(nolock) ');
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
