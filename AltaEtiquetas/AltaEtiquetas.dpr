program AltaEtiquetas;

uses
  Vcl.Forms,
  FormPrincipal in 'FormPrincipal.pas' {FrmPrincipal},
  IniDataModule in '..\..\..\comun\modulos\IniDataModule.pas' {dmIniDataModule: TDataModule},
  SQLServerDataModule in '..\..\..\comun\modulos\SQLServerDataModule.pas' {dmSQLServerDataModule: TDataModule},
  DmDatos in 'Datos\DmDatos.pas' {dmdDatos: TDataModule},
  JncFraCxGrid in '..\..\..\comun\frames\JncFraCxGrid.pas' {fraCxGrid: TFrame},
  FormFormatosA3erp in 'Forms\FormFormatosA3erp.pas' {FrmFormatosA3erp};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
