object FrameTransactionSearch: TFrameTransactionSearch
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  object PnlBottom: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LblStatus: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 634
      Height = 15
      Align = alTop
      Caption = 'Transaction Search'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 104
    end
    object PnlResults: TPanel
      Left = 0
      Top = 21
      Width = 640
      Height = 459
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 24
      object LabelSeqNum: TLabel
        Left = 159
        Top = 89
        Width = 132
        Height = 15
        Caption = 'Input Sequence Number:'
      end
      object LabelTransDateTime: TLabel
        Left = 147
        Top = 118
        Width = 144
        Height = 15
        Caption = 'Transaction Date and Time:'
      end
      object LabelSiteCode: TLabel
        Left = 238
        Top = 147
        Width = 53
        Height = 15
        Caption = 'Site Code:'
      end
      object LabelBackupFilename: TLabel
        Left = 198
        Top = 176
        Width = 93
        Height = 15
        Caption = 'Backup Filename:'
      end
      object EditSeqNum: TEdit
        Left = 297
        Top = 85
        Width = 121
        Height = 23
        Alignment = taRightJustify
        NumbersOnly = True
        TabOrder = 0
      end
      object ButtonSearchSeqNum: TButton
        Left = 448
        Top = 84
        Width = 75
        Height = 25
        Caption = 'Search'
        TabOrder = 1
        OnClick = ButtonSearchSeqNumClick
      end
      object EditBackupFilename: TEdit
        Left = 297
        Top = 172
        Width = 192
        Height = 23
        ReadOnly = True
        TabOrder = 4
      end
      object EditSiteCode: TEdit
        Left = 297
        Top = 143
        Width = 192
        Height = 23
        ReadOnly = True
        TabOrder = 3
      end
      object EditTransDateTime: TEdit
        Left = 297
        Top = 114
        Width = 192
        Height = 23
        ReadOnly = True
        TabOrder = 2
      end
    end
  end
  object QryTransactionSearch: TFDQuery
    Connection = DataMod.Con
    Left = 544
    Top = 104
  end
end
