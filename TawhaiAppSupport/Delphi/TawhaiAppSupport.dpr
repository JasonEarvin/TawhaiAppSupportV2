program TawhaiAppSupport;



uses
  Vcl.Forms,
  AppSupportServerThreadUnit in 'AppSupportServerThreadUnit.pas',
  UConfigServerThread in 'UConfigServerThread.pas' {/UStatusServerThread in 'UStatusServerThread.pas';},
  UFrameBackup in 'UFrameBackup.pas' {FrameBackup: TFrame},
  UFrameConfig in 'UFrameConfig.pas' {FrameConfig: TFrame},
  UFormAppSupportMain in 'UFormAppSupportMain.pas' {FormAppSupportMain},
  UFormAppSupportConfig in 'UFormAppSupportConfig.pas' {FormAppSupportConfig},
  UAppSupportConfig in 'UAppSupportConfig.pas',
  UDataMod in 'UDataMod.pas' {DataMod: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  UFrameStatus in 'UFrameStatus.pas' {FrameStatus: TFrame},
  UConfigGroups in 'UConfigGroups.pas',
  TwRegUtils in '..\..\..\..\TawhaiUtils\TwRegUtils.pas',
  TwUtils in '..\..\..\..\TawhaiUtils\TwUtils.pas',
  TwConstants in '..\..\..\..\TawhaiUtils\TwConstants.pas',
  UFrameTransactionSearch in 'UFrameTransactionSearch.pas' {FrameTransactionSearch: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataMod, DataMod);
  Application.CreateForm(TFormAppSupportMain, FormAppSupportMain);
  Application.CreateForm(TFormAppSupportConfig, FormAppSupportConfig);
  Application.Run;
end.
