unit UFrameStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  TwConstants, System.IOUtils, System.UITypes, AppSupportServerThreadUnit, Vcl.Buttons, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait, Vcl.DBCtrls,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef;

type
  TFrameStatus = class(TFrame)
    PnlBottom: TPanel;
    LblStatus: TLabel;
    PnlResults: TPanel;
    GrdStatus: TDBGrid;
    PnlControls: TPanel;
    NvgStatus: TDBNavigator;
    QryStatus: TFDQuery;
    DtsStatus: TDataSource;
    procedure FrameEnter(Sender: TObject);
    procedure QryStatusRECENTDATEGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure QryStatusRECENTTIMEGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  private
    //
  public
    procedure Initialise;
    procedure OnRefreshMsg(var Msg: TMessage); message WM_REFRESH_HISTORY;
  end;

implementation

{$R *.dfm}

uses
  UDataMod,
  TwUtils;
//  TwConnection,
//  TwSystemUtils,
//  TwStringUtils;

procedure TFrameStatus.FrameEnter(Sender: TObject);
begin
  QryStatus.Refresh;
  //MemLog.Invalidate;
  GrdStatus.Invalidate;
  Self.Invalidate;
  //MemLog.Refresh;
  GrdStatus.Refresh;
  Self.Repaint;
  //SendCursorToEnd(MemLog);
end;

procedure TFrameStatus.Initialise;
begin
  QryStatus.Connection := DataMod.Con;
  GrdStatus.DataSource := DtsStatus;
  QryStatus.Open('select c.DeviceName, s.SiteName, s.SiteCode, c.AppName, c.AppVersion, c.FBVersion, c.RecentVehicle, c.RecentDate, c.RecentTime, c.LastSeqNum, c.LastStatusReceived, c.LocalIP, s.GatewayIP, s.PublicIP from Computers c left join Sites s on s.SiteIdx = c.SitesIdx order by DeviceName');

  //GrdSites.ColumnByFieldName('SiteIdx').Visible := False;

//  GrdStatus.ColumnByFieldName('DeviceName').Title.Caption := 'Device name';
//  GrdStatus.ColumnByFieldName('DeviceName').Width := 125;
//
//  GrdStatus.ColumnByFieldName('SiteName').Title.Caption := 'Site name';
//  GrdStatus.ColumnByFieldName('SiteName').Width := 100;
//
//  GrdStatus.ColumnByFieldName('SiteCode').Title.Caption := 'Site Code';
//  GrdStatus.ColumnByFieldName('SiteCode').Width := 70;
//
//  GrdStatus.ColumnByFieldName('AppName').Title.Caption := 'App Name';
//  GrdStatus.ColumnByFieldName('AppName').Width := 110;
//
//  GrdStatus.ColumnByFieldName('AppVersion').Title.Caption := 'App version';
//  GrdStatus.ColumnByFieldName('AppVersion').Width := 70;
//
//  GrdStatus.ColumnByFieldName('FBVersion').Title.Caption := 'FB Version';
//  GrdStatus.ColumnByFieldName('FBVersion').Width := 70;
//
//  GrdStatus.ColumnByFieldName('RecentVehicle').Title.Caption := 'Recent Vehicle';
//  GrdStatus.ColumnByFieldName('RecentVehicle').Width := 80;
//
//  GrdStatus.ColumnByFieldName('RecentDate').Title.Caption := 'Recent Date';
//  GrdStatus.ColumnByFieldName('RecentDate').Width := 75;
//
//  GrdStatus.ColumnByFieldName('RecentTime').Title.Caption := 'Recent Time';
//  GrdStatus.ColumnByFieldName('RecentTime').Width := 75;
//
//  GrdStatus.ColumnByFieldName('LastSeqNum').Title.Caption := 'Last Sequence Number';
//  GrdStatus.ColumnByFieldName('LastSeqNum').Width := 80;
//
//  GrdStatus.ColumnByFieldName('LastStatusReceived').Title.Caption := 'Last Status';
//  GrdStatus.ColumnByFieldName('LastStatusReceived').Width := 130;
//
//  GrdStatus.ColumnByFieldName('LocalIP').Title.Caption := 'Local IP';
//  GrdStatus.ColumnByFieldName('LocalIP').Width := 70;
//
//  GrdStatus.ColumnByFieldName('GatewayIP').Title.Caption := 'Gateway IP';
//  GrdStatus.ColumnByFieldName('GatewayIP').Width := 70;
//
//  GrdStatus.ColumnByFieldName('PublicIP').Title.Caption := 'Public IP';
//  GrdStatus.ColumnByFieldName('PublicIP').Width := 70;
//
//  QryStatus.ShowDateTimesFully := False;
end;

procedure TFrameStatus.OnRefreshMsg(var Msg: TMessage);
begin
  QryStatus.Refresh;
//  MemLog.Invalidate;
  GrdStatus.Invalidate;
  Self.Invalidate;
  //MemLog.Refresh;
  GrdStatus.Refresh;
  Self.Repaint;
  //SendCursorToEnd(MemLog);
end;

procedure TFrameStatus.QryStatusRECENTDATEGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.AsDateTime > 0.1 then
    Text := DateToStr(Sender.AsDateTime)
  else
    Text := '';
end;

procedure TFrameStatus.QryStatusRECENTTIMEGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.AsDateTime > 0.1 then
    Text := TimetoStr(Sender.AsDateTime)
  else
    Text := '';
end;

end.
