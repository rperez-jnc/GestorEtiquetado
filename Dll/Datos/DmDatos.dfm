inherited dmdDatos: TdmdDatos
  OldCreateOrder = True
  Width = 342
  object sqlLotes: TADOQuery
    Connection = acnConexion
    Parameters = <>
    Left = 208
    Top = 16
  end
  object DsLotes: TDataSource
    DataSet = sqlLotes
    Left = 288
    Top = 16
  end
end
