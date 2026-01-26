unit TwRegUtils;

interface

uses
  Registry,
  System.Classes,
  System.SysUtils,
  System.UITypes,
  System.IniFiles,
  //JclFileUtils,
  //JclRegistry,
  //DbugIntf,
  Vcl.Dialogs,
  Winapi.Windows;

type
  TTwRegUtils = class
  private
    class var MigrationOccurredThisSession: Boolean;
    class var MigrationOccurredPreviously: Boolean;
  public
    class var AppRegRootKey: string;
    class var AppRegDevicesKey: string;
    class var OldRegRootKey: string;
    class var TawhaiRegRootKey: string;
    class function RegValueExists(KeyRoot, Field: string): Boolean;
    class function RegKeyExists(AKey: string): Boolean; static;
    //class function MigrateKey(AOldKey: string; ANewKey: string): Boolean; static;
    class function RegCUValueExists(KeyRoot, Field: string): Boolean;
    class function ReadRegKey(KeyRoot, Field: string; out Value: Integer): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: Int64): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: string): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: Boolean): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: TDateTime): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: TDate): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: TTime): Boolean; overload;
    class function ReadRegKey(KeyRoot, Field: string; out Value: Double): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: Integer; AForceFlush: Boolean = False): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: Int64; AForceFlush: Boolean = False): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: string): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: Boolean): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: TDate): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: TTime): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: TDateTime): Boolean; overload;
    class function WriteRegKey(KeyRoot, Field: string; Value: Double): Boolean; overload;
    class function DeleteRegValue(KeyRoot, Field: string): Boolean;
    class function ReadHKLMRegKey(KeyRoot, Field: string; out Value: string): Boolean; overload;
    class function ReadHKLMRegKey(KeyRoot, Field: string; out Value: Integer): Boolean; overload;
    class function WriteHKLMRegKey(KeyRoot, Field, Value: string): Boolean; overload;
    class function WriteHKLMRegKey(KeyRoot, Field: string; Value: Integer): Boolean; overload;
    class procedure SaveToTextFile(AKeyRoot: string; AFileName: string);
    class procedure SaveToIniFile(AKeyRoot: string; AFileName: string);
    class procedure LoadFromIniFile(AKeyRoot: string; AFileName: string; AIgnoreKey: string);
  end;

implementation

//uses
//  LoggerUnit,
//  TwStringUtils,
//  TwConstants,
//  TwUtils,
//  TwSQLUtils;

{ TTwRegUtils }

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := False;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY or KEY_WRITE);

  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadBool(Field);
      except
        on E:ERegistryException do
        begin
          if Reg.DeleteValue(Field) then
            Reg.WriteBool(Field, False);
        end;
        on E:Exception do
        begin
          //('TTwRegUtils.ReadRegKey: ' + E.Message);
          Result := False;
          Value := False;
        end;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey( '\SOFTWARE', False );
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadBool(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := False;
        end;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := '';
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadString(Field);
      except
        Result := False;
        Value := '';
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadString(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := '';
        end;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: Integer): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then //check current user first
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadInteger(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then //check current user first
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadInteger(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := 0;
        end;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.DeleteRegValue(KeyRoot, Field: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;

    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.LazyWrite := False;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      if not Reg.DeleteValue(Field) then
        Result := False;
      Reg.CloseKey;
    except
      Result := False;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') then
    begin
      try
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.LazyWrite := False;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(OldRegRootKey, True);
        if not Reg.DeleteValue(Field) then
          Result := False;
        Reg.CloseKey;
      except
        Result := False;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadHKLMRegKey(KeyRoot, Field: string; out Value: string): Boolean;
var
  Reg: TRegistry;
begin
  //Result := False;
  Value := '';
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    try
      Result := True;
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Value := Reg.ReadString(Field);
    except
      Result := False;
      Value := '';
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadHKLMRegKey(KeyRoot, Field: string; out Value: Integer): Boolean;
var
  Reg: TRegistry;
begin
  //Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    try
      Result := True;
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Value := Reg.ReadInteger(Field);
    except
      Result := False;
      Value := 0;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: Double): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadFloat(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadFloat(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := 0;
        end;
      end;
    end;

  finally
    Reg.Free;
  end;

end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: TTime): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadTime(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadTime(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := 0;
        end;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: Int64): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then //check current user first
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadInt64(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: TDate): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadDate(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadDate(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := 0;
        end;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.ReadRegKey(KeyRoot, Field: string; out Value: TDateTime): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Value := 0;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    if RegCUValueExists(KeyRoot, Field) then
    begin
      try
        Result := True;
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(KeyRoot, True);
        Value := Reg.ReadDate(Field);
      except
        Result := False;
        Value := 0;
      end;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') and not TTwRegUtils.MigrationOccurredPreviously then
    begin
      if RegCUValueExists(OldRegRootKey, Field) then
      begin
        try
          Result := True;
          Reg.RootKey := HKEY_CURRENT_USER;
          Reg.OpenKey('\SOFTWARE', False);
          Reg.OpenKey(OldRegRootKey, True);
          Value := Reg.ReadDate(Field);
          WriteRegKey(KeyRoot, Field, Value);
          TTwRegUtils.MigrationOccurredThisSession := True;
        except
          Result := False;
          Value := 0;
        end;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.RegCUValueExists(KeyRoot, Field: string): Boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, False);
      Result := Reg.ValueExists(Field);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.RegValueExists(KeyRoot, Field: string): Boolean;
var
  Reg: TRegistry;
begin
  //Reg := TRegistry.Create;
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  try
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, False);
      Result := Reg.ValueExists(Field);
    except
      Result := False;
    end;

    if not Result and (KeyRoot = AppRegRootKey) and (OldRegRootKey <> '') then
    begin
      try
        Reg.RootKey := HKEY_CURRENT_USER;
        Reg.OpenKey('\SOFTWARE', False);
        Reg.OpenKey(OldRegRootKey, False);
        Result := Reg.ValueExists(Field);
      except
        Result := False;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class procedure TTwRegUtils.SaveToIniFile(AKeyRoot, AFileName: string);
var
  Reg: TRegistry;
  IniFile: TIniFile;
  SLLines: TStringList;
  CommentLine: string;

  procedure ProcessRegistryKey(const CurrentPath: string);
  var
    ValueNames, SubKeys: TStringList;
    i: Integer;
    ValueType: TRegDataType;
    ValueData: string;
  begin
    Reg.OpenKey('\SOFTWARE', False);
    Reg.OpenKey(CurrentPath, False);
    ValueNames := TStringList.Create;
    SubKeys := TStringList.Create;
    try
      // Read all values in the current key
      Reg.GetValueNames(ValueNames);
      for i := 0 to ValueNames.Count - 1 do
      begin
        ValueType := Reg.GetDataType(ValueNames[i]);
        case ValueType of
          rdString, rdExpandString:
            ValueData := Reg.ReadString(ValueNames[i]).QuotedString;
          rdInteger:
            ValueData := IntToStr(Reg.ReadInteger(ValueNames[i]));
          rdBinary:
            ValueData := '(binary data)'.QuotedString; // Handle binary data as needed
        else
          ValueData := '(unsupported type)'.QuotedString;
        end;
        IniFile.WriteString(CurrentPath, ValueNames[i], ValueData);
      end;

      // Recursively process subkeys
      Reg.GetKeyNames(SubKeys);
      for i := 0 to SubKeys.Count - 1 do
        ProcessRegistryKey(CurrentPath + '\' + SubKeys[i]);
    finally
      ValueNames.Free;
      SubKeys.Free;
      Reg.CloseKey;
    end;
  end;

begin
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  IniFile := TIniFile.Create(AFileName);
  try
    Reg.RootKey := HKEY_CURRENT_USER; // Change root key if needed
    Reg.OpenKey('\SOFTWARE', False);
    if Reg.KeyExists(AKeyRoot) then
      ProcessRegistryKey(AKeyRoot)
    else
      raise Exception.Create('Registry path does not exist: ' + AKeyRoot);
  finally
    Reg.Free;
    IniFile.Free;
  end;

  CommentLine := ';Automatically created from registry key ' + AKeyRoot + ' by TTwRegUtils.SaveToIniFile';
  SLLines := TStringList.Create;
  try
    SLLines.LoadFromFile(AFileName);
    if SLLines.Count > 0 then
      if SLLines[0] <> CommentLine then
      begin
        SLLines.Insert(0, CommentLine);
        SLLines.SaveToFile(AFileName);
      end;
  finally
    SLLines.Free;
  end;
end;

class procedure TTwRegUtils.LoadFromIniFile(AKeyRoot, AFileName, AIgnoreKey: string);
var
  IniFile: TIniFile;
  Reg: TRegistry;
  Sections, Keys: TStringList;
  Section, Key, Value: string;
  RegSection: string;
  i, j: Integer;
begin
//  IniFile := TIniFile.Create(AFileName);
//  Reg := TRegistry.Create;
//  Sections := TStringList.Create;
//  Keys := TStringList.Create;
//  try
//    // Get all sections from the INI file
//    IniFile.ReadSections(Sections);
//
//    for i := 0 to Sections.Count - 1 do
//    begin
//      Section := Sections[i];
//      RegSection := Section;
//      if not AIgnoreKey.IsEmpty and RegSection.StartsWith(AIgnoreKey) then
//        TTwStringUtils.StrToken(RegSection, AIgnoreKey);
//
//      // Set the Registry path for the current section
//      Reg.RootKey := HKEY_CURRENT_USER;
//      Reg.OpenKey('\SOFTWARE', False);
//      if Reg.OpenKey(AKeyRoot + '\' + RegSection, True) then
//      begin
//        // Get all keys in the current section
//        IniFile.ReadSection(Section, Keys);
//        for j := 0 to Keys.Count - 1 do
//        begin
//          Key := Keys[j];
//          Value := IniFile.ReadString(Section, Key, '');
//          // Write the key-value pair to the Registry
//          if Value.StartsWith('''') and Value.EndsWith('''') then
//            Reg.WriteString(Key, Value.DeQuotedString)
//          else
//          begin
//            try
//              Reg.WriteInteger(Key, StrToInt(Value))
//            except
//              Reg.WriteString(Key, Value);
//            end;
//          end;
//          Logger.Write(Format('Section: %s, Key: %s, Value: %s', [Section, Key, Value]));
//        end;
//        Reg.CloseKey;
//      end;
//    end;
//  finally
//    IniFile.Free;
//    Reg.Free;
//    Sections.Free;
//    Keys.Free;
//  end;
end;

class procedure TTwRegUtils.SaveToTextFile(AKeyRoot: string; AFileName: string);
var
  Reg: TRegistry;
  SLValues: TStringList;
  SLResults: TStringList;
  I: Integer;
  DataType: string;
begin
//  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
//  SLValues := TStringList.Create;
//  SLResults := TStringList.Create;
//  try
//    try
//      Reg.RootKey := HKEY_CURRENT_USER;
//      Reg.OpenKey('\SOFTWARE', False);
//      Reg.OpenKey(AKeyRoot, False);
//
//      Reg.GetValueNames(SLValues);
//
//      for I := 0 to SLValues.Count-1  do
//      begin
//        case Reg.GetDataType(SLValues[I]) of
//          rdUnknown: DataType := 'Unknown';
//          rdString: DataType := 'String';
//          rdExpandString: DataType := 'ExpandString';
//          rdInteger: DataType := 'Integer';
//          rdBinary: DataType := 'Binary';
//        end;
//        SLResults.Add(SLValues[I] + ascTAB + Reg.GetDataAsString(SLValues[I]) + ascTAB + DataType);
//      end;
//      SLResults.SaveToFile(AFileName);
//    except
//    end;
//  finally
//    Reg.Free;
//    SLValues.Free;
//    SLResults.Free;
//  end;
end;

class function TTwRegUtils.RegKeyExists(AKey: string): Boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WOW64_32KEY);
  Result := False;
  try
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      if Reg.OpenKey(AKey, False) then
        Result := True;
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

//class function TTwRegUtils.MigrateKey(AOldKey: string; ANewKey: string): Boolean;
//var
//  Reg: TRegistry;
//  TempFileName: string;
//begin
//  System.Writeln('Attempting to migrate registry settings from ' + AOldKey + ' to ' + ANewKey);
//  Reg := TRegistry.Create(KEY_ALL_ACCESS);
//  Result := False;
//  TempFileName := FileGetTempName('Tawhai');
//  //TempFileName := 'C:\Temp\TempReg.reg';
//  try
//    try
//      //Reg.RootKey := HKEY_CURRENT_USER;
//      Reg.RootKey := HKEY_USERS;
//      Reg.OpenKey('S-1-5-21-3014685433-3912864514-4254054589-1001', False);
//      Reg.OpenKey('\SOFTWARE', False);
//
//      if not TTwSystemUtils.NTSetPrivilege('SeBackupPrivilege', True) then
//      begin
//        System.Writeln('Cannot set privilege needed to migrate registry settings. Try running as administrator.');
//        Exit;
//      end;
//
//      if not TTwSystemUtils.NTSetPrivilege('SeRestorePrivilege', True) then
//      begin
//        System.Writeln('Cannot set privilege needed to migrate registry settings. Try running as administrator.');
//        Exit;
//      end;
//
//      if FileExists(TempFileName) then
//        System.SysUtils.DeleteFile(TempFileName);
//      if Reg.SaveKey(AOldKey, TempFileName) then
//      begin
//        System.Writeln('Saved registry settings to ' + TempFileName)
//      end
//      else
//      begin
//        System.Writeln('Could not save registry settings to ' + TempFileName + '. Error ' + Reg.LastErrorMsg);
//        Exit;
//      end;
//
//      if Reg.LoadKey(ANewKey, TempFileName) then
//      begin
//        System.Writeln('Loaded registry settings from ' + TempFileName);
//        Result := True;
//      end
//      else
//      begin
//        System.Writeln('Could not load registry settings from ' + TempFileName + '. Error ' + IntToStr(Reg.LastError) + ': ' + Reg.LastErrorMsg);
//        Exit;
//      end;
//    except
//      Result := False;
//    end;
//  finally
//    Reg.Free;
//    TTwSystemUtils.NTSetPrivilege('SeBackupPrivilege', False);
//    TTwSystemUtils.NTSetPrivilege('SeRestorePrivilege', False);
//    //System.SysUtils.DeleteFile(TempFileName);
//  end;
//end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field, Value: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteString(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: Integer; AForceFlush: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.LazyWrite := not AForceFlush;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteInteger(Field, Value);
      Reg.CloseKey;
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: TDateTime): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteDateTime(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteHKLMRegKey(KeyRoot, Field, Value: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteString(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteHKLMRegKey(KeyRoot, Field: string; Value: Integer): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteInteger(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: Int64; AForceFlush: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.LazyWrite := not AForceFlush;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteInt64(Field, Value);
      Reg.CloseKey;
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: Double): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteFloat(Field, Value);
    except
      Result := False;
    end;

  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: TTime): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteTime(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteBool(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

class function TTwRegUtils.WriteRegKey(KeyRoot, Field: string; Value: TDate): Boolean;
var
  Reg: TRegistry;
begin
  Result := True;
  Reg := TRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('\SOFTWARE', False);
      Reg.OpenKey(KeyRoot, True);
      Reg.WriteDate(Field, Value);
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

initialization
  TTwRegUtils.AppRegRootKey := 'Tawhai\AppSupportServer';
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'MigrationOccurredPreviously', TTwRegUtils.MigrationOccurredPreviously);

finalization
//  if TTwSystemUtils.InDevMode then
//    SendDebug('Entering TwRegUtils finalization');

  if TTwRegUtils.MigrationOccurredThisSession then
    TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'MigrationOccurredPreviously', True);

//  if TTwSystemUtils.InDevMode then
//    SendDebug('Exiting TwRegUtils finalization');
end.
