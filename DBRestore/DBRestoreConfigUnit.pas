unit DBRestoreConfigUnit;

interface

uses
  System.SysUtils;

type
  TDBRestoreConfig = record
  private
    function GetBackupServerEndpoint: string;
    function GetBackupServerPassword: string;
    function GetBackupServerUsername: string;
    procedure SetBackupServerEndpoint(const Value: string);
    procedure SetBackupServerPassword(const Value: string);
    procedure SetBackupServerUsername(const Value: string);
    function GetDestFolder: string;
    procedure SetDestFolder(const Value: string);
    function GetDestFileName: string;
    procedure SetDestFileName(const Value: string);
  public
    property BackupServerEndpoint: string read GetBackupServerEndpoint write SetBackupServerEndpoint;
    property BackupServerUsername: string read GetBackupServerUsername write SetBackupServerUsername;
    property BackupServerPassword: string read GetBackupServerPassword write SetBackupServerPassword;
    property DestFolder: string read GetDestFolder write SetDestFolder;
    property DestFileName: string read GetDestFileName write SetDestFileName;
  end;

var
  DBRestoreConfig: TDBRestoreConfig;

implementation

{ TDBRestoreConfig }

uses
  TwRegUtils;

function TDBRestoreConfig.GetBackupServerEndpoint: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackServerEndpoint', Result);
  if Result.IsEmpty then
  begin
    //Result := 'https://backup.wmsnzportal.co.nz'; //?getList=Y';
    Result := 'http://localhost:43241';
    SetBackupServerEndpoint(Result);
  end;
end;

function TDBRestoreConfig.GetBackupServerPassword: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackServerPassword', Result);
  if Result.IsEmpty then
  begin
    Result := 'Backup01#';
    SetBackupServerPassword(Result);
  end;
end;

function TDBRestoreConfig.GetBackupServerUsername: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'BackServerUsername', Result);
  if Result.IsEmpty then
  begin
    Result := 'backup';
    SetBackupServerUsername(Result);
  end;
end;

function TDBRestoreConfig.GetDestFileName: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'DestFileName', Result);
  if Result.IsEmpty then
  begin
    Result := 'WBData.fdb';
    SetDestFileName(Result);
  end;
end;

function TDBRestoreConfig.GetDestFolder: string;
begin
  TTwRegUtils.ReadRegKey(TTwRegUtils.AppRegRootKey, 'DestFolder', Result);
  if Result.IsEmpty then
  begin
    Result := 'C:\Projects\WIS\Data';
    SetDestFolder(Result);
  end;
end;

procedure TDBRestoreConfig.SetBackupServerEndpoint(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackServerEndpoint', Value);
end;

procedure TDBRestoreConfig.SetBackupServerPassword(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackServerPassword', Value);
end;

procedure TDBRestoreConfig.SetBackupServerUsername(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'BackServerUsername', Value);
end;

procedure TDBRestoreConfig.SetDestFileName(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'DestFileName', Value);
end;

procedure TDBRestoreConfig.SetDestFolder(const Value: string);
begin
  TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, 'DestFolder', Value);
end;

end.
