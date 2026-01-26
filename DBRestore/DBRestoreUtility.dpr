program DBRestoreUtility;

uses
  Vcl.Forms,
  DBRestoreMainForm in 'DBRestoreMainForm.pas' {FormDBRestoreMain},
  DBRestoreConfigForm in 'DBRestoreConfigForm.pas' {FormDBRestoreConfig},
  DBRestoreConfigUnit in 'DBRestoreConfigUnit.pas',
  TwUtils in '..\..\..\TawhaiUtils\TwUtils.pas',
  TwConstants in '..\..\..\TawhaiUtils\TwConstants.pas',
  TwRegUtils in '..\..\..\TawhaiUtils\TwRegUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormDBRestoreMain, FormDBRestoreMain);
  Application.Run;
end.
