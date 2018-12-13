unit
  wml_browser;

interface
type
  TatID = ShortString;
  TatCDATA = WideString;
  TNMTOKEN = ShortString;

  TWMLBaseElement = class(TxmlElement)
  private
    Fid: TatID; // IMPLIED, NODEFAULT, NOLIST);
    Fclass: TatCDATA; // IMPLIED, NODEFAULT, NOLIST);
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWML_Lang = class(TWMLBaseElement)
  private
    Fxml_lang: TNMTOKEN; // IMPLIED, NODEFAULT, NOLIST);
  protected
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TWMLWML = class(TWML_Lang)
  private
    FBinCode:= $3F;
    FNestedElements.AddNew(TxmlComment, wciAny);
    FNestedElements.AddNew(TxmlSSScript, wciAny);

    FNestedElements.AddNew(TWMLHead, wciAny);
    FNestedElements.AddNew(TWMLTemplate, wciAny);
    FNestedElements.AddNew(TWMLCard, wciOneOrMore);
  protected
  public
    function CanInsertElement(AElementClass: TPersistentClass): Boolean; override;
    constructor Create(ACollection: TCollection); override;
  end;

implementation

end.
