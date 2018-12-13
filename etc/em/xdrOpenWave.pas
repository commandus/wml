unit xdrOpenWave;

interface

uses
  xmldom, XMLDoc, XMLIntf, SysUtils,
  Controls;
type

{ IXMLUiimagesType }

  IXMLUiimagesType = interface(IXMLNode)
    ['{9A510809-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Imagenormal: String;
    function Get_Imageover: String;
    function Get_Imagepressed: String;
    { Methods & Properties }
    property Imagenormal: String read Get_Imagenormal;
    property Imageover: String read Get_Imageover;
    property Imagepressed: String read Get_Imagepressed;
  end;

{ IXMLButtonType }

  IXMLButtonType = interface(IXMLNode)
    ['{9A51080A-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Comment: ANSIString;
    function Get_X1: Integer;
    function Get_Y1: Integer;
    function Get_X2: Integer;
    function Get_Y2: Integer;
    procedure Set_Comment(Value: ANSIString);
    procedure Set_X1(Value: Integer);
    procedure Set_Y1(Value: Integer);
    procedure Set_X2(Value: Integer);
    procedure Set_Y2(Value: Integer);
    { Methods & Properties }
    property Comment: ANSIString read Get_Comment write Set_Comment;
    property X1: Integer read Get_X1 write Set_X1;
    property Y1: Integer read Get_Y1 write Set_Y1;
    property X2: Integer read Get_X2 write Set_X2;
    property Y2: Integer read Get_Y2 write Set_Y2;
  end;

{ IXMLButtonsType }

  IXMLButtonsType = interface(IXMLNodeCollection)
    ['{9A51080B-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Button(Index: Integer): IXMLButtonType;
    { Methods & Properties }
    function Add: IXMLButtonType;
    function Insert(const Index: Integer): IXMLButtonType;
    property Button[Index: Integer]: IXMLButtonType read Get_Button; default;
  end;

{ IXMLUserinterfaceType }

  IXMLUserinterfaceType = interface(IXMLNode)
    ['{9A51080C-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Displayoffsetx: Integer;
    function Get_Displayoffsety: Integer;
    function Get_Uiimages: IXMLUiimagesType;
    function Get_Buttons: IXMLButtonsType;
    { Methods & Properties }
    property Displayoffsetx: Integer read Get_Displayoffsetx;
    property Displayoffsety: Integer read Get_Displayoffsety;
    property Uiimages: IXMLUiimagesType read Get_Uiimages;
    property Buttons: IXMLButtonsType read Get_Buttons;
  end;

{ IXMLFontType }

  IXMLFontType = interface(IXMLNode)
    ['{9A51080D-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Name: ANSIString;
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_Variablewidth: Boolean;
    function Get_Bold: Boolean;
    function Get_Italics: Boolean;
    function Get_Underline: Boolean;
    procedure Set_Name(Value: ANSIString);
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
    procedure Set_Variablewidth(Value: Boolean);
    procedure Set_Bold(Value: Boolean);
    procedure Set_Italics(Value: Boolean);
    procedure Set_Underline(Value: Boolean);
    { Methods & Properties }
    property Name: ANSIString read Get_Name write Set_Name;
    property Height: Integer read Get_Height write Set_Height;
    property Width: Integer read Get_Width write Set_Width;
    property Variablewidth: Boolean read Get_Variablewidth write Set_Variablewidth;
    property Bold: Boolean read Get_Bold write Set_Bold;
    property Italics: Boolean read Get_Italics write Set_Italics;
    property Underline: Boolean read Get_Underline write Set_Underline;
  end;

{ IXMLSizeType }

  IXMLSizeType = interface(IXMLNode)
    ['{9A51080E-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    procedure Set_X(Value: Integer);
    procedure Set_Y(Value: Integer);
    { Methods & Properties }
    property X: Integer read Get_X write Set_X;
    property Y: Integer read Get_Y write Set_Y;
  end;

{ IXMLCharacterType }

  IXMLCharacterType = interface(IXMLNode)
    ['{9A51080F-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Value: ANSIString;
    function Get_Comment: ANSIString;
    function Get_Height: Integer;
    function Get_Width: Integer;
    procedure Set_Value(Value: ANSIString);
    procedure Set_Comment(Value: ANSIString);
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
    { Methods & Properties }
    property Value: ANSIString read Get_Value write Set_Value;
    property Comment: ANSIString read Get_Comment write Set_Comment;
    property Height: Integer read Get_Height write Set_Height;
    property Width: Integer read Get_Width write Set_Width;
  end;

{ IXMLCharactersetType }

  IXMLCharactersetType = interface(IXMLNodeCollection)
    ['{9A510810-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_Variablewidth: Boolean;
    function Get_Character(Index: Integer): IXMLCharacterType;
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
    procedure Set_Variablewidth(Value: Boolean);
    { Methods & Properties }
    function Add: IXMLCharacterType;
    function Insert(const Index: Integer): IXMLCharacterType;
    property Height: Integer read Get_Height write Set_Height;
    property Width: Integer read Get_Width write Set_Width;
    property Variablewidth: Boolean read Get_Variablewidth write Set_Variablewidth;
    property Character[Index: Integer]: IXMLCharacterType read Get_Character; default;
  end;

{ IXMLFgcolorType }

  IXMLFgcolorType = interface(IXMLNode)
    ['{9A510811-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Red: Integer;
    function Get_Green: Integer;
    function Get_Blue: Integer;
    procedure Set_Red(Value: Integer);
    procedure Set_Green(Value: Integer);
    procedure Set_Blue(Value: Integer);
    { Methods & Properties }
    property Red: Integer read Get_Red write Set_Red;
    property Green: Integer read Get_Green write Set_Green;
    property Blue: Integer read Get_Blue write Set_Blue;
  end;

{ IXMLBgcolorType }

  IXMLBgcolorType = interface(IXMLNode)
    ['{9A510812-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Red: Integer;
    function Get_Green: Integer;
    function Get_Blue: Integer;
    procedure Set_Red(Value: Integer);
    procedure Set_Green(Value: Integer);
    procedure Set_Blue(Value: Integer);
    { Methods & Properties }
    property Red: Integer read Get_Red write Set_Red;
    property Green: Integer read Get_Green write Set_Green;
    property Blue: Integer read Get_Blue write Set_Blue;
  end;

{ IXMLBrowserareaType }

  IXMLBrowserareaType = interface(IXMLNode)
    ['{9A510813-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Fgcolor: Integer read Get_Fgcolor;
    property Bgcolor: Integer read Get_Bgcolor;
  end;

{ IXMLStatusbarareaType }

  IXMLStatusbarareaType = interface(IXMLNode)
    ['{9A510814-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Fgcolor: Integer read Get_Fgcolor;
    property Bgcolor: Integer read Get_Bgcolor;
  end;

{ IXMLSoftbutton1Type }

  IXMLSoftbutton1Type = interface(IXMLNode)
    ['{9A510816-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Align: TAlign;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Align: TAlign read Get_Align;
  end;

{ IXMLSoftbutton2Type }

  IXMLSoftbutton2Type = interface(IXMLNode)
    ['{9A510817-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Align: TAlign;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Align: TAlign read Get_Align;
  end;

{ IXMLSoftbuttonsType }

  IXMLSoftbuttonsType = interface(IXMLNode)
    ['{9A51081A-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Fgcolor: IXMLFgcolorType;
    function Get_Bgcolor: IXMLBgcolorType;
    function Get_Font: IXMLFontType;
    function Get_Drawstyle: Integer;
    function Get_Presentationstyle: Integer;
    function Get_Softbutton1: IXMLSoftbutton1Type;
    function Get_Softbutton2: IXMLSoftbutton2Type;
    { Methods & Properties }
    property Fgcolor: IXMLFgcolorType read Get_Fgcolor;
    property Bgcolor: IXMLBgcolorType read Get_Bgcolor;
    property Font: IXMLFontType read Get_Font;
    property Drawstyle: Integer read Get_Drawstyle;
    property Presentationstyle: Integer read Get_Presentationstyle;
    property Softbutton1: IXMLSoftbutton1Type read Get_Softbutton1;
    property Softbutton2: IXMLSoftbutton2Type read Get_Softbutton2;
  end;

{ IXMLScrollbarimagesType }

  IXMLScrollbarimagesType = interface(IXMLNode)
    ['{9A51081F-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Imagetop: String;
    function Get_Imagebottom: String;
    function Get_Imagemiddle: String;
    function Get_Imagenoscroll: String;
    { Methods & Properties }
    property Imagetop: String read Get_Imagetop;
    property Imagebottom: String read Get_Imagebottom;
    property Imagemiddle: String read Get_Imagemiddle;
    property Imagenoscroll: String read Get_Imagenoscroll;
  end;

{ IXMLScrollbarareaType }

  IXMLScrollbarareaType = interface(IXMLNode)
    ['{9A510820-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Font: IXMLFontType;
    function Get_Scrollbarimages: IXMLScrollbarimagesType;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Fgcolor: Integer read Get_Fgcolor;
    property Bgcolor: Integer read Get_Bgcolor;
    property Font: IXMLFontType read Get_Font;
    property Scrollbarimages: IXMLScrollbarimagesType read Get_Scrollbarimages;
  end;

{ IXMLTitlebarareaType }

  IXMLTitlebarareaType = interface(IXMLNode)
    ['{9A510821-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Font: IXMLFontType;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Xoffset: Integer read Get_Xoffset;
    property Yoffset: Integer read Get_Yoffset;
    property Fgcolor: Integer read Get_Fgcolor;
    property Bgcolor: Integer read Get_Bgcolor;
    property Font: IXMLFontType read Get_Font;
  end;

{ IXMLDisplayType }

  IXMLDisplayType = interface(IXMLNode)
    ['{9A510822-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Devicex: Integer;
    function Get_Devicey: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Browserarea: IXMLBrowserareaType;
    function Get_Statusbararea: IXMLStatusbarareaType;
    function Get_Softbuttons: IXMLSoftbuttonsType;
    function Get_Scrollbararea: IXMLScrollbarareaType;
    function Get_Titlebararea: IXMLTitlebarareaType;
    { Methods & Properties }
    property X: Integer read Get_X;
    property Y: Integer read Get_Y;
    property Devicex: Integer read Get_Devicex;
    property Devicey: Integer read Get_Devicey;
    property Fgcolor: Integer read Get_Fgcolor;
    property Bgcolor: Integer read Get_Bgcolor;
    property Browserarea: IXMLBrowserareaType read Get_Browserarea;
    property Statusbararea: IXMLStatusbarareaType read Get_Statusbararea;
    property Softbuttons: IXMLSoftbuttonsType read Get_Softbuttons;
    property Scrollbararea: IXMLScrollbarareaType read Get_Scrollbararea;
    property Titlebararea: IXMLTitlebarareaType read Get_Titlebararea;
  end;

{ IXMLParserType }

  IXMLParserType = interface(IXMLNode)
    ['{9A510837-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Xdevicebrowser: Integer;
    function Get_Characterset: IXMLCharactersetType;
    function Get_Font: IXMLFontType;
    function Get_Cxprefix: Integer;
    function Get_Cyprefix: Integer;
    function Get_Supportbold: Boolean;
    function Get_Supportitalics: Boolean;
    function Get_Supportunderline: Boolean;
    function Get_Supportstrong: Boolean;
    function Get_Supportemphasis: Boolean;
    function Get_Supportbig: Boolean;
    function Get_Supportsmall: Boolean;
    function Get_Supportimages: Boolean;
    function Get_Supportlocalsrcimages: Boolean;
    function Get_Supportaccesskeys: Boolean;
    function Get_Anchordelimleft: Char;
    function Get_Anchordelimright: Char;
    function Get_Highlightmode: Integer;
    function Get_Imgselect: String;
    function Get_Imgselectblank: String;
    function Get_Imgscroll: String;
    function Get_Imgscrollblank: String;
    { Methods & Properties }
    property Xdevicebrowser: Integer read Get_Xdevicebrowser;
    property Characterset: IXMLCharactersetType read Get_Characterset;
    property Font: IXMLFontType read Get_Font;
    property Cxprefix: Integer read Get_Cxprefix;
    property Cyprefix: Integer read Get_Cyprefix;
    property Supportbold: Boolean read Get_Supportbold;
    property Supportitalics: Boolean read Get_Supportitalics;
    property Supportunderline: Boolean read Get_Supportunderline;
    property Supportstrong: Boolean read Get_Supportstrong;
    property Supportemphasis: Boolean read Get_Supportemphasis;
    property Supportbig: Boolean read Get_Supportbig;
    property Supportsmall: Boolean read Get_Supportsmall;
    property Supportimages: Boolean read Get_Supportimages;
    property Supportlocalsrcimages: Boolean read Get_Supportlocalsrcimages;
    property Supportaccesskeys: Boolean read Get_Supportaccesskeys;
    property Anchordelimleft: Char read Get_Anchordelimleft;
    property Anchordelimright: Char read Get_Anchordelimright;
    property Highlightmode: Integer read Get_Highlightmode;
    property Imgselect: String read Get_Imgselect;
    property Imgselectblank: String read Get_Imgselectblank;
    property Imgscroll: String read Get_Imgscroll;
    property Imgscrollblank: String read Get_Imgscrollblank;
  end;

{ IXMLAccepttypesType }

  IXMLAccepttypesType = interface(IXMLNodeCollection)
    ['{9A510839-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Accepttype(Index: Integer): String;
    { Methods & Properties }
    function Add: String;
    function Insert(const Index: Integer): String;
    property Accepttype[Index: Integer]: String read Get_Accepttype; default;
  end;

{ IXMLDeviceType }

  IXMLDeviceType = interface(IXMLNode)
    ['{9A51083B-0202-11D6-A03C-F3237B93C631}']
    { Property Accessors }
    function Get_Name: ANSIString; safecall;
    function Get_Progid: ANSIString; safecall;
    function Get_Platformid: ANSIString; safecall;
    function Get_Userinterface: IXMLUserinterfaceType; safecall;
    function Get_Display: IXMLDisplayType; safecall;
    function Get_Parser: IXMLParserType; safecall;
    function Get_Accepttypes: IXMLAccepttypesType; safecall;
    function Get_Requestheaders: String; safecall;
    { Methods & Properties }
    property Name: ANSIString read Get_Name;
    property Progid: ANSIString read Get_Progid;
    property Platformid: ANSIString read Get_Platformid;
    property Userinterface: IXMLUserinterfaceType read Get_Userinterface;
    property Display: IXMLDisplayType read Get_Display;
    property Parser: IXMLParserType read Get_Parser;
    property Accepttypes: IXMLAccepttypesType read Get_Accepttypes;
    property Requestheaders: String read Get_Requestheaders;
  end;

{ TXMLUiimagesType }

  TXMLUiimagesType = class(TXMLNode, IXMLUiimagesType)
  protected
    { IXMLUiimagesType }
    function Get_Imagenormal: String;
    function Get_Imageover: String;
    function Get_Imagepressed: String;
  end;

{ TXMLButtonType }

  TXMLButtonType = class(TXMLNode, IXMLButtonType)
  protected
    { IXMLButtonType }
    function Get_Comment: ANSIString;
    function Get_X1: Integer;
    function Get_Y1: Integer;
    function Get_X2: Integer;
    function Get_Y2: Integer;
    procedure Set_Comment(Value: ANSIString);
    procedure Set_X1(Value: Integer);
    procedure Set_Y1(Value: Integer);
    procedure Set_X2(Value: Integer);
    procedure Set_Y2(Value: Integer);
  end;

{ TXMLButtonsType }

  TXMLButtonsType = class(TXMLNodeCollection, IXMLButtonsType)
  protected
    { IXMLButtonsType }
    function Get_Button(Index: Integer): IXMLButtonType;
    function Add: IXMLButtonType;
    function Insert(const Index: Integer): IXMLButtonType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLUserinterfaceType }

  TXMLUserinterfaceType = class(TXMLNode, IXMLUserinterfaceType)
  protected
    { IXMLUserinterfaceType }
    function Get_Displayoffsetx: Integer;
    function Get_Displayoffsety: Integer;
    function Get_Uiimages: IXMLUiimagesType;
    function Get_Buttons: IXMLButtonsType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLFontType }

  TXMLFontType = class(TXMLNode, IXMLFontType)
  protected
    { IXMLFontType }
    function Get_Name: ANSIString;
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_Variablewidth: Boolean;
    function Get_Bold: Boolean;
    function Get_Italics: Boolean;
    function Get_Underline: Boolean;
    procedure Set_Name(Value: ANSIString);
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
    procedure Set_Variablewidth(Value: Boolean);
    procedure Set_Bold(Value: Boolean);
    procedure Set_Italics(Value: Boolean);
    procedure Set_Underline(Value: Boolean);
  end;

{ TXMLSizeType }

  TXMLSizeType = class(TXMLNode, IXMLSizeType)
  protected
    { IXMLSizeType }
    function Get_X: Integer;
    function Get_Y: Integer;
    procedure Set_X(Value: Integer);
    procedure Set_Y(Value: Integer);
  end;

{ TXMLCharacterType }

  TXMLCharacterType = class(TXMLNode, IXMLCharacterType)
  protected
    { IXMLCharacterType }
    function Get_Value: ANSIString;
    function Get_Comment: ANSIString;
    function Get_Height: Integer;
    function Get_Width: Integer;
    procedure Set_Value(Value: ANSIString);
    procedure Set_Comment(Value: ANSIString);
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
  end;

{ TXMLCharactersetType }

  TXMLCharactersetType = class(TXMLNodeCollection, IXMLCharactersetType)
  protected
    { IXMLCharactersetType }
    function Get_Height: Integer;
    function Get_Width: Integer;
    function Get_Variablewidth: Boolean;
    function Get_Character(Index: Integer): IXMLCharacterType;
    procedure Set_Height(Value: Integer);
    procedure Set_Width(Value: Integer);
    procedure Set_Variablewidth(Value: Boolean);
    function Add: IXMLCharacterType;
    function Insert(const Index: Integer): IXMLCharacterType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLFgcolorType }

  TXMLFgcolorType = class(TXMLNode, IXMLFgcolorType)
  protected
    { IXMLFgcolorType }
    function Get_Red: Integer;
    function Get_Green: Integer;
    function Get_Blue: Integer;
    procedure Set_Red(Value: Integer);
    procedure Set_Green(Value: Integer);
    procedure Set_Blue(Value: Integer);
  end;

{ TXMLBgcolorType }

  TXMLBgcolorType = class(TXMLNode, IXMLBgcolorType)
  protected
    { IXMLBgcolorType }
    function Get_Red: Integer;
    function Get_Green: Integer;
    function Get_Blue: Integer;
    procedure Set_Red(Value: Integer);
    procedure Set_Green(Value: Integer);
    procedure Set_Blue(Value: Integer);
  end;

{ TXMLBrowserareaType }

  TXMLBrowserareaType = class(TXMLNode, IXMLBrowserareaType)
  protected
    { IXMLBrowserareaType }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
  public
  end;

{ TXMLStatusbarareaType }

  TXMLStatusbarareaType = class(TXMLNode, IXMLStatusbarareaType)
  protected
    { IXMLStatusbarareaType }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
  public
  end;

{ TXMLSoftbutton1Type }

  TXMLSoftbutton1Type = class(TXMLNode, IXMLSoftbutton1Type)
  protected
    { IXMLSoftbutton1Type }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Align: TAlign;
  public
  end;

{ TXMLSoftbutton2Type }

  TXMLSoftbutton2Type = class(TXMLNode, IXMLSoftbutton2Type)
  protected
    { IXMLSoftbutton2Type }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Align: TAlign;
  end;

{ TXMLSoftbuttonsType }

  TXMLSoftbuttonsType = class(TXMLNode, IXMLSoftbuttonsType)
  protected
    { IXMLSoftbuttonsType }
    function Get_Fgcolor: IXMLFgcolorType;
    function Get_Bgcolor: IXMLBgcolorType;
    function Get_Font: IXMLFontType;
    function Get_Drawstyle: Integer;
    function Get_Presentationstyle: Integer;
    function Get_Softbutton1: IXMLSoftbutton1Type;
    function Get_Softbutton2: IXMLSoftbutton2Type;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLScrollbarimagesType }

  TXMLScrollbarimagesType = class(TXMLNode, IXMLScrollbarimagesType)
  protected
    { IXMLScrollbarimagesType }
    function Get_Imagetop: String;
    function Get_Imagebottom: String;
    function Get_Imagemiddle: String;
    function Get_Imagenoscroll: String;
  end;

{ TXMLScrollbarareaType }

  TXMLScrollbarareaType = class(TXMLNode, IXMLScrollbarareaType)
  protected
    { IXMLScrollbarareaType }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Font: IXMLFontType;
    function Get_Scrollbarimages: IXMLScrollbarimagesType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLTitlebarareaType }

  TXMLTitlebarareaType = class(TXMLNode, IXMLTitlebarareaType)
  protected
    { IXMLTitlebarareaType }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Xoffset: Integer;
    function Get_Yoffset: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Font: IXMLFontType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLDisplayType }

  TXMLDisplayType = class(TXMLNode, IXMLDisplayType)
  protected
    { IXMLDisplayType }
    function Get_X: Integer;
    function Get_Y: Integer;
    function Get_Devicex: Integer;
    function Get_Devicey: Integer;
    function Get_Fgcolor: Integer;
    function Get_Bgcolor: Integer;
    function Get_Browserarea: IXMLBrowserareaType;
    function Get_Statusbararea: IXMLStatusbarareaType;
    function Get_Softbuttons: IXMLSoftbuttonsType;
    function Get_Scrollbararea: IXMLScrollbarareaType;
    function Get_Titlebararea: IXMLTitlebarareaType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLParserType }

  TXMLParserType = class(TXMLNode, IXMLParserType)
  protected
    { IXMLParserType }
    function Get_Xdevicebrowser: Integer;
    function Get_Characterset: IXMLCharactersetType;
    function Get_Font: IXMLFontType;
    function Get_Cxprefix: Integer;
    function Get_Cyprefix: Integer;
    function Get_Supportbold: Boolean;
    function Get_Supportitalics: Boolean;
    function Get_Supportunderline: Boolean;
    function Get_Supportstrong: Boolean;
    function Get_Supportemphasis: Boolean;
    function Get_Supportbig: Boolean;
    function Get_Supportsmall: Boolean;
    function Get_Supportimages: Boolean;
    function Get_Supportlocalsrcimages: Boolean;
    function Get_Supportaccesskeys: Boolean;
    function Get_Anchordelimleft: Char;
    function Get_Anchordelimright: Char;
    function Get_Highlightmode: Integer;
    function Get_Imgselect: String;
    function Get_Imgselectblank: String;
    function Get_Imgscroll: String;
    function Get_Imgscrollblank: String;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLAccepttypesType }

  TXMLAccepttypesType = class(TXMLNodeCollection, IXMLAccepttypesType)
  protected
    { IXMLAccepttypesType }
    function Get_Accepttype(Index: Integer): String;
    function Add: String;
    function Insert(const Index: Integer): String;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLDeviceType }

  TXMLDeviceType = class(TXMLNode, IXMLDeviceType)
  protected
    { IXMLDeviceType }
    function Get_Name: ANSIString; safecall;
    function Get_Progid: ANSIString; safecall;
    function Get_Platformid: ANSIString; safecall;
    function Get_Requestheaders: String; safecall;
    function Get_Userinterface: IXMLUserinterfaceType; safecall;
    function Get_Display: IXMLDisplayType; safecall;
    function Get_Parser: IXMLParserType; safecall;
    function Get_Accepttypes: IXMLAccepttypesType; safecall;
  public
    procedure AfterConstruction; override;
  end;

function GetDevice(Doc: IXMLDocument): IXMLDeviceType;

function LoadDevice(const FileName: ANSIString): IXMLDeviceType;

function NewDevice: IXMLDeviceType;

implementation

function TXMLUiimagesType.Get_Imagenormal: String;
begin
  Result := ChildNodes['imagenormal'].Text;
end;

function TXMLUiimagesType.Get_Imageover: String;
begin
  Result := ChildNodes['imageover'].Text;
end;

function TXMLUiimagesType.Get_Imagepressed: String;
begin
  Result := ChildNodes['imagepressed'].Text;
end;

{ TXMLButtonType }

function TXMLButtonType.Get_Comment: ANSIString;
begin
  Result := AttributeNodes['comment'].Text;
end;

procedure TXMLButtonType.Set_Comment(Value: ANSIString);
begin
  SetAttribute('comment', Value);
end;

function TXMLButtonType.Get_X1: Integer;
begin
  Result := AttributeNodes['x1'].NodeValue;
end;

procedure TXMLButtonType.Set_X1(Value: Integer);
begin
  SetAttribute('x1', Value);
end;

function TXMLButtonType.Get_Y1: Integer;
begin
  Result := AttributeNodes['y1'].NodeValue;
end;

procedure TXMLButtonType.Set_Y1(Value: Integer);
begin
  SetAttribute('y1', Value);
end;

function TXMLButtonType.Get_X2: Integer;
begin
  Result := AttributeNodes['x2'].NodeValue;
end;

procedure TXMLButtonType.Set_X2(Value: Integer);
begin
  SetAttribute('x2', Value);
end;

function TXMLButtonType.Get_Y2: Integer;
begin
  Result := AttributeNodes['y2'].NodeValue;
end;

procedure TXMLButtonType.Set_Y2(Value: Integer);
begin
  SetAttribute('y2', Value);
end;

{ TXMLButtonsType }

procedure TXMLButtonsType.AfterConstruction;
begin
  RegisterChildNode('button', TXMLButtonType);
  ItemTag := 'button';
  ItemInterface := IXMLButtonType;
  inherited;
end;

function TXMLButtonsType.Get_Button(Index: Integer): IXMLButtonType;
begin
  Result := List[Index] as IXMLButtonType;
end;

function TXMLButtonsType.Add: IXMLButtonType;
begin
  Result := AddItem(-1) as IXMLButtonType;
end;

function TXMLButtonsType.Insert(const Index: Integer): IXMLButtonType;
begin
  Result := AddItem(Index) as IXMLButtonType;
end;


{ TXMLUserinterfaceType }

procedure TXMLUserinterfaceType.AfterConstruction;
begin
  RegisterChildNode('uiimages', TXMLUiimagesType);
  RegisterChildNode('buttons', TXMLButtonsType);
  inherited;
end;

function TXMLUserinterfaceType.Get_Displayoffsetx: Integer;
begin
  Result := StrToIntDef(ChildNodes['displayoffsetx'].Text, 0);
end;

function TXMLUserinterfaceType.Get_Displayoffsety: Integer;
begin
  Result := StrToIntDef(ChildNodes['displayoffsety'].Text, 0);
end;

function TXMLUserinterfaceType.Get_Uiimages: IXMLUiimagesType;
begin
  Result := ChildNodes['uiimages'] as IXMLUiimagesType;
end;

function TXMLUserinterfaceType.Get_Buttons: IXMLButtonsType;
begin
  Result := ChildNodes['buttons'] as IXMLButtonsType;
end;

{ TXMLFontType }

function TXMLFontType.Get_Name: ANSIString;
begin
  Result := AttributeNodes['name'].Text;
end;

procedure TXMLFontType.Set_Name(Value: ANSIString);
begin
  SetAttribute('name', Value);
end;

function TXMLFontType.Get_Height: Integer;
begin
  Result := AttributeNodes['height'].NodeValue;
end;

procedure TXMLFontType.Set_Height(Value: Integer);
begin
  SetAttribute('height', Value);
end;

function TXMLFontType.Get_Width: Integer;
begin
  Result := AttributeNodes['width'].NodeValue;
end;

procedure TXMLFontType.Set_Width(Value: Integer);
begin
  SetAttribute('width', Value);
end;

function TXMLFontType.Get_Variablewidth: Boolean;
begin
  Result := AttributeNodes['variablewidth'].NodeValue;
end;

procedure TXMLFontType.Set_Variablewidth(Value: Boolean);
begin
  SetAttribute('variablewidth', Value);
end;

function TXMLFontType.Get_Bold: Boolean;
begin
  Result := AttributeNodes['bold'].NodeValue;
end;

procedure TXMLFontType.Set_Bold(Value: Boolean);
begin
  SetAttribute('bold', Value);
end;

function TXMLFontType.Get_Italics: Boolean;
begin
  Result := AttributeNodes['italics'].NodeValue;
end;

procedure TXMLFontType.Set_Italics(Value: Boolean);
begin
  SetAttribute('italics', Value);
end;

function TXMLFontType.Get_Underline: Boolean;
begin
  Result := AttributeNodes['underline'].NodeValue;
end;

procedure TXMLFontType.Set_Underline(Value: Boolean);
begin
  SetAttribute('underline', Value);
end;


{ TXMLSizeType }

function TXMLSizeType.Get_X: Integer;
begin
  Result := AttributeNodes['x'].NodeValue;
end;

procedure TXMLSizeType.Set_X(Value: Integer);
begin
  SetAttribute('x', Value);
end;

function TXMLSizeType.Get_Y: Integer;
begin
  Result := AttributeNodes['y'].NodeValue;
end;

procedure TXMLSizeType.Set_Y(Value: Integer);
begin
  SetAttribute('y', Value);
end;

{ TXMLCharacterType }

function TXMLCharacterType.Get_Value: ANSIString;
begin
  Result := AttributeNodes['value'].Text;
end;

procedure TXMLCharacterType.Set_Value(Value: ANSIString);
begin
  SetAttribute('value', Value);
end;

function TXMLCharacterType.Get_Comment: ANSIString;
begin
  Result := AttributeNodes['comment'].Text;
end;

procedure TXMLCharacterType.Set_Comment(Value: ANSIString);
begin
  SetAttribute('comment', Value);
end;

function TXMLCharacterType.Get_Height: Integer;
begin
  Result := AttributeNodes['height'].NodeValue;
end;

procedure TXMLCharacterType.Set_Height(Value: Integer);
begin
  SetAttribute('height', Value);
end;

function TXMLCharacterType.Get_Width: Integer;
begin
  Result := AttributeNodes['width'].NodeValue;
end;

procedure TXMLCharacterType.Set_Width(Value: Integer);
begin
  SetAttribute('width', Value);
end;

{ TXMLCharactersetType }

procedure TXMLCharactersetType.AfterConstruction;
begin
  RegisterChildNode('character', TXMLCharacterType);
  ItemTag := 'character';
  ItemInterface := IXMLCharacterType;
  inherited;
end;

function TXMLCharactersetType.Get_Height: Integer;
begin
  Result := AttributeNodes['height'].NodeValue;
end;

procedure TXMLCharactersetType.Set_Height(Value: Integer);
begin
  SetAttribute('height', Value);
end;

function TXMLCharactersetType.Get_Width: Integer;
begin
  Result := AttributeNodes['width'].NodeValue;
end;

procedure TXMLCharactersetType.Set_Width(Value: Integer);
begin
  SetAttribute('width', Value);
end;

function TXMLCharactersetType.Get_Variablewidth: Boolean;
begin
  Result := AttributeNodes['variablewidth'].NodeValue;
end;

procedure TXMLCharactersetType.Set_Variablewidth(Value: Boolean);
begin
  SetAttribute('variablewidth', Value);
end;

function TXMLCharactersetType.Get_Character(Index: Integer): IXMLCharacterType;
begin
  Result := List[Index] as IXMLCharacterType;
end;

function TXMLCharactersetType.Add: IXMLCharacterType;
begin
  Result := AddItem(-1) as IXMLCharacterType;
end;

function TXMLCharactersetType.Insert(const Index: Integer): IXMLCharacterType;
begin
  Result := AddItem(Index) as IXMLCharacterType;
end;


{ TXMLFgcolorType }

function TXMLFgcolorType.Get_Red: Integer;
begin
  Result := AttributeNodes['red'].NodeValue;
end;

procedure TXMLFgcolorType.Set_Red(Value: Integer);
begin
  SetAttribute('red', Value);
end;

function TXMLFgcolorType.Get_Green: Integer;
begin
  Result := AttributeNodes['green'].NodeValue;
end;

procedure TXMLFgcolorType.Set_Green(Value: Integer);
begin
  SetAttribute('green', Value);
end;

function TXMLFgcolorType.Get_Blue: Integer;
begin
  Result := AttributeNodes['blue'].NodeValue;
end;

procedure TXMLFgcolorType.Set_Blue(Value: Integer);
begin
  SetAttribute('blue', Value);
end;

{ TXMLBgcolorType }

function TXMLBgcolorType.Get_Red: Integer;
begin
  Result := AttributeNodes['red'].NodeValue;
end;

procedure TXMLBgcolorType.Set_Red(Value: Integer);
begin
  SetAttribute('red', Value);
end;

function TXMLBgcolorType.Get_Green: Integer;
begin
  Result := AttributeNodes['green'].NodeValue;
end;

procedure TXMLBgcolorType.Set_Green(Value: Integer);
begin
  SetAttribute('green', Value);
end;

function TXMLBgcolorType.Get_Blue: Integer;
begin
  Result := AttributeNodes['blue'].NodeValue;
end;

procedure TXMLBgcolorType.Set_Blue(Value: Integer);
begin
  SetAttribute('blue', Value);
end;

{ TXMLBrowserareaType }

function TXMLBrowserareaType.Get_X: Integer;
begin
  Result := StrToIntDef(ChildNodes['x'].Text, 0);
end;

function TXMLBrowserareaType.Get_Y: Integer;
begin
  Result := StrToIntDef(ChildNodes['y'].Text, 0);
end;

function TXMLBrowserareaType.Get_Xoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['xoffset'].Text, 0);
end;

function TXMLBrowserareaType.Get_Yoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['yoffset'].Text, 0);
end;

function TXMLBrowserareaType.Get_Fgcolor: Integer;
begin
  Result := StrToIntDef(ChildNodes['fgcolor'].Text, 0);
end;

function TXMLBrowserareaType.Get_Bgcolor: Integer;
begin
  Result := StrToIntDef(ChildNodes['bgcolor'].Text, 0);
end;

{ TXMLStatusbarareaType }

function TXMLStatusbarareaType.Get_X: Integer;
begin
  Result := StrToIntDef(ChildNodes['x'].Text, 0);
end;

function TXMLStatusbarareaType.Get_Y: Integer;
begin
  Result := StrToIntDef(ChildNodes['y'].Text, 0);
end;

function TXMLStatusbarareaType.Get_Xoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['xoffset'].Text, 0);
end;

function TXMLStatusbarareaType.Get_Yoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['yoffset'].Text, 0);
end;

function TXMLStatusbarareaType.Get_Fgcolor: Integer;
begin
  Result := StrToIntDef(ChildNodes['fgcolor'].Text, 0);
end;

function TXMLStatusbarareaType.Get_Bgcolor: Integer;
begin
  Result := StrToIntDef(ChildNodes['bgcolor'].Text, 0);
end;

{ TXMLSoftbutton1Type }

function TXMLSoftbutton1Type.Get_X: Integer;
begin
  Result := StrToIntDef(ChildNodes['x'].Text, 0);
end;

function TXMLSoftbutton1Type.Get_Y: Integer;
begin
  Result := StrToIntDef(ChildNodes['y'].Text, 0);
end;

function TXMLSoftbutton1Type.Get_Xoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['xoffset'].Text, 0);
end;

function TXMLSoftbutton1Type.Get_Yoffset: Integer;
begin
  Result := StrToIntDef(ChildNodes['yoffset'].Text, 0);
end;

function TXMLSoftbutton1Type.Get_Align: TAlign;
begin
  Result := TAlign(Integer(ChildNodes['align'].NodeValue));
end;

{ TXMLSoftbutton2Type }

function TXMLSoftbutton2Type.Get_X: Integer;
begin
  Result := ChildNodes['x'].NodeValue;
end;

function TXMLSoftbutton2Type.Get_Y: Integer;
begin
  Result := ChildNodes['y'].NodeValue;
end;

function TXMLSoftbutton2Type.Get_Xoffset: Integer;
begin
  Result := ChildNodes['xoffset'].NodeValue;
end;

function TXMLSoftbutton2Type.Get_Yoffset: Integer;
begin
  Result := ChildNodes['yoffset'].NodeValue;
end;

function TXMLSoftbutton2Type.Get_Align: TAlign;
begin
  Result := TAlign(Integer(ChildNodes['align'].NodeValue));
end;

{ TXMLSoftbuttonsType }

procedure TXMLSoftbuttonsType.AfterConstruction;
begin
  RegisterChildNode('fgcolor', TXMLFgcolorType);
  RegisterChildNode('bgcolor', TXMLBgcolorType);
  RegisterChildNode('font', TXMLFontType);
  RegisterChildNode('softbutton1', TXMLSoftbutton1Type);
  RegisterChildNode('softbutton2', TXMLSoftbutton2Type);
  inherited;
end;

function TXMLSoftbuttonsType.Get_Fgcolor: IXMLFgcolorType;
begin
  Result := ChildNodes['fgcolor'] as IXMLFgcolorType;
end;

function TXMLSoftbuttonsType.Get_Bgcolor: IXMLBgcolorType;
begin
  Result := ChildNodes['bgcolor'] as IXMLBgcolorType;
end;

function TXMLSoftbuttonsType.Get_Font: IXMLFontType;
begin
  Result := ChildNodes['font'] as IXMLFontType;
end;

function TXMLSoftbuttonsType.Get_Drawstyle: Integer;
begin
  Result := ChildNodes['drawstyle'].NodeValue;
end;

function TXMLSoftbuttonsType.Get_Presentationstyle: Integer;
begin
  Result := ChildNodes['presentationstyle'].NodeValue;
end;

function TXMLSoftbuttonsType.Get_Softbutton1: IXMLSoftbutton1Type;
begin
  Result := ChildNodes['softbutton1'] as IXMLSoftbutton1Type;
end;

function TXMLSoftbuttonsType.Get_Softbutton2: IXMLSoftbutton2Type;
begin
  Result := ChildNodes['softbutton2'] as IXMLSoftbutton2Type;
end;

{ TXMLScrollbarimagesType }

function TXMLScrollbarimagesType.Get_Imagetop: String;
begin
  Result := ChildNodes['imagetop'].NodeValue;
end;

function TXMLScrollbarimagesType.Get_Imagebottom: String;
begin
  Result := ChildNodes['imagebottom'].NodeValue;
end;

function TXMLScrollbarimagesType.Get_Imagemiddle: String;
begin
  Result := ChildNodes['imagemiddle'].NodeValue;
end;

function TXMLScrollbarimagesType.Get_Imagenoscroll: String;
begin
  Result := ChildNodes['imagenoscroll'].NodeValue;
end;

{ TXMLScrollbarareaType }

procedure TXMLScrollbarareaType.AfterConstruction;
begin
  RegisterChildNode('font', TXMLFontType);
  RegisterChildNode('scrollbarimages', TXMLScrollbarimagesType);
  inherited;
end;

function TXMLScrollbarareaType.Get_X: Integer;
begin
  Result := ChildNodes['x'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Y: Integer;
begin
  Result := ChildNodes['y'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Xoffset: Integer;
begin
  Result := ChildNodes['xoffset'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Yoffset: Integer;
begin
  Result := ChildNodes['yoffset'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Fgcolor: Integer;
begin
  Result := ChildNodes['fgcolor'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Bgcolor: Integer;
begin
  Result := ChildNodes['bgcolor'].NodeValue;
end;

function TXMLScrollbarareaType.Get_Font: IXMLFontType;
begin
  Result := ChildNodes['font'] as IXMLFontType;
end;

function TXMLScrollbarareaType.Get_Scrollbarimages: IXMLScrollbarimagesType;
begin
  Result := ChildNodes['scrollbarimages'] as IXMLScrollbarimagesType;
end;

{ TXMLTitlebarareaType }

procedure TXMLTitlebarareaType.AfterConstruction;
begin
  RegisterChildNode('font', TXMLFontType);
  inherited;
end;

function TXMLTitlebarareaType.Get_X: Integer;
begin
  Result := ChildNodes['x'].NodeValue;;
end;

function TXMLTitlebarareaType.Get_Y: Integer;
begin
  Result := ChildNodes['y'].NodeValue;
end;

function TXMLTitlebarareaType.Get_Xoffset: Integer;
begin
  Result := ChildNodes['xoffset'].NodeValue;
end;

function TXMLTitlebarareaType.Get_Yoffset: Integer;
begin
  Result := ChildNodes['yoffset'].NodeValue;
end;

function TXMLTitlebarareaType.Get_Fgcolor: Integer;
begin
  Result := ChildNodes['fgcolor'].NodeValue;
end;

function TXMLTitlebarareaType.Get_Bgcolor: Integer;
begin
  Result := ChildNodes['bgcolor'].NodeValue;
end;

function TXMLTitlebarareaType.Get_Font: IXMLFontType;
begin
  Result := ChildNodes['font'] as IXMLFontType;
end;

{ TXMLDisplayType }

procedure TXMLDisplayType.AfterConstruction;
begin
  RegisterChildNode('browserarea', TXMLBrowserareaType);
  RegisterChildNode('statusbararea', TXMLStatusbarareaType);
  RegisterChildNode('softbuttons', TXMLSoftbuttonsType);
  RegisterChildNode('scrollbararea', TXMLScrollbarareaType);
  RegisterChildNode('titlebararea', TXMLTitlebarareaType);
  inherited;
end;

function TXMLDisplayType.Get_X: Integer;
begin
  Result := ChildNodes['x'].NodeValue;
end;

function TXMLDisplayType.Get_Y: Integer;
begin
  Result := ChildNodes['y'].NodeValue;
end;

function TXMLDisplayType.Get_Devicex: Integer;
begin
  Result := ChildNodes['devicex'].NodeValue;
end;

function TXMLDisplayType.Get_Devicey: Integer;
begin
  Result := ChildNodes['devicey'].NodeValue;
end;

function TXMLDisplayType.Get_Fgcolor: Integer;
begin
  Result := ChildNodes['fgcolor'].NodeValue;
end;

function TXMLDisplayType.Get_Bgcolor: Integer;
begin
  Result := ChildNodes['bgcolor'].NodeValue;
end;

function TXMLDisplayType.Get_Browserarea: IXMLBrowserareaType;
begin
  Result := ChildNodes['browserarea'] as IXMLBrowserareaType;
end;

function TXMLDisplayType.Get_Statusbararea: IXMLStatusbarareaType;
begin
  Result := ChildNodes['statusbararea'] as IXMLStatusbarareaType;
end;

function TXMLDisplayType.Get_Softbuttons: IXMLSoftbuttonsType;
begin
  Result := ChildNodes['softbuttons'] as IXMLSoftbuttonsType;
end;

function TXMLDisplayType.Get_Scrollbararea: IXMLScrollbarareaType;
begin
  Result := ChildNodes['scrollbararea'] as IXMLScrollbarareaType;
end;

function TXMLDisplayType.Get_Titlebararea: IXMLTitlebarareaType;
begin
  Result := ChildNodes['titlebararea'] as IXMLTitlebarareaType;
end;

{ TXMLParserType }

procedure TXMLParserType.AfterConstruction;
begin
  RegisterChildNode('characterset', TXMLCharactersetType);
  RegisterChildNode('font', TXMLFontType);
  inherited;
end;

function TXMLParserType.Get_Xdevicebrowser: Integer;
begin
  Result := ChildNodes['xdevicebrowser'].NodeValue;
end;

function TXMLParserType.Get_Characterset: IXMLCharactersetType;
begin
  Result := ChildNodes['characterset'] as IXMLCharactersetType;
end;

function TXMLParserType.Get_Font: IXMLFontType;
begin
  Result := ChildNodes['font'] as IXMLFontType;
end;

function TXMLParserType.Get_Cxprefix: Integer;
begin
  Result := ChildNodes['cxprefix'].NodeValue;
end;

function TXMLParserType.Get_Cyprefix: Integer;
begin
  Result := ChildNodes['cyprefix'].NodeValue;
end;

function TXMLParserType.Get_Supportbold: Boolean;
begin
  Result := ChildNodes['supportbold'].NodeValue;
end;

function TXMLParserType.Get_Supportitalics: Boolean;
begin
  Result := ChildNodes['supportitalics'].NodeValue;
end;

function TXMLParserType.Get_Supportunderline: Boolean;
begin
  Result := ChildNodes['supportunderline'].NodeValue;
end;

function TXMLParserType.Get_Supportstrong: Boolean;
begin
  Result := ChildNodes['supportstrong'].NodeValue;
end;

function TXMLParserType.Get_Supportemphasis: Boolean;
begin
  Result := ChildNodes['supportemphasis'].NodeValue;
end;

function TXMLParserType.Get_Supportbig: Boolean;
begin
  Result := ChildNodes['supportbig'].NodeValue;
end;

function TXMLParserType.Get_Supportsmall: Boolean;
begin
  Result := ChildNodes['supportsmall'].NodeValue;
end;

function TXMLParserType.Get_Supportimages: Boolean;
begin
  Result := ChildNodes['supportimages'].NodeValue;
end;

function TXMLParserType.Get_Supportlocalsrcimages: Boolean;
begin
  Result := ChildNodes['supportlocalsrcimages'].NodeValue;
end;

function TXMLParserType.Get_Supportaccesskeys: Boolean;
begin
  Result := ChildNodes['supportaccesskeys'].NodeValue;
end;

function TXMLParserType.Get_Anchordelimleft: Char;
var
  s: String;
begin
  s:= ChildNodes['anchordelimleft'].NodeValue;
  if Length(s) > 0
  then Result := s[1]
  else Result:= #0;
end;

function TXMLParserType.Get_Anchordelimright: Char;
var
  s: String;
begin
  s:= ChildNodes['anchordelimright'].NodeValue;
  if Length(s) > 0
  then Result := s[1]
  else Result:= #0;
end;

function TXMLParserType.Get_Highlightmode: Integer;
begin
  Result := ChildNodes['highlightmode'].NodeValue;
end;

function TXMLParserType.Get_Imgselect: String;
begin
  Result := ChildNodes['imgselect'].NodeValue;
end;

function TXMLParserType.Get_Imgselectblank: String;
begin
  Result := ChildNodes['imgselectblank'].NodeValue;
end;

function TXMLParserType.Get_Imgscroll: String;
begin
  Result := ChildNodes['imgscroll'].NodeValue;
end;

function TXMLParserType.Get_Imgscrollblank: String;
begin
  Result := ChildNodes['imgscrollblank'].NodeValue;
end;

{ TXMLAccepttypesType }

procedure TXMLAccepttypesType.AfterConstruction;
begin
  ItemTag := 'accepttype';
  inherited;
end;

function TXMLAccepttypesType.Get_Accepttype(Index: Integer): String;
begin
  Result := List[Index].NodeValue;
end;

function TXMLAccepttypesType.Add: String;
begin
  Result := AddItem(-1).NodeValue;
end;

function TXMLAccepttypesType.Insert(const Index: Integer): String;
begin
  Result := AddItem(Index).NodeValue;
end;


{ TXMLDeviceType }

procedure TXMLDeviceType.AfterConstruction;
begin
  RegisterChildNode('userinterface', TXMLUserinterfaceType);
  RegisterChildNode('display', TXMLDisplayType);
  RegisterChildNode('parser', TXMLParserType);
  RegisterChildNode('accepttypes', TXMLAccepttypesType);
  inherited;
end;

function TXMLDeviceType.Get_Name: ANSIString;
begin
  Result := ChildNodes['name'].NodeValue;
end;

function TXMLDeviceType.Get_Progid: ANSIString;
begin
  Result := ChildNodes['progid'].NodeValue;
end;

function TXMLDeviceType.Get_Platformid: ANSIString;
begin
  Result := ChildNodes['platformid'].NodeValue;
end;

function TXMLDeviceType.Get_Userinterface: IXMLUserinterfaceType;
begin
  Result := ChildNodes['userinterface'] as IXMLUserinterfaceType;
end;

function TXMLDeviceType.Get_Display: IXMLDisplayType;
begin
  Result := ChildNodes['display'] as IXMLDisplayType;
end;

function TXMLDeviceType.Get_Parser: IXMLParserType;
begin
  Result := ChildNodes['parser'] as IXMLParserType;
end;

function TXMLDeviceType.Get_Accepttypes: IXMLAccepttypesType;
begin
  Result := ChildNodes['accepttypes'] as IXMLAccepttypesType;
end;

function TXMLDeviceType.Get_Requestheaders: String;
begin
  Result := ChildNodes['requestheaders'].NodeValue;
end;

function GetDevice(Doc: IXMLDocument): IXMLDeviceType;
begin
   Result := Doc.GetDocBinding('device', TXMLDeviceType) as IXMLDeviceType;
end;

function LoadDevice(const FileName: ANSIString): IXMLDeviceType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('device', TXMLDeviceType) as IXMLDeviceType;
end;

function NewDevice: IXMLDeviceType;
begin
  Result := NewXMLDocument.GetDocBinding('device', TXMLDeviceType) as IXMLDeviceType;
end;

end.
