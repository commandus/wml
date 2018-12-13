unit fprint;
(*##*)
(*******************************************************************************
*                                                                              *
*   f  P  r  i  n  t                                                          *
*   Print dialog window, part of apooed                                        *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 103                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, Printers,
  EMemo, ComCtrls;

type
  TFormPrint = class(TForm)
    BOk: TButton;
    BCancel: TButton;
    BPrintSetup: TButton;
    GroupBox1: TGroupBox;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    LMsg: TLabel;
    CBSyntax: TCheckBox;
    procedure BPrintSetupClick(Sender: TObject);
    procedure BOkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    PrintFileName: String;
    function OnNextPage(Sender: TObject; APage, ALine: Integer): Boolean;
  public
    { Public declarations }
  end;

var
  FormPrint: TFormPrint;

implementation

{$R *.dfm}

uses
  FDockBase;

procedure TFormPrint.BPrintSetupClick(Sender: TObject);
begin
  with PrinterSetupDialog1 do begin
    if Execute then begin
    end;
  end;
end;

function TFormPrint.OnNextPage(Sender: TObject; APage, ALine: Integer): Boolean;
begin
  Result:= False;
  LMsg.Caption:= Format('Page %d of %s printed', [APage + 1, PrintFileName]);
  try
    Printer.NewPage;
    Result:= True;
  except
  end;
end;

procedure TFormPrint.BOkClick(Sender: TObject);
var
  c: Integer;
  curmemo: TECustomMemo;
  idx: Integer;
  R: TRect;
begin
  with PrintDialog1 do begin
    if Execute then begin
     { determine the range the user wants to print }
      with PrintDialog1 do begin
        if PrintRange = prSelection then begin
        end;
      end;
      idx:= FormDockBase.TCOpenFiles.TabIndex;
      if idx < 0
      then Exit;

      curmemo:= FormDockBase.Memos.Memo[idx];
      PrintFileName:= FormDockBase.Memos.FileStatus[idx].FileName;
      Caption:= Format('Print %s', [PrintFileName]);
      for c:= 0 to PrintDialog1.Copies - 1 do begin
        { now, print the pages }
        with Printer do begin
          with FormDockBase.Memos.FileStatus[idx] do begin
            Title:= Format('apoo editor, file: %s', [FileName]);
          end;
          BeginDoc;
          R.Left:= 0;
          R.Top:= 0;
          R.Right:= Printer.PageWidth;
          R.Bottom:= Printer.PageHeight;
          Printer.Canvas.Font.Name:= FormDockBase.GetCurMemo.Canvas.Font.Name;

          LMsg.Caption:= Format('Printing %s started', [PrintFileName]);

          try
            // add new page?!!
            FormDockBase.GetCurMemo.DrawDirect2Canvas(Printer.Canvas, R, OnNextPage, PrintFileName);
          finally
            EndDoc;
          end;
        end;
        LMsg.Caption:= Format('Printing %s, copy %d is finished', [PrintFileName, c + 1]);
      end;
    end;
  end;
end;

procedure TFormPrint.FormActivate(Sender: TObject);
begin
  BOk.SetFocus;
end;

end.
