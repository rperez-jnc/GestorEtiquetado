unit FormTeclado;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Touch.Keyboard,
  Vcl.ExtCtrls;

type
  TFrmTeclado = class(TForm)
    TecladoFlotante: TTouchKeyboard;
    Panel1: TPanel;
    edTexto: TEdit;
    lblEtiqueta: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edTextoChange(Sender: TObject);
    procedure edTextoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FTexto: string;
    { Private declarations }
  public
    { Public declarations }
    property Texto:string read FTexto write FTexto;
  end;

var
  FrmTeclado: TFrmTeclado;

implementation

{$R *.dfm}

procedure TFrmTeclado.edTextoChange(Sender: TObject);
var
  lchar:string;
begin
  lChar := copy(edTexto.text, length(edtexto.Text),1);
  if lChar = #13 then
  begin
     Texto := edTexto.Text;
     Close;
  end;

end;

procedure TFrmTeclado.edTextoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key = VK_RETURN then
  begin
    // Guardas el valor en la propiedad del formulario
    texto := edtexto.Text;

    // Opcional: evitar salto de línea o comportamiento por defecto
    //Key := 0;

    // Cerrar formulario
    ModalResult := mrOk;
  end;
end;

procedure TFrmTeclado.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Texto := edTexto.Text;
  Close;
end;

procedure TFrmTeclado.FormShow(Sender: TObject);
begin
   TExto := '';

end;

end.
