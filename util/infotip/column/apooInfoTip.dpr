library
  apooInfoTip;
(*##*)
(*******************************************************************************
*                                                                             *
*   w  m  l  I  n  f  o  T  i  p                                               *
*                                                                             *
*   Copyright (c) 2002, Andrei Ivanov. All rights reserved.                    *
*   wireless markup language info tip library                                 *
*   Conditional defines:                                                       *
*                                                                             *
*   Last Revision: Jan 16 2002                                                 *
*   Last fix     : Jan 16 2002                                                *
*   Related docs:  http://www.rsdn.ru/article/winshell/shlext1.xml             *
*                                                                             *
*   Lines        : 206                                                         *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

uses
  ComServ,
  WMLInfoTipImpl in 'WMLInfoTipImpl.pas' {WMLInfoTip: CoClass},
  WMLColumnImpl in 'WMLColumnImpl.pas' {WMLColumn: CoClass},
  WMLInfo_TLB in 'WMLInfo_TLB.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
