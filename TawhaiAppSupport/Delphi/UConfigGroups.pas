unit UConfigGroups;

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
  FireDAC.Comp.Client;
  //TwFDQuery;

type
  TConfigGroups = class sealed (TObject)
  strict private
    class var FInstance: TConfigGroups;
  private
    Query: TFDQuery;

    class function Instance: TConfigGroups;
//    constructor Create;

    function GetConfigGroupName: string;
//    function GetTicketEndpoint: string;
//    function GetWebsiteHomePage: string;
//    function GetWISGatewayServiceEndpoint: string;
//
//    function GetSMSAddress: string;
//    function GetSMSUsername: string;
//    function GetSMSPassword: string;
//    function GetSMSEnabled: Boolean;
//
//    function GetNavmanEndpoint: string;
//    function GetNavmanAPIKey: string;
//    function GetNavmanClientCode: string;



    procedure SetconfigGroupName(const Value: string);


  public
    property ConfigGroupName: string read GetConfigGroupName write SetConfigGroupName;
    class procedure ReleaseInstance;
  published
  end;

function ConfigGroups: TConfigGroups;

implementation

uses
//  LoggerUnit,
//  DbugIntf,
//  TwConnection,
//  TwSystemUtils,
  TwConstants,
  TwRegUtils;

function ConfigGroups: TConfigGroups;
begin
  Result := TConfigGroups.Instance;
end;

function TConfigGroups.GetConfigGroupName: string;
begin
  //get
end;

procedure TConfigGroups.SetConfigGroupName(const Value: string);
begin
  //set
end;

class function TConfigGroups.Instance: TConfigGroups;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TConfigGroups.Create;
  end;

  Result := FInstance;
end;

class procedure TConfigGroups.ReleaseInstance;
begin
  ConfigGroups.Free;
end;

end.
