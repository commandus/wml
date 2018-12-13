program wapgate3;
(*##*)
(*******************************************************************
*                                                                 *
*   w  a  p  g  a  t  e  3                                         *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   WAP gateway, MS Windows application                           *
*   Conditional defines:                                           *
*                                                                 *
*                                                                  *
*                                                                 *
*   Last Revision: Nov 28 2001                                     *
*   Last fix     : Mar 29 2002                                    *
*   Lines        : 31                                              *
*   Project size : 31                                             *
*   History      : 50277 lines                                     *
*                                                                 *
*   Printed      : ---                                             *
*                                                                 *
********************************************************************)
(*##*)

uses
  Forms,
  fmain in 'fmain.pas' {FormMain},
  pdu in '..\..\pdu.pas',
  resWAPStrings in '..\..\resWAPStrings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
