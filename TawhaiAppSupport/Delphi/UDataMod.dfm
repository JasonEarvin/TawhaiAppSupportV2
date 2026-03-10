object DataMod: TDataMod
  OnCreate = DataModuleCreate
  Height = 720
  Width = 960
  PixelsPerInch = 144
  object Con: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba')
    UpdateOptions.AssignedValues = [uvAutoCommitUpdates]
    UpdateOptions.AutoCommitUpdates = True
    Left = 65368
    Top = 48
  end
end
