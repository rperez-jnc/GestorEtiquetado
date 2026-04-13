unit FormValidacionUsuario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DmDatos, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFrmValidacion = class(TForm)
    lblError: TLabel;
    ledClave: TLabeledEdit;
    bAcceder: TButton;
    cbUsuario: TComboBox;
    Label1: TLabel;
    procedure bAccederClick(Sender: TObject);

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FValido: boolean;
    FBd: TdmdDatos;
    { Private declarations }
  public
    { Public declarations }

    procedure Inicializa(vBd:TdmdDatos);
    function GetIDComputerName(): String;
    procedure CargaComboUsuarios;

    Property Valido:boolean read FValido write FValido;
    Property Bd:TdmdDatos read FBd write FBd;
  end;

var
  FrmValidacion: TFrmValidacion;

implementation

{$R *.dfm}

procedure TFrmValidacion.bAccederClick(Sender: TObject);
begin
   if Bd.UsuarioValido(cbUsuario.Items[cbUsuario.ItemIndex], ledclave.Text) then
   begin
     lblError.Visible := FAlse;
     Valido := true;
     Bd.Equipo :=    GetIDComputerName;
     Bd.GuardaLog('Acceso del operario: ' + bd.UsuarioLog );
     Close;
   end
   else
   begin
     lblError.Visible := true;
     Valido := False;
     Bd.GuardaLog('Intento de acceso con usuario: ' + cbUsuario.Items[cbUsuario.ItemIndex] +  ' y clave : ' + ledclave.Text);
   end;


end;

procedure TFrmValidacion.CargaComboUsuarios;
begin
   Bd.BuscaUsuarios;
   with bd.sqlUsuarios do
   begin
     first;

     while  not eof do
     begin
        cbUsuario.Items.add(fieldbyname('ge_usuario').AsString);
       next;
     end;
   end;
end;

procedure TFrmValidacion.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Close;
end;



procedure TFrmValidacion.FormShow(Sender: TObject);
begin
    cbUsuario.SetFocus;
end;

function TFrmValidacion.GetIDComputerName: String;
begin
   // Esto es para Terminal Server
  //   Primero recoger en LOCAL (CLIENTNAME) si devuelve '' nada esto significa que el
  // CLIENTNAME no existe en TERMINAL SERVER eso quiere decir que estamos en
  // LOCAL y la variable suya es COMPUTERNAME
  Result := GetEnvironmentVariable('CLIENTNAME');
  if (Length(Result) = 0) then
    Result := GetEnvironmentVariable('COMPUTERNAME');
end;

procedure TFrmValidacion.Inicializa(vBd: TdmdDatos);
begin
  Bd := vBd;
  Valido := False;

  CargaComboUsuarios;


end;

end.
