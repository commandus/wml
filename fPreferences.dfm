object FormPreferences: TFormPreferences
  Left = 318
  Top = 66
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 435
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PCPref: TPageControl
    Left = 0
    Top = 0
    Width = 504
    Height = 394
    ActivePage = TSGeneral
    Align = alClient
    TabOrder = 0
    object TSGeneral: TTabSheet
      Caption = '&General'
      object GBImage: TGroupBox
        Left = 40
        Top = 16
        Width = 441
        Height = 81
        Caption = 'wbmp &images'
        TabOrder = 0
        object LDitherMode: TLabel
          Left = 8
          Top = 20
          Width = 115
          Height = 13
          Caption = 'Default &dithering method'
        end
        object CBDefaultDitherMode: TComboBox
          Left = 136
          Top = 16
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Nearest color matching'
          Items.Strings = (
            'Nearest color matching'
            'Floyd Steinberg Error Diffusion'
            'Stucki Error Diffusion'
            'Sierra Error Diffusion'
            'Jarvis, Judice & Ninke Error Diffusion'
            'Stevenson & Arche Error Diffusion'
            'Burkes Error Diffusion')
        end
        object CBStretchPreview: TCheckBox
          Left = 136
          Top = 48
          Width = 145
          Height = 17
          Hint = 'Stretch preview area of the converted wbmp image'
          Caption = '&Stretch preview area'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
      object GBCharset: TGroupBox
        Left = 40
        Top = 104
        Width = 441
        Height = 97
        Caption = 'Encode &compiled .wmlc with '
        TabOrder = 1
        object LCharSet: TLabel
          Left = 16
          Top = 24
          Width = 63
          Height = 13
          Caption = 'Character s&et'
        end
        object LCharSetDesc: TLabel
          Left = 136
          Top = 48
          Width = 140
          Height = 13
          Caption = 'utf-8 is strongly recommended'
        end
        object LWBXMLVersion: TLabel
          Left = 16
          Top = 64
          Width = 77
          Height = 13
          Caption = 'WBXML &version'
        end
        object Label2: TLabel
          Left = 180
          Top = 68
          Width = 95
          Height = 13
          Caption = '1.3 is recommended'
        end
        object CBCharSet: TComboBox
          Left = 136
          Top = 24
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 13
          TabOrder = 0
          Text = 'utf-8'
          Items.Strings = (
            'big5'
            'iso-10646-ucs-2'
            'iso-8859-1'
            'iso-8859-2'
            'iso-8859-3'
            'iso-8859-4'
            'iso-8859-5'
            'iso-8859-6'
            'iso-8859-7'
            'iso-8859-8'
            'iso-8859-9'
            'shift_JIS'
            'us-ascii'
            'utf-8')
        end
        object CBWBXMLVersion: TComboBox
          Left = 136
          Top = 64
          Width = 41
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 3
          TabOrder = 1
          Text = '1.3'
          Items.Strings = (
            '1.0'
            '1.1'
            '1.2'
            '1.3')
        end
      end
      object GBExtensions: TGroupBox
        Left = 40
        Top = 208
        Width = 441
        Height = 153
        Caption = 'language e&xtensions'
        TabOrder = 2
        object LUDLFolder: TLabel
          Left = 8
          Top = 36
          Width = 142
          Height = 13
          Caption = '&Data access object files folder'
        end
        object LDbDrvFileName: TLabel
          Left = 8
          Top = 100
          Width = 128
          Height = 13
          Caption = 'Data access DLL &file name'
        end
        object CBServerSide: TCheckBox
          Left = 8
          Top = 16
          Width = 289
          Height = 17
          Caption = '&include serverside element in editor'
          TabOrder = 0
        end
        object EUDLFolder: TEdit
          Left = 8
          Top = 52
          Width = 273
          Height = 21
          TabOrder = 1
        end
        object BUDLFolder: TButton
          Left = 281
          Top = 52
          Width = 19
          Height = 21
          Hint = 'Select folder where .UDL files resides'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = BUDLFolderClick
        end
        object BShowUDLFolder: TButton
          Left = 301
          Top = 52
          Width = 19
          Height = 21
          Hint = 'Show .UDL files in selected folder'
          Caption = '>'
          Enabled = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object EDbDrvFileName: TEdit
          Left = 8
          Top = 116
          Width = 273
          Height = 21
          TabOrder = 5
        end
        object BDbDrvFileName: TButton
          Left = 281
          Top = 116
          Width = 19
          Height = 21
          Hint = 'Select folder where .UDL files resides'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          OnClick = BDbDrvFileNameClick
        end
        object CBDbDrvEnable: TCheckBox
          Left = 8
          Top = 80
          Width = 313
          Height = 17
          Caption = '&parse serverside elements in preview window'
          TabOrder = 4
        end
      end
    end
    object TSLanguages: TTabSheet
      Caption = '&Languages support'
      ImageIndex = 1
      object LLanguage: TLabel
        Left = 16
        Top = 48
        Width = 53
        Height = 13
        Caption = 'L&anguages'
      end
      object CLBLanguages: TCheckListBox
        Left = 16
        Top = 64
        Width = 465
        Height = 273
        Columns = 3
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 13
        ParentFont = False
        TabOrder = 0
      end
      object MLanguage: TMemo
        Left = 16
        Top = 16
        Width = 337
        Height = 33
        BorderStyle = bsNone
        Lines.Strings = (
          
            'From the list below, select the countries which you would like p' +
            'rogram '
          'to view when you edit xml:lang on then in property editor.')
        ParentColor = True
        ReadOnly = True
        TabOrder = 1
      end
    end
    object TSLIT: TTabSheet
      Caption = 'Open &eBook generation'
      ImageIndex = 2
      object GBGenerator: TGroupBox
        Left = 40
        Top = 16
        Width = 353
        Height = 81
        Caption = '&LIT generator'
        TabOrder = 0
        object CBLitgenGenAutoStart: TCheckBox
          Left = 8
          Top = 16
          Width = 337
          Height = 17
          Caption = 
            '&Automatically start generation when .LIT compiler window appear' +
            's'
          TabOrder = 0
        end
      end
      object GBTempFolder: TGroupBox
        Left = 40
        Top = 112
        Width = 353
        Height = 129
        Caption = '&Temporary files folder'
        TabOrder = 1
        object Memo1: TMemo
          Left = 8
          Top = 16
          Width = 337
          Height = 33
          BorderStyle = bsNone
          Lines.Strings = (
            
              'Temporary files folder used by Internet Explorer extension- '#39'apo' +
              'o editor'#39' '
            'band to keep downloaded texts and pictures passed to the editor')
          ParentColor = True
          ReadOnly = True
          TabOrder = 0
        end
        object ETempFolder: TEdit
          Left = 8
          Top = 48
          Width = 289
          Height = 21
          TabOrder = 1
        end
        object BTempFolder: TButton
          Left = 297
          Top = 48
          Width = 19
          Height = 21
          Hint = 'Select folder where temporary files must resides'
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = BTempFolderClick
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 394
    Width = 504
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOk: TButton
      Left = 312
      Top = 8
      Width = 75
      Height = 25
      Caption = 'O&k'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object BCancel: TButton
      Left = 408
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
