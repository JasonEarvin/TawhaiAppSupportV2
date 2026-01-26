object FormDBRestoreMain: TFormDBRestoreMain
  Left = 0
  Top = 0
  Caption = 'Database restore utility'
  ClientHeight = 583
  ClientWidth = 920
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MnuMain
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 920
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = -3
    object LblDestFile: TLabel
      Left = 23
      Top = 88
      Width = 82
      Height = 15
      Caption = 'Destination file:'
    end
    object LnkReload: TLabel
      Left = 23
      Top = 63
      Width = 36
      Height = 15
      Cursor = crHandPoint
      Caption = 'Reload'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = LnkReloadClick
    end
    object LblSiteNames: TLabel
      Left = 23
      Top = 13
      Width = 62
      Height = 15
      Caption = 'Site Names:'
    end
    object LblBackupVersion: TLabel
      Left = 360
      Top = 13
      Width = 75
      Height = 15
      Caption = 'Select Version:'
    end
    object BtnDownload: TButton
      Left = 631
      Top = 33
      Width = 121
      Height = 25
      Caption = 'Download backup'
      TabOrder = 1
      OnClick = BtnDownloadClick
    end
    object CmbSiteNames: TComboBox
      Left = 23
      Top = 34
      Width = 313
      Height = 23
      Style = csDropDownList
      DropDownCount = 20
      Sorted = True
      TabOrder = 0
      StyleElements = [seBorder]
    end
  end
  object PnlMain: TPanel
    Left = 0
    Top = 112
    Width = 920
    Height = 471
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 914
    ExplicitHeight = 454
    object memoBackupInfo: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 914
      Height = 465
      Align = alClient
      Lines.Strings = (
        'memoBackupInfo')
      ParentShowHint = False
      ReadOnly = True
      ShowHint = False
      TabOrder = 0
      ExplicitWidth = 908
      ExplicitHeight = 448
    end
  end
  object CmbBackups: TComboBox
    Left = 360
    Top = 34
    Width = 265
    Height = 23
    TabOrder = 2
  end
  object HttpClient: TIdHTTP
    IOHandler = SSLHandler
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = True
    Request.Password = 'Backup01#'
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Username = 'backup'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 416
    Top = 472
  end
  object SSLHandler: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvTLSv1_2
    SSLOptions.SSLVersions = [sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 312
    Top = 472
  end
  object UnZipper: TAbUnZipper
    Left = 120
    Top = 472
  end
  object FDIBRestore: TFDIBRestore
    OnProgress = FDIBRestoreProgress
    Left = 496
    Top = 472
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 680
    Top = 472
  end
  object SaveDialog1: TSaveDialog
    Left = 776
    Top = 472
  end
  object FDCon: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    Left = 648
    Top = 248
  end
  object Qry: TFDQuery
    Connection = FDCon
    Left = 464
    Top = 264
  end
  object MnuMain: TMainMenu
    Left = 112
    Top = 152
    object MniFile: TMenuItem
      Caption = 'File'
      object MniFileSetup: TMenuItem
        Caption = 'Setup'
        OnClick = MniFileSetupClick
      end
      object MniFileExit: TMenuItem
        Caption = 'Exit'
        OnClick = MniFileExitClick
      end
    end
  end
end
