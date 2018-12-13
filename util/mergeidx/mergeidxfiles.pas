unit
  mergeidxfiles;
(*##*)
(*******************************************************************************
*                                                                             *
*   M  E  R  G  E  I  D  X  F  I  L  E  S                                      *
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
{$DEFINE IGNOREFLD}
interface

uses
  SysUtils, Windows, Classes, jclUnicode,
  marc, IdxStruct;

type
  TIdxSet32 = set of 0..31; // == Cardinal, Pointer

  TIndexItem = class(TPersistent)
  private
  public
    HasTextIdx: Boolean;
    Dir: String;
    strmWrd, { output stream, must be opened }
    strmFld,
    strmLoc,
    strmKey,
    strmTag: TStream;
    FTextIdx: Text;
    IdxOrder: Cardinal;
    LocOffset: Cardinal;
    LocCount: Cardinal;
    KeyOffset,
    KeyCount: Cardinal;
    WrdIndex,
    WrdCount: Cardinal;
    constructor Create(AOrder: Cardinal; var ALocOffsetTotal, AKeyTotal, AKeyOffsetTotal: Cardinal; const ADir: String);
    destructor Destroy; override;
  end;

  TMergeIndexesCustomThread = class(TCustomProgressThread)
  private
    FFileList: TStrings;
    FKeyAccumulator: Cardinal; // .key file for accumulator is not created, so remember here

    KeyLocSizeAcc,
    locOffsetTotal,
    KeyTotal: Cardinal; // KeyTtal is used, KeyLocSizeAcc and locOffsetTotal - none
    CurWrd: Cardinal;
    IdxItems: array of TIndexItem;
    FWrdIdx: array[0..31] of TIndexItem; // array of input indexes
    FWrdIdxCount: Integer; // count of indexes in FWrdIdx array, e.g. FWrdIdxCount = 2 means FWrdIdx[0] and FWrdIdx[1] ara valuable
    FCurTime: TDateTime;
    Fsortfl: TFld2LocItems;
    TempAccIdxDir: String;
    function IterateWord(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;
    function IterateCreateSL(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;
    procedure QuickSort(L, R: Integer);
    procedure MergeWords(AIndex0, AIndex1: Integer);
    procedure SortWords;
    procedure StoreLoc;
    procedure StoreLst(AIndex: Cardinal; var AReccount: Cardinal);
    procedure StoreKey(AIndex: Cardinal; var ADirofs, ADataofs: Cardinal);
    procedure StoreMergedLst(AIndex0, AIndex1: Cardinal);
    procedure StoreMergedKey(AIndex0, AIndex1: Cardinal);
    procedure MoveIdxAccumulator;
    procedure Open2IdxFiles(AFileNo1, AFileNo2: Integer);
    procedure OpenAllIdxFiles;
    procedure OpenLstFiles;
    procedure RenameAccumulatorToIndex;
  protected
    FstrmFinalWrd, { output stream, must be opened }
    FstrmFinalFld,
    FstrmFinalLoc,
    FstrmFinalKey,
    FstrmFinalTag: TStream;
    FTextFinalIdx: Text;
    FDir: String;
    procedure Sort;
    procedure Execute; override;
    procedure FldLocal2Global(AIdxOrder: Cardinal; var AFld: Word);
  public
    SLWord: THashWordList;
    WF2Loc: TWordFld2LocFileList;
    constructor Create(ASuspended: Boolean; ADir: String; AReportProc: TReportProc);
    destructor Destroy; override;
    // function Next: Boolean;
  end;

function LoadWrdStream2List(const AStrm: TStream; AWords: TStrings; AAllocRec: Boolean): Boolean;

function LoadWrdFile2List(const AFileName: String; AWords: TStrings; const AAllocRec: Boolean = False): Boolean;

function SearchIdxFiles(const Afn: String; ARecursive: Boolean; ADirs: TStrings): Boolean;

implementation

uses
  JclStrHashMap,
  util1;

//------------------------------ utility functions  ----------------------------

function LoadWrdStream2List(const AStrm: TStream; AWords: TStrings; AAllocRec: Boolean): Boolean;
var
  wr: TWordRec;
  i: Cardinal;
  p: PWordRec;
begin
  if AAllocRec then begin
    while (AStrm.Position < AStrm.Size) do begin
      AStrm.Read(wr, 4 + 4 + 1);
      GetMem(p, 4 + 4 + 1 + Byte(wr.w[0]));
      p^.h:= wr.h;
      p^.w[0]:= wr.w[0];
      AStrm.Read(p^.w[1], Byte(wr.w[0]));
      AWords.AddObject(UTF8ToWideString(p^.w), TObject(p));
    end;
  end else begin
    i:= 0;
    while (AStrm.Position < AStrm.Size) do begin
      AStrm.Read(wr, 4 + 4 + 1);
      AStrm.Read(wr.w[1], Byte(wr.w[0]));
      AWords.AddObject(UTF8ToWideString(wr.w), TObject(i));
      Inc(i);
    end;
  end;
end;

function LoadWrdFile2List(const AFileName: String; AWords: TStrings; const AAllocRec: Boolean = False): Boolean;
var
  strm: TStream;
begin
  strm:= TFileStream.Create(AFileName, fmOpenRead);
  Result:= LoadWrdStream2List(strm, AWords, AAllocRec);
  strm.Free;
end;

function WalkFolder_SearchIdxFiles(const AFN: String; AEnv: TObject = Nil): Boolean;
var
  fn, fn2, fn3, fn4, fn5, fn6: String;
begin
  fn:= util1.ConcatPath(AFn, 'idx', '\');
  fn2:= ReplaceExt('wrd', fn);
  fn3:= ReplaceExt('fld', fn);
  fn4:= ReplaceExt('loc', fn);
  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);

  if FileExists(fn2) and FileExists(fn3) and FileExists(fn4) then begin
    TStrings(AEnv).AddObject(Afn, Nil);
  end;
  Result:= True;
end;

function SearchIdxFiles(const Afn: String; ARecursive: Boolean; ADirs: TStrings): Boolean;
var
  rootf: String;
begin
  rootf:= ExtractFilePath(Afn);
  util1.Walk_DirTree(rootf, WalkFolder_SearchIdxFiles, ADirs);
end;

function WrdCalcWords(AWrdStrm: TStream): Cardinal;
var
  wr: TWordRec;
begin
  Result:= 0;
  AWrdStrm.Position:= 0;
  while AWrdStrm.Position < AWrdStrm.Size do begin
    AWrdStrm.ReadBuffer(wr, 4 + 4 + 1);
    AWrdStrm.Read(wr.w[1], Byte(wr.w[0]));
    Inc(Result);
  end;
end;

//-------------------------- TIndexItem ----------------------------------------

constructor TIndexItem.Create(AOrder: Cardinal; var ALocOffsetTotal, AKeyTotal, AKeyOffsetTotal: Cardinal; const ADir: String);
var
  fn, fn2, fn3, fn4, fn5, fn6, fn7: String;
  l: Integer;
begin
  inherited Create;
  Dir:= ADir;
  l:= Length(Dir);
  if (L > 0) and (Dir[L] <> '\')
  then Dir:= Dir + '\';
  
  fn:= util1.ConcatPath(ADir, 'idx', '\');
  fn2:= ReplaceExt('wrd', fn);
  fn3:= ReplaceExt('fld', fn);
  fn4:= ReplaceExt('loc', fn);
  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);
  fn7:= ReplaceExt('lst', fn);

  strmWrd:= TFileStream.Create(fn2, fmOpenRead);
  strmFld:= TFileStream.Create(fn3, fmOpenRead);
  strmLoc:= TFileStream.Create(fn4, fmOpenRead);
  strmTag:= TFileStream.Create(fn5, fmOpenRead);
  strmKey:= TFileStream.Create(fn6, fmOpenRead);

  if FileExists(fn7) then begin
    AssignFile(FTextIdx, fn7);
    Reset(FTextIdx);
    HasTextIdx:= True;
  end else HasTextIdx:= False;
  IdxOrder:= AOrder;
  LocOffset:= ALocOffsetTotal;
  LocCount:= strmLoc.Size div 4;

  if strmKey.Size >= 4
  then strmKey.ReadBuffer(KeyCount, 4)
  else KeyCount:= 0;
  WrdIndex:= 0;

  // remember offset of key (files, records)
  KeyOffset:= AKeyTotal;
  // increment to next index
  Inc(AKeyTotal, KeyCount);
  // increment to next index
  Inc(ALocOffsetTotal, LocCount);
  // 1. size of data is offset for next index. Data size is file length - length desrciptor - size of directory
  Inc(AKeyOffsetTotal, strmKey.Size - (LocCount * 4) - 4);
  // 2. index now contains relative path, so szie is bigger
  Inc(AKeyOffsetTotal, LocCount * Length(Dir)); // + '\' ?
end;

destructor TIndexItem.Destroy;
begin
  strmWrd.Free;
  strmFld.Free;
  strmLoc.Free;
  strmKey.Free;
  strmTag.Free;
  if HasTextIdx then begin
    CloseFile(FTextIdx);
  end;
  inherited Destroy;
end;

// ------------------------ TMergeIndexesCustomThread --------------------------

constructor TMergeIndexesCustomThread.Create(ASuspended: Boolean; ADir: String; AReportProc: TReportProc);
var
  i: Integer;
  fn, fn2, fn3, fn4, fn5, fn6, fn7,
  fn22, fn23, fn24: String;
begin
  FreeOnTerminate:= True;
  FDir:= ADir;

  WF2Loc:= TWordFld2LocFileList.Create;
  SLWord:= THashWordList.Create;

  FCurTime:= Now;

  FFileList:= TStringList.Create;
  SearchIdxFiles(ADir, True, FFileList);
  if FFileList.Count > 0 then begin
    i:= FFileList.IndexOf(ADir);  //
    if i >= 0
    then FFileList.Delete(i);
  end;

  if FFileList.Count < 2 then begin
    raise Exception.Create('Less than 2 index files to merge.');
  end;

  if FFileList.Count > 0 then begin
    TempAccIdxDir:= FFileList[0];
  end;

  fn:= util1.ConcatPath(ADir, 'idx', '\');
  fn2:= ReplaceExt('w$$', fn);
  fn3:= ReplaceExt('f$$', fn);
  fn4:= ReplaceExt('l$$', fn);

  fn22:= ReplaceExt('wrd', fn);
  fn23:= ReplaceExt('fld', fn);
  fn24:= ReplaceExt('loc', fn);

  if (FileExists(fn2) and FileExists(fn3) and FileExists(fn4)) then begin // OR tRUE
    raise Exception.Create('Index exists already.');
  end else begin
    FstrmFinalWrd:= TFileStream.Create(fn2, fmCreate);
    FstrmFinalFld:= TFileStream.Create(fn3, fmCreate);
    FstrmFinalLoc:= TFileStream.Create(fn4, fmCreate);
  end;

  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);
  fn7:= ReplaceExt('lst', fn);

  // create an empty files. Re-creates them in OpenLstFiles before storing values
  FstrmFinalTag:= TFileStream.Create(fn5, fmCreate);
  FstrmFinalTag.Free;
  FstrmFinalKey:= TFileStream.Create(fn6, fmCreate);
  FstrmFinalKey.Free;
  AssignFile(FTextFinalIdx, fn7);
  Rewrite(FTextFinalIdx);
  CloseFile(FTextFinalIdx);

  CurWrd:= 0;
  inherited Create(ASuspended, AReportProc);
end;

destructor TMergeIndexesCustomThread.Destroy;
var
  i: Integer;
begin
  for i:= 0 to Length(IdxItems) - 1 do begin
    IdxItems[i].Free;
  end;
  SetLength(IdxItems, 0);
  if Assigned(SLWord) then begin
    SLWord.Iterate(Nil, Iterate_FreeMem);
    SLWord.Free;
  end;
  WF2Loc.Free;

  FstrmFinalWrd.Free;
  FstrmFinalFld.Free;
  FstrmFinalLoc.Free;

  FstrmFinalKey.Free;
  FstrmFinalTag.Free;
  CloseFile(FTextFinalIdx);

  FFileList.Free;
  inherited Destroy;
end;

procedure TMergeIndexesCustomThread.OpenLstFiles;
var
  fn, fn4, fn5, fn6, fn7: String;
begin
  fn:= util1.ConcatPath(FDir, 'idx', '\');
  fn5:= ReplaceExt('tag', fn);
  fn6:= ReplaceExt('key', fn);
  fn7:= ReplaceExt('lst', fn);

  FstrmFinalTag:= TFileStream.Create(fn5, fmCreate);
  FstrmFinalKey:= TFileStream.Create(fn6, fmCreate);
  AssignFile(FTextFinalIdx, fn7);
  Rewrite(FTextFinalIdx);
end;

procedure TMergeIndexesCustomThread.Open2IdxFiles(AFileNo1, AFileNo2: Integer);
begin
  // accumulator of key offset
  KeyLocSizeAcc:= 0;
  // accumulator of loc count
  locOffsetTotal:= 0;
  // key count
  KeyTotal:= 0;
  SetLength(IdxItems, 2); // FFileList.Count
  IdxItems[0]:= TIndexItem.Create(0, locOffsetTotal, KeyTotal, KeyLocSizeAcc, FFileList[AFileNo1]); // after creating new TIndexItem idxofs is incremented
  if KeyTotal = 0
  then KeyTotal:= FKeyAccumulator;
  IdxItems[1]:= TIndexItem.Create(1, locOffsetTotal, KeyTotal, KeyLocSizeAcc, FFileList[AFileNo2]);
  FKeyAccumulator:= KeyTotal;
end;

procedure TMergeIndexesCustomThread.OpenAllIdxFiles;
var
  i: Integer;
begin
  // accumulator of key offset
  KeyLocSizeAcc:= 0;
  // accumulator of loc count
  locOffsetTotal:= 0;
  // key count
  KeyTotal:= 0;
  SetLength(IdxItems, FFileList.Count); // FFileList.Count

  for i:= 0 to FFileList.Count - 1 do begin
    if Pos(Uppercase(FDir), Uppercase(FFileList[i])) = 1
    then FFileList[i]:= Copy(FFileList[i], Length(FDir) + 1, MaxInt);
  end;
  SetCurrentDir(FDir);

  for i:= 0 to FFileList.Count - 1 do begin
    IdxItems[i]:= TIndexItem.Create(i, locOffsetTotal, KeyTotal, KeyLocSizeAcc, FFileList[i]); // after creating new TIndexItem idxofs is incremented
  end;
end;

procedure TMergeIndexesCustomThread.FldLocal2Global(AIdxOrder: Cardinal; var AFld: Word);
begin
  AFld:= 0;
end;

// set CurWrd, FWrdIdxCount and FWrdIdx array for CurWrd where
// CurWrd
// FWrdIdx - array of input indexes
// FWrdIdxCount - count of indexes in FWrdIdx array, e.g. FWrdIdxCount = 2 means FWrdIdx[0] and FWrdIdx[1] ara valuable
function TMergeIndexesCustomThread.IterateWord(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;
var
  wr: TWordRec;
  i: Integer;
  idx, cnt, len, sz: Cardinal;
  fld: TFldRec;
  fldStart, curFld: Cardinal;
  locStart, curLoc, cur0Loc: Cardinal;
  locdelta: Integer;
  locs: array of Cardinal;
  oldFld: Word;
begin
  Result:= True;
  with TWordBEs(APtr^) do begin
    cnt:= 0;
    FWrdIdxCount:= L;
    for i:= 0 to 31 do begin
      if (msk and (1 shl i)) > 0 then begin
        FWrdIdx[cnt]:= IdxItems[i];
        Inc(cnt);
        if cnt = L
        then Break;
      end;
    end;
    Inc(CurWrd);
    Progress:= CurWrd;

    case FWrdIdxCount of
      0: ; // it is impossible, raise exception?
      1: begin
           with FWrdIdx[0] do begin
             // rememeber where locations for entire word is stored
             locStart:= FstrmFinalLoc.Position;
             // rememeber where fields for entire word is stored
             fldStart:= FstrmFinalFld.Position;
             // repeat for each fld, starting from first field (wrd points to)
             strmFld.Position:= a[0].fs;
             // get first fld
             strmFld.ReadBuffer(fld, SizeOf(TFldRec));
             FldLocal2Global(IdxOrder, fld.fld);
             // delta between location in old fld and new fld
             locdelta:= locStart - fld.ls;
             repeat
               len:= fld.lf - fld.ls + 4;
               sz:= len div 4;
               SetLength(locs, sz);
               with strmLoc do begin
                 Position:= fld.ls;
                 ReadBuffer(locs[0], len);
               end;
               // increment each location depending on offset in a new list of all files
               for i:= 0 to sz - 1 do begin
                 Inc(locs[i], FWrdIdx[0].KeyOffset);
               end;
               // store locations
               FstrmFinalLoc.WriteBuffer(locs[0], len);      // --loc
               // increment field pointers to the locs
               fld.ls:= Integer(fld.ls) + locDelta;
               fld.lf:= Integer(fld.lf) + locDelta;
               FstrmFinalFld.WriteBuffer(fld, SizeOf(TFldRec)); // --fld

               if strmFld.Position > a[0].ff
               then Break;

               // go to the next field
               strmFld.ReadBuffer(fld, SizeOf(TFldRec));
             FldLocal2Global(IdxOrder, fld.fld);
             until False; // until last fld is pointed by wrd

             wr.h.fs:= fldStart;
             wr.h.ff:= fldStart + a[0].ff - a[0].fs;
             wr.w:= AStr;
             FstrmFinalWrd.WriteBuffer(wr, 9 + Byte(wr.w[0]));  // -- wrd
           end;
        end;
      else begin
         // word found in more than 2 indexes, so we must get fld+loc pairs and sort them first
         // prepare to sort fld-loc pairs
         // get quantity of locations
         len:= 0;
         for cnt:= 0 to FWrdIdxCount - 1 do begin
           with FWrdIdx[cnt] do begin
             // repeat for each fld, starting from first field (wrd points to)
             strmFld.Position:= a[cnt].fs;
             // get first fld
             strmFld.ReadBuffer(fld, SizeOf(TFldRec));
             FldLocal2Global(IdxOrder, fld.fld);
             repeat
               Inc(len,  (fld.lf - fld.ls + 4) div 4);

               if strmFld.Position > a[cnt].ff
               then Break;

               // go to the next field
               strmFld.ReadBuffer(fld, SizeOf(TFldRec));
               FldLocal2Global(IdxOrder, fld.fld);
             until False; // until last fld is pointed by wrd
           end; // with
         end; // for

         // set sort array size
         SetLength(Fsortfl, len);

         idx:= 0;
         // read fld-loc sort table
         for cnt:= 0 to FWrdIdxCount - 1 do begin
           with FWrdIdx[cnt] do begin
             // repeat for each fld, starting from first field (wrd points to)
             strmFld.Position:= a[cnt].fs;
             // get first fld
             strmFld.ReadBuffer(fld, SizeOf(TFldRec));
             FldLocal2Global(IdxOrder, fld.fld);
             repeat
               sz:= (fld.lf - fld.ls + 4) div 4;
               with strmLoc do begin
                 Position:= fld.ls;
                 for i:= 0 to sz - 1 do begin
                   FSortfl[idx + i].Fld:= fld.fld;     // get fld + loc to sort
                   with FSortfl[idx + i] do begin
                     ReadBuffer(Loc, 4);               // correct location stored in merging index
                     Inc(Loc, FWrdIdx[cnt].KeyOffset); // to the value in new index of all files depending on offset
                   end;
                 end;
                 Inc(idx, sz); // all loc of fld is read
               end;

               if strmFld.Position > a[cnt].ff // all fields done
               then Break;

               // go to the next field
               strmFld.ReadBuffer(fld, SizeOf(TFldRec));
             FldLocal2Global(IdxOrder, fld.fld);
             until False; // until last fld is pointed by wrd
           end; // with
         end; // for

         // sort table fld + loc
         Sort;

         // store index
         // rememeber where locations for entire word is stored
         locStart:= FstrmFinalLoc.Position;
         curLoc:= locStart; // where fld finished
         cur0Loc:= curLoc;  // where fld starts
         // fldStart - where fields for entire word is stored in new merged index
         fldStart:= FstrmFinalFld.Position;
         curFld:= fldStart;

         oldfld:= FSortfl[0].Fld;
         // store all sorted locations
         for idx:= 0 to Length(FSortfl) - 1 do begin
           // store location
           FstrmFinalLoc.WriteBuffer(FSortfl[idx].Loc, 4);      // --loc

           if FSortfl[idx].Fld <> oldfld then begin
             // increment field pointers to the locs
             fld.fld:= FSortfl[idx].Fld;
             fld.ls:= cur0Loc;
             fld.lf:= curLoc - 4;
             FstrmFinalFld.WriteBuffer(fld, SizeOf(TFldRec)); // --fld
             cur0Loc:= curLoc;
             oldfld:= FSortfl[idx].Fld;
             Inc(CurFld, SizeOf(TFldRec));
           end;

           Inc(curLoc, 4);
         end;
         // store last fld
         fld.fld:= FSortfl[FWrdIdxCount - 1].Fld;
         fld.ls:= cur0Loc;
         fld.lf:= curLoc - 4;
         FstrmFinalFld.WriteBuffer(fld, SizeOf(TFldRec)); // --fld

         // store word
         with wr, h do begin
           fs:= fldStart;  // where fields for entire word is stored in new merged index
           ff:= CurFld;
           w:= AStr;
         end;
         FstrmFinalWrd.WriteBuffer(wr, 9 + Byte(wr.w[0]));  // -- wrd
       end; // else case
    end;  // case
  end; // with
end;

function TMergeIndexesCustomThread.IterateCreateSL(AUserData: Pointer; const AStr: string; var APtr: Pointer): Boolean;
begin
  TStrings(AUserData).AddObject(AStr, APtr);
  Result:= True;
end;

procedure TMergeIndexesCustomThread.SortWords;
begin
  // sort words - we can do it later, if it is required. It is no importance.
  {
  sl:= TStringList.Create;
  SLWord.IterateMethod(FStringList, IterateCreateSL);
  with TStringList(sl) do begin
    Duplicates:= dupIgnore;
    Sorted:= True;
  end;
  sl.Free;
  }
end;

procedure TMergeIndexesCustomThread.StoreLst(AIndex: Cardinal; var AReccount: Cardinal);
var
  i: Integer;
  fofs: Cardinal;
  s: ShortString;
begin
  if Terminated then Exit;
  with IdxItems[AIndex] do begin
    for i:= 0 to KeyCount - 1 do begin
      // read directory entry
      with strmKey do begin
        Position:= 4 + (i * 4);
        ReadBuffer(fofs, 4);
        // read entry
        Position:= fofs;
        ReadBuffer(s[0], 1);
        ReadBuffer(s[1], Byte(s[0]));
      end;
      Writeln(FTextFinalIdx, AReccount, #9 + Dir + s);
      Inc(AReccount);
    end;
  end;
end;

procedure TMergeIndexesCustomThread.StoreMergedLst(AIndex0, AIndex1: Cardinal);
var
  idx, cnt: Cardinal;
  reccount: Cardinal;
begin
  if Terminated then Exit;
  cnt:= AIndex1 - AIndex0 + 1;
  Report(0, 0, 'Merge .lst files..');
  Writeln(FTextFinalIdx, DateTimeToStr(Now));

  ProgressCount:= cnt;
  reccount:= 1;
  for idx:= AIndex0 to AIndex1 do with IdxItems[idx] do begin
    Progress:= idx - AIndex0;
    ProgressState:= 'Merge .idx : ' +  IdxItems[idx].Dir  + ', .idx list count: ' + IntToStr(KeyCount);
    Report(idx - AIndex0, cnt, ProgressState);
    StoreLst(idx, reccount);
    if Terminated then Exit;
  end;
end;

procedure TMergeIndexesCustomThread.StoreMergedKey(AIndex0, AIndex1: Cardinal);
var
  idx, DataOfs, DirOfs: Cardinal;
  cnt: Integer;
begin
  if Terminated then Exit;
  cnt:= AIndex1 - AIndex0 + 1;
  Report(0, 0, 'Merge .key files..');
  if True then begin
    // KeyTotal - total qty of records in all merged indexes
    // and store as size of directory in new created .key at first dword
    with FstrmFinalKey do begin
      Position:= 0;
      WriteBuffer(KeyTotal, 4);
      // store merged directory
      // start offset
      dataofs:= KeyTotal * 4 + 4;
      dirofs:= 4;
      for idx:= 0 to cnt - 1 do with IdxItems[idx] do begin
        Progress:= idx;
        ProgressState:= 'Merge .key list: ' +  IdxItems[idx].Dir  + ', items: ' + IntToStr(IdxItems[idx].KeyCount);
        Report(idx, cnt, ProgressState);

        StoreKey(idx, DirOfs, DataOfs);

        if Terminated then Exit;
      end;
    end; // with
  end;
end;

procedure TMergeIndexesCustomThread.StoreKey(AIndex: Cardinal; var ADirofs, ADataofs: Cardinal);
var
  i: Integer;
  fofs: Cardinal;
  s: ShortString;
  len: Integer;
begin
  with IdxItems[AIndex] do begin
    for i:= 0 to KeyCount - 1 do begin
      with strmKey do begin
        strmKey.Position:= 4 + i * 4;
        ReadBuffer(fofs, 4);
        Position:= fofs;
        ReadBuffer(s[0], 1);
        ReadBuffer(s[1], Byte(s[0]));
      end;
      s:= Dir + s;
      len:= Length(s) + 1;

      with FstrmFinalKey do begin
        Position:= ADirOfs;
        WriteBuffer(ADataOfs, 4); // current offset

        Position:= ADataOfs;
        WriteBuffer(s[0], len); // current offset

      end;
      Inc(ADirOfs, 4);
      Inc(ADataOfs, len);
    end; // for
  end // with
end;

// load entire words list from each input index into hash array
// hash allocates word and structure (bit fields and array of offsets in loaded for each .wrd)
procedure TMergeIndexesCustomThread.MergeWords(AIndex0, AIndex1: Integer);
var
  i: Integer;
  idx: Cardinal;
  fofs: Cardinal;
  s: ShortString;
  len: Integer;
  cnt: Integer;
begin
  if Terminated then Exit;
  cnt:= AIndex1 - AIndex0 + 1;
  ProgressCount:= cnt;

  for idx:= AIndex0 to AIndex1 do with IdxItems[idx] do begin
    Progress:= idx - AIndex0;
    ProgressState:= 'Merge words list: ' +  IntToStr(idx);
    strmWrd.Position:= 0;
    // load input index into one hash array, each word stored in them
    // contains bit fields indicates number (idx) of .wrd index where word exists
    SLWord.LoadFromWrdStreamMax(strmWrd, idx, cnt);
    if Terminated then Exit;
  end;

  // length of new words list is SLWord.Count
  Report(cnt, cnt, 'Total ' + IntToStr(SLWord.Count) + ' words.' );
  // sort words - we can do it later, if it is required. It is no importance.
  // SortWords();
end;

procedure TMergeIndexesCustomThread.StoreLoc;
begin
  // after word lists are merged into one hash array, for each word store in hash
  // call function IterateWord which build new merged indexes
  if Terminated then Exit;
  ProgressCount:= SLWord.Count;
  CurWrd:= 0;
  SLWord.IterateMethod(Self, IterateWord);
end;

procedure TMergeIndexesCustomThread.MoveIdxAccumulator;
var
  fn, fn2, fn3, fn4,
  fn22, fn23, fn24: String;
begin
  fn:= util1.ConcatPath(FDir, 'idx', '\');
  fn2:= ReplaceExt('w$$', fn);
  fn3:= ReplaceExt('f$$', fn);
  fn4:= ReplaceExt('l$$', fn);

  fn22:= ReplaceExt('wrd', fn);
  fn23:= ReplaceExt('fld', fn);
  fn24:= ReplaceExt('loc', fn);

  FstrmFinalWrd.Free;
  FstrmFinalFld.Free;
  FstrmFinalLoc.Free;

  // close streams fn22, fn23, fn24
  IdxItems[0].Free;
  IdxItems[1].Free;

  if FileExists(fn22)
  then DeleteFile(PChar(fn22));
  if FileExists(fn23)
  then DeleteFile(PChar(fn23));
  if FileExists(fn24)
  then DeleteFile(PChar(fn24));

  RenameFile(fn2, fn22);
  RenameFile(fn3, fn23);
  RenameFile(fn4, fn24);

  FstrmFinalWrd:= TFileStream.Create(fn2, fmCreate);
  FstrmFinalFld:= TFileStream.Create(fn3, fmCreate);
  FstrmFinalLoc:= TFileStream.Create(fn4, fmCreate);
end;

procedure TMergeIndexesCustomThread.RenameAccumulatorToIndex;
var
  fn, fn2, fn3, fn4,
  fn22, fn23, fn24: String;
begin
  fn:= util1.ConcatPath(FDir, 'idx', '\');
  fn2:= ReplaceExt('w$$', fn);
  fn3:= ReplaceExt('f$$', fn);
  fn4:= ReplaceExt('l$$', fn);

  fn22:= ReplaceExt('wrd', fn);
  fn23:= ReplaceExt('fld', fn);
  fn24:= ReplaceExt('loc', fn);

  FstrmFinalWrd.Free;
  FstrmFinalFld.Free;
  FstrmFinalLoc.Free;

  // close streams fn22, fn23, fn24
  IdxItems[0].Free;
  IdxItems[1].Free;

  if FileExists(fn22)
  then DeleteFile(PChar(fn22));
  if FileExists(fn23)
  then DeleteFile(PChar(fn23));
  if FileExists(fn24)
  then DeleteFile(PChar(fn24));

  RenameFile(fn2, fn22);
  RenameFile(fn3, fn23);
  RenameFile(fn4, fn24);

  // restore first index (.key)
  FFileList[0]:= TempAccIdxDir;

  FstrmFinalWrd:= TFileStream.Create(fn22, fmOpenRead);
  FstrmFinalFld:= TFileStream.Create(fn23, fmOpenRead);
  FstrmFinalLoc:= TFileStream.Create(fn24, fmOpenRead);
end;

procedure TMergeIndexesCustomThread.Execute;
var
  idx: Integer;
  cnt: Cardinal;
begin
  {
  cnt:= Length(IdxItems);
  MergeWords(0, cnt - 1);       // merge words into SLWord
  StoreLoc;                     // .wrd .fld .loc from SLWord
  }
  {
  // calculate words in
  for idx:= 2 to cnt - 1 do begin
    with IdxItems[AIndex] do begin
      WrdCount:= WrdCalcWords(strmWrd);
    end;
  end;
  }
  Open2IdxFiles(0, 1);

  MergeWords(0, 1);       // merge first two indexes
  ProgressState:= 'Store first two merged indexes';
  StoreLoc;

  cnt:= FFileList.Count;

  FFileList[0]:= FDir;

  for idx:= 2 to cnt - 1 do begin
    MoveIdxAccumulator;
    // clear hash
    SLWord.Iterate(Nil, Iterate_FreeMem);
    SLWord.Clear;
    // merge
    Open2IdxFiles(0, idx);

    MergeWords(0, 1);       // merge words
    ProgressState:= 'Store ' + IntToStr(idx + 1) +' merged indexes';
    StoreLoc;                  // store
  end;

  // rename '.l$$' to '.loc'
  RenameAccumulatorToIndex; // and restore FFileList[0]:= TempAccIdxDir;

  OpenAllIdxFiles;
  OpenLstFiles;

  StoreMergedLst(0, cnt - 1);   // .lst
  StoreMergedKey(0, cnt - 1);   // .key
  Report(cnt, cnt, 'Total ' + IntToStr(cnt) + ' indexes.' );
  // .tag
end;

procedure TMergeIndexesCustomThread.Sort;
var
  c: Integer;
begin
  c:= Length(Fsortfl);
  if (c > 0) then begin
    QuickSort(0, c - 1);
  end;
end;

// compare based on field value
procedure TMergeIndexesCustomThread.QuickSort(L, R: Integer);
var
  I, J: Integer;
  P: Integer;
  AR: TFld2LocItem;

  function RecCompare(R1, R2: Integer): Integer;
  begin
{$IFNDEF IGNOREFLD}
    if Fsortfl[R1].Fld > Fsortfl[R2].Fld
    then Result:= 1
    else if Fsortfl[R1].Fld < Fsortfl[R2].Fld
      then Result:= -1
      else
{$ENDIF}
        if Fsortfl[R1].Loc > Fsortfl[R2].Loc // Fsortfl[R1].Fld = Fsortfl[R2].Fld
        then Result:= 1
        else if Fsortfl[R1].Loc < Fsortfl[R2].Loc // Fsortfl[R1].Fld = Fsortfl[R2].Fld
          then Result:= -1
          else Result:= 0;
  end;

begin
  repeat
    I:= L;
    J:= R;
    P:= (L + R) shr 1;
    repeat
      while RecCompare(I, P) < 0
      do Inc(I);
      while RecCompare(J, P) > 0
      do Dec(J);
      if I <= J then begin
        { exchange }
        AR:= Fsortfl[j];
        Fsortfl[j]:= Fsortfl[i];
        Fsortfl[i]:= AR;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then begin
      QuickSort(L, J);
    end;
    L:= I;
  until (I >= R);
end;

end.
