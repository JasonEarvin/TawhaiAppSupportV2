unit UFormAppSupportConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.DBCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Mask, Vcl.Samples.Spin;

type
  TFormAppSupportConfig = class(TForm)
    PnlBottom: TPanel;
    BtnFormClose: TBitBtn;
    PnlMid: TPanel;
    PgcConfig: TPageControl;
    TbsNavman: TTabSheet;
    TbsEmail: TTabSheet;
    TbsSMS: TTabSheet;
    TbsTicket: TTabSheet;
    LblTicketServerEndpoint: TLabel;
    EdtTicketServerEndpoint: TEdit;
    TbsBackup: TTabSheet;
    GrpBackup: TGroupBox;
    LblBackupPassword: TLabel;
    ChkBackupHTTPEnabled: TCheckBox;
    EdtBackupHost: TEdit;
    EdtBackupPort: TEdit;
    EdtBackupUsername: TEdit;
    BtnShowBackupPass: TButton;
    EdtBackupPassword: TEdit;
    PnlTop: TPanel;
    LblConfig: TLabel;
    LblGeneral: TLabel;
    ChkStartWithWindows: TCheckBox;
    GrpDatabase: TGroupBox;
    EdtDBName: TEdit;
    grpNavman: TGroupBox;
    LblNavmanAPIKey: TLabel;
    LblNavmanEndpoint: TLabel;
    LblNavmanClientCode: TLabel;
    EdtNavmanAPIKey: TEdit;
    EdtNavmanEndpoint: TEdit;
    EdtNavmanClientCode: TEdit;
    ChkNavmanSplitMsg: TCheckBox;
    DlgKeyFile: TFileOpenDialog;
    LnkPrivateFolder: TLabel;
    BtnBackupRootFolder: TButton;
    GrpHTTP: TGroupBox;
    EdtAppSupportUserame: TEdit;
    EdtAppSupportPassword: TEdit;
    EdtBackupRootFolder: TEdit;
    ChkConfigEnabled: TCheckBox;
    ChkAppSupportEnabled: TCheckBox;
    grpSiteGrps: TGroupBox;
    TbsWIS: TTabSheet;
    LblWISAPIKey: TLabel;
    EdtWebsiteHomePage: TEdit;
    TbsWindcave: TTabSheet;
    GrpWindcave: TGroupBox;
    Label1: TLabel;
    lblWindcavePort: TLabel;
    lblWindcaveUsername: TLabel;
    lblWindcavePassword: TLabel;
    edtWindcaveEndpoint: TEdit;
    edtWindcavePort: TEdit;
    edtWindcaveURL: TEdit;
    btnShowWindcavePassword: TButton;
    edtWindcavePassword: TEdit;
    edtWindcaveUsername: TEdit;
    lblWindcaveURL: TLabel;
    lblWindcaveEndpoint: TLabel;
    GrpSMS: TGroupBox;
    LblSMSAddress: TLabel;
    LblSMSUsername: TLabel;
    LblSMSPassword: TLabel;
    LblSMSModem: TLabel;
    EdtSMSServerEndpoint: TEdit;
    BtnShowSMSPass: TButton;
    CmbSMSModem: TComboBox;
    EdtSMSPassword: TEdit;
    EdtSMSUsername: TEdit;
    EdtWISAPIKey: TEdit;
    LblWebsiteHomepage: TLabel;
    btnAddGrp: TButton;
    btnRemoveGrp: TButton;
    CmbConfigGroups: TComboBox;
    TbsDriverMode: TTabSheet;
    TbsReports: TTabSheet;
    grpReports: TGroupBox;
    LblReportLine2: TLabel;
    lblReportLine1: TLabel;
    LblReportLine3: TLabel;
    edtReportLine2: TEdit;
    edtReportLine1: TEdit;
    edtReportLine3: TEdit;
    LblStartButtonText: TLabel;
    EdtStartButtonText: TEdit;
    TbsShipMode: TTabSheet;
    EdtShipModeEmail: TEdit;
    LblShipModePassword: TLabel;
    edtShipModePassword: TEdit;
    btnShipModeShowPassword: TButton;
    lblShipModeEmail: TLabel;
    LblWISAPIEndpoint: TLabel;
    EdtWISAPIEndpoint: TEdit;
    LblWISGatewayEndpoint: TLabel;
    EdtWISGatewayEndpoint: TEdit;
    edtTicketLogoPath: TEdit;
    btnTicketLogoPathOpen: TButton;
    lblTicketLogoPath: TLabel;
    lblTicketContent: TLabel;
    TbsLogrithm: TTabSheet;
    grpWISWebsite: TGroupBox;
    grpWISAPI: TGroupBox;
    grpTareServer: TGroupBox;
    grpLogrithm: TGroupBox;
    EdtLogrithmEndpoint: TEdit;
    EdtLogrithmAPIKey: TEdit;
    ChkLogrithmAddVehicle: TCheckBox;
    ChkLogrithmUpdateTares: TCheckBox;
    ChkTareServerEnabled: TCheckBox;
    ChkTareServerReadTares: TCheckBox;
    ChkTareServerWriteTares: TCheckBox;
    pgcEmail: TPageControl;
    TbsSMTP: TTabSheet;
    GrpSMTP: TGroupBox;
    LblSMTPHost: TLabel;
    LblSMTPPort: TLabel;
    LblSMTPUsername: TLabel;
    LblSMTPPassword: TLabel;
    LblSMTPSSLTLS: TLabel;
    EdtSMTPPort: TEdit;
    EdtSMTPHost: TEdit;
    BtnShowSMTPPass: TButton;
    ChkCopyToSelf: TCheckBox;
    ChkSMTPAuth: TCheckBox;
    CmbTLS: TComboBox;
    EdtSMTPPassword: TEdit;
    EdtSMTPUsername: TEdit;
    TbsOauth: TTabSheet;
    AdvCmbEmail: TComboBox;
    EdtOauthClientID: TEdit;
    EdtOauthClientSecret: TEdit;
    EdtOauthHost: TEdit;
    AdvSpinEdtOauthPort: TSpinEdit;
    EdtOauthFrom: TEdit;
    EdtSMTPFrom: TEdit;
    LblSMTPFrom: TLabel;
    grpLogrithmV2: TGroupBox;
    EdtLogrithmV2Endpoint: TEdit;
    EdtLogrithmV2APIKey: TEdit;
    EdtLogrithmV2CompanyID: TEdit;
    Query: TFDQuery;
    ChkStatusReport: TCheckBox;
    StatusReportEmailAddr: TEdit;
    GrpEmailAlert: TGroupBox;
    procedure ChkStartWithWindowsClick(Sender: TObject);
    procedure LnkPrivateFolderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnBackupRootFolderClick(Sender: TObject);
    procedure EdtAppSupportUserameExit(Sender: TObject);
    procedure EdtAppSupportPasswordExit(Sender: TObject);
    procedure EdtBackupRootFolderExit(Sender: TObject);
    procedure EdtSMSServerEndpointExit(Sender: TObject);
    procedure EdtTicketServerEndpointExit(Sender: TObject);
    procedure EdtNavmanEndpointExit(Sender: TObject);
    procedure EdtNavmanAPIKeyExit(Sender: TObject);
    procedure EdtNavmanClientCodeExit(Sender: TObject);
    procedure ChkNavmanSplitMsgClick(Sender: TObject);
    procedure EdtSMTPHostExit(Sender: TObject);
    procedure EdtSMTPPortExit(Sender: TObject);
    procedure EdtSMTPUsernameExit(Sender: TObject);
    procedure EdtSMTPPasswordExit(Sender: TObject);
    procedure BtnShowSMTPPassClick(Sender: TObject);
    procedure CmbTLSExit(Sender: TObject);
    procedure ChkCopyToSelfClick(Sender: TObject);
    procedure ChkSMTPAuthClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ChkConfigEnabledClick(Sender: TObject);
    procedure ChkAppSupportEnabledClick(Sender: TObject);
    procedure ChkBackupHTTPEnabledClick(Sender: TObject);
    procedure EdtBackupHostExit(Sender: TObject);
    procedure EdtBackupPortExit(Sender: TObject);
    procedure EdtBackupUsernameExit(Sender: TObject);
    procedure EdtBackupPasswordExit(Sender: TObject);
    procedure BtnShowBackupPassClick(Sender: TObject);
    procedure EdtWebsiteHomePageExit(Sender: TObject);
    procedure BtnShowSMSPassClick(Sender: TObject);
    procedure EdtSMSUsernameExit(Sender: TObject);
    procedure EdtWISAPIKeyExit(Sender: TObject);
    procedure btnAddGrpClick(Sender: TObject);
    procedure btnRemoveGrpClick(Sender: TObject);
    procedure btnShowWindcavePasswordClick(Sender: TObject);
    procedure edtWindcaveURLExit(Sender: TObject);
    procedure edtWindcavePortExit(Sender: TObject);
    procedure edtWindcaveUsernameExit(Sender: TObject);
    procedure edtWindcavePasswordExit(Sender: TObject);
    procedure edtWindcaveEndpointExit(Sender: TObject);
    procedure EdtSMSPasswordExit(Sender: TObject);
    procedure CmbSMSModemExit(Sender: TObject);
    procedure CmbConfigGroupsChange(Sender: TObject);
    procedure EdtStartButtonTextExit(Sender: TObject);
    procedure edtReportLine1Exit(Sender: TObject);
    procedure edtReportLine2Exit(Sender: TObject);
    procedure edtReportLine3Exit(Sender: TObject);
    procedure EdtShipModeEmailExit(Sender: TObject);
    procedure btnShipModeShowPasswordClick(Sender: TObject);
    procedure edtShipModePasswordExit(Sender: TObject);
    procedure EdtWISAPIEndpointExit(Sender: TObject);
    procedure EdtWISGatewayEndpointExit(Sender: TObject);
    procedure btnTicketLogoPathOpenClick(Sender: TObject);
    procedure EdtLogrithmEndpointExit(Sender: TObject);
    procedure EdtLogrithmAPIKeyExit(Sender: TObject);
    procedure ChkLogrithmAddVehicleClick(Sender: TObject);
    procedure ChkLogrithmUpdateTaresClick(Sender: TObject);
    procedure ChkTareServerEnabledClick(Sender: TObject);
    procedure ChkTareServerReadTaresClick(Sender: TObject);
    procedure ChkTareServerWriteTaresClick(Sender: TObject);
    procedure EdtOauthClientIDExit(Sender: TObject);
    procedure EdtOauthClientSecretExit(Sender: TObject);
    procedure EdtOauthHostExit(Sender: TObject);
    procedure AdvSpinEdtOauthPortExit(Sender: TObject);
    procedure EdtOauthFromExit(Sender: TObject);
    procedure AdvCmbEmailChange(Sender: TObject);
    procedure EdtSMTPFromExit(Sender: TObject);
    procedure EdtLogrithmV2EndpointExit(Sender: TObject);
    procedure EdtLogrithmV2APIKeyExit(Sender: TObject);
    procedure EdtLogrithmV2CompanyIDExit(Sender: TObject);
    procedure ChkStatusReportEnabledClick(Sender: TObject);
    //procedure LblEmailAddrClick(Sender: TObject);
  private
    procedure Initialise;
    procedure LoadConfigGroupItems;
    procedure writePropertyChange(ChangedField : string; setValue : Variant);
  public
    { Public declarations }
  end;

var
  FormAppSupportConfig: TFormAppSupportConfig;

implementation

uses
  TwConstants,
  TwUtils,
  //TwSystemUtils,
  UAppSupportConfig,
  //LoggerUnit,
  //CommonEnumTypesUnit,
  //Email,
  //EmailTypesUnit,
  UDataMod;

{$R *.dfm}

procedure TFormAppSupportConfig.AdvCmbEmailChange(Sender: TObject);
begin
  writePropertyChange('EmailProvider', Integer(AdvCmbEmail.Items.Objects[AdvCmbEmail.ItemIndex]));
end;

procedure TFormAppSupportConfig.AdvSpinEdtOauthPortExit(Sender: TObject);
begin
  writePropertyChange('OauthPort', AdvSpinEdtOauthPort.Value);
end;

procedure TFormAppSupportConfig.btnAddGrpClick(Sender: TObject);
var
  InputString: string;
begin
  try
//    Query := TTwFDQuery.Create(nil);
    if InputQuery('New Config Group', 'Group Name:', InputString) then
      begin
        Query.Open('select ConfigGroup from ConfigGroups where ConfigGroup = :ConfigGroup', [Inputstring]);
        if Query.FieldByName('ConfigGroup').IsNull then
        begin
          try
            Query.SQL.Text := 'insert into ConfigGroups (ConfigGroup) ' +
            'values (:ConfigGroup)';
            Query.ParamByName('ConfigGroup').AsString := InputString;
            Query.ExecSQL;
          except
            on E:Exception do
              //Logger.Write('Error in TFormAppSupportConfig.btnAddGrpClick ' + E.Message);
          end;
          //Logger.Write('Created new config group: ' + InputString);
        end
        else
          ShowMessage('This Config Group already exists');
      end;
  finally
    LoadConfigGroupItems;
  end;
end;

procedure TFormAppSupportConfig.BtnBackupRootFolderClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := EdtBackupRootFolder.Text;
//  if BrowseForFolder(Folder) then
//  begin
//    AppSupportSettings.RootFolder := Folder;
//    EdtBackupRootFolder.Text := Folder;
//  end;
end;

procedure TFormAppSupportConfig.btnRemoveGrpClick(Sender: TObject);
begin
  try
    if MessageDlg('Are you sure you want to delete the ' + CmbConfigGroups.Text + ' config group?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    Query.Connection := DataMod.Con;
    try
      Query.ExecSQL('delete from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [Integer(CmbConfigGroups.Items.Objects[CmbConfigGroups.ItemIndex])]);
    except
      on E:Exception do
          //Logger.Write('Error in TFormAppSupportConfig.btnRemoveGrpClick ' + E.Message);
    end;
  end;
  finally
    LoadConfigGroupItems;
  end;

end;

procedure TFormAppSupportConfig.btnShipModeShowPasswordClick(Sender: TObject);
begin
  if (edtShipModePassword.PasswordChar = '*') and (edtShipModePassword.Text <> '') then
  begin
    btnShipModeShowPassword.Caption := 'Hide';
    edtShipModePassword.PasswordChar := #0
  end
  else
  begin
    btnShipModeShowPassword.Caption := 'Show';
    edtShipModePassword.PasswordChar := '*';
  end;
end;

procedure TFormAppSupportConfig.BtnShowBackupPassClick(Sender: TObject);
begin
  if (EdtBackupPassword.PasswordChar = '*') and (EdtBackupPassword.Text <> '') then
  begin
    BtnShowBackupPass.Caption := 'Hide';
    EdtBackupPassword.PasswordChar := #0
  end
  else
  begin
    BtnShowBackupPass.Caption := 'Show';
    EdtBackupPassword.PasswordChar := '*';
  end;
end;

procedure TFormAppSupportConfig.BtnShowSMSPassClick(Sender: TObject);
begin
  if (EdtSMSPassword.PasswordChar = '*') and (EdtSMSPassword.Text <> '') then
  begin
    BtnShowSMSPass.Caption := 'Hide';
    EdtSMSPassword.PasswordChar := #0
  end
  else
  begin
    BtnShowSMSPass.Caption := 'Show';
    EdtSMSPassword.PasswordChar := '*';
  end;
end;

procedure TFormAppSupportConfig.BtnShowSMTPPassClick(Sender: TObject);
begin
  if (EdtSMTPPassword.PasswordChar = '*') and (EdtSMTPPassword.Text <> '') then
  begin
    BtnShowSMTPPass.Caption := 'Hide';
    EdtSMTPPassword.PasswordChar := #0
  end
  else
  begin
    BtnShowSMTPPass.Caption := 'Show';
    EdtSMTPPassword.PasswordChar := '*';
  end;
end;

procedure TFormAppSupportConfig.btnShowWindcavePasswordClick(Sender: TObject);
begin
  if (edtWindcavePassword.PasswordChar = '*') and (edtWindcavePassword.Text <> '') then
  begin
    btnShowWindcavePassword.Caption := 'Hide';
    edtWindcavePassword.PasswordChar := #0
  end
  else
  begin
    btnShowWindcavePassword.Caption := 'Show';
    edtWindcavePassword.PasswordChar := '*';
  end;
end;

procedure TFormAppSupportConfig.btnTicketLogoPathOpenClick(Sender: TObject);
var
  Folder: string;
begin
  Folder := edtTicketLogoPath.Text;
//  if BrowseForFolder(Folder) then
//  begin
//    edtTicketLogoPath.Text := Folder;
//    writePropertyChange('TicketLogoPath', edtTicketLogoPath.Text);
//  end;
end;

procedure TFormAppSupportConfig.ChkAppSupportEnabledClick(Sender: TObject);
begin
  AppSupportSettings.BackupEnabled := ChkAppSupportEnabled.Checked;
end;

//From Jason
procedure TFormAppSupportConfig.ChkStatusReportEnabledClick(Sender: TObject);
begin
  AppSupportSettings.StatusReportEnabled := ChkStatusReport.Checked;
end;

procedure TFormAppSupportConfig.ChkBackupHTTPEnabledClick(Sender: TObject);
begin
  writePropertyChange('BackupEnabled', ChkBackupHTTPEnabled.Checked);
end;

procedure TFormAppSupportConfig.ChkConfigEnabledClick(Sender: TObject);
begin
  AppSupportSettings.ConfigEnabled := ChkConfigEnabled.Checked;
end;

procedure TFormAppSupportConfig.ChkCopyToSelfClick(Sender: TObject);
begin
  writePropertyChange('SMTPSendCopy', ChkCopyToSelf.Checked);
end;

procedure TFormAppSupportConfig.ChkLogrithmAddVehicleClick(Sender: TObject);
begin
  writePropertyChange('LogrithmAddVehicle', ChkLogrithmAddVehicle.Checked);
end;

procedure TFormAppSupportConfig.ChkLogrithmUpdateTaresClick(Sender: TObject);
begin
  writePropertyChange('LogrithmUpdateTares', ChkLogrithmUpdateTares.Checked);
end;

procedure TFormAppSupportConfig.ChkNavmanSplitMsgClick(Sender: TObject);
begin
//  ConfigServerConfig.NavmanSplitMsg := ChkNavmanSplitMsg.Checked;
end;

procedure TFormAppSupportConfig.ChkSMTPAuthClick(Sender: TObject);
begin
  writePropertyChange('SMTPAuth', ChkSMTPAuth.Checked);
end;

procedure TFormAppSupportConfig.ChkStartWithWindowsClick(Sender: TObject);
begin
  //TTwSystemUtils.StartWithWindows := ChkStartWithWindows.Checked;
end;

procedure TFormAppSupportConfig.ChkTareServerEnabledClick(Sender: TObject);
begin
  writePropertyChange('TareServerEnabled', ChkTareServerEnabled.Checked);
end;

procedure TFormAppSupportConfig.ChkTareServerReadTaresClick(Sender: TObject);
begin
  writePropertyChange('TareServerReadTares', ChkTareServerReadTares.Checked);
end;

procedure TFormAppSupportConfig.ChkTareServerWriteTaresClick(Sender: TObject);
begin
  writePropertyChange('TareServerWriteTares', ChkTareServerWriteTares.Checked);
end;

procedure TFormAppSupportConfig.CmbConfigGroupsChange(Sender: TObject);
var
  I: Integer;
  J: Integer;
  K: Integer;
begin
  try
    try
    Query.Open('select * from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [Integer(CmbConfigGroups.Items.Objects[CmbConfigGroups.ItemIndex])]); //CmbSiteGrps.ItemIndex

    EdtWebsiteHomePage.Text := Query.FieldByName('WebsiteHomePage').AsString;
    EdtWISGatewayEndpoint.Text := Query.FieldByName('WISGatewayServiceEndpoint').AsString;
    EdtWISAPIEndpoint.Text := Query.FieldByName('WISAPIEndpoint').AsString;
    EdtWISAPIKey.Text := Query.FieldByName('WISAPIKey').AsString;

    EdtLogrithmEndpoint.Text := Query.FieldByName('LogrithmEndpoint').AsString;
    EdtLogrithmAPIKey.Text := Query.FieldByName('LogrithmAPIKey').AsString;

    EdtLogrithmV2Endpoint.Text := Query.FieldByName('LogrithmV2Endpoint').AsString;
    EdtLogrithmV2APIKey.Text := Query.FieldByName('LogrithmV2APIKey').AsString;
    EdtLogrithmV2CompanyID.Text := Query.FieldByName('LogrithmV2CompanyID').AsString;

    EdtNavmanEndpoint.Text := Query.FieldByName('NavmanEndpoint').AsString;
    EdtNavmanAPIKey.Text := Query.FieldByName('NavmanAPIKey').AsString;
    EdtNavmanClientCode.Text := Query.FieldByName('NavmanClientCode').AsString;
//    ChkNavmanSplitMsg.Checked := ConfigServerConfig.NavmanSplitMsg;

    EdtSMTPHost.Text := Query.FieldByName('SMTPHost').AsString;
    EdtSMTPPort.Text := Query.FieldByName('SMTPPort').AsString;
    EdtSMTPUsername.Text := Query.FieldByName('SMTPUsername').AsString;
    EdtSMTPPassword.Text := Query.FieldByName('SMTPPassword').AsString;
    EdtSMTPFrom.Text := Query.FieldByName('SMTPFrom').AsString;

    EdtOauthClientID.Text := Query.FieldByName('OauthClientID').AsString;
    EdtOauthClientSecret.Text := Query.FieldByName('OauthClientSecret').AsString;
    EdtOauthHost.Text := Query.FieldByName('OauthHost').AsString;
    AdvSpinEdtOauthPort.Value := Query.FieldByName('OauthPort').AsInteger;
    EdtOauthFrom.Text := Query.FieldByName('OauthFrom').AsString;


    ChkSMTPAuth.OnClick := nil;
    ChkCopyToSelf.OnClick := nil;
    ChkBackupHTTPEnabled.OnClick := nil;
    ChkLogrithmAddVehicle.OnClick := nil;
    ChkLogrithmUpdateTares.OnClick := nil;
    ChkTareServerEnabled.OnClick := nil;
    ChkTareServerReadTares.OnClick := nil;
    ChkTareServerWriteTares.OnClick := nil;
    try
      ChkSMTPAuth.Checked := Query.FieldByName('SMTPAuth').AsBoolean;
      ChkCopyToSelf.Checked := Query.FieldByName('SMTPSendCopy').AsBoolean;
      ChkBackupHTTPEnabled.Checked := Query.FieldByName('BackupEnabled').AsBoolean;
      ChkLogrithmAddVehicle.Checked := Query.FieldByName('LogrithmAddVehicle').AsBoolean;
      ChkLogrithmUpdateTares.Checked := Query.FieldByName('LogrithmUpdateTares').AsBoolean;
      ChkTareServerEnabled.Checked := Query.FieldByName('TareServerEnabled').AsBoolean;
      ChkTareServerReadTares.Checked := Query.FieldByName('TareServerReadTares').AsBoolean;
      ChkTareServerWriteTares.Checked := Query.FieldByName('TareServerWriteTares').AsBoolean;
    finally
      ChkSMTPAuth.OnClick := ChkSMTPAuthClick;
      ChkCopyToSelf.OnClick := ChkCopyToSelfClick;
      ChkBackupHTTPEnabled.OnClick := ChkAppSupportEnabledClick;
      ChkLogrithmAddVehicle.OnClick := ChkLogrithmAddVehicleClick;
      ChkLogrithmUpdateTares.OnClick := ChkLogrithmUpdateTaresClick;
      ChkTareServerEnabled.OnClick := ChkTareServerEnabledClick;
      ChkTareServerReadTares.OnClick := ChkTareServerReadTaresClick;
      ChkTareServerWriteTares.OnClick := ChkTareServerWriteTaresClick;
    end;

    for I := 0 to CmbTLS.Items.Count-1 do
    if integer(CmbTLS.Items.Objects[i]) = Query.FieldByName('SMTPSecurity').AsInteger then
    begin
      CmbTLS.ItemIndex := i;
      Break;
    end;

    for j := 0 to AdvCmbEmail.Items.Count-1 do
    if integer(AdvCmbEmail.Items.Objects[j]) = Query.FieldByName('EmailProvider').AsInteger then
    begin
      AdvCmbEmail.ItemIndex := j;
      Break;
    end;

    for k := 0 to CmbSMSModem.Items.Count-1 do
    if integer(CmbSMSModem.Items.Objects[k]) = Query.FieldByName('SMSEnabled').AsInteger then
    begin
      CmbSMSModem.ItemIndex := k;
      Break;
    end;

    EdtSMSServerEndpoint.Text := Query.FieldByName('SMSAddress').AsString;
    EdtSMSUsername.Text := Query.FieldByName('SMSUsername').AsString;
    EdtSMSPassword.Text := Query.FieldByName('SMSPassword').AsString;

    EdtTicketServerEndpoint.Text := Query.FieldByName('TicketEndpoint').AsString;

    EdtStartButtonText.Text := Query.FieldByName('StartButtonText').AsString;

    EdtShipModeEmail.Text := Query.FieldByName('ShipModeEmail').AsString;
    edtShipModePassword.Text := Query.FieldByName('ShipModePassword').AsString;

    edtReportLine1.Text := Query.FieldByName('ReportLine1').AsString;
    edtReportLine2.Text := Query.FieldByName('ReportLine2').AsString;
    edtReportLine3.Text := Query.FieldByName('ReportLine3').AsString;


    EdtBackupHost.Text := Query.FieldByName('BackupHost').AsString;
    EdtBackupPort.Text := Query.FieldByName('BackupPort').AsString;
    EdtBackupUsername.Text := Query.FieldByName('BackupUsername').AsString;
    EdtBackupPassword.Text := Query.FieldByName('BackupPassword').AsString;

    edtWindcaveURL.Text := Query.FieldByName('WindcaveHost').AsString;
    edtWindcavePort.Text := Query.FieldByName('WindcavePort').AsString;
    edtWindcaveUsername.Text := Query.FieldByName('WindcaveUsername').AsString;
    edtWindcavePassword.Text := Query.FieldByName('WindcavePassword').AsString;
    edtWindcaveEndpoint.Text := Query.FieldByName('WindcaveEndpoint').AsString;

  except
    on E:Exception do
      //Logger.Write('Error executing SQL statement in TFormAppSupportConfig.CmbConfigGroupsChange ' + E.Message)
  end;
  finally
  end;
end;

procedure TFormAppSupportConfig.CmbSMSModemExit(Sender: TObject);
begin
  writePropertyChange('SMSEnabled', Integer(CmbSMSModem.Items.Objects[CmbTLS.ItemIndex]));
end;

procedure TFormAppSupportConfig.CmbTLSExit(Sender: TObject);
begin
  writePropertyChange('SMTPSecurity', Integer(CmbTLS.Items.Objects[CmbTLS.ItemIndex]));
end;

procedure TFormAppSupportConfig.EdtBackupHostExit(Sender: TObject);
begin
  writePropertyChange('BackupHost', EdtBackupHost.Text);
end;

procedure TFormAppSupportConfig.EdtBackupPasswordExit(Sender: TObject);
begin
  writePropertyChange('BackupPassword', EdtBackupPassword.Text);
end;

procedure TFormAppSupportConfig.EdtBackupPortExit(Sender: TObject);
begin
  writePropertyChange('BackupPort', StrToInt(EdtBackupPort.Text));
end;

procedure TFormAppSupportConfig.EdtBackupUsernameExit(Sender: TObject);
begin
  writePropertyChange('BackupUsername', EdtBackupUsername.Text);
end;

procedure TFormAppSupportConfig.EdtOauthFromExit(Sender: TObject);
begin
    writePropertyChange('OauthFrom', EdtOauthFrom.Text);
end;

procedure TFormAppSupportConfig.EdtAppSupportPasswordExit(Sender: TObject);
begin
  AppSupportSettings.BackupPassword := EdtBackupPassword.Text;
end;

procedure TFormAppSupportConfig.EdtBackupRootFolderExit(Sender: TObject);
begin
  AppSupportSettings.RootFolder := EdtBackupRootFolder.Text;
end;

procedure TFormAppSupportConfig.EdtAppSupportUserameExit(Sender: TObject);
begin
  AppSupportSettings.BackupUserName := EdtBackupUsername.Text;
end;

procedure TFormAppSupportConfig.EdtLogrithmAPIKeyExit(Sender: TObject);
begin
  writePropertyChange('LogrithmAPIKey', EdtLogrithmAPIKey.Text);
end;

procedure TFormAppSupportConfig.EdtLogrithmEndpointExit(Sender: TObject);
begin
  writePropertyChange('LogrithmEndpoint', EdtLogrithmEndpoint.Text);
end;

procedure TFormAppSupportConfig.EdtLogrithmV2APIKeyExit(Sender: TObject);
begin
  writePropertyChange('LogrithmV2APIKey', EdtLogrithmV2APIKey.Text);
end;

procedure TFormAppSupportConfig.EdtLogrithmV2CompanyIDExit(Sender: TObject);
begin
  writePropertyChange('LogrithmV2CompanyID', EdtLogrithmV2CompanyID.Text);
end;

procedure TFormAppSupportConfig.EdtLogrithmV2EndpointExit(Sender: TObject);
begin
  writePropertyChange('LogrithmV2Endpoint', EdtLogrithmV2Endpoint.Text);
end;

procedure TFormAppSupportConfig.EdtNavmanAPIKeyExit(Sender: TObject);
begin
  writePropertyChange('NavmanAPIKey', EdtNavmanAPIKey.Text);
end;

procedure TFormAppSupportConfig.EdtNavmanClientCodeExit(Sender: TObject);
begin
  writePropertyChange('NavmanClientCode', EdtNavmanClientCode.Text);
end;

procedure TFormAppSupportConfig.EdtNavmanEndpointExit(Sender: TObject);
begin
  writePropertyChange('NavmanEndpoint', EdtNavmanEndpoint.Text);
end;

procedure TFormAppSupportConfig.EdtOauthClientIDExit(Sender: TObject);
begin
  writePropertyChange('OauthClientID', EdtOauthClientID.Text);
end;

procedure TFormAppSupportConfig.EdtOauthClientSecretExit(Sender: TObject);
begin
  writePropertyChange('OauthClientSecret', EdtOauthClientSecret.Text);
end;

procedure TFormAppSupportConfig.EdtOauthHostExit(Sender: TObject);
begin
  writePropertyChange('OauthHost', EdtOauthHost.Text);
end;

procedure TFormAppSupportConfig.edtReportLine1Exit(Sender: TObject);
begin
  writePropertyChange('ReportLine1', edtReportLine1.Text);
end;

procedure TFormAppSupportConfig.edtReportLine2Exit(Sender: TObject);
begin
  writePropertyChange('ReportLine2', edtReportLine2.Text);
end;

procedure TFormAppSupportConfig.edtReportLine3Exit(Sender: TObject);
begin
  writePropertyChange('ReportLine3', edtReportLine3.Text);
end;

procedure TFormAppSupportConfig.EdtShipModeEmailExit(Sender: TObject);
begin
  writePropertyChange('ShipModeEmail', EdtShipModeEmail.Text);
end;

procedure TFormAppSupportConfig.edtShipModePasswordExit(Sender: TObject);
begin
  writePropertyChange('ShipModePassword', edtShipModePassword.Text);
end;

procedure TFormAppSupportConfig.EdtSMSPasswordExit(Sender: TObject);
begin
  writePropertyChange('SMSPassword', EdtSMSPassword.Text);
end;

procedure TFormAppSupportConfig.EdtSMSServerEndpointExit(Sender: TObject);
begin
  writePropertyChange('SMSAddress', EdtSMSServerEndpoint.Text);
end;

procedure TFormAppSupportConfig.EdtSMSUsernameExit(Sender: TObject);
begin
  writePropertyChange('SMSUsername', EdtSMSUsername.Text);
end;

procedure TFormAppSupportConfig.EdtSMTPFromExit(Sender: TObject);
begin
  writePropertyChange('SMTPFrom', EdtSMTPFrom.Text);
end;

procedure TFormAppSupportConfig.EdtSMTPHostExit(Sender: TObject);
begin
  writePropertyChange('SMTPHost', EdtSMTPHost.Text);
end;

procedure TFormAppSupportConfig.EdtSMTPPasswordExit(Sender: TObject);
begin
  writePropertyChange('SMTPPassword', EdtSMTPPassword.Text);
end;

procedure TFormAppSupportConfig.EdtSMTPPortExit(Sender: TObject);
begin
  writePropertyChange('SMTPPort', EdtSMTPPort.Text);
end;

procedure TFormAppSupportConfig.EdtSMTPUsernameExit(Sender: TObject);
begin
  writePropertyChange('SMTPUsername', EdtSMTPUsername.Text);
end;

procedure TFormAppSupportConfig.EdtStartButtonTextExit(Sender: TObject);
begin
  writePropertyChange('StartButtonText', EdtStartButtonText.Text);
end;

procedure TFormAppSupportConfig.EdtTicketServerEndpointExit(Sender: TObject);
begin
  writePropertyChange('TicketEndpoint', EdtTicketServerEndpoint.Text);
end;

procedure TFormAppSupportConfig.EdtWebsiteHomePageExit(Sender: TObject);
begin
  writePropertyChange('WebsitehomePage', EdtWebsiteHomePage.Text);
end;

procedure TFormAppSupportConfig.edtWindcaveEndpointExit(Sender: TObject);
begin
  writePropertyChange('WindcaveEndpoint', edtWindcaveEndpoint.Text);
end;

procedure TFormAppSupportConfig.edtWindcavePasswordExit(Sender: TObject);
begin
  writePropertyChange('WindcavePassword', edtWindcavePassword.Text);
end;

procedure TFormAppSupportConfig.edtWindcavePortExit(Sender: TObject);
begin
  writePropertyChange('WindcavePort', edtWindcavePort.Text);
end;

procedure TFormAppSupportConfig.edtWindcaveURLExit(Sender: TObject);
begin
  writePropertyChange('WindcaveHost', edtWindcaveURL.Text);
end;

procedure TFormAppSupportConfig.edtWindcaveUsernameExit(Sender: TObject);
begin
  writePropertyChange('WindcaveUsername', edtWindcaveUsername.Text);
end;

procedure TFormAppSupportConfig.EdtWISAPIEndpointExit(Sender: TObject);
begin
  writePropertyChange('WISAPIEndpoint', EdtWISAPIEndpoint.Text);
end;

procedure TFormAppSupportConfig.EdtWISAPIKeyExit(Sender: TObject);
begin
  writePropertyChange('WISAPIKey', EdtWISAPIKey.Text);
end;

procedure TFormAppSupportConfig.EdtWISGatewayEndpointExit(Sender: TObject);
begin
  writePropertyChange('WISGatewayServiceEndpoint', EdtWISGatewayEndpoint.Text);
end;

procedure TFormAppSupportConfig.FormCreate(Sender: TObject);
//var
//  I: TEmailSSLSetting.Enum;
//  J: TSMSModemEnabled.Enum;
//  K: TEmailProvider.Enum;
begin
  Query.Connection := DataMod.Con;
//  CmbTLS.Clear;
//  for I := Low(TEmailSSLSetting.Enum) to High(TEmailSSLSetting.Enum) do
//    CmbTLS.AddItem(TEmailSSLSetting.DescriptionFromEnum(I), TObject(TEmailSSLSetting.ValueFromEnum(I)));
//
//  CmbSMSModem.Clear;
//  for J := Low(TSMSModemEnabled.Enum) to High(TSMSModemEnabled.Enum) do
//    CmbSMSModem.AddItem(TSMSModemEnabled.DescriptionFromEnum(J), TObject(TSMSModemEnabled.ValueFromEnum(J)));
//
//  AdvCmbEmail.Clear;
//  for K := Low(TEmailProvider.Enum) to High(TEmailProvider.Enum) do
//    AdvCmbEmail.AddItem(TEmailProvider.DescriptionFromEnum(K), TObject(TEmailProvider.ValueFromEnum(K)));

end;

procedure TFormAppSupportConfig.LoadConfigGroupItems;
begin
  CmbConfigGroups.Clear;
  //iterate through items to be loaded
  Query.Open('select ConfigGroup, ConfigGroupsIdx from ConfigGroups order by ConfigGroup');
  while not Query.Eof do
  begin
    CmbConfigGroups.Items.AddObject(Query.FieldByName('ConfigGroup').AsString, TObject(Query.FieldByName('ConfigGroupsIdx').AsInteger));
    Query.Next;
  end;
end;

procedure TFormAppSupportConfig.writePropertyChange(ChangedField : string; setValue : Variant);
begin
  try
    try
      Query.ExecSQL('update ConfigGroups set ' + ChangedField + ' = :ChangedField where ConfigGroupsIdx = :ConfigGroupsIdx', [setValue, Integer(CmbConfigGroups.Items.Objects[CmbConfigGroups.ItemIndex])]);
    except
      on E:Exception do
      //Logger.Write('Error executing SQL statement in TFormAppSupportConfig.writePropertyChange ' + E.Message)
    end;
  finally
  end;
end;

procedure TFormAppSupportConfig.FormShow(Sender: TObject);
begin
  Initialise;
  LoadConfigGroupItems;
  if CmbConfigGroups.Items.Count > 0 then
  begin
    CmbConfigGroups.ItemIndex := 0;
    CmbConfigGroupsChange(Sender);
  end;
end;

procedure TFormAppSupportConfig.Initialise;
begin
  EdtAppSupportUserame.Text := AppSupportSettings.BackupUsername;
  EdtAppSupportPassword.Text := AppSupportSettings.BackupPassword;
  EdtBackupRootFolder.Text := AppSupportSettings.RootFolder;

  EdtDBName.Text := AppSupportSettings.TawhaiAppSupportDBName;
  //ChkStartWithWindows.Checked := TTwSystemUtils.StartWithWindows;
  ChkAppSupportEnabled.Checked := AppSupportSettings.BackupEnabled;
  ChkConfigEnabled.Checked := AppSupportSettings.ConfigEnabled;
end;

//procedure TFormAppSupportConfig.Label2Click(Sender: TObject);
//begin
//
//end;

procedure TFormAppSupportConfig.LnkPrivateFolderClick(Sender: TObject);
begin
  //TTwSystemUtils.ExecuteFile(PrivateFolder);
end;

end.
