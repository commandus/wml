object FormSearching: TFormSearching
  Left = 572
  Top = 619
  Width = 449
  Height = 111
  BorderStyle = bsSizeToolWin
  Caption = 'Searching'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PanelIndicator: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 36
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LabelIndicator: TLabel
      Left = 8
      Top = 8
      Width = 57
      Height = 13
      Caption = 'Searching...'
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 36
    Width = 441
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BCancel: TButton
      Left = 184
      Top = 8
      Width = 75
      Height = 25
      Hint = 'Press button to stop searching'
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = BCancelClick
    end
  end
end
