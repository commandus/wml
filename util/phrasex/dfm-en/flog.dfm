object FormLog: TFormLog
  Left = 0
  Top = 0
  HelpType = htKeyword
  HelpKeyword = 'log'
  BorderStyle = bsSizeToolWin
  Caption = 'Log'
  ClientHeight = 294
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmExplicit
  Position = poDefaultSizeOnly
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MLog: TMemo
    Left = 0
    Top = 0
    Width = 426
    Height = 294
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PopupMenu = pmLog
    TabOrder = 0
    WordWrap = False
  end
  object pmLog: TPopupMenu
    Left = 40
    Top = 16
    object Clearlog1: TMenuItem
      Action = actClearLog
    end
    object Showdatatobesent1: TMenuItem
      Action = actSetVerbose
    end
  end
  object ActionList1: TActionList
    Left = 8
    Top = 16
    object actClearLog: TAction
      Caption = 'Clear log'
      Hint = 'Clear log'
      ShortCut = 24665
      OnExecute = actClearLogExecute
    end
    object actSetVerbose: TAction
      Caption = 'Show data to be sent'
      Hint = 'Show more detailed information|data sent to the client'
      ShortCut = 24662
      OnExecute = actSetVerboseExecute
    end
  end
end
