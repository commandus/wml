unit
  fbuildxmlidx;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  b  u  i  l  d  x  m  l  i  d  x                                         *
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
  xmlidx, ActnList, XPStyleActnCtrls, ActnMan, StdCtrls, ComCtrls, ExtCtrls;

type
  TFormCreateIndexFile = class(TForm)
    EIndexFileName: TEdit;
    BStart: TButton;
    ActionManager1: TActionManager;
    actStartCreateIdx: TAction;
    actSearch: TAction;
    BStop: TButton;
    GBOptions: TGroupBox;
    LMaxWord: TLabel;
    LShorterWord: TLabel;
    LNumberLen: TLabel;
    ENumberLen: TEdit;
    UDNumberLen: TUpDown;
    UDWordLen: TUpDown;
    EWordLen: TEdit;
    EMaxWord: TEdit;
    UDMaxWord: TUpDown;
    LShorter1: TLabel;
    LWords1: TLabel;
    LNum1: TLabel;
    LIndexFileName: TLabel;
    BBrowse: TButton;
    GBProgress: TGroupBox;
    ProgressBar1: TProgressBar;
    actStop: TAction;
    BClose: TButton;
    BHelp: TButton;
    Timer1: TTimer;
    MResult: TMemo;

    procedure actStartCreateIdxExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BBrowseClick(Sender: TObject);
    procedure BHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    StartTime,
    FinishTime: TDateTime;
    FIndexateThread: TxmlIndexateCustomThread;
    FstrmFinalWrd, FstrmFinalFld, FstrmFinalLoc, FstrmFinalKey, FstrmFinalTag: TStream;
    FListFile, FRootFolder: String;
    procedure SetRootFolder(const ARootFolder: String);
    procedure SetListFile(const AListFile: String);
    procedure Report();
    procedure ThreadDone(Sender: TObject);
  public
    { Public declarations }
    Extensions: TStrings;
    property ListFile: String read FListFile write SetListFile;
    property RootFolder: String read FRootFolder write SetRootFolder;
  end;

var
  FormCreateIndexFile: TFormCreateIndexFile;

implementation

{$R *.dfm}

uses
  util1, fDockBase;

const
  LISTING_FILE_NOT_FOUND = 'List of files to create index not found.'#13#10+
    'All files in %s folder ''ll be included in list file'#13#10 +
    'Press Yes to include all subdirectries in folder, No to skip them.';
var
  IDX_cnt: Integer;
  idxfn, rootf: String;

function WalkFolder_CreateIdx(const FN: String; AEnv: TObject = Nil): Boolean;
var
  ext: String;
begin
  ext:= ExtractFileExt(fn);
  if (not Assigned(FormCreateIndexFile)) or (FormCreateIndexFile.Extensions.IndexOf(ext) >= 0) then begin
    util1.String2File(idxfn, IntToStr(IDX_cnt) + #9 + util1.DiffPath(rootf, Fn) + #13#10);
    Inc(IDX_cnt);
  end;
  Result:= True;
end;

function CreateIdxFile(const Afn: String; ARecursive: Boolean): Boolean;
var
  fn2, fn3, fn4, fn5, fn6: String;
begin
  IDX_cnt:= 1;
  idxfn:= Afn;
  rootf:= ExtractFilePath(Afn);

  fn2:= ReplaceExt('wrd', Afn);
  fn3:= ReplaceExt('fld', Afn);
  fn4:= ReplaceExt('loc', Afn);
  fn5:= ReplaceExt('tag', Afn);
  fn6:= ReplaceExt('key', Afn);

  DeleteFile(AFn);
  DeleteFile(fn2);
  DeleteFile(fn3);
  DeleteFile(fn4);
  DeleteFile(fn5);
  DeleteFile(fn6);

  util1.String2File(AFn, DateTimeToStr(Now) + #13#10);
  util1.Walk_Tree('*.*', rootf, 0, ARecursive, WalkFolder_CreateIdx, Nil);
end;

procedure TFormCreateIndexFile.actStartCreateIdxExecute(Sender: TObject);
var
  sl: TStrings;
  recursive: Boolean;
  fn, fn2, fn3, fn4, fn5, fn6: String;
begin
  StartTime:= Now;
  BStart.Enabled:= False;
  GBProgress.Visible:= True;
  GBProgress.Enabled:= True;

  // fn:= util1.ConcatPath(RootFolder, ListFile, '\');
  fn:= ListFile;
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
  fn2:= ReplaceExt('wrd', fn);
  fn3:= ReplaceExt('fld', fn);
  fn4:= ReplaceExt('loc', fn);
  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);

  FstrmFinalWrd:= TFileStream.Create(fn2, fmCreate);
  FstrmFinalFld:= TFileStream.Create(fn3, fmCreate);
  FstrmFinalLoc:= TFileStream.Create(fn4, fmCreate);
  FstrmFinalTag:= TFileStream.Create(fn5, fmCreate);
  FstrmFinalKey:= TFileStream.Create(fn6, fmCreate);

  sl:= xmlIdx.LoadListOfFiles(fn);

  SetCurrentDir(ExtractFilePath(fn));

  BStop.Enabled:= True;
  FIndexateThread:= TxmlIndexateCustomThread.Create(True,
    UDMaxWord.Position * 1000, UDWordLen.Position, UDNumberLen.Position,
    sl,
    FstrmFinalWrd, FstrmFinalFld, FstrmFinalLoc, FstrmFinalKey, FstrmFinalTag, Report);
  with FIndexateThread do begin
    FreeOnTerminate:= True;
    OnTerminate:= ThreadDone;
    Resume;
    Timer1.Enabled:= True;
  end;

  sl.Free;
  // FIndexateThread.Priority:= TThreadPriority(CBPriority.ItemIndex);
  // CBPriority.ItemIndex:= Integer(FIndexateThread.Priority);
end;

procedure TFormCreateIndexFile.actStopExecute(Sender: TObject);
begin
  if Assigned(FIndexateThread)
  then FIndexateThread.Terminate;
end;

procedure TFormCreateIndexFile.ThreadDone(Sender: TObject);
begin
  Timer1.Enabled:= False;
  FstrmFinalWrd.Free;
  FstrmFinalFld.Free;
  FstrmFinalLoc.Free;
  FstrmFinalTag.Free;
  FstrmFinalKey.Free;

  FinishTime:= Now;
  MResult.Lines.Add('Elapsed time: ' + TimeToStr(FinishTime - StartTime));
  MResult.Lines.Add('Words: ' + IntToStr(FIndexateThread.SLWord.Count));
  MResult.Lines.Add('Locations: ' + IntToStr(FIndexateThread.WF2Loc.Count));

  BStop.Enabled:= False;
  BStart.Enabled:= True;
  GBProgress.Enabled:= False;
  FIndexateThread:= Nil;
end;

procedure TFormCreateIndexFile.Report();
begin
  with FIndexateThread do begin
    if Length(ProgressState) > 0 then begin
      MResult.Lines.Add(ProgressState);
    end;
    if (Progress < ProgressCount)
    then ProgressBar1.Position:= ProgressBar1.Max * Progress div ProgressCount;
    // Application.Title:= Format('%d/%d - %s - mkxmlidx', [APos, ASize, AMsg]);
  end;
end;

procedure TFormCreateIndexFile.SetRootFolder(const ARootFolder: String);
var
  l: Integer;
begin
  FRootFolder:= ARootFolder;
  l:= Length(FRootFolder);
  if (l > 0) and (not (FRootFolder[l] in ['\', '/']))
  then FRootFolder:= FRootFolder + '\';
  Self.Caption:= 'Build index ' + FileCtrl.MinimizeName(FRootFolder, Canvas, 128);
end;

procedure TFormCreateIndexFile.SetListFile(const AListFile: String);
begin
  FListFile:= ExpandFileName(ConcatPath(RootFolder, AListFile, '\'));
  EIndexFileName.Text:= util1.DiffPath(RootFolder, FListFile);
end;

procedure TFormCreateIndexFile.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCreateIndexFile.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:= (not Assigned(FIndexateThread));
end;

procedure TFormCreateIndexFile.BBrowseClick(Sender: TObject);
var
  s: String;
  DlgOpen: TOpenDialog;
begin
  //
  s:= ExpandFileName(ConcatPath(RootFolder, EIndexFileName.Text, '\'));

  DlgOpen:= TOpenDialog.Create(Nil);
  with DlgOpen do begin
    Title:= 'Select files listing to build index';
    InitialDir:= ExtractFilePath(s);
    FileName:= s;
    HistoryList.Add(s);
    DefaultExt:= 'lst';
    Filter := 'Listing of files to build index(*.lst)|*.lst|All files (*.*)|*.*';
    FilterIndex:= 1;
    if Execute then begin
      ListFile:= FileName;
    end;
    Free;
  end;
end;

procedure TFormCreateIndexFile.BHelpClick(Sender: TObject);
var
  p: TPoint;
begin
  // help screen
  p.X:= 0;
  p.Y:= 0;
  formDockBase.ShowHelpByIndex(p, Nil, 'cmdtoolsbuildindex');
end;

procedure TFormCreateIndexFile.FormCreate(Sender: TObject);
begin
  Extensions:= TStringList.Create;
end;

procedure TFormCreateIndexFile.FormDestroy(Sender: TObject);
begin
  Extensions.Free;
end;

procedure TFormCreateIndexFile.Timer1Timer(Sender: TObject);
begin
  if Assigned(FIndexateThread) then with FIndexateThread do begin
    GBProgress.Caption:= 'Progress: ' + ProgressState;
    if ProgressCount > Progress
    then ProgressBar1.Position:= ProgressBar1.Max * Progress div ProgressCount;
  end;
end;

end.
