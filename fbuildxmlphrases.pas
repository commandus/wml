unit
  fbuildxmlphrases;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  b  u  i  l  d  x  m  l  p  h  r  a  s  e  s                             *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language editor utility functions                         *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Nov 01 2003                                                 *
*   Last fix     : Nov 25 2003                                                *
*   Lines        : 265                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileCtrl,
  xmlidx, ActnList, XPStyleActnCtrls, ActnMan, StdCtrls, ComCtrls;

type
  TFormCreatePhrases = class(TForm)
    EIndexFileName: TEdit;
    BStart: TButton;
    ActionManager1: TActionManager;
    actStartCreateIdx: TAction;
    actSearch: TAction;
    BStop: TButton;
    GBOptions: TGroupBox;
    LIndexFileName: TLabel;
    BBrowse: TButton;
    GBProgress: TGroupBox;
    MResult: TMemo;
    ProgressBar1: TProgressBar;
    actStop: TAction;
    BClose: TButton;
    BHelp: TButton;
    CBCaseSensitive: TCheckBox;
    CBOutputUnicode: TCheckBox;
    CBSkipAttributes: TCheckBox;
    MSkipElements: TMemo;
    Label1: TLabel;

    procedure actStartCreateIdxExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BBrowseClick(Sender: TObject);
    procedure BHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    StartTime,
    FinishTime: TDateTime;
    FxmlPhraseThread: TxmlPhraseThread;
    FstrmFinalPhrase: TStream;
    FRootFolder: String;
    procedure SetRootFolder(const ARootFolder: String);
    procedure Report();
    procedure ThreadDone(Sender: TObject);
  public
    { Public declarations }
    Extensions: TStrings;
    property RootFolder: String read FRootFolder write SetRootFolder;
  end;

var
  FormCreatePhrases: TFormCreatePhrases;

implementation

{$R *.dfm}

uses
  util1, fDockBase;

const
  LISTING_FILE_NOT_FOUND = 'Listing of documents to create phrases not found.'#13#10+
    'All files in %s folder ''ll be included in list file'#13#10 +
    'Press Yes to include all subdirectoirs in folder, No to skip them.';
var
  IDX_cnt: Integer;
  idxfn, rootf: String;

function WalkFolder_CreatePhrase(const FN: String; AEnv: TObject = Nil): Boolean;
var
  ext: String;
begin
  ext:= ExtractFileExt(fn);
  if (not Assigned(FormCreatePhrases)) or (FormCreatePhrases.Extensions.IndexOf(ext) >= 0) then begin
    util1.String2File(idxfn, IntToStr(IDX_cnt) + #9 + util1.DiffPath(rootf, Fn) + #13#10);
    Inc(IDX_cnt);
  end;
  Result:= True;
end;

function CreateIdxFile(const Afn: String; ARecursive: Boolean): Boolean;
var
  fn2: String;
begin
  IDX_cnt:= 1;
  idxfn:= Afn;
  rootf:= ExtractFilePath(Afn);

  fn2:= ReplaceExt('phr', Afn);
  DeleteFile(AFn);
  DeleteFile(fn2);

  util1.String2File(AFn, DateTimeToStr(Now) + #13#10);
  util1.Walk_Tree('*.*', rootf, 0, ARecursive, WalkFolder_CreatePhrase, Nil);
end;

procedure TFormCreatePhrases.actStartCreateIdxExecute(Sender: TObject);
var
  sl: TStrings;
  recursive: Boolean;
  fn, fn2: String;
begin
  StartTime:= Now;
  BStart.Enabled:= False;
  GBProgress.Visible:= True;
  GBProgress.Enabled:= True;

  fn:= util1.ConcatPath(RootFolder, EIndexFileName.Text, '\');
  if not FileExists(fn) then begin
    // create new one
    if Length(fn) = 0
    then fn:= fDockBase.SRCH_DIR_DESC_FILE;
    case Dialogs.MessageDlg(Format(LISTING_FILE_NOT_FOUND, [fn]), mtInformation, mbYesNoCancel, 0) of
      mrCancel: Exit;
      mrNo: recursive:= False;
      mrYes: recursive:= True;
    end;
    CreateIdxFile(fn, recursive);
  end;
  fn2:= ReplaceExt('phr', fn);

  FstrmFinalPhrase:= TFileStream.Create(fn2, fmCreate);

  sl:= xmlIdx.LoadListOfFiles(fn);

  SetCurrentDir(ExtractFilePath(fn));

  BStop.Enabled:= True;
  FxmlPhraseThread:= TxmlPhraseThread.Create(True, CBCaseSensitive.Checked,
    CBOutputUnicode.Checked, CBSkipAttributes.Checked, MSkipElements.Lines, sl.CommaText, FstrmFinalPhrase, Report);
  with FxmlPhraseThread do begin
    FreeOnTerminate:= True;
    OnTerminate:= ThreadDone;
    Resume;
  end;

  sl.Free;
  // FIndexateThread.Priority:= TThreadPriority(CBPriority.ItemIndex);
  // CBPriority.ItemIndex:= Integer(FIndexateThread.Priority);
end;

procedure TFormCreatePhrases.actStopExecute(Sender: TObject);
begin
  if Assigned(FxmlPhraseThread)
  then FxmlPhraseThread.Terminate;
end;

procedure TFormCreatePhrases.ThreadDone(Sender: TObject);
begin
  FstrmFinalPhrase.Free;

  FinishTime:= Now;
  MResult.Lines.Add('Elapsed time: ' + TimeToStr(FinishTime - StartTime));

  BStop.Enabled:= False;
  BStart.Enabled:= True;
  GBProgress.Enabled:= False;
  FxmlPhraseThread:= Nil;
end;

procedure TFormCreatePhrases.Report();
begin
  with FxmlPhraseThread do begin
    if Length(ProgressState) > 0 then begin
      MResult.Lines.Add(ProgressState);
    end;
    if (Progress < ProgressCount)
    then ProgressBar1.Position:= 100 * Progress div ProgressCount;
    // Application.Title:= Format('%d/%d - %s - mkxmlidx', [APos, ASize, AMsg]);
  end;
end;

procedure TFormCreatePhrases.SetRootFolder(const ARootFolder: String);
var
  l: Integer;
begin
  FRootFolder:= ARootFolder;
  l:= Length(FRootFolder);
  if (l > 0) and (not (FRootFolder[l] in ['\', '/']))
  then FRootFolder:= FRootFolder + '\';
  Self.Caption:= 'Build phrases list ' + FileCtrl.MinimizeName(FRootFolder, Canvas, 128);
end;

procedure TFormCreatePhrases.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCreatePhrases.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:= (not Assigned(FxmlPhraseThread));
end;

procedure TFormCreatePhrases.BBrowseClick(Sender: TObject);
var
  s: String;
  DlgOpen: TOpenDialog;
begin
  //
  s:= ExpandFileName(ConcatPath(RootFolder, EIndexFileName.Text, '\'));

  DlgOpen:= TOpenDialog.Create(Nil);
  with DlgOpen do begin
    Title:= 'Select document listing to build list of phrases';
    InitialDir:= ExtractFilePath(s);
    FileName:= s;
    HistoryList.Add(s);
    DefaultExt:= 'lst';
    Filter := 'Listing of files to build phrases(*.lst)|*.lst|All files (*.*)|*.*';
    FilterIndex:= 1;
    if Execute then begin
      s:= FileName;
      EIndexFileName.Text:= util1.DiffPath(RootFolder, s);
    end;
    Free;
  end;
end;

procedure TFormCreatePhrases.BHelpClick(Sender: TObject);
var
  p: TPoint;
begin
  // help screen
  p.X:= 0;
  p.Y:= 0;
  formDockBase.ShowHelpByIndex(p, Nil, 'cmdtoolsbuildphrases');
end;

procedure TFormCreatePhrases.FormCreate(Sender: TObject);
begin
  Extensions:= TStringList.Create;
end;

procedure TFormCreatePhrases.FormDestroy(Sender: TObject);
begin
  Extensions.Free;
end;

end.
