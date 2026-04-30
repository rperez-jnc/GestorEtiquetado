unit Dll_GestorEtiquetado;

interface

Uses DmDatos, Dll_Modelo, Dialogs, System.UITypes, System.Classes, JncLib,System.variants;

procedure INICIAR(Empresa: PAnsiChar); stdcall;
procedure FINALIZAR; stdcall;
procedure DESPUESDEGUARDARDOCUMENTOV2(Documento: AnsiString; IdDoc: Double; Estado: integer); stdcall;
function REPINTAR(Tabla: AnsiString): boolean; stdcall;
function ANTESDEGUARDARLINEACONDETALLEV2(Documento: AnsiString; Cabecera: variant; Linea: variant; Detalle: variant;
  Estado: integer; var PermitirGuardar: boolean): variant; stdcall;


Var
  Bd:TdmdDatos;

implementation

function REPINTAR(Tabla: AnsiString): boolean; stdcall;
BEGIN
  if Tabla = 'CABEREGU' then
    result := True;

END;
procedure INICIAR(Empresa: PAnsiChar); stdcall;

begin
  Bd := TdmdDatos.Create(nil);
  Bd.Conecta(Empresa);
end;

procedure FINALIZAR; stdcall;
begin

   Bd.Free;

end;

function ANTESDEGUARDARLINEACONDETALLEV2(Documento: AnsiString; Cabecera: variant; Linea: variant; Detalle: variant;
  Estado: integer; var PermitirGuardar: boolean): variant; stdcall;
var
  lIdreg: double;
  lNumLin: integer;
  lListaIdPesos : TStringList;
  lFAO, lArte,lFAOC, lArteC:string;
  lCodArt, lLote: string;
BEGIN
   PermitirGuardar := true;
   if ((documento = 'RE') and (Estado = 2)) then
   BEGIN
        lListaIdPesos := TStringList.Create;
        lListaIdPesos.Delimiter := ',';

        lIdreg := TInternoDLL.GetValorCampoVarFloat(Cabecera, 'IdReg');
        lNumLin := TInternoDLL.GetValorCampoVarInt(Linea, 'NUmLin');
        lListaIdPesos.DelimitedText := ifnull(TInternoDLL.GetValorCampoVarStr(Linea, 'GE_LISTAIDPESOS'),'');
        if lListaIdPesos.Count > 0 then
        begin
          if MessageDlg('¿Recuperar las pesadas asociadas a la linea?. Este cambio es irreversible aunque no guarde el documento', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          begin
            Bd.RecuperarPesadas(lListaIdPesos);
          end;
        end;


   END;
   if (((documento = 'RE') or (documento = 'TR') or (documento = 'AV') or (documento = 'FV')) and (Estado < 2)) then
   BEGIN

       result := varArrayCreate([0, 2], varVariant);
         result[0] := 2;

       lCodArt := TInternoDLL.GetValorCampoVarStr(Linea, 'CodArt');
       lLote := TInternoDLL.GetValorCampoDetalleStr(Detalle, 'Lote');
       lFAo := ifnull(TInternoDLL.GetValorCampoVarStr(Linea, 'Sal_Fao'),'');
       lArte := ifnull(TInternoDLL.GetValorCampoVarStr(Linea, 'SAl_ArtePesca'),'');

       if ((lFAO = '') or (lArte = '')) then
       begin

         //Buscamos la compra del lote y ponermos el arte de pesca y la Fao
         Bd.BuscarFaoArte(lCodArt, lLote, lFaoC, lArteC );
         if lFao = '' then
           if lFAOC <> '' then
               result[1] := VarArrayOf(['SAl_Fao', lFAOC])
           else
           result[1] := VarArrayOf(['SAl_Fao', Null])
         else
           result[1] := VarArrayOf(['SAl_Fao', lFAO]);

         if lArte = '' then
           if lArteC <> '' then
               result[2] := VarArrayOf(['SAl_ArtePesca', lArteC])
           else
           result[2] := VarArrayOf(['SAl_ArtePesca', Null])
         else
           result[2] := VarArrayOf(['SAl_ArtePesca', lArte]);


       end
       else
       begin
         result[1] := VarArrayOf(['SAl_Fao', lFAO]);
         result[2] := VarArrayOf(['SAl_ArtePesca', lArte]);
       end;


   END;
END;
procedure DESPUESDEGUARDARDOCUMENTOV2(Documento: AnsiString; IdDoc: Double; Estado: integer); stdcall;
var
  lFao, lArte : string;
begin
  //En las regularizaciones, calculamos la FAO y el Arte de pesca de la mayor materia prima y
  //lo guardamos en los parametrizables de la cabecera, para luego poder asignarlo a las lineas
  //de lo producido

  if ((documento = 'RE') and (Estado < 2)) then
  begin
      if bd.CalculaYGuardaFAO(IdDoc, lFao, lArte) then
         bd.AsignarFAO(IdDoc, lFao, lArte);
  end;
end;
end.
