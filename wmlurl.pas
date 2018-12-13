unit wmlurl;
(*##*)
(*******************************************************************
*                                                                 *
*   w  m  l  u  r  l                                               *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   wireless markup language browser url parser and loader        *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Oct 14 2001                                     *
*   Last fix     : Mar 29 2002                                    *
*   Lines        : 65                                              *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface
uses
  Windows, SysUtils, Classes, Graphics, Controls, StdCtrls,
  util1, util_xml, wml, wmlc;

const
  umOK = 0;
  umFILENOTFOUND = 1;
  umNOTIMPLEMENTED = 2;
  umINVALIDURI = 3;

function GetSrcFromURI(const AURI: string; var Src: WideString; var bookmark: string; var AEncoding: Integer): Integer;

implementation
uses
  UrlFuncs;
  
function GetSrcFromURI(const AURI: string; var Src: WideString; var bookmark: string; var AEncoding: Integer): Integer;
var
  protocol, user, password, host, IP, fn: string;
  port: Integer;
  s: string;
begin
  if urlFuncs.ParseUrl(AURI, protocol, user, password, host, IP, fn, bookmark, port, '', 0) then begin
    Result:= umOK;
    if (Length(protocol) = 0) or (CompareText(protocol, 'file') = 0) then begin
      // www.commandus.com is file name or host? try to find file first...
      if FileExists(AUri) then begin
        s:= util1.File2String(AUri);
      end else begin
        Result:= umFILENOTFOUND;
      end;
    end;
    if CompareText('http', protocol) = 0 then begin
      Result:= umNOTIMPLEMENTED;
    end;
  end else begin
    Result:= umINVALIDURI;
  end;
  if Result = umOK then begin
    AEncoding:= util_xml.GetEncoding(s, csUTF8);
    Src:= util_xml.CharSet2WideStringLine(AEncoding, s, []); // convEnEntity2Char
  end else begin
    Src:= '';
    AEncoding:= csUTF8;
  end;
end;

end.

