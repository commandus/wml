unit
  WMLInfoTipImpl;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  I  n  f  o  T  i  p  I  m  p  l                                   *
*                                                                             *
*   Copyright (c) 2002, Andrei Ivanov. All rights reserved.                    *
*   wireless markup language info tip library implementation                  *
*   Conditional defines:                                                       *
*                                                                             *
*   Last Revision: Jan 16 2002                                                 *
*   Last fix     : Jan 16 2002                                                *
*   Lines        : 228                                                       *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  ComObj, ActiveX, WMLInfo_TLB, StdVcl, shlobj, windows, classes, sysutils,
  jclUnicode, customxml, wml, wmlc, util_xml;

const
  DEFSRCENCODING = csUTF8;

type
  TWMLInfoTip = class(TAutoObject, IWMLInfoTip, IQueryInfo, IPersistFile, IPersist )
  private
    FConvOnLoadOptions: TEntityConvOptions;
  protected
    pMalloc : IMalloc;
    FFile : String;
    { Protected declarations }
    {IQueryInfo}
    function GetInfoTip(dwFlags: DWORD; var ppwszTip: PWideChar): HResult; stdcall;
    function GetInfoFlags(out pdwFlags: DWORD): HResult; stdcall;
    {IPersistFile}
    function IsDirty: HResult; stdcall;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult;
      stdcall;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
      stdcall;
    function SaveCompleted(pszFileName: POleStr): HResult;
      stdcall;
    function GetCurFile(out pszFileName: POleStr): HResult;
      stdcall;
    {IPersist} // need to implement, since IPersistFile is derived from IPersist
    function GetClassID(out classID: TCLSID): HResult; stdcall;

    //function to read WML
    function GetWMLInfo : String;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

  TWMLInfoTipFactory = class(TAutoObjectFactory)
  protected
    procedure ApproveShellExtension(ARegister: Boolean; const ClsID: String);
    function GetProgID: String; override;
  public
    procedure UpdateRegistry(ARegister: Boolean); override;
  end;

implementation

uses
  ComServ, registry;

{ TWMLInfoTip }

destructor TWMLInfoTip.Destroy;
begin
  inherited;
  pMalloc := nil;
end;

function TWMLInfoTip.GetClassID(out classID: TCLSID): HResult;
begin
  Result:= E_NOTIMPL;
end;

function TWMLInfoTip.GetCurFile(out pszFileName: POleStr): HResult;
begin
  Result:= E_NOTIMPL;
end;

function TWMLInfoTip.GetWMLInfo: String;
var
  fStream: TFileStream;
  SLErrors: TWideStrings;
  src, compiled, encodingname: String;
  expectedsize: Integer;
  i, len: Integer;
  ws: WideString;
  SrcEncoding: Integer;
begin
  if FFile = ''
  then Exit;
  customxml.XMLENV.xmlCapabilities:= [wcServerExtensions];
  Result:= 'WML source file: ' + ExtractFileName(FFile) + #13#10;

  SLErrors:= TWideStringList.Create;
  //open the file
  try
    fStream:= TFileStream.Create(FFile, fmOpenRead or fmShareDenyNone);
    len:= fStream.Size;
    SetLength(src, len);
    fStream.Read(src[1], len);


    // get wml source encoding (search for <xml encoding="utf-8"?>
    // return ADefaultEncoding if not found or cannot resolve name of encoding code page
    SrcEncoding:= util_xml.GetEncoding(src, DEFSRCENCODING);  // utf-8
    ws:= util_xml.CharSet2WideString(SrcEncoding, src, FConvOnLoadOptions);
    SetLength(src, 0); // just free memory

    compiled:= wmlc.CompileWMLCString(-1, ws, SLErrors);
    encodingname:= CharSetCode2Name(SrcEncoding); // util_xml.GetEncodingName(src);
    expectedsize:= Length(compiled);
    fStream.Free;
  except
    Result:= Result + 'Unexpected fatal error.';
    SLErrors.Free;
    Exit;
  end;
  Result:= Result + Format(#13#10'Encoding: %s, source size %d bytes (%xh)', [encodingname, len, len]);
  Result:= Result + Format(#13#10'Expected compiled size: %d bytes (%xh)', [expectedsize, expectedsize]);
  if SLErrors.Count > 0 then begin
    Result:= Result + Format(#13#10'Errors/warnings: %d', [SLErrors.Count]);
    for i:= 0 to SLErrors.Count - 1 do begin
      Result:= Result + #13#10 + SLErrors[i];
    end;
  end;
  slErrors.Free;
end;

function TWMLInfoTip.GetInfoFlags(out pdwFlags: DWORD): HResult;
begin
  pdwFlags := 0;
  Result := E_NOTIMPL;
end;

function TWMLInfoTip.GetInfoTip(dwFlags: DWORD; var ppwszTip: PWideChar): HResult;
var
  szTip: String;
begin
  Result:= S_OK;
  // The current file name is in FFile through IPersistFile
  szTip:= GetWMLInfo;
  ppwszTip:= pMalloc.Alloc(SizeOf(WideChar) * (Length(szTip) + 1));
  if (ppwszTip <> nil)
  then ppwszTip:= StringToWideChar(szTip, ppwszTip, SizeOf(WideChar) * Length(szTip) + 1 );
end;

procedure TWMLInfoTip.Initialize;
begin
  inherited;
  if Failed(ShGetMalloc(pMalloc))
  then pMalloc:= Nil;
  FConvOnLoadOptions:= [];
end;

function TWMLInfoTip.IsDirty: HResult;
begin
  Result:= E_NOTIMPL;
end;

function TWMLInfoTip.Load(pszFileName: POleStr; dwMode: Integer): HResult;
begin
  FFile:= pszFileName;
  Result:= S_OK;
end;

function TWMLInfoTip.Save(pszFileName: POleStr; fRemember: BOOL): HResult;
begin
  Result:= E_NOTIMPL;
end;

function TWMLInfoTip.SaveCompleted(pszFileName: POleStr): HResult;
begin
  Result:= E_NOTIMPL;
end;

{ TWMLInfoTipFactory }

procedure TWMLInfoTipFactory.ApproveShellExtension(ARegister: Boolean; const ClsID: String);
// This registry entry is required in order for the extension to
// operate correctly under Windows NT.
const
  SApproveKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved';
begin
  with TRegistry.Create do try
    RootKey:= HKEY_LOCAL_MACHINE;
    if not OpenKey(SApproveKey, True) then Exit;
    if ARegister then WriteString(ClsID, Description)
    else DeleteValue(ClsID);
  finally
    Free;
  end;
end;

function TWMLInfoTipFactory.GetProgID: String;
begin
  // ProgID not needed for shell extension
  Result:= '';
end;

procedure TWMLInfoTipFactory.UpdateRegistry(ARegister: Boolean);
var
  ClsID: String;
begin
  ClsID := GUIDToString(ClassID);
  inherited UpdateRegistry(ARegister);
  ApproveShellExtension(ARegister, ClsID);
  if ARegister then
    CreateRegKey('.wml\shellex\' + SID_IQueryInfo, '', ClsID)
  else
    DeleteRegKey('.wml\shellex\' + SID_IQueryInfo);
end;

initialization
  TWMLInfoTipFactory.Create(ComServer, TWMLInfoTip, Class_WMLInfoTip,
    ciMultiInstance, tmApartment);
end.
