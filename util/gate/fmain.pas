unit fmain;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  a  p  g  a  t  e  3                                                     *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*   main form, part of wapgate3 program                                       *
*   Conditional defines:                                                       *
*                                                                             *
*   Last Revision: Nov 28 2001                                                 *
*   Last fix     : Mar 29 2002                                                *
*   Lines        : 211                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jclUnicode,
  util1, pdu, Sockets,
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer, IdSocketHandle,
  IdTCPServer, IdHTTPServer, IdUDPClient, IdTCPConnection, IdTCPClient,
  PluginHTTP, ScktComp;

type
  TFormMain = class(TForm)
    EWMLFilename: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Button3: TButton;
    Memo2: TMemo;
    Button2: TButton;
    IdUDPServer1: TIdUDPServer;
    Button4: TButton;
    IdUDPClient1: TIdUDPClient;
    Button5: TButton;
    procedure Button3Click(Sender: TObject);
    procedure UdpSocket1Receive(Sender: TObject; Buf: PChar;
      var DataLen: Integer);
    procedure UdpSocket1Connect(Sender: TObject);
    procedure UdpSocket1Send(Sender: TObject; Buf: PChar;
      var DataLen: Integer);
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure TcpServer1Listening(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure IdTCPServer1Connect(AThread: TIdPeerThread);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  wmlc, util_xml;

{
  Parameters:
  AWBXMLVersion  -1 set appropriate wbxml version according to wml version (if failed, WBXML1.3)
                 1- WBXML1.1 2- WBXML1.2 3- WBXML1.3
  ASLErrors      error description list. Can be Nil
}
function GetWMLFileInfo(const AFileName: String; AWBXMLVersion: Integer;
  ADefaultSrcEncoding: Integer; var ASrcEncoding: Integer; ASLErrors: TWideStrings): String;
var
  fStream: TFileStream;
  src: String;
  len: Integer;
  ws: WideString;
begin
  if not FileExists(AFileName)
  then Exit;
  Result:= 'WML source file: ' + ExtractFileName(AFileName) + #13#10;
  //open the file
  try
    fStream:= TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    len:= fStream.Size;
    SetLength(src, len);
    fStream.Read(src[1], len);

    // get wml source encoding (search for <xml encoding="utf-8"?>
    // return ADefaultEncoding if not found or cannot resolve name of encoding code page
    ASrcEncoding:= util_xml.GetEncoding(src, ADefaultSrcEncoding);
    ws:= util_xml.CharSet2WideString(ASrcEncoding, src);

    Result:= wmlc.CompileWMLCString(AWBXMLVersion, ws, ASLErrors);
    // encodingname:= util_xml.CharSetCode2Name(ASrcEncoding);
    fStream.Free;
  except
    Result:= ''; // Unexpected fatal error
    Exit;
  end;
end;

{------------------------------ form event handlers ---------------------------}

function EncodeHttp(S: String): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(S) do begin
    case S[i] of
      #0..#31, #128..#255: Result:= Result + '%' +IntToHex(Byte(S[i]), 2);
      else Result:= Result + S[i];
    end;
  end;
end;

function ShowInHex(const S: String): String;
var
  i: Integer;
begin
  Result:= '';
  for i:= 1 to Length(S) do begin
    Result:= Result + IntToHex(Byte(S[i]), 2) + ' ';
  end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
var
  s: String;
  pdu: TCustomPDU;
begin
  pdu:= TCustomPDU.Create;
  s:= pdu.Produce(True, 32, $40, 'http://ensen', Memo1.Lines);
  Memo2.Lines.Text:= ShowInHex(s);
  Memo2.Lines.Add(s);
  pdu.Free;
end;

procedure TFormMain.UdpSocket1Receive(Sender: TObject; Buf: PChar;
  var DataLen: Integer);
begin
  Memo2.Text:= Buf;
  Memo2.Lines.Add(IntToStr(DataLen));
end;

procedure TFormMain.UdpSocket1Connect(Sender: TObject);
begin
  Memo2.Lines.Add('Connect');
end;

procedure TFormMain.UdpSocket1Send(Sender: TObject; Buf: PChar;
  var DataLen: Integer);
begin
  Memo2.Text:= 'Send: ' + Buf;
  Memo2.Lines.Add(IntToStr(DataLen));
end;

procedure TFormMain.IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
  s, uri: String;
  pdu: TCustomPDU;
  pdutype: Integer;
  headers, capabilities: TStrings;
begin
  pdu:= TCustomPDU.Create;
  headers:= TStringList.Create;
  capabilities:= TStringList.Create;

  SetLength(s, AData.Size);
  AData.Read(s[1], Length(s));
  s:= ConnectionLessRequestAndReply(s, pdutype, uri, headers, capabilities);
  ABinding.SendTo(ABinding.PeerIP, ABinding.PeerPort, s[1], Length(s));

  capabilities.Free;
  headers.Free;
  pdu.Free;
end;

procedure TFormMain.TcpServer1Listening(Sender: TObject);
begin
  //
end;

procedure TFormMain.Button4Click(Sender: TObject);
var
  s: String;
  vl, ext: TStrings;
begin
  vl:= TStringList.Create;
  ext:= TStringList.Create;
  Button4.Caption:= ExtractHeaderExtFields(PChar(Memo1.Lines[0]), vl, ext);
  s:= vl.Text;
  Memo2.Lines.Text:= ShowInHex(s)+#13#10 + s;
  ext.Free;
  vl.Free;
end;

procedure TFormMain.IdTCPServer1Connect(AThread: TIdPeerThread);
begin
    Memo2.Lines.Text:= AThread.Connection.CurrentReadBuffer;
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  s: String;
  pdu: TCustomPDU;
begin
  pdu:= TCustomPDU.Create;
  s:= pdu.Produce(True, 32, $40, 'http://ensen', Memo1.Lines);
  Memo2.Lines.Text:= 'Send '+ShowInHex(s) + #13#10;
  pdu.Free;
  s:= #1'@'#$C'http://ensenÅÍÅÑÅ'#3#2#3'ËÄîÄïÄáÄáÄtext/x-vcal'#0'ÄÜÄÜÄ°Ä©Ä£ÄåÄùÄû©Nokia-WAP-Toolkit/2.1'#0'Éô';
  IdUDPClient1.Send(s);
  s:= IdUDPClient1.ReceiveString();
  Memo2.Lines.Add(ShowInHex(s));
  s:= #1#4'b!'#3'îÅÑEncoding-version'#0'1.2'#0'ÑÄí'#4'<±hY'#1#4#4#0'Á6'#3'Error'#0#1'`ËF!'#3'back'#0#1'2'#1#3'Connection from gateway to host failed'#0#1#1#1;
end;

procedure TFormMain.Button5Click(Sender: TObject);
var
  s, uri: String;
  pdu: TCustomPDU;
  pdutype: Integer;
  headers, capabilities: TStrings;
begin
  pdu:= TCustomPDU.Create;
  headers:= TStringList.Create;
  capabilities:= TStringList.Create;

  s:= #1'@'#$C'http://ensenÅÍÅÑÅ'#3#2#3'ËÄîÄïÄáÄáÄtext/x-vcal'#0'ÄÜÄÜÄ°Ä©Ä£ÄåÄùÄû©Nokia-WAP-Toolkit/2.1'#0'Éô';
  s:= ConnectionLessRequestAndReply(s, pdutype, uri, headers, capabilities);
  capabilities.Free;
  headers.Free;
  pdu.Free;
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  Src:  String;
  Headers: TStrings;
  Code: Integer;
begin
  Headers:= TStringList.Create;
  Src:= 'HTTP/1.1 403 Access Forbidden'#13#10+
'Server: Microsoft-IIS/5.1'#13#10+
'Date: Thu, 11 Apr 2002 08:23:41 GMT'#13#10+
'Content-Type: text/html'#13#10+
'Content-Length: 172'#13#10+
''#13#10+
'<html><head><title>Directory Listing Denied</title></head>'#13#10+
'<body><h1>Directory Listing Denied</h1>This Virtual Directory does not allow contents to be listed.</b></body>'#13#10;
  Code:= ParseHTTPResponse(Src, Headers);
  Headers.Free;
end;

end.
