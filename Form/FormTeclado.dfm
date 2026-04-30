object FrmTeclado: TFrmTeclado
  Left = 0
  Top = 0
  ClientHeight = 295
  ClientWidth = 703
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TecladoFlotante: TTouchKeyboard
    Left = 0
    Top = 0
    Width = 703
    Height = 248
    Align = alClient
    GradientEnd = clSilver
    GradientStart = clGray
    Layout = 'Standard'
    ExplicitLeft = 192
    ExplicitTop = 72
    ExplicitWidth = 550
    ExplicitHeight = 180
  end
  object Panel1: TPanel
    Left = 0
    Top = 248
    Width = 703
    Height = 47
    Align = alBottom
    TabOrder = 1
    object lblEtiqueta: TLabel
      Left = 72
      Top = 16
      Width = 40
      Height = 13
      Caption = 'Etiqueta'
    end
    object edTexto: TEdit
      Left = 184
      Top = 6
      Width = 153
      Height = 33
      TabOrder = 0
      OnKeyDown = edTextoKeyDown
    end
  end
end
