unit EMemos;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  s                                                           *
*                                                                             *
*   Copyright©2001-2004 Andrei Ivanov. All rights reserved.                    *
*   TECustomMemo collection class                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001                                                 *
*   Last revision: Jul 29 2001                                                *
*   Lines        : 815                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, StdActns, Dialogs,
  jclUnicode,
  util1,
  rtcShellHelper, rtcFolderTree,
  urlFuncs, EMemo, customxml, xmlsupported, wmlc, xmlParse, util_xml;

type
  TStorageType = (srSame, srFile, srFtp, srLdap, srHttp, srDb, srString);
  TDocState = (dsIsNew);
  TDocStates = set of TDocState;

  TFileStatus = class(TPersistent)
  public
    FileName: String[255];
    DocType: TEditableDoc;
    Storage: TStorageType;
    State: TDocStates;
    constructor Create;
    destructor Destroy; override;
  end;

  TOnGetExternalStorageFile = function (AFolderType: TFolderType; const AURL: String): String of object;
  TOnPutExternalStorageFile = function (AFolderType: TFolderType; const AURL, AData: String): Integer of object;

  TEMemos = class(TPersistent)
  private
    FAddDelOpCount: Cardinal;  // used for renaming ememo components
    FBlockIndent: Integer;
    FWBXMLVersion: Integer; // used to store wbxml. -1- set appropriate to wml version
    FFontName: String;
    FFontSize: Integer;
    FDefRightMargin: Integer;
    FDefGutterWidth: Integer;
    FUseRightMargin: Boolean;
    FUseGutter: Boolean;
    FShowLineNum: Boolean;
    FConvOnLoadOptions,
    FConvOnSaveOptions: TEntityConvOptions;

    FEnvironmentOptionsStr: String;
    FDefaultEncoding: Integer;
    FOptions: TEMemoOptionSet;
    FOnExit: TOnExitEvent;
    FMemos: TList;
    FFileStatus: TList;
    FOwner: TComponent;
    FParent: TWinControl;
    FOnModifiedTimeDelay: TTimeDelayEvent;
    FOnProcessTemplate: xmlParse.TOnProcessTemplateEvent;
    FAutoComplete: Boolean;
    FAutoCompleteInterval: Integer;
    FOnGetStorageFile: TOnGetExternalStorageFile;
    FOnPutStorageFile: TOnPutExternalStorageFile;
    FOnMemoDragOver: TDragOverEvent;
    FOnMemoDragDrop: TDragDropEvent;

    function GetLength: Integer;
    function GetSelected(AIndex: Integer): Boolean;
    procedure SetSelected(AIndex: Integer; ANewValue: Boolean);
    function GetMemo(AIndex: Integer): TEMemo;
    function GetFileStatus(AIndex: Integer): TFileStatus;
    procedure SetLength(ANewValue: Integer);
    procedure SetOnModifiedTimeDelay(AOnModifiedTimeDelay: TTimeDelayEvent);
    procedure SetOnExit(AValue: TOnExitEvent);
    procedure SetBlockIndent(AValue: Integer);

    procedure SetRightMargin(AValue: Integer);
    procedure SetGutterWidth(AValue: Integer);
    procedure SetUseRightMargin(AValue: Boolean);
    procedure SetUseGutter(AValue: Boolean);
    procedure SetShowLineNum(AValue: Boolean);
    procedure SetConvOnLoadOptions(AValue: TEntityConvOptions);
    procedure SetConvOnSaveOptions(AValue: TEntityConvOptions);

    procedure SetEnvironmentOptionsStr(const AValue: String);

    procedure SetFontName(const AValue: String);
    procedure SetFontSize(AValue: Integer);
    procedure SetOptions(AValue: TEMemoOptionSet);
    procedure SetDefaultEncoding(AValue: Integer);
    procedure SetAutoComplete(AValue: Boolean);
    procedure SetAutoCompleteInterval(AValue: Integer);
    procedure SetOnMemoDragOver(AOnMemoDragOver: TDragOverEvent);
    procedure SetOnMemoDragDrop(AOnMemoDragDrop: TDragDropEvent);
  public
    property Memo[AIndex: Integer]: TEMemo read GetMemo; default;
    property FileStatus[AIndex: Integer]: TFileStatus read GetFileStatus;
    property Selected[AIndex: Integer]: Boolean read GetSelected write SetSelected;
    constructor Create(AOwner: TControl; AParent: TWinControl);
    destructor Destroy; override;
    function AddNew(const ADocNamePrefix: String; const ATemplate: String; ADocType: TEditableDoc; AStorage: TStorageType): Integer;
    function Add(AFileName: String; AStorage: TStorageType; ADocType: TEditableDoc): Integer;
    function IndexOfFileName(AFileName: String): Integer; // return -1 if does not exists
    procedure Delete(AIndex: Integer);
    function Store(AIdx: Integer; AFileName: String; AStorage: TStorageType; ADocType: TEditableDoc): Boolean;
    procedure SaveAllModified(AFileSaveAs: TFileSaveAs);  //
    function ModifiedCount: Integer;
  published
    property Size: Integer read GetLength write SetLength;
    property OnModifiedTimeDelay: TTimeDelayEvent read FOnModifiedTimeDelay write SetOnModifiedTimeDelay;
    property OnProcessTemplate: TOnProcessTemplateEvent read FOnProcessTemplate write FOnProcessTemplate;
    property OnExit: TOnExitEvent read FOnExit write SetOnExit;
    property BlockIndent: Integer read FBlockIndent write SetBlockIndent;
    property FontName: String read FFontName write SetFontName;
    property FontSize: Integer read FFontSize write SetFontSize;

    property AutoComplete: Boolean read FAutoComplete write SetAutoComplete;
    property AutoCompleteInterval: Integer read FAutoCompleteInterval write SetAutoCompleteInterval;
    property DefRightMargin: Integer read FDefRightMargin write SetRightMargin;
    property DefGutterWidth: Integer read FDefGutterWidth write SetGutterWidth;
    property UseRightMargin: Boolean read FUseRightMargin write SetUseRightMargin;
    property UseGutter: Boolean read FUseGutter write SetUseGutter;
    property ShowLineNum: Boolean read FShowLineNum write SetShowLineNum;

    property ConvOnLoadOptions: TEntityConvOptions read FConvOnLoadOptions write SetConvOnLoadOptions;
    property ConvOnSaveOptions: TEntityConvOptions read FConvOnSaveOptions write SetConvOnSaveOptions;

    property Options: TEMemoOptionSet read FOptions write SetOptions;
    property EnvironmentOptions: String read FEnvironmentOptionsStr write SetEnvironmentOptionsStr;
    property DefaultEncoding: Integer read FDefaultEncoding write SetDefaultEncoding;
    property WBXMLVersion: Integer read FWBXMLVersion write FWBXMLVersion;
    property OnGetStorageFile: TOnGetExternalStorageFile read FOnGetStorageFile write FOnGetStorageFile;
    property OnPutStorageFile: TOnPutExternalStorageFile read FOnPutStorageFile write FOnPutStorageFile;
    property OnMemoDragOver: TDragOverEvent read FOnMemoDragOver write SetOnMemoDragOver;
    property OnMemoDragDrop: TDragDropEvent read FOnMemoDragDrop write SetOnMemoDragDrop;
  end;

// return short description string of document storage: srFile, srFtp, srHttp, srDb
function GetStorageTypeDesc(AStorage: TStorageType): String;

// return document storage: srFile, srFtp, srHttp, srDb depending on file name
function GetStorageTypeByFileName(const AFileName: String): TStorageType;

// load from file to memo
function Load2NewMemo(AStorage: TStorageType; const AFileName: String;
  AOnGetStorageFile: TOnGetExternalStorageFile = Nil): TECustomMemo;

function StoreMemo2File(AMemo: TECustomMemo; ADocType: TEditableDoc; AStorage: TStorageType; const AFileName: String): Boolean;

// load collection from file
function LoadXMLElement(AStorage: TStorageType; ADocType: TEditableDoc; const AFileName: String; AOptions: TEntityConvOptions): TxmlElementCollection;  // Entity to Char

implementation

// return short description string of document storage: srFile, srFtp, srHttp, srDb
function GetStorageTypeDesc(AStorage: TStorageType): String;
begin
  case AStorage of
    srFile: Result:= 'file';
    srFtp: Result:= 'placed on ftp site';
    srHttp: Result:= 'published on web server';
    srDb: Result:= 'stored in database';
    else begin
      Result:= 'unrecognized type of storage';
    end;
  end; { case }
end;

// return document storage: srFile, srFtp, srHttp, srDb depending on file name
function GetStorageTypeByFileName(const AFileName: String): TStorageType;
begin
  if FileExists(AFileName) or DirectoryExists(AFileName) then begin
    Result:= srFile;
  end else begin
    if urlFuncs.IsFtpUrl(AFileName) then begin
      Result:= srFtp;
    end else begin
      if IsLdapUrl(AFileName) then begin
        Result:= srLdap;
      end else begin
        Result:= srSame;
      end;
    end;
  end;
end;

constructor TFileStatus.Create;
begin
  inherited;
  FileName:= '';
  doctype:= edWML;
  Storage:= srFile;
  State:= [];
end;

destructor TFileStatus.Destroy;
begin
  inherited;
end;

constructor TEMemos.Create(AOwner: TControl; AParent: TWinControl);
begin
  inherited Create;
  FAddDelOpCount:= 0;
  FOnProcessTemplate:= Nil;
  FOnModifiedTimeDelay:= Nil;
  FMemos:= TList.Create;
  FFileStatus:= TList.Create;
  FOwner:= AOwner;
  FParent:= AParent;
  FFontName:= 'Courier New';
  FFontSize:= 8;
  FOptions:= [];
  FOnExit:= Nil;

  FDefRightMargin:= 80;
  FDefGutterWidth:= 26;
  FUseRightMargin:= False;
  FUseGutter:= True;
  FShowLineNum:= False;
  FConvOnLoadOptions:= [];
  FConvOnSaveOptions:= [];

  FAutoComplete:= False;

  FOnGetStorageFile:= Nil;
  FOnPutStorageFile:= Nil;
  FOnMemoDragOver:= Nil;
  FOnMemoDragDrop:= Nil;
end;

destructor TEMemos.Destroy;
begin
  FOnModifiedTimeDelay:= Nil;
  Self.SetLength(0);
  FMemos.Free;
  FFileStatus.Free;
  inherited;
end;

function TEMemos.GetLength: Integer;
begin
//  Result:= Length(FMemos);
  Result:= FMemos.Count;
end;

function TEMemos.GetSelected(AIndex: Integer): Boolean;
begin
  Result:= False;
  if (AIndex < 0) or (AIndex >= GetLength)
  then Exit;
  Result:= TEMemo(FMemos[AIndex]).Visible;
end;

procedure TEMemos.SetSelected(AIndex: Integer; ANewValue: Boolean);
var
  i, idx: Integer;
begin
  if (AIndex < 0) or (AIndex >= GetLength)
  then Exit;
  idx:= -1;
  for i:= 0 to GetLength - 1 do begin
    if i = AIndex then begin
      TEMemo(FMemos[i]).Visible:= True;
      idx:= i;
    end else begin
      TEMemo(FMemos[i]).Visible:= False;
    end;
  end;
  if idx >= 0 then with TEMemo(FMemos[idx]) do begin
    if CanFocus
    then SetFocus;
  end;
end;

function TEMemos.GetMemo(AIndex: Integer): TEMemo;
begin
  Result:= Nil;
  if (AIndex < 0) or (AIndex >= GetLength)
  then Exit;
  Result:= TEMemo(FMemos[AIndex]);
end;

function TEMemos.GetFileStatus(AIndex: Integer): TFileStatus;
begin
  Result:= Nil;
  if (AIndex < 0) or (AIndex >= GetLength)
  then Exit;
  Result:= FFileStatus[AIndex];
end;

// return -1 if does not exists
function TEMemos.IndexOfFileName(AFileName: String): Integer;
var
  i: Integer;
begin
  Result:= -1;
  for i:= 0 to GetLength - 1 do begin
    if SameFileName(ExpandFileName(AFileName), TFileStatus(FFileStatus[i]).FileName) then begin
      Result:= i;
      Break;
    end;
  end;
end;

function TEMemos.AddNew(const ADocNamePrefix: String; const ATemplate: String; ADocType: TEditableDoc; AStorage: TStorageType): Integer;
var
  L: Integer;
begin
  L:= GetLength;
  // expand
  Self.SetLength(L + 1);
  with TFileStatus(FFileStatus[L]) do begin
    FileName:= ExpandFileName(ADocNamePrefix);
    doctype:= ADocType;
    Storage:= AStorage;
    State:= State + [dsIsNew];
  end;
  with TEMemo(FMemos[L]) do begin
    Modified:= True;
    case AStorage of
      srFile: begin
        end;
      srFtp: begin
        end;
      srHttp: begin
        end;
      srDb: begin
        end;
    end;
    BlockIndent:= FBlockIndent;
    Font.Name:= FontName;
    Font.Size:= FontSize;

    RightEdgeCol:= FDefRightMargin;
    GutterOptions.Width:= FDefGutterWidth;
    RightEdge:= FUseRightMargin;
    GutterOptions.Visible:= FUseGutter;
    GutterOptions.ShowLineNum:= FShowLineNum;

    AutoComplete:= FAutoComplete;
    SetEnvironmentOptionsStr(FEnvironmentOptionsStr);

    Options:= [emUseBoldTags];

    ConvOnLoadOptions:= FConvOnLoadOptions;
    Lines.Text:= ATemplate;
    ModifiedSinceLastDelay:= False;
    OnModifiedTimeDelay:= FOnModifiedTimeDelay;
    OnDragOver:= FOnMemoDragOver;
    OnDragDrop:= FOnMemoDragDrop;

    ConvOnSaveOptions:= FConvOnSaveOptions;
  end;
  Result:= L;
end;

function TEMemos.Add(AFileName: String; AStorage: TStorageType; ADocType: TEditableDoc): Integer;
var
  L: Integer;
  s: String;
  ws: TGsString;
  errDesc: String;
  encoding: Integer;
  wbxmlver, publicid: Integer;
begin
  L:= GetLength;
  // expand
  Self.SetLength(L + 1);
  with TFileStatus(FFileStatus[L]) do begin
    if Pos('://', AFileName) = 0
    then FileName:= ExpandFileName(AFileName)
    else FileName:= AFileName;
    Storage:= AStorage;
  end;

  // load raw data
  case AStorage of
    srFile: begin
        s:= util1.File2String(AFileName);
      end;
    srFtp: begin
        if Assigned(FOnGetStorageFile)
        then s:= FOnGetStorageFile(ftFtpNode, AFileName)
        else s:= 'ftp storage is not supported.'#13#10;
      end;
    srLdap: begin
        if Assigned(FOnGetStorageFile)
        then s:= FOnGetStorageFile(ftFtpNode, AFileName)
        else s:= 'ldap storage is not supported.'#13#10;
      end;
    srHttp: begin
        if Assigned(FOnGetStorageFile)
        then s:= FOnGetStorageFile(ftFtpNode, AFileName)
        else s:= 'ldap storage is not supported.'#13#10;
      end;
    srDb: begin
        s:=  'Database storage is not supported.'#13#10;
      end;
  end;
  // at least 1 row
  if Length(S) = 0
  then S:= #13#10;
  // set doc type
  with TFileStatus(FFileStatus[L]) do begin
    if ADocType in [edSame, edDefault]
    then doctype:= GetDocTypeByFileName(AFileName)
    else doctype:= ADocType;
  end;

  case TFileStatus(FFileStatus[L]).doctype of
    edWMLTemplate: begin
        // set character set first (before read TextInCharacterset property )
        TEMemo(FMemos[L]).Encoding:= util_xml.GetEncoding(s, DefaultEncoding);
        // load
        // translate default to ALL memos character set to unicode
        ws:= util_xml.CharSet2WideString(TEMemo(FMemos[L]).Encoding, s, FConvOnLoadOptions);
        if Assigned(FOnProcessTemplate) then begin
          FOnProcessTemplate(Self, ws);
        end;
        // set converted template
        TEMemo(FMemos[L]).Lines.Text:= ws;
      end;
    edWMLCompiled: begin
        // do not use that: TEMemo(FMemos[L]).TextInCharacterset[convPCDATA]:= wmlc.DecompileWMLCString(s, FBlockIndent, errDesc);
        // because DecompileWMLCString returns wide string itself
        TEMemo(FMemos[L]).Lines.Text:= wmlc.DecompileWMLCString(s, FBlockIndent,
          errDesc, encoding, wbxmlver, publicid);
        TEMemo(FMemos[L]).Encoding:= encoding;
        if Length(errDesc) <> 0
        then ShowMessage(errDesc);
      end;
    else begin  // edText, edWML, edHTML, edCSS, edOEB, edPkg, edXHTML, edTaxon, edSMIT
        // set character set first (before read TextInCharacterset property )
        TEMemo(FMemos[L]).Encoding:= util_xml.GetEncoding(s, DefaultEncoding);
        // load
        with TEMemo(FMemos[L]) do begin
          ConvOnLoadOptions:= FConvOnLoadOptions;
          TextInCharacterset[convPCDATA]:= s;
        end;
      end;
  end;

  with TEMemo(FMemos[L]) do begin
    FBlockIndent:= FBlockIndent;
    Font.Name:= FontName;
    Font.Size:= FontSize;

    RightEdgeCol:= FDefRightMargin;
    GutterOptions.Width:= FDefGutterWidth;
    RightEdge:= FUseRightMargin;
    SetEnvironmentOptionsStr(FEnvironmentOptionsStr);
    GutterOptions.Visible:= FUseGutter;
    // smth wrong with show line. It does not work
    GutterOptions.ShowLineNum:= FShowLineNum;

    Options:= FOptions;
    ModifiedSinceLastDelay:= False;
    OnModifiedTimeDelay:= FOnModifiedTimeDelay;
    OnDragOver:= FOnMemoDragOver;
    OnDragDrop:= FOnMemoDragDrop;

    ConvOnSaveOptions:= FConvOnSaveOptions;
  end;
  Result:= L;
end;

// store to file, ftp, http or db
// AFileName = ''        - save with previous name
// AStorage  = srDefault - store in previous storage
function TEMemos.Store(AIdx: Integer; AFileName: String; AStorage: TStorageType; ADocType: TEditableDoc): Boolean;
var
  L: Integer;
//  sl: TStrings;
  s: String;
  errDesc: TWideStrings;
begin
  Result:= False;
  if (AIdx >= FMemos.Count) or (AIdx < 0)
  then Exit;
  L:= Length(AFileName);
  if L = 0
  then AFileName:= TFileStatus(FFileStatus[AIdx]).FileName;

  case ADocType of
  edSame:;
  edDefault: begin
      // get new document type
        TFileStatus(FFileStatus[AIdx]).doctype:= GetDocTypeByFileName(AFileName);
     end;
  else begin
        TFileStatus(FFileStatus[AIdx]).doctype:= ADocType;
      end;
  end; { case }
  // do translation from pure wml
  // not implemented yet for most types
  case TFileStatus(FFileStatus[AIdx]).doctype of
    edWMLCompiled: begin
        errDesc:= TWideStringList.Create;
        s:= wmlc.CompileWMLCString(FWBXMLVersion, TEMemo(FMemos[AIdx]).Lines.Text, errDesc);
        if errDesc.Count > 0
        then ShowMessage(errDesc.Text);
        errDesc.Free;
      end;
    else begin //  edText, edWML, edHTML, edCSS, edOEB, edPKG, edXHTML, edTaxon, edSMIT, edWMLTemplate
        s:= TEMemo(FMemos[AIdx]).TextInCharacterset[convPCDATA];
      end;
  end;

  if AStorage = srSame
  then AStorage:= TFileStatus(FFileStatus[AIdx]).Storage;
  case AStorage of
    srFile: begin
        DeleteFile(AFileName);
        util1.String2File(AFileName, S);
      end;
    srFtp: begin
      if Assigned(FOnPutStorageFile)
      then FOnPutStorageFile(ftFtpNode, AFileName, s)
      else raise Exception.CreateFmt('Can not store %s via ftp', [TFileStatus(FFileStatus[L]).FileName]);
      end;
    srLdap: begin
      if Assigned(FOnPutStorageFile)
      then FOnPutStorageFile(ftFtpNode, AFileName, s)
      else raise Exception.CreateFmt('Can not store %s via ldap', [TFileStatus(FFileStatus[L]).FileName]);
      end;
    srHttp: begin
      if Assigned(FOnPutStorageFile)
      then FOnPutStorageFile(ftHTTPNode, AFileName, s)
      else raise Exception.CreateFmt('Can not store %s via http', [TFileStatus(FFileStatus[L]).FileName]);
      end;
    srDb: begin
      raise Exception.CreateFmt('Can not store %s to db', [TFileStatus(FFileStatus[L]).FileName]);
      end;
  end;

  // indicate that memo modification is stored
  TEMemo(FMemos[AIdx]).ModifiedSinceLastDelay:= False;
  // indicate that file is stored succesefully
  with TFileStatus(FFileStatus[AIdx]) do begin
    // change name of file name
    if AFileName <> FileName then FileName:= AFileName;
    State:= State - [dsIsNew];
    TEMemo(FMemos[AIdx]).Modified:= False;
  end;
  Result:= True;
end;

procedure TEMemos.Delete(AIndex: Integer);
var
  L: Integer;
begin
  // get len
  L:= GetLength;
  if (AIndex < 0) or (AIndex >= L)
  then raise Exception.CreateFmt('Out of index in %s', ['TEmemos']);
  // destroy objects
  TEMemo(FMemos[AIndex]).Free;
  TFileStatus(FFileStatus[AIndex]).Free;
  // move tail of array
  FMemos.Delete(AIndex);
  FFileStatus.Delete(AIndex);
  {
  for i:= AIndex + 1 to L - 1 do begin
    Move(TEMemo(FMemos[i]), TEMemo(FMemos[i-1]), SizeOf(TEMemo));
    Move(TFileStatus(FFileStatus[i]), TFileStatus(FFileStatus[i-1]), SizeOf(TFileStatus());
  end;
  // shrink
  Self.SetLength(L-1);
  }
end;

procedure TEMemos.SetLength(ANewValue: Integer);
var
  p, AOldValue: Integer;
begin
  AOldValue:= GetLength;
  // delete old images if new qty is less than previous
  for p:= ANewValue to AOldValue - 1 do begin
    TEMemo(FMemos[p]).Free;
    TFileStatus(FFileStatus[p]).Free;
  end;
  // set new array bounds
  FMemos.Count:= ANewValue;
  FFileStatus.Count:= ANewValue;
  // System.SetLength(FMemos, ANewValue); System.SetLength(FFileStatus, ANewValue);

  // allocate new ones if new qty is larger than previous
  for p:= AOldValue to ANewValue - 1 do begin
    FMemos[p]:= TEMemo.Create(FOwner);
    with TEMemo(FMemos[p]) do begin
      // component mast have unique name
      // after add/delete ememo give new names according to their order
      // to avoid renaming with old value use different prefix each time (count is used) 
      Name:= Format('EMemo%d_%d', [FAddDelOpCount, p]);
      Visible:= False;
      Align:= alClient;
      Parent:= FParent;
    end;
    FFileStatus[p]:= TFileStatus.Create();
  end;
  // make invisible and assign Click event handler
  for p:= AOldValue to ANewValue - 1 do with TEMemo(FMemos[p]) do begin
    // Id:= p;
    // Visible:= True;
  end;
  Inc(FAddDelOpCount);
end;

procedure TEMemos.SetOnModifiedTimeDelay(AOnModifiedTimeDelay: TTimeDelayEvent);
var
  i: Integer;
begin
  FOnModifiedTimeDelay:= AOnModifiedTimeDelay;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).OnModifiedTimeDelay:= AOnModifiedTimeDelay;
  end;
end;

procedure TEMemos.SetOnExit(AValue: TOnExitEvent);
var
  i: Integer;
begin
  FOnExit:= AValue;
  // set tab width to indent value
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).OnExit:= FOnExit;
  end;
end;

procedure TEMemos.SetBlockIndent(AValue: Integer);
var
  i: Integer;
begin
  if AValue < 0
  then FBlockIndent:= 2
  else FBlockIndent:= AValue;
  // set tab width to indent value
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).BlockIndent:= FBlockIndent;
  end;
  // re- format opened files?
end;

procedure TEMemos.SetRightMargin(AValue: Integer);
var
  i: Integer;
begin
  if AValue <= 0
  then FDefRightMargin:= 80
  else FDefRightMargin:= AValue;
  // set right margin to the new value
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).RightEdgeCol:= AValue;
end;

procedure TEMemos.SetGutterWidth(AValue: Integer);
var
  i: Integer;
begin
  if AValue <= 0
  then FDefGutterWidth:= 26
  else FDefGutterWidth:= AValue;
  // set gutter width to the new value
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).GutterOptions.Width:= AValue;
end;

procedure TEMemos.SetUseRightMargin(AValue: Boolean);
var
  i: Integer;
begin
  FUseRightMargin:= AValue;
  // set visible or not
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).RightEdge:= AValue;
end;

procedure TEMemos.SetUseGutter(AValue: Boolean);
var
  i: Integer;
begin
  FUseGutter:= AValue;
  // set visible or not
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).GutterOptions.Visible:= AValue;
end;

procedure TEMemos.SetShowLineNum(AValue: Boolean);
var
  i: Integer;
begin
  FShowLineNum:= AValue;
  // set visible or not
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).GutterOptions.ShowLineNum:= AValue;
end;

procedure TEMemos.SetConvOnLoadOptions(AValue: TEntityConvOptions);
var
  i: Integer;
begin
  FConvOnLoadOptions:= AValue;
  // set all opened editors
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).ConvOnLoadOptions:= AValue;
end;

procedure TEMemos.SetConvOnSaveOptions(AValue: TEntityConvOptions);
var
  i: Integer;
begin
  FConvOnSaveOptions:= AValue;
  // set all opened editors
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).ConvOnSaveOptions:= AValue;
end;

procedure TEMemos.SetEnvironmentOptionsStr(const AValue: String);
var
  i: Integer;
begin
  FEnvironmentOptionsStr:= AValue;
  for i:= 0 to Size - 1
  do TEMemo(FMemos[i]).EnvironmentOptions.SetByString(AValue);
end;

procedure TEMemos.SetFontName(const AValue: String);
var
  i: Integer;
begin
  FFontName:= AValue;
  // set tab width to indent value
  for i:= 0 to Size - 1 do with TEMemo(FMemos[i]) do begin
    Font.Name:= AValue;
    Font.Charset:= ANSI_CHARSET; // 2003 Mar 14
    UpdateFontMetrics;
  end;
  // re- format opened files?
end;

procedure TEMemos.SetFontSize(AValue: Integer);
var
  i: Integer;
begin
  FFontSize:= AValue;
  // set tab width to indent value
  for i:= 0 to Size - 1 do with TEMemo(FMemos[i]) do begin
    Font.Size:= AValue;
    UpdateFontMetrics;
  end;
  // re- format opened files?
end;


procedure TEMemos.SetOptions(AValue: TEMemoOptionSet);
var
  i: Integer;
begin
  FOptions:= AValue;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).Options:= Options;
  end;
end;

procedure TEMemos.SetDefaultEncoding(AValue: Integer);
begin
  FDefaultEncoding:= AValue;
  {  do not assign default encoding to all editors
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).Encoding:= AValue;
  end;
  }
end;

procedure TEMemos.SetAutoComplete(AValue: Boolean);
var
  i: Integer;
begin
  FAutoComplete:= AValue;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).AutoComplete:= AValue;
  end;
end;

procedure TEMemos.SetAutoCompleteInterval(AValue: Integer);
var
  i: Integer;
begin
  FAutoCompleteInterval:= AValue;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).DropListTimeDelay:= AValue;
  end;
end;

procedure TEMemos.SetOnMemoDragOver(AOnMemoDragOver: TDragOverEvent);
var
  i: Integer;
begin
  FOnMemoDragOver:= AOnMemoDragOver;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).OnDragOver:= AOnMemoDragOver;
  end;
end;

procedure TEMemos.SetOnMemoDragDrop(AOnMemoDragDrop: TDragDropEvent);
var
  i: Integer;
begin
  FOnMemoDragDrop:= AOnMemoDragDrop;
  for i:= 0 to Size - 1 do begin
    TEMemo(FMemos[i]).OnDragDrop:= AOnMemoDragDrop;
  end;
end;

// load collection from file
function LoadXMLElement(AStorage: TStorageType; ADocType: TEditableDoc; const AFileName: String; AOptions: TEntityConvOptions): TxmlElementCollection;
const
  DEFAULTENCODING = csUTF8;
var
  s: String;
  ws: TGsString;
  errDesc: String;
  i, Encoding: Integer;
  wbxmlver, publicid: Integer;
  ContainerClass: TClass;
  wsl: TWideStrings;
begin
  Result:= Nil;
  // expand
  // load raw data
  case AStorage of
    srFile: begin
        s:= util1.File2String(AFileName);
      end;
    srFtp: begin
        s:=  'FTP storage is not supported in evaluation version.'#13#10;
      end;
    srHttp: begin
        s:=  'HTTP storage is not supported in evaluation version.'#13#10;
      end;
    srDb: begin
        s:=  'Database storage is not supported in evaluation version.'#13#10;
      end;
    srString: begin
        s:=  AFileName;
      end;
  end;
  // at least 1 row
  if Length(S) = 0
  then S:= #13#10;
  // set doc type
  if ADocType in [edSame, edDefault]
  then Adoctype:= GetDocTypeByFileName(AFileName);

  case Adoctype of
    edText, edHTML, edCss: begin
        // do not load xml
        Exit;
      end;
    edWMLCompiled: begin
        // do not use that: TEMemo(FMemos[L]).TextInCharacterset[convPCDATA]:= wmlc.DecompileWMLCString(s, FBlockIndent, errDesc);
        // because DecompileWMLCString returns wide string itself
        ws:= wmlc.DecompileWMLCString(s, BlockIndent, errDesc, Encoding, wbxmlver, publicid);
      end;
    else //edWML, edOEB, edPkg, edXHTML, edWMLTemplate:  // template does not loaded correctly
      begin
        // set character set first (before read TextInCharacterset property )
        Encoding:= util_xml.GetEncoding(s, DefaultEncoding);
        wsl:= TWideStringList.Create;
        wsl.Text:= s;
        for i:= 0 to wsl.Count - 1 do begin
          ws:= util_xml.CharSet2WideString(Encoding, wsl[i], AOptions);
          // check validity of conversion
          if Length(ws) > 0
          then wsl[i]:= ws;
        end;
        ws:= wsl.Text;
        wsl.Free;
      end;
  end;
  ContainerClass:= getContainerClassByDoctype(ADocType);
  if not Assigned(ContainerClass) then Result:= Nil else begin
    Result:= TxmlElementCollection.Create(TxmlElementClass(ContainerClass), Nil, wciOne);
    Result.Clear1;
    xmlParse.xmlCompileText(ws, Nil, Nil, Nil, Result.Items[0], ContainerClass);
  end;
end;

// load from file to memo

function Load2NewMemo(AStorage: TStorageType; const AFileName: String;
  AOnGetStorageFile: TOnGetExternalStorageFile = Nil): TECustomMemo;
const
  DEFAULTENCODING = csUTF8;
var
  s: String;
  errDesc: String;
  i, Encoding: Integer;
  doctype: TEditableDoc;
  wbxmlver, publicid: Integer;
begin
  Result:= Nil;
  // load raw data
  case AStorage of
    srFile: begin
        s:= util1.File2String(AFileName);
      end;
    srFtp: begin
        if Assigned(AOnGetStorageFile)
        then s:= AOnGetStorageFile(ftFtpNode, AFileName)
        else s:= 'ftp storage is not supported.'#13#10;
      end;
    srLdap: begin
        if Assigned(AOnGetStorageFile)
        then s:= AOnGetStorageFile(ftLdapNode,AFileName)
        else s:= 'ldap storage is not supported.'#13#10;
      end;
    srHttp: begin
        if Assigned(AOnGetStorageFile)
        then s:= AOnGetStorageFile(ftHttpNode,AFileName)
        else s:= 'HTTP storage is not supported.'#13#10;
      end;
    srDb: begin
        s:= 'Database storage is not supported in this case.'#13#10;
      end;
    srString: begin
        s:= AFileName;
      end;
  end;
  // at least 1 row
  if Length(S) = 0
  then S:= #13#10;

  // set doc type
  doctype:= GetDocTypeByFileName(AFileName);

  Result:= TEMemo.Create(Nil);

  case doctype of
  edWMLCompiled: begin
      // do not use that: TEMemo(FMemos[L]).TextInCharacterset[convPCDATA]:= wmlc.DecompileWMLCString(s, FBlockIndent, errDesc);
      // because DecompileWMLCString returns wide string itself
      Result.Lines.Text:= wmlc.DecompileWMLCString(s, 2,errDesc, encoding, wbxmlver, publicid);
      Result.Encoding:= encoding;
      if Length(errDesc) <> 0
      then ShowMessage(errDesc);
    end;
  else begin
    // edText, edWML, edHTML, edCSS, edOEB, edPkg, edXHTML, edWMLTemplate, edTaxon, edSMIT
      // set character set first (before read TextInCharacterset property )
      Result.Encoding:= util_xml.GetEncoding(s, DefaultEncoding);
      // load
      Result.TextInCharacterset[convPCDATA]:= s;
    end;
  end; { case }
end;

function StoreMemo2File(AMemo: TECustomMemo; ADocType: TEditableDoc; AStorage: TStorageType; const AFileName: String): Boolean;
var
  L: Integer;
//  sl: TStrings;
  s: String;
  errDesc: TWideStrings;
begin
  Result:= False;

  // do translation from pure wml
  if ADocType in [edSame, edDefault]
  then Adoctype:= GetDocTypeByFileName(AFileName);

  case ADoctype of
    edWMLTemplate: begin
        s:= AMemo.TextInCharacterset[convPCDATA];
      end;
    edWMLCompiled: begin
        errDesc:= TWideStringList.Create;
        s:= wmlc.CompileWMLCString(-1, AMemo.Lines.Text, errDesc);
        if errDesc.Count > 0
        then ShowMessage(errDesc.Text);
        errDesc.Free;
      end;
    else s:= AMemo.TextInCharacterset[convPCDATA];
  end;

  case AStorage of
    srFile: begin
        DeleteFile(AFileName);
        util1.String2File(AFileName, S);
      end;
    srFtp: begin
      raise Exception.CreateFmt('Can not store %s via ftp', [AFileName]);
      end;
    srHttp: begin
      raise Exception.CreateFmt('Can not store %s via http', [AFileName]);
      end;
    srDb: begin
      raise Exception.CreateFmt('Can not store %s to db', [AFileName]);
      end;
  end;

  // indicate that memo modification is stored
  AMemo.ModifiedSinceLastDelay:= False;
  // indicate that file is stored succesefully
  AMemo.Modified:= False;
  Result:= True;
end;

procedure TEMemos.SaveAllModified(AFileSaveAs: TFileSaveAs);  //
var
  m: Integer;
begin
  for m:= 0 to Size - 1 do begin
    if Memo[m].Modified then begin
      if dsIsNew in Self.FileStatus[m].State then begin
        if Assigned(AFileSaveAs) then begin
          AFileSaveAs.Execute;
        end;
      end else begin
        Store(m, '', srSame, edDefault);
      end;
    end;
  end;
end;

function TEMemos.ModifiedCount: Integer;
var
  m: Integer;
begin
  Result:= 0;
  for m:= 0 to Size - 1 do begin
    if Memo[m].Modified
    then Inc(Result);
  end;
end;

end.
