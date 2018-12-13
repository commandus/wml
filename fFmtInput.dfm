object FormFormatUserInput: TFormFormatUserInput
  Left = 274
  Top = 93
  BorderStyle = bsDialog
  Caption = 'Format for user input'
  ClientHeight = 509
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 470
    Height = 468
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 152
      Top = 24
      Width = 207
      Height = 13
      Caption = 'Select &format character, specify number of it'
    end
    object Label2: TLabel
      Left = 40
      Top = 24
      Width = 81
      Height = 13
      Caption = 'Characters &count'
    end
    object Label3: TLabel
      Left = 272
      Top = 408
      Width = 72
      Height = 13
      Caption = 'User input &Test'
    end
    object Label4: TLabel
      Left = 40
      Top = 408
      Width = 100
      Height = 13
      Caption = '&Format for user unput'
    end
    object Label5: TLabel
      Left = 40
      Top = 200
      Width = 180
      Height = 13
      Caption = 'select one format string of the &samples'
    end
    object Label6: TLabel
      Left = 16
      Top = 200
      Width = 19
      Height = 13
      Caption = 'OR'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object CBCount: TComboBox
      Left = 40
      Top = 40
      Width = 97
      Height = 21
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 0
      Items.Strings = (
        '* - any number'
        ''
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9')
    end
    object BAdd: TButton
      Left = 344
      Top = 192
      Width = 105
      Height = 25
      Hint = 'Add format character to format string'
      Caption = '&Add'
      TabOrder = 2
      OnClick = BAddClick
    end
    object ETest: TEdit
      Left = 272
      Top = 424
      Width = 169
      Height = 21
      TabOrder = 7
    end
    object CBFormat: TComboBox
      Left = 40
      Top = 424
      Width = 177
      Height = 21
      Hint = 'Format for user input'
      ItemHeight = 13
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Items.Strings = (
        ''
        '*A'
        '*N'
        '*M'
        '*X'
        '\$'
        '\.'
        '\:'
        '\%'
        '\@')
    end
    object BReplace: TButton
      Left = 344
      Top = 368
      Width = 105
      Height = 25
      Hint = 'Replace edit control "format for user input"'
      Caption = '&Replace'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = BReplaceClick
    end
    object LVFormats: TListView
      Left = 152
      Top = 224
      Width = 297
      Height = 129
      Hint = 'Double click to replace edit control "format for user input"'
      Columns = <
        item
          Caption = 'Name'
          Width = 80
        end
        item
          Caption = 'Sample'
          Width = 100
        end
        item
          Caption = 'Format'
          Width = 100
        end>
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      ViewStyle = vsReport
      OnDblClick = BReplaceClick
    end
    object LBCountry: TListBox
      Left = 40
      Top = 224
      Width = 113
      Height = 129
      Hint = 'Select appropriate category of format strings'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = LBCountryClick
    end
    object LVFormat: TListView
      Left = 152
      Top = 40
      Width = 297
      Height = 137
      Columns = <
        item
          Caption = 'Char'
        end
        item
          Caption = 'Description'
          Width = 243
        end>
      Items.Data = {
        FA0100000800000000000000FFFFFFFFFFFFFFFF010000000000000001412D75
        707065726361736520616C7068616265746963206F722070756E637475617469
        6F6E2063686172616374657200000000FFFFFFFFFFFFFFFF0100000000000000
        01612D6C6F7765726361736520616C7068616265746963206F722070756E6374
        756174696F6E2063686172616374657200000000FFFFFFFFFFFFFFFF01000000
        00000000014E116E756D657269632063686172616374657200000000FFFFFFFF
        FFFFFFFF0100000000000000015817616E792075707065726361736520636861
        72616374657200000000FFFFFFFFFFFFFFFF0100000000000000017817616E79
        206C6F776572636173652063686172616374657200000000FFFFFFFFFFFFFFFF
        0100000000000000014D34616E7920636861726163746572202864656661756C
        742C206D6179206265206368616E67656420746F207570706572636173652900
        000000FFFFFFFFFFFFFFFF0100000000000000016D2B616E7920636861726163
        74657220286D6179206265206368616E67656420746F206C6F77657263617365
        2900000000FFFFFFFFFFFFFFFF0100000000000000025C4331446973706C6179
        7320746865206E6578742063686172616374657220432C20696E207468652065
        6E747279206669656C64FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = BAddClick
    end
  end
  object PanelBtn: TPanel
    Left = 0
    Top = 468
    Width = 470
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOk: TButton
      Left = 240
      Top = 8
      Width = 75
      Height = 25
      Caption = 'O&k'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object BCancel: TButton
      Left = 336
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
