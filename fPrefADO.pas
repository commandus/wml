unit fPrefADO;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus, ShellAPI;

type
  TFormADO = class(TForm)
    PanelBottom: TPanel;
    PanelTop: TPanel;
    BOk: TButton;
    BCancel: TButton;
    BAdd: TButton;
    BDelete: TButton;
    BProp: TButton;

    LVAdo: TListView;

    pmViewAdd: TMenuItem;
    pmViewDelete: TMenuItem;
    pmViewProp: TMenuItem;
    pmViewD1: TMenuItem;
    pmView: TPopupMenu;
    pmViewIcon: TMenuItem;
    pmViewList: TMenuItem;
    pmViewReport: TMenuItem;
    pmViewSmallicon: TMenuItem;
    LFolder: TLabel;
    EUDLFolder: TEdit;
    BUDLFolder: TButton;
    BShowUDLFolder: TButton;
    pmViewD2: TMenuItem;
    pmViewMakeACopyOfSelectedFile: TMenuItem;

    procedure pmViewIconClick(Sender: TObject);
    procedure pmViewListClick(Sender: TObject);
    procedure pmViewReportClick(Sender: TObject);
    procedure pmViewSmalliconClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BUDLFolderClick(Sender: TObject);
    procedure EUDLFolderKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BShowUDLFolderClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BAddClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
    procedure BPropClick(Sender: TObject);
    procedure BOkClick(Sender: TObject);
  private
    { Private declarations }
    FFirstTime: Boolean;
  public
    { Public declarations }
  end;

var
  FormADO: TFormADO;

implementation

uses
  fileCtrl, util1, fDockBase, dm;

{$R *.dfm}

procedure FillListView(const AFolder: String; ALV: TListView);
var
  li: TListItem;
  SearchRec: TSearchRec;

  procedure AddItem;
  begin
    li:= ALV.Items.Add;
    with li do begin
      Caption:= SearchRec.Name;
      SubItems.Add(DateTimeToStr(FileDateToDateTime(SearchRec.Time)));
      SubItems.Add(IntToStr(SearchRec.Size));
      ImageIndex:= 41;
    end;
  end;

begin
  ALV.Clear;

  if FindFirst(ConcatPath(AFolder, '*.udl', '\'), faAnyFile xor faDirectory, SearchRec) = 0 then begin
    AddItem;
    while FindNext(SearchRec) = 0
    do AddItem;
  end;
{$IFDEF VER80}
  FindClose(SearchRec);
{$ELSE}
  Windows.FindClose(SearchRec.FindHandle);
{$ENDIF}
end;

procedure TFormADO.pmViewIconClick(Sender: TObject);
begin
  LVAdo.ViewStyle:= vsIcon;
end;

procedure TFormADO.pmViewListClick(Sender: TObject);
begin
  LVAdo.ViewStyle:= vsList;
end;

procedure TFormADO.pmViewReportClick(Sender: TObject);
begin
  LVAdo.ViewStyle:= vsReport;
end;

procedure TFormADO.pmViewSmalliconClick(Sender: TObject);
begin
  LVAdo.ViewStyle:= vsSmallIcon;
end;

procedure TFormADO.FormCreate(Sender: TObject);
var
  s: String;
  c: TListColumn;
begin
  FFirstTime:= True;
  s:= util1.DiffPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]],
    ExpandFileName(FormDockBase.FParameters.Values[ParameterNames[ID_UDLFolder]]));
  if (Length(s) > 0) and (s[1] = '\')
  then Delete(s, 1, 1);
  EUDLFolder.Text:= s;

  with LVADO.Columns do begin
    c:= Add();
    c.Caption:= 'File name';
    c.AutoSize:= True;
    c:= Add();
    c.Caption:= 'Time stamp';
    c.AutoSize:= True;
    c:= Add();
    c.Caption:= 'Size';
    c.AutoSize:= True;    
  end;
end;

procedure TFormADO.BUDLFolderClick(Sender: TObject);
var
  s: String;
  root: WideString;
begin
  //
  s:= ExpandFileName(EUDLFolder.Text);
  root:= ''; // FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]];
  if SelectDirectory('Select data access object files folder', root, s) then begin
    s:= util1.DiffPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], s);
    if (Length(s) > 0) and (s[1] = '\')
    then Delete(s, 1, 1); 
    EUDLFolder.Text:= s;
  end;
  // refresh
  BShowUDLFolderClick(Self);
end;

procedure TFormADO.EUDLFolderKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: BShowUDLFolderClick(Self);
  end;
end;

procedure TFormADO.BShowUDLFolderClick(Sender: TObject);
begin
  //
  FillListView(EUDLFolder.Text, LVADO);
end;

procedure TFormADO.FormActivate(Sender: TObject);
begin
  if FFirstTime then begin
    BShowUDLFolderClick(Self);
    FFirstTime:= False;
  end;
end;

procedure TFormADO.BAddClick(Sender: TObject);
var
  fn, fnWOext: String;
  no: Integer;
  s: String;
begin
  // add
  if Assigned(LVAdo.Selected) then begin
    fn:= ConcatPath(EUDLFolder.Text,
      LVAdo.Selected.Caption);
    s:= util1.File2String(fn);
  end else begin
    fn:= ConcatPath(EUDLFolder.Text, 'New_file_');
    s:= '';
  end;

  fnWOext:= fn;
  no:= Pos('.udl', fnWOext);
  if no > 0 then Delete(fnWOext, no, 4);
  no:= 1;
  while FileExists(fn) do begin
    fn:= fnWOext +IntToHex(no, 2) + '.udl';
    Inc(no);
    if no > $FF
    then Exit;
  end;
  try
    util1.String2File(fn, s);
  except
  end;
  // reflect changes
  BShowUDLFolderClick(Self);
end;

procedure TFormADO.BDeleteClick(Sender: TObject);
var
  fn: String;
begin
  // delete
  if Assigned(LVAdo.Selected) then with LVAdo.Selected do begin
    fn:= ConcatPath(EUDLFolder.Text,
      LVAdo.Selected.Caption);
    if Dialogs.MessageDlg(Format('Are you sure to delete file %s?', [fn]),
      mtConfirmation, [mbOK, mbCancel], 0) = mrOK then begin
      try
        DeleteFile(fn);
      except
      end;
      // reflect changes
      BShowUDLFolderClick(Self);
    end;
  end;
end;

procedure TFormADO.BPropClick(Sender: TObject);
var
  fn: String;
begin
  // properties
  if Assigned(LVAdo.Selected) then with LVAdo.Selected do begin
    fn:= ConcatPath(EUDLFolder.Text,
      LVAdo.Selected.Caption);
    if ShellAPI.ShellExecute(0, 'open', PChar(fn), Nil, Nil, SW_SHOWNORMAL) <= 32 then begin
      ShowMessage('Error: Explorer file extension ".UDL" is not registered.'#13#10);
    end;
  end;
end;

procedure TFormADO.BOkClick(Sender: TObject);
begin
  // set default
  FormDockBase.FParameters.Values[ParameterNames[ID_UDLFolder]]:= EUDLFolder.Text;
end;

end.
