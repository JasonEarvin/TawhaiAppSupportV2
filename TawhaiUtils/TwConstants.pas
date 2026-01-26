unit TwConstants;

interface

uses
  Winapi.Messages;

const
  WM_LOG_MSG = WM_USER + 2508;
  WM_REFRESH_HISTORY = WM_USER + 2104;
  iPORT_CONFIG_SERVER = 43200;
  iPORT_HTTP_BACKUP_SERVER = 43241;
  PrivateFolder = 'C:\Users\Jason\AppData\Local\Tawhai Technology';

  { ASCII Codes }
  ascNUL = Chr(0);
  ascSOH = Chr(1);
  ascSTX = Chr(2);
  ascETX = Chr(3);
  ascEOT = Chr(4);
  ascENQ = Chr(5);
  ascACK = Chr(6);
  ascBEL = Chr(7);
  ascBS = Chr(8);
  ascTAB = Chr(9);
  ascLF = Chr(10);
  ascVT = Chr(11);
  ascFF = Chr(12);
  ascCR = Chr(13);
  ascENT = Chr(13);
  ascSO = Chr(14);
  ascSI = Chr(15);
  ascDLE = Chr(16);
  ascDC1 = Chr(17);
  ascXON = Chr(17);
  ascDC2 = Chr(18);
  ascDC3 = Chr(19);
  ascXOFF = Chr(19);
  ascDC4 = Chr(20);
  ascNAK = Chr(21);
  ascSYN = Chr(22);
  ascETB = Chr(23);
  ascCAN = Chr(24);
  ascEM = Chr(25);
  ascSUB = Chr(26);
  ascESC = Chr(27);
  ascFS = Chr(28); //file separator
  ascGS = Chr(29); //group separator
  ascRS = Chr(30); //record separator
  ascUS = Chr(31); //unit separator

  VERSION_FIREBIRD = 'FirebirdVersion';
  VERSION_APPNAME = 'AppName';
  VERSION_APPVERSION = 'AppVersion';

  FIREBIRD_USERNAME = 'SYSDBA';
  FIREBIRD_PASSWORD = 'masterkey';

  JSON_BACKUP_CURRENTBACKUPS = 'CurrentBackups';
  JSON_BACKUP_GETLIST_SITENAME = 'SiteName';
  JSON_BACKUP_GETLIST_INDEX = 'Index';
  JSON_BACKUP_GETLIST_LASTBACKUP = 'LastBackup';
  JSON_BACKUP_GETLIST_SITESIDX = 'SitesIdx';
  JSON_BACKUP_GETLIST_APPNAME = 'AppName';
  JSON_BACKUP_GETLIST_APPVERSION = 'AppVersion';
  JSON_BACKUP_GETLIST_FBVERSION = 'FBVersion';
  JSON_CONFIGSERVER_VERSION = 'ConfigServerVersion';
  X_FORWARDED_FOR = 'X-Forwarded-For';
  CONFIG_REQUEST = 'ConfigRequest';
  JSON_SITECODE = 'SiteCode';
  JSON_DEVICENAME = 'DeviceName';
  JSON_WEBSITE_HOMEPAGE = 'WebsiteHomePage';
  JSON_WEBSITE_WISGATEWAYSERVICEENDPOINT = 'WISGatewayServiceEndpoint';
  JSON_WEBSITE_WISAPIENDPOINT = 'WISAPIEndpoint';
  JSON_WEBSITE_WISAPIKEY = 'WISAPIKey';
  JSON_TARESERVER_ENABLED = 'TareServerEnabled';
  JSON_TARESERVER_READTARES = 'TareServerReadTares';
  JSON_TARESERVER_WRITETARES = 'TareServerWriteTares';

  JSON_LOGRITHM_ENDPOINT = 'LogrithmEndpoint';
  JSON_LOGRITHM_APIKEY = 'LogrithmAPIKey';
  JSON_LOGRITHM_ADDVEHICLE = 'LogrithmAddVehicle';
  JSON_LOGRITHM_UPDATETARES = 'LogrithmUpdateTares';

  JSON_LOGRITHMV2_ENDPOINT = 'LogrithmV2Endpoint';
  JSON_LOGRITHMV2_APIKEY = 'LogrithmV2APIKey';
  JSON_LOGRITHMV2_COMPANYID = 'LogrithmV2CompanyID';

  JSON_EMAIL_PROVIDER = 'EmailProvider';

  JSON_SMTP_HOST = 'SMTPHost';
  JSON_SMTP_PORT = 'SMTPPort';
  JSON_SMTP_USERNAME = 'SMTPUsername';
  JSON_SMTP_PASSWORD = 'SMTPPassword';
  JSON_SMTP_AUTH = 'SMTPAuth';
  JSON_SMTP_SMTPSSLTLS = 'SMTPSSLTLS';
  JSON_SMTP_COPYTOSELF = 'SMTPCopyToSelf';
  JSON_SMTP_FROM = 'SMTPFromAddr';

  JSON_OAUTH_CLIENTID = 'OauthClientID';
  JSON_OAUTH_CLIENTSECRET = 'OauthClientSecret';
  JSON_OAUTH_HOST = 'OauthHost';
  JSON_OAUTH_PORT = 'OauthPort';
  JSON_OAUTH_FROM = 'OauthFromAddr';

  JSON_BACKUP_BASEFOLDER = 'BackupBaseFolder';
  JSON_BACKUP_ENABLED = 'BackupEnabled';
  JSON_BACKUP_HOST = 'BackupHost';
  JSON_BACKUP_PASSWORD = 'BackupPassword';
  JSON_BACKUP_PORT = 'BackupPort';
  JSON_BACKUP_USERNAME = 'BackupUsername';

  JSON_BACKUPHTTP_ENABLED = 'BackupHTTPEnabled';
  JSON_BACKUPHTTP_HOST = 'BackupHTTPHost';
  JSON_BACKUPHTTP_PASSWORD = 'BackupHTTPPassword';
  JSON_BACKUPHTTP_PORT = 'BackupHTTPPort';
  JSON_BACKUPHTTP_USERNAME = 'BackupHTTPUsername';

  JSON_REPORTS_LINE1 = 'ReportLine1';
  JSON_REPORTS_LINE2 = 'ReportLine2';
  JSON_REPORTS_LINE3 = 'ReportLine3';

  JSON_CONFIG_GROUP = 'ConfigGroup';

  JSON_CONFIG_TESTCONNECT = 'ConfigTestConnect';
  JSON_CONFIG_STATUS = 'Status';
  JSON_CONFIG_GENERAL = 'ConfigGeneral';
  JSON_CONFIG_NAVMAN = 'ConfigNavman';
  JSON_CONFIG_EMAIL = 'ConfigSMTP';
  JSON_CONFIG_SMS_SERVER = 'ConfigSMSServer';
  JSON_CONFIG_TICKET_SERVER = 'ConfigTicketServer';
  JSON_CONFIG_BACKUP_SERVER = 'ConfigBackupServer';
  JSON_CONFIG_WEBSITE = 'ConfigWebsite';
  JSON_CONFIG_WINDCAVE = 'ConfigWindcave';
  JSON_CONFIG_REPORTS = 'ConfigReports';
  JSON_CONFIG_DRIVERMODE = 'ConfigDriverMode';
  JSON_CONFIG_SHIPMODE = 'ConfigShipMode';
  JSON_CONFIG_LOGRITHM = 'ConfigLogrithm';
  JSON_CONFIG_TARE_SERVER = 'ConfigTareServer';
  JSON_CONFIG_DATABASE = 'ConfigDatabase';
  JSON_CONFIG_COMPANY = 'ConfigCompany';

  JSON_DRIVERMODE_STARTTEXT = 'DriverModeStartText';

  JSON_NAVMAN_ENDPOINT = 'NavmanEndpoint';
  JSON_NAVMAN_APIKEY = 'NavmanAPIKey';
  JSON_NAVMAN_CLIENTCODE = 'NavmanClientCode';
  JSON_NAVMAN_SPLITMSG = 'NavmanSplitMsg';

  JSON_SMSSERVER_ENDPOINT = 'SMSServerEndpoint';
  JSON_SMS_USERNAME = 'SMSUsername';
  JSON_SMS_PASSWORD = 'SMSPassword';
  JSON_SMS_MODEM_MODE = 'SMSModemMode';

  JSON_TICKETSERVER_ENDPOINT = 'TicketServerEndpoint';

  JSON_SHIPMODE_EMAIL = 'ShipModeEmail';
  JSON_SHIPMODE_EMAIL_PASSWORD = 'ShipModeEmailPassword';

  JSON_WINDCAVE_URL = 'WindcaveURL';
  JSON_WINDCAVE_ENDPOINT = 'WindcaveEndpoint';
  JSON_WINDCAVE_PORT = 'WindcavePort';
  JSON_WINDCAVE_USERNAME = 'WindcaveUsername';
  JSON_WINDCAVE_PASSWORD = 'WindcavePassword';

  JSON_STATUS_NAME = 'SiteName';
  JSON_STATUS_APPNAME = 'AppName';    //eg WIS, RTS, GantryWIS, RoadGate, LoadoutBay etc
  JSON_STATUS_APPVERSION = 'AppVersion';
  JSON_STATUS_FBVERSION = 'FBVersion';
  JSON_STATUS_RECENTVEHICLE = 'RecentVehicle';
  JSON_STATUS_RECENTTIME = 'RecentTime';
  JSON_STATUS_RECENTDATE = 'RecentDate';
  JSON_STATUS_LASTSEQNUM = 'LastSeqNum';
  JSON_STATUS_LOCALIP = 'LocalIP';
  JSON_STATUS_GATEWAYIP = 'GatewayIP';
  JSON_STATUS_PUBLICIP = 'PublicIP';
  JSON_STATUS_DEVICES = 'DeviceStatus';

  JSON_STATUS_DEVICE_NAME = 'Name';
  JSON_STATUS_DEVICE_TYPE = 'Type';
  JSON_STATUS_DEVICE_ENABLED = 'Enabled';
  JSON_STATUS_DEVICE_ONLINE = 'Online';
  JSON_STATUS_DEVICE_LASTVALUE = 'LastValue'; //current weight for scales, last plate for NPR, last tag for iButton, paper status for printer

  JSON_STATUS_DEVICE_SCALE1 = 'Scale1';
  JSON_STATUS_DEVICE_SCALE2 = 'Scale2';
  JSON_STATUS_DEVICE_IBUTTON = 'IButton';
  JSON_STATUS_DEVICE_OFFICEIBUTTON = 'OfficeIButton';
  JSON_STATUS_DEVICE_NPIBUTTON = 'NPIButton';
  JSON_STATUS_DEVICE_PRIMARYPRINTER = 'PrimaryPrinter';
  JSON_STATUS_DEVICE_SECONDARYPRINTER = 'SecondaryPrinter';
  JSON_STATUS_DEVICE_COPYPRINTER = 'CopyPrinter';
  JSON_STATUS_DEVICE_NPR1 = 'NPR1';
  JSON_STATUS_DEVICE_NPR2 = 'NPR2';
  JSON_STATUS_DEVICE_NPRSTILL = 'NPRStill';
  JSON_STATUS_DEVICE_WINDCAVE = 'Windcave';
  JSON_STATUS_DEVICE_IO1 = 'IO1';
  JSON_STATUS_DEVICE_IO2 = 'IO2';
  JSON_STATUS_DEVICE_IO3 = 'IO3';
  JSON_STATUS_DEVICE_IO4 = 'IO4';
  JSON_STATUS_DEVICE_ICP = 'ICP';
  JSON_STATUS_DEVICE_SILDISPLAY = 'SILDisplay';
  JSON_STATUS_DEVICE_RINSTRUMDISPLAY = 'RinstrumDisplay';
  JSON_STATUS_DEVICE_RICELAKEDISPLAY = 'RiceLakeDisplay';
  JSON_STATUS_DEVICE_DISPLAY1 = 'Display1';
  JSON_STATUS_DEVICE_DISPLAY2 = 'Display2';
  JSON_STATUS_DEVICE_DISPLAY3 = 'Display3';
  JSON_STATUS_DEVICE_DRIVERTERMINAL = 'DriverTerminal';

  JSON_STATUS_HARDWARE_CPU = 'CPU'; //Returns CPU model
  JSON_STATUS_HARDWARE_MEMORY = 'MEMORY'; //Returns amount of RAM
  JSON_STATUS_HARDWARE_STORAGETYPE = 'StorageType'; //Bool: true SSD VS false HDD
  JSON_STATUS_HARDWARE_STORAGECAPACITY = 'StorageCapacity';
  JSON_STATUS_HARDWARE_STORAGEUSE = 'StorageUsed'; //% of use

  HTTP_BACKUP_GETLIST = 'GetList';
  //From Jason
  HTTP_BACKUP_ACTION_GETBACKUPSFORSITE = 'getBackupsForSite';
  HTTP_BACKUP_SITEIDX = 'SiteIdx';
  HTTP_BACKUP_GETBACKUP = 'GetBackup';
  HTTP_BACKUP_SITECODE = 'SiteCode';
  HTTP_BACKUP_ACTION = 'Action';
  HTTP_BACKUP_ACTION_ONLINECHECK = 'OnlineCheck';
  HTTP_BACKUP_ACTION_BACKUPFILE = 'BackupFile';
  HTTP_BACKUP_FILENAME = 'FileName';

implementation

end.
