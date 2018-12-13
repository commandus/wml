unit WMLInfo_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 09.01.2005 13:39:26 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\src\wml\util\infotip\column\apooInfoTip.tlb (1)
// LIBID: {8DC76F80-09F4-44FD-A101-3E43FF78C695}
// LCID: 0
// Helpfile: 
// HelpString: WML info rip library
// DepndLst: 
//   (1) v2.0 stdole, (E:\WINDOWS\System32\Stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WMLInfoMajorVersion = 1;
  WMLInfoMinorVersion = 0;

  LIBID_WMLInfo: TGUID = '{8DC76F80-09F4-44FD-A101-3E43FF78C695}';

  IID_IWMLInfoTip: TGUID = '{B4D5F9E3-A8E9-4845-BA36-B10B29928B3B}';
  CLASS_WMLInfoTip: TGUID = '{A6614304-6DFB-4A31-8032-C4E0CCA42D81}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWMLInfoTip = interface;
  IWMLInfoTipDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WMLInfoTip = IWMLInfoTip;


// *********************************************************************//
// Interface: IWMLInfoTip
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4D5F9E3-A8E9-4845-BA36-B10B29928B3B}
// *********************************************************************//
  IWMLInfoTip = interface(IDispatch)
    ['{B4D5F9E3-A8E9-4845-BA36-B10B29928B3B}']
  end;

// *********************************************************************//
// DispIntf:  IWMLInfoTipDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B4D5F9E3-A8E9-4845-BA36-B10B29928B3B}
// *********************************************************************//
  IWMLInfoTipDisp = dispinterface
    ['{B4D5F9E3-A8E9-4845-BA36-B10B29928B3B}']
  end;

// *********************************************************************//
// The Class CoWMLInfoTip provides a Create and CreateRemote method to          
// create instances of the default interface IWMLInfoTip exposed by              
// the CoClass WMLInfoTip. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWMLInfoTip = class
    class function Create: IWMLInfoTip;
    class function CreateRemote(const MachineName: string): IWMLInfoTip;
  end;

implementation

uses ComObj;

class function CoWMLInfoTip.Create: IWMLInfoTip;
begin
  Result := CreateComObject(CLASS_WMLInfoTip) as IWMLInfoTip;
end;

class function CoWMLInfoTip.CreateRemote(const MachineName: string): IWMLInfoTip;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WMLInfoTip) as IWMLInfoTip;
end;

end.
