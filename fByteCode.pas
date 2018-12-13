unit
  fByteCode;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  b  y  t  e  c  o  d  e                                                  *
*                                                                             *
*   Copyright © 2001-2003 Andrei Ivanov. All rights reserved.                  *
*   bytecode viewer                                                           *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Jul 06 2001, Oct 11 2001                                    *
*   Last revision: Mar 29 2002                                                *
*   Lines        : 3702                                                        *
*   History      : see todo file                                              *
*                                                                              *
*                                                                             *
*   Printed      :                                                             *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
  jclUnicode,
  customxml, StdCtrls;

type
  TFormByteCode = class(TForm)
    StatusBar1: TStatusBar;
    MemoBytes: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FCompiled: String;
    procedure DrawCompiled;
  public
    { Public declarations }
    procedure SyncViewText(const AText: WideString);
    procedure SyncViewXML(AxmlElementColl: TxmlElementCollection);
  end;

var
  FormByteCode: TFormByteCode = Nil;

implementation

{$R *.dfm}

uses
  wmlc, fDockBase;

procedure TFormByteCode.DrawCompiled;
var
  x, y, i, j, len: Integer;
  s: String;
begin
  MemoBytes.Clear;
  s:= '';
  i:= 0;
  x:= 0;
  y:= 0;
  len:= Length(FCompiled);
  while True do begin
    if i >= len then begin
      MemoBytes.Lines.Add(s);
      Break;
    end;
    if ((i mod 16) = 0) and (i > 0) then begin
      MemoBytes.Lines.Add(s);
      s:= '';
    end;
    Inc(i);
    s:= s + IntToHex(Ord(FCompiled[i]), 2) + ' ';    
  end;
end;

procedure TFormByteCode.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Sender is TFormByteCode then begin
    // CanClose:= False;
  end;
end;

const
  WBXMLVersion = 3;

procedure TFormByteCode.SyncViewText(const AText: WideString);
var
  errDesc: TWideStrings;
  i, compiledlen: Integer;
begin
  //
  errDesc:= TWideStringList.Create;
  FCompiled:= wmlc.CompileWMLCString(WBXMLVersion, AText, errDesc);
  compiledlen:= Length(FCompiled);
  StatusBar1.SimpleText:= Format('Compiled size: %d bytes (%xh)', [compiledlen, compiledlen]);
  // Compilation messages
  {
  for i:= 0 to errDesc.Count - 1 do begin
    MemoInfo.Lines.Add(errDesc[i]);
  end;
  }
  errDesc.Free;
  DrawCompiled;
end;

procedure TFormByteCode.SyncViewXML(AxmlElementColl: TxmlElementCollection);
var
  errDesc: TWideStrings;
  i, compiledlen: Integer;
begin
  //
  errDesc:= TWideStringList.Create;
  FCompiled:= wmlc.CompileWMLC(WBXMLVersion, AxmlElementColl, errDesc);
  compiledlen:= Length(FCompiled);
  StatusBar1.SimpleText:= Format('Compiled size: %d bytes (%xh)', [compiledlen, compiledlen]);
  // Compilation messages
  {
  for i:= 0 to errDesc.Count - 1 do begin
    MemoInfo.Lines.Add(errDesc[i]);
  end;
  }
  errDesc.Free;
  DrawCompiled;
end;

procedure TFormByteCode.FormCreate(Sender: TObject);
begin
  FCompiled:= '';
end;

end.
