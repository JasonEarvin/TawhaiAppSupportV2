unit UFrameBackup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  TwConstants, System.IOUtils, System.UITypes, AppSupportServerThreadUnit, Vcl.Buttons, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait, Vcl.DBCtrls, System.Math;

//From Jason
procedure AutoSizeDBGridColumns(AGrid: TDBGrid);

type
  TFrameBackup = class(TFrame)
    LblLog: TLabel;
    MemLog: TMemo;
    PnlBottom: TPanel;
    LblResults: TLabel;
    PnlResults: TPanel;
    GrdSites: TDBGrid;
    PnlControls: TPanel;
    NvgSites: TDBNavigator;
    Splitter1: TSplitter;
    DtsSites: TDataSource;
    QrySites: TFDQuery;
    procedure FrameEnter(Sender: TObject);
  private
    Grandparent : TWinControl;
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

procedure TFrameBackup.FrameEnter(Sender: TObject);
begin
  QrySites.Refresh;
  //MemLog.Invalidate;
  GrdSites.Invalidate;
  Self.Invalidate;
  //MemLog.Refresh;
  GrdSites.Refresh;
  Self.Repaint;
end;

procedure TFrameBackup.Initialise;
begin
  Grandparent := Self.Parent;
  while Grandparent.Parent <> nil do
    Grandparent := Grandparent.Parent;

  //update grid
  try
    QrySites.Connection := DataMod.Con;
    GrdSites.DataSource := DtsSites;
    QrySites.Open('select s.SiteCode, s.SiteName, s.SiteFolder, b.BackupReceived, b.FileName, FileSize, b.AppName, b.AppVersion, b.FBVersion from Backups b left join Sites s on s.SiteIdx = b.SitesIdx where b.IsCurrentBackup = true order by s.SiteCode');


    AutoSizeDBGridColumns(GrdSites);
    //GrdSites.ColumnByFieldName('SiteIdx').Visible := False;

//    GrdSites.ColumnByFieldName('SiteCode').Title.Caption := 'Site code';
//    GrdSites.ColumnByFieldName('SiteCode').Width := 150;
//
//    GrdSites.ColumnByFieldName('SiteName').Title.Caption := 'Site name';
//    GrdSites.ColumnByFieldName('SiteName').Width := 150;
//
//    GrdSites.ColumnByFieldName('SiteFolder').Title.Caption := 'Site folder';
//    GrdSites.ColumnByFieldName('SiteFolder').Width := 200;
//
//    GrdSites.ColumnByFieldName('BackupReceived').Title.Caption := 'Last backup';
//    GrdSites.ColumnByFieldName('BackupReceived').Width := 150;
//
//    GrdSites.ColumnByFieldName('FileName').Title.Caption := 'File name';
//    GrdSites.ColumnByFieldName('FileName').Width := 150;
//
//    GrdSites.ColumnByFieldName('FileSize').Title.Caption := 'File size';
//    GrdSites.ColumnByFieldName('FileSize').Width := 75;
//
//    GrdSites.ColumnByFieldName('AppName').Title.Caption := 'App name';
//    GrdSites.ColumnByFieldName('AppName').Width := 150;
//
//    GrdSites.ColumnByFieldName('AppVersion').Title.Caption := 'App version';
//    GrdSites.ColumnByFieldName('AppVersion').Width := 75;
//
//    GrdSites.ColumnByFieldName('FBVersion').Title.Caption := 'FB version';
//    GrdSites.ColumnByFieldName('FBVersion').Width := 75;
//
//    QrySites.ShowDateTimesFully := True;
  except
    on E:Exception do
      //Logger.Write('Error executing SQL statement in TFrameBackup.Initialise ' + E.Message)
  end;

end;

//From Jason
procedure AutoSizeDBGridColumns(AGrid: TDBGrid);
var
  I, W: Integer;
  Field: TField;
  DS: TDataSet;
begin
  if (AGrid = nil) or
     (AGrid.DataSource = nil) or
     (AGrid.DataSource.DataSet = nil) or
     not AGrid.DataSource.DataSet.Active then
    Exit;

  DS := AGrid.DataSource.DataSet;
  AGrid.Canvas.Font := AGrid.Font;

  DS.DisableControls;
  try
    for I := 0 to AGrid.Columns.Count - 1 do
    begin
      Field := AGrid.Columns[I].Field;
      if Field = nil then
        Continue;

      //Start with title width
      W := AGrid.Canvas.TextWidth(AGrid.Columns[I].Title.Caption) + 16;

      DS.First;
      while not DS.Eof do
      begin
        W := Max(W,
          AGrid.Canvas.TextWidth(Field.DisplayText) + 16
        );
        DS.Next;
      end;

      AGrid.Columns[I].Width := W;
    end;
  finally
    DS.EnableControls;
  end;
end;



procedure TFrameBackup.LogMsg(AMsg: string);
begin
  MemLog.Lines.Append(DateTimeToStr(Now) + ': ' + AMsg);
//  SendCursorToEnd(MemLog);
//
//  if MemLog.Lines.Count > 10000 then
//    TTwStringUtils.PurgeMemo(MemLog, 1000);
end;

procedure TFrameBackup.OnLogMsg(var Msg: TMessage);
begin
  LogMsg(TStringMsg(Msg.WParam).MsgStr);
  TStringMsg(Msg.WParam).Free;
end;

procedure TFramebackup.OnRefreshMsg(var Msg: TMessage);
begin
  //Logger.Write('Running TFramebackup.OnRefreshMsg');
  if Grandparent = nil then
    begin
      //Logger.Write('Exiting because Grandparent is nil');
      exit;
    end;

  if Grandparent.Visible and QrySites.Active then
  begin
    try
      QrySites.Refresh;
    except
      on E:Exception do
        begin
          //Logger.Write('Error in TFramebackup.OnRefreshMsg ' + E.message);
          Exit;
        end;
    end;
    //Logger.Write('Running OnRefreshMsg');

    GrdSites.DataSource := DtsSites;
    QrySites.Open;
    MemLog.Invalidate;
    GrdSites.Invalidate;
    Self.Invalidate;
    MemLog.Refresh;
    GrdSites.Refresh;
    Self.Repaint;
    //SendCursorToEnd(MemLog);
  end
  else
    //Logger.Write('Not running OnRefreshMsg because Grandparent is not visible or QrySites is not active');
end;

end.
