library AXComposerTaxonP;

uses
  ComServ,
  AXComposerTaxonP_TLB in 'AXComposerTaxonP_TLB.pas',
  AXComposerTaxonImpl in 'AXComposerTaxonImpl.pas' {AXComposerTaxon: TActiveForm} {AXComposerTaxon: CoClass},
  FComposerTaxonAbout in 'FComposerTaxonAbout.pas' {AXComposerTaxonAbout};

{$E ocx}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
