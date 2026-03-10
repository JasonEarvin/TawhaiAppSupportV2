object FormAppSupportConfig: TFormAppSupportConfig
  Left = 0
  Top = 0
  Caption = 'Setup'
  ClientHeight = 920
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PnlBottom: TPanel
    Left = 0
    Top = 879
    Width = 634
    Height = 41
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 862
    ExplicitWidth = 628
    DesignSize = (
      634
      41)
    object BtnFormClose: TBitBtn
      Left = 515
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 0
      ExplicitLeft = 509
    end
  end
  object PnlMid: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 412
    Width = 628
    Height = 464
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 622
    ExplicitHeight = 447
    object LblConfig: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 620
      Height = 15
      Align = alTop
      Caption = 'Config Server:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 80
    end
    object PgcConfig: TPageControl
      Left = 1
      Top = 89
      Width = 626
      Height = 374
      ActivePage = TbsDriverMode
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 620
      ExplicitHeight = 357
      object TbsWIS: TTabSheet
        Caption = 'WIS'
        ImageIndex = 5
        object grpWISWebsite: TGroupBox
          Left = 0
          Top = 89
          Width = 618
          Height = 88
          Align = alTop
          Caption = 'WIS Website'
          TabOrder = 1
          DesignSize = (
            618
            88)
          object LblWebsiteHomepage: TLabel
            AlignWithMargins = True
            Left = 65
            Top = 24
            Width = 110
            Height = 15
            Caption = 'Website Home page:'
          end
          object LblWISGatewayEndpoint: TLabel
            AlignWithMargins = True
            Left = 13
            Top = 53
            Width = 162
            Height = 15
            Caption = 'WIS Service Gateway Endpoint:'
          end
          object EdtWebsiteHomePage: TEdit
            AlignWithMargins = True
            Left = 181
            Top = 21
            Width = 424
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = EdtWebsiteHomePageExit
          end
          object EdtWISGatewayEndpoint: TEdit
            AlignWithMargins = True
            Left = 181
            Top = 50
            Width = 424
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = EdtWISGatewayEndpointExit
          end
        end
        object grpWISAPI: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 89
          Align = alTop
          Anchors = [akLeft, akRight]
          Caption = 'WIS API'
          TabOrder = 0
          DesignSize = (
            618
            89)
          object LblWISAPIEndpoint: TLabel
            AlignWithMargins = True
            Left = 14
            Top = 25
            Width = 95
            Height = 15
            Caption = 'WIS API Endpoint:'
          end
          object LblWISAPIKey: TLabel
            AlignWithMargins = True
            Left = 36
            Top = 54
            Width = 66
            Height = 15
            Caption = 'WIS API Key:'
          end
          object EdtWISAPIEndpoint: TEdit
            AlignWithMargins = True
            Left = 115
            Top = 22
            Width = 490
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = EdtWISAPIEndpointExit
          end
          object EdtWISAPIKey: TEdit
            AlignWithMargins = True
            Left = 115
            Top = 51
            Width = 490
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = EdtWISAPIKeyExit
          end
        end
        object grpTareServer: TGroupBox
          Left = 0
          Top = 177
          Width = 618
          Height = 96
          Align = alTop
          Caption = 'Tare Server'
          TabOrder = 2
          object ChkTareServerEnabled: TCheckBox
            Left = 14
            Top = 23
            Width = 180
            Height = 17
            Caption = 'Tare Server Enabled'
            TabOrder = 0
            OnClick = ChkTareServerEnabledClick
          end
          object ChkTareServerReadTares: TCheckBox
            Left = 14
            Top = 46
            Width = 193
            Height = 17
            Caption = 'Read Tares'
            TabOrder = 1
            OnClick = ChkTareServerReadTaresClick
          end
          object ChkTareServerWriteTares: TCheckBox
            Left = 13
            Top = 69
            Width = 161
            Height = 17
            Caption = 'Write Tares'
            TabOrder = 2
            OnClick = ChkTareServerWriteTaresClick
          end
        end
      end
      object TbsSMS: TTabSheet
        Caption = 'SMS'
        ImageIndex = 3
        object GrpSMS: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 161
          Align = alTop
          Caption = 'SMS'
          TabOrder = 0
          DesignSize = (
            618
            161)
          object LblSMSAddress: TLabel
            Left = 25
            Top = 27
            Width = 45
            Height = 15
            Caption = 'Address:'
          end
          object LblSMSUsername: TLabel
            Left = 17
            Top = 82
            Width = 53
            Height = 15
            Caption = 'Password:'
          end
          object LblSMSPassword: TLabel
            Left = 14
            Top = 56
            Width = 56
            Height = 15
            Caption = 'Username:'
          end
          object LblSMSModem: TLabel
            Left = 25
            Top = 114
            Width = 45
            Height = 15
            Caption = 'Enabled:'
          end
          object EdtSMSServerEndpoint: TEdit
            Left = 75
            Top = 24
            Width = 521
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = EdtSMSServerEndpointExit
          end
          object BtnShowSMSPass: TButton
            Left = 547
            Top = 82
            Width = 50
            Height = 23
            Anchors = [akTop, akRight]
            Caption = 'Show'
            TabOrder = 3
            OnClick = BtnShowSMSPassClick
          end
          object CmbSMSModem: TComboBox
            Left = 76
            Top = 111
            Width = 521
            Height = 23
            Style = csDropDownList
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 4
            OnExit = CmbSMSModemExit
          end
          object EdtSMSPassword: TEdit
            Left = 76
            Top = 82
            Width = 465
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            PasswordChar = '*'
            TabOrder = 2
            OnExit = EdtSMSPasswordExit
          end
          object EdtSMSUsername: TEdit
            Left = 76
            Top = 53
            Width = 521
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = EdtSMSUsernameExit
          end
        end
      end
      object TbsTicket: TTabSheet
        Caption = 'Tickets'
        ImageIndex = 4
        DesignSize = (
          618
          344)
        object LblTicketServerEndpoint: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 10
          Width = 612
          Height = 15
          Margins.Top = 10
          Align = alTop
          Caption = 'Ticket Server Endpoint:'
          ExplicitWidth = 121
        end
        object lblTicketLogoPath: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 60
          Width = 612
          Height = 15
          Align = alTop
          Caption = 'Ticket Logo Path:'
          ExplicitWidth = 92
        end
        object lblTicketContent: TLabel
          Left = 3
          Top = 110
          Width = 81
          Height = 15
          Caption = 'Ticket Content:'
        end
        object EdtTicketServerEndpoint: TEdit
          AlignWithMargins = True
          Left = 3
          Top = 31
          Width = 612
          Height = 23
          Align = alTop
          TabOrder = 0
          OnExit = EdtTicketServerEndpointExit
        end
        object edtTicketLogoPath: TEdit
          AlignWithMargins = True
          Left = 3
          Top = 81
          Width = 612
          Height = 23
          Align = alTop
          TabOrder = 1
        end
        object btnTicketLogoPathOpen: TButton
          AlignWithMargins = True
          Left = 576
          Top = 81
          Width = 21
          Height = 23
          Anchors = [akTop, akRight]
          Caption = '...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnTicketLogoPathOpenClick
        end
      end
      object TbsNavman: TTabSheet
        Caption = 'Navman'
        object grpNavman: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 249
          Align = alTop
          Caption = 'Navman'
          TabOrder = 0
          DesignSize = (
            618
            249)
          object LblNavmanAPIKey: TLabel
            Left = 16
            Top = 86
            Width = 91
            Height = 15
            Caption = 'Navman API Key:'
          end
          object LblNavmanEndpoint: TLabel
            Left = 16
            Top = 22
            Width = 99
            Height = 15
            Caption = 'Navman Endpoint:'
          end
          object LblNavmanClientCode: TLabel
            Left = 16
            Top = 149
            Width = 111
            Height = 15
            Caption = 'Navman Client code:'
          end
          object EdtNavmanAPIKey: TEdit
            Left = 3
            Top = 107
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = EdtNavmanAPIKeyExit
          end
          object EdtNavmanEndpoint: TEdit
            Left = 3
            Top = 43
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = EdtNavmanEndpointExit
          end
          object EdtNavmanClientCode: TEdit
            Left = 3
            Top = 170
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 2
            OnExit = EdtNavmanClientCodeExit
          end
          object ChkNavmanSplitMsg: TCheckBox
            Left = 3
            Top = 216
            Width = 198
            Height = 17
            Caption = 'Split truck and trailer messages'
            TabOrder = 3
            OnClick = ChkNavmanSplitMsgClick
          end
        end
      end
      object TbsEmail: TTabSheet
        Caption = 'Email'
        ImageIndex = 2
        object pgcEmail: TPageControl
          Left = 0
          Top = 29
          Width = 618
          Height = 315
          ActivePage = TbsOauth
          Align = alClient
          TabOrder = 0
          object TbsSMTP: TTabSheet
            Caption = 'SMTP'
            object GrpSMTP: TGroupBox
              Left = 0
              Top = 0
              Width = 610
              Height = 249
              Align = alTop
              Caption = 'SMTP'
              TabOrder = 0
              DesignSize = (
                610
                249)
              object LblSMTPHost: TLabel
                Left = 41
                Top = 27
                Width = 28
                Height = 15
                Caption = 'Host:'
              end
              object LblSMTPPort: TLabel
                Left = 45
                Top = 56
                Width = 25
                Height = 15
                Caption = 'Port:'
              end
              object LblSMTPUsername: TLabel
                Left = 14
                Top = 85
                Width = 56
                Height = 15
                Caption = 'Username:'
              end
              object LblSMTPPassword: TLabel
                Left = 17
                Top = 114
                Width = 53
                Height = 15
                Caption = 'Password:'
              end
              object LblSMTPSSLTLS: TLabel
                Left = 26
                Top = 170
                Width = 45
                Height = 15
                Caption = 'SSL/TLS:'
              end
              object LblSMTPFrom: TLabel
                Left = 40
                Top = 143
                Width = 31
                Height = 15
                Caption = 'From:'
              end
              object EdtSMTPPort: TEdit
                Left = 76
                Top = 53
                Width = 77
                Height = 23
                TabOrder = 1
                OnExit = EdtSMTPPortExit
              end
              object EdtSMTPHost: TEdit
                Left = 75
                Top = 24
                Width = 523
                Height = 23
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 0
                OnExit = EdtSMTPHostExit
              end
              object BtnShowSMTPPass: TButton
                Left = 884
                Top = 111
                Width = 50
                Height = 23
                Anchors = [akTop, akRight]
                Caption = 'Show'
                TabOrder = 4
                OnClick = BtnShowSMTPPassClick
              end
              object ChkCopyToSelf: TCheckBox
                Left = 76
                Top = 199
                Width = 158
                Height = 17
                Caption = 'Send copy to self'
                TabOrder = 6
                OnClick = ChkCopyToSelfClick
              end
              object ChkSMTPAuth: TCheckBox
                Left = 76
                Top = 222
                Width = 158
                Height = 17
                Caption = 'SMTP Authentication'
                TabOrder = 7
                OnClick = ChkSMTPAuthClick
              end
              object CmbTLS: TComboBox
                Left = 77
                Top = 170
                Width = 522
                Height = 23
                Style = csDropDownList
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 5
                OnExit = CmbTLSExit
              end
              object EdtSMTPPassword: TEdit
                Left = 76
                Top = 111
                Width = 522
                Height = 23
                Anchors = [akLeft, akTop, akRight]
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -12
                Font.Name = 'Segoe UI'
                Font.Style = []
                ParentFont = False
                PasswordChar = '*'
                TabOrder = 3
                OnExit = EdtSMTPPasswordExit
              end
              object EdtSMTPUsername: TEdit
                Left = 76
                Top = 82
                Width = 522
                Height = 23
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 2
                OnExit = EdtSMTPUsernameExit
              end
              object EdtSMTPFrom: TEdit
                Left = 77
                Top = 140
                Width = 522
                Height = 23
                Anchors = [akLeft, akTop, akRight]
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -12
                Font.Name = 'Segoe UI'
                Font.Style = []
                ParentFont = False
                TabOrder = 8
                OnExit = EdtSMTPFromExit
              end
            end
          end
          object TbsOauth: TTabSheet
            Caption = 'OAuth'
            ImageIndex = 1
            DesignSize = (
              610
              285)
            object EdtOauthClientID: TEdit
              Left = 83
              Top = 74
              Width = 492
              Height = 23
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 0
              OnExit = EdtOauthClientIDExit
            end
            object EdtOauthClientSecret: TEdit
              Left = 83
              Top = 103
              Width = 492
              Height = 23
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 1
              OnExit = EdtOauthClientSecretExit
            end
            object EdtOauthHost: TEdit
              Left = 83
              Top = 16
              Width = 492
              Height = 23
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 2
              OnExit = EdtOauthHostExit
            end
            object AdvSpinEdtOauthPort: TSpinEdit
              Left = 83
              Top = 45
              Width = 121
              Height = 24
              Color = clWhite
              MaxValue = 0
              MinValue = 0
              TabOrder = 3
              Value = 0
              OnExit = AdvSpinEdtOauthPortExit
            end
            object EdtOauthFrom: TEdit
              AlignWithMargins = True
              Left = 83
              Top = 132
              Width = 492
              Height = 23
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 4
              OnExit = EdtOauthFromExit
            end
          end
        end
        object AdvCmbEmail: TComboBox
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 612
          Height = 23
          Align = alTop
          TabOrder = 1
          OnChange = AdvCmbEmailChange
        end
      end
      object TbsBackup: TTabSheet
        Caption = 'Backup'
        ImageIndex = 5
        object GrpBackup: TGroupBox
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 612
          Height = 170
          Align = alTop
          Caption = 'Backup'
          TabOrder = 0
          DesignSize = (
            612
            170)
          object LblBackupPassword: TLabel
            Left = 55
            Top = 138
            Width = 53
            Height = 15
            Alignment = taRightJustify
            Caption = 'Password:'
          end
          object ChkBackupHTTPEnabled: TCheckBox
            Left = 12
            Top = 24
            Width = 165
            Height = 17
            Caption = 'HTTP backup enabled'
            TabOrder = 0
            OnClick = ChkBackupHTTPEnabledClick
          end
          object EdtBackupHost: TEdit
            Left = 112
            Top = 47
            Width = 489
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = EdtBackupHostExit
          end
          object EdtBackupPort: TEdit
            Left = 112
            Top = 76
            Width = 81
            Height = 23
            TabOrder = 2
            Text = '0'
            OnExit = EdtBackupPortExit
          end
          object EdtBackupUsername: TEdit
            Left = 112
            Top = 105
            Width = 489
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 3
            OnExit = EdtBackupUsernameExit
          end
          object BtnShowBackupPass: TButton
            Left = 551
            Top = 133
            Width = 50
            Height = 25
            Anchors = [akTop, akRight]
            Caption = 'Show'
            TabOrder = 4
            OnClick = BtnShowBackupPassClick
          end
          object EdtBackupPassword: TEdit
            Left = 112
            Top = 134
            Width = 433
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            PasswordChar = '*'
            TabOrder = 5
            OnExit = EdtBackupPasswordExit
          end
        end
      end
      object TbsWindcave: TTabSheet
        Caption = 'Windcave'
        ImageIndex = 6
        object GrpWindcave: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 185
          Align = alTop
          Caption = 'Windcave'
          TabOrder = 0
          DesignSize = (
            618
            185)
          object Label1: TLabel
            Left = 914
            Top = 507
            Width = 28
            Height = 15
            Caption = 'Host:'
          end
          object lblWindcavePort: TLabel
            Left = 28
            Top = 56
            Width = 53
            Height = 15
            Caption = 'Host port:'
          end
          object lblWindcaveUsername: TLabel
            Left = 24
            Top = 85
            Width = 56
            Height = 15
            Caption = 'Username:'
          end
          object lblWindcavePassword: TLabel
            Left = 27
            Top = 114
            Width = 53
            Height = 15
            Caption = 'Password:'
          end
          object lblWindcaveURL: TLabel
            Left = 28
            Top = 27
            Width = 52
            Height = 15
            Caption = 'Host URL:'
          end
          object lblWindcaveEndpoint: TLabel
            Left = 9
            Top = 142
            Width = 72
            Height = 15
            Caption = 'API Endpoint:'
          end
          object edtWindcaveEndpoint: TEdit
            Left = 86
            Top = 140
            Width = 521
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 5
            OnExit = edtWindcaveEndpointExit
          end
          object edtWindcavePort: TEdit
            Left = 86
            Top = 53
            Width = 77
            Height = 23
            TabOrder = 1
            OnExit = edtWindcavePortExit
          end
          object edtWindcaveURL: TEdit
            Left = 86
            Top = 24
            Width = 521
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = edtWindcaveURLExit
          end
          object btnShowWindcavePassword: TButton
            Left = 557
            Top = 111
            Width = 50
            Height = 23
            Anchors = [akTop, akRight]
            Caption = 'Show'
            TabOrder = 4
            OnClick = btnShowWindcavePasswordClick
          end
          object edtWindcavePassword: TEdit
            Left = 86
            Top = 111
            Width = 465
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            PasswordChar = '*'
            TabOrder = 3
            OnExit = edtWindcavePasswordExit
          end
          object edtWindcaveUsername: TEdit
            Left = 86
            Top = 82
            Width = 521
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 2
            OnExit = edtWindcaveUsernameExit
          end
        end
      end
      object TbsDriverMode: TTabSheet
        Caption = 'Driver Mode'
        ImageIndex = 7
        object LblStartButtonText: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 612
          Height = 15
          Align = alTop
          Caption = 'Start button text:'
          ExplicitWidth = 88
        end
        object EdtStartButtonText: TEdit
          AlignWithMargins = True
          Left = 3
          Top = 24
          Width = 612
          Height = 23
          Align = alTop
          TabOrder = 0
          OnExit = EdtStartButtonTextExit
          ExplicitWidth = 606
        end
      end
      object TbsReports: TTabSheet
        Caption = 'Reports'
        ImageIndex = 8
        object grpReports: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 193
          Align = alTop
          Caption = 'Report Headers'
          TabOrder = 0
          DesignSize = (
            618
            193)
          object LblReportLine2: TLabel
            Left = 16
            Top = 76
            Width = 34
            Height = 15
            Caption = 'Line 2:'
          end
          object lblReportLine1: TLabel
            Left = 16
            Top = 22
            Width = 34
            Height = 15
            Caption = 'Line 1:'
          end
          object LblReportLine3: TLabel
            Left = 16
            Top = 131
            Width = 34
            Height = 15
            Caption = 'Line 3:'
          end
          object edtReportLine2: TEdit
            Left = 3
            Top = 97
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            OnExit = edtReportLine2Exit
          end
          object edtReportLine1: TEdit
            Left = 3
            Top = 43
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            OnExit = edtReportLine1Exit
          end
          object edtReportLine3: TEdit
            Left = 3
            Top = 152
            Width = 545
            Height = 23
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 2
            OnExit = edtReportLine3Exit
          end
        end
      end
      object TbsShipMode: TTabSheet
        Caption = 'Ship Mode'
        ImageIndex = 9
        DesignSize = (
          618
          344)
        object LblShipModePassword: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 53
          Width = 612
          Height = 30
          Align = alTop
          Caption = 'Email from password:'#13#10
          ExplicitWidth = 114
        end
        object lblShipModeEmail: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 612
          Height = 15
          Align = alTop
          Caption = 'Email from address:'
          ExplicitWidth = 104
        end
        object EdtShipModeEmail: TEdit
          AlignWithMargins = True
          Left = 3
          Top = 24
          Width = 612
          Height = 23
          Align = alTop
          TabOrder = 0
          OnExit = EdtShipModeEmailExit
        end
        object edtShipModePassword: TEdit
          Left = 3
          Top = 74
          Width = 538
          Height = 23
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          PasswordChar = '*'
          TabOrder = 1
          OnExit = edtShipModePasswordExit
        end
        object btnShipModeShowPassword: TButton
          Left = 547
          Top = 74
          Width = 50
          Height = 23
          Anchors = [akTop, akRight]
          Caption = 'Show'
          TabOrder = 2
          OnClick = btnShipModeShowPasswordClick
        end
      end
      object TbsLogrithm: TTabSheet
        Caption = 'Logrithm'
        ImageIndex = 10
        object grpLogrithm: TGroupBox
          Left = 0
          Top = 0
          Width = 618
          Height = 129
          Align = alTop
          Caption = 'Logrithm V1'
          TabOrder = 0
          object EdtLogrithmEndpoint: TEdit
            Left = 88
            Top = 24
            Width = 517
            Height = 23
            TabOrder = 0
            OnExit = EdtLogrithmEndpointExit
          end
          object EdtLogrithmAPIKey: TEdit
            Left = 88
            Top = 53
            Width = 517
            Height = 23
            TabOrder = 1
            OnExit = EdtLogrithmAPIKeyExit
          end
          object ChkLogrithmAddVehicle: TCheckBox
            Left = 88
            Top = 82
            Width = 97
            Height = 17
            Caption = 'Add vehicle'
            TabOrder = 2
            OnClick = ChkLogrithmAddVehicleClick
          end
          object ChkLogrithmUpdateTares: TCheckBox
            Left = 88
            Top = 105
            Width = 97
            Height = 17
            Caption = 'Update Tares'
            TabOrder = 3
            OnClick = ChkLogrithmUpdateTaresClick
          end
        end
        object grpLogrithmV2: TGroupBox
          Left = 0
          Top = 129
          Width = 618
          Height = 120
          Align = alTop
          Caption = 'Logrithm V2'
          TabOrder = 1
          object EdtLogrithmV2Endpoint: TEdit
            Left = 88
            Top = 24
            Width = 517
            Height = 23
            TabOrder = 0
            OnExit = EdtLogrithmV2EndpointExit
          end
          object EdtLogrithmV2APIKey: TEdit
            Left = 88
            Top = 53
            Width = 515
            Height = 23
            TabOrder = 1
            OnExit = EdtLogrithmV2APIKeyExit
          end
          object EdtLogrithmV2CompanyID: TEdit
            Left = 88
            Top = 82
            Width = 97
            Height = 23
            TabOrder = 2
            OnExit = EdtLogrithmV2CompanyIDExit
          end
        end
      end
    end
    object grpSiteGrps: TGroupBox
      AlignWithMargins = True
      Left = 6
      Top = 22
      Width = 616
      Height = 62
      Margins.Left = 5
      Margins.Top = 0
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Site Group'
      Padding.Left = 10
      Padding.Top = 10
      Padding.Right = 10
      Padding.Bottom = 10
      TabOrder = 0
      ExplicitWidth = 610
      object btnAddGrp: TButton
        Left = 12
        Top = 27
        Width = 30
        Height = 23
        Align = alLeft
        Caption = '+'
        TabOrder = 0
        OnClick = btnAddGrpClick
      end
      object btnRemoveGrp: TButton
        Left = 42
        Top = 27
        Width = 30
        Height = 23
        Align = alLeft
        Caption = '-'
        TabOrder = 1
        OnClick = btnRemoveGrpClick
      end
      object CmbConfigGroups: TComboBox
        Left = 72
        Top = 27
        Width = 540
        Height = 23
        Align = alLeft
        TabOrder = 2
        OnChange = CmbConfigGroupsChange
      end
    end
  end
  object PnlTop: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 409
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 628
    object LblGeneral: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 626
      Height = 15
      Align = alTop
      Caption = 'General:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 47
    end
    object LnkPrivateFolder: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 350
      Width = 626
      Height = 15
      Cursor = crHandPoint
      Margins.Bottom = 6
      Align = alTop
      Caption = 'Open private folder'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = LnkPrivateFolderClick
      ExplicitWidth = 102
    end
    object ChkStartWithWindows: TCheckBox
      AlignWithMargins = True
      Left = 4
      Top = 374
      Width = 626
      Height = 25
      Align = alTop
      Caption = 'Start with Windows'
      TabOrder = 2
      OnClick = ChkStartWithWindowsClick
      ExplicitWidth = 620
    end
    object GrpDatabase: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 25
      Width = 626
      Height = 56
      Align = alTop
      Caption = 'Database'
      TabOrder = 0
      ExplicitWidth = 620
      DesignSize = (
        626
        56)
      object EdtDBName: TEdit
        Left = 96
        Top = 21
        Width = 498
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        ReadOnly = True
        TabOrder = 0
        Text = 'EdtDBName'
        ExplicitWidth = 492
      end
    end
    object GrpHTTP: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 87
      Width = 626
      Height = 146
      Align = alTop
      Caption = 'HTTP server settings'
      TabOrder = 1
      ExplicitWidth = 620
      DesignSize = (
        626
        146)
      object EdtAppSupportUserame: TEdit
        Left = 96
        Top = 24
        Width = 412
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnExit = EdtAppSupportUserameExit
        ExplicitWidth = 406
      end
      object EdtAppSupportPassword: TEdit
        Left = 96
        Top = 85
        Width = 412
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        OnExit = EdtAppSupportPasswordExit
        ExplicitWidth = 406
      end
      object EdtBackupRootFolder: TEdit
        Left = 96
        Top = 53
        Width = 412
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnExit = EdtBackupRootFolderExit
        ExplicitWidth = 406
      end
      object BtnBackupRootFolder: TButton
        Left = 514
        Top = 81
        Width = 23
        Height = 23
        Anchors = [akTop, akRight]
        Caption = '...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = BtnBackupRootFolderClick
        ExplicitLeft = 508
      end
      object ChkAppSupportEnabled: TCheckBox
        Left = 203
        Top = 110
        Width = 182
        Height = 25
        Caption = 'App Support Server Enabled'
        TabOrder = 5
        OnClick = ChkAppSupportEnabledClick
      end
      object ChkConfigEnabled: TCheckBox
        Left = 18
        Top = 110
        Width = 179
        Height = 25
        Caption = 'Legacy Config Server Enabled'
        TabOrder = 4
        OnClick = ChkConfigEnabledClick
      end
    end
    object ChkStatusReport: TCheckBox
      Left = 384
      Top = 201
      Width = 137
      Height = 16
      Caption = 'Status Report Enabled'
      TabOrder = 3
      OnClick = ChkStatusReportEnabledClick
    end
    object GrpEmailAlert: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 239
      Width = 626
      Height = 105
      Align = alTop
      Caption = 'Group Email Alert'
      TabOrder = 4
      ExplicitWidth = 620
      object StatusReportEmailAddr: TEdit
        Left = 96
        Top = 41
        Width = 206
        Height = 23
        TabOrder = 0
      end
    end
  end
  object DlgKeyFile: TFileOpenDialog
    FavoriteLinks = <>
    FileName = 'C:\Temp\BackupKey.key'
    FileTypes = <
      item
        DisplayName = 'Key files (*.key)'
        FileMask = '*.key'
      end>
    Options = []
    Title = 'Select the private key file'
    Left = 600
    Top = 8
  end
  object Query: TFDQuery
    Left = 312
    Top = 436
  end
end
