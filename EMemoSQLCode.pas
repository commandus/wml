unit
  EMemoSQLCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  S  Q  L  C  o  d  e                                         *
*                                                                             *
*   Copyright © 2001- 2004 Andrei Ivanov. All rights reserved.                 *
*   wireless markup language code highlight and code insight                  *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Feb 23 2004                                                 *
*   Last revision: Feb 23 2004                                                *
*   Lines        : 463                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Graphics,
  EMemo, EMemoCode, wml, customxml, xmlsupported;

type
  TEMemoSQLCode = class(TEMemoCode)
  private
    FKeywordsForeColor: TColor;
    FKeywordsBackColor: TColor;
    {
    FCommentsForeColor: TColor;
    FCommentsBackColor: TColor;
    }
    procedure SetKeywordsForeColor(AValue: TColor);
    procedure SetKeywordsBackColor(AValue: TColor);
    procedure SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
  protected
    procedure ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect); override;
    function GetClassDescription(var R: TxmlClassDesc): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBackgroundColors(AColor: TColor); override;
    property KeywordsForeColor: TColor read FKeywordsForeColor write SetKeywordsForeColor;
    property KeywordsBackColor: TColor read FKeywordsBackColor write SetKeywordsBackColor;
  end;

implementation

const
  IBKEYWORDS: array[0..280] of String[18] = (
    'ACTION', 'ACTIVE', 'ADD',
    'ADMIN', 'AFTER', 'ALL',
    'ALTER', 'AND', 'ANY',
    'AS', 'ASC', 'ASCENDING',
    'AT', 'AUTO', 'AUTODDL',
    'AVG', 'BASED', 'BASENAME',
    'BASE_NAME', 'BEFORE', 'BEGIN',
    'BETWEEN', 'BLOB', 'BLOBEDIT',
    'BUFFER', 'BY', 'CACHE',
    'CASCADE', 'CAST', 'CHAR',
    'CHARACTER', 'CHARACTER_LENGTH', 'CHAR_LENGTH',
    'CHECK', 'CHECK_POINT_LEN', 'CHECK_POINT_LENGTH',
    'COLLATE', 'COLLATION', 'COLUMN',
    'COMMIT', 'COMMITTED', 'COMPILETIME',
    'COMPUTED', 'CLOSE', 'CONDITIONAL',
    'CONNECT', 'CONSTRAINT', 'CONTAINING',
    'CONTINUE', 'COUNT', 'CREATE',
    'CSTRING', 'CURRENT', 'CURRENT_DATE',
    'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURSOR',
    'DATABASE', 'DATE', 'DAY',
    'DB_KEY', 'DEBUG', 'DEC',
    'DECIMAL', 'DECLARE', 'DEFAULT',
    'DELETE', 'DESC', 'DESCENDING',
    'DESCRIBE', 'DESCRIPTOR', 'DISCONNECT',
    'DISPLAY', 'DISTINCT', 'DO',
    'DOMAIN', 'DOUBLE', 'DROP',
    'ECHO', 'EDIT', 'ELSE',
    'END', 'ENTRY_POINT', 'ESCAPE',
    'EVENT', 'EXCEPTION', 'EXECUTE',
    'EXISTS', 'EXIT', 'EXTERN',
    'EXTERNAL', 'EXTRACT', 'FETCH',
    'FILE', 'FILTER', 'FLOAT',
    'FOR', 'FOREIGN', 'FOUND',
    'FREE_IT', 'FROM', 'FULL',
    'FUNCTION', 'GDSCODE', 'GENERATOR',
    'GEN_ID', 'GLOBAL', 'GOTO',
    'GRANT', 'GROUP', 'GROUP_COMMIT_WAIT',
    'GROUP_COMMIT_', 'WAIT_TIME', 'HAVING',
    'HELP', 'HOUR', 'IF',
    'IMMEDIATE', 'IN', 'INACTIVE',
    'INDEX', 'INDICATOR', 'INIT',
    'INNER', 'INPUT', 'INPUT_TYPE',
    'INSERT', 'INT', 'INTEGER',
    'INTO', 'IS', 'ISOLATION',
    'ISQL', 'JOIN', 'KEY',
    'LC_MESSAGES', 'LC_TYPE', 'LEFT',
    'LENGTH', 'LEV', 'LEVEL',
    'LIKE', 'LOGFILE', 'LOG_BUFFER_SIZE',
    'LOG_BUF_SIZE', 'LONG', 'MANUAL',
    'MAX', 'MAXIMUM', 'MAXIMUM_SEGMENT',
    'MAX_SEGMENT', 'MERGE', 'MESSAGE',
    'MIN', 'MINIMUM', 'MINUTE',
    'MODULE_NAME', 'MONTH', 'NAMES',
    'NATIONAL', 'NATURAL', 'NCHAR',
    'NO', 'NOAUTO', 'NOT',
    'NULL', 'NUMERIC', 'NUM_LOG_BUFS',
    'NUM_LOG_BUFFERS', 'OCTET_LENGTH', 'OF',
    'ON', 'ONLY', 'OPEN',
    'OPTION', 'OR', 'ORDER',
    'OUTER', 'OUTPUT', 'OUTPUT_TYPE',
    'OVERFLOW', 'PAGE', 'PAGELENGTH',
    'PAGES', 'PAGE_SIZE', 'PARAMETER',
    'PASSWORD', 'PLAN', 'POSITION',
    'POST_EVENT', 'PRECISION', 'PREPARE',
    'PROCEDURE', 'PROTECTED', 'PRIMARY',
    'PRIVILEGES', 'PUBLIC', 'QUIT',
    'RAW_PARTITIONS', 'RDB$DB_KEY', 'READ',
    'REAL', 'RECORD_VERSION', 'REFERENCES',
    'RELEASE', 'RESERV', 'RESERVING',
    'RESTRICT', 'RETAIN', 'RETURN',
    'RETURNING_VALUES', 'RETURNS', 'REVOKE',
    'RIGHT', 'ROLE', 'ROLLBACK',
    'RUNTIME', 'SCHEMA', 'SECOND',
    'SEGMENT', 'SELECT', 'SET',
    'SHADOW', 'SHARED', 'SHELL',
    'SHOW', 'SINGULAR', 'SIZE',
    'SMALLINT', 'SNAPSHOT', 'SOME',
    'SORT', 'SQLCODE', 'SQLERROR',
    'SQLWARNING', 'STABILITY', 'STARTING',
    'STARTS', 'STATEMENT', 'STATIC',
    'STATISTICS', 'SUB_TYPE', 'SUM',
    'SUSPEND', 'TABLE', 'TERMINATOR',
    'THEN', 'TIME', 'TIMESTAMP',
    'TO', 'TRANSACTION', 'TRANSLATE',
    'TRANSLATION', 'TRIGGER', 'TRIM',
    'TYPE', 'UNCOMMITTED', 'UNION',
    'UNIQUE', 'UPDATE', 'UPPER',
    'USER', 'USING', 'VALUE',
    'VALUES', 'VARCHAR', 'VARIABLE',
    'VARYING', 'VERSION', 'VIEW',
    'WAIT', 'WEEKDAY', 'WHEN',
    'WHENEVER', 'WHERE', 'WHILE',
    'WITH', 'WORK', 'WRITE',
    'YEAR', 'YEARDAY');

constructor TEMemoSQLCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeywordsForeColor:= clNavy;
  FKeywordsBackColor:= clWhite;
end;

procedure TEMemoSQLCode.SetKeywordsForeColor(AValue: TColor);
begin
  FKeywordsForeColor:= AValue;
  if (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSQLCode.SetKeywordsBackColor(AValue: TColor);
begin
  FKeywordsBackColor:= AValue;
  if (FCxMemo <> nil) then FCxMemo.Invalidate;
end;

procedure TEMemoSQLCode.SelectTagColor(const ATag: TGsString; ACanvas: TCanvas);
var
  Tag: TGsString;
  i: Integer;
begin
  ACanvas.Font.Color := FTagForeColor;
  ACanvas.Brush.Color := FTagBackColor;
  ACanvas.Font.Style:= [];

  Tag:= ANSIUppercase(ATag);
  //
  for i:= Low(IBKEYWORDS) to High(IBKEYWORDS) do begin
    if Tag = IBKEYWORDS[i] then begin
      ACanvas.Font.Color:= FKeywordsForeColor;
      ACanvas.Brush.Color:= FKeywordsBackColor;
      if emUseBoldTags in FCxMemo.Options
      then ACanvas.Font.Style:= [fsBold];
      Break;
    end;
  end;
end;

function TEMemoSQLCode.GetClassDescription(var R: TxmlClassDesc): Boolean;
begin
  Result:= GetxmlClassDescByClass(TWmlContainer, R);
end;

procedure TEMemoSQLCode.ParseLine(ALineNo: Integer; Canvas: TCanvas; ARect: TRect);
var
  I, x0, len, st, fin: Integer;
  S: TGsString;
  Line: WideString;

  procedure RecalcX;
  begin
    ARect.Left:= x0 + FLastPos * FCxMemo.FontWidth;
    printcanvasVisible(Canvas.Handle, PWideChar(S), ARect);
  end;

begin
  FCharCount:= 0;
  FLastPos:= 0;
  FStartPos:= 0;
  x0:= ARect.Left;
  Line:= CxMemo.Lines[ALineNo];

  // get line width
  len:= Length(Line);
  // set boundary to prevent scan too much
  st:= FCxMemo.ScrollPos_H - FCxMemo.WidthsLen; // set to 1 ?!!
  fin:= FCxMemo.ScrollPos_H + FCxMemo.WidthsLen;  // Length(Line)
  // check left boundary
  if st <= 0
  then st:= 1;
  if fin > len
  then fin:= len;

  for I:= st to fin do begin
    case Line[I] of
      ' ': begin
            S:= Trim(Copy(Line, FStartPos, FCharCount));
            SelectTagColor(S, Canvas);
            RecalcX;
            FCharCount:= 0;
            FStartPos:= I + 1;
            FLastPos:= I;
            Canvas.Font.Color:= FCxMemo.EnvironmentOptions.TextColor;
            Canvas.Brush.Color:= FCxMemo.EnvironmentOptions.TextBackground;
            Continue;
          end;
      '"', '''':
      begin
        if FStartPos = 0 then begin
          FCharCount := I - 1;
          FLastPos := 0;
        end;
        FInValue := True;
        S:= Copy(Line, FStartPos, FCharCount);
        Canvas.Font.Color := FTagPropForeColor;
        Canvas.Brush.Color := FTagPropBackColor;
        RecalcX;
        FCharCount := 0;
        FStartPos := I + 1;
        FLastPos := I;
        Canvas.Font.Color := FCxMemo.EnvironmentOptions.TextColor;
        Canvas.Brush.Color := FCxMemo.EnvironmentOptions.TextBackground;
        Continue;
      end else begin
        Inc(FCharCount);
      end;
    end;
  end;
end;

procedure TEMemoSQLCode.SetBackgroundColors(AColor: TColor);
begin
  inherited SetBackgroundColors(AColor);
  FKeywordsBackColor:= AColor;
  if (FCxMemo <> nil)
  then FCxMemo.Invalidate;
end;

end.
