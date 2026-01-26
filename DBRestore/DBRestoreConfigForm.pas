unit DBRestoreConfigForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TFormDBRestoreConfig = class(TForm)
    EdtBackServerEndpoint: TEdit;
    EdtBackServerUsername: TEdit;
    EdtBackServerPassword: TEdit;
    PnlBottom: TPanel;
    BtnClose: TBitBtn;
    EdtDestFolder: TEdit;
    BtnBrowse: TButton;
    EdtDestFileName: TEdit;
    LblBackupServerEndpoint: TLabel;
    LblBackupServerUsername: TLabel;
    LblBackupServerPassword: TLabel;
    LblDestFolder: TLabel;
    LblDestFileName: TLabel;
    procedure FormShow(Sender: TObject);
    procedure EdtBackServerEndpointExit(Sender: TObject);
    procedure EdtBackServerUsernameExit(Sender: TObject);
    procedure EdtBackServerPasswordExit(Sender: TObject);
    procedure BtnBrowseClick(Sender: TObject);
    procedure EdtDestFolderExit(Sender: TObject);
    procedure EdtDestFileNameExit(Sender: TObject);
  private
    { Private declarations }
    class function Instance: TFormDBRestoreConfig;
    procedure Initialise;
  public
    { Public declarations }
  end;

function FormDBRestoreConfig: TFormDBRestoreConfig;

implementation

{$R *.dfm}

uses
  TwUtils,
  DBRestoreConfigUnit;

var
  FormDBRestoreConfigInstance: TFormDBRestoreConfig;

function FormDBRestoreConfig: TFormDBRestoreConfig;
begin
  Result := TFormDBRestoreConfig.Instance;
end;

procedure TFormDBRestoreConfig.BtnBrowseClick(Sender: TObject);
var
  FolderName: string;
begin
  FolderName := EdtDestFolder.Text;
//  if BrowseForFolder(FolderName, True, 'Select a folder to save the database') then
//  begin
//    EdtDestFolder.Text := FolderName;
//    EdtDestFolderExit(Sender);
//  end;
end;

procedure TFormDBRestoreConfig.EdtBackServerEndpointExit(Sender: TObject);
begin
  DBRestoreConfig.BackupServerEndpoint := EdtBackServerEndpoint.Text;
end;

procedure TFormDBRestoreConfig.EdtBackServerPasswordExit(Sender: TObject);
begin
  DBRestoreConfig.BackupServerPassword := EdtBackServerPassword.Text;
end;

procedure TFormDBRestoreConfig.EdtBackServerUsernameExit(Sender: TObject);
begin
  DBRestoreConfig.BackupServerUsername := EdtBackServerUsername.Text;
end;

procedure TFormDBRestoreConfig.EdtDestFolderExit(Sender: TObject);
begin
  DBRestoreConfig.DestFolder := EdtDestFolder.Text;
end;

procedure TFormDBRestoreConfig.EdtDestFileNameExit(Sender: TObject);
begin
  DBRestoreConfig.DestFileName := EdtDestFileName.Text;
end;

procedure TFormDBRestoreConfig.FormShow(Sender: TObject);
begin
  Initialise;
end;

procedure TFormDBRestoreConfig.Initialise;
begin
  EdtBackServerEndpoint.Text := DBRestoreConfig.BackupServerEndpoint;
  EdtBackServerUsername.Text := DBRestoreConfig.BackupServerUsername;
  EdtBackServerPassword.Text := DBRestoreConfig.BackupServerPassword;
  EdtDestFolder.Text := DBRestoreConfig.DestFolder;
  EdtDestFileName.Text := DBRestoreConfig.DestFileName;
end;

class function TFormDBRestoreConfig.Instance: TFormDBRestoreConfig;
begin
  if FormDBRestoreConfigInstance = nil then
    FormDBRestoreConfigInstance := TFormDBRestoreConfig.Create(Application);
  Result := FormDBRestoreConfigInstance;
end;

end.
