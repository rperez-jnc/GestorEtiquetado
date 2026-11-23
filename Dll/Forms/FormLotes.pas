unit FormLotes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JncFraCxGrid, Vcl.StdCtrls, Vcl.Buttons,DmDatos, JncGridDx,
  Vcl.ExtCtrls;

type
  TFrmLotes = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    fraCxGridLotes: TfraCxGrid;
    procedure fraCxGridLotesdbtvDatosDblClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    FLote: string;
    FDescripcion: string;
    { Private declarations }
  public
    { Public declarations }
    procedure Inicializa(vBd: TdmdDatos; VCodArt:string);
    procedure AceptarSeleccion;

    Property Lote: string read FLote write FLote;
    Property Descripcion: string read FDescripcion write FDescripcion;
  end;

var
  FrmLotes: TFrmLotes;
  BD : TdmdDatos;
implementation

{$R *.dfm}

{ TFrmLotes }

procedure TFrmLotes.AceptarSeleccion;
begin
  Lote := TJNCGridDx.BuscaValor(FraCxGridLotes.dbtvDatos,FraCxGridLotes.dbtvDatos.Controller.SelectedRecords[0].RecordIndex,'Lote');
  Close;
end;

procedure TFrmLotes.btnCancelarClick(Sender: TObject);
begin
  Lote := '';
  Close;
end;

procedure TFrmLotes.fraCxGridLotesdbtvDatosDblClick(Sender: TObject);
begin
  AceptarSeleccion;
end;

procedure TFrmLotes.Inicializa(vBd: TdmdDatos; VCodArt: string);
var
   lDescripcion : string;
begin
  Bd := vBd;
  Bd.BuscarLotes(vCodart, lDescripcion);
  Caption := Caption  + '(' + lDescripcion + ')';
  Panel1.Caption := Panel1.Caption +  '(' + lDescripcion + ')';
  FraCxGridLotes.cargaDatosGrid(Bd.DsLotes,'\GestorEtiquetado\LotesDll');
  FraCxGridLotes.dbtvDatos.OptionsCustomize.ColumnSorting := False;
  TJncGridDx.PonerGridNoEditable(FraCxGridLotes.dbtvDatos);
end;

end.
