object FormFormatSource: TFormFormatSource
  Left = 164
  Top = 173
  BorderStyle = bsDialog
  Caption = 'Format source'
  ClientHeight = 208
  ClientWidth = 302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object BOk: TButton
    Left = 117
    Top = 172
    Width = 75
    Height = 25
    Caption = '&Format'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object BCancel: TButton
    Left = 211
    Top = 172
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 41
    Width = 302
    Height = 120
    Align = alTop
    Caption = '&Options'
    TabOrder = 2
    object LBlockIndent: TLabel
      Left = 27
      Top = 72
      Width = 59
      Height = 13
      Hint = 'Block indent in symbols'
      Caption = '&Block indent'
      ParentShowHint = False
      ShowHint = True
    end
    object CBRightMargin: TCheckBox
      Left = 8
      Top = 24
      Width = 193
      Height = 17
      Hint = 'Align source at right margin'
      Caption = 'Set right &margin'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 0
      OnClick = CBRightMarginClick
      OnKeyDown = CBRightMarginKeyDown
    end
    object ERightMargin: TEdit
      Left = 204
      Top = 22
      Width = 37
      Height = 21
      TabOrder = 2
      Text = '80'
    end
    object UDRightMargin: TUpDown
      Left = 241
      Top = 22
      Width = 16
      Height = 21
      Associate = ERightMargin
      Max = 32767
      Position = 80
      TabOrder = 3
    end
    object CBCompressSpaces: TCheckBox
      Left = 8
      Top = 48
      Width = 193
      Height = 17
      Hint = 
        'delete double white spaces, lead and terminal empty lines in all' +
        ' texts, excluding <pre>'
      Caption = '&Compress spaces in PCDATA'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 1
    end
    object EBlockIndent: TEdit
      Left = 204
      Top = 69
      Width = 37
      Height = 21
      TabOrder = 4
      Text = '2'
    end
    object UDBlockIndent: TUpDown
      Left = 241
      Top = 69
      Width = 16
      Height = 21
      Associate = EBlockIndent
      Position = 2
      TabOrder = 5
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object L1: TLabel
      Left = 16
      Top = 8
      Width = 160
      Height = 13
      Caption = 'Incorrect elements will be deleted.'
    end
    object L2: TLabel
      Left = 16
      Top = 24
      Width = 101
      Height = 13
      Caption = 'Format source "%s"?'#39
    end
  end
end
