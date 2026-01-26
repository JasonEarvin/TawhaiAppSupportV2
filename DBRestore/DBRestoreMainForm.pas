unit DBRestoreMainForm;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Forms, IdHTTP, IdURI, System.JSON,
  Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, Vcl.Dialogs,
  IdAuthentication, IdServerIOHandler, IdSSL, IdSSLOpenSSL, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, System.Generics.Collections, AbUnzper,
  AbBase, AbBrowse, AbZBrows, AbZipper, System.IOUtils, FireDAC.Stan.Def,
  FireDAC.VCLUI.Wait, FireDAC.Phys.IBWrapper, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.IBBase, FireDAC.Phys.IBDef, FireDAC.Phys.IB, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys.FB, FireDAC.Phys.FBDef, Data.DB,
  FireDAC.Comp.Client, Vcl.FileCtrl, Win.Registry, Winapi.Windows, System.UITypes,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, System.IniFiles, Vcl.Menus;

type
  TFormDBRestoreMain = class(TForm)
    HttpClient: TIdHTTP;
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    UnZipper: TAbUnZipper;
    FDIBRestore: TFDIBRestore;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    PnlTop: TPanel;
    BtnDownload: TButton;
    PnlMain: TPanel;
    memoBackupInfo: TMemo;
    SaveDialog1: TSaveDialog;
    FDCon: TFDConnection;
    Qry: TFDQuery;
    MnuMain: TMainMenu;
    MniFile: TMenuItem;
    MniFileSetup: TMenuItem;
    MniFileExit: TMenuItem;
    CmbSiteNames: TComboBox;
    LblDestFile: TLabel;
    LnkReload: TLabel;
    LblSiteNames: TLabel;
    CmbBackups: TComboBox;
    LblBackupVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnDownloadClick(Sender: TObject);
    procedure FDIBRestoreProgress(ASender: TFDPhysDriverService;
      const AMessage: string);
    procedure MniFileExitClick(Sender: TObject);
    procedure MniFileSetupClick(Sender: TObject);
    procedure LnkReloadClick(Sender: TObject);
  private
    procedure Configure;
    procedure LoadBackups;
    procedure LoadBackupsForSite(SiteIdx: Integer);
    procedure CmbSiteNamesChange(Sender: TObject);
    procedure WriteLog(ALogMsg: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDBRestoreMain: TFormDBRestoreMain;

implementation

{$R *.dfm}

uses
  TwUtils,
  DBRestoreConfigUnit,
  DBRestoreConfigForm;

procedure TFormDBRestoreMain.LnkReloadClick(Sender: TObject);
begin
  LoadBackups;
end;

procedure TFormDBRestoreMain.LoadBackups;
var
  Response: TStringStream;
  JsonResponse: TJSONObject;
  JsonArray: TJSONArray;
  i: Integer;
  SiteName: string;
  BackupDateStr: string;
  IndexStr: string;
  SitesIdx: Integer;
begin
  Screen.Cursor := crHourGlass;
  Response := TStringStream.Create;
  try
    try
      HttpClient.Get(DBRestoreConfig.BackupServerEndpoint + '?getList=Y', Response);
      JsonResponse := TJSONObject.ParseJSONValue(Response.DataString) as TJSONObject;

      if Assigned(JsonResponse) then
      begin
        JsonArray := JsonResponse.GetValue('CurrentBackups') as TJSONArray;

        CmbSiteNames.Clear;

        // Populate combo box with received site names
        for i := 0 to JsonArray.Count - 1 do
        begin
          SiteName := JsonArray.Items[i].GetValue<string>('SiteName');
          BackupDateStr := JsonArray.Items[i].GetValue<string>('LastBackup');
          IndexStr := JsonArray.Items[i].GetValue<string>('Index');
          SitesIdx := JsonArray.Items[i].GetValue<Integer>('SitesIdx');
          CmbSiteNames.Items.AddObject(SiteName + ' last backup ' + BackupDateStr, TObject(SitesIdx));
        end;

        WriteLog('Sites loaded successfully.');
      end;
    except
      on E: Exception do
        ShowMessage('Error loading backups: ' + E.Message);
    end;
  finally
    Response.Free;
    Screen.Cursor := crDefault;
  end;
end;

//Jason Work
procedure TFormDBRestoreMain.CmbSiteNamesChange(Sender: TObject);
var
  SiteIdx: Integer;
begin
  if CmbSiteNames.ItemIndex < 0 then Exit;

  SiteIdx := Integer(CmbSiteNames.Items.Objects[CmbSiteNames.ItemIndex]);

  LoadBackupsForSite(SiteIdx);
end;

//Jason Work
procedure TFormDBRestoreMain.LoadBackupsForSite(SiteIdx: Integer);
var
  Response: TStringStream;
  JsonResponse: TJSONObject;
  JsonArray: TJSONArray;
  i: Integer;
  FileName, BackupDateStr: string;
  SiteIdxStr: Integer;
  URL: string;
begin
  Screen.Cursor := crHourGlass;
  Response := TStringStream.Create;
  try
    URL := DBRestoreConfig.BackupServerEndpoint +
       '?getBackupsForSite=Y&SiteIdx=' + IntToStr(SiteIdx);

    HttpClient.Get(URL, Response);
    JsonResponse := TJSONObject.ParseJSONValue(Response.DataString) as TJSONObject;

    //ShowMessage(Response.DataString);

    if Assigned(JsonResponse) then
    begin
      JsonArray := JsonResponse.GetValue('BackupsForSite') as TJSONArray;

      if Assigned(JsonArray) then
      begin
        CmbBackups.Clear;

        for i := 0 to JsonArray.Count - 1 do
        begin
          //FileName := JsonArray.Items[i].GetValue<string>('FileName');
          BackupDateStr := JsonArray.Items[i].GetValue<string>('LastBackup');
          SiteIdxStr  := JsonArray.Items[i].GetValue<Integer>('BackupIdx');

          CmbBackups.Items.AddObject(
            Format('%s', [BackupDateStr]),
            TObject(SiteIdxStr)
          );
        end;

        WriteLog('Backups loaded successfully.');
      end
      else
        ShowMessage('No backups returned for this site.');
    end;

  except
    on E: Exception do
      ShowMessage('Error loading backups: ' + E.Message);
  end;

  Response.Free;
  Screen.Cursor := crDefault;
end;

procedure TFormDBRestoreMain.MniFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormDBRestoreMain.MniFileSetupClick(Sender: TObject);
begin
  FormDBRestoreConfig.ShowModal;
end;

procedure TFormDBRestoreMain.WriteLog(ALogMsg: string);
begin
  MemoBackupInfo.Lines.Add(DateTimeToStr(Now) + ': ' + ALogMsg)
end;

procedure TFormDBRestoreMain.Configure;
begin
  SSLHandler.SSLOptions.Method := sslvTLSv1_2;
  SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  HttpClient.IOHandler := SSLHandler;
  HttpClient.Request.BasicAuthentication := True;
  HttpClient.Request.Username := DBRestoreConfig.BackupServerUsername;
  HttpClient.Request.Password := DBRestoreConfig.BackupServerPassword;
  LblDestFile.Caption := 'Destination file: ' + TPath.Combine(DBRestoreConfig.DestFolder, DBRestoreConfig.DestFileName);
end;

procedure TFormDBRestoreMain.FDIBRestoreProgress(ASender: TFDPhysDriverService; const AMessage: string);
begin
  WriteLog(AMessage);
end;

procedure TFormDBRestoreMain.BtnDownloadClick(Sender: TObject);
var
  SelectedIndex: Integer;
  URL, ExtractedFileName, DestinationFDB, BackupFDB, FolderPath, FileName: string;
  MemoryStream: TMemoryStream;
  i: Integer;
  dlgResult: Integer;
begin
  if CmbSiteNames.ItemIndex = -1 then
  begin
    MessageDlg('Please select the site you wish to restore from first.', mtWarning, [mbOK], 0);
    Exit;
  end;

  FolderPath := DBRestoreConfig.DestFolder;
  if FolderPath.IsEmpty then
  begin
    ShowMessage('Please select a folder.');
    Exit;
  end;

  if not TDirectory.Exists(FolderPath) then
  begin
    ShowMessage('The selected folder does not exist. Please try again.');
    Exit;
  end;

  //Jason Work
  //SelectedIndex := Integer(CmbSiteNames.Items.Objects[CmbSiteNames.ItemIndex]);
  if CmbBackups.ItemIndex = -1 then
  begin
    MessageDlg('Please select a backup version.', mtWarning, [mbOK], 0);
    Exit;
  end;

  FileName := DBRestoreConfig.DestFileName;

  if not FileName.ToLower.EndsWith('.fdb') then
    FileName := FileName + '.fdb';

  DestinationFDB := TPath.Combine(FolderPath, FileName);

  if TFile.Exists(DestinationFDB) then
  begin
    FDCon.Params.Values['Database'] := DestinationFDB;
    Qry.Open('select first 1 SITECODE from SETUP');
    var SiteCode := Qry.FieldByName('SITECODE').AsString;
    Qry.Close;
    FDCon.Close;

//    dlgResult := MessageDlg(
//      'The destination file already exists. Do you wish to rename it as: ' +
//      ChangeFileExt(FileName, '') + '-' + SiteCode + '?',
//      mtConfirmation, [mbYes, mbNo], 0
//    );
//
//    case dlgResult of
//      mrYes:
//        begin
//          try
//            BackupFDB := TPath.Combine(FolderPath, ChangeFileExt(FileName, '') + '-' + SiteCode + '.fdb');
//
//            if TFile.Exists(BackupFDB) then
//              TFile.Delete(BackupFDB);
//
//            TFile.Move(DestinationFDB, BackupFDB);
//            WriteLog('Existing file renamed to: ' + BackupFDB);
//          except
//            on E: Exception do
//            begin
//              ShowMessage('Error renaming the existing file: ' + E.Message);
//              Exit;
//            end;
//          end;
//        end;
//
//      mrNo:
//        begin
//          //TFile.Delete(DestinationFDB);
//          Exit;
//        end;
//    else
//      Exit;
//    end;

    if MessageDlg(
        'The destination file already exists. Do you wish to rename it as: ' +
        ChangeFileExt(FileName, '') + '-' + SiteCode + '?',
        mtConfirmation, [mbYes, mbNo], 0
      ) = mrYes then
   begin
      try
        BackupFDB := TPath.Combine(
          FolderPath,
          ChangeFileExt(FileName, '') + '-' + SiteCode + '.fdb'
        );

        // If renamed file already exists, delete it
        if TFile.Exists(BackupFDB) then
          TFile.Delete(BackupFDB);

        // Rename existing WBData.fdb  WBData-SiteCode.fdb
        TFile.Move(DestinationFDB, BackupFDB);

        // Create a NEW WBData.fdb with the SAME DATA
        TFile.Copy(BackupFDB, DestinationFDB);

        WriteLog('Existing file renamed to: ' + BackupFDB);
        WriteLog('New file created: ' + DestinationFDB);

      except
        on E: Exception do
        begin
          ShowMessage('Error renaming the existing file: ' + E.Message);
          Exit;
        end;
      end;
    end
    else
    begin
      // User chose NO  overwrite existing file
      WriteLog('Existing database will be overwritten.');
    end;

  end;

  SelectedIndex := Integer(CmbBackups.Items.Objects[CmbBackups.ItemIndex]);

  URL := Format(DBRestoreConfig.BackupServerEndpoint + '?getBackup=%d', [SelectedIndex]);

  MemoryStream := TMemoryStream.Create;
  try
    try
      WriteLog('Downloading backup file...');
      HttpClient.Get(URL, MemoryStream);
      WriteLog('Backup downloaded successfully into memory.');
      MemoryStream.Position := 0;


      for i := 0 to UnZipper.Count - 1 do
      begin
        if TPath.GetExtension(UnZipper.Items[i].FileName).ToLower = '.fbk' then
        begin
          ExtractedFileName := TPath.Combine(FolderPath, TPath.GetFileName(UnZipper.Items[i].FileName));
          UnZipper.BaseDirectory := FolderPath;
          UnZipper.ExtractFiles(UnZipper.Items[i].FileName);
          WriteLog('Extracted .fbk file: ' + ExtractedFileName);

          FDIBRestore.DriverLink := FDPhysFBDriverLink1;
          FDIBRestore.BackupFiles.Clear;
          FDIBRestore.BackupFiles.Add(ExtractedFileName);
          FDIBRestore.Database := DestinationFDB;
          FDIBRestore.Protocol := ipLocal;
          FDIBRestore.Host := 'localhost';
          FDIBRestore.Verbose := True;
          FDIBRestore.UserName := 'SYSDBA';
          FDIBRestore.Password := 'masterkey';
          FDIBRestore.OnProgress := FDIBRestoreProgress;

          try
            FDIBRestore.Restore;
            WriteLog('');
            WriteLog('');
            WriteLog('                     Database restored successfully to: ' + DestinationFDB);
          except
            on E: Exception do
              WriteLog('Error restoring database: ' + E.Message);
          end;

          Break;
        end;
      end;

    finally
      MemoryStream.Free;
    end;

  except
    on E: Exception do
      WriteLog('Error downloading or extracting backup: ' + E.Message);
  end;
end;

procedure TFormDBRestoreMain.FormCreate(Sender: TObject);
begin
  MemoBackupInfo.Lines.Clear;
  WriteLog('Loading backups...');
  LoadBackups;
  Configure;

  CmbSiteNames.OnChange := CmbSiteNamesChange;
end;

end.
