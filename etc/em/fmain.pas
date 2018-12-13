unit fmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xmldom, XMLIntf, msxmldom, XMLDoc, ExtCtrls, StdCtrls, Registry,
  xdrOpenWave, IdBaseComponent, IdCoder, IdCoder3To4,
  util1,
  wmlbemulate, jpeg,
  GifImage;
// Windows, Messages, SysUtils, Classes, Graphics, Controls, ;

type
  TForm1 = class(TForm)
    emx: TXMLDocument;
    Button1: TButton;
    Image1: TImage;
    IdBase64Decoder1: TIdBase64Decoder;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    EXMLFileName: TEdit;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    em: TWMLBEmulator;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
const
  imgs: array[0..2] of String = ('imagenormal', 'imageover', 'imagepressed');
  scrimg: array[0..3] of String = ('imagetop', 'imagebottom', 'imagemiddle', 'imagenoscroll');
var
  ReturnedInteger,
  i: Integer;
  s: String;
  v: Variant;
  fn: String;
begin
  emx.FileName:= EXMLFileName.Text;
  emx.Active:= True;
  //
  //em7190.DocumentElement. .ChildNodes
  IdBase64Decoder1.AutoCompleteInput:= True;
  {
  with em7190.ChildNodes['device'].ChildNodes['userinterface'].ChildNodes['uiimages'] do begin
    for i:= Low(imgs) to High(imgs) do begin
      fn:= imgs[i] + ReplaceExt('.jpg', ExtractFileName(em7190.FileName));
      v:= ChildNodes[imgs[i]].NodeValue;
      if (VarType(v) <> varEmpty) and (VarType(v) <> varNull) then begin
        s:= IdBase64Decoder1.CodeString(v);
        IdBase64Decoder1.GetCodedData;
        if FileExists(fn)
        then DeleteFile(fn);
        util1.String2File(fn, s);
      end;
    end;
  end;
  }
  with emx.ChildNodes['device'].ChildNodes['display'].ChildNodes['scrollbararea'].ChildNodes['scrollbarimages'] do begin
    for i:= Low(scrimg) to High(scrimg) do begin
      fn:= scrimg[i] + ReplaceExt('.bmp', ExtractFileName(emX.FileName));
      v:= ChildNodes[scrimg[i]].NodeValue;
      if ((VarType(V) and varTypeMask) <> varEmpty) and ((VarType(V) and varTypeMask) <> varNull) then begin
        s:= IdBase64Decoder1.CodeString(v);
        Delete(s, 1, 2);
        IdBase64Decoder1.GetCodedData;
        if FileExists(fn)
        then DeleteFile(fn);
        util1.String2File(fn, s);
      end;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  n: Integer;
  em: TWMLBEmulator;
  strm: TStream;
  txtstrm: TStream;
  wsB: TWAPSoftButton;
  wB: TWAPButton;
  cp: TCharacterProperty;
  v: Variant;
  s: String;
  fn: String;
begin
  emx.FileName:= EXMLFileName.Text;
  emx.Active:= True;

  strm:= TMemoryStream.Create;
  txtstrm:= TStringStream.Create('');
  em:= TWMLBEmulator.Create(Self);
  fn:= ReplaceExt('.jpg', ExtractFileName(emX.FileName));
{}
  with em do begin
    em.Name:= emX.ChildNodes['device'].ChildValues['name'];
    em.ImgNormal:= Format('%s%s', ['imagenormal', fn]);
    em.ImgOver:= Format('%s%s', ['imageover', fn]);
    em.ImgPressed:= Format('%s%s', ['imagepressed', fn]);

    with emX.ChildNodes['device'].ChildNodes['parser'] do begin
      cxprefix:= ChildValues['cxprefix'];
      cyprefix:= ChildValues['cyprefix'];
      xdevicebrowser:= ChildValues['xdevicebrowser'];
      Highlightmode:= ChildValues['highlightmode'];
      with ChildNodes['font'] do begin
        Display.Font.Name:= Attributes['name'];
        Display.Font.Height:= - Attributes['height'];
        if Attributes['variablewidth'] > 0
        then Display.Font.Pitch:= fpVariable;
        if Attributes['variablewidth'] = 0
        then Display.Font.Pitch:= fpFixed;
      end;
      // assign default font to other areas
      em.BrowserArea.Font:= Display.Font;
      em.TitleBar.Font:= Display.Font;
      em.BrowserArea.Font:= Display.Font;
      em.SoftButtons.DisplayArea.Font:= Display.Font;

      em.DeviceSupports:= [];
      if ChildValues['supportbold'] > 0
      then DeviceSupports:= DeviceSupports + [dsBold];
      if ChildValues['supportitalics'] > 0
      then DeviceSupports:= DeviceSupports + [dsItalics];
      if ChildValues['supportunderline'] > 0
      then DeviceSupports:= DeviceSupports + [dsunderline];
      if ChildValues['supportstrong'] > 0
      then DeviceSupports:= DeviceSupports + [dsStrong];
      if ChildValues['supportemphasis'] > 0
      then DeviceSupports:= DeviceSupports + [dsEmphasis];
      if ChildValues['supportbig'] > 0
      then DeviceSupports:= DeviceSupports + [dsBig];
      if ChildValues['supportsmall'] > 0
      then DeviceSupports:= DeviceSupports + [dsSmall];
      if ChildValues['supportimages'] > 0
      then DeviceSupports:= DeviceSupports + [dsImages];
      if ChildValues['supportlocalsrcimages'] > 0
      then DeviceSupports:= DeviceSupports + [dslocalsrcimages];
      if ChildValues['supportaccesskeys'] > 0
      then DeviceSupports:= DeviceSupports + [dsaccesskeys];
      try
      AnchorDelimiterLeft:= ChildValues['anchordelimleft'];
      AnchorDelimiterRight:= ChildValues['anchordelimright'];
      except
      end;
    end;

    with emX.ChildNodes['device'].ChildNodes['accepttypes'] do begin
      DeviceAcceptTypes:= [];
      for n:= 0 to ChildNodes.Count - 1 do begin
        if ChildNodes[n].NodeValue = 'text/wml'
        then DeviceAcceptTypes:= DeviceAcceptTypes + [mtWML];
        if ChildNodes[n].NodeValue = 'image/wbmp'
        then DeviceAcceptTypes:= DeviceAcceptTypes + [mtWBMP];
      end;
    end;

    with emX.ChildNodes['device'] do begin
      Platforms:= [];
      v:= ChildValues['platformid'];
      if Pos('wap:1.1', v) > 0
      then Platforms:= Platforms + [wpWAP1_1];
      if Pos('openwave:3.0', v) > 0
      then Platforms:= Platforms + [wpOpenWave3_0];
      if Pos('openwave:3.03', v) > 0
      then Platforms:= Platforms + [wpOpenWave3_03];
      if Pos('openwave:3.1', v) > 0
      then Platforms:= Platforms + [wpOpenWave3_1];
      if Pos('openwave:4.1', v) > 0
      then Platforms:= Platforms + [wpOpenWave4_1];
      if Pos('nokia:1.1', v) > 0
      then Platforms:= Platforms + [wpNokia1_1];
    end;
    with emX.ChildNodes['device'].ChildNodes['display'] do begin
      Display.x0:= ChildValues['x'];
      Display.y0:= ChildValues['y'];
      Display.x1:= ChildValues['devicex'];
      Display.y1:= ChildValues['devicey'];
      Display.x1:= ChildValues['devicex'];
      Display.y1:= ChildValues['devicey'];
      with ChildNodes['bgcolor'] do Display.BackColor:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
      with ChildNodes['fgcolor'] do Display.Font.Color:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
    end;
    with emX.ChildNodes['device'].ChildNodes['display'].ChildNodes['browserarea'] do begin
      BrowserArea.x0:= ChildValues['x'];
      BrowserArea.y0:= ChildValues['y'];
      BrowserArea.x1:= ChildValues['xoffset'];
      BrowserArea.y1:= ChildValues['yoffset'];
      with ChildNodes['bgcolor'] do BrowserArea.BackColor:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
      with ChildNodes['fgcolor'] do BrowserArea.Font.Color:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
    end;

    if emX.ChildNodes['device'].ChildNodes['display'].ChildNodes['softbuttons'].HasChildNodes
      then with emX.ChildNodes['device'].ChildNodes['display'].ChildNodes['softbuttons'] do begin
      SoftButtons.SoftButtonsStyle:= ChildValues['drawstyle'];
      SoftButtons.SoftButtonsPresentationStyle:= ChildValues['presentationstyle'];
      with ChildNodes['bgcolor'] do SoftButtons.DisplayArea.BackColor:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
      with ChildNodes['fgcolor'] do SoftButtons.DisplayArea.Font.Color:= Attributes['red'] +
        Attributes['green'] shl 8 + Attributes['blue'] shl 16;
      with ChildNodes['font'] do begin
        SoftButtons.DisplayArea.Font.Name:= Attributes['name'];
        SoftButtons.DisplayArea.Font.Height:= - Attributes['height'];
        if Attributes['variablewidth'] > 0
        then SoftButtons.DisplayArea.Font.Pitch:= fpVariable;
        if Attributes['variablewidth'] = 0
        then SoftButtons.DisplayArea.Font.Pitch:= fpFixed;
      end;
      n:= 1;
      repeat
        v:= ChildNodes['softbutton'+IntToStr(n)];
        if not ChildNodes['softbutton'+IntToStr(n)].HasChildNodes
        then Break;
        with ChildNodes['softbutton'+IntToStr(n)] do begin
          wsB:= em.SoftButtons.Add;
          wsb.DisplayArea.x0:= ChildValues['x'];
          wsb.DisplayArea.y0:= ChildValues['y'];
          wsb.DisplayArea.x1:= ChildValues['xoffset'];
          wsb.DisplayArea.y1:= ChildValues['yoffset'];
          case ChildValues['align'] of
            0: wsb.DisplayArea.Align:= alLeft;
            1: wsb.DisplayArea.Align:= alRight;
          end;
        end;
        Inc(n);
      until False;
    end;

    // buttons
    if emX.ChildNodes['device'].ChildNodes['userinterface'].ChildNodes['buttons'].HasChildNodes then
      with emX.ChildNodes['device'].ChildNodes['userinterface'].ChildNodes['buttons'] do begin
      for n:= 0 to ChildNodes.Count - 1 do begin
        wB:= em.Buttons.Add;
        wb.Comment:= ChildNodes[n].Attributes['comment'];
        wb.x0:= ChildNodes[n].Attributes['x1'];
        wb.y0:= ChildNodes[n].Attributes['y1'];
        wb.x1:= ChildNodes[n].Attributes['x2'];
        wb.y1:= ChildNodes[n].Attributes['y2'];
        s:= ChildNodes[n].NodeValue;
        if Length(s) > 0
        then wb.Value:= s[1];
      end;
    end;

    // character properties
    if emX.ChildNodes['device'].ChildNodes['parser'].ChildNodes['characterset'].HasChildNodes then
      with emX.ChildNodes['device'].ChildNodes['parser'].ChildNodes['characterset'] do begin
      try
      em.CharacterSet.Height:= Attributes['height'];
      except end;
      try
      em.CharacterSet.VariableWidth:= Attributes['variablewidth'] = 1;
      except end;
      try
      em.CharacterSet.Width:= Attributes['width'];
      except end;
      for n:= 0 to ChildNodes.Count - 1 do begin
        cp:= em.CharacterSet.Add;
        cp.Comment:= ChildNodes[n].Attributes['comment'];
        cp.Width:= ChildNodes[n].Attributes['width'];
        s:= ChildNodes[n].Attributes['value'];
        if Length(s) > 0
        then cp.CharValue:= Ord(s[1]);
      end;
    end;
  end;
{}
  strm.WriteDescendent(em, Nil);
  strm.Seek(0, soFromBeginning);
  ObjectBinaryToText(strm, txtstrm);
  fn:= ReplaceExt('.txt', ExtractFileName(emX.FileName));

  if FileExists(fn)
  then DeleteFile(fn);
  util1.String2File(fn, TStringStream(txtstrm).DataString);

  em.Free;
  txtstrm.Free;
  strm.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  strm: TStream;
  binstrm: TStream;
  i: Integer;
  s: String;
begin
  strm:= TFileStream.Create(ReplaceExt('.txt', EXMLFileName.Text), fmOpenRead);
  binstrm:= TMemoryStream.Create;
  ObjectTextToBinary(strm, binstrm);
  binstrm.Seek(0, soFromBeginning);
  binstrm.ReadComponent(em);
  binstrm.Free;
  strm.Free;

  { do smth }
  Caption:= em.Name;
  Memo1.Lines.Clear;
  for i:= 0 to em.Buttons.Count - 1 do with em.Buttons[i] do begin
    s:= Format('%d %d %d %d', [x0, y0, x1, y1]);
    Memo1.Lines.Add(Comment +'; '+ Value + '; ' + s)
  end;
  Image1.Picture.LoadFromFile(em.ImgNormal);
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i: Integer;
begin
  //
  for i:= 0 to em.Buttons.Count - 1 do with em.Buttons[i] do begin
    if (X >= x0) and (Y >= y0) and (X <= x1) and (Y <= y1) then begin
      Button3.Caption:= Comment;
    end;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  { destroy object }
  em.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  em:= TWMLBEmulator.Create(Self);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  with OpenDialog1 do begin
    if Execute then begin
      EXMLFileName.Text:= Filename;
    end;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
const
  RC_CpuUsageKey = 'KERNEL\CPUUsage';
  RC_PerfStart = 'PerfStats\StartStat';
  RC_PerfStop = 'PerfStats\StopStat';
  RC_PerfStat = 'PerfStats\StatData';
var
  FRegistry: TRegistry;
  FValue: Cardinal;
begin
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_DYN_DATA;
  FRegistry.OpenKey(RC_PerfStart, False);
  FRegistry.ReadBinaryData(RC_CpuUsageKey, FValue, SizeOf(FValue));

  Sleep(100);
  
  FRegistry.OpenKey(RC_PerfStop, False);
  FRegistry.ReadBinaryData(RC_CpuUsageKey, FValue, SizeOf(FValue));
  FRegistry.CloseKey;

  FRegistry.OpenKey(RC_PerfStat, False);
  FRegistry.ReadBinaryData(RC_CpuUsageKey, FValue, SizeOf(FValue));
  FRegistry.CloseKey;
  Button5.Caption:= IntToHex(FValue, 16);// IntToStr(FValue);
  FRegistry.Free;

end;

end.
