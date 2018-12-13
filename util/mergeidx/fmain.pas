unit
  fmain;
(*##*)
(*******************************************************************************
*                                                                             *
*   F  M  A  I  N                                                              *
*                                                                             *
*   Copyright © 2006 Andrei Ivanov. All rights reserved.                       *
*   Part of mergeidx project                                                  *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Feb 08 2006                                                 *
*   Last revision: Feb 08 2006                                                *
*   Lines        :                                                             *
*   History      :                                                            *
*                                                                              *
*                                                                             *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  jclUnicode, zlib,
  AbDfBase, AbDfEnc, AbDfDec,
  marc, IdxStruct, mergeidxfiles, ComCtrls, ExtCtrls,
  customxml, xmlParse, xhtml, wmlurl, htmlPrsr;

type
  TFormMain = class(TForm)
    EFiles: TEdit;
    BWords: TButton;
    LBWords: TListBox;
    LBIndexes: TListBox;
    BDirs: TButton;
    BStart: TButton;
    BStop: TButton;
    Timer1: TTimer;
    GBProgress: TGroupBox;
    MResult: TMemo;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    procedure BWordsClick(Sender: TObject);
    procedure BDirsClick(Sender: TObject);
    procedure BStartClick(Sender: TObject);
    procedure BStopClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure LBWordsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FMergeIndexesCustomThread: TMergeIndexesCustomThread;
    procedure OnReport();
    procedure ThreadDone(Sender: TObject);

  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  FileCtrl, util1;

procedure TFormMain.BWordsClick(Sender: TObject);
var
  fn: String;
begin
  fn:= ConcatPath(EFiles.Text, 'idx.wrd', '\');
  // fn:= ReplaceExt('wrd', fn);
  LBWords.Items.Clear;
  LoadWrdFile2List(fn, LBWords.Items, True);
end;

procedure TFormMain.BDirsClick(Sender: TObject);
var
  fn: String;
  sl: TStrings;
begin
  fn:= ExtractFilePath(EFiles.Text);
  sl:= TStringList.Create;
  SearchIdxFiles(fn, True, sl);
  LBIndexes.Items.Assign(sl);
  sl.Free;
end;

procedure TFormMain.OnReport;
begin
  with FMergeIndexesCustomThread do begin
    if Length(ProgressState) > 0 then begin
      MResult.Lines.Add(ProgressState);
    end;
    if (Progress < ProgressCount)
    then ProgressBar1.Position:= ProgressBar1.Max * Progress div ProgressCount
    else ProgressBar1.Position:= 0;
    // Application.Title:= Format('%d/%d - %s - mkxmlidx', [APos, ASize, AMsg]);
  end;
end;

procedure TFormMain.BStartClick(Sender: TObject);
var
  dir: String;
  fn, fn2, fn3, fn4, fn5, fn6: String;
begin
  BStart.Enabled:= False;
  BStop.Enabled:= True;
  GBProgress.Visible:= True;
  GBProgress.Enabled:= True;
  MResult.Clear;
  dir:= EFiles.Text;
  if not DirExists(dir)
  then dir:= ExtractFilePath(dir);

  fn:= util1.ConcatPath(dir, 'idx', '\');
  fn2:= ReplaceExt('wrd', fn);
  fn3:= ReplaceExt('fld', fn);
  fn4:= ReplaceExt('loc', fn);
  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);

//-----------------------------------------DELETE!------------------------------

  DeleteFile(fn2);
  DeleteFile(fn3);
  DeleteFile(fn4);
  DeleteFile(fn5);
  DeleteFile(fn6);
  
//-----------------------------------------DELETE!------------------------------

  FMergeIndexesCustomThread:= TMergeIndexesCustomThread.Create(True,
    dir, OnReport);
  with FMergeIndexesCustomThread do begin
    FreeOnTerminate:= True;
    OnTerminate:= ThreadDone;
    Resume;
    Timer1.Enabled:= True;
  end;
end;

procedure TFormMain.ThreadDone(Sender: TObject);
begin
  Timer1.Enabled:= False;
  BStop.Enabled:= False;
  BStart.Enabled:= True;
  GBProgress.Enabled:= False;
  FMergeIndexesCustomThread:= Nil;
end;

procedure TFormMain.BStopClick(Sender: TObject);
begin
  if Assigned(FMergeIndexesCustomThread)
  then FMergeIndexesCustomThread.Terminate;
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  if Assigned(FMergeIndexesCustomThread) then with FMergeIndexesCustomThread do begin
    GBProgress.Caption:= 'Progress: ' + ProgressState;
    if ProgressCount > Progress
    then ProgressBar1.Position:= ProgressBar1.Max * Progress div ProgressCount;
    Caption:= FileCtrl.MinimizeName(ProgressState, Canvas, 256);
  end;
end;

procedure TFormMain.LBWordsClick(Sender: TObject);
begin
  with PWordRec(LBWords.Items.Objects[LBWords.ItemIndex])^ do begin
    LBWords.Hint:= Format('%8x - %8x', [h.fs, h.ff]);
  end;
end;


function WalkFolder_Unzlib(const AFN: String; AEnv: TObject = Nil): Boolean;
var
  fn: String;
  l: Integer;
  z: TDecompressionStream;
  strm, outstrm: TStream;
  b: array[0..1023] of Byte;
begin
  Result:= True;
  fn:= AFn;
  l:= Length(AFn);
  if L < 0
  then Exit;
  if not (fn[l] in ['e', 'E'])
  then Exit;
  Delete(fn, l, 1);
  strm:= TFileStream.Create(AFN, fmOpenRead);
  outstrm:= TFileStream.Create(fn, fmCreate);
  z:= TDecompressionStream.Create(strm);
  repeat
    l:= z.Read(b, SizeOf(b));
  until l < SizeOf(b);
  z.Free;
  strm.Free;
  outstrm.Free;
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  fn, bookmark, pt, fl: String;
  ws, src, srca: WideString;
  i, p, c, sp: Integer;
  encoding: Integer;
  FXHTMLCollection: TxmlElementCollection;
  e: array[0..10] of TxmlElement;
  cl: TPersistentClass;
  hauthor, author: WideString;
  pr: htmlPrsr.TSimpleHTMLParser;
  sl: TStrings;
  t: System.Text;
begin
  AssignFile(t, 't.txt');
  Rewrite(t);
  FXHTMLCollection:= TxmlElementCollection.Create(THtmContainer, Nil, wciOne);
  pr:= TSimpleHTMLParser.Create;
  SetCurrentDirectory('e:\app\lib\d1d2\Content');

  for i:= 1 to 27 do begin
    fn:= 'e:\app\lib\d1d2\Content\' + 'index' + Format('%2.2d', [i]) +  '_full.htm';
    if wmlurl.GetSrcFromURI(fn, src, bookmark, encoding) = wmlurl.umOK then begin
      FXHTMLCollection.Clear1;
      xmlParse.xmlCompileText(src, Nil, Nil, Nil,
        FXHTMLCollection.Items[0], THTMContainer);
    end;
    e[0]:= FXHTMLCollection.Items[0].NestedDescendantElement[ThtmHTML, 0];
    e[1]:= e[0].NestedDescendantElement[ThtmBody, 0];
    p:= 0;
    repeat
      e[2]:= e[1].NestedDescendantElement[ThtmP, p];
      if not Assigned(e[2]) then Break;
      e[3]:= e[2].NestedDescendantElement[ThtmA, 0];
      if not Assigned(e[3]) then begin
        Inc(p);
        Continue;
      end;
      hauthor:= Trim(e[3].Attributes.ValueByName['href']);
      e[4]:= e[3].NestedDescendantElement[TxmlPCData, 0];
      if Assigned(e[4])
      then author:= Trim(e[4].Attributes[0].Value)
      else author:= '';


      if wmlurl.GetSrcFromURI(hauthor, srca, bookmark, encoding) = wmlurl.umOK then begin
        pr.Text:= srca;
        sl:= pr.UrlNameList();
        for c:= 0 to sl.Count - 1 do begin
          pt:= Copy(hauthor, 1, Length(hauthor) - Length('index_full.htm'));
          if (Length(hauthor) > 0) and (hauthor[Length(hauthor)] = '.')
          then Delete(hauthor, Length(hauthor), 1);
          fl:= sl.Names[c];
          if (Length(fl) > 0) and (fl[Length(fl)] = '.')
          then Delete(fl, Length(fl), 1);

          if (Length(fl) > 2) and (fl[1] = '.') then begin
            repeat
              sp:= Pos('/', fl);
              if sp <= 0
              then Break;
              Delete(fl, 1, sp);
            until False;
          end;

          //fl:= ExtractFileName(fl);
          Write(t, ConcatPath(pt, fl, '/'));
          Write(t, #9);
          Write(t, author);
          Write(t, #9);
          Write(t, sl.ValueFromIndex[c]);
          Writeln(t);
        end;
        sl.Free;
      end;

      Inc(p);
    until false;
  end;
  pr.Free;
  FXHTMLCollection.Free;
  CloseFile(t);
end;

end.
