unit UFrameConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,  Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  TwConstants, System.IOUtils, System.UITypes, AppSupportServerThreadUnit, Vcl.Buttons, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait, Vcl.DBCtrls;

type
  TFrameConfig = class(TFrame)
    LblLog: TLabel;
    MemLog: TMemo;
    PnlBottom: TPanel;
    LblSiteGrps: TLabel;
    PnlControls: TPanel;
    Splitter1: TSplitter;
    cmbSite: TComboBox;
    cmbConfigGroup: TComboBox;
    Query: TFDQuery;
    procedure cmbSiteChange(Sender: TObject);
    procedure cmbConfigGroupChange(Sender: TObject);
  private

  public
    procedure OnLogMsg(var Msg: TMessage); message WM_LOG_MSG;
    procedure OnRefreshMsg(var Msg: TMessage); message WM_REFRESH_HISTORY;
    procedure LogMsg(AMsg: string);
    procedure Initialise;
  end;

implementation

{$R *.dfm}

uses
  UDataMod,
  TwUtils;
//  TwConnection,
//  TwSystemUtils,
//  TwStringUtils,
//  LoggerUnit;

procedure TFrameConfig.cmbConfigGroupChange(Sender: TObject);
begin
  try
    query.SQL.Text := 'update Sites set ConfigGroupIdx = :ConfigGroupIdx where SiteIdx = :SiteIdx';
    Query.ParamByName('ConfigGroupIdx').AsLargeInt := Integer(cmbConfigGroup.Items.Objects[cmbConfigGroup.ItemIndex]);
    Query.ParamByName('SiteIdx').AsLargeInt := Integer(cmbSite.Items.Objects[cmbSite.ItemIndex]);
    Query.ExecSQL;
   except
    on E:Exception do
      //Logger.Write('Error executing SQL statement in TFrameConfig.cmbConfigGroupChange ' + E.Message)
  end;
end;

procedure TFrameConfig.cmbSiteChange(Sender: TObject);
begin
  try
    try
    Query.Open('select ConfigGroupIdx from Sites where "SITEIDX" = :SiteIdx', [integer(cmbSite.Items.Objects[cmbSite.ItemIndex])]);
    cmbConfigGroup.ItemIndex := cmbConfigGroup.Items.IndexOfObject(TObject(Query.FieldByName('ConfigGroupIdx').AsInteger));
  except
    on E:Exception do
      //Logger.Write('Error executing SQL statement in TFrameConfig.cmbSiteExit ' + E.Message)
  end;
  finally
//    if not cmbSite.ItemIndex = -1 then
    cmbConfigGroup.Enabled := true;
  end;
end;

procedure TFrameConfig.Initialise;
begin
  Query.Connection := DataMod.Con;
  try
    try
      CmbSite.Clear;
      //iterate through items to be loaded
      Query.Open('select SiteName, SiteIdx from Sites order by SiteName');
      while not Query.Eof do
      begin
        CmbSite.Items.AddObject(Query.FieldByName('SiteName').AsString, TObject(Query.FieldByName('SiteIdx').AsInteger));
        Query.Next;
      end;
    except
      on E:Exception do
      //Logger.Write('Error executing SQL statement in TFrameConfig.Initialise for SiteName ' + E.Message)
    end;

    try
      CmbConfigGroup.Clear;
      //iterate through items to be loaded
      Query.Open('select ConfigGroup, ConfigGroupsIdx from ConfigGroups order by ConfigGroup');
      while not Query.Eof do
      begin
        CmbConfigGroup.Items.AddObject(Query.FieldByName('ConfigGroup').AsString, TObject(Query.FieldByName('ConfigGroupsIdx').AsInteger));
        Query.Next;
      end;
    except
      on E:Exception do
      //Logger.Write('Error executing SQL statement in TFrameConfig.Initialise for ConfigGroup ' + E.Message)
    end;
  finally
    if cmbSite.ItemIndex = -1 then
      cmbConfigGroup.Enabled := False;
  end;
end;


procedure TFrameConfig.LogMsg(AMsg: string);
begin
  MemLog.Lines.Append(DateTimeToStr(Now) + ': ' + AMsg);
//  SendCursorToEnd(MemLog);
//
//  if MemLog.Lines.Count > 10000 then
//    TTwStringUtils.PurgeMemo(MemLog, 1000);
end;

procedure TFrameConfig.OnLogMsg(var Msg: TMessage);
begin
  LogMsg(TStringMsg(Msg.WParam).MsgStr);
  TStringMsg(Msg.WParam).Free;
end;

procedure TFrameConfig.OnRefreshMsg(var Msg: TMessage);
begin
  MemLog.Invalidate;
  Self.Invalidate;
  MemLog.Refresh;
  Self.Repaint;
  //SendCursorToEnd(MemLog);
end;

end.
