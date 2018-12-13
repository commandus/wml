object FormEditorOptions: TFormEditorOptions
  Left = 222
  Top = 102
  BorderStyle = bsDialog
  Caption = 'Editor options'
  ClientHeight = 375
  ClientWidth = 491
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PC1: TPageControl
    Left = 0
    Top = 0
    Width = 491
    Height = 334
    ActivePage = TSDisplay
    Align = alClient
    TabOrder = 0
    object TSDisplay: TTabSheet
      Caption = '&Display'
      object GBMarginAndGutter: TGroupBox
        Left = 8
        Top = 8
        Width = 209
        Height = 120
        Caption = 'Margin and gutter'
        TabOrder = 0
        object CBVisibleRightMargin: TCheckBox
          Left = 16
          Top = 24
          Width = 129
          Height = 17
          Caption = '&Visible right margin'
          TabOrder = 0
        end
        object CBVisibleGutter: TCheckBox
          Left = 16
          Top = 56
          Width = 97
          Height = 17
          Caption = 'Visible &gutter'
          TabOrder = 3
        end
        object ERightMargin: TEdit
          Left = 144
          Top = 24
          Width = 33
          Height = 21
          TabOrder = 1
          Text = '80'
        end
        object EGutterWidth: TEdit
          Left = 144
          Top = 56
          Width = 33
          Height = 21
          TabOrder = 4
          Text = '26'
        end
        object UDRightMargin: TUpDown
          Left = 177
          Top = 24
          Width = 16
          Height = 21
          Associate = ERightMargin
          Min = 1
          Max = 512
          Position = 80
          TabOrder = 2
        end
        object UDGutterWidth: TUpDown
          Left = 177
          Top = 56
          Width = 16
          Height = 21
          Associate = EGutterWidth
          Min = 18
          Position = 26
          TabOrder = 5
        end
        object CBNumerateLines: TCheckBox
          Left = 16
          Top = 88
          Width = 97
          Height = 17
          Hint = 'Show line'#39's numbers'
          Caption = '&Numerate lines'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
        end
      end
      object GBFont: TGroupBox
        Left = 8
        Top = 144
        Width = 209
        Height = 142
        Caption = 'Fonts'
        TabOrder = 2
        object LFont: TLabel
          Left = 8
          Top = 24
          Width = 48
          Height = 13
          Caption = 'Editor &font'
        end
        object LSample: TLabel
          Left = 8
          Top = 112
          Width = 35
          Height = 13
          Caption = 'Sample'
        end
        object LSize: TLabel
          Left = 110
          Top = 50
          Width = 20
          Height = 13
          Caption = '&Size'
        end
        object BFont: TButton
          Left = 90
          Top = 72
          Width = 101
          Height = 24
          Hint = 'Select font'
          Caption = 'Select font'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = BFontClick
        end
        object EFontSample: TEdit
          Left = 62
          Top = 104
          Width = 129
          Height = 24
          BevelInner = bvNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentColor = True
          ParentFont = False
          TabOrder = 5
          Text = 'Sample'
        end
        object CBUseBoldTags: TCheckBox
          Left = 8
          Top = 50
          Width = 97
          Height = 17
          Caption = '&Bold tags'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object CBFontName: TComboBox
          Left = 64
          Top = 16
          Width = 129
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = CBFontChange
        end
        object EFontSize: TEdit
          Left = 142
          Top = 42
          Width = 33
          Height = 21
          TabOrder = 2
          Text = '10'
          OnChange = CBFontChange
        end
        object UDFontSize: TUpDown
          Left = 175
          Top = 42
          Width = 16
          Height = 21
          Associate = EFontSize
          Min = 4
          Max = 64
          Position = 10
          TabOrder = 3
        end
      end
      object GBBlockIndent: TGroupBox
        Left = 232
        Top = 8
        Width = 217
        Height = 120
        Caption = 'Block indent'
        TabOrder = 1
        object LBlockIndent: TLabel
          Left = 8
          Top = 24
          Width = 59
          Height = 13
          Caption = 'Block i&ndent'
        end
        object EBlockIndent: TEdit
          Left = 136
          Top = 24
          Width = 33
          Height = 21
          TabOrder = 0
          Text = '2'
        end
        object UDBlockIndent: TUpDown
          Left = 169
          Top = 24
          Width = 16
          Height = 21
          Associate = EBlockIndent
          Max = 8
          Position = 2
          TabOrder = 1
        end
      end
      object GBAutoComplete: TGroupBox
        Left = 232
        Top = 144
        Width = 217
        Height = 142
        Caption = 'Auto complete tag'
        TabOrder = 3
        object LCompileModifiedAtDelay: TLabel
          Left = 27
          Top = 64
          Width = 118
          Height = 13
          Caption = 'when you are stop typing'
        end
        object LAutoCompleteSec: TLabel
          Left = 162
          Top = 19
          Width = 17
          Height = 13
          Caption = 'sec'
        end
        object CBAutoComplete: TCheckBox
          Left = 8
          Top = 18
          Width = 105
          Height = 17
          Caption = '&Auto complete'
          TabOrder = 0
        end
        object CBCompileModifiedAtDelay: TCheckBox
          Left = 8
          Top = 48
          Width = 193
          Height = 17
          Hint = 
            'Compile modified source when you are stop typing. If not checked' +
            ', source is compiled when you are exit editor window'
          Caption = 'Re&compile modified source'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object CBCompileBeforeSave: TCheckBox
          Left = 8
          Top = 80
          Width = 193
          Height = 17
          Hint = 'Compile modified source before save source to disk'
          Caption = 'Re&compile before save file'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object UDAutoComplete: TUpDown
          Left = 145
          Top = 16
          Width = 16
          Height = 21
          Associate = EAutoComplete
          Min = 1
          Max = 15
          Position = 3
          TabOrder = 2
        end
        object EAutoComplete: TEdit
          Left = 112
          Top = 16
          Width = 33
          Height = 21
          TabOrder = 1
          Text = '3'
        end
      end
    end
    object TSColor: TTabSheet
      Caption = '&Color'
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 297
        Height = 289
        Caption = 'Editor'
        TabOrder = 0
        object PanelColorBottom: TPanel
          Left = 2
          Top = 136
          Width = 293
          Height = 151
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
        end
        object PanelColorTop: TPanel
          Left = 2
          Top = 15
          Width = 293
          Height = 121
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object Label1: TLabel
            Left = 4
            Top = 0
            Width = 38
            Height = 13
            Caption = '&Element'
          end
          object Label2: TLabel
            Left = 132
            Top = 0
            Width = 24
            Height = 13
            Caption = '&Color'
          end
          object LBElements: TListBox
            Left = 4
            Top = 16
            Width = 121
            Height = 105
            ItemHeight = 13
            Items.Strings = (
              'Text'
              'Text background'
              'Selection'
              'Selection background'
              'Hyperlink'
              'Hyperlink background'
              'Right edge')
            TabOrder = 0
            OnClick = LBElementsClick
          end
          object ColorBox1: TColorBox
            Left = 132
            Top = 16
            Width = 145
            Height = 22
            AutoDropDown = True
            Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbPrettyNames]
            ItemHeight = 16
            TabOrder = 1
            OnChange = ColorBox1Change
          end
        end
      end
    end
    object TSHighlight: TTabSheet
      Caption = 'Code &highlighting'
      ImageIndex = 2
      object GBhighlighting: TGroupBox
        Left = 8
        Top = 8
        Width = 457
        Height = 89
        Caption = 'Syntax &highlighting'
        TabOrder = 0
        object CBHighlightTag: TCheckBox
          Left = 16
          Top = 24
          Width = 185
          Height = 17
          Caption = '&Tags'
          TabOrder = 0
        end
        object CBHighlightSTag: TCheckBox
          Left = 16
          Top = 48
          Width = 249
          Height = 17
          Caption = '&Special tags'
          Enabled = False
          TabOrder = 1
        end
        object CBHighlightEntity: TCheckBox
          Left = 200
          Top = 24
          Width = 249
          Height = 17
          Caption = '&Entities'
          TabOrder = 2
        end
      end
    end
    object TSHighlightAutoConversion: TTabSheet
      Caption = 'Auto &conversion'
      ImageIndex = 3
      object GBLoading: TGroupBox
        Left = 8
        Top = 8
        Width = 457
        Height = 89
        Caption = 'On &loading document'
        TabOrder = 0
        object CBEntities2Char: TCheckBox
          Left = 16
          Top = 24
          Width = 417
          Height = 17
          Hint = 'Replace entities to characters except quot, lt, gt and so ones'
          Caption = 'Replace &entities to characters'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object CBLoadRefCharset: TCheckBox
          Left = 16
          Top = 48
          Width = 417
          Height = 17
          Hint = 'In WML entities are referenced with respect to the Unicode. '
          Caption = 
            'Numeric entities are referenced with respect to the document enc' +
            'oding (charset). '
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 112
        Width = 457
        Height = 89
        Caption = 'On &saving document'
        TabOrder = 1
        object CBChar2Entities: TCheckBox
          Left = 16
          Top = 24
          Width = 417
          Height = 17
          Hint = 'Replace all non-ASCII characters to entities'
          Caption = 'Replace all non-&ASCII characters to entities'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object CBSaveRefCharset: TCheckBox
          Left = 16
          Top = 48
          Width = 417
          Height = 17
          Hint = 'In WML entities are referenced with respect to the Unicode. '
          Caption = 
            'Numeric entities are referenced with respect to the document enc' +
            'oding (charset). '
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 334
    Width = 491
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOk: TButton
      Left = 320
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
