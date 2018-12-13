object FormMain: TFormMain
  Left = 263
  Top = 107
  Width = 639
  Height = 488
  Caption = 'wap gateway'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object EWMLFilename: TEdit
    Left = 48
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'GET /'
  end
  object Button1: TButton
    Left = 184
    Top = 24
    Width = 75
    Height = 25
    Caption = '&HTTP'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 229
    Width = 631
    Height = 225
    Align = alBottom
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    Lines.Strings = (
      'Accept-Charset: utf-8, iso-8859-5, unicode-1-1;q=0.8'
      
        'Accept: text/vnd.wap.wml, text/plain; q=0.5, text/html, text/x-d' +
        'vi; q=0.8, text/x-c'
      'Content-Type: text/plain'
      'Content-Range: bytes 0-499/1025')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Button3: TButton
    Left = 192
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Memo2: TMemo
    Left = 0
    Top = 140
    Width = 631
    Height = 89
    Align = alBottom
    Lines.Strings = (
      'Memo2')
    TabOrder = 4
  end
  object Button2: TButton
    Left = 408
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Client read'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Button4: TButton
    Left = 24
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 424
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object IdUDPServer1: TIdUDPServer
    Active = True
    Bindings = <>
    DefaultPort = 9200
    OnUDPRead = IdUDPServer1UDPRead
    Left = 376
  end
  object IdUDPClient1: TIdUDPClient
    Host = 'localhost'
    Port = 9200
    Left = 376
    Top = 32
  end
end
