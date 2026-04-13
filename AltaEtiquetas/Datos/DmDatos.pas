unit DmDatos;

interface

uses
  System.SysUtils, System.Classes, SQLServerDataModule, Data.DB, Data.Win.ADODB, IniFiles,
  JvMemoryDataset, JncLib;

type
  TdmdDatos = class(TdmSQLServerDataModule)
    sqlEtiquetas: TADOQuery;
    sqlEtiquetasId: TIntegerField;
    sqlEtiquetasCodigo: TStringField;
    sqlEtiquetasFormato: TStringField;
    sqlEtiquetasDescripcion: TStringField;
    DsEtiquetas: TDataSource;
    JvmFormatos: TJvMemoryData;
    JvmFormatosFormato: TStringField;
    DsFormatos: TDataSource;
    JvmFormatosDescripcion: TStringField;
    procedure sqlEtiquetasBeforePost(DataSet: TDataSet);
  private
    FFicheroIni: string;
    FCarpetaListados: string;
    { Private declarations }
  public
    { Public declarations }
    procedure LeeIni(vIni: TIniFile); override;
    procedure CargarEtiquetas;

    property FicheroIni: string read FFicheroIni write FFicheroIni;
    property CarpetaListados: string read FCarpetaListados write FCarpetaListados;
  end;

var
  dmdDatos: TdmdDatos;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmdDatos }

procedure TdmdDatos.CargarEtiquetas;
begin
  with sqlEtiquetas do
  begin
    close;
    sql.Clear;

    sql.Add('Select ge_id, ge_codigo, ge_etiqueta, ge_descripcion ');
    sql.Add('from ge_etiquetas with(nolock)');
    open;
  end;
end;

procedure TdmdDatos.LeeIni(vIni: TIniFile);
begin
  inherited;
  FicheroIni := vIni.FileName;
  CarpetaListados := vIni.ReadString('Opciones','CarpetaListados','');

end;

procedure TdmdDatos.sqlEtiquetasBeforePost(DataSet: TDataSet);
begin
  inherited;
  sqlEtiquetasCodigo.value :=  cuadrasiesnumerico(sqlEtiquetasCodigo.value,8);
end;

end.
