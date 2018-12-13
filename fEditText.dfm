object FormEditText: TFormEditText
  Left = 243
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Edit text'
  ClientHeight = 246
  ClientWidth = 384
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PanelEditor: TPanel
    Left = 0
    Top = 25
    Width = 384
    Height = 183
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 208
    Width = 384
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BOK: TButton
      Left = 180
      Top = 6
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
    object BCancel: TButton
      Left = 284
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 384
    Height = 25
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 2
    object CoolBar1: TCoolBar
      Left = 0
      Top = 0
      Width = 384
      Height = 25
      AutoSize = True
      Bands = <
        item
          Control = ToolBar
          ImageIndex = -1
          MinHeight = 21
          Width = 380
        end>
      object ToolBar: TToolBar
        Left = 9
        Top = 0
        Width = 367
        Height = 21
        AutoSize = True
        ButtonHeight = 21
        ButtonWidth = 34
        Caption = 'ToolBar'
        EdgeBorders = []
        Flat = True
        ShowCaptions = True
        TabOrder = 0
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Action = actEditCopy
        end
        object ToolButton2: TToolButton
          Left = 34
          Top = 0
          Action = actEditPaste
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 288
    Top = 44
    object actEditCopy: TAction
      Category = 'Edit'
      Caption = 'Copy'
      Hint = 'Copy text'
      ShortCut = 16451
      OnExecute = actEditTextCopyExecute
    end
    object actEditPaste: TAction
      Category = 'Edit'
      Caption = 'Paste'
      Hint = 'Paste text'
      ShortCut = 16470
      OnExecute = actEditTextPasteExecute
    end
  end
end
