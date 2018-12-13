unit fEditText;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,
  EMemo, Menus, ComCtrls, ToolWin, ActnList;

type
  TFormEditText = class(TForm)
    PanelEditor: TPanel;
    PanelBottom: TPanel;
    BOK: TButton;
    BCancel: TButton;
    PanelTop: TPanel;
    ActionList1: TActionList;
    actEditCopy: TAction;
    actEditPaste: TAction;
    CoolBar1: TCoolBar;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure actEditTextCopyExecute(Sender: TObject);
    procedure actEditTextPasteExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    EMemo: TEMemo;
  end;

var
  FormEditText: TFormEditText;

implementation

{$R *.dfm}

procedure TFormEditText.FormCreate(Sender: TObject);
begin
  //
  EMemo:= TEMemo.Create(Self);
  with EMemo do begin
    Align:= alClient;
    Visible:= True;
    GutterOptions.ShowLineNum:= True;
    Parent:= PanelEditor;
  end;
end;

procedure TFormEditText.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TFormEditText.FormActivate(Sender: TObject);
begin
  EMemo.SetFocus;
end;

procedure TFormEditText.actEditTextCopyExecute(Sender: TObject);
begin
  EMemo.CopyToClipboard;
end;

procedure TFormEditText.actEditTextPasteExecute(Sender: TObject);
begin
  EMemo.PasteFromClipboard;
end;

end.
