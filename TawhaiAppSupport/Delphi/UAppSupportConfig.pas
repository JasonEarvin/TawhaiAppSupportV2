unit UAppSupportConfig;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Script,
  FireDAC.Stan.Error,
  FireDAC.Comp.Client,
  //TwFDQuery,
  vcl.Forms;

type
  TAppSupportSettings = class sealed (TObject)
  strict private
    class var FInstance: TAppSupportSettings;
  private
    Query: TFDQuery;
    Connection: TFDConnection;
    class function Instance: TAppSupportSettings;

    constructor Create;

    function GetTheme : string;
    procedure SetTheme(const Value: string);

    function GetRootFolder: string;
    function GetTawhaiAppSupportDBName: string;
    function GetBackupPassword: string;
    function GetBackupUserName: string;
    function GetBackupEnabled: Boolean;
    function GetConfigEnabled: Boolean;
    function GetStatusReportEnabled: Boolean;
    function GetStatusReportEmailAddr: string;

    procedure SetBackupEnabled(const Value: Boolean);
    procedure SetConfigEnabled(const Value: Boolean);
    procedure SetRootFolder(const Value: string);
    procedure SetTawhaiAppSupportDBName(const Value: string);
    procedure SetBackupPassword(const Value: string);
    procedure SetBackupUserName(const Value: string);
    procedure SetStatusReportEnabled(const Value: Boolean);
    procedure SetStatusReportEmailAddr(const Value: string);


  public
    property Theme : string read GetTheme write SetTheme;
    property TawhaiAppSupportDBName: string read GetTawhaiAppSupportDBName write SetTawhaiAppSupportDBName;
    property BackupEnabled: Boolean read GetBackupEnabled write SetBackupEnabled;
    property ConfigEnabled: Boolean read GetConfigEnabled write SetConfigEnabled;
    property BackupUserName: string read GetBackupUserName write SetBackupUserName;
    property BackupPassword: string read GetBackupPassword write SetBackupPassword;
    property RootFolder: string read GetRootFolder write SetRootFolder;
    property StatusReportEnabled: Boolean read GetStatusReportEnabled write SetStatusReportEnabled;
    property StatusReportEmailAddr: string read GetStatusReportEmailAddr write SetStatusReportEmailAddr;
    class procedure ReleaseInstance;
  published
  end;

function AppSupportSettings: TAppSupportSettings;

implementation

uses
//  LoggerUnit,
//  DbugIntf;
//  TwConnection,
//  TwSystemUtils,
//  TwConstants,
  TwRegUtils;

function AppSupportSettings: TAppSupportSettings;
begin
  Result := TAppSupportSettings.Instance;
end;

function TAppSupportSettings.GetTheme: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'Theme', Result);
  if Result.IsEmpty then
    Result := 'Auto';
end;

function TAppSupportSettings.GetBackupUsername: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackupUsername', Result);
end;

function TAppSupportSettings.GetBackupPassword: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackupPassword', Result);
end;

function TAppSupportSettings.GetConfigEnabled: Boolean;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'ConfigEnabled', Result);
end;

function TAppSupportSettings.GetBackupEnabled: Boolean;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackupEnabled', Result);
end;

function TAppSupportSettings.GetRootFolder: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'RootFolder', Result);
end;

function TAppSupportSettings.GetTawhaiAppSupportDBName: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'TawhaiAppServerDBName', Result);
end;

//From Jason
function TAppSupportSettings.GetStatusReportEnabled: Boolean;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'StatusReportEnabled', Result);
end;

function TAppSupportSettings.GetStatusReportEmailAddr: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'StatusReportEmailAddr', Result);
end;

class function TAppSupportSettings.Instance: TAppSupportSettings;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAppSupportSettings.Create;
  end;
  Result := FInstance;
end;

class procedure TAppSupportSettings.ReleaseInstance;
begin
  AppSupportSettings.Free;
end;

constructor TAppSupportSettings.Create;
var
  DBName: string;
begin
//  Connection := TFDConnection.Create(nil);
//  Query := TTwFDQuery.Create(nil);
//  try
//    TTwConnection.ConfigureTFDConnection(Connection, AppSupportSettings.TawhaiAppSupportDBName);
//    Query.SQLConnection := Connection;
//  except
//    on E:Exception do
//      Logger.Write('Error in TAppSupportSettings.Create, '+E.Message);
//  end;
end;


procedure TAppSupportSettings.SetTheme(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'Theme', Value);
end;

procedure TAppSupportSettings.SetRootFolder(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'RootFolder', Value);
end;

procedure TAppSupportSettings.SetTawhaiAppSupportDBName(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'TawhaiAppServerDBName', Value);
end;

procedure TAppSupportSettings.SetBackupEnabled(const Value: Boolean);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackupEnabled', Value);
end;

procedure TAppSupportSettings.SetConfigEnabled(const Value: Boolean);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'ConfigEnabled', Value);
end;

procedure TAppSupportSettings.SetBackupPassword(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackupPassword', Value);
end;

procedure TAppSupportSettings.SetBackupUsername(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackupUsername', Value);
end;

//From Jason
procedure TAppSupportSettings.SetStatusReportEnabled(const Value: Boolean);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'StatusReportEnabled', Value);
end;

procedure TAppSupportSettings.SetStatusReportEmailAddr(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'StatusReportEmailAddr', Value);
end;

initialization

finalization
  TAppSupportSettings.ReleaseInstance;

end.
