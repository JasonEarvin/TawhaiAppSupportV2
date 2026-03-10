unit AppSupportServerThreadUnit;

interface

uses
  System.SysUtils,
  System.Variants,
  System.IOUtils,
  System.SyncObjs,
  System.JSON,
  Winapi.Windows,
  System.DateUtils,
  IdHTTPServer,
  IdBaseComponent,
  IdComponent,
  IdContext,
  IdGlobal,
  IdURI,
  IdCustomHTTPServer,
  AbBase,
  AbBrowse,
  AbZBrows,
  AbZipper,
  AbUnzper,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.IBWrapper,
  FireDAC.Stan.Param,
  System.UITypes,
  Vcl.Dialogs,
  System.Classes;

type
  TAppSupportServerThread = class(TThread)
  private
    { Private declarations }
    FMsgHandle: THandle;
    FTerminateEvent: TEvent;
    FPurgeBackupsNow: Boolean;
    IdHttpServer: TIdHttpServer;
    procedure IdHTTPServerConnect(AContext: TIdContext);
    procedure IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure LogMsg(AMsg: string);
    procedure Initialise;
    procedure PurgeOldBackupFiles;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;    //sleep alternative
  public
    property MsgHandle: THandle read FMsgHandle write FMsgHandle;
    procedure PurgeBackups;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TAppSupportServerThread }

uses
  TwConstants,
  TwUtils,
  DbugIntf,
//  TwFDQuery,
//  TwConnection,
//  TwUtils,
//  TwSystemUtils,
//  TwStringUtils,
//  HTTPEnumTypesUnit,
//  LoggerUnit,
  UAppSupportConfig;
//  CommonSetupUnit,
//  TwConstants,
//  CameraTypes;

constructor TAppSupportServerThread.Create;
begin
  inherited Create;

  FreeOnTerminate := True;
  FTerminateEvent := TEvent.Create(nil, True, False, '');
  IdHttpServer := TIdHTTPServer.Create(nil);
  IdHttpServer.DefaultPort := 43241;
  IdHttpServer.OnConnect := IdHTTPServerConnect;
  IdHttpServer.OnCommandGet := IdHTTPServerCommandGet;

  //Logger.Write('AppSupport server thread created');

  FMsgHandle := 0;
  Initialise;
end;

destructor TAppSupportServerThread.Destroy;
begin
  FTerminateEvent.Free;
  IdHttpServer.Free;

  inherited;
end;

procedure TAppSupportServerThread.LogMsg(AMsg: string);
var
  StringMsg: TStringMsg;
begin
  //Logger.Write(AMsg);

  if FMsgHandle = 0 then
    Exit;

  StringMsg := TStringMsg.Create(AMsg);
  if not PostMessage(FMsgHandle, WM_LOG_MSG, WPARAM(StringMsg), 0) then
    StringMsg.Free;
end;

procedure TAppSupportServerThread.PurgeBackups;
begin
  FPurgeBackupsNow := True;
end;

procedure TAppSupportServerThread.PurgeOldBackupFiles;

  procedure PurgeBackupFilesInFolder(AFolderName: string);
  var
    SLFiles: TStringList;
    FileNameOrig: string;
    FileName: string;
    YearStr: string;
    MonthStr: string;
    DayStr: string;
    FileDateStamp: TDate;
  begin
    SLFiles := TStringList.Create;
    try
      LogMsg('Purging backup files in ' + AFolderName);
      ConstructFileList(TPath.Combine(AFolderName, '*.zip'), SLFiles, False);
      for FileNameOrig in SLFiles do
      begin
        FileName := TPath.GetFileNameWithoutExtension(FileNameOrig);
        YearStr := StrToken(FileName, '-');
        MonthStr := StrToken(FileName, '-');
        DayStr := StrToken(FileName, '-');

        try
          FileDateStamp := EncodeDate(StrToIntDef(YearStr, 0), StrToIntDef(MonthStr, 0), StrToIntDef(DayStr, 0));
        except
          LogMsg('Skipping file ' + FileNameOrig + ' because date could not be determined');
          Continue;
        end;

        if DaysBetween(Now, FileDateStamp) > 1096 then   //3 years
        begin
          try
            TFile.Delete(FileNameOrig);
            LogMsg('Deleted file ' + FileNameOrig + ' because it was more than three years old');
          except
          end;
          Continue;
        end;

        if DaysBetween(Now, FileDateStamp) > 31 then
        begin
          //delete unless it is the first of the month
          if DayOf(FileDateStamp) > 1 then
          begin
            try
              TFile.Delete(FileNameOrig);
              LogMsg('Deleted file ' + FileNameOrig + ' because it was more than 31 days old');
            except
            end;
            Continue;
          end;
        end;
      end;
    finally
      SLFiles.Free;
    end;
  end;

var
  BaseFolder: string;
  SLFolders: TStringList;
  FolderName: string;
begin
  BaseFolder := AppSupportSettings.RootFolder;
  LogMsg('Purging backup files in ' + BaseFolder);

  SLFolders := TStringList.Create;
  try
    ConstructFolderList(BaseFolder, SLFolders);

    for FolderName in SLFolders do
      PurgeBackupFilesInFolder(FolderName);

  finally
    SLFolders.Free;
  end;

  LogMsg('Backup Purging complete');
end;

procedure TAppSupportServerThread.Execute;
var
  PurgedToday: Boolean;
  Hour: Word;
  Min: Word;
  Sec: Word;
  MSec: Word;
begin
  PurgedToday := False;

  repeat
    FTerminateEvent.WaitFor(1000);

    DecodeTime(Now, Hour, Min, Sec, MSec);

    if Hour < 2 then
      PurgedToday := False;

    if ((Hour = 2) and not PurgedToday) or FPurgeBackupsNow then
    begin
      PurgedToday := True;
      FPurgeBackupsNow := False;
      PurgeOldBackupFiles;
    end;

    if not AppSupportSettings.BackupEnabled then
    begin
      if IdHttpServer.Active then
      begin
        IdHttpServer.Active := False;
        LogMsg('AppSupport server inactive');
      end;
    end;

    if not AppSupportSettings.BackupEnabled then
      Continue;

    if AppSupportSettings.BackupEnabled and not IdHttpServer.Active then
    begin
      Initialise;
      try
        IdHttpServer.Active := True;
      except
        on E:Exception do
          LogMsg('Error opening AppSupport server: ' + E.Message);
      end;
      LogMsg('AppSupport server active');
    end;
  until Terminated;
end;

procedure TAppSupportServerThread.IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);

  procedure ProcessBackup(AFileName: string);
  var
    ConAppSupport: TFDConnection;
    QueryAppSupport: TFDQuery;
    QuerySites: TFDQuery;
    UnzipBackup: TAbUnZipper;
    MemoryStream: TMemoryStream;
    SLVersions: TStringList;
    I: Integer;
    OneVersion: string;
    FBVersion: string;
    AppName: string;
    AppVersion: string;
    //From Jason
    IsValid: Boolean;
    HasFBK: Boolean;
    TempFolder: string;
    TempFBK: string;
    TempFDB: string;
    WBDBFileName: string;
    MsgResult: Integer;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDIBRestore: TFDIBRestore;
    ConWB: TFDConnection;
    QryWB: TFDQuery;
  begin
    //look for version information
    UnzipBackup := TAbUnZipper.Create(nil);
    MemoryStream := TMemoryStream.Create;
    SLVersions := TStringList.Create;
    FBVersion := '';
    AppName := '';
    AppVersion := '';
    HasFBK := false;
    IsValid := HasFBK;
    MemoryStream.Size := 0;

    try
      //From Jason
      UnzipBackup.FileName := AFileName;
      UnzipBackup.ExtractToStream('Versions.txt', MemoryStream);
      UnzipBackup.OpenArchive(AFileName);
      for I := 0 to UnzipBackup.Count - 1 do
      begin
        if SameText(
          TPath.GetExtension(UnzipBackup.Items[I].FileName),'.fbk'
        ) then
        begin
          HasFBK := True;
          Break;
        end;
      end;

      IsValid := HasFBK;

      SLVersions.Delimiter := ascCR;
      SLVersions.StrictDelimiter := True;
      SLVersions.DelimitedText := MemoryStreamToString(MemoryStream);

      for I := 0 to SLVersions.Count-1 do
      begin
        OneVersion := SLVersions[I].Trim;
        if OneVersion.StartsWith(VERSION_FIREBIRD) then
        begin
          StrToken(OneVersion, ' = ');
          FBVersion := OneVersion;
        end
        else
        if OneVersion.StartsWith(VERSION_APPNAME) then
        begin
          StrToken(OneVersion, ' = ');
          AppName := OneVersion;
        end
        else
        if OneVersion.StartsWith(VERSION_APPVERSION) then
        begin
          StrToken(OneVersion, ' = ');
          AppVersion := OneVersion;
        end;
      end;

    finally
      UnzipBackup.CloseArchive;
      UnzipBackup.Free;
      MemoryStream.Free;
      SLVersions.Free;
    end;                                               //TPath.Combine() //TPath.GetTempPath  //TFile.Delete()

    ConAppSupport := TFDConnection.Create(nil);
    QueryAppSupport := TFDQuery.Create(nil);
    QuerySites := TFDQuery.Create(nil);
    try
      ConfigureTFDConnection(ConAppSupport, AppSupportSettings.TawhaiAppSupportDBName);
      QueryAppSupport.Connection := ConAppSupport;
      QuerySites.Connection := ConAppSupport;
      try
        QuerySites.Open('select SiteIdx, SiteFolder from Sites where SiteCode = :SiteCode', [GetParentFolderFromFile(AFileName)]);
        QueryAppSupport.ExecSQL('update Backups set IsCurrentBackup = :IsCurrentBackup where SitesIdx = :SitesIdx', [False, QuerySites.FieldByName('SiteIdx').AsInteger]);


        QueryAppSupport.SQL.Text := 'update or insert into Backups (SitesIdx, BackupReceived, FileName, FileSize, AppName, AppVersion, FBVersion, IsCurrentBackup, IsValid) ' +
        'values (:SitesIdx, :BackupReceived, :FileName, :FileSize, :AppName, :AppVersion, :FBVersion, :IsCurrentBackup, :IsValid) matching (SitesIdx, FileName)';
        QueryAppSupport.ParamByName('SitesIdx').AsInteger := QuerySites.FieldByName('SiteIdx').AsInteger;
        QueryAppSupport.ParamByName('BackupReceived').AsDateTime := Now;
        QueryAppSupport.ParamByName('FileName').AsString := TPath.GetFileName(AFileName);
        QueryAppSupport.ParamByName('FileSize').AsString := FileSizeDesc(AFileName);
        QueryAppSupport.ParamByName('AppName').AsString := AppName;
        QueryAppSupport.ParamByName('AppVersion').AsString := AppVersion;
        QueryAppSupport.ParamByName('FBVersion').AsString := FBVersion;
        QueryAppSupport.ParamByName('IsCurrentBackup').AsBoolean := true;
        QueryAppSupport.ParamByName('IsValid').AsBoolean := IsValid;
        QueryAppSupport.ExecSQL;

        QueryAppSupport.SQL.Text := 'update or insert into Sites (SiteCode, SiteFolder) ' +
        'values (:SiteCode, :SiteFolder) matching (SiteCode)';
        QueryAppSupport.ParamByName('SiteCode').AsString := GetParentFolderFromFile(AFileName);
        QueryAppSupport.ParamByName('SiteFolder').AsString := TPath.GetDirectoryName(AFileName);
        QueryAppSupport.ExecSQL;
      except
        on E:Exception do
        LogMsg('Error saving database: ' + E.Message);
      end;


      //start here (From Jason)
      if HasFBK = true then
      begin
        ConWB := TFDConnection.Create(nil);
        QryWB := TFDQuery.Create(nil);
        try
          // get windows temp folder name
          //TempFolder := TPath.GetTempPath;
          TempFolder := 'C:\Temp';
          ForceDirectories(TempFolder);

          TempFBK := '';
          TempFDB := TPath.Combine(
            TempFolder,
            TPath.GetFileNameWithoutExtension(AFileName) + '.fdb'
          );

          if FileExists(TempFDB) or
             FileExists(TPath.Combine(
               TempFolder,
               TPath.GetFileNameWithoutExtension(AFileName) + '.fbk'
             )) then
          begin
            MsgResult := MessageDlg(
              'A backup/database file with the same date already exists.' + sLineBreak +
              sLineBreak +
              'Do you want to overwrite the existing files?',
              mtConfirmation,
              [mbYes, mbNo],
              0
            );

            if MsgResult <> mrYes then
            begin
              LogMsg('Operation cancelled by user (existing FBK/FDB)');
              Exit;
            end;
          end;

          // get fbk from zip file and save into temp folder
          // Extract FBK from ZIP
          UnzipBackup := TAbUnZipper.Create(nil);
          try
            UnzipBackup.FileName := AFileName;
            UnzipBackup.BaseDirectory := TempFolder;
            UnzipBackup.OpenArchive(AFileName);
            UnzipBackup.ExtractFiles('*.fbk');

            // Find extracted FBK
            for I := 0 to UnzipBackup.Count - 1 do
            begin
              if SameText(
                TPath.GetExtension(UnzipBackup.Items[I].FileName),
                '.fbk'
              ) then
              begin
                TempFBK := TPath.Combine(
                  TempFolder,
                  TPath.GetFileName(UnzipBackup.Items[I].FileName)
                );
                Break;
              end;
            end;

            if TempFBK = '' then
              raise Exception.Create('FBK file not found after extraction');
          finally
            UnzipBackup.CloseArchive;
            UnzipBackup.Free;
          end;

          // restore fbk file to fdb file
          FDPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
          FDIBRestore := TFDIBRestore.Create(nil);
          try
            FDPhysFBDriverLink.VendorLib := 'fbclient.dll';
            FDIBRestore.DriverLink := FDPhysFBDriverLink;

            FDIBRestore.UserName := 'SYSDBA';
            FDIBRestore.Password := 'masterkey';

            FDIBRestore.Database := TempFDB;
            FDIBRestore.BackupFiles.Clear;
            FDIBRestore.BackupFiles.Add(TempFBK);

            FDIBRestore.Options := [roReplace];
            FDIBRestore.Verbose := True;

            FDIBRestore.Restore;
          finally
            FDIBRestore.Free;
            FDPhysFBDriverLink.Free;
          end;

          LogMsg('FBK restored successfully to: ' + TempFDB);

          // create a connection (ConWB) and a query (QryWB) and connect to the fdb file
          ConfigureTFDConnection(ConWB, TempFDB);
          QryWB.Connection := ConWB;
          ConWB.Connected := True;

          // select SeqNum from Transactions order by SeqNum
          QryWB.SQL.Text :=
            'select SEQNUM, DATEOUT + TIMEOUT as TransDateTime from Transactions order by SEQNUM';
          QryWB.Open;

          if QryWB.IsEmpty then
          begin
            LogMsg('No transactions found in backup: ' + TempFDB);
          end
          // write each sequence number into the TransactionLocation table using QueryAppSupport
          else
          begin
            while not QryWB.Eof do
            begin
              QueryAppSupport.SQL.Text :=
                'update or insert into TransactionLocation ' +
                '(SeqNum, TransDateTime, SiteCode, BackupFileName) ' +
                'values (:SeqNum, :TransDateTime, :SiteCode, :BackupFileName) ' +
                'matching (SeqNum, SiteCode)';

              QueryAppSupport.ParamByName('SeqNum').AsLargeInt := QryWB.FieldByName('SeqNum').AsLargeInt;
              QueryAppSupport.ParamByName('TransDateTime').AsDateTime := QryWB.FieldByName('TransDateTime').AsDateTime;
              QueryAppSupport.ParamByName('SiteCode').AsString := GetParentFolderFromFile(AFileName);
              QueryAppSupport.ParamByName('BackupFileName').AsString :=TPath.GetFileName(AFileName);

              QueryAppSupport.ExecSQL;
              QryWB.Next;
            end;
          end;
        finally
          FreeAndNil(QryWB);
          FreeAndNil(ConWB);
        end;
      end;
    finally
      QuerySites.Free;
      QueryAppSupport.Free;
      ConAppSupport.Free;
    end;
  end;

  procedure GetBackupListResponse;
  var
    jsonResponseRootObject : TJSONObject;
    jsonResponseArray : TJSONArray;
    jsonResponseArrayChildObject : TJSONObject;
    jsonResponseString : string;
    Connection: TFDConnection;
    Query: TFDQuery;
  begin
    jsonResponseRootObject := TJSONObject.Create;
    jsonResponseArray := TJSONArray.Create;
    try
      Connection := TFDConnection.Create(nil);
      Query := TFDQuery.Create(nil);
      try
        ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
        Query.Connection := Connection;

        Query.SQL.Text := 'select s.SiteCode, b.BackupIdx, b.BackupReceived, b.AppName, b.AppVersion, b.FBVersion, b.SitesIdx from Backups b ' +
        'left join Sites s on s.SiteIdx = b.SitesIdx where b.IsCurrentBackup = :IsCurrentBackup order by SiteIdx';
        Query.ParamByName('IsCurrentBackup').AsBoolean := True;
        Query.Open;

        while not Query.Eof do
        begin
          jsonResponseArrayChildObject := TJSONObject.Create;
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_SITENAME, Query.FieldByName('SiteCode').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_INDEX, Query.FieldByName('BackupIdx').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_LASTBACKUP, Query.FieldByName('BackupReceived').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_APPNAME, Query.FieldByName('AppName').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_APPVERSION, Query.FieldByName('AppVersion').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_FBVERSION, Query.FieldByName('FBVersion').AsString);
          jsonResponseArrayChildObject.AddPair(JSON_BACKUP_GETLIST_SITESIDX, Query.FieldByName('SitesIdx').AsString);
          jsonResponseArray.Add(jsonResponseArrayChildObject);
          Query.Next;
        end;
        jsonResponseRootObject.AddPair(JSON_BACKUP_CURRENTBACKUPS, jsonResponseArray);
        jsonResponseString := jsonResponseRootObject.ToString;
      except
        on E:Exception do
          //Logger.Write('Error processing GetBackupListResponse in TAppSupportServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    finally
      jsonResponseRootObject.Free;
      Query.Free;
      Connection.Free;
    end;
    try
      AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
    except
       on E:Exception do
          //Logger.Write('Error sending GetBackupListResponse in TAppSupportServerThread.IdHTTPServerCommandGet ' + E.Message);
    end;
  end;

  procedure GetBackupResponse(index: integer);
  var
    filename: string;
    Connection: TFDConnection;
    Query: TFDQuery;
    QuerySites: TFDQuery;
  begin
    Connection := TFDConnection.Create(nil);
    Query := TFDQuery.Create(nil);
    QuerySites := TFDQuery.Create(nil);
    try
      ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
      Query.Connection := Connection;
      QuerySites.Connection := Connection;
      try
        Query.Open('select SitesIdx, FileName from Backups where BackupIdx = :BackupIdx', [index]);
        QuerySites.Open('select SiteFolder from Sites where SiteIdx = :SiteIdx', [Query.FieldByName('SitesIdx').AsInteger]);

        filename := QuerySites.FieldByName('SiteFolder').AsString + '\' + Query.FieldByName('FileName').AsString;
      except
         on E:Exception do
          //Logger.Write('Error processing GetBackupResponse in TAppSupportServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    finally
      Query.Free;
      Connection.Free;
    end;
    try
      if FileExists(filename) then
      begin
        AResponseInfo.ContentStream := TFileStream.Create(filename, fmOpenRead)
      end
      else
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'Backup does not exist';
      end;
    except
      on E:Exception do
          //Logger.Write('Error sending GetBackupResponse in TAppSupportServerThread.IdHTTPServerCommandGet ' + E.Message);
    end;
  end;

  //From Jason
  procedure GetBackupsForSiteResponse;
  var
    JsonRoot: TJSONObject;
    JsonArray: TJSONArray;
    JsonItem: TJSONObject;
    JsonString: string;
    Connection: TFDConnection;
    Query: TFDQuery;
    SiteIdx: Integer;
  begin
    JsonRoot := TJSONObject.Create;
    JsonArray := TJSONArray.Create;

    try
      // Extract the SiteIdx param from URL
      SiteIdx := StrToIntDef(ARequestInfo.Params.Values['SiteIdx'], -1);
      if SiteIdx < 0 then
      begin
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ContentText := 'Invalid SiteIdx';
        Exit;
      end;

      Connection := TFDConnection.Create(nil);
      Query := TFDQuery.Create(nil);
      try
        ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
        Query.Connection := Connection;

        Query.SQL.Text :=
          'select BackupIdx, FileName, BackupReceived, FileSize, AppName, AppVersion, FBVersion ' +
          'from Backups where SitesIdx = :SiteIdx order by BackupReceived desc';
        Query.ParamByName('SiteIdx').AsInteger := SiteIdx;
        Query.Open;

        while not Query.Eof do
        begin
          JsonItem := TJSONObject.Create;
          JsonItem.AddPair('BackupIdx', Query.FieldByName('BackupIdx').AsString);
          JsonItem.AddPair('FileName', Query.FieldByName('FileName').AsString);
          JsonItem.AddPair('LastBackup', Query.FieldByName('BackupReceived').AsString);
          JsonItem.AddPair('FileSize', Query.FieldByName('FileSize').AsString);
          JsonItem.AddPair('AppName', Query.FieldByName('AppName').AsString);
          JsonItem.AddPair('AppVersion', Query.FieldByName('AppVersion').AsString);
          JsonItem.AddPair('FBVersion', Query.FieldByName('FBVersion').AsString);
          JsonArray.AddElement(JsonItem);

          Query.Next;
        end;

        JsonRoot.AddPair('BackupsForSite', JsonArray);
        JsonString := JsonRoot.ToString;

        AResponseInfo.ContentStream := TStringStream.Create(JsonString, TEncoding.UTF8);

      finally
        Query.Free;
        Connection.Free;
      end;

    finally
      JsonRoot.Free;
    end;
  end;

  procedure GetLogo(DeviceName: string);
  var
    CompanyLogo: string;
    TicketLogo: string;
    filename: string;
    Connection: TFDConnection;
    Query: TFDQuery;
    QuerySite: TFDQuery;
  begin
    Connection := TFDConnection.Create(nil);
    Query := TFDQuery.Create(nil);
    QuerySite := TFDQuery.Create(nil);
    try
      ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
      Query.Connection := Connection;
      QuerySite.Connection := Connection;
      try
        QuerySite.Open('Select s.ConfigGroupIdx from Computers c left join Sites s on S.SiteIdx = c.SitesIdx where DeviceName = :DeviceName', [DeviceName]);
        Query.Open('select CompanyLogoPath, TicketLogoPath from ConfigGroups where ConfigGroupIdx = :ConfigGroupIdx', [QuerySite.FieldByName('ConfigGroupIdx').asInteger]);
        CompanyLogo := Query.FieldByName('CompanyLogoPath').AsString;
        TicketLogo := Query.FieldByName('TicketLogoPath').AsString;
      except
         on E:Exception do
          //Logger.Write('Error finding Logo field ' + E.Message);
      end;
    finally
      Query.Free;
      Connection.Free;
    end;
    try
      if FileExists(filename) then
        AResponseInfo.ContentStream := TFileStream.Create(filename, fmOpenRead)
      else
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'Logo does not exist';
    except
      on E:Exception do
          //Logger.Write('Error sending Company logo ' + E.Message);
    end;
  end;

  procedure GetConfigRequest;
  var
    jsonRequestString : string;
    requestGroupString :  string;
    jsonRequestValue : TJSONValue;
    jsonResponseRootObject : TJSONObject;
    jsonResponseChildObject : TJSONObject;
    jsonResponseString : string;
    Connection: TFDConnection;
    Query: TFDQuery;
    QuerySites: TFDQuery;

    function sourceMsg(headerMsg: string) : integer;
    var
      siteIPstring: string;
      siteCodeString: string;
      deviceNameString: string;
    begin

      try
        try
          siteIPstring := ARequestInfo.RawHeaders.Values[X_FORWARDED_FOR];
          if siteIPstring.IsEmpty then
            siteIPstring := AContext.Binding.PeerIP;

          siteCodeString := jsonRequestValue.getValue<string>(JSON_SITECODE);
          if siteCodeString.IsEmpty then
            siteCodeString := 'Unknown site';

          deviceNameString := jsonRequestValue.GetValue<string>(JSON_DEVICENAME);
          if deviceNameString.IsEmpty then
            deviceNameString := 'Unknown device';
        except
          on E:Exception do
            //Logger.Write('Error in TConfigServerThread.IdHTTPServerCommandGet (SourceMsg) ' + E.Message);
        end;
        try
          Query.Open('select ConfigGroupIdx, SiteIdx from Sites where SiteCode = :SiteCode', [siteCodeString]);

//          Query.Open('select s.ConfigGroupIdx, c.SitesIdx from Computers c left join Sites s on s.SiteIdx = c.SitesIdx where c.DeviceName = :DeviceName', [DeviceNameString]);
          if Query.FieldByName('ConfigGroupIdx').IsNull then
          begin
            Result := 1;
            try
              QuerySites.Open('update or insert into Sites (SiteCode, ConfigGroupIdx) values (:SiteCode, :ConfigGroupIdx) matching (SiteCode) returning SiteIdx', [SiteCodeString, 1]);
//              Query.SQL.Text := 'update or insert into Computers (DeviceName, SitesIdx, ConfigGroupIdx) ' +
//              'values (:DeviceName, :SitesIdx, :ConfigGroupIdx) matching (DeviceName)';
//              Query.ParamByName('DeviceName').AsString := deviceNameString;
//              Query.ParamByName('SitesIdx').AsLargeInt := QuerySites.FieldByName('SiteIdx').AsLargeInt;
//              Query.ParamByName('ConfigGroupIdx').AsInteger := 1;
//              Query.ExecSQL;
            except
              on E:Exception do
                //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (SourceMsg) ' + E.Message)
            end;
          end
          else
            Result := Query.FieldByName('ConfigGroupIdx').AsInteger;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (SourceMsg) ' + E.Message)
        end;
      finally
        LogMsg('processing ' + headerMsg + ' request from '+ DeviceNameString + ' ' + siteCodeString + ' [' + siteIPString + ']');
      end;


    end;

    procedure ProcessTestConnection;
    begin

      jsonResponseRootObject := TJSONObject.Create;
      try
        jsonResponseRootObject.AddPair(JSON_CONFIGSERVER_VERSION, GetFileVersion());
        jsonResponseString := jsonResponseRootObject.ToString;
      finally
         jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Test request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessWIS;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select WebsiteHomePage, WISGatewayServiceEndpoint, WISAPIEndpoint, WISAPIKey, TareServerEnabled, TareServerReadTares, TareServerWriteTares from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Website')]);

          jsonResponseChildObject.AddPair(JSON_WEBSITE_HOMEPAGE, Query.FieldByName('WebsiteHomePage').AsString);
          jsonResponseChildObject.AddPair(JSON_WEBSITE_WISGATEWAYSERVICEENDPOINT, Query.FieldByName('WISGatewayServiceEndpoint').AsString);
          jsonResponseChildObject.AddPair(JSON_WEBSITE_WISAPIENDPOINT, Query.FieldByName('WISAPIEndpoint').AsString);
          jsonResponseChildObject.AddPair(JSON_WEBSITE_WISAPIKEY, Query.FieldByName('WISAPIKey').AsString);

          jsonResponseChildObject.AddPair(JSON_TARESERVER_ENABLED, Query.FieldByName('TareServerEnabled').AsBoolean);
          jsonResponseChildObject.AddPair(JSON_TARESERVER_READTARES, Query.FieldByName('TareServerReadTares').AsBoolean);
          jsonResponseChildObject.AddPair(JSON_TARESERVER_WRITETARES, Query.FieldByName('TareServerWriteTares').AsBoolean);

          jsonResponseRootObject.AddPair(JSON_CONFIG_WEBSITE, jsonResponseChildObject);

          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessWIS) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Website request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessCompany;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select ReportLine1, ReportLine2, ReportLine3 from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Company')]);

          jsonResponseChildObject.AddPair(JSON_REPORTS_LINE1, Query.FieldByName('ReportLine1').AsString);
          jsonResponseChildObject.AddPair(JSON_REPORTS_LINE2, Query.FieldByName('ReportLine2').AsString);
          jsonResponseChildObject.AddPair(JSON_REPORTS_LINE3, Query.FieldByName('ReportLine3').AsString);
//          jsonResponseChildObject.AddPair(JSON_COMPANY_GSTNUM, Query.FieldByName('GSTNum').AsString);
//          jsonResponseChildObject.AddPair(JSON_COMPANY_GSTPERCENT, Query.FieldByName('GSTPercent').AsInteger);


          jsonResponseRootObject.AddPair(JSON_CONFIG_COMPANY, jsonResponseChildObject);

          jsonResponseString := jsonResponseRootObject.ToString;

        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessCompany) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Company request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessDriverMode;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select StartButtonText from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Driver Mode')]);

          jsonResponseChildObject.AddPair(JSON_DRIVERMODE_STARTTEXT, Query.FieldByName('StartButtonText').AsString);
          jsonResponseRootObject.AddPair(JSON_CONFIG_DRIVERMODE, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessDriverMode) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Driver Mode request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessLogrithm;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select LogrithmEndpoint, LogrithmAPIKey, LogrithmAddVehicle, LogrithmUpdateTares, LogrithmV2Endpoint, LogrithmV2APIKey, LogrithmV2CompanyID from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Logrithm')]);

          jsonResponseChildObject.AddPair(JSON_LOGRITHM_ENDPOINT, Query.FieldByName('LogrithmEndpoint').AsString);
          jsonResponseChildObject.AddPair(JSON_LOGRITHM_APIKEY, Query.FieldByName('LogrithmAPIKey').AsString);
          jsonResponseChildObject.AddPair(JSON_LOGRITHM_ADDVEHICLE, Query.FieldByName('LogrithmAddVehicle').AsBoolean);
          jsonResponseChildObject.AddPair(JSON_LOGRITHM_UPDATETARES, Query.FieldByName('LogrithmUpdateTares').AsBoolean);

          jsonResponseChildObject.AddPair(JSON_LOGRITHMV2_ENDPOINT, Query.FieldByName('LogrithmV2Endpoint').AsString);
          jsonResponseChildObject.AddPair(JSON_LOGRITHMV2_APIKEY, Query.FieldByName('LogrithmV2APIKey').AsString);
          jsonResponseChildObject.AddPair(JSON_LOGRITHMV2_COMPANYID, Query.FieldByName('LogrithmV2CompanyID').AsString);
          jsonResponseRootObject.AddPair(JSON_CONFIG_LOGRITHM, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessLogrithm) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Logrithm request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);

      end;
    end;

    procedure ProcessNavman;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select NavmanEndpoint, NavmanAPIKey, NavmanClientCode from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Navman')]);

          jsonResponseChildObject.AddPair(JSON_NAVMAN_ENDPOINT, Query.FieldByName('NavmanEndpoint').AsString);
          jsonResponseChildObject.AddPair(JSON_NAVMAN_APIKEY, Query.FieldByName('NavmanAPIKey').AsString);
          jsonResponseChildObject.AddPair(JSON_NAVMAN_CLIENTCODE, Query.FieldByName('NavmanClientCode').AsString);

          jsonResponseRootObject.AddPair(JSON_CONFIG_NAVMAN, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessNavman) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Navman request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessSMSServer;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select SMSAddress, SMSUsername, SMSPassword, SMSEnabled from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('SMS')]);

          jsonResponseChildObject.AddPair(JSON_SMSSERVER_ENDPOINT, Query.FieldByName('SMSAddress').AsString);
//          jsonResponseChildObject.AddPair(JSON_SMSSERVER_MODEMIP, Query.FieldByName('ModemIP').AsString);
          jsonResponseChildObject.AddPair(JSON_SMS_USERNAME, Query.FieldByName('SMSUsername').AsString);
          jsonResponseChildObject.AddPair(JSON_SMS_PASSWORD, Query.FieldByName('SMSPassword').AsString);
          jsonResponseChildObject.AddPair(JSON_SMS_MODEM_MODE, Query.FieldByName('SMSEnabled').AsInteger);

          jsonResponseRootObject.AddPair(JSON_CONFIG_SMS_SERVER, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessSMSServer) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing SMS request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessTicketServer;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select TicketEndpoint from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Ticket')]);

          jsonResponseChildObject.AddPair(JSON_TICKETSERVER_ENDPOINT, Query.FieldByName('TicketEndpoint').AsString);

          jsonResponseRootObject.AddPair(JSON_CONFIG_TICKET_SERVER, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessTicketServer) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Ticket request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessShipMode;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select ShipModeEmail, ShipModePassword from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Ship Mode')]);

          jsonResponseChildObject.AddPair(JSON_SHIPMODE_EMAIL, Query.FieldByName('ShipModeEmail').AsString);
          jsonResponseChildObject.AddPair(JSON_SHIPMODE_EMAIL_PASSWORD, Query.FieldByName('ShipModePassword').AsString);
          jsonResponseRootObject.AddPair(JSON_CONFIG_SHIPMODE, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessShipMode) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing Ship Mode request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessEmail;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select EmailProvider, OauthFrom, OauthClientID, OauthClientSecret, OauthHost, OauthPort, OauthFrom, SMTPFrom, SMTPHost, SMTPPort, SMTPUsername, SMTPPassword, SMTPSecurity, SMTPSendCopy, SMTPAuth from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Email')]);

          jsonResponseChildObject.AddPair(JSON_EMAIL_PROVIDER, Query.FieldByName('EmailProvider').AsInteger);

          jsonResponseChildObject.AddPair(JSON_SMTP_HOST, Query.FieldByName('SMTPHost').AsString);
          jsonResponseChildObject.AddPair(JSON_SMTP_PORT, Query.FieldByName('SMTPPort').AsInteger);
          jsonResponseChildObject.AddPair(JSON_SMTP_USERNAME, Query.FieldByName('SMTPUsername').AsString);
          jsonResponseChildObject.AddPair(JSON_SMTP_FROM, Query.FieldByName('SMTPFrom').AsString);
          jsonResponseChildObject.AddPair(JSON_SMTP_PASSWORD, Query.FieldByName('SMTPPassword').AsString);
          jsonResponseChildObject.AddPair(JSON_SMTP_AUTH, Query.FieldByName('SMTPAuth').AsBoolean);
          jsonResponseChildObject.AddPair(JSON_SMTP_SMTPSSLTLS, Query.FieldByName('SMTPSecurity').AsInteger);
          jsonResponseChildObject.AddPair(JSON_SMTP_COPYTOSELF, Query.FieldByName('SMTPSendCopy').AsBoolean);

          jsonResponseChildObject.AddPair(JSON_OAUTH_CLIENTID, Query.FieldByName('OauthClientID').AsString);
          jsonResponseChildObject.AddPair(JSON_OAUTH_CLIENTSECRET, Query.FieldByName('OauthClientSecret').AsString);
          jsonResponseChildObject.AddPair(JSON_OAUTH_HOST, Query.FieldByName('OauthHost').AsString);
          jsonResponseChildObject.AddPair(JSON_OAUTH_PORT, Query.FieldByName('OauthPort').AsInteger);
          jsonResponseChildObject.AddPair(JSON_OAUTH_FROM, Query.FieldByName('OauthFrom').AsString);

          jsonResponseRootObject.AddPair(JSON_CONFIG_EMAIL, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessSMTP) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing SMTP request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessDatabase;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select BackupEnabled, BackupHost, BackupPort, BackupUsername, BackupPassword from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Database')]);

          jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_ENABLED, Query.FieldByName('BackupEnabled').AsBoolean);
          jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_HOST, Query.FieldByName('BackupHost').AsString);
          jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_PASSWORD, Query.FieldByName('BackupPassword').AsString);
          jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_PORT, Query.FieldByName('BackupPort').AsInteger);
          jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_USERNAME, Query.FieldByName('BackupUsername').AsString);
//          jsonResponseChildObject.AddPair(JSON_HISTORY_PURGE_TIME, Query.FieldByName('HistoryTracePurgeTime').AsInteger);
//          jsonResponseChildObject.AddPair(JSON_ONSITE_PURGE_ENABLED, Query.FieldByName('OnSitePurgeEnabled').AsBoolean);
//          jsonResponseChildObject.AddPair(JSON_ONSITE_PURGE_TIME, Query.FieldByName('OnSitePurgeTime').AsInteger);
//          jsonResponseChildObject.AddPair(JSON_TRANSACTIONS_PURGE_ENABLED, Query.FieldByName('TransactionsPurge').AsBoolean);
//          jsonResponseChildObject.AddPair(JSON_TRANSACTIONS_PURGE_TIME, Query.FieldByName('TransactionsPurgeTime').AsInteger);
//          jsonResponseChildObject.AddPair(JSON_DELETEDTRANS_PURGE_TIME, Query.FieldByName('DeletedTransPurgeTime').AsInteger);
//          jsonResponseChildObject.AddPair(JSON_BACKUP_INTERVAL, Query.FieldByName('BackupInterval').AsInteger);


          jsonResponseRootObject.AddPair(JSON_CONFIG_DATABASE, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessDatabase) ' + E.Message);
        end;
      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing database request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessWindcave;
    begin
      jsonResponseRootObject := TJSONObject.Create;
      jsonResponseChildObject := TJSONObject.Create;
      try
        try
          Query.Open('select WindcaveHost, WindcavePort, WindcaveUsername, WindcavePassword, WindcaveEndpoint from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Windcave')]);

          jsonResponseChildObject.AddPair(JSON_WINDCAVE_URL, Query.FieldByName('WindcaveHost').AsString);
          jsonResponseChildObject.AddPair(JSON_WINDCAVE_PORT, Query.FieldByName('WindcavePort').AsInteger);
          jsonResponseChildObject.AddPair(JSON_WINDCAVE_USERNAME, Query.FieldByName('WindcaveUsername').AsString);
          jsonResponseChildObject.AddPair(JSON_WINDCAVE_PASSWORD, Query.FieldByName('WindcavePassword').AsString);
          jsonResponseChildObject.AddPair(JSON_WINDCAVE_ENDPOINT, Query.FieldByName('WindcaveEndpoint').AsString);

          jsonResponseRootObject.AddPair(JSON_CONFIG_WINDCAVE, jsonResponseChildObject);
          jsonResponseString := jsonResponseRootObject.ToString;
        except
          on E:Exception do
            //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessWindcave) ' + E.Message);
        end;

      finally
        jsonResponseRootObject.Free;
      end;
      try
        AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
      except
         on E:Exception do
            //Logger.Write('Error processing backup request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
    end;

    procedure ProcessStatus;
    var
      StatusValue: TJSONValue;
      DevicesArray: TJSONArray;
      DevicesArrayElement: TJSONValue;
    begin
      sourceMsg('status');
      StatusValue := jsonRequestValue.GetValue<TJSONObject>(JSON_CONFIG_STATUS) as TJSONValue;
      try
        QuerySites.Open('update or insert into Sites (SiteName, SiteCode, GatewayIP, PublicIP) values (:SiteName, :SiteCode, :GatewayIP, :PublicIP) matching (SiteCode) returning SiteIdx', [StatusValue.getValue<string>(JSON_STATUS_NAME), JsonRequestValue.getValue<string>(JSON_SITECODE), StatusValue.getValue<string>(JSON_STATUS_GATEWAYIP), ARequestInfo.RawHeaders.Values[X_FORWARDED_FOR]]);
      except
        on E:Exception do
          //Logger.Write('Error in ProcessStatus, cannot insert values into Sites table ' + E.Message);
      end;

      Query.SQL.Text := 'update or insert into Computers (DeviceName, SitesIdx, AppName, AppVersion, FBVersion, RecentVehicle, RecentDate, RecentTime, LastSeqNum, LastStatusReceived, LocalIP, CPU, Memory, StorageType, StorageCapacity, StorageUse) ' +
        'values (:DeviceName, :SitesIdx, :AppName, :AppVersion, :FBVersion, :RecentVehicle, :RecentDate, :RecentTime, :LastSeqNum, :LastStatusReceived, :LocalIP, :CPU, :Memory, :StorageType, :StorageCapacity, :StorageUse) matching (DeviceName, AppName) returning ComputerIdx';
      try
        Query.ParamByName('DeviceName').AsString := jsonRequestValue.getValue<string>(JSON_DEVICENAME);
        Query.ParamByName('SitesIdx').AsInteger := QuerySites.FieldByName('SiteIdx').AsInteger;
        Query.ParamByName('AppName').AsString := StatusValue.getValue<string>(JSON_STATUS_APPNAME);
        Query.ParamByName('AppVersion').AsString := StatusValue.getValue<string>(JSON_STATUS_APPVERSION);
        Query.ParamByName('FBVersion').AsString := StatusValue.getValue<string>(JSON_STATUS_FBVERSION);
        Query.ParamByName('RecentVehicle').AsString := StatusValue.getValue<string>(JSON_STATUS_RECENTVEHICLE);
        Query.ParamByName('RecentDate').AsDate := DateOf(ISO8601ToDate(StatusValue.getValue<string>(JSON_STATUS_RECENTDATE)));
        Query.ParamByName('RecentTime').AsTime := TimeOf(ISO8601ToDate(StatusValue.getValue<string>(JSON_STATUS_RECENTTIME)));
        Query.ParamByName('LastSeqNum').AsString := StatusValue.getValue<string>(JSON_STATUS_LASTSEQNUM);
        Query.ParamByName('LastStatusReceived').AsDateTime := Now;
        //catch for newly added fields - Older versions of Weighbridge software may not send these.
        try
          Query.ParamByName('LocalIP').AsString := StatusValue.getValue<string>(JSON_STATUS_LOCALIP);
        except
          on E:Exception do
            //Logger.Write('Error in ProcessStatus, cannot process Local IP ' + E.Message);
        end;

        try
          Query.ParamByName('CPU').AsString := StatusValue.getValue<string>(JSON_STATUS_HARDWARE_CPU);
          Query.ParamByName('MemCapacity').AsInteger := StatusValue.getValue<integer>(JSON_STATUS_HARDWARE_MEMORY);
          Query.ParamByName('Storage').Asboolean := StatusValue.getValue<boolean>(JSON_STATUS_HARDWARE_STORAGETYPE);
          Query.ParamByName('StorageCapacity').AsInteger := StatusValue.getValue<integer>(JSON_STATUS_HARDWARE_STORAGECAPACITY);
          Query.ParamByName('StorageUse').AsInteger := StatusValue.getValue<integer>(JSON_STATUS_HARDWARE_STORAGEUSE);
        except
          on E:Exception do
            //Logger.Write('Error in ProcessStatus, no hardware values provided ' + E.Message);
        end;

        Query.Open;

        if StatusValue.TryGetValue(JSON_STATUS_DEVICES, DevicesArray) then
        begin
          //Device status
          try
            QuerySites.SQL.Text := 'update or insert into DeviceStatus (ComputersIdx, Device, Type, Enabled, Online, LastOnline, LastValue) '  +
            'values (:ComputersIdx, :Device, :Type, :Enabled, :Online, :LastOnline, :LastValue) matching (ComputersIdx, Device)';

            for DevicesArrayElement in DevicesArray do
            begin
              QuerySites.ParamByName('ComputersIdx').AsInteger := Query.FieldByName('ComputerIdx').AsInteger;
              QuerySites.ParamByName('Device').AsString := DevicesArrayElement.getValue<string>(JSON_STATUS_DEVICE_NAME);
//              QuerySites.ParamByName('Enabled').AsBoolean := DevicesArrayElement.getValue<Boolean>(JSON_STATUS_DEVICE_ENABLED);
//              if DevicesArrayElement.getValue<Boolean>(JSON_STATUS_DEVICE_ENABLED) then
//              begin
                QuerySites.ParamByName('Type').AsString := DevicesArrayElement.getValue<string>(JSON_STATUS_DEVICE_TYPE);
                QuerySites.ParamByName('Online').AsBoolean := DevicesArrayElement.getValue<Boolean>(JSON_STATUS_DEVICE_ONLINE);
                if DevicesArrayElement.getValue<Boolean>(JSON_STATUS_DEVICE_ONLINE) then
                  QuerySites.ParamByName('LastOnline').AsDateTime := Now;
                try
                  QuerySites.ParamByName('LastValue').AsString := DevicesArrayElement.getValue<string>(JSON_STATUS_DEVICE_LASTVALUE);
//                  if DevicesArrayElement.getValue<string>(JSON_STATUS_DEVICE_TYPE) = CameraTypes.TNPRCameraType.Enum then
//                  begin
//                    //send plate if recieved value is different to last value
//                  end;
                except

                end;
//              end;

              QuerySites.ExecSQL;
            end;

          except
            on E:Exception do
              //Logger.Write('Error in processing device status: ' + E.Message);
          end;
        end;


      except
        on E:Exception do
          //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
      end;
      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ResponseText := 'OK';
    end;

  begin
    jsonRequestString := ReadStringFromStream(ARequestInfo.PostStream);
    jsonRequestValue := TJSONObject.ParseJSONValue(jsonRequestString);
    Connection := TFDConnection.Create(nil);
    Query := TFDQuery.Create(nil);
    QuerySites := TFDQuery.Create(nil);

    try
      if jsonRequestValue = nil then
        Exit;

      ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
      Query.Connection := Connection;
      QuerySites.Connection := Connection;
      requestGroupString := jsonRequestValue.getValue<string>(JSON_CONFIG_GROUP);

      if requestGroupString = JSON_CONFIG_STATUS then
        ProcessStatus
      else
      if requestGroupString = JSON_CONFIG_WEBSITE then
        ProcessWIS
      else
      if requestGroupString = JSON_CONFIG_NAVMAN then
        ProcessNavman
      else
      if requestGroupString = JSON_CONFIG_EMAIL then
        ProcessEmail
      else
      if requestGroupString = JSON_CONFIG_TESTCONNECT then
        ProcessTestConnection
      else
      if requestGroupString = JSON_CONFIG_SMS_SERVER then
        ProcessSMSServer
      else
      if requestGroupString = JSON_CONFIG_TICKET_SERVER then
        ProcessTicketServer
      else
      if requestGroupString = JSON_CONFIG_DATABASE then
        ProcessDatabase
      else
      if requestGroupString = JSON_CONFIG_WINDCAVE then
        ProcessWindcave
      else
      if requestGroupString = JSON_CONFIG_DRIVERMODE then
        ProcessDriverMode
      else
      if requestGroupString = JSON_CONFIG_COMPANY then
        ProcessCompany
      else
      if requestGroupString = JSON_CONFIG_SHIPMODE then
        ProcessShipMode
      else
      if requestGroupString = JSON_CONFIG_LOGRITHM then
        ProcessLogrithm
      else
        LogMsg('Received invalid request for ' + requestGroupString + ' from '+ ARequestInfo.RawHeaders.Values[X_FORWARDED_FOR]);

    finally
       jsonRequestValue.Free;
       Query.Free;
       QuerySites.Free;
       Connection.Free;
    end;
  end;

var
  FileStream: TFileStream;
  SLParams: TStringList;
  SiteCode: string;
  Action: string;
  FileName: string;
  DestFileName: string;
  BackupIndex: string;
  SiteIdx: Integer;

begin
  SLParams := TStringList.Create;
  try
    try
      SLParams.Delimiter := '&';
      SLParams.StrictDelimiter := True;
      SLParams.DelimitedText := TIdURI.URLDecode(ARequestInfo.QueryParams);

      if (ARequestInfo.AuthUsername <> AppSupportSettings.BackupUsername) or (ARequestInfo.AuthPassword <> AppSupportSettings.BackupPassword) then
      begin
        LogMsg(Format('HTTP client attempted to connect with username %s and password %s. Denied access.', [ARequestInfo.AuthUsername, ARequestInfo.AuthPassword]));
        AResponseInfo.ResponseNo := 401;
        AResponseInfo.ResponseText := 'Invalid username or password';
        Exit;
      end;

      if SLParams.Values[CONFIG_REQUEST] = 'Y' then
      begin
        GetConfigRequest;
        Exit;
      end;

      if SLParams.Values[HTTP_BACKUP_GETLIST] = 'Y' then
      begin
        LogMsg('Processing request to get Backups list');
        GetBackupListResponse;
        Exit;
      end;

      //From Jason
      if SLParams.Values[HTTP_BACKUP_ACTION_GETBACKUPSFORSITE] = 'Y' then
      begin
        LogMsg('Processing request to get Backups list');
        GetBackupsForSiteResponse;
        Exit;
      end;

      //From Jason
      BackupIndex := SLParams.Values[HTTP_BACKUP_GETBACKUP];
      if not BackupIndex.isEmpty then
      begin
        try
          GetBackupResponse(BackupIndex.ToInteger);
        except
          on E:Exception do
            LogMsg('Invalid index requested');
        end;
        Exit;
      end;

      SiteCode := SLParams.Values[HTTP_BACKUP_SITECODE];
      if SiteCode.IsEmpty then
      begin
        LogMsg('Ignoring request because no site code was specified.');
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'No SiteCode specified';
        Exit;
      end;

      if SiteCode.Length > 50 then
      begin
        LogMsg('Ignoring request because site code is too long: ' + SiteCode);
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'SiteCode too long';
        Exit;
      end;

      if not TPath.HasValidFileNameChars(SiteCode, False) then
      begin
        LogMsg('Ignoring request because site name is invalid: ' + SiteCode);
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'SiteName invalid';
        Exit;
      end;

      Action := SLParams.Values[HTTP_BACKUP_ACTION];
      if Action.IsEmpty then
      begin
        LogMsg('Ignoring request because no action was specified.');
        AResponseInfo.ResponseNo := 400;
        AResponseInfo.ResponseText := 'No Action specified';
        Exit;
      end;

      if Action = HTTP_BACKUP_ACTION_ONLINECHECK then
      begin
        LogMsg('Confirming with site ' + SiteCode + ' that backup server is online');
        AResponseInfo.ResponseNo := 200;
        AResponseInfo.ResponseText := 'Backup server online';
        Exit;
      end
      else
      if Action = HTTP_BACKUP_ACTION_BACKUPFILE then
      begin
        FileName := SLParams.Values[HTTP_BACKUP_FILENAME];
        if FileName.IsEmpty then
        begin
          LogMsg('Ignoring request because no filename was specified.');
          AResponseInfo.ResponseNo := 400;
          AResponseInfo.ResponseText := 'No FileName specified';
          Exit;
        end;

        if FileName.Length > 100 then
        begin
          LogMsg('Ignoring request because filename is too long: ' + SiteCode);
          AResponseInfo.ResponseNo := 400;
          AResponseInfo.ResponseText := 'FileName too long';
          Exit;
        end;

        LogMsg('Backup file being processed from ' + SiteCode + '. Size: ' + ARequestInfo.PostStream.Size.ToString + ', name: ' + FileName);
        DestFileName := TPath.Combine(AppSupportSettings.RootFolder, SiteCode);
        if not TDirectory.Exists(DestFileName) then
          ForceDirectories(DestFileName);
        DestFileName := TPath.Combine(DestFileName, FileName);
        if TFile.Exists(DestFileName) then
          TFile.Delete(DestFileName);
        LogMsg('Saving backup file to ' + DestFileName);

        FileStream := TFileStream.Create(DestFileName, fmCreate);
        try
          try
            ARequestInfo.PostStream.Position := 0;
            FileStream.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
          finally
            FileStream.Free;
          end;
          ProcessBackup(DestFileName);
          LogMsg('Saved backup file to ' + DestFileName);
        except
          on E:Exception do
            LogMsg('Error saving backup file: ' + E.Message);
        end;
      end
      else
    except
      on E:Exception do
        LogMsg('Error in TAppSupportServerThread.IdHTTPServerCommandGet: ' + E.Message);
    end;

  finally
    SLParams.Free;
    PostMessage(FMsgHandle, WM_REFRESH_HISTORY, 0, 0);
  end;
end;

procedure TAppSupportServerThread.IdHTTPServerConnect(AContext: TIdContext);
begin
  SendDebug('Connection from HTTP client ' + AContext.Binding.PeerIP);
end;

procedure TAppSupportServerThread.Initialise;
begin

end;

procedure TAppSupportServerThread.TerminatedSet;
begin
  inherited;
  FTerminateEvent.SetEvent;
end;

end.
