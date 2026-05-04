unit FormMensaje;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TFrmMensaje = class(TForm)
    lMensaje: TLabel;
    btnOk: TBitBtn;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure Inicializa(vMensaje:string);
  end;

var
  FrmMensaje: TFrmMensaje;

implementation

{$R *.dfm}

procedure TFrmMensaje.btnOkClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmMensaje.Inicializa(vMensaje: string);
begin
   lMensaje.Caption := vMensaje;
end;

end.
