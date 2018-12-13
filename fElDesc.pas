unit
  fElDesc;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  E  L  D  E  S  C                                                       *
*   wml element description window, part of apooed                             *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 179                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  util1, customxml, xmlsupported, wml, xmlParse, wmleditutil,
  dm;

const
  HINTFILENAME = 'hint.wml';
type
  TFormElementDescription = class(TForm)
    MemoBrief: TMemo;
    MemoAttr: TMemo;
    Splitter1: TSplitter;
    PanelNavigate: TPanel;
    CBEElement: TComboBoxEx;
    LElement: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CBEElementChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FElementDescWMLCollection: TxmlElementCollection;
    root: TxmlElement;
  public
    { Public declarations }
    procedure ShowElement(AWMLElementClass: TxmlElementClass);
    procedure ShowAbout;
  end;

var
  FormElementDescription: TFormElementDescription;

implementation

{$R *.dfm}

procedure TFormElementDescription.FormCreate(Sender: TObject);
var
  e, imIdx: Integer;
  Indent: Integer;
  src: String;
  dsc: TxmlClassDesc;
begin
  if not GetxmlClassDescByClass(TwmlContainer, dsc)
  then Exit;
  // create CBEElement items
  with CBEElement.Items do begin
    Clear;
    BeginUpdate;
    for e:= 0 to dsc.len - 1 do begin
      imIdx:= GetBitmapIndexByClass(dsc.classes[e]);
      Indent:= 0;
      CBEElement.ItemsEx.AddItem(dsc.classes[e].GetElementName, imIdx, imIdx, imIdx, Indent, dsc.classes[e])
    end;
    EndUpdate;
  end;
  // load hint file
  FElementDescWMLCollection:= TxmlElementCollection.Create(TWMLContainer, Nil, wciOne);
  FElementDescWMLCollection.Add;
  root:= FElementDescWMLCollection.Items[0];
  src:= util1.File2String(HINTFILENAME);
  xmlParse.xmlCompileText(src, Nil, Nil, Nil, FElementDescWMLCollection.Items[0], TwmlContainer);
  // load first screen
  // ..
end;

procedure TFormElementDescription.FormDestroy(Sender: TObject);
begin
  FElementDescWMLCollection.Free;
end;

procedure TFormElementDescription.ShowElement(AWMLElementClass: TxmlElementClass);
begin
  try
    CBEElement.ItemIndex:= GetBitmapIndexByClass(AWMLElementClass);
  except
    //?!! impossible!
  end;
  // call CBEElementChange
  CBEElementChange(Self);
end;

procedure TFormElementDescription.ShowAbout;
const
  ABOUTCARDID = 'about';
var
  c, p, t: Integer;
  card, para, txt: TxmlElement;
begin
  // clear memos
  MemoBrief.Lines.Text:= '';
  MemoAttr.Lines.Text:= '';
  // look for card
  for c:= 0 to root.NestedElementCount[TWMLCard] - 1 do begin
    card:= root.NestedElement[TWMLCard, c];
    if CompareText(ABOUTCARDID, card.Name) = 0 then begin
      // look for pcdata elements
      for p:= 0 to card.NestedElementCount[TWMLP] - 1 do begin
        para:= card.NestedElement[TWMLP, p];
        if CompareText(ABOUTCARDID + 'brief', para.Name) = 0 then begin
          // brief description
          // MemoBrief.Lines.Text:= para.CreateText(0, 0);
          for t:= 0 to para.NestedElementCount[TWMLPCData] - 1 do begin
            txt:= para.NestedElement[TWMLPCData, t];
            MemoBrief.Lines.Add(txt.Attributes.ValueByName['value']);
          end;
        end;
        if CompareText(ABOUTCARDID + 'attr', para.Name) = 0 then begin
          // attribites list
          for t:= 0 to para.NestedElementCount[TWMLPCData] - 1 do begin
            txt:= para.NestedElement[TWMLPCData, t];
            MemoAttr.Lines.Add(txt.Attributes.ValueByName['value']);
          end;
        end;
      end;
      Break;
    end;
  end;
end;

procedure TFormElementDescription.CBEElementChange(Sender: TObject);
var
  elementname: String;
  c, p, t: Integer;
  card, para, txt: TxmlElement;
begin
  with CBEElement do begin
    if (ItemIndex < 0) or (ItemIndex > ItemsEx.Count)
    then ItemIndex:= 0; // Exit;
    // Look for element card brief and attr
    elementname:= ItemsEx[ItemIndex].Caption;
  end;
  // clear memos
  MemoBrief.Lines.Text:= '';
  MemoAttr.Lines.Text:= '';
  // look for card
  for c:= 0 to root.NestedElementCount[TWMLCard] - 1 do begin
    card:= root.NestedElement[TWMLCard, c];
    if CompareText(elementname, card.Name) = 0 then begin
      // look for pcdata elements
      for p:= 0 to card.NestedElementCount[TWMLP] - 1 do begin
        para:= card.NestedElement[TWMLP, p];
        if CompareText(elementname + 'brief', para.Name) = 0 then begin
          // brief description
          // MemoBrief.Lines.Text:= para.CreateText(0, 0);
          for t:= 0 to para.NestedElementCount[TWMLPCData] - 1 do begin
            txt:= para.NestedElement[TWMLPCData, t];
            MemoBrief.Lines.Add(txt.Attributes.ValueByName['value']);
          end;
        end;
        if CompareText(elementname + 'attr', para.Name) = 0 then begin
          // attribites list
          for t:= 0 to para.NestedElementCount[TWMLPCData] - 1 do begin
            txt:= para.NestedElement[TWMLPCData, t];
            MemoAttr.Lines.Add(txt.Attributes.ValueByName['value']);
          end;
        end;
      end;
      Break;
    end;
  end;
end;

end.
