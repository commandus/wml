unit fFmtInput;
(*##*)
(*******************************************************************
*                                                                 *
*   f  F  m  t  I  n  p  u  t                                      *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   input format= selection master                                *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Dec 24 2001                                     *
*   Last revision: Mar 29 2002                                    *
*   Lines        : 324                                                *
*   History      :                                                *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, Grids, ComCtrls, IniFiles,
  util1, jclUnicode;

resourcestring
  DEF_FORMATINI = 'format.txt';
  MSG_FORMATFILENOTLOADED = 'Can not load format samples file: %s';

type
  TFormFormatUserInput = class(TForm)
    PanelTop: TPanel;
    PanelBtn: TPanel;
    BOk: TButton;
    BCancel: TButton;
    Label1: TLabel;
    CBCount: TComboBox;
    Label2: TLabel;
    BAdd: TButton;
    ETest: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    CBFormat: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    BReplace: TButton;
    LVFormats: TListView;
    LBCountry: TListBox;
    LVFormat: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LBCountryClick(Sender: TObject);
    procedure BReplaceClick(Sender: TObject);
    procedure BAddClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    First: Boolean;
    FIniFile: String;
    IniFile: TIniFile;
  public
    { Public declarations }
    procedure LoadIni;
  end;

var
  FormFormatUserInput: TFormFormatUserInput;

implementation

{$R *.dfm}

uses
  fDockBase;

procedure TFormFormatUserInput.LoadIni;
begin
  with LBCountry.Items do begin
    BeginUpdate;
    Clear;
    IniFile.ReadSections(LBCountry.Items);
    if Count > 0 then begin
      // select default settings/country
      LBCountry.ItemIndex:= 0;
      // select settings
      LBCountryClick(Self);
    end;
    EndUpdate;
  end;
end;

procedure TFormFormatUserInput.FormCreate(Sender: TObject);
var
  ListItem: TListItem;
begin
  First:= True;
  FIniFile:= util1.ConcatPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]],
    DEF_FORMATINI);
  if not FileExists(FIniFile) then begin
    //
    raise Exception.CreateFmt(MSG_FORMATFILENOTLOADED, [FIniFile]);
  end;
  IniFile:= TIniFile.Create(FIniFile);
  LoadIni;
end;

procedure TFormFormatUserInput.FormDestroy(Sender: TObject);
begin
  IniFile.Free;
end;

procedure TFormFormatUserInput.FormActivate(Sender: TObject);
begin
  if First then begin
    LVFormat.Items.Item[5].Selected:= True;
    BOk.SetFocus;
    First:= False;
  end;
end;

type
  TInputFormattingState = (ifsComplete, ifsNotCompleted, ifsInvalidFormat, ifsInvalidData,
    ifsInvalidAsterisk, ifsTooMuchAsterisks);

function MkWMLInputFormat(const AFmt: WideString; const ASample: WideString;
  var AState: TInputFormattingState): String;
const
  DEF_FMT = '*M';
var
  Fmt: WideString;
  i, rpt: Integer;
  si: Integer;
  ch: WideChar;
  sch: WideChar;
  cnt: Integer;
  asteriskCount: Integer;
  sym: WideChar;
begin
  Result:= '';
  AState:= ifsComplete;
  Fmt:= AFmt;
  if Length(Fmt) = 0
  then Fmt:= DEF_FMT;
  i:= 1;
  si:= 1;
  cnt:= 1;
  asteriskCount:= 0;
  while i <= Length(Fmt) do begin
    ch:= Fmt[i];
    if asteriskCount > 0 then begin
      // can not proceed- * must be last
      AState:= ifsInvalidAsterisk;
      Exit;
    end;
    case ch of
      '*': begin
          cnt:= MaxInt;
          if asteriskCount > 0 then begin
            AState:= ifsTooMuchAsterisks;
            Exit;
          end;
          Inc(asteriskCount);
          Inc(i);
          if i > Length(Fmt) then begin
            AState:= ifsInvalidFormat;
            Exit;
          end;
          sym:= Fmt[i];
        end;
      '1'..'9': begin
          cnt:= StrToIntDef(ch, 1);
          Inc(i);
          if i > Length(Fmt) then begin
            AState:= ifsInvalidFormat;
            Exit;
          end;
          sym:= Fmt[i];
        end;
      '\': begin
          // Displays the next character in the entry field. Allows quoting of the
          // format codes so they can be displayed in the entry area.
          Inc(i);
          if i > Length(Fmt) then begin
            AState:= ifsInvalidFormat;
            Exit;
          end;
          for rpt:= 1 to cnt do Result:= Result + Fmt[i];
          cnt:= 1;
          Inc(i);
          Continue;
        end;
      else begin
        sym:= ch;
        cnt:= 1;
      end;
    end; { case }
    // now we have sym and cnt
    while cnt > 0 do begin
      if si > Length(ASample) then begin
        if asteriskCount > 0 then begin
          // do not check is format valid
          Exit;
        end;
        AState:= ifsNotCompleted;
        Exit;
      end;
      sch:= ASample[si];
      case sym of
        'X':begin
            Result:= Result + WideUpperCase(sch);
          end;
        'x':begin
              Result:= Result + WideLowerCase(sch);
            end;
        'M', 'm':begin
            // user agent may choose to assume or not character is lowercase/uppercase
            Result:= Result + sch;
          end;
        'A':begin
            if UnicodeIsDigit(UCS4(sch)) then begin
              AState:= ifsInvalidData;
              Exit;
            end;
            Result:= Result + WideUpperCase(sch);
          end;
        'a':begin
              if UnicodeIsDigit(UCS4(sch)) then begin
                AState:= ifsInvalidData;
                Exit;
              end;
              Result:= Result + WideLowerCase(sch);
            end;
        'N':begin
            if not UnicodeIsDigit(UCS4(sch)) then begin
              AState:= ifsInvalidData;
              Exit;
            end;
            Result:= Result + sch;
          end;
        else begin
          AState:= ifsInvalidFormat;
          Exit;
        end;
      end; { case }
      Dec(cnt);
      Inc(si);
    end; { while }
    cnt:= 1;
    Inc(i);
  end; { while }
end;

procedure TFormFormatUserInput.LBCountryClick(Sender: TObject);
var
  li: TListItem;
  msg,
  sect,
  vl,
  fmt,
  example: String;
  state: TInputFormattingState;
  sl: TStringList;
  i: Integer;
begin
  if LBCountry.ItemIndex < 0
  then Exit;
  sl:= TStringList.Create;
  sl.Duplicates:= dupIgnore;
  sl.Sorted:= True;
  sect:= LBCountry.Items[LBCountry.ItemIndex];
  // select settings/country
  with LVFormats.Items do begin
    Clear;
    IniFile.ReadSectionValues(sect, sl);
    for i:= 0 to sl.Count - 1 do begin
      li:= Add;
      li.Caption:= sl.Names[i];
      vl:= Copy(sl[i], Pos('=', sl[i]) + 1, MaxInt);
      fmt:= util1.GetToken(2, '|', vl);
      example:= MkWMLInputFormat(fmt, util1.GetToken(1, '|', vl), state);
      if state <> ifsComplete then begin
        case state of
          ifsNotCompleted: msg:= 'Example not completed';
          ifsInvalidFormat: msg:= 'Format is invalid';
          ifsInvalidData: msg:= 'Characters in sample is not follows the specified format';
          ifsInvalidAsterisk: msg:= 'After asterisk ''*'' and format character no other format characters is allowed';
          ifsTooMuchAsterisks: msg:= 'Only one asterisk is allowed';
        end;
        ShowMessage(Format('Error [%s], section [%s], entry [%s]: %s [format "%s", sample "%s"]',
          [FIniFile, sect, sl.Names[i], msg, fmt, example]));
      end;
      li.SubItems.Add(example);
      li.SubItems.Add(fmt);
    end;
  end;
  sl.Free;
end;

procedure TFormFormatUserInput.BReplaceClick(Sender: TObject);
begin
  // replace
  if LVFormats.ItemIndex < 0
  then Exit;
  CBFormat.Text:= LVFormats.Items[LVFormats.ItemIndex].SubItems[1];
  ETest.Text:= LVFormats.Items[LVFormats.ItemIndex].SubItems[0];
end;

procedure TFormFormatUserInput.BAddClick(Sender: TObject);
var
  prefix: String[2];
begin
  if Assigned(LVFormat.Selected) then begin
    case CBCount.ItemIndex of
      -1, 1: prefix:= '';
      else begin
        prefix:= Copy(CBCount.Text, 1, 1);
      end;
    end; { case }
    CBFormat.Text:= CBFormat.Text + prefix + LVFormat.Selected.Caption;
    ETest.Text:= '';
  end;
end;

procedure TFormFormatUserInput.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const
  pt: TPoint = (x: 0; y: 0);
begin
  case Key of
    VK_F1, VK_HELP: begin
      FormDockBase.ShowHelpByIndex(pt, Nil, 'howtocreateinput');
    end;
  end;
end;

end.
