object FrameConfig: TFrameConfig
  Left = 0
  Top = 0
  Width = 661
  Height = 591
  TabOrder = 0
  object LblLog: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 655
    Height = 15
    Align = alTop
    Caption = 'Activity log'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitWidth = 63
  end
  object MemLog: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 24
    Width = 655
    Height = 393
    Align = alTop
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 420
    Width = 661
    Height = 171
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object LblSiteGrps: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 9
      Width = 102
      Height = 15
      Align = alTop
      Caption = 'Assign site groups:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Splitter1: TSplitter
      Left = 0
      Top = 0
      Width = 661
      Height = 6
      Cursor = crVSplit
      Align = alTop
    end
    object PnlControls: TPanel
      Left = 0
      Top = 139
      Width = 661
      Height = 32
      Align = alBottom
      BevelOuter = bvNone
      BevelWidth = 3
      TabOrder = 0
      object cmbSite: TComboBox
        AlignWithMargins = True
        Left = 5
        Top = 3
        Width = 326
        Height = 23
        Margins.Left = 5
        Align = alLeft
        TabOrder = 0
        OnChange = cmbSiteChange
      end
      object cmbConfigGroup: TComboBox
        AlignWithMargins = True
        Left = 330
        Top = 3
        Width = 326
        Height = 26
        Margins.Right = 5
        Align = alRight
        TabOrder = 1
        OnChange = cmbConfigGroupChange
      end
    end
  end
  object Query: TFDQuery
    CachedUpdates = True
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvMacroExpand]
    ResourceOptions.MacroExpand = False
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate, uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 608
    Top = 24
  end
end
