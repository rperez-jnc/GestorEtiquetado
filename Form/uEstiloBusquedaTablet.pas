unit uEstiloBusquedaTablet;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  System.Types,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Graphics;

procedure AplicarEstiloBusquedaTablet(AForm: TCustomForm; AOwnerForm: TCustomForm);

implementation

type
  TControlAccess = class(TControl)
  end;

  TCustomFormAccess = class(TCustomForm)
  end;

const
  MARGEN_FORM = 14;
  FUENTE_MINIMA = 14;
  FUENTE_BOTON = 14;
  ALTO_BOTON_MIN = 52;
  ALTO_EDIT_MIN = 34;

procedure EstilizarControles(AParent: TWinControl);
var
  I: Integer;
  C: TControl;
begin
  if not Assigned(AParent) then
    Exit;

  for I := 0 to AParent.ControlCount - 1 do
  begin
    C := AParent.Controls[I];

    if C is TLabel then
    begin
      TLabel(C).Font.Size := Max(TLabel(C).Font.Size, FUENTE_MINIMA);
    end
    else if C is TCustomEdit then
    begin
      TControlAccess(C).Font.Size := Max(TControlAccess(C).Font.Size, FUENTE_MINIMA);
      if (TCustomEdit(C).Align = alNone) and (TCustomEdit(C).Height < ALTO_EDIT_MIN) then
        TCustomEdit(C).Height := ALTO_EDIT_MIN;
    end
    else if C is TComboBox then
    begin
      TComboBox(C).Font.Size := Max(TComboBox(C).Font.Size, FUENTE_MINIMA);
    end
    else if C is TButton then
    begin
      TButton(C).Font.Size := Max(TButton(C).Font.Size, FUENTE_BOTON);
      if (TButton(C).Align = alNone) and (TButton(C).Height < ALTO_BOTON_MIN) then
        TButton(C).Height := ALTO_BOTON_MIN;
    end
    else if C is TBitBtn then
    begin
      TBitBtn(C).Font.Size := Max(TBitBtn(C).Font.Size, FUENTE_BOTON);
      if (TBitBtn(C).Align = alNone) and (TBitBtn(C).Height < ALTO_BOTON_MIN) then
        TBitBtn(C).Height := ALTO_BOTON_MIN;
    end
    else if C is TCheckBox then
    begin
      TCheckBox(C).Font.Size := Max(TCheckBox(C).Font.Size, FUENTE_MINIMA);
    end
    else if C is TRadioButton then
    begin
      TRadioButton(C).Font.Size := Max(TRadioButton(C).Font.Size, FUENTE_MINIMA);
    end
    else if C is TCustomListView then
    begin
      TControlAccess(C).Font.Size := Max(TControlAccess(C).Font.Size, FUENTE_MINIMA);
    end;

    if C is TWinControl then
      EstilizarControles(TWinControl(C));
  end;
end;

procedure AplicarEstiloBusquedaTablet(AForm: TCustomForm; AOwnerForm: TCustomForm);
var
  R: TRect;
  W, H: Integer;
begin
  if not Assigned(AForm) then
    Exit;

  TCustomFormAccess(AForm).Position := poDesigned;
  TCustomFormAccess(AForm).BorderStyle := bsSingle;
  TCustomFormAccess(AForm).BorderIcons := [biSystemMenu];
  TCustomFormAccess(AForm).KeyPreview := True;

  if Assigned(AOwnerForm) then
  begin
    TCustomFormAccess(AForm).Color := TCustomFormAccess(AOwnerForm).Color;
    TCustomFormAccess(AForm).Font.Name := TCustomFormAccess(AOwnerForm).Font.Name;
    TCustomFormAccess(AForm).Font.Charset := TCustomFormAccess(AOwnerForm).Font.Charset;
    TCustomFormAccess(AForm).Font.Size := Max(TCustomFormAccess(AOwnerForm).Font.Size, FUENTE_MINIMA);

    R := AOwnerForm.BoundsRect;
    W := Max(1, (R.Right - R.Left) - (MARGEN_FORM * 2));
    H := Max(1, (R.Bottom - R.Top) - (MARGEN_FORM * 2));

    AForm.SetBounds(
      R.Left + MARGEN_FORM,
      R.Top + MARGEN_FORM,
      W,
      H
    );
  end
  else
  begin
    TCustomFormAccess(AForm).Font.Size := Max(TCustomFormAccess(AForm).Font.Size, FUENTE_MINIMA);
    TCustomFormAccess(AForm).Position := poScreenCenter;
  end;

  EstilizarControles(AForm);
end;

end.
