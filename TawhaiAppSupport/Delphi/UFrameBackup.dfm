object FrameBackup: TFrameBackup
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  OnEnter = FrameEnter
  object LblLog: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 634
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
  object Splitter1: TSplitter
    Left = 0
    Top = 252
    Width = 640
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object MemLog: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 24
    Width = 634
    Height = 225
    Align = alTop
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 255
    Width = 640
    Height = 225
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object LblResults: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 147
      Height = 15
      Align = alTop
      Caption = 'Most recent backup status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object PnlResults: TPanel
      Left = 0
      Top = 21
      Width = 640
      Height = 163
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object GrdSites: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 634
        Height = 157
        Align = alClient
        DataSource = DtsSites
        DrawingStyle = gdsClassic
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object PnlControls: TPanel
      Left = 0
      Top = 184
      Width = 640
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        640
        41)
      object NvgSites: TDBNavigator
        Left = 209
        Top = 8
        Width = 222
        Height = 25
        DataSource = DtsSites
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbRefresh]
        Anchors = [akTop]
        TabOrder = 0
      end
    end
  end
  object DtsSites: TDataSource
    DataSet = QrySites
    Left = 280
    Top = 288
  end
  object QrySites: TFDQuery
    CachedUpdates = True
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvMacroExpand]
    ResourceOptions.MacroExpand = False
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate, uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 192
    Top = 288
  end
end
