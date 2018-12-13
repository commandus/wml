object Form1: TForm1
  Left = 273
  Top = 134
  Width = 571
  Height = 486
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 282
    Top = 0
    Width = 281
    Height = 459
    Align = alRight
    OnMouseMove = Image1MouseMove
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 38
    Height = 13
    Caption = 'XML file'
  end
  object Button1: TButton
    Left = 168
    Top = 24
    Width = 97
    Height = 25
    Caption = 'Extract Images'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 56
    Top = 24
    Width = 97
    Height = 25
    Caption = 'XML->Component'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 16
    Top = 424
    Width = 105
    Height = 25
    Caption = 'Test component'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Memo1: TMemo
    Left = 16
    Top = 56
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
  end
  object EXMLFileName: TEdit
    Left = 56
    Top = 2
    Width = 201
    Height = 21
    TabOrder = 4
    Text = 'p8167.xml'
  end
  object Button4: TButton
    Left = 257
    Top = 3
    Width = 17
    Height = 19
    Caption = '...'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 32
    Top = 248
    Width = 137
    Height = 25
    Caption = 'Button5'
    TabOrder = 6
    OnClick = Button5Click
  end
  object emx: TXMLDocument
    FileName = 'C:\src\wml\em\R289LX.xml'
    Left = 280
    DOMVendorDesc = 'MSXML'
  end
  object IdBase64Decoder1: TIdBase64Decoder
    Left = 216
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.xml'
    Filter = 'xml(*.xml)|*.xml'
    Left = 312
  end
end
