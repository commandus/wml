unit apooed_TLB;

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
// File generated on 05.03.2003 19:59:44 from Type Library described below.

// ************************************************************************  //
// Type Lib: E:\src\wml\apooed.tlb (1)
// LIBID: {66F725EE-9DCF-40C4-B04B-DBAF4B9CEAE0}
// LCID: 0
// Helpfile: 
// HelpString: apooed Library
// DepndLst: 
//   (1) v2.0 stdole, (E:\WINDOWS\System32\stdole2.tlb)
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
  apooedMajorVersion = 1;
  apooedMinorVersion = 0;

  LIBID_apooed: TGUID = '{66F725EE-9DCF-40C4-B04B-DBAF4B9CEAE0}';

  IID_IAPOOIEExtention: TGUID = '{4372A53A-ACCC-4E6E-B519-55F709210628}';
  CLASS_APOOIEExtention: TGUID = '{2BB44D1F-C2C1-4E15-A977-4094CF6808E0}';
  IID_IObjectWithSite: TGUID = '{746941A3-1DF9-4E70-96A2-13486566E3ED}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IAPOOIEExtention = interface;
  IObjectWithSite = interface;
  IObjectWithSiteDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  APOOIEExtention = IAPOOIEExtention;


// *********************************************************************//
// Interface: IAPOOIEExtention
// Flags:     (0)
// GUID:      {4372A53A-ACCC-4E6E-B519-55F709210628}
// *********************************************************************//
  IAPOOIEExtention = interface(IUnknown)
    ['{4372A53A-ACCC-4E6E-B519-55F709210628}']
  end;

// *********************************************************************//
// Interface: IObjectWithSite
// Flags:     (320) Dual OleAutomation
// GUID:      {746941A3-1DF9-4E70-96A2-13486566E3ED}
// *********************************************************************//
  IObjectWithSite = interface(IUnknown)
    ['{746941A3-1DF9-4E70-96A2-13486566E3ED}']
    procedure GetSite; safecall;
    procedure SetSite; safecall;
  end;

// *********************************************************************//
// DispIntf:  IObjectWithSiteDisp
// Flags:     (320) Dual OleAutomation
// GUID:      {746941A3-1DF9-4E70-96A2-13486566E3ED}
// *********************************************************************//
  IObjectWithSiteDisp = dispinterface
    ['{746941A3-1DF9-4E70-96A2-13486566E3ED}']
    procedure GetSite; dispid 6;
    procedure SetSite; dispid 7;
  end;

// *********************************************************************//
// The Class CoAPOOIEExtention provides a Create and CreateRemote method to          
// create instances of the default interface IAPOOIEExtention exposed by              
// the CoClass APOOIEExtention. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAPOOIEExtention = class
    class function Create: IAPOOIEExtention;
    class function CreateRemote(const MachineName: string): IAPOOIEExtention;
  end;

implementation

uses ComObj;

class function CoAPOOIEExtention.Create: IAPOOIEExtention;
begin
  Result := CreateComObject(CLASS_APOOIEExtention) as IAPOOIEExtention;
end;

class function CoAPOOIEExtention.CreateRemote(const MachineName: string): IAPOOIEExtention;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_APOOIEExtention) as IAPOOIEExtention;
end;

end.
