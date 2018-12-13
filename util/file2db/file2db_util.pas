unit
  file2db_util;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  i  l  e  2  d  b  _  u  t  i  l                                         *
*                                                                             *
*   Copyright © 2001-2005 Andrei Ivanov. All rights reserved.                  *
*   Main object module implementation. Part of the                            *
*   utility to load text and blob data to the Interbase/Firebird or any ADO    *
*   database                                                                  *
*                                                                              *
*                                                                             *
*   Conditional defines:  USE_IB  Ib/Fb database                               *
*                         USE_ADO ADO compliant database                      *
*   Revisions    :                                                             *
*   Last revision: Oct 25 2005                                                *
*   Lines        : 35                                                          *
*   History      :                                                            *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)
{.$DEFINE USE_IB}

interface

uses
  SysUtils, Classes, Windows,
  jclUnicode, zLib,
{$IFDEF USE_IB}
  IBDatabase, IBSQL,
{$ENDIF}
{$IFDEF USE_ADO}
  Db, ADODb,
{$ENDIF}
  util1,
  DECUtil, Cipher, Hash,
  Variants, ComObj, ActiveX;

const
  MSG_VERSION = '1.0';
  MSG_COPYRIGHT = 'file2db ' + MSG_VERSION + ' Copyright (c) 2003 Andrei Ivanov.';
  REG_PATH = 'Software\ensen\file2db\1.0';

  STR_DB = 'db';
  STR_USER = 'user';
  STR_PASSWORD = 'password';
{$IFDEF USE_ADO}
  DBPAR_USERNAME = 'User Name';
  DBPAR_PASSWORD = 'Password';
  DEF_FIELD_TYPE = ftMemo; // ftBlob ftMemo;
{$ENDIF}

  function DoCmd: Boolean;

implementation

const
  MAX_IMAGES = 12;
  REGISTER_PRODUCTCODE = 'phrasex';
  CAP_APOOED = 'phrasex';

  DEF_EXTENSIONS = '.wml.htm.html.xhtm.xhtml.oeb.pkg.txn.xml.txt.gif.png.jpg.jpeg.tif.tiff.wav.css.xls';

  REG_URL: String = 'http://www.regsoft.net/purchase.php3?productid=56950';

type
  TMBEnv = class(TObject)
  private
    // FireBird/Interbase
{$IFDEF USE_IB}
    FIBDatabase: TIBDatabase;
    FIBTransaction: TIBTransaction;
    FIBSQL: TIBSQL;
{$ENDIF}
{$IFDEF USE_ADO}
    FBlobFldType: TFieldType;
    FADOConnection: TADOConnection;
    FADOCommand: TADOCommand;
{$ENDIF}
    FCompressionLevel: zLib.TCompressionLevel;
    FldList: TStrings;
    Delimiter,
    CipherKey,
    DEF_ContentType,
    PrefixRemove,
    PrefixAdd,
    dbConnStr,
    TableName,
    UrlCol,
    ColumnDelimiter,
    ContentTypeCol: String;
    ContentCols: TStrings;

    excel_columnlistrow,
    firstrow: Integer;
    LineDelimiter: String;

    mkNull,
    CipherUrl,
    CipherContent,
    CipherContentType: Boolean;

    sourcepath,
    outputpath: String;

    doregister,
    doClear,
    mkLoadDelim,
    mkAddContentFile,
    mkExtract,
    recurse,
    verbose,
    anyExtension,
    getQUERY_STRING,
    getInput,
    SkipIni,
    showhelp: Boolean;

    filelist: TStrings;
  protected
    function ExtractColumnData(ANo: Integer; const Data: String): String;
  public
    Cnt: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure LoadSettings;
    procedure Clear;
    procedure Report(APos, ASize: Cardinal; const AStatus, AMsg: string);
    procedure ThreadDone(Sender: TObject);
  end;

procedure RaiseError(ACode: Integer; const ACodeS: String);
begin
  Writeln('Error ', ACode, ': ', ACodeS);
  Halt(ACode);
end;

function PrintUsage: String;
begin
// free letters are: none
  Result:=
    'Usage: file2db -[?|e|a|x] [Options] File(s)|Mask|Path'#13#10 +
    '  File list: e.g. file1.txt ..\file2.xml'#13#10 +
    '  File mask can include willcards e.g. *.htm'#13#10 +
    '  Commands:'#13#10 +
    '    e - register program -u "user name" -t "registration code"'#13#10 +
    '    l <delimiter> - load delimited text. Use f to list fields'#13#10 +
    '    n <column delimiter> - add content files to database. #9 []'#13#10 +
    '    x - extract files from database'#13#10 +
    '    b <compression level> - 0 - none 1 - fastest 2 - normal 3 - max'#13#10 +
    '  Options:  ? - this screen'#13#10 +
    '    s <database connection string file>'#13#10 +
    '      or -h <DB> -@ <USER> -k <PWD> -# <DIALECT> -! <ROLE> -w <CODEPAGE>'#13#10 +
    '    t <table> - table name'#13#10 +
    '    f <field list> - comma separated list e.g. fld1,"Fld 2"'#13#10 +
    '    u <column name> - url column. Use U to cipher'#13#10 +
    '    c <column1>{,<column2>} - content column(s). Use C to cipher column'#13#10 +
    '    y <column name> - content type column. Use Y to cipher'#13#10 +
    '    m <prefix> - remove file name prefix'#13#10 +
    '    q <prefix> - add file name prefix'#13#10 +
    '    z <mime type> - default MIME type(default application/octet-stream)'#13#10 +
    '    i - clear table before add or after extract'#13#10 +
    '    j <cipher> - cipher key'#13#10 +
    '    o <folder> - extract database to folder'#13#10 +
    '    v - verbose'#13#10 +
    '    r - recurse subfolders'#13#10 +
    '    a - any files, otherwise:' + DEF_EXTENSIONS + #13#10 +
    '      or use file mask *.* (valid for N, L commands)' + #13#10 +    
    '    g - get command line options from QUERY_STRING environment variable <GET>'#13#10 +
    '    p - get command line options from input <POST>'#13#10 +
{$IFDEF USE_ADO}
    '    + <0..n> - ADO blob type [' + IntToStr(Ord(DEF_FIELD_TYPE)) + ']'#13#10 +
{$ENDIF}
    '    1 <1..n> - excel column list (field names row number) [1]'#13#10 +
    '    2 <1..n> - first data row [1]. Excel: 1,2,3.. Text: 1|2'#13#10 +
    '    9 <record delimiter>. [#13#10, ^M^J, #$C#$A]'#13#10 +
    '    0 - make NULL'#13#10 +
    '    d - skip default settings (don''t load file2db.ini)';
end;

const
  OptionsHasExt: TSysCharSet = ['B', 'b', 'N', 'n', 'C', 'c', 'F', 'f', 'J', 'j', 'L', 'l', 'O', 'o', 'S', 's', 'T', 't', 'U', 'u', 'Y', 'y', 'M', 'm', 'Q', 'q', 'Z', 'z',
    'H', 'h', 'K', 'k', '#', '@', '!', '+', 'W', 'w', '1', '2', '9'];

function StdEncode(var Buf: String; Pwd: String): Boolean;
begin
  Result:= False;
  { Encrypt the data }
  with TCipher_Blowfish.Create(Pwd, nil) do
  try
    Mode:= TCipherMode(cmCTS);
    Buf:= CodeString(Buf, paEncode, fmtCOPY);
    Result:= True;
  finally
    Free;
  end;
end;

function Decompress(var Buf: String): Boolean;
var
  zd: TDeCompressionStream;
  b: array[0..1023] of Byte;
  strmIn: TStream;
  c, len: Cardinal;
begin
  Result:= False;
  { Decompress the data }
  strmIn:= TStringStream.Create(buf);
  zd:= zlib.TDeCompressionStream.Create(strmin);

  buf:= '';
  len:= 0;
  repeat
    c:= zd.Read(b, SizeOf(b));
    if c > 0 then begin
      SetLength(buf, c + len);
      Move(b, Buf[len + 1], c);
      Inc(len, c);
    end;
    if c < SizeOf(b)
    then Break;
  until False;
  zd.Free;
  strmIn.Free;
end;

function Compress(var Buf: String; ACompressionLevel: TCompressionLevel): Boolean;
var
  zc: TCompressionStream;
  strmIn,
  strmOut: TStream;
  c, len: Cardinal;
begin
  Result:= False;
  { Decompress the data }
  strmIn:= TStringStream.Create(buf);
  strmOut:= TStringStream.Create('');
  zc:= zlib.TCompressionStream.Create(ACompressionLevel, strmout);
  zc.CopyFrom(strmIn, strmIn.Size);
  zc.Free;
  strmIn.Free;
  Buf:= TStringStream(strmOut).DataString;
  strmOut.Free;
end;

function StdDecode(var Buf: String; Pwd: String): Boolean;
begin
  Result:= False;
  { Decrypt the data }
  with TCipher_Blowfish.Create(Pwd, nil) do
  try
    Mode:= TCipherMode(cmCTS);
    Buf:= CodeString(Buf, paDecode, fmtCOPY);
    Result:= True;
  finally
    Free;
  end;
end;

{
  Parameters:
    Return:
      AFileList - can be Nil
}
function ExportExcel2TxtFiles(const AExcelFn: String; AFolder: String;
  const AColumnListRow, AFirstRow: Integer;
  ASheetNames, AFileNames, AColumnNames: TStrings; const ADefColumns: String): Boolean;
const
  xlCellTypeLastCell = 11; //ExcelXP unit
var
  XLApp: OleVariant;
  WorkBk, // : _WorkBook;
  WorkSheet: OleVariant;// _WorkSheet;
  K, R, X, Y : Integer;
  IIndex : OleVariant;
  // RangeMatrix: Variant;
  cs, s, line: String;
  sheetname: WideString;
  sheet, sheets: Integer;
  isnotemptyline: Boolean;
  cols: TStrings;
  colFirst, colLast: Integer;
begin
  Result:= False;
  IIndex:= 1;
  // Создаем объект Excel-OLE
  XLApp:= CreateOleObject('Excel.Application');
  try
    XLApp.Visible:= False; //  Connect;
    // Открываем файл Excel
    try
      XLApp.WorkBooks.Open(AExcelFn); //, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);
    except
      on E: Exception do begin
        Writeln(Format('Close opened Excel document %s, error: %s', [AExcelFn, E.Message]));
        Exit;
      end;
    end;

    WorkBk:= XLApp.WorkBooks.Item[IIndex];
    sheets:= WorkBk.WorkSheets.Count;

    for sheet:= 1 to sheets do begin
      WorkSheet:= WorkBk.WorkSheets[sheet];
      sheetname:= WorkSheet.Name;
      if Assigned(ASheetNames) then begin
        ASheetNames.Add(sheetname);
      end;
      // Чтобы знать размер листа (WorkSheet), т.е. количество строк и количество
      // столбцов, мы активируем его последнюю непустую ячейку
      WorkSheet.Select; // (EmptyParam, 0)
      WorkSheet.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
      // Получаем значение последней строки
      X:= XLApp.ActiveCell.Row;
      // Получаем значение последней колонки
      Y:= XLApp.ActiveCell.Column;
      // Сопоставляем матрицу WorkSheet с нашей матрицей
      // RangeMatrix:= XLApp.Range['A1',XLApp.Cells.Item[X,Y]];

      // write column
      if (AColumnListRow > 0) and (AColumnListRow <= x) then begin
        // determine 1st ans last columns
        colFirst:= -1;
        colLast:= y;
        for r:= 1 to y do begin
          if colFirst <= 0 then begin
            if Length(Trim(XLApp.Range[XLApp.Cells.Item[AColumnListRow, r], XLApp.Cells.Item[AColumnListRow, r]].Text)) > 0 then begin
              colFirst:= r;
            end;
            Continue;
          end;
          if Length(Trim(XLApp.Range[XLApp.Cells.Item[AColumnListRow, r], XLApp.Cells.Item[AColumnListRow, r]].Text)) = 0 then begin
            colLast:= r - 1;
            Break;
          end;
        end;
        // store column names
        if Assigned(AColumnNames) then begin
          cols:= TStringList.Create;
          for r:= 1 to y do begin
            cols.Add((XLApp.Range[XLApp.Cells.Item[AColumnListRow, r], XLApp.Cells.Item[AColumnListRow, r]].Text));
          end;
          AColumnNames.Add(cols.CommaText);
          cols.Free;
        end;
      end else begin
        colFirst:= 1;
        colLast:= y;
        // get column list from environment (passed thru command line parameters)
        AColumnNames.Add(ADefColumns);
      end;
      s:= '';
      for k:= AFirstRow to x do begin
        // cs:= RangeMatrix[K, 1];
        isnotemptyline:= False;
        line:= '';
        for r:= colFirst to colLast do begin
          // cs:= RangeMatrix[K, R];
          cs:= Trim(XLApp.Range[XLApp.Cells.Item[k,r], XLApp.Cells.Item[k,r]].Text);
          isnotemptyline:= isnotemptyline or (Length(cs) > 0);
          // escape '|'
          util1.ReplaceStr(cs, True, '|', '!');
          util1.ReplaceStr(cs, True, '''', '''''');
          util1.ReplaceStr(cs, True, '"', '''''');
          if r = 1
          then line:= line + cs
          else line:= line + '|' + cs;
        end;
        if isnotemptyline then begin
          s:= s + line + #13#10;
        end;
      end;
      if Length(s) > 2
      then Delete(s, Length(s) - 1, 2);
      // write to text file
      cs:= ConcatPath(AFolder, sheetname + '.txt', '\');
      util1.String2File(cs, s, True);
      // add created file name into list if list is passed to function
      if Assigned(AFileNames) then begin
        AFileNames.Add(cs);
      end;
      // Уничтожаем RangeMatrix
      // RangeMatrix:= Unassigned;
    end;
    Result:= True;
  finally
    // Выходим из Excel и отсоединяемся от сервера
    if not VarIsEmpty(XLApp) then begin
      XLApp.Quit;
      XLApp:= Unassigned;
    end;
  end;
end;

function ParseCmd(const AConfig: String; AOptionsHasExt: TSysCharSet; Rslt: TStrings): String;
var
  S, os: String;
  o: Char;
  filecount, p, i, L: Integer;
  state: Integer;
  Quoted: Boolean;
begin
  Rslt.Clear;
  S:= AConfig;
  state:= 0;
  i:= 1;
  filecount:= 0;
  L:= Length(S);
  // skip program name
  while i <= L do begin
    if S[i] = #32 then begin
      Inc(i);
      Break;
    end;
    Inc(i);
  end;
  Result:= Copy(S, 1, i - 2);

  Quoted:= False;
  // parse
  while i <= L do begin
    o:= S[i];
    case o of
      '''', '"': begin
          Quoted:= not Quoted;
          Inc(i);
        end;
      '-': begin
          case state of
            0: state:= 1;  // option started
          end;
          Inc(i);
        end;
      #0..#32: begin
          state:= 0;
          Inc(i);
        end;
      else begin
        case state of
          0:begin  // file name or mask
              p:= i;
              if Quoted then begin
                repeat
                  Inc(i);
                until (i > L) or (S[i] in ['''', '"', #0]);
                Quoted:= False;
              end else begin
                repeat
                  Inc(i);
                until (i > L) or (S[i] in [#0..#32]); // , '-' was wrong in case of 'p-bin.rar'
              end;
              os:= Copy(s, p, i - p);
              Inc(filecount);
              Rslt.AddObject('=' + os, TObject(filecount));
            end;
          1: begin  // option
              if S[i] in AOptionsHasExt then begin  // option has next parameter
                //
                // skip spaces if exists
                Inc(i);
                while (i <= L) and (S[i] <= #32) do Inc(i);
                if (S[i] = '-') then begin // Jan 2006 check added
                  // invalid option- no value
                  Rslt.Add(o + '=');
                  Dec(i);
                end else begin
                  // get option's parameter
                  p:= i;
                  Quoted:= (i <= L) and (s[i] in ['''', '"']);
                  if Quoted then begin
                    Inc(p);
                    repeat
                      Inc(i);
                    until (i > L) or (S[i] in [#0, '''', '"']);
                    os:= Copy(s, p, i - p);
                    Inc(i);
                    Quoted:= False;
                  end else begin
                    repeat
                      Inc(i);
                    until (i > L) or (S[i] in [#0..#32, '-']); // possible '-' is wrong 
                    os:= Copy(s, p, i - p);
                  end;
                  // add option
                  Rslt.Add(o + '=' + os);
                end;
              end else begin
                // add option
                Rslt.Add(o + '=');
                Inc(i);
              end;
            end;
          else begin
            Inc(i);
          end;
        end; { case state }
        //
      end; { else case }
    end; { case }
  end;
end;

{ calc count of switches
}
function GetSwitchesCount(const ASwitches: TSysCharSet; opts: TStrings): Integer;
var
  i: Integer;
  s: String;
begin
  Result:= 0;
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    if (Length(s) > 0) and (s[1] in ASwitches)
    then Result:= Result + 1;
  end;
end;

{ extract switch values
}
function ExtractSwitchValue(ASwitches: TSysCharSet; opts: TStrings): String;
var
  i, l: Integer;
  s: String;
begin
  Result:= '';
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    l:= Length(s);
    if ((l > 0) and (s[1] in ASwitches))
      or ((l = 0) and (ASwitches = [])) then begin
      Result:= Copy(opts[i], l + 2, MaxInt);
    end;
  end;
end;

{ extract switch values
}
function ExtractSwitchValues(ASwitches: TSysCharSet; opts: TStrings; ARslt: TStrings): Integer;
var
  i, l: Integer;
  s: String;
begin
  Result:= 0;
  for i:= 0 to opts.Count - 1 do begin
    s:= opts.Names[i];
    l:= Length(s);
    if ((l > 0) and (s[1] in ASwitches))
      or ((l = 0) and (ASwitches = [])) then begin
      s:= Copy(opts[i], l + 2, MaxInt);
      ARslt.AddObject(s, opts.Objects[i]);
      Result:= Result + 1;
    end;
  end;
end;

function HTTPDecode(const AStr: String): String;
var
  Sp, Rp, Cp: PChar;
  S: String;
begin
  SetLength(Result, Length(AStr));
  Sp := PChar(AStr);
  Rp := PChar(Result);
//  Cp := Sp;
  try
    while Sp^ <> #0 do
    begin
      case Sp^ of
        '+': Rp^ := ' ';
        '%': begin
               // Look for an escaped % (%%) or %<hex> encoded character
               Inc(Sp);
               if Sp^ = '%' then
                 Rp^ := '%'
               else
               begin
                 Cp := Sp;
                 Inc(Sp);
                 if (Cp^ <> #0) and (Sp^ <> #0) then
                 begin
                   S := '$' + Cp^ + Sp^;
                   Rp^ := Chr(StrToInt(S));
                 end
                 else
                   RaiseError(3, 'Invalid encoded URL');
               end;
             end;
      else
        Rp^ := Sp^;
      end;
      Inc(Rp);
      Inc(Sp);
    end;
  except
    on E:EConvertError do
      RaiseError(3, 'Invalid encoded URL');
  end;
  SetLength(Result, Rp - PChar(Result));
end;

procedure ExtractHeaderFields(Separators, WhiteSpace: TSysCharSet; Content: PChar;
  Strings: TStrings; Decode: Boolean; StripQuotes: Boolean = False);
var
  Head, Tail: PChar;
  EOS, InQuote, LeadQuote: Boolean;
  QuoteChar: Char;

  function DoStripQuotes(const S: string): string;
  var
    I: Integer;
  begin
    Result := S;
    if StripQuotes then
      for I := Length(Result) downto 1 do
        if Result[I] in ['''', '"'] then
          Delete(Result, I, 1);
  end;

begin
  if (Content = nil) or (Content^ = #0) then Exit;
  Tail := Content;
  QuoteChar := #0;
  repeat
    while Tail^ in WhiteSpace + [#13, #10] do Inc(Tail);
    Head := Tail;
    InQuote := False;
    LeadQuote := False;
    while True do
    begin
      while (InQuote and not (Tail^ in [#0, #13, #10, '"'])) or
        not (Tail^ in Separators + [#0, #13, #10, '"']) do Inc(Tail);
      if Tail^ = '"' then
      begin
        if (QuoteChar <> #0) and (QuoteChar = Tail^) then
          QuoteChar := #0
        else
        begin
          LeadQuote := Head = Tail;
          QuoteChar := Tail^;
          if LeadQuote then Inc(Head);
        end;
        InQuote := QuoteChar <> #0;
        if InQuote then
          Inc(Tail)
        else Break;
      end else Break;
    end;
    if not LeadQuote and (Tail^ <> #0) and (Tail^ = '"') then
      Inc(Tail);
    EOS := Tail^ = #0;
    Tail^ := #0;
    if Head^ <> #0 then
      if Decode then
        Strings.Add(DoStripQuotes(HTTPDecode(Head)))
      else Strings.Add(DoStripQuotes(Head));
    Inc(Tail);
  until EOS;
end;

procedure EmptyNames(AName: String; AStrings: TStrings);
var
  i: Integer;
  p: Integer;
  s: String;
begin
  for i:= 0 to AStrings.Count - 1 do begin
    s:= AStrings[i];
    p:= Pos('=', s);
    if p = 0 then begin
      s:= s + '=';
      AStrings[i]:= s;
    end else begin
      if CompareText(AName, Copy(s, 1, p - 1)) = 0 then begin
        Delete(s, 1, p);
        AStrings[i]:= '=' + s;
      end;
    end;
  end;
end;

function SimpleGetMimeType(const AURI: String): String;
begin
  Result:= util1.MIMEByExt(AUri);
end;

function QuoteDbObjectName(AName: String): String;
const
  QUOTE_CHAR = ''''; // "
var
  i, len: Integer;
  f: Boolean;
begin
  // find spaces
  len:= Length(AName);
  f:= False;
  for i:= 1 to len do begin
    if AName[i] <= #32 then begin
      f:= True;
      Break;
    end;
  end;
  if f then begin
  {$IFDEF USE_IB}
    Result:= Quote_Char + AName + Quote_Char;
  {$ENDIF}
  {$IFDEF USE_ADO}
    Result:= Quote_Char + AName + Quote_Char;
  {$ENDIF}
  end else Result:= AName;
end;

function Readline(var T: Text; const ALineDelimiter: String; var S: String): Boolean; // NOT TESTED YET!!!
var
  ch: Char;
  c: Integer;
  len: Integer;
begin
  Result:= True;
  len:= Length(ALineDelimiter);
  if (len = 0) or (ALineDelimiter = #13#10)
  then Readln(t, s) else begin
    c:= 1;
    s:= '';
    while not EOF(t) do begin
      Read(t, ch);
      if ch = ALineDelimiter[c] then begin
        Inc(c);
        if c > len then begin
          Exit;
        end;
      end else s:= s + ch;
    end;
  end;
end;

function ProcessFile(const AFN: String; AEnv: TObject): Boolean;
var
  s, data, dataAll, contenttype, ofn, p, f, ext, np: String;
  SamePlace: Boolean;
  Strm: TStream;
  col, rec: Integer;
  t: Text;

  procedure AddColumns(const AUrl: String; var AData: String);
  var
    c, cols: Integer;

    procedure PrepareEntireOrPiece(var ADataStr: String);
    // designed to avoid copy of string
    begin
      with TMBEnv(AEnv) do begin
        if FCompressionLevel > clNone
        then Compress(ADataStr, FCompressionLevel);
        if CipherContent then begin
          StdEncode(ADataStr, CipherKey);
        end;

        if verbose and (cols > 1) then begin
          Writeln(Format(#9'column %d'#9'%d byte(s)', [c, Length(ADataStr)]));
        end;
        strm:= TStringStream.Create(ADataStr);
      end;
    end;

  begin
    with TMBEnv(AEnv) do begin
{$IFDEF USE_IB}
      with FIBSQL do begin
        Close;
        SQL.Text:= s;
        ParamByName('url').AsString:= AUrl;

        if (Length(ContentTypeCol) > 0) then begin
          ParamByName('contenttype').AsString:= contenttype;
        end;
      end;
{$ENDIF}
{$IFDEF USE_ADO}
      with FADOCommand do begin
        Cancel;
        CommandText:= s;
        Parameters.ParamByName('url').Value:= AUrl;

        if (Length(ContentTypeCol) > 0) then begin
          Parameters.ParamByName('contenttype').Value:= contenttype;
        end;
      end;
{$ENDIF}
      cols:= ContentCols.Count;
      for c:= 0 to cols - 1 do begin
        // parse content
        if Length(AData) = 0
        then Break; // no more data
        if cols = 1 then begin
          PrepareEntireOrPiece(AData);  // prepare stream for all data we have
        end else begin
          data:= ExtractColumnData(c, AData);
          if Length(data) = 0
          then Continue; // no data in this piece
          PrepareEntireOrPiece(Data); // prepare stream for chunk of data just extracted
        end;
        strm.Position:= 0;
{$IFDEF USE_IB}
        FIBSQL.ParamByName('data' + IntToStr(c)).LoadFromStream(strm);
{$ENDIF}
{$IFDEF USE_ADO}
        FADOCommand.Parameters.ParamByName('data' + IntToStr(c)).LoadFromStream(strm, FBlobFldType);
{$ENDIF}
        strm.Free;
      end;
      try
{$IFDEF USE_IB}
        with FIBSQL do begin
          Prepare;
          ExecQuery;
        end;
{$ENDIF}
{$IFDEF USE_ADO}
        with FADOCommand do begin
          Prepared:= True;
          FADOCommand.Execute;
        end;
{$ENDIF}
      except
        on E: Exception do begin
          Writeln(Format('Transfer file %s to table %s with name %s error:'#9'%s', [AFN, TableName, AUrl, E.Message]));
          Result:= False;
        end;
      end;
    end;
  end;

begin
  Result:= True;

  ext:= ExtractFileExt(AFN);
  f:= ExtractFileName(AFN);
  p:= ExtractFilePath(AFN);

  with TMBEnv(AEnv) do begin
    if not AnyExtension then begin
      if Pos(LowerCase(ext), DEF_EXTENSIONS) = 0
      then Exit;
    end;

    SamePlace:= mkAddContentFile or ((Length(outputpath) = 0) or (outputpath = '.'));

    ofn:= AFN;

    if SamePlace then begin
      np:= '';
    end else begin
      ofn:= ConcatPath(outputpath, util1.DiffPath(sourcepath, ofn), '\');
      np:= ExtractFilePath(ofn);
    end;

    if Pos('file://', LowerCase(ofn)) = 1
    then ofn:= Copy(ofn, Length('file://') + 1, MaxInt);

    if Length(PrefixRemove) > 0 then begin
      if Pos(PrefixRemove, Uppercase(ofn)) = 1 then begin
        Delete(ofn, 1, Length(PrefixRemove));
      end;
    end;
    if Length(PrefixAdd) > 0 then begin
      ofn:= PrefixAdd + ofn;
    end;

    repeat until not util1.ReplaceStr(ofn, False, '\', '/');
    while (Length(ofn) > 0) and (ofn[1] in ['.', ':']) do Delete(ofn, 1, 1);

    if verbose then begin
      Writeln(Format('%s'#9'->'#9'%s', [AFN, ofn]));
    end;

    Cnt:= TMBEnv(AEnv).Cnt + 1;

    ContentType:= SimpleGetMimeType(ofn);
    if Length(ContentType) = 0
    then ContentType:= DEF_ContentType;

    s:= 'INSERT INTO ' + QuoteDbObjectName(TableName) + ' (' + UrlCol;

    for col:= 0 to ContentCols.Count - 1 do s:= s + ', ' + ContentCols[col];

    if Length(ContentTypeCol) > 0
    then s:= s + ', ' + ContentTypeCol + '';

    s:= s + ') VALUES (:url';
    for col:= 0 to ContentCols.Count - 1 do s:= s + ', :data' + IntToStr(col);

    if Length(ContentTypeCol) > 0
    then s:= s + ', :contenttype';
    s:= s + ')';


    if CipherUrl then begin
      StdEncode(ofn, CipherKey);
    end;

    if (Length(ContentTypeCol) > 0) and CipherContenttype then begin
      StdEncode(contenttype, CipherKey);
    end;

    // -N <ColumnDelimiter> -9 line delimiter. if none, ''
    if LineDelimiter = '' then begin
      dataAll:= util1.File2String(afn);
      AddColumns(ofn, dataAll);
    end else begin
      // Read "lines"
      AssignFile(t, ofn);
      Reset(t);
      rec:= 0;
      while not EOF(t) do begin
        ReadLine(t, LineDelimiter, dataAll);
        Inc(rec);
        if verbose then begin
          Writeln(Format(#9'record %d'#9'%d byte(s)', [rec, Length(dataAll)]));
        end;
        AddColumns(ofn + '.' + IntToStr(rec), dataAll);
      end;
      CloseFile(t);
    end;
  end;
end;

function LoadDelimText(const AFN: String; AEnv: TObject): Boolean;
var
  v, ext, tmpfolder: String;
  f: Integer;
  Strm: TStream;
{$IFDEF USE_IB}
  DelimInput: TIBInputDelimitedFile;
{$ENDIF}
  cflds,
  sheetnames,
  filenames,
  columnnames: TStrings;

{$IFDEF USE_IB}
  procedure LoadDelimInput(const AFileName: String; const ATableName: String;
    const AFldList: TStrings);
  var
    i: Integer;
  begin
    with TMBEnv(AEnv), FIBSQL do begin
      DelimInput.Filename:= AFileName;
      Close;
      v:= '';
      for i:= 0 to AFldList.Count - 1 do begin
        v:= v + ':' + AFldList[i] + ',';
      end;
      repeat until not util1.ReplaceStr(v, False, #32, '_');
      // delete last ','
      if Length(v) > 0 then System.Delete(v, Length(v), 1);

      SQL.Text:= 'INSERT INTO ' + QuoteDbObjectName(ATableName) + ' (' + AFldList.CommaText + ') VALUES (' + v + ')';
      try
        try
          FIBSQL.BatchInput(DelimInput);
        except
          on E: Exception do begin
            Writeln(Format('Loading file %s to table %s error:'#9'%s', [AFN, ATableName, E.Message]));
            Result:= False;
          end;
        end;
      finally
      end;
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  procedure LoadDelimInput(const AFileName: String; const ATableName: String;
    const AFldList: TStrings);
  var
    i, cnt1, cnt2: Integer;
    t: Text;
    s: String;
    sl: TStrings;

  begin
    with TMBEnv(AEnv), FADOCommand do begin
      // load AFileName to 0..n fields of ATableName
      Cancel;
      v:= '';
      for i:= 0 to AFldList.Count - 1 do begin
        v:= v + ':' + AFldList[i] + ',';
      end;
      repeat until not util1.ReplaceStr(v, False, #32, '_');
      // delete last ','
      if Length(v) > 0 then System.Delete(v, Length(v), 1);

      CommandText:= 'INSERT INTO ' + ATableName + ' (' + AFldList.CommaText + ') VALUES (' + v + ')';
      try
        AssignFile(t, AFileName);
        Reset(t);
        i:= 1;

        while not System.EOF(t) and (i < firstrow) do begin
          Readline(t, LineDelimiter, s);
          Inc(i);
        end;

        sl:= TStringList.Create;
        sl.Delimiter:= Delimiter[1];
        while not System.EOF(t) do begin
          Readline(t, LineDelimiter, s);
          s:= Trim(s);
          if Length(s) = 0
          then Continue;
          if Parameters.Count > 1
          then sl.DelimitedText:= s
          else sl.Text:= s;

          if sl.Count < Parameters.Count then begin
            cnt1:= sl.Count;
            cnt2:= Parameters.Count;
          end else begin
            cnt1:= Parameters.Count;
            cnt2:= 0;
          end;
          for i:= 0 to cnt - 1 do begin
            s:= sl[i];
            if Length(s) = 0
            then Parameters[i].Value:= Null
            else Parameters[i].Value:= s;
          end;

          for i:= cnt1 to cnt2 - 1 do begin
            Parameters[i].Value:= Null;
          end;
          Execute;

        end;
        sl.Free;
        CloseFile(t);
      except
        on E: Exception do begin
          Writeln(Format('Loading file %s to table %s error:'#9'%s', [AFN, ATableName, E.Message]));
          Result:= False;
        end;
      end;
    end;
  end;
{$ENDIF}

begin
  Result:= True;

  ext:= ExtractFileExt(AFN);

  with TMBEnv(AEnv) do begin
    if not AnyExtension then begin
      if Pos(LowerCase(ext), DEF_EXTENSIONS) = 0
      then Exit;
    end;

    if verbose then begin
      Writeln(Format('%s'#9'->'#9'%s', [AFN, TableName]));
    end;

    Cnt:= TMBEnv(AEnv).Cnt + 1;

{$IFDEF USE_IB}
    // load delimited file afn
    DelimInput:= TIBInputDelimitedFile.Create;
    with DelimInput do begin
      DelimInput.RowDelimiter:= LineDelimiter;
      ColDelimiter:= Delimiter;
      SkipTitles:= firstrow > 1;
      ReadBlanksAsNull:= mkNull; // ?!! 
    end;
{$ENDIF}

    if CompareText(ext, '.xls') = 0 then begin
      // load excel tables
      ActiveX.CoInitialize(Nil);
      sheetnames:= TStringList.Create;
      filenames:= TStringList.Create;
      columnnames:= TStringList.Create;
      cflds:= TStringList.Create;

      // create temporary text files in TEMP folder
      SetLength(tmpfolder, 512);
      windows.GetTempPath(511, PChar(@(tmpfolder[1])));
      tmpfolder:= PChar(tmpfolder);

      // process each sheet as table. Sheet name is table name
      if ExportExcel2TxtFiles(ExpandFileName(afn), tmpfolder, excel_columnlistrow, firstrow,
        sheetnames, filenames, columnnames, fldlist.CommaText) then begin
        // get column list from environment (passed thru command line parameters)
        for f:= 0 to filenames.Count - 1 do begin
          cflds.CommaText:= columnnames[f];
          LoadDelimInput(filenames[f], sheetnames[f], cflds);
          DeleteFile(PChar(filenames[f]));
        end;
      end;

      cflds.Free;
      sheetnames.Free;
      filenames.Free;
      columnnames.Free;
      ActiveX.CoUnInitialize;
    end else begin
      // load text files
      LoadDelimInput(afn, tablename, fldlist);
    end;
{$IFDEF USE_IB}
    DelimInput.Free;
{$ENDIF}
end;
end;

procedure Extract(AEnv: TObject);
var
  s, data, dataAll, p, url, fn, np: String;
  SamePlace: Boolean;
  i, c: Integer;
  Strm: TStream;
  FileHandle: Integer;
{$IFDEF USE_ADO}
  rs: _RecordSet;
{$ENDIF}
begin
  with TMBEnv(AEnv) do begin
    // output folder
    np:= ExpandFileName(outputpath);

    s:= 'SELECT ' + UrlCol;

    for c:= 0 to ContentCols.Count - 1 do s:= s + ', ' + ContentCols[c];
    s:= s + ' FROM ' + QuoteDbObjectName(TableName)  + ' ORDER BY ' + UrlCol;

    try
{$IFDEF USE_IB}
      with FIBSQL do begin
        Close;
        SQL.Text:= s;
        Prepare;
        ExecQuery;
      end;
{$ENDIF}
{$IFDEF USE_ADO}
      with FADOCommand do begin
        Cancel;
        CommandText:= s;
        rs:= Execute;
      end;
{$ENDIF}
    except
      on E: Exception do begin
        Writeln(Format('Extract records from %s error:'#9'%s', [TableName, E.Message]));
        if verbose then Writeln(s);
      end;
    end;

{$IFDEF USE_IB}
    while not FIBSQL.EOF do begin
      url:= FIBSQL.Fields[0].AsString;
{$ENDIF}
{$IFDEF USE_ADO}
    while not rs.EOF do begin
      url:= rs.Fields[0].Value;
{$ENDIF}
      if CipherUrl then begin
        StdDecode(url, CipherKey);
      end;

      repeat until not util1.ReplaceStr(url, False, '/', '\');

      dataAll:= '';
      for c:= 0 to ContentCols.Count - 1 do begin
{$IFDEF USE_IB}
        data:= FIBSQL.Fields[c + 1].AsString;
{$ENDIF}
{$IFDEF USE_ADO}
        data:= rs.Fields[c + 1].Value;
{$ENDIF}

        if CipherContent
        then StdDecode(data, CipherKey);
        if FCompressionLevel > clNone
        then Decompress(data);
        dataAll:= dataAll + ColumnDelimiter + data;
      end;
      // write to the file
      if IsAbsolutePath(url) then Delete(url, 1, 1);
      fn:= ConcatPath(np, url, '\');
      if verbose then begin
        Writeln(Format('%s'#9'->'#9'%s', [url, p]));
      end;
      p:= ExtractFilePath(fn);
      if not DirectoryExists(p) then begin
        if not ForceDirectories(p) then begin
          Writeln('Can not create folder '+ p);
          Exit;
        end;
      end;
      FileHandle:= FileCreate(fn);
      if FileHandle >= 0 then begin
        FileWrite(FileHandle, dataAll[1], Length(dataAll));
        FileClose(fileHandle);
      end;
{$IFDEF USE_IB}
      FIBSQL.Next;
{$ENDIF}
{$IFDEF USE_ADO}
      rs.MoveNext;
{$ENDIF}
    end;
  end;
{$IFDEF USE_ADO}
      rs.Close;
{$ENDIF}

end;

function PrintSettings(AEnv: TMBEnv): String;
const
  R: array[Boolean] of String = ('', 'recurse subdirectories, ');
  V: array[Boolean] of String = ('', 'verbose output, ');
  D: array[Boolean] of String = ('', 'ini file settings skipped, ');
  Q: array[Boolean] of String = ('', 'HTTP GET method, ');
  G: array[Boolean] of String = ('', 'HTTP POST method, ');
  X: array[Boolean] of String = ('known xml docs only, ', 'any file, ');

var
  p: Integer;
begin
  with AEnv do begin
    Result:=
      'Switches:'#13#10+
      '  output folder: ' + AEnv.outputpath + #13#10 +
      '  translation mode: ' + #13#10'  ' +
        R[recurse] + V[verbose] + Q[getQUERY_STRING] + G[getInput] + D[SkipIni] +
          X[anyExtension] + #13#10 +
      'File(s) or file mask:'#13#10;
    for p:= 0 to AEnv.filelist.Count - 1 do begin
      Result:= Result + '  ' + filelist[p] + #13#10;
    end;
  end;
end;

function CheckParameters(AOpts: TStrings; AEnv: TMBEnv): Boolean;
var
  i: Integer;
  s: String;
begin
  ExtractSwitchValues([], Aopts, AEnv.filelist);
  { check '.', '..' and other directory specs }
  for i:= 0 to AEnv.filelist.Count - 1 do begin
    if DirectoryExists(AEnv.filelist[i]) then begin
      s:= ConcatPath(AEnv.filelist[i], '*.*', '\');
      AEnv.filelist[i]:= s;
    end;
  end;
  with AEnv do begin
    // regiter command
    doregister:= GetSwitchesCount(['e', 'E'], AOpts) > 0;
    // FormatStr:= ExtractSwitchValue(['m', 'M'], AOpts);
    // if Length(FormatStr) = 0 then FormatStr:= DEF_FORMATSTR;

    // command
    mkAddContentFile:= GetSwitchesCount(['N', 'n'], AOpts) > 0;
    MkExtract:=  GetSwitchesCount(['X', 'x'], AOpts) > 0;
    mkLoadDelim:=  GetSwitchesCount(['L', 'l'], AOpts) > 0;

    // options
    outputpath:= ExtractSwitchValue(['O', 'o'], AOpts);
    if Length(outputpath) > 0
    then outputpath:= ExpandFileName(outputpath);

    // -l load options
    Delimiter:= ExtractSwitchValue(['L', 'l'], AOpts);
    FldList.CommaText:= ExtractSwitchValue(['F', 'f'], AOpts);

    // other options
    doClear:= GetSwitchesCount(['I', 'i'], AOpts) > 0;
    dbConnStr:= util1.LoadString(ExtractSwitchValue(['S', 's'], AOpts));
    if Length(dbConnStr) < 2 then begin
      dbConnStr:= Format('db="%s";user="%s";password="%s";lc_ctype="%s";sql_role_name="%s";dialect="%s";', [
        ExtractSwitchValue(['H', 'h'], AOpts),
        ExtractSwitchValue(['@'], AOpts),
        ExtractSwitchValue(['K', 'k'], AOpts),
        ExtractSwitchValue(['W', 'w'], AOpts),
        ExtractSwitchValue(['!'], AOpts),
        ExtractSwitchValue(['#'], AOpts)
      ]);
    end;

{$IFDEF USE_ADO}
    s:= ExtractSwitchValue(['+'], AOpts);
    if Length(s) > 0 then begin
      FBlobFldType:= TFieldType(StrToIntDef(s, Ord(DEF_FIELD_TYPE)));
    end;
{$ENDIF}

    s:= ExtractSwitchValue(['1'], AOpts);
    if Length(s) > 0 then begin
      AEnv.excel_columnlistrow:= StrToIntDef(s, 1);
    end;

    s:= ExtractSwitchValue(['2'], AOpts);
    if Length(s) > 0 then begin
      AEnv.firstrow:= StrToIntDef(s, 2);
    end;

    s:= ExtractSwitchValue(['9'], AOpts);
    if Length(s) > 0 then begin
      AEnv.LineDelimiter:= PascalString(s);
    end else begin
      if AEnv.mkLoadDelim
      then AEnv.LineDelimiter:= #13#10;
      if AEnv.mkAddContentFile
      then AEnv.LineDelimiter:= '';
    end;

    TableName:= ExtractSwitchValue(['T', 't'], AOpts);
    UrlCol:= ExtractSwitchValue(['U', 'u'], AOpts);
    ContentCols.CommaText:= ExtractSwitchValue(['C', 'c'], AOpts);
    // #9- tab, ; - comma
    ColumnDelimiter:= util1.PascalString(ExtractSwitchValue(['N', 'n'], AOpts));

    ContentTypeCol:= ExtractSwitchValue(['Y', 'y'], AOpts);

    CipherKey:= ExtractSwitchValue(['J', 'j'], AOpts);
    CipherUrl:= GetSwitchesCount(['U'], AOpts) > 0;
    CipherContent:= GetSwitchesCount(['C'], AOpts) > 0;
    CipherContentType:= GetSwitchesCount(['Y'], AOpts) > 0;

    // compression
    AEnv.FCompressionLevel:= clNone;
    s:= ExtractSwitchValue(['B', 'b'], AOpts);
    if Length(s) > 0 then begin
      Byte(AEnv.FCompressionLevel):= StrToIntDef(s, 1);
    end;

    // make NULL    
    mkNull:= GetSwitchesCount(['0'], AOpts) > 0;

    PrefixRemove:= Uppercase(ExtractSwitchValue(['M', 'm'], AOpts));
    PrefixAdd:= ExtractSwitchValue(['Q', 'q'], AOpts);
    DEF_ContentType:= ExtractSwitchValue(['Z', 'z'], AOpts);
    if Length(DEF_ContentType) = 0
    then DEF_ContentType:= 'application/octet-stream'; // 'text/html';

    recurse:= GetSwitchesCount(['r', 'R'], AOpts) > 0;
    verbose:= GetSwitchesCount(['v', 'V'], AOpts) > 0;
    anyExtension:= GetSwitchesCount(['a', 'A'], AOpts) > 0;
    showhelp:= GetSwitchesCount(['?'], AOpts) > 0;
    SkipIni:= GetSwitchesCount(['d', 'D'], AOpts) > 0;
    getQUERY_STRING:= GetSwitchesCount(['g', 'G'], AOpts) > 0;
    getInput:= GetSwitchesCount(['p', 'P'], AOpts) > 0;
  end;
  if Length(AEnv.outputpath) = 0
  then AEnv.outputpath:= '.';
  Result:= DirectoryExists(AEnv.outputpath);
  if not Result
  then Writeln(output, Format('output folder %s does not exists'#13#10, [AEnv.outputpath]))
  else Result:= (AEnv.filelist.Count > 0);
end;

constructor TMBEnv.Create;
begin
  inherited Create;
  Cnt:= 0;
  TableName:= '';
  UrlCol:= '';
  ColumnDelimiter:= '';
  ContentCols:= TStringList.Create;
  ContentTypeCol:= '';
  FldList:= TStringList.Create;
  Delimiter:= #9;

  Excel_ColumnListRow:= 1;
  FirstRow:= 1;
  LineDelimiter:= #13#10;

{$IFDEF USE_IB}
  FIBDatabase:= TIBDatabase.Create(Nil);
  FIBTransaction:= TIBTransaction.Create(Nil);
  FIBSQL:= TIBSQL.Create(Nil);

  FIBDatabase.DefaultTransaction:= FIBTransaction;
  FIBTransaction.DefaultDatabase:= FIBDatabase;
  FIBDatabase.LoginPrompt:= False;
  FIBSQL.Database:= FIBDatabase;
  FIBSQL.Transaction:= FIBTransaction;
{$ENDIF}
{$IFDEF USE_ADO}
  FBlobFldType:= DEF_FIELD_TYPE;
  CoInitialize(Nil);
  FADOConnection:= TADOConnection.Create(Nil);
  FADOCommand:= TADOCommand.Create(Nil);
  FADOCommand.Connection:= FADOConnection;
{$ENDIF}

  CipherKey:= 'NONE'; // Bruce Schneier
  filelist:= TStringList.Create;
end;

function TMBEnv.ExtractColumnData(ANo: Integer; const Data: String): String;
begin
  if ColumnDelimiter = ''
  then Result:= Data
  else Result:= util1.GetToken(ANo + 1,  ColumnDelimiter, Data);
end;

procedure TMBEnv.Clear;
begin
  Cnt:= 0;
  filelist.Clear;
  FldList.Free;
end;

destructor TMBEnv.Destroy;
begin
{$IFDEF USE_ADO}
  FADOCommand.Free;
  FADOConnection.Free;
{$ENDIF}

{$IFDEF USE_IB}
  FIBSQL.Free;
  FIBTransaction.Free;
  FIBDatabase.Free;
{$ENDIF}

  filelist.Free;
  ContentCols.Free;
  inherited Destroy;
end;

procedure TMBEnv.Report(APos, ASize: Cardinal; const AStatus, AMsg: string);
begin
end;

procedure TMBEnv.ThreadDone(Sender: TObject);
begin
  {
  if Assigned(FstrmPhrase)
  then FreeAndNil(FstrmPhrase);
  }
end;

// load dictionary
procedure TMBEnv.LoadSettings;
begin
end;

{$IFDEF USE_IB}
function OpenDbConn(AIBDatabase: TIBDatabase; AIBTransaction: TIBTransaction; const ADatabaseName, ADbConnStr: WideString): Boolean;
{$ENDIF}
{$IFDEF USE_ADO}
function OpenDbConn(AADOConnection: TADOConnection; const ADatabaseName, ADbConnStr: WideString): Boolean;
{$ENDIF}
var
  sl: TStrings;
  i, L: Integer;
{$IFDEF USE_ADO}
  conn: TStrings;
  connstr: String;
{$ENDIF}
begin
  Result:= True;
  // dbs=db01;user=SYSDBA;password=CHANGE_ON_INSTALL;
  sl:= TStringList.Create;

  // sl.Delimiter:= ';';   sl.QuoteChar:= '"'; sl.DelimitedText:= expr;
  util1.SetStringsDelimitedTextWithSpace(sl, '"', ';', ADbConnStr);
{$IFDEF USE_IB}
  try
    with AIBDatabase do begin
      if AIBTransaction.InTransaction
      then AIBTransaction.Commit;

      DatabaseName:= sl.Values['db']; // ExpandFileName(sl.Values['db']); // it is wrong because localhost was omitted
      { set SQL dialect }
      i:= sl.IndexOfName('dialect');
      if i >= 0 then begin
        L:= StrToIntDef(sl.Values['dialect'], -1);
        if (L >= 1) and (SQLDialect <> L)
        then SQLDialect:= L;
        sl.Delete(i);
      end;

      { other parameters }
      Params.Assign(sl);
      // delete 'db', 'user', 'password', 'dialect'
      with Params do begin
        i:= IndexOfName('db');
        if i >= 0 then Delete(i);
        i:= IndexOfName('user');
        if i >= 0 then Delete(i);
        i:= IndexOfName('password');
        if i >= 0 then Delete(i);
      end;

      Params.Values['user_name']:= sl.Values['user'];
      // AIBDatabase.Params.Values[DBPAR_ROLE]:= sl.Values[STR_ROLE];
      Params.Values['password']:= sl.Values['password'];

      // I hope dataset still closed
      Open;

      AIBTransaction.StartTransaction;
    end;
  except
    on E: Exception do begin
      Writeln(E.Message); // do not provide ADbConnStr to secure
      Result:= False;
    end;
  end;
{$ENDIF}

{$IFDEF USE_ADO}
// Provider	The name of the provider to use for the connection.
// File name	The name of a file containing connection information.
// Remote Provider	The name of the provider to use for a client-side connection.
// Remote Server	The path name of the server to use for a client-side connection.

    conn:= TStringList.Create;
    with conn do begin
      Delimiter:= ';';
      QuoteChar:= '"';
      connstr:= sl.Values[STR_DB];
      // delete quotes from conn str
      L:= Length(connstr);
      if (L > 0) and (connstr[1] = '"') then begin
        System.Delete(connstr, 1, 1);
        Dec(L);
        if (L > 0) and (connstr[L] = '"') then System.Delete(connstr, L, 1);
      end;

      // add new username and password
      util1.SetStringsDelimitedTextWithSpace(conn, '"', ';', connstr);
      if Length(sl.Values[STR_USER]) > 0 then Values[DBPAR_USERNAME]:= sl.Values[STR_USER];
      if Length(sl.Values[STR_PASSWORD]) > 0 then Values[DBPAR_PASSWORD]:= sl.Values[STR_PASSWORD];
      connstr:= '';
      for l:= 0 to Count - 1 do begin
        connstr:= connstr + Strings[l] + ';';
      end;
      L:= Length(connstr);
      if L > 0 then System.Delete(connstr, L, 1); // delete last ';'
      try
        with AADOConnection do begin
          Close;
          ConnectionString:= connstr;
          Open;
          BeginTrans;
        end;
      except
        on E: Exception do begin
          Writeln(E.Message); // do not provide ADbConnStr to secure
          Result:= False;
        end;
      end;
    end;
{$ENDIF}
  sl.Free;
end;

{$IFDEF USE_IB}
function CloseDbConn(AIBDatabase: TIBDatabase; AIBTransaction: TIBTransaction): Boolean;
{$ENDIF}
{$IFDEF USE_ADO}
function CloseDbConn(AADOConnection: TADOConnection): Boolean;
{$ENDIF}

begin
{$IFDEF USE_IB}
  AIBTransaction.Commit;
  AIBDatabase.Close;
{$ENDIF}
{$IFDEF USE_ADO}
  // AADOQuery.;
  if AADOConnection.InTransaction
  then AADOConnection.CommitTrans;
{$ENDIF}
  Result:= True;
end;

function DoCmd: Boolean;
label
  LSkipIni, Stopped;
var
  ElapsedTime: TDateTime;
  f: Integer;
  config,
  configfn: String;
  cvrtEnv: TMBEnv;
  opts: TStrings;
  skipinicount: Integer;

  procedure ClearTable;
  begin
{$IFDEF USE_IB}
    with cvrtEnv.FIBSQL do begin
      Close;
      SQL.Text:= 'DELETE FROM ' + QuoteDbObjectName(cvrtEnv.TableName);
      Prepare;
      ExecQuery;
    end;
{$ENDIF}
{$IFDEF USE_ADO}
    with cvrtEnv.FADOCommand do begin
      Cancel;
      CommandText:= 'DELETE FROM ' + QuoteDbObjectName(cvrtEnv.TableName);
      Prepared:= True;
      Execute;
    end;
{$ENDIF}
  end;
  
begin
  Result:= False;
  skipinicount:= 0;
  ElapsedTime:= Now;
  cvrtEnv:= TMBEnv.Create;
  // validate is registered version
  // ValidateCode;
  //  if not FProgramIsRegistered then begin end;

  opts:= TStringList.Create;
  configfn:= ConcatPath(ExtractFilePath(ParamStr(0)), 'renum.ini', '\');
  if FileExists(configfn) then begin
    config:= util1.File2String(configfn);
  end else config:= '';
LSkipIni:
  Inc(skipinicount);
  f:= Pos(#32, System.CmdLine);
  if f = 0
  then f:= Length(CmdLine)+1;
  config:= Copy(CmdLine, 1, f - 1) + #32 + config + #32 + Copy(CmdLine, f + 1, MaxInt);
  ParseCmd(config, OptionsHasExt, opts);

  if (not CheckParameters(opts, cvrtEnv)) or (cvrtEnv.showhelp) or (cvrtEnv.doregister) then begin
    if cvrtEnv.doregister then begin
      {
      FRegUser:= ExtractSwitchValue(['u', 'U'], opts);
      FRegCode:= ExtractSwitchValue(['t', 'T'], opts);
      StoreIni;
      ValidateCode;
      Result:= False;
      goto Stopped;
      }
    end;
    Writeln(PrintUsage);
    Result:= False;
    goto Stopped;
  end;

  if cvrtEnv.SkipIni and (skipinicount = 1) then begin
    opts.Clear;
    cvrtEnv.Clear;
    config:= '';
    goto LSkipIni;
  end;

  if cvrtEnv.verbose
  then ;

  if cvrtEnv.getQUERY_STRING then begin
    // read QUERY_STRING
    ExtractHeaderFields(['&'], [], PChar(GetEnvironmentVariable('QUERY_STRING')), opts, True, True);
    EmptyNames('src', opts);
    if not CheckParameters(opts, cvrtEnv) then begin
      RaiseError(6, 'Invalid parameters');
    end;
    cvrtEnv.verbose:= false;
    // cvrtEnv.send2output:= true;
    // Writeln(output, '(((', opts.Text, ')))');
  end;
  if cvrtEnv.getInput then begin
    // read input
    f:= 1;
    while not EOF(input) do begin
      SetLength(config, f);
      Read(input, config[f]);
      Inc(f);
    end;
    ExtractHeaderFields(['&'], [], PChar(config), opts, True, True);
    EmptyNames('src', opts);
    if not CheckParameters(opts, cvrtEnv) then begin
      RaiseError(7, 'Invalid parameters');
    end;
    cvrtEnv.verbose:= false;
  end;

  if cvrtEnv.verbose then begin
    Writeln(PrintSettings(cvrtEnv));
    Writeln('load settings..');
  end;

  // load dictionary
  cvrtEnv.LoadSettings;

  if cvrtEnv.verbose then begin
    Writeln(PrintSettings(cvrtEnv));
    Writeln('Process file(s):');
  end;

  // make connection to the database
  with cvrtEnv do begin
{$IFDEF USE_IB}
    if not OpenDbConn(FIBDatabase, FIBTransaction, 'db', dbConnStr) then begin
{$ENDIF}
{$IFDEF USE_ADO}
    if not OpenDbConn(FADOConnection, 'db', dbConnStr) then begin
{$ENDIF}
      Writeln('can not connect to database');
      Exit;
    end;
    // add to database

    if mkLoadDelim or mkAddContentFile then begin
      if doClear then begin
        if verbose then Writeln('All records from ' + TableName + ' now will be deleted...');
        try
          ClearTable;
        except
          on E: Exception do begin
            Writeln(Format('Deleting all records from %s error:'#9'%s', [TableName, E.Message]));
          end;
        end;
        if verbose then Writeln('All records from ' + TableName + ' deleted.');
      end;
    end;

    if mkAddContentFile then begin
      for f:= 0 to cvrtEnv.filelist.Count - 1 do begin
        sourcepath:= ExtractFilePath(filelist[f]);
        if verbose
        then Writeln(output, #13#10 + filelist[f] + #13#10);

        if DirectoryExists(filelist[f]) then begin
          // directory
          Walk_Tree('*.*', filelist[f], faAnyFile, Recurse, ProcessFile, cvrtEnv);
        end else begin
          if (util1.IsFileMask(filelist[f])) then begin
            AnyExtension:= True;
            Walk_Tree(ExtractFileName(filelist[f]), ExtractFilePath(filelist[f]),
              faAnyFile, Recurse, ProcessFile, cvrtEnv);
          end else begin
            if FileExists(FileList[f]) then begin
              // ordinal file (or filemask- excluded)
              ProcessFile(filelist[f], cvrtEnv);
            end else begin
              // some kind of mask ?
              Walk_Tree(ExtractFileName(filelist[f]),
                ExtractFilePath(filelist[f]), faAnyFile, Recurse, ProcessFile, cvrtEnv);
            end;
          end;
        end;
      end;
    end;

    if mkLoadDelim then begin
      for f:= 0 to cvrtEnv.filelist.Count - 1 do begin
        sourcepath:= ExtractFilePath(filelist[f]);
        if verbose
        then Writeln(output, #13#10 + filelist[f] + #13#10);

        if DirectoryExists(filelist[f]) then begin
          // directory
          Walk_Tree('*.*', filelist[f], faAnyFile, Recurse, LoadDelimText, cvrtEnv);
        end else begin
          if (util1.IsFileMask(filelist[f])) then begin
            AnyExtension:= True;
            Walk_Tree(ExtractFileName(filelist[f]), ExtractFilePath(filelist[f]),
              faAnyFile, Recurse, LoadDelimText, cvrtEnv);
          end else begin
            if FileExists(FileList[f]) then begin
              // ordinal file (or filemask- excluded)
              LoadDelimText(filelist[f], cvrtEnv);
            end else begin
              // some kind of mask ?
              Walk_Tree(ExtractFileName(filelist[f]),
                ExtractFilePath(filelist[f]), faAnyFile, Recurse, LoadDelimText, cvrtEnv);
            end;
          end;
        end;
      end;
    end;

    if mkExtract then begin
      Extract(cvrtEnv);
      if doClear then begin
        try
          ClearTable;
        except
          on E: Exception do begin
            Writeln(Format('Deleting all records from %s error:'#9'%s', [TableName, E.Message]));
          end;
        end;
        if verbose then Writeln('All records from ' + TableName + ' deleted.');
      end;
    end;

    if verbose then begin
      DateTimeToString(config, 'nn:ss', Now - ElapsedTime);
      config:= Format(#13#10'Elapsed time: %s', [config]);
      Writeln(config);
    end;
{$IFDEF USE_IB}
    CloseDbConn(FIBDatabase, FIBTransaction);
{$ENDIF}
{$IFDEF USE_ADO}
    CloseDbConn(FADOConnection);
{$ENDIF}


  end;
stopped:

  cvrtEnv.Free;
  opts.Free;
end;

end.
