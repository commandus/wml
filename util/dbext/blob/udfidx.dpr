library Udfidx;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.
select eq_char(1,1,'1')
from RDB$DATABASE;
select eno, eq_char(1,1,'1XKSDFKSDKFKSFKKASFKSA')
from employee;
  }

{$R *.RES}

uses
  SysUtils, Windows, Classes,
  IB, IBConst, IBIntf, // IB_Util,
  util1, xmlidx;

function DoSearch(const APath: String; const ASearchString: String;
  AFrom, ATo: Integer; var AResult: TStrings): Integer;
var
  invSrch: TInvSearch;
  r: Integer;
  path: String;
  st, fin, cnt: Integer;
begin
  //
  path:= APath;

  invSrch:= TInvSearch.Create(nil);
  with invSrch do begin

    LoadIndex(util1.ConcatPath(path, 'idx', '\'));

    WordsAllFields:= ASearchString;
    Search;

    cnt:= FoundCount;
    st:= AFrom;
    fin:= ATo;
    Result:= 0;

    if st >= cnt
    then Exit;

    if fin > cnt
    then fin:= cnt;

    Result:= fin - st;

    for r:= 0 to fin - 1 do begin
      AResult.Add(Urls[r]); // (ConcatPath(path, Urls[r], '\');
    end;
    Free;
  end;
end;

{ DECLARE EXTERNAL FUNCTION idx_search CSTRING(128), CSTRING(32767), INTEGER, INTEGER,
  RETURNS CSTRING(32767) FREE_IT ENTRY_POINT 'idx_search' MODULE_NAME 'udfidx';

  SELECT idx_search('c:/indexpath/', 'searchword1 searchmask*') FROM dual

  returns list of found file names
}

function idx_search(APath, ASearchString: PChar; AFrom, ATo: Integer): PChar; cdecl; stdcall; export;
const
  STR_INS = 'INSERT INTO cs_poll (poll,dept,user_id,voter_id,dt,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16) VALUES (''%s'',''%s'',''%s'',''%s'',''%s'', %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d);';
var
  r: array[0..15] of Integer;
  s, line: String;
  i, c, f, len: Integer;
begin
  i:= 0;
  len:= strlen(ABlock);
  s:= '';
  c:= 0; // count array index
  FillChar(r, SizeOf(r), 0); // fill zeroes to array
  f:= -1; // digit is not found
  while i <= len do begin
    case ABlock[i] of
    #0..#32: begin
        if f > -1 then begin // if digit was found earlier
          if c > 15
          then Continue; // only 16 parameters is allowed

          try
            r[c]:= StrToIntDef(Copy(ABlock, f + 1, i - f), 0); // try to read integer
          except
            // just in case
          end;
          Inc(c); // go to the next array index
          f:= -1; // indicate that digit is not found yet
        end;
        if ABlock[i] in [#0,#10] then begin
          // write INSERT statement
          if c > 0 then begin
            line:= Format(STR_INS, [APoll, ADept, AUser_id, AVoter_id, ADt,
              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]]);
            s:= s + line + #13#10;
          end;
          FillChar(r, SizeOf(r), 0); // zeroes array
          c:= 0;  // go to the first array index
          f:= -1; // indicate that digit is not found yet
        end;
      end;
      else begin
        if f = -1
        then f:= i; // it is allowed more than 1 digit in integer
      end;
    end; { case }
    Inc(i);
  end;
  len:= Length(s);
  GlobalLock(GlobalAlloc(GHND, len + 1));
  // Pointer(Result):= ib_util_malloc(len + 1);
  Move(s[1], Result[0], len);
  Result[len]:= #0;
end;

exports
  idx_search name 'idx_search';

begin
end.
