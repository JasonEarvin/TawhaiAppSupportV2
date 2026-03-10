unit UFrameTransactionSearch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus,
  TwConstants, System.IOUtils, System.UITypes, AppSupportServerThreadUnit, Vcl.Buttons, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait, Vcl.DBCtrls,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef;

type
  TFrameTransactionSearch = class(TFrame)
    PnlBottom: TPanel;
    LblStatus: TLabel;
    PnlResults: TPanel;
    LabelSeqNum: TLabel;
    EditSeqNum: TEdit;
    LabelTransDateTime: TLabel;
    LabelSiteCode: TLabel;
    LabelBackupFilename: TLabel;
    ButtonSearchSeqNum: TButton;
    EditBackupFilename: TEdit;
    EditSiteCode: TEdit;
    EditTransDateTime: TEdit;
    QryTransactionSearch: TFDQuery;
    procedure ButtonSearchSeqNumClick(Sender: TObject);
  private
    procedure ClearFields;
  public
    procedure Initialise;
  end;

implementation

{$R *.dfm}

uses
  UDataMod,
  TwUtils;

procedure TFrameTransactionSearch.ButtonSearchSeqNumClick(Sender: TObject);
var
  SeqNum: Integer;
begin
  // basic validation
  if not TryStrToInt(EditSeqNum.Text, SeqNum) then
  begin
    ShowMessage('Please enter a valid numeric sequence number.');
    Exit;
  end;

  QryTransactionSearch.Close;
  QryTransactionSearch.SQL.Clear;
  QryTransactionSearch.SQL.Text :=
    'SELECT TRANSDATETIME, SITECODE, BACKUPFILENAME ' +
    'FROM TRANSACTIONLOCATION ' +
    'WHERE SEQNUM = :SEQNUM';

  QryTransactionSearch.ParamByName('SEQNUM').AsInteger := SeqNum;
  QryTransactionSearch.Open;

  if QryTransactionSearch.IsEmpty then
  begin
    ShowMessage('Sequence number not found.');
    ClearFields;
    Exit;
  end;

  EditTransDateTime.Text :=
    DateTimeToStr(QryTransactionSearch.FieldByName('TRANSDATETIME').AsDateTime);
  EditSiteCode.Text :=
    QryTransactionSearch.FieldByName('SITECODE').AsString;
  EditBackupFilename.Text :=
    QryTransactionSearch.FieldByName('BACKUPFILENAME').AsString;
end;

procedure TFrameTransactionSearch.ClearFields;
begin
  EditTransDateTime.Clear;
  EditSiteCode.Clear;
  EditBackupFilename.Clear;
end;

procedure TFrameTransactionSearch.Initialise;
begin
  QryTransactionSearch.Connection := DataMod.Con;
  ClearFields;
  EditSeqNum.Clear;
  LblStatus.Caption := '';
end;

end.
