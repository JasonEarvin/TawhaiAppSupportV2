unit UDataMod;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  System.IOUtils,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Script, FireDAC.Phys.FB, FireDAC.Phys.FBDef;
type
  TDataMod = class(TDataModule)
    Con: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure CreateLocalDatabase(ALocalDBName: string);
    procedure CheckTables;
  public
    { Public declarations }
  end;

var
  DataMod: TDataMod;

implementation

uses
//  TwFDQuery,
//  TwConnection,
//  LoggerUnit,
//  DbugIntf,
//  TwSystemUtils,
  TwUtils,
  TwConstants,
  TwRegUtils,
  UAppSupportConfig;
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDataMod.DataModuleCreate(Sender: TObject);
var
  DBName: string;
begin
  if AppSupportSettings.TawhaiAppSupportDBName.IsEmpty then
  begin
    DBName := TPath.Combine(PrivateFolder, 'Data');
    if not DirectoryExists(DBName) then
      ForceDirectories(DBName);
    DBName := 'localhost:' + DBName + '\TawhaiAppSupportData.fdb';
    AppSupportSettings.TawhaiAppSupportDBName := DBName;
  end;

  Con := TFDConnection.Create(nil);
  ConfigureTFDConnection(Con, AppSupportSettings.TawhaiAppSupportDBName);
  CreateLocalDatabase(AppSupportSettings.TawhaiAppSupportDBName);

  CheckTables;

  ConfigureTFDConnection(Con, AppSupportSettings.TawhaiAppSupportDBName);
end;

procedure TDataMod.CreateLocalDatabase(ALocalDBName: string);
var
  FDScript: TFDScript;
  SLScript: TStringList;
  UserName: string;
  Password: string;
  DBExists: Boolean;
begin
  DBExists := False;
  try
    Con.Connected := True;
    DBExists := True;
  except
    on E:EFDDBEngineException do
      if E.Message.ToUpper.Contains('UNSUPPORTED ON-DISK STRUCTURE FOR FILE') then
        raise Exception.Create(ALocalDBName + ' is wrong version');
  end;

  if DBExists then
    Exit;

  UserName := FIREBIRD_USERNAME;
  Password := FIREBIRD_PASSWORD;

  FDScript := TFDScript.Create(nil);
  SLScript := TStringList.Create;
  try
    FDScript.Connection := Con;

    SLScript.Add('SET SQL DIALECT 3;');
    SLScript.Add('SET NAMES UTF8;');
    SLScript.Add('CREATE DATABASE ' + QuotedStr(ALocalDBName));
    SLScript.Add('  USER ' + QuotedStr(UserName) + ' PASSWORD ' + QuotedStr(Password));
    SLScript.Add('  PAGE_SIZE 16384');
    SLScript.Add('  DEFAULT CHARACTER SET UTF8;');

    try
      FDScript.ExecuteScript(SLScript);
    except
      on E:Exception do
        //SendDebug(E.Message);
    end;
  finally
    FDScript.Free;
    SLScript.Free;
  end;
end;

procedure TDataMod.CheckTables;

  procedure CreateSitesTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'Sites';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('SiteIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('SiteCode', ftString, 50, False);
      Table.FieldDefs.Add('SiteName', ftString, 50, False);
      Table.FieldDefs.Add('GatewayIP', ftString, 50, False);
      Table.FieldDefs.Add('PublicIP', ftString, 50, False);
      Table.FieldDefs.Add('SiteFolder', ftString, 250, False);
      Table.FieldDefs.Add('ConfigGroupIdx', ftLargeInt, 0, False);
      Table.AddIndex('pkSiteIdx', 'SiteIdx', '', [soPrimary]);
      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
      //Logger.Write('Sites table created');
    finally
      Table.Free;
    end;
  end;

  procedure CreateBackupsTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'Backups';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('BackupIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('SitesIdx', ftLargeInt, 0, False);
      Table.FieldDefs.Add('BackupReceived', ftDateTime, 0, False);
      Table.FieldDefs.Add('FileName', ftString, 250, False);
      Table.FieldDefs.Add('FileSize', ftString, 50, False);
      Table.FieldDefs.Add('AppName', ftString, 50, False);
      Table.FieldDefs.Add('AppVersion', ftString, 25, False);
      Table.FieldDefs.Add('FBVersion', ftString, 25, False);
      Table.FieldDefs.Add('IsCurrentBackup', ftBoolean, 0, False);
      Table.FieldDefs.Add('IsValid', ftBoolean, 0, False);
      Table.AddIndex('pkBackupIdx', 'BackupIdx', '', [soPrimary]);
      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
      //Logger.Write('Backups table created');
    finally
      Table.Free;
    end;
  end;

  //From Jason
  procedure CreateTransactionLocationTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'TransactionLocation';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('TransactionLocationIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('TransDateTime', ftTimeStamp, 0, False);
      Table.FieldDefs.Add('SeqNum', ftLargeint, 0, False);
      Table.FieldDefs.Add('SiteCode', ftString, 50, False);
      Table.FieldDefs.Add('BackupFileName', ftString, 250, False);
      Table.AddIndex('pkTransactionLocationIdx', 'TransactionLocationIdx', '', [soPrimary]);
      Table.AddIndex('idxSeqNum', 'SeqNum', '', []);
      Table.AddIndex('uqSeqNumSite', 'SeqNum;SiteCode', '', [soUnique]);
      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers, tpIndexes]);
      //Logger.Write('TransactionLocation table created');
    finally
      Table.Free;
    end;
  end;

  procedure CreateComputersTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'Computers';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('ComputerIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('DeviceName', ftString, 50, False);
      Table.FieldDefs.Add('SitesIdx', ftLargeInt, 0, False);
      Table.FieldDefs.Add('AppName', ftString, 50, False);
      Table.FieldDefs.Add('AppVersion', ftString, 25, False);
      Table.FieldDefs.Add('FBVersion', ftString, 25, False);
      Table.FieldDefs.Add('IsUpToDate', ftBoolean, 0, False);
      Table.FieldDefs.Add('RecentVehicle', ftString, 25, False);
      Table.FieldDefs.Add('RecentDate', ftDateTime, 0, False);
      Table.FieldDefs.Add('RecentTime', ftDateTime, 0, False);
      Table.FieldDefs.Add('LastSeqNum', ftString, 50, False);
      Table.FieldDefs.Add('LastStatusReceived', ftDateTime, 0, False);
      Table.FieldDefs.Add('LocalIP', ftString, 50, False);
      Table.FieldDefs.Add('CPU', ftString, 25, False);
      Table.FieldDefs.Add('Memory', ftInteger, 0, False);
      Table.FieldDefs.Add('StorageType', ftBoolean, 0, False);
      Table.FieldDefs.Add('StorageCapacity', ftInteger, 0, False);
      Table.FieldDefs.Add('StorageUse', ftInteger, 0, False);

      Table.AddIndex('pkComputerIdx', 'ComputerIdx', '', [soPrimary]);
      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
      //Logger.Write('Computers table created');
    finally
      Table.Free;
    end;
  end;

  procedure CreateDeviceStatusTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'DeviceStatus';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('DeviceStatusIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('ComputersIdx', ftLargeInt, 0, False);
      Table.FieldDefs.Add('Device', ftString, 25, False);
      Table.FieldDefs.Add('Type', ftString, 25, False);
      Table.FielDDefs.Add('Enabled', ftBoolean, 0, False);
      Table.FielDDefs.Add('Online', ftBoolean, 0, False);
      Table.FielDDefs.Add('LastOnline', ftDateTime, 0, False);
      Table.FieldDefs.Add('LastValue', ftString, 25, False);

      Table.AddIndex('plDeviceStatusIdx', 'DeviceStatusIdx', '', [soPrimary]);
      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
      //Logger.Write('Device Status table created');
    finally

    end;

  end;

  procedure CreateConfigGroupsTable;
  var
    Table: TFDTable;
  begin
    Table := TFDTable.Create(nil);
    try
      Table.Connection := Con;
      Table.TableName := 'ConfigGroups';
      Table.FieldDefs.Clear;
      Table.FieldDefs.Add('ConfigGroupsIdx', ftAutoInc, 0, False);
      Table.FieldDefs.Add('ConfigGroup', ftString, 50, False);

      Table.FieldDefs.Add('TicketEndpoint', ftString, 250, False);

      Table.FieldDefs.Add('TicketLogoPath', ftString, 250, False);

      Table.FieldDefs.Add('WebsiteHomePage', ftString, 250, False);
      Table.FieldDefs.Add('WISGatewayServiceEndpoint', ftString, 250, False);
      Table.FieldDefs.Add('WISAPIEndpoint', ftString, 250, False);
      Table.FieldDefs.Add('WISAPIKey', ftString, 250, False);

      Table.FieldDefs.Add('TareServerEnabled', ftBoolean, 0, False);
      Table.FieldDefs.Add('TareServerReadTares', ftBoolean, 0, False);
      Table.FieldDefs.Add('TareServerWriteTares', ftBoolean, 0, False);

      Table.FieldDefs.Add('LogrithmEndpoint', ftString, 250, False);
      Table.FieldDefs.Add('LogrithmAPIKey', ftString, 250, False);
      Table.FieldDefs.Add('LogrithmAddVehicle', ftBoolean, 0, False);
      Table.FieldDefs.Add('LogrithmUpdateTares', ftBoolean, 0, False);

      Table.FieldDefs.Add('LogrithmV2Endpoint', ftString, 250, False);
      Table.FieldDefs.Add('LogrithmV2APIKey', ftString, 250, False);
      Table.FieldDefs.Add('LogrithmV2CompanyID', ftString, 50, False);

      Table.FieldDefs.Add('StartButtonText', ftString, 250, False);

      Table.FieldDefs.Add('ShipModeEmail', ftString, 250, False);
      Table.FieldDefs.Add('ShipModePassword', ftString, 250, False);

      Table.FieldDefs.Add('ReportLine1', ftString, 250, False);
      Table.FieldDefs.Add('ReportLine2', ftString, 250, False);
      Table.FieldDefs.Add('ReportLine3', ftString, 250, False);

      Table.FieldDefs.Add('CompanyLogoPath', ftString, 250, False);


      Table.FieldDefs.Add('SMSAddress', ftString, 50, False);
      Table.FieldDefs.Add('SMSUsername', ftString, 50, False);
      Table.FieldDefs.Add('SMSPassword', ftString, 50, False);
      Table.FieldDefs.Add('SMSEnabled', ftInteger, 0, False);

      Table.FieldDefs.Add('NavmanEndpoint', ftString, 250, False);
      Table.FieldDefs.Add('NavmanAPIKey', ftString, 250, False);
      Table.FieldDefs.Add('NavmanClientCode', ftString, 250, False);

      Table.FieldDefs.Add('EmailProvider', ftInteger, 0, False);

      Table.FieldDefs.Add('OauthClientID', ftString, 250, False);
      Table.FieldDefs.Add('OauthClientSecret', ftString, 250, False);
      Table.FieldDefs.Add('OauthHost', ftString, 50, False);
      Table.FieldDefs.Add('OauthFrom', ftString, 50, False);
      Table.FieldDefs.Add('OauthPort', ftInteger, 0, False);

      Table.FieldDefs.Add('SMTPHost', ftString, 25, False);
      Table.FieldDefs.Add('SMTPPort', ftInteger, 0, False);
      Table.FieldDefs.Add('SMTPUsername', ftString, 50, False);
      Table.FieldDefs.Add('SMTPPassword', ftString, 50, False);
      Table.FieldDefs.Add('SMTPFrom', ftString, 25, False);
      Table.FieldDefs.Add('SMTPSecurity', ftInteger, 0, False);
      Table.FieldDefs.Add('SMTPSendCopy', ftBoolean, 0, False);
      Table.FieldDefs.Add('SMTPAuth', ftBoolean, 0, False);

      Table.FieldDefs.Add('BackupEnabled', ftBoolean, 0, False);
      Table.FieldDefs.Add('BackupHost', ftString, 25, False);
      Table.FieldDefs.Add('BackupPort', ftString, 25, False);
      Table.FieldDefs.Add('BackupUsername', ftString, 25, False);
      Table.FieldDefs.Add('BackupPassword', ftString, 25, False);

      Table.FieldDefs.Add('WindcaveHost', ftString, 25, False);
      Table.FieldDefs.Add('WindcavePort', ftInteger, 0, False);
      Table.FieldDefs.Add('WindcaveUsername', ftString, 25, False);
      Table.FieldDefs.Add('WindcavePassword', ftString, 25, False);
      Table.FieldDefs.Add('WindcaveEndpoint', ftString, 250, False);

      Table.AddIndex('pkConfigGroupsIdx', 'ConfigGroupsIdx', '', [soPrimary]);

      Table.CreateTable(False, [tpTable, tpPrimaryKey, tpGenerators, tpTriggers]);
      //Logger.Write('Config groups table created');
    finally
      Table.Free;
    end;
  end;

  procedure CreateDefaultConfigGroup;
  var
    Query: TFDQuery;
  begin
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := Con;
      Query.SQL.Text := 'update or insert into ConfigGroups (ConfigGroup, TicketEndpoint, WebsitehomePage, WISGatewayServiceEndpoint, TareServerEnabled, TareServerReadTares, TareServerWriteTares, LogrithmEndpoint, LogrithmAPIKey, LogrithmAddVehicle, LogrithmUpdateTares, LogrithmV2Endpoint, LogrithmV2APIKey, LogrithmV2CompanyID, SMSAddress, SMSUsername, SMSPassword, SMSEnabled, NavmanEndpoint, NavmanAPIKey, NavmanClientCode, EmailProvider, OauthFrom, OauthClientID, OauthClientSecret, OauthHost, OauthPort, SMTPFrom, SMTPHost, SMTPPort, SMTPUsername, SMTPPassword, SMTPSecurity, SMTPSendCopy, SMTPAuth, BackupEnabled, BackupHost, BackupPort, BackupUsername, BackupPassword, WindcaveHost, WindcavePort, WindcaveUsername, WindcavePassword, WindcaveEndpoint, StartButtonText, ReportLine1, ReportLine2, ReportLine3, ShipModeEmail, ShipModePassword, WISAPIEndpoint, WISAPIKey) ' +
        'values (:ConfigGroup, :TicketEndpoint, :WebsitehomePage, :WISGatewayServiceEndpoint, :TareServerEnabled, :TareServerReadTares, :TareServerWriteTares, :LogrithmEndpoint, :LogrithmAPIKey, :LogrithmAddVehicle, :LogrithmUpdateTares, :LogrithmV2Endpoint, :LogrithmV2APIKey, :LogrithmV2CompanyID, :SMSAddress, :SMSUsername, :SMSPassword, :SMSEnabled, :NavmanEndpoint, :NavmanAPIKey, :NavmanClientCode, :EmailProvider, :OauthFrom, :OauthclientID, :OauthClientSecret, :OauthHost, :OauthPort, :SMTPFrom, :SMTPHost, :SMTPPort, :SMTPUsername, :SMTPPassword, :SMTPSecurity, :SMTPSendCopy, :SMTPAuth, :BackupEnabled, :BackupHost, :BackupPort, :BackupUsername, :BackupPassword, :WindcaveHost, :WindcavePort, :WindcaveUsername, :WindcavePassword, :WindcaveEndpoint, :StartButtonText, :ReportLine1, :ReportLine2, :ReportLine3, :ShipModeEmail, :ShipModePassword, :WISAPIEndpoint, :WISAPIKey) matching (ConfigGroup)';
      try
        Query.ParamByName('ConfigGroup').AsString := 'Default';

        Query.ParamByName('TicketEndpoint').AsString := 'https://wmsnzportal.co.nz/ticket';
//        Query.ParamByName('TicketLogoPath').AsString := '';

//        Query.ParamByName('TicketHeaderLine1Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketHeaderLine1Alignment').AsInteger := 1;
//        Query.ParamByName('TicketHeaderLine1Style').AsIntegers := (1,0,0,0,0);

//        Query.ParamByName('TicketHeaderLine2Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketHeaderLine2Alignment').AsInteger := 1;
//        Query.ParamByName('TicketHeaderLine2Style').AsIntegers := [1,0,0,0,0];
//
//        Query.ParamByName('TicketHeaderLine3Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketHeaderLine3Alignment').AsInteger := 1;
//        Query.ParamByName('TicketHeaderLine3Style').AsIntegers := [1,0,0,0,0];
//
//        Query.ParamByName('TicketFooterLine1Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketFooterLine1Alignment').AsInteger := 1;
//        Query.ParamByName('TicketFooterLine1Style').AsIntegers := [1,0,0,0,0];
//
//        Query.ParamByName('TicketFooterLine2Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketFooterLine2Alignment').AsInteger := 1;
//        Query.ParamByName('TicketFooterLine2Style').AsIntegers := [1,0,0,0,0];
//
//        Query.ParamByName('TicketFooterLine3Text').AsString := 'WMS NZ Limited';
//        Query.ParamByName('TicketFooterLine3Alignment').AsInteger := 1;
//        Query.ParamByName('TicketFooterLine3Style').AsIntegers := [1,0,0,0,0];

        Query.ParamByName('WebsitehomePage').AsString := 'https://weighsolutions.co.nz';
        Query.ParamByName('WISGatewayServiceEndpoint').AsString := 'https://login.wmsnzportal.co.nz';
        Query.ParamByName('WISAPIEndpoint').AsString := 'https://api.wmsnzportal.co.nz';
        Query.ParamByName('WISAPIKey').AsString := '46691EEE-C10A-4E57-A932-6F8FF6E90BF7';

        Query.ParamByName('TareServerEnabled').AsBoolean := true;
        Query.ParamByName('TareServerReadTares').AsBoolean := true;
        Query.ParamByName('TareServerWriteTares').AsBoolean := false;

        Query.ParamByName('LogrithmEndpoint').AsString := 'https://api.logrithm.app/logrithm-wb-api-prod';
        Query.ParamByName('LogrithmAPIKey').AsString := 'cb432549d3f0411a8ec0aa4ccdcf58e2';
        Query.ParamByName('LogrithmAddVehicle').AsBoolean := false;
        Query.ParamByName('LogrithmUpdateTares').AsBoolean := false;

        Query.ParamByName('LogrithmV2Endpoint').AsString := 'https://api.logrithm.app/prod';
        Query.ParamByName('LogrithmV2APIKey').AsString := '52fb5d0e-b0a8-4fa1-b69b-30380f2ed23b';
        Query.ParamByName('LogrithmV2CompanyID').AsString := 'WMN';

        Query.ParamByName('StartButtonText').AsString := 'Tap here to enter REGO or use tag';

        Query.ParamByName('ShipModeEmail').AsString := 'shipping@weighsolutions.nz';
        Query.ParamByName('ShipModePassword').AsString := 'Yuf63332';

        Query.ParamByName('ReportLine1').AsString := 'WMS';
        Query.ParamByName('ReportLine2').AsString := '0800';
        Query.ParamByName('ReportLine3').AsString := 'Napier';

        Query.ParamByName('SMSAddress').AsString := 'https://sms.wmsnzportal.co.nz';
        Query.ParamByName('SMSUsername').AsString := 'admin';
        Query.ParamByName('SMSPassword').AsString := 'Weighbridge01#';
        Query.ParamByName('SMSEnabled').AsInteger := 1;

        Query.ParamByName('NavmanEndpoint').AsString := 'https://api-au.telematics.com/v1/';
        Query.ParamByName('NavmanAPIKey').AsString := 'b3acf4e796c641d8a3b57d625c35ff06';
        Query.ParamByName('NavmanClientCode').AsString := '66633';

        Query.ParamByName('EmailProvider').AsInteger := 0;

        Query.ParamByName('OauthClientID').AsString := '';
        Query.ParamByName('OauthClientSecret').AsString := '';
        Query.ParamByName('Oauthhost').AsString := '';
        Query.ParamByName('OauthPort').AsInteger := 465;
        Query.ParamByName('OauthFrom').AsString := '';

        Query.ParamByName('SMTPHost').AsString := 'smtp.office365.com';
        Query.ParamByName('SMTPPort').AsInteger := 587;
        Query.ParamByName('SMTPUsername').AsString := 'reports@weighsolutions.nz';
        Query.ParamByName('SMTPPassword').AsString := 'Yuf63332';
        Query.ParamByName('SMTPFrom').AsString := 'reports@weighsolutions.nz';
        Query.ParamByName('SMTPSecurity').AsInteger := 1;
        Query.ParamByName('SMTPSendCopy').AsBoolean := false;
        Query.ParamByName('SMTPAuth').AsBoolean := true;

        Query.ParamByName('BackupEnabled').AsBoolean := True;
        Query.ParamByName('BackupHost').AsString := 'wmsnzportal.co.nz/backup';
        Query.ParamByName('BackupPort').AsInteger := iPORT_HTTP_BACKUP_SERVER;
        Query.ParamByName('BackupUsername').AsString := 'backup';
        Query.ParamByName('BackupPassword').AsString := 'Backup01#';

        Query.ParamByName('WindcaveHost').AsString := 'scr.windcave.com';
        Query.ParamByName('WindcavePort').AsInteger := 65;
        Query.ParamByName('WindcaveUsername').AsString := 'admin';
        Query.ParamByName('WindcavePassword').AsString := 'admin';
        Query.ParamByName('WindcaveEndpoint').AsString := 'https://sec.windcave.com/api/v1/transactions';
        Query.ExecSQL;
      except
        on E:Exception do
          //Logger.Write('Error executing SQL statement while creating default config group in UDataMod ' + E.Message);
      end;
    finally
      //Logger.Write('Default config group created');
      Query.Free;
    end;
  end;

var
  SLTables: TStrings;
  Table: TFDTable;
begin
  //Logger.Write('TawhaiAppSupport starting up');
  //Logger.Write('Checking TawhaiAppSupport database tables');

  SLTables := TStringList.Create;
  Table := TFDTable.Create(nil);
  try
    try
      Con.GetTableNames('', '', '', SLTables, [osMy, osOther], [tkTable]); //[tkTable, tkTempTable, tkLocalTable]);
    except
      on E:Exception do
        //SendDebug('Error calling GetTableNames: ' + E.Message);
    end;

    if SLTables.IndexOf('Sites') = -1 then
      CreateSitesTable
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'Sites';
      Table.Open();
      if Table.FindField('SiteName') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE SITES ADD SITENAME VARCHAR(50)');
        //Logger.Write('Added field SiteName to table Sites');
      end;
      if Table.FindField('ConfigGroupIdx') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE SITES ADD CONFIGGROUPIDX BIGINT');
        //Logger.Write('Added field ConfigGroupIdx to table Sites');
      end;

    end;

    if SLTables.IndexOf('Backups') = -1 then
      CreateBackupsTable
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'Backups';
      Table.Open();
      if Table.FindField('IsCurrentBackup') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE BACKUPS ADD ISCURRENTBACKUP BOOLEAN');
        //Logger.Write('Added field IsCurrentBackup to table Backups');
      end;
      Table.Open;
      //From Jason
      if Table.FindField('IsValid') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE BACKUPS ADD ISVALID BOOLEAN');
      end;

      Con.ExecSQL('UPDATE BACKUPS SET ISVALID = FALSE WHERE ISVALID IS NULL');

      try
        Con.ExecSQL('ALTER TABLE BACKUPS ALTER ISVALID SET DEFAULT FALSE');
        Con.ExecSQL('ALTER TABLE BACKUPS ALTER ISVALID SET NOT NULL');
      except
        on E: Exception do
          ; // ignore if already applied
      end;
      Table.Close;
    end;

    //From Jason
    if SLTables.IndexOf('TransactionLocation') = -1 then
      CreateTransactionLocationTable
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'TransactionLocation';
      Table.Open();
    end;

    if SLTables.IndexOf('Computers') = -1 then
      CreateComputersTable
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'Computers';
      Table.Open();
//      if Table.FindField('PublicIP') = nil then
//      begin
//        Table.Close;
//        Con.ExecSQL('ALTER TABLE COMPUTERS ADD PUBLICIP VARCHAR(50)');
//        Logger.Write('Added field PublicIP to table Computers');
//      end;
    end;


    if SLTables.IndexOf('DeviceStatus') = -1 then
      CreateDeviceStatusTable
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'DeviceStatus';
      Table.Open();
      if Table.FindField('LastValue') = nil  then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE DEVICESTATUS ADD LASTVALUE VARCHAR(25)');
        //Logger.Write('Added field LastValue to table DeviceStatus');
      end;
    end;


    if SLTables.IndexOf('ConfigGroups') = -1 then
    begin
      CreateConfigGroupsTable;
      CreateDefaultConfigGroup
    end
    else
    begin
      Table.Connection := Con;
      Table.Close;
      Table.TableName := 'ConfigGroups';
      Table.Open();
      if Table.FindField('WISAPIEndpoint') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD WISAPIENDPOINT VARCHAR(250)');
        //Logger.Write('Added field WISAPIEndpoint to table ConfigGroups');
      end;

      if Table.FindField('WISAPIKey') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD WISAPIKEY VARCHAR(250)');
        //Logger.Write('Added field WISAPIKey to table ConfigGroups');
      end;

      if Table.FindField('ShipModePassword') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD SHIPMODEPASSWORD VARCHAR(250)');
        //Logger.Write('Added field ShipModePassword to table ConfigGroups');
      end;

      if Table.FindField('TareServerEnabled') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD TARESERVERENABLED BOOLEAN');
        //Logger.Write('Added field TareServerEnabled to table ConfigGroups');
      end;

      if Table.FindField('TareServerReadTares') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD TARESERVERREADTARES BOOLEAN');
        //Logger.Write('Added field TareServerReadTares to table ConfigGroups');
      end;

      if Table.FindField('TareServerWriteTares') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD TARESERVERWRITETARES BOOLEAN');
        //Logger.Write('Added field TareServerWriteTares to table ConfigGroups');
      end;

      if Table.FindField('LogrithmEndpoint') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMENDPOINT VARCHAR(250)');
        //Logger.Write('Added field LogrithmEndpoint to table ConfigGroups');
      end;

      if Table.FindField('LogrithmAPIKey') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMAPIKEY VARCHAR(250)');
        //Logger.Write('Added field LogrithmAPIKey to table ConfigGroups');
      end;

      if Table.FindField('LogrithmAddVehicle') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMADDVEHICLE BOOLEAN');
        //Logger.Write('Added field LogrithmAddVehicle to table ConfigGroups');
      end;

      if Table.FindField('LogrithmUpdateTares') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMUPDATETARES BOOLEAN');
        //Logger.Write('Added field LogrithmUpdateTares to table ConfigGroups');
      end;

      if Table.FindField('LogrithmV2Endpoint') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMV2ENDPOINT VARCHAR(250)');
        //Logger.Write('Added field LogrithmV2Endpoint to table ConfigGroups');
      end;

      if Table.FindField('LogrithmV2APIKey') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMV2APIKEY VARCHAR(250)');
        //Logger.Write('Added field LogrithmV2APIKey to table ConfigGroups');
      end;

      if Table.FindField('LogrithmV2CompanyID') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD LOGRITHMV2COMPANYID VARCHAR(50)');
        //Logger.Write('Added field LogrithmV2CompanyID to table ConfigGroups');
      end;

      if Table.FindField('EmailProvider') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD EMAILPROVIDER INTEGER');
        //Logger.Write('Added field EmailProvider to table ConfigGroups');
      end;

      if Table.FindField('SMTPFrom') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD SMTPFROM VARCHAR(50)');
        //Logger.Write('Added field SMTPFrom to table ConfigGroups');
      end;

      if Table.FindField('OauthFrom') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD OAUTHFROM VARCHAR(50)');
        //Logger.Write('Added field OauthFrom to table ConfigGroups');
      end;

      if Table.FindField('OauthClientID') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD OAUTHCLIENTID VARCHAR(250)');
        //Logger.Write('Added field OauthClientID to table ConfigGroups');
      end;

      if Table.FindField('OauthClientSecret') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD OAUTHCLIENTSECRET VARCHAR(250)');
        //Logger.Write('Added field OauthClientSecret to table ConfigGroups');
      end;

      if Table.FindField('OauthHost') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD OAUTHHOST VARCHAR(50)');
        //Logger.Write('Added field OauthHost to table ConfigGroups');
      end;

      if Table.FindField('OauthPort') = nil then
      begin
        Table.Close;
        Con.ExecSQL('ALTER TABLE CONFIGGROUPS ADD OAUTHPORT INTEGER');
        //Logger.Write('Added field OauthPort to table ConfigGroups');
      end;

    end;

  finally
    SLTables.Free;
    Table.Free;
  end;
end;

end.
