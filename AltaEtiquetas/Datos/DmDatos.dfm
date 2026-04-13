inherited dmdDatos: TdmdDatos
  Height = 152
  Width = 656
  object sqlEtiquetas: TADOQuery
    Connection = Conexion
    BeforePost = sqlEtiquetasBeforePost
    Parameters = <>
    Left = 216
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
      FieldName = 'ge_Etiqueta'
    end
    object sqlEtiquetasDescripcion: TStringField
      DisplayLabel = 'Descripci'#243'n'
      FieldName = 'ge_Descripcion'
      Size = 100
    end
  end
  object DsEtiquetas: TDataSource
    DataSet = sqlEtiquetas
    Left = 328
    Top = 16
  end
  object JvmFormatos: TJvMemoryData
    FieldDefs = <>
    Left = 424
    Top = 16
    object JvmFormatosFormato: TStringField
      FieldName = 'Formato'
    end
    object JvmFormatosDescripcion: TStringField
      FieldName = 'Descripcion'
    end
  end
  object DsFormatos: TDataSource
    DataSet = JvmFormatos
    Left = 504
    Top = 16
  end
end
