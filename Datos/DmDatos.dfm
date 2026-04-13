inherited dmdDatos: TdmdDatos
  Height = 181
  Width = 824
  object sqlBasculas: TADOQuery
    Connection = Conexion
    Parameters = <>
    Left = 144
    Top = 93
  end
  object sqlUsuarios: TADOQuery
    Connection = Conexion
    Parameters = <>
    Left = 320
    Top = 13
  end
  object sqlEtiquetas: TADOQuery
    Connection = Conexion
    Parameters = <>
    Left = 408
    Top = 16
    object sqlEtiquetasId: TIntegerField
      FieldName = 'ge_id'
    end
    object sqlEtiquetasCodigo: TStringField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'ge_Codigo'
      Size = 8
    end
    object sqlEtiquetasFormato: TStringField
      DisplayLabel = 'Formato'
      DisplayWidth = 100
      FieldName = 'ge_Etiqueta'
      Size = 200
    end
    object sqlEtiquetasDescripcion: TStringField
      DisplayLabel = 'Descripci'#243'n'
      FieldName = 'ge_Descripcion'
      Size = 100
    end
  end
  object DsEtiquetas: TDataSource
    DataSet = sqlEtiquetas
    Left = 520
    Top = 16
  end
  object sqlLecturas: TADOQuery
    Connection = Conexion
    Parameters = <>
    Left = 232
    Top = 101
    object sqlLecturasGe_codart: TStringField
      DisplayLabel = 'Articulo'
      FieldName = 'Ge_codart'
      Size = 15
    end
    object sqlLecturasge_descripcion: TStringField
      DisplayLabel = 'Descripci'#243'n'
      FieldName = 'ge_descripcion'
      Size = 50
    end
    object sqlLecturasge_fecha: TDateField
      DisplayLabel = 'Fecha'
      FieldName = 'ge_fecha'
    end
    object sqlLecturasge_lote: TStringField
      DisplayLabel = 'Lote'
      FieldName = 'ge_lote'
      Size = 25
    end
    object sqlLecturasge_usuario: TStringField
      DisplayLabel = 'Usuario'
      FieldName = 'ge_usuario'
      Size = 15
    end
    object sqlLecturasge_Json: TMemoField
      DisplayLabel = 'Json'
      FieldName = 'ge_Json'
      BlobType = ftMemo
    end
    object sqlLecturasge_id: TAutoIncField
      DisplayLabel = 'ID'
      FieldName = 'ge_id'
    end
    object sqlLecturasge_peso: TFloatField
      DisplayLabel = 'Peso'
      FieldName = 'ge_peso'
      DisplayFormat = '#,####0.0000'
    end
    object sqlLecturasge_etiqueta: TStringField
      DisplayLabel = 'Etiqueta'
      FieldName = 'ge_etiqueta'
    end
    object sqlLecturasge_idregu: TFloatField
      DisplayLabel = 'Regularizacion'
      FieldName = 'ge_idregu'
    end
    object sqlLecturasge_impresa: TStringField
      DisplayLabel = 'Impresa'
      FieldName = 'ge_impresa'
      Size = 1
    end
  end
  object DsLecturas: TDataSource
    DataSet = sqlLecturas
    Left = 320
    Top = 104
  end
  object JvmLineasARegularizar: TJvMemoryData
    FieldDefs = <>
    Left = 536
    Top = 96
    object JvmLineasARegularizarGe_codart: TStringField
      DisplayLabel = 'Articulo'
      FieldName = 'Ge_codart'
      Size = 15
    end
    object JvmLineasARegularizarge_descripcion: TStringField
      DisplayLabel = 'Descripci'#243'n'
      FieldName = 'ge_descripcion'
      Size = 50
    end
    object JvmLineasARegularizarge_fecha: TDateField
      DisplayLabel = 'Fecha'
      FieldName = 'ge_fecha'
    end
    object JvmLineasARegularizarge_lote: TStringField
      DisplayLabel = 'Lote'
      FieldName = 'ge_lote'
      Size = 25
    end
    object JvmLineasARegularizarge_id: TFloatField
      FieldName = 'ge_id'
    end
    object JvmLineasARegularizarge_peso: TFloatField
      DisplayLabel = 'Peso'
      FieldName = 'ge_peso'
      DisplayFormat = '#,####0.0000'
    end
  end
  object qEtiqueta: TADOQuery
    Connection = Conexion
    Parameters = <>
    Left = 648
    Top = 21
  end
  object DsEtiqueta: TfrxDBDataset
    UserName = 'Etiquetas'
    CloseDataSource = False
    DataSet = qEtiqueta
    BCDToCurrency = False
    Left = 712
    Top = 16
  end
  object frxReport: TfrxReport
    Version = '5.4.6'
    DataSetName = 'DsEtiqueta'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 43830.471064166690000000
    ReportOptions.LastChange = 43832.404592546300000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 640
    Top = 101
    Datasets = <
      item
        DataSetName = 'DsArticulo'
      end>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
      object DsArticulocodart: TfrxMemoView
        Left = 188.976500000000000000
        Top = 45.354360000000000000
        Width = 120.944960000000000000
        Height = 18.897650000000000000
        DataField = 'codart'
        DataSetName = 'DsArticulo'
        Memo.UTF8W = (
          '[DsArticulo."codart"]')
      end
      object DsArticulodescart: TfrxMemoView
        Left = 75.590600000000000000
        Top = 75.590600000000000000
        Width = 400.630180000000000000
        Height = 18.897650000000000000
        DataField = 'descart'
        DataSetName = 'DsArticulo'
        Memo.UTF8W = (
          '[DsArticulo."descart"]')
      end
    end
  end
  object frxCodBarras: TfrxBarCodeObject
    Left = 712
    Top = 93
  end
  object JvmLineasMarcar: TJvMemoryData
    FieldDefs = <>
    Left = 416
    Top = 112
    object JvmLineasMarcarId: TFloatField
      FieldName = 'Id'
    end
  end
end
