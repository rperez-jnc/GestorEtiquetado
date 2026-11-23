unit Dll_GestorEtiquetado;

interface

Uses DmDatos, Dll_Modelo, Dialogs, System.UITypes, System.Classes, JncLib,System.variants, FormLotes,dxCore;

procedure INICIAR(Empresa: PAnsiChar); stdcall;
procedure FINALIZAR; stdcall;
procedure DESPUESDEGUARDARDOCUMENTOV2(Documento: AnsiString; IdDoc: Double; Estado: integer); stdcall;
function REPINTAR(Tabla: AnsiString): boolean; stdcall;
function ANTESDEGUARDARLINEACONDETALLEV2(Documento: AnsiString; Cabecera: variant; Linea: variant; Detalle: variant;
  Estado: integer; var PermitirGuardar: boolean): variant; stdcall;
function SEPROPORCIONADETALLE(Documento: AnsiString; Cabecera: variant; Linea: variant): boolean; stdcall;
procedure OBTDETALLE(Documento: AnsiString; Cabecera: variant; Linea: variant; var Detalle: variant); stdcall;

Var
  Bd:TdmdDatos;

implementation
function SEPROPORCIONADETALLE(Documento: AnsiString; Cabecera: variant; Linea: variant): boolean; stdcall;
begin
  if documento = 'AV' then
     result := true;
end;
procedure OBTDETALLE(Documento: AnsiString; Cabecera: variant; Linea: variant; var Detalle: variant); stdcall;
var
  lCodArt, lLote:string;
    Alpha: Variant;
  lFrmLotes : TFrmLotes;
begin
  lCodArt := TInternoDLL.GetValorCampoVarStr(Linea, 'CodArt');
  //Pedimos el lote a poner en la linea
  lFrmLotes := TFrmLotes.Create(Nil);
  lFrmLotes.Inicializa(Bd, lCodArt);
  LFrmLotes.ShowModal;
  lLote := cuadrasiesnumerico(lFrmLotes.Lote,25);
  lFrmLotes.Free;


  Detalle := VarArrayCreate([0, 1], varVariant);
  Detalle[0] := 1;

  Alpha := VarArrayCreate([0, 1], varVariant);
  Alpha[0] :=  1;
  Alpha[1] := VarArrayOf(['Lote', lLote]);
  Detalle[1] := Alpha;

end;
function REPINTAR(Tabla: AnsiString): boolean; stdcall;
BEGIN
  if Tabla = 'CABEREGU' then
    result := True;

END;
procedure INICIAR(Empresa: PAnsiChar); stdcall;

begin
    dxInitialize;
  Bd := TdmdDatos.Create(nil);
  Bd.Conecta(Empresa);
end;

procedure FINALIZAR; stdcall;
begin

   Bd.Free;
     dxFinalize;
end;

function ANTESDEGUARDARLINEACONDETALLEV2(Documento: AnsiString; Cabecera: variant; Linea: variant; Detalle: variant;
  Estado: integer; var PermitirGuardar: boolean): variant; stdcall;
var
  lIdreg: double;
  lNumLin: integer;
  lListaIdPesos : TStringList;
  lFAO, lArte,lFAOC, lArteC:string;
  lCodArt, lLote: string;
  lUnidades : Integer;
  lKilos: double;
  lUnidadesLinea, lUnidadesCalculadas : double;
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
      lUnidadesLinea := TInternoDll.GetValorCampoVarFloat(Linea,'ge_unidadesventa');

      //Vemos si tenemos que calcular la doble unidad
      if ((documento = 'AV')  and (Estado < 2)) then
       BEGIN
           lCodArt := TInternoDLL.GetValorCampoVarStr(Linea, 'CodArt');
           lLote := TInternoDLL.GetValorCampoDetalleStr(Detalle, 'Lote');

           if bd.ArticuloDobleUnidad(lCodArt) then
           begin
               //Buscamos las lineas de regularizacion en las que está ese articulo con ese lote
               //Se supone que solo está en una regularizacion
               //Sumamos las unidades pesadas y los pesos
               Bd.ObtenerUnidadesPesoArticulo(lCodArt, lLote, lUnidades, lKilos);
               if lUnidades <> 0 then
                  lUnidadesCalculadas := lUnidadesLinea * (lKilos / lUnidades)
               else
                  lUnidadesCalculadas :=  lUnidadesLinea;

           end
           else
               lUnidadesCalculadas :=  lUnidadesLinea;


       END
       else
          lUnidadesCalculadas :=  lUnidadesLinea;

       result := varArrayCreate([0, 3], varVariant);
         result[0] := 3;

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
         result[3] := VarArrayOf(['Unidades', lUnidadesCalculadas]);

       end
       else
       begin
         result[1] := VarArrayOf(['SAl_Fao', lFAO]);
         result[2] := VarArrayOf(['SAl_ArtePesca', lArte]);
         result[3] := VarArrayOf(['Unidades', lUnidadesCalculadas]);
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
