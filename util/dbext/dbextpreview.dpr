program
  dbextpreview;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  b  e  x  t  p  r  e  v  i  e  w                                         *
*                                                                             *
*   Copyright © 2002 Andrei Ivanov. All rights reserved.                       *
*   server extension test program                                             *
*   Conditional defines: USE_DLL or USE_BDE|USE_IB|USE_ADO                     *
*                                                                             *
*   Revisions    : May 27 2002                                                 *
*   Last fix     : May 27 2002                                                *
*   Lines        : 32                                                          *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

uses
  Forms,
  fmain in 'fmain.pas' {FormMain},
  fsettings in 'fsettings.pas' {FormSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
