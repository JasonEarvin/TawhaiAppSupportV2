unit UFormAppSupportMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  TwConstants, System.IOUtils, System.UITypes, Vcl.Buttons, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait, Vcl.DBCtrls,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin, AppSupportServerThreadUnit, UConfigServerThread, UFrameBackup, UFrameConfig,
  UFrameStatus, UFrameTransactionSearch, FireDAC.Phys.IBWrapper, FireDAC.Phys.IBBase;

type
  TFormAppSupportMain = class(TForm)
    ToolBar1: TToolBar;
    ToolButtonPurge: TToolButton;
    PageControlMain: TPageControl;
    TsStatus: TTabSheet;
    TsBackup: TTabSheet;
    TsConfig: TTabSheet;
    ToolButtonSetup: TToolButton;
    ToolButtonTerminate: TToolButton;
    ToolButtonSeperator: TToolButton;
    ApplicationEvents1: TApplicationEvents;
    TrayIcon: TTrayIcon;
    MnuPopup: TPopupMenu;
    MniShow: TMenuItem;
    MniTerminate: TMenuItem;
    ImgListMenu: TImageList;
    btnLog: TToolButton;
    pmPopup: TPopupMenu;
    PmLogFile: TMenuItem;
    PmLogFolder: TMenuItem;
    FDIBRestore1: TFDIBRestore;
    TsTransactionSearch: TTabSheet;
    procedure ToolButtonSetupClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonPurgeClick(Sender: TObject);
    procedure ToolButtonTerminateClick(Sender: TObject);
    procedure MniShowClick(Sender: TObject);
    procedure MniTerminateClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PageControlMainChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PmLogFileClick(Sender: TObject);
    procedure PmLogFolderClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
  private
    AppSupportServerThread: TAppSupportServerThread;
    ConfigServerThread: TConfigServerThread;
    ForceClose: Boolean;
    FrameConfig: TFrameConfig;
    FrameBackup: TFrameBackup;
    FrameStatus: TFrameStatus;
    FrameTransactionSearch: TFrameTransactionSearch;
    procedure RestoreApp;
    procedure WriteLog(AMsg: string);
    procedure ThemeChange();
  public
    { Public declarations }
  end;

var
  FormAppSupportMain: TFormAppSupportMain;

implementation

uses
  WindowsDarkMode,
  UDataMod,
  UAppSupportConfig,
  UFormAppSupportConfig,
  TwUtils;
//  TwConnection,
//  TwSystemUtils,
//  TwStringUtils,
//  LoggerUnit;

{$R *.dfm}

procedure TFormAppSupportMain.ThemeChange;
begin
if AppSupportSettings.Theme = 'Auto' then
  begin
    //SetAppropriateThemeMode('Windows11 Modern Dark', 'Windows11 Modern Light');
  end
  else
  begin
    //SetSpecificThemeMode(StrToBool(ConfigServerConfig.Theme), 'Windows11 Modern Dark', 'Windows11 Modern Light');
//    rbAuto.Checked := false;
//    rbLight.Checked := not FormBool;
//    rbDark.Checked := FormBool;
  end;
end;

procedure TFormAppSupportMain.WriteLog(AMsg: string);
begin
  AMsg := DateTimeToStr(Now) + ': ' + AMsg;
  //Logger.Write(AMsg);
end;

procedure TFormAppSupportMain.ApplicationEvents1Minimize(Sender: TObject);
begin
  Hide();
  WindowState := wsMinimized;
  TrayIcon.Visible := True;
end;

procedure TFormAppSupportMain.btnLogClick(Sender: TObject);
begin
  //TTwSystemUtils.ExecuteFile(//Logger.FileName);
end;

procedure TFormAppSupportMain.FormActivate(Sender: TObject);
begin
  //FrameBackup1.FrameEnter(sender);
end;

procedure TFormAppSupportMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ForceClose;
  if not CanClose then
    Application.Minimize;
end;

procedure TFormAppSupportMain.FormCreate(Sender: TObject);
begin
//  Caption := 'Tawhai app support V' + TTwSystemUtils.GetFileVersion;
//  WriteLog('AppSupport Server Ver: ' + TTwSystemUtils.GetFileVersion);
  ThemeChange;

  AppSupportServerThread := TAppSupportServerThread.Create;
  FrameBackup := TFrameBackup.Create(Self);
  FrameBackup.Parent := TsBackup;
  AppSupportServerThread.MsgHandle := FrameBackup.Handle;
  FrameBackup.Align := TAlign.alClient;

  ConfigServerThread := TConfigServerThread.Create;
  FrameConfig := TFrameConfig.Create(Self);
  FrameConfig.Parent := TsConfig;
  ConfigServerThread.MsgHandle := FrameConfig.Handle;
  FrameConfig.Align := TAlign.alClient;

  FrameStatus := TFrameStatus.Create(Self);
  FrameStatus.Parent := TsStatus;
  FrameStatus.Align := TAlign.alClient;

  FrameTransactionSearch := TFrameTransactionSearch.Create(Self);
  FrameTransactionSearch.Parent := TsTransactionSearch;
  FrameTransactionSearch.Align := TAlign.alClient;

  PageControlMain.ActivePage := TsStatus;
end;

procedure TFormAppSupportMain.FormShow(Sender: TObject);
begin
  PageControlMainChange(Sender);
end;

procedure TFormAppSupportMain.MniShowClick(Sender: TObject);
begin
  RestoreApp;
end;

procedure TFormAppSupportMain.MniTerminateClick(Sender: TObject);
begin
    ToolButtonTerminateClick(Sender);
end;

procedure TFormAppSupportMain.PageControlMainChange(Sender: TObject);
begin
  if PageControlMain.ActivePage = TsBackup then
  begin
    FrameBackup.Initialise;
  end
  else
  if PageControlMain.ActivePage = TsStatus then
  begin
    FrameStatus.Initialise;
  end
  else
  if PageControlMain.ActivePage = TsConfig then
  begin
    FrameConfig.Initialise;
  end
  else
  if PageControlMain.ActivePage = TsTransactionSearch then
  begin
    FrameTransactionSearch.Initialise;
  end;
end;

procedure TFormAppSupportMain.PmLogFileClick(Sender: TObject);
begin
  //TTwSystemUtils.ExecuteFile(//Logger.FileName);
end;

procedure TFormAppSupportMain.PmLogFolderClick(Sender: TObject);
begin
  //TTwSystemUtils.ExecuteFile(//Logger.LogFolder);
end;

procedure TFormAppSupportMain.ToolButtonPurgeClick(Sender: TObject);
begin
  AppSupportServerThread.PurgeBackups;
end;

procedure TFormAppSupportMain.ToolButtonSetupClick(Sender: TObject);
begin
  FormAppSupportConfig.ShowModal;

end;

procedure TFormAppSupportMain.ToolButtonTerminateClick(Sender: TObject);
  begin
    if MessageDlg('Are you really sure you want to stop the AppSupport server?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      ForceClose := True;
      Close;
    end;
  end;
procedure TFormAppSupportMain.TrayIconDblClick(Sender: TObject);
begin
  RestoreApp;
end;

procedure TFormAppSupportMain.RestoreApp;
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

end.


(*
    try
      FDPhysFBDriverLink.VendorLib := 'fbclient.dll';
      FDIBRestore.DriverLink := FDPhysFBDriverLink;

      FDIBRestore.UserName := DataMod.Connection.UserName;
      FDIBRestore.Password := DataMod.Connection.Password;
      FDIBRestore.Host := 'localhost';
      FDIBRestore.Protocol := ipTCPIP;

      DatabaseName := DataMod.Connection.DatabaseName;
      if ContainsText(DatabaseName, 'localhost:') then
        TTwStringUtils.StrToken(DatabaseName, ':');
      FDIBRestore.Database := DatabaseName;
      FDIBRestore.BackupFiles.Add(TempBackupFileName);
      FDIBRestore.Options := [roReplace];
      FDIBRestore.Verbose := True;
      //FDIBRestore.OnProgress := FDIBRestoreProgress;
      FDIBRestore.Restore;

      Msg := 'Current database overwritten from backup file ' + dlgBackup.FileName;
      TTwRegUtils.WriteRegKey(TTwRegUtils.AppRegRootKey, sDATABASERESTOREDMESSAGE, Msg);
      Msg := Msg + '. ' + StripFileExt(ExtractFileName(Application.ExeName)) + ' will now be restarted...';
      MessageDlg(Msg, mtInformation, [mbOK], 0);
    except
      on E:Exception do
      begin
        Msg := 'Error occurred during database restore: ' + E.Message;
        MessageDlg(Msg, mtWarning, [mbOK], 0);
      end;
    end;
*)
