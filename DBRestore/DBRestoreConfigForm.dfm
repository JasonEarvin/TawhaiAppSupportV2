object FormDBRestoreConfig: TFormDBRestoreConfig
  Left = 0
  Top = 0
  Caption = 'DBRestore settings'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    624
    441)
  TextHeight = 15
  object LblBackupServerEndpoint: TLabel
    Left = 7
    Top = 19
    Width = 128
    Height = 15
    Alignment = taRightJustify
    Caption = 'Backup Server Endpoint:'
  end
  object LblBackupServerUsername: TLabel
    Left = 2
    Top = 49
    Width = 133
    Height = 15
    Alignment = taRightJustify
    Caption = 'Backup Server Username:'
  end
  object LblBackupServerPassword: TLabel
    Left = 8
    Top = 76
    Width = 130
    Height = 15
    Alignment = taRightJustify
    Caption = 'Backup Server Password:'
  end
  object LblDestFolder: TLabel
    Left = 39
    Top = 123
    Width = 99
    Height = 15
    Alignment = taRightJustify
    Caption = 'Destination Folder:'
  end
  object LblDestFileName: TLabel
    Left = 22
    Top = 152
    Width = 116
    Height = 15
    Alignment = taRightJustify
    Caption = 'Destination File Name'
  end
  object EdtBackServerEndpoint: TEdit
    Left = 144
    Top = 15
    Width = 459
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnExit = EdtBackServerEndpointExit
    ExplicitWidth = 453
  end
  object EdtBackServerUsername: TEdit
    Left = 144
    Top = 45
    Width = 125
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnExit = EdtBackServerUsernameExit
    ExplicitWidth = 119
  end
  object EdtBackServerPassword: TEdit
    Left = 144
    Top = 73
    Width = 125
    Height = 23
    TabOrder = 2
    OnExit = EdtBackServerPasswordExit
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 400
    Width = 624
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 6
    ExplicitTop = 383
    ExplicitWidth = 618
    DesignSize = (
      624
      41)
    object BtnClose: TBitBtn
      Left = 528
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 0
      ExplicitLeft = 522
    end
  end
  object EdtDestFolder: TEdit
    Left = 144
    Top = 119
    Width = 433
    Height = 23
    TabOrder = 3
    OnExit = EdtDestFolderExit
  end
  object BtnBrowse: TButton
    Left = 586
    Top = 120
    Width = 23
    Height = 23
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = BtnBrowseClick
  end
  object EdtDestFileName: TEdit
    Left = 144
    Top = 148
    Width = 125
    Height = 23
    TabOrder = 5
    OnExit = EdtDestFileNameExit
  end
end
