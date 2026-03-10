unit UConfigServerThread;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  System.SyncObjs,
  Winapi.Windows,
  System.DateUtils,
  System.JSON,
  IdBaseComponent,
  IdComponent,
  IdGlobal,
  IdHTTPServer,
  IdContext,
  IdURI,
  IdCustomHTTPServer,
  AbBase,
  AbBrowse,
  AbZBrows,
  AbZipper,
  AbUnzper,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param;

type
  TConfigServerThread = class(TThread)
  private
    { Private declarations }
    FMsgHandle: THandle;
    FTerminateEvent: TEvent;
    FPurgeNow: Boolean;
    IdHttpServer: TIdHttpServer;
    procedure IdHTTPServerConnect(AContext: TIdContext);
    procedure IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure LogMsg(AMsg: string);
    procedure Initialise;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;    //sleep alternative
  public
    property MsgHandle: THandle read FMsgHandle write FMsgHandle;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  TwUtils,
  TwConstants,
//  TwUtils,
//  TwSystemUtils,
//  TwStringUtils,
//  HTTPEnumTypesUnit,
//  LoggerUnit,
//  TwConstants,
  UAppSupportConfig;
//  CommonSetupUnit;

constructor TConfigServerThread.Create;
begin
  inherited Create;

  FreeOnTerminate := True;
  FTerminateEvent := TEvent.Create(nil, True, False, '');
  IdHttpServer := TIdHTTPServer.Create(nil);
  IdHttpServer.DefaultPort := iPORT_CONFIG_SERVER;

  IdHttpServer.OnConnect := IdHTTPServerConnect;
  IdHttpServer.OnCommandGet := IdHTTPServerCommandGet;

  //Logger.Write('Config server thread created');

  FMsgHandle := 0;
  Initialise;
end;

destructor TConfigServerThread.Destroy;
begin
  FTerminateEvent.Free;
  IdHttpServer.Free;

  inherited;
end;

procedure TConfigServerThread.LogMsg(AMsg: string);
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

procedure TConfigServerThread.Execute;
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

    if not AppSupportSettings.ConfigEnabled then
    begin
      if IdHttpServer.Active then
      begin
        IdHttpServer.Active := False;
        LogMsg('Config HTTP server inactive');
      end;
    end;

    if not AppSupportSettings.configEnabled then
      Continue;

    if AppSupportSettings.configEnabled and not IdHttpServer.Active then
    begin
      Initialise;
      try
        IdHttpServer.Active := True;
      except
        on E:Exception do
          LogMsg('Error opening HTTP server: ' + E.Message);
      end;
      LogMsg('HTTP server active');
    end;
  until Terminated;
end;

procedure TConfigServerThread.IdHTTPServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  jsonRequestString : string;
  requestGroupString :  string;
  jsonRequestValue : TJSONValue;
  jsonResponseRootObject : TJSONObject;
  jsonResponseChildObject : TJSONObject;
  jsonResponseString : string;
//  configGroup : integer;
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
        try
          deviceNameString := jsonRequestValue.GetValue<string>(JSON_DEVICENAME);
          if deviceNameString.IsEmpty then
            deviceNameString := 'Unknown device';
        except
         //
        end;

      except
        on E:Exception do
          //Logger.Write('Error in TConfigServerThread.IdHTTPServerCommandGet (SourceMsg) ' + E.Message);
      end;
      try
        Query.Open('select ConfigGroupIdx, SiteIdx from Sites where SiteCode = :SiteCode', [siteCodeString]);

//        Query.Open('select s.ConfigGroupIdx, c.SitesIdx from Computers c left join Sites s on s.SiteIdx = c.SitesIdx where c.DeviceName = :DeviceName', [DeviceNameString]);
        if Query.FieldByName('ConfigGroupIdx').IsNull then
        begin
          Result := 1;
          try
            Query.Open('update or insert into Sites (SiteCode, ConfigGroupIdx) values (:SiteCode, :ConfigGroupIdx) matching (SiteCode) returning SiteIdx', [SiteCodeString, 1]);
//
//            Query.SQL.Text := 'update or insert into Computers (DeviceName, SiteCodeIdx, ConfigGroupIdx) ' +
//            'values (:DeviceName, :SiteCode, :ConfigGroupIdx) matching (DeviceName)';
//            Query.ParamByName('DeviceName').AsString := deviceNameString;
//            Query.ParamByName('SiteCode').AsString := siteCodeString;
//            Query.ParamByName('ConfigGroupIdx').AsInteger := 1;
//            Query.ExecSQL;
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

  procedure ProcessReports;
  begin
    jsonResponseRootObject := TJSONObject.Create;
    jsonResponseChildObject := TJSONObject.Create;
    try
      try
        Query.Open('select ReportLine1, ReportLine2, ReportLine3 from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('reports')]);

        jsonResponseChildObject.AddPair(JSON_REPORTS_LINE1, Query.FieldByName('ReportLine1').AsString);
        jsonResponseChildObject.AddPair(JSON_REPORTS_LINE2, Query.FieldByName('ReportLine2').AsString);
        jsonResponseChildObject.AddPair(JSON_REPORTS_LINE3, Query.FieldByName('ReportLine3').AsString);
        jsonResponseRootObject.AddPair(JSON_CONFIG_REPORTS, jsonResponseChildObject);

        jsonResponseString := jsonResponseRootObject.ToString;
      except
        on E:Exception do
          //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessReports) ' + E.Message);
      end;
    finally
      jsonResponseRootObject.Free;
    end;
    try
      AResponseInfo.ContentStream := TStringStream.Create(jsonResponseString, TEncoding.UTF8);
    except
       on E:Exception do
          //Logger.Write('Error processing Reports request in TConfigServerThread.IdHTTPServerCommandGet ' + E.Message);
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

  procedure ProcessBackupServer;
  begin
    jsonResponseRootObject := TJSONObject.Create;
    jsonResponseChildObject := TJSONObject.Create;
    try
      try
        Query.Open('select BackupEnabled, BackupHost, BackupPort, BackupUsername, BackupPassword from ConfigGroups where ConfigGroupsIdx = :ConfigGroupsIdx', [sourceMsg('Backup')]);

        jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_ENABLED, Query.FieldByName('BackupEnabled').AsBoolean);
        jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_HOST, Query.FieldByName('BackupHost').AsString);
        jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_PASSWORD, Query.FieldByName('BackupPassword').AsString);
        jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_PORT, Query.FieldByName('BackupPort').AsInteger);
        jsonResponseChildObject.AddPair(JSON_BACKUPHTTP_USERNAME, Query.FieldByName('BackupUsername').AsString);

        jsonResponseRootObject.AddPair(JSON_CONFIG_BACKUP_SERVER, jsonResponseChildObject);
        jsonResponseString := jsonResponseRootObject.ToString;
      except
        on E:Exception do
          //Logger.Write('Error executing SQL statement in TConfigServerThread.IdHTTPServerCommandGet (ProcessBackupServer) ' + E.Message);
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

     Query.SQL.Text := 'update or insert into Computers (DeviceName, SitesIdx, AppName, AppVersion, FBVersion, RecentVehicle, RecentDate, RecentTime, LastSeqNum, LastStatusReceived, LocalIP) ' +
        'values (:DeviceName, :SitesIdx, :AppName, :AppVersion, :FBVersion, :RecentVehicle, :RecentDate, :RecentTime, :LastSeqNum, :LastStatusReceived, :LocalIP) matching (DeviceName, AppName)';
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

      Query.ExecSQL;
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
    begin
//      LogMsg(JsonRequestString);
      ProcessStatus
    end

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
    if requestGroupString = JSON_CONFIG_BACKUP_SERVER then
      ProcessBackupServer
    else
    if requestGroupString = JSON_CONFIG_WINDCAVE then
      ProcessWindcave
    else
    if requestGroupString = JSON_CONFIG_DRIVERMODE then
      ProcessDriverMode
    else
    if requestGroupString = JSON_CONFIG_REPORTS then
      ProcessReports
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

procedure TConfigServerThread.IdHTTPServerConnect(AContext: TIdContext);
begin
  //LogMsg('Connection from HTTP client ' + AContext.Binding.PeerIP);
end;

procedure TConfigServerThread.Initialise;
begin

end;

procedure TConfigServerThread.TerminatedSet;
begin
  inherited;
  FTerminateEvent.SetEvent;
end;

end.
