program GestorEtiquetado;

uses
  Vcl.Forms,
  FormPrincipal in 'FormPrincipal.pas' {FrmPrincipal},
  IniDataModule in '..\..\comun\modulos\IniDataModule.pas' {dmIniDataModule: TDataModule},
  SQLServerDataModule in '..\..\comun\modulos\SQLServerDataModule.pas' {dmSQLServerDataModule: TDataModule},
  DmDatos in 'Datos\DmDatos.pas' {dmdDatos: TDataModule},
  DmBascula in 'Datos\DmBascula.pas' {AccesoBascula: TDataModule},
  BasculaModelo in 'Datos\BasculaModelo.pas',
  FormValidacionUsuario in 'Form\FormValidacionUsuario.pas' {FrmValidacion},
  Maestro in '..\..\comun\datos\Maestro.pas',
  JncMaestro in '..\..\comun\frames\JncMaestro.pas' {fraMaestro: TFrame},
  dmImagenesGrande in '..\..\comun\img\dmImagenesGrande.pas' {dmImagesGrande: TDataModule},
  JncFraCxGrid in '..\..\comun\frames\JncFraCxGrid.pas' {fraCxGrid: TFrame},
  FormEtiquetas in 'Form\FormEtiquetas.pas' {FrmEtiquetas},
  FormMensaje in 'Form\FormMensaje.pas' {FrmMensaje},
  FormTecladoBusqueda in '..\..\comun\frames\FormTecladoBusqueda.pas' {FrmTecladoBusqueda},
  FormTeclado in 'Form\FormTeclado.pas' {FrmTeclado};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TdmImagesGrande, dmImagesGrande);
  Application.CreateForm(TFrmMensaje, FrmMensaje);
  Application.CreateForm(TFrmTecladoBusqueda, FrmTecladoBusqueda);
  Application.CreateForm(TFrmTeclado, FrmTeclado);
  Application.Run;
end.
