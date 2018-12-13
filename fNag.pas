unit
  fNag;
(*##*)
(*******************************************************************************
*                                                                              *
*   F  N  A  G                                                                *
*   nag screen dialog window, part of apooed                                   *
*                                                                             *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.                 *
*                                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Mar 29 2002                                                 *
*   Last revision:                                                            *
*   Lines        : 121                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)


interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls,
  util1, ComCtrls;

type
  TFormNag = class(TForm)
    Panel1: TPanel;
    BContinue: TButton;
    PanelInfo: TPanel;
    BEnter: TButton;
    Timer1: TTimer;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BEnterClick(Sender: TObject);
  private
    { Private declarations }
    FhtmlHelpWnd: HWND;
  public
    { Public declarations }
  end;

var
  FormNag: TFormNag;

implementation

{$R *.dfm}

uses
  appconst, HtmlHlp, wmleditutil, fDockBase;

{ Thank you for using this trial version of apoo editor.
  Our trial period has been expired. Click here for upgrade }


procedure TFormNag.FormCreate(Sender: TObject);
begin
  BContinue.Enabled:= False;
  FhtmlHelpWnd:= wmleditutil.ShowHTMLHelpNag(PanelInfo,
    util1.ConcatPath(FormDockBase.FParameters.Values[ParameterNames[ID_ConfigDir]], DEFHELPFILE), 'z-nag');  //  Self.Handle
end;

procedure TFormNag.Timer1Timer(Sender: TObject);
begin
  ProgressBar1.Position:= ProgressBar1.Position + 1;
  BContinue.Enabled:= FormDockBase.FRegistered or (ProgressBar1.Position = ProgressBar1.Max);
end;

procedure TFormNag.BEnterClick(Sender: TObject);
begin
  with FormDockBase do begin
    actHelpEnterCodeExecute(Self);
    BContinue.Enabled:= FRegistered;
  end;  
end;

end.
