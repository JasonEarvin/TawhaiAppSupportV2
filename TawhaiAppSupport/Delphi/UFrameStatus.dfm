object FrameStatus: TFrameStatus
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  OnEnter = FrameEnter
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
      Width = 127
      Height = 15
      Align = alTop
      Caption = 'Most recent site status'
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
      Height = 418
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object GrdStatus: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 634
        Height = 412
        Align = alClient
        DataSource = DtsStatus
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
      Top = 439
      Width = 640
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        640
        41)
      object NvgStatus: TDBNavigator
        Left = 193
        Top = 3
        Width = 222
        Height = 25
        DataSource = DtsStatus
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbDelete, nbRefresh]
        Anchors = [akTop]
        TabOrder = 0
      end
    end
  end
  object QryStatus: TFDQuery
    CachedUpdates = True
    Connection = DataMod.Con
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvMacroExpand]
    ResourceOptions.MacroExpand = False
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate, uvCheckRequired]
    UpdateOptions.CheckRequired = False
    SQL.Strings = (
      
        'select DeviceName, SiteName, SiteCode, AppName, AppVersion, FBVe' +
        'rsion, RecentVehicle, RecentDate, RecentTime, LastSeqNum, LastSt' +
        'atusReceived, LocalIP, GatewayIP, PublicIP from Status order by ' +
        'DeviceName')
    Left = 88
    Top = 168
  end
  object DtsStatus: TDataSource
    DataSet = QryStatus
    Left = 280
    Top = 288
  end
end
