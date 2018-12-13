unit
  smit;
(*##*)
(*******************************************************************************
*                                                                             *
*   s  m  i  t                                                                 *
*                                                                             *
*   Copyright © 2003 Andrei Ivanov. All rights reserved.                       *
*   smit menu xml                                                             *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : Nov 04 2003                                                 *
*   Last fix     : Nov 04 2003                                                *
*   Lines        :                                                             *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)

interface
uses
  Classes, Windows, SysUtils, Controls, StrUtils,
  jclUnicode, customxml;

var
  DEF_PKG_TEXTWRAP: Boolean = True;

type
  TSmtDocDesc = class(TDocDesc)
  public
    constructor Create(ACollection: TCollection); override;
    function CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString; override;
  end;

  TSmtServerSide = class(TServerSide)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtBracket = class(TBracket)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtPCData = class(TxmlPCData)
  public
    // return default values
    function TextAlignment: TAlignment; override;
    function TextWrap: Boolean; override;
    function TextEmphasisis: TEmphasisis; override;
  end;

  TSmt_Base = class(TxmlElement)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmt_Command = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  // --------- SMIT elements implementation ---------

  TSmtContainer = class(TxmlContainer)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtMenu = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtSelector = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtDialog = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtCmd = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

  TSmtcmd_to_classify = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_classify_postfix = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_exec = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_discover = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_discover_postfix = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_list_mode = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_list = class(TSmt_Command)
  public
  end;

  TSmtcmd_to_list_postfix = class(TSmt_Command)
  public
  end;

  TSmtHelp = class(TSmt_Base)
  public
    constructor Create(ACollection: TCollection); override;
  end;

// register xml schema used by xmlsupported

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;

implementation

uses
  util1,
  xmlParse; // for GetDocumentTitle() implementation - document is parsed

  const
  SmitElements: array[0..20] of TxmlElementClass = (
    TSmtContainer, TsmtBracket,
    TSmtMenu,
    TSmtSelector,
    TSmtDialog,
    TSmtCmd,
    TSmtcmd_to_classify,
    TSmtcmd_to_classify_postfix,
    TSmtcmd_to_exec,
    TSmtcmd_to_discover,
    TSmtcmd_to_discover_postfix,
    TSmtcmd_to_list_mode,
    TSmtcmd_to_list,
    TSmtcmd_to_list_postfix,
    TSmtHelp,
    TSmtPCDATA,
    TxmlComment,
    TXMLDesc,
    TSmtDocDesc,
    TSmtServerSide,
    TxmlssScript
);


// --------- TSmt_Base ---------

constructor TSmt_Base.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TxmlComment, wciAny);
  FNestedElements.AddNew(TxmlSSScript, wciAny);
  // string that appears on the dialog or selector screen as the field name.
  // prompting part of the object, a natural language description of a flag, option or parameter of command string[1024]
  FNestedElements.AddNew(TSmtPCData, wciAny);

  // ID or name of the object. The id field can be externalized as a fast path ID unless has_name_select is set to "y" (yes). string[64]
  FAttributes.AddAttribute('id', atID, IMPLIED, NODEFAULT, NOLIST);

  // Help Message Facility
  // Specifies a message set number and message ID number with a comma as the separator or a numeric string equal to a SMIT identifier tag.
  FAttributes.AddAttribute('help_msg_id', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // file name sent as a parameter to the man command for retrieval of help text, or the file name containing help text. string[1024]
  FAttributes.AddAttribute('help_msg_loc', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // fully qualified path name of a library that SMIT reads for the file names associated with the correct book.
  FAttributes.AddAttribute('help_msg_base', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // Contains the string with the value of the name file contained in the file library indicated by help_msg_base
  FAttributes.AddAttribute('help_msg_book', atVDATA, IMPLIED, NODEFAULT, NOLIST);

  // server extension
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    FAttributes.AddAttribute('loop', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('id', atVData, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('first', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('last', atNumber, IMPLIED, NODEFAULT, NOLIST);
    FAttributes.AddAttribute('move', atNumber, IMPLIED, NODEFAULT, NOLIST);

    FNestedElements.AddNew(TsmtBracket, wciAny);
  end;
  FAbstract:= True;
end;

// --------- TSmt_Command ---------

constructor TSmt_Command.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // FNestedElements.AddNew(TSmtPCDATA, wciAny);
end;

// --------- TSmtContainer ---------

constructor TSmtContainer.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TSmtMenu, wciOne);
  FNestedElements.AddNew(TSmtDocDesc, wciOneOrNone);

  if wcServerExtensions in xmlENV.xmlCapabilities
  then FNestedElements.AddNew(TSmtServerSide, wciAny);
end;

// --------- TSmtDocDesc ---------

constructor TSmtDocDesc.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FAbstract:= False;
  // attribute collection
  FAttributes.AddAttribute('version', atCData, REQUIRED, '1.0', '0.1|1.0');
end;

function TSmtDocDesc.CreateText(ALevel: Integer; AOptions: TFormatTextSet): WideString;
var
  t: String;
  i: Integer;
  s: String;
begin
  // left align
  t:= ValidateLevel(ALevel);
  s:= FAttributes.ValueByName['version'];
  i:= 1;
  while i <= Length(s) do begin
    if s[i] = '.'
    then Delete(s, i, 1)
    else Inc(i);
  end;
  Result:= t + Format('<!DOCTYPE taxon PUBLIC "-//taxon//DTD taxon %s//EN" "http://ensen.sitc.ru/dtds/taxon-%s/taxon%s.dtd">',
    [FAttributes.ValueByName['version'], FAttributes.ValueByName['version'], s]);
end;

// --------- TSmtServerSide ---------

constructor TSmtServerSide.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FNestedElements.AddNew(TSmtPCData, wciAny);
end;

// --------- TSmtPCData ---------

// return what aligmnment assigned in parent paragraph
function TSmtPCData.TextAlignment: TAlignment;
begin
  Result:= DEFAULT_TEXTALIGNMENT;
end;

// return what warpping mode set in parent paragraph
function TSmtPCData.TextWrap: Boolean;
begin
  Result:= DEF_PKG_TEXTWRAP;
end;

// return context of TWMLEm TWMLStrong TWMLB TWMLI TWMLU TWMLBig TWMLSmall elements
function TSmtPCData.TextEmphasisis: TEmphasisis;
begin
  Result:= [];
end;

// --------- TSmtMenu ---------
{
<!ELEMENT menu	(menu*, selector*)>
<!ATTLIST menu
  id            ID or name of the object. string[64] IDs should be unique both to your application and unique within the particular SMIT database used. See the next_id and alias definitions for this object for related information.
  id_seq_num    position of this item in relation to other items on the menu. Non-title sm_menu_opt objects are sorted on this string field. string[16]
  next_id       fast path name of the next menu, if the value for the next_type descriptor of this object is "m" (menu). The next_id of a menu should be unique both to your application and within the particular SMIT database used. All non-alias sm_menu_opt objects with id values matching the value of next_id form the set of selections for that menu. string[64]
  text          description of the task that is displayed as the menu item. The value of text string[1024] This string can be formatted with embedded \n (newline)]
  text_msg_file file name (not the full path name) that is the Message Facility catalog for the string, text. string[1024] Message catalogs required by an application program can be developed with the Message Facility. Set to "" if you are not using the Message Facility.
  text_msg_set  Message Facility set ID for the string, text. Set IDs can be used to indicate subsets of a single catalog. integer. Set to 0 if you are not using the Message Facility.
  text_msg_id   Message Facility ID for the string, text. integer. Set to 0 if you are not using the Message Facility.
  next_type     type of the next object if this item is selected. Valid values are:
    "m"  next object is a menu
    "d"  next object is a dialog
    "n"  next object is a selector
    "i"  Info; this object is used to put blank or other separator lines in a menu, or to present a topic that does not lead to an executable task but about which help is provided via the help_msg_loc descriptor of this object.
  alias         Defines whether or not the value of the id descriptor for this menu object is an alias for another existing fast path specified in the next_id field of this object. The value of the alias descriptor must be "n" for a menu object.
  help_msg_id   Specifies a Message Facility message set number and message ID number with a comma as the separator or a numeric string equal to a SMIT identifier tag.
  help_msg_loc  file name sent as a parameter to the man command for retrieval of help text, or the file name of a file containing help text. string[1024]
  help_msg_base fully qualified path name of a library that SMIT reads for the file names associated with the correct book.
  help_msg_book
>
}

constructor TSmtMenu.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  //
  FNestedElements.AddNew(TSmtMenu, wciAny);
  FNestedElements.AddNew(TSmtSelector, wciAny);
  FNestedElements.AddNew(TSmtDialog, wciAny);

  // attribute collection
  // position of this item in relation to other items on the menu. string[16]
  FAttributes.AddAttribute('id_seq_num', atID, IMPLIED, NODEFAULT, NOLIST);
  // fast path name of the next menu, if the value for the next_type descriptor of this object is "m" (menu). The next_id of a menu should be unique both to your application and within the particular SMIT database used. All non-alias sm_menu_opt objects with id values matching the value of next_id form the set of selections for that menu. string[64]
  FAttributes.AddAttribute('next_id', atID, IMPLIED, NODEFAULT, NOLIST);
  // Message Facility
  // Message catalogs required by an application program can be developed with the Message Facility.
  //   file name (not the full path name) catalog for text. string[1024]. Set to "" if you are not using the Message Facility.
  FAttributes.AddAttribute('text_msg_file', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // set ID for the string, text. Set IDs can be used to indicate subsets of a single catalog. Set to 0 if you are not using the Message Facility.
  FAttributes.AddAttribute('text_msg_set', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // ID for the string, text. Set to 0 if you are not using the Message Facility.
  FAttributes.AddAttribute('text_msg_id', atNumber, IMPLIED, NODEFAULT, NOLIST);

  // type of the next object if this item is selected.
  // m|d|n|i
  FAttributes.AddAttribute('next_type', atLIST, IMPLIED, NODEFAULT, 'menu|dialog|nameselector|info');
  // Defines whether or not the value of the id descriptor for this menu object is an alias for another existing fast path specified in the next_id field of this object. The value of the alias descriptor must be "n" for a menu object.
  FAttributes.AddAttribute('alias', atNOSTRICTLIST, IMPLIED, 'n', 'n|y');

  FAbstract:= False;
end;

// --------- TSmtSelector ---------
{
  id              ID or name of the object. The id field can be externalized as a fast path ID unless has_name_select is set to "y" (yes). string[64]
  next_id         header object for the subsequent screen; set to the value of the id field of the sm_cmd_hdr object or the sm_name_hdr object that follows this selector. The next_type field described below specifies which object class is indicated. string[64]
  option_id       body of this selector; set to the id field of the sm_cmd_opt object. string[64]
  has_name_select whether this screen must be preceded by a selector screen. Valid values are:
    "" or "n"     No; this is the default case. The id of this object can be used as a fast path, even if preceded by a selector screen.
    "y"           Yes; a selector must precede this object. This setting prevents the id of this object from being used as a fast path to the corresponding dialog screen.
  name            text displayed as the title of the selector screen. string[1024] The string can be formatted with embedded \n (newline)
  name_msg_file   file name (not the full path name) that is the Message Facility catalog for the string, name. string[1024] Message catalogs required by an application program can be developed with the Message Facility.
  name_msg_set    Message Facility set ID for the string, name. Set IDs can be used to indicate subsets of a single catalog. The value of name_msg_set is an integer.
  name_msg_id     ID for the string, name. The value of name_msg_id is an integer.
  type            method to be used to process the selector. string[1] character. Valid values are:
    "" or "j"     Just next ID; the object following this object is always the object specified by the value of the next_id descriptor. The next_id descriptor is a fully-defined string initialized at development time.
    "r"           Cat raw name; in this case, the next_id descriptor is defined partially at development time and partially at runtime by user input. The value of the next_id descriptor defined at development time is concatenated with the value selected by the user to create the id value to search for next (that of the dialog or selector to display).
    "c"           Cat cooked name; the value selected by the user requires processing for more information. This value is passed to the command named in the cmd_to_classify descriptor, and then output from the command is concatenated with the value of the next_id descriptor to create the id descriptor to search for next (that of the dialog or selector to display).
  ghost           Specifies whether to display this selector screen or only the list pop-up panel produced by the command in the cmd_to_list field. The value of ghost is a string. Valid values are:
    "" or "n"     No; display this selector screen.
    "y"           Yes; display only the pop-up panel produced by the command string constructed using the cmd_to_list and cmd_to_list_postfix fields in the associated sm_cmd_opt object. If there is no cmd_to_list value, SMIT assumes this object is a super-ghost (nothing is displayed), runs the cmd_to_classify command, and proceeds.
  cmd_to_classify command string to be used, if needed, to classify the value of the name field of the sm_cmd_opt object associated with this selector. string[1024] The input to the cmd_to_classify taken from the entry field is called the "raw name" and the output of the cmd_to_classify is called the "cooked name". Previous to AIX Version 4.2.1, you could create only one value with cmd_to_classify. If that value included a colon, it was escaped automatically. In AIX 4.2.1 and later, you can create multiple values with cmd_to_classify, but the colons are no longer escaped. The colon is now being used as a delimiter by this command. If you use colons in your values, you must preserve them manually.
  cmd_to_classify_postfix postfix to interpret and add to the command string in the cmd_to_classify field. string[1024]
  raw_field_name  alternate name for the raw value. string[1024] default "_rawname".
  cooked_field_name  alternate name for the cooked value. string[1024] default "cookedname".
  next_type       type of screen that follows this selector. Valid values are:
    "n"           Name; a selector screen follows. See the description of next_id above for related information.
    "d"           Dialog; a dialog screen follows. See the description of next_id above for related information.
  help_msg_id     Specifies a Message Facility message set number and message ID number with a comma as the separator or a numeric string equal to a SMIT identifier tag.
  help_msg_loc    file name sent as a parameter to the man command for retrieval of help text, or the file name of a file containing help text. string[1024]
  help_msg_base   fully qualified path name of a library that SMIT reads for the file names associated with the correct book.
  help_msg_book   Contains the string with the value of the name file contained in the file library indicated by help_msg_base.
}

constructor TSmtSelector.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // command string to be used, if needed, to classify the value of the name field of the sm_cmd_opt object associated with this selector. string[1024] The input to the cmd_to_classify taken from the entry field is called the "raw name" and the output of the cmd_to_classify is called the "cooked name". Previous to AIX Version 4.2.1, you could create only one value with cmd_to_classify. If that value included a colon, it was escaped automatically. In AIX 4.2.1 and later, you can create multiple values with cmd_to_classify, but the colons are no longer escaped. The colon is now being used as a delimiter by this command. If you use colons in your values, you must preserve them manually.
  FNestedElements.AddNew(TSmtcmd_to_classify, wciOneOrNone);
  // postfix to interpret and add to the command string in the cmd_to_classify field. string[1024]
  FNestedElements.AddNew(TSmtcmd_to_classify_postfix, wciOneOrNone);

  // attribute collection
  // header object for the subsequent screen; set to the value of the id field of the sm_cmd_hdr object or the sm_name_hdr object that follows this selector. The next_type field described below specifies which object class is indicated. string[64]
  FAttributes.AddAttribute('next_id', atID, IMPLIED, NODEFAULT, NOLIST);
  // body of this selector; set to the id field of the sm_cmd_opt object. string[64]
  FAttributes.AddAttribute('option_id', atID, IMPLIED, NODEFAULT, NOLIST);
  // whether this screen must be preceded by a selector screen.
  FAttributes.AddAttribute('has_name_select', atLIST, IMPLIED, 'n', 'n|y');
  // Message Facility
  // Message catalogs required by an application program can be developed with the Message Facility.
  //   file name (not the full path name) that is the Message Facility catalog for the string, name. string[1024] Message catalogs required by an application program can be developed with the Message Facility.
  FAttributes.AddAttribute('name_msg_file', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // Message Facility set ID for the string, name. Set IDs can be used to indicate subsets of a single catalog. The value of name_msg_set is an integer.
  FAttributes.AddAttribute('name_msg_set', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // ID for the string, name. The value of name_msg_id is an integer.
  FAttributes.AddAttribute('name_msg_id', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // method to be used to process the selector. string[1] character. Valid values are:
  FAttributes.AddAttribute('type', atNOSTRICTLIST, IMPLIED, 'justnextid', 'justnextid|rawnamecat|catcookedname');
  // Specifies whether to display this selector screen or only the list pop-up panel produced by the command in the cmd_to_list field. The value of ghost is a string. Valid values are:
  FAttributes.AddAttribute('ghost', atNOSTRICTLIST, IMPLIED, 'n', 'n|y');

  // alternate name for the raw value. string[1024] The default value is "_rawname".
  FAttributes.AddAttribute('raw_field_name', atNOSTRICTLIST, IMPLIED, '_rawname', '_rawname');
  // alternate name for the cooked value. string[1024] The default value is "cookedname".
  FAttributes.AddAttribute('cooked_field_name', atNOSTRICTLIST, IMPLIED, 'cookedname', 'cookedname');
  // type of screen that follows this selector. Valid values are:
  FAttributes.AddAttribute('ask', atNOSTRICTLIST, IMPLIED, 'n', 'n|y');
  // Defines the handling of standard input, standard output, and the stderr file during task execution. The value of exec_mode is a string. Valid values are:
  FAttributes.AddAttribute('next_type', atNOSTRICTLIST, IMPLIED, NODEFAULT, 'nameselector|dialog');
  FAbstract:= False;
end;

// --------- TSmtDialog ---------
{
  id              name of the object. string[64]. can be used as a fast path ID unless there is a selector associated with the dialog.
  option_id       The id of the sm_cmd_opt objects (the dialog fields) to which this header refers. string[64]
  has_name_select Specifies whether this screen must be preceded by a selector screen or a menu screen. Valid values are:
    "" or "n"  No; this is the default case.
    "y"        Yes; a selector precedes this object. This setting prevents the id of this object from being used as a fast path to the corresponding dialog screen.
  name            text displayed as the title of the dialog screen. string[1024] The text describes the task performed by the dialog. The string can be formatted with embedded \n (newline)]
  name_msg_file The file name (not the full path name) that is the Message Facility catalog for the string, name. string[1024] Message catalogs required by an application program can be developed with the Message Facility.
  name_msg_set The Message Facility set ID for the string, name. Set IDs can be used to indicate subsets of a single catalog. integer.
  name_msg_id The Message Facility ID for the string, name. Message IDs can be created by the message extractor tools owned by the Message Facility. integer.
  cmd_to_exec The initial part of the command string, which can be the command or the command and any fixed options that execute the task of the dialog. Other options are automatically appended through user interaction with the command option objects (sm_cmd_opt) associated with the dialog screen. string[1024]
  ask Defines whether or not the user is prompted to reconsider the choice to execute the task. Valid values are:
    "" or "n"  No; the user is not prompted for confirmation; the task is performed when the dialog is committed. This is the default setting for the ask descriptor.
    "y"        Yes; the user is prompted to confirm that the task be performed; the task is performed only after user confirmation.
    Prompting the user for execution confirmation is especially useful prior to performance of deletion tasks, where the deleted resource is either difficult or impossible to recover, or when there is no displayable dialog associated with the task (when the ghost field is set to "y").
  exec_mode Defines the handling of standard input, standard output, and the stderr file during task execution. The value of exec_mode is a string. Valid values are:
    "" or "p"  Pipe mode; the default setting for the exec_mode descriptor. The command executes with standard output and the stderr file redirected through pipes to SMIT. SMIT manages output from the command. The output is saved and is scrollable by the user after the task finishes running. While the task runs, output is scrolled as needed.
    "n"        No scroll pipe mode; works like the "p" mode, except that the output is not scrolled while the task runs. The first screen of output will be shown as it is generated and then remains there while the task runs. The output is saved and is scrollable by the user after the task finishes running.
    "i"        Inherit mode; the command executes with standard input, standard output, and the stderr file inherited by the child process in which the task runs. This mode gives input and output control to the executed command. This value is intended for commands that need to write to the /dev/tty file, perform cursor addressing, or use libcur or libcurses library operations.
    "e"        Exit/exec mode; causes SMIT to run (do an execl subroutine call on) the specified command string in the current process, which effectively terminates SMIT. This is intended for running commands that are incompatible with SMIT (which change display modes or font sizes, for instance). A warning is given that SMIT will exit before running the command.
    "E"        Same as "e", but no warning is given before exiting SMIT.
    "P" , "N" or "I" Backup modes; work like the corresponding "p", "n", and "i" modes, except that if the cmd_to_exec command is run and returns with an exit value of 0, SMIT backs up to the nearest preceding menu (if any), or to the nearest preceding selector (if any), or to the command line.
  ghost      Indicates if the normally displayed dialog should not be shown. The value of ghost is a string. Valid values are:
    "" or "n"  No; the dialog associated with the task is displayed. This is the default setting.
    "y"        Yes; the dialog associated with the task is not displayed because no further information is required from the user. The command specified in the cmd_to_exec descriptor is executed as soon as the user selects the task.
  cmd_to_discover The command string used to discover the default or current values of the object being manipulated. The value of cmd_to_discover string[1024] The command is executed before the dialog is displayed, and its output is retrieved. Output of the command must be in colon format.
  cmd_to_discover_postfix The postfix to interpret and add to the command string in the cmd_to_discover field. The value of cmd_to_discover_postfix string[1024]
  help_msg_id Specifies a Message Facility message set number and message ID number with a comma as the separator or a numeric string equal to a SMIT identifier tag.
  help_msg_loc The file name sent as a parameter to the man command for retrieval of help text, or the file name of a file containing help text. string[1024]
  help_msg_base The fully qualified path name of a library that SMIT reads for the file names associated with the correct book.
  help_msg_book Contains the string with the value of the name file contained in the file library indicated by help_msg_base.
}
constructor TSmtDialog.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // The initial part of the command string, which can be the command or the command and any fixed options that execute the task of the dialog. Other options are automatically appended through user interaction with the command option objects (sm_cmd_opt) associated with the dialog screen. string[1024]
  FNestedElements.AddNew(TSmtcmd_to_exec, wciOneOrNone);
  // The command string used to discover the default or current values of the object being manipulated. string[1024] The command is executed before the dialog is displayed, and its output is retrieved. Output of the command must be in colon format.
  FNestedElements.AddNew(TSmtcmd_to_discover, wciOneOrNone);
  // The postfix to interpret and add to the command string in the cmd_to_discover field. string[1024]
  FNestedElements.AddNew(TSmtcmd_to_discover_postfix, wciOneOrNone);
  
  // attribute collection
  // The id of the sm_cmd_opt objects (the dialog fields) to which this header refers. string[64]
  FAttributes.AddAttribute('option_id', atID, IMPLIED, NODEFAULT, NOLIST);
  // Specifies whether this screen must be preceded by a selector screen or a menu screen. Valid values are:
  FAttributes.AddAttribute('has_name_select', atLIST, IMPLIED, 'n', 'n|y');
  // Message Facility
  // Message catalogs required by an application program can be developed with the Message Facility.
  //   file name (not the full path name) that is the Message Facility catalog for the string, name. string[1024] Message catalogs required by an application program can be developed with the Message Facility.
  FAttributes.AddAttribute('name_msg_file', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // set ID for the string, name. Set IDs can be used to indicate subsets of a single catalog. integer.
  FAttributes.AddAttribute('name_msg_set', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // ID for the string, name. Message IDs can be created by the message extractor tools owned by the Message Facility. integer.
  FAttributes.AddAttribute('name_msg_id', atNumber, IMPLIED, NODEFAULT, NOLIST);

  // Defines whether or not the user is prompted to reconsider the choice to execute the task. Valid values are:
  FAttributes.AddAttribute('ask', atNOSTRICTLIST, IMPLIED, 'n', 'n|y');
  // Defines the handling of standard input, standard output, and the stderr file during task execution. The value of exec_mode is a string. Valid values are:
  FAttributes.AddAttribute('exec_mode', atNOSTRICTLIST, IMPLIED, 'pipe', 'pipe|noscrollpipe|inherit|exit|Exitnowar|Pipe-back|Noscrollpipe-back|Inherit-back');
  // Indicates if the normally displayed dialog should not be shown. The value of ghost is a string. Valid values are:
  FAttributes.AddAttribute('ghost', atNOSTRICTLIST, IMPLIED, 'n', 'n|y');
  FAbstract:= False;
end;

{
  id              id of the associated dialog or selector header object can be used as a fast path to this and other dialog objects in the dialog. The value of id is a string with a maximum length of 64 characters. All dialog objects that appear in one dialog must have the same ID. Also, IDs should be unique to your application and unique within the particular SMIT database used.
  id_seq_num      position of this item in relation to other items on the dialog; sm_cmd_opt objects in a dialog are sorted on this string field. The value of id_seq_num is a string with a maximum length of 16 characters. When this object is part of a dialog screen, the string "0" is not a valid value for this field. When this object is part of a selector screen, the id_seq_num descriptor must be set to 0.
  disc_field_name string that should match one of the name fields in the output of the cmd_to_discover command in the associated dialog header. The value of disc_field_name is a string with a maximum length of 64 characters.
  name            string that appears on the dialog or selector screen as the field name. It is the visual questioning or prompting part of the object, a natural language description of a flag, option or parameter of the command specified in the cmd_to_exec field of the associated dialog header object. The value of name is a string with a maximum length of 1024 characters.
  name_msg_file   file name (not the full path name) that is the Message Facility catalog for the string, name. string [1024]. Message catalogs required by an application program can be developed with the Message Facility. Set to "" (empty string) if not used.
  name_msg_set    Message Facility set ID for the string, name. The value of name_msg_set is an integer. Set to 0 if not used.
  name_msg_id     Message Facility message ID for the string, name. The value of name_msg_id is an integer. Set to 0 if not used.
  op_type         type of auxiliary operation supported for this field. The value of op_type is a string. Valid values are:
     "" or "n" - This is the default case. No auxiliary operations (list or ring selection) are supported for this field.
     "l" - List selection operation provided. A pop-up window displays a list of items produced by running the command in the cmd_to_list field of this object when the user selects the F4=List function of the SMIT interface.
     "r" - Ring selection operation provided. The string in the disp_values or aix_values field is interpreted as a comma-delimited set of valid entries. The user can tab or backtab through these values to make a selection. Also, the F4=List interface function can be used in this case, since SMIT will transform the ring into a list as needed.
     The values "N", "L", and "R" can be used as op_type values just as the lowercase values "n", "l", and "r". However, with the uppercase values, if the cmd_to_exec command is run and returns with an exit value of 0, then the corresponding entry field will be cleared to an empty string.

  entry_type      type of value required by the entry field. The value of entry_type is a string. Valid values are:
     "" or "n" - No entry; the current value cannot be modified via direct type-in. The field is informational only.
     "t" - Text entry; alphanumeric input can be entered.
     "#" - Numeric entry; only the numeric characters 0, 1, 2, 3, 4, 5, 6, 7, 8, or 9 can be entered. A - (minus sign) or + (plus sign) can be entered as the first character.
     "x" - Hex entry; hexadecimal input only can be entered.
     "f" - File entry; a file name should be entered.
     "r" - Raw text entry; alphanumeric input can be entered. Leading and trailing spaces are considered significant and are not stripped off the field.

  entry_size      Limits the number of characters the user can type in the entry field. The value of entry_size is an integer. A value of 0 defaults to the maximum allowed value size.
  required        Defines if a command field must be sent to the cmd_to_exec command defined in the associated dialog header object. The value of required is a string. If the object is part of a selector screen, the required field should normally be set to "" (empty string). If the object is part of a dialog screen, valid values are:
     "" or "n" - No; the option is added to the command string in the cmd_to_exec command only if the user changes the initially-displayed value. This is the default case.
     "y" - Yes; the value of the prefix field and the value of the entry field are always sent to the cmd_to_exec command.
     "+" - The value of the prefix field and the value of the entry field are always sent to the cmd_to_exec command. The entry field must contain at least one non-blank character. SMIT will not allow the user to run the task until this condition is satisfied.
     "?" - Except when empty; the value of the prefix field and the value of the entry field are sent to the cmd_to_exec field unless the entry field is empty.
  prefix           In the simplest case, defines the flag to send with the entry field value to the cmd_to_exec command defined in the associated dialog header object. string[1024]
  cmd_to_list_mode Defines how much of an item from a list should be used. The list is produced by the command specified in this object's cmd_to_list field. The value of cmd_to_list_mode is a string with a maximum length of 1 character. Valid values are:
    "" or "a" - Get all fields. This is the default case.
    "1" - Get the first field.
    "2" - Get the second field.
    "r" - Range; running the command string in the cmd_to_list field returns a range (such as 1..99) instead of a list. Ranges are for information only; they are displayed in a list pop-up, but do not change the associated entry field.
  cmd_to_list      command string used to get a list of valid values for the value field. string[1024]. This command should output values that are separated by \n (new line) characters.
  cmd_to_list_postfix postfix to interpret and add to the command string specified in the cmd_to_list field of the dialog object. string[1024] If the first line starts with # (pound sign) following a space, that entry will be made non-selectable. This is useful for column headings. Subsequent lines that start with a #, optionally preceded by spaces, are treated as a comment and as a continuation of the preceding entry.
  multi_select     Defines if the user can make multiple selections from a list of valid values produced by the command in the cmd_to_list field of the dialog object. The value of multi_select is a string. Valid values are:
    "" - No; a user can select only one value from a list. This is the default case.
    "," - Yes; a user can select multiple items from the list. When the command is built, a comma is inserted between each item.
    "y" - Yes; a user can select multiple values from the list. When the command is built, the option prefix is inserted once before the string of selected items.
    "m" - Yes; a user can select multiple items from the list. When the command is built, the option prefix is inserted before each selected item.

  value_index      For an option ring, the zero-origin index to the array of disp_value fields. The value_index number indicates the value that is displayed as the default in the entry field to the user. The value of entry_size is an integer.
  disp_values      array of valid values in an option ring to be presented to the user. string[1024]. The field values are separated by , (commas) with no spaces preceding or following the commas.
  values_msg_file  file name (not the full path name) that is the Message Facility catalog for the values in the disp_values fields, if the values are initialized at development time. string[1024]. Message catalogs required by an application program can be developed with the Message Facility.
    Message FDacility:
  values_msg_set   set ID for the values in the disp_values fields. Set to 0 if not used.
  values_msg_id    message ID for the values in the disp_values fields. Set to 0 if not used.
  aix_values       If for an option ring, an array of values specified so that each element corresponds to the element in the disp_values array in the same position; use if the natural language values in disp_values are not the actual options to be used for the command. string[1024]
}
constructor TSmtCmd.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  //
  FNestedElements.AddNew(TSmtMenu, wciAny);
  FNestedElements.AddNew(TSmtSelector, wciAny);
  FNestedElements.AddNew(TSmtDialog, wciAny);

  // Defines how much of an item from a list should be used. The list is produced by the command specified in this object's cmd_to_list field.
  FNestedElements.AddNew(TSmtcmd_to_list_mode, wciOneOrNone);
  // command string used to get a list of valid values for the value field. The value of cmd_to_list is a string with a maximum length of 1024 characters. This command should output values that are separated by \n (new line) characters.
  FNestedElements.AddNew(TSmtcmd_to_list, wciOneOrNone);
  // postfix to interpret and add to the command string specified in the cmd_to_list field of the dialog object. The value of cmd_to_list_postfix is a string with a maximum length of 1024 characters. If the first line starts with # (pound sign) following a space, that entry will be made non-selectable. This is useful for column headings. Subsequent lines that start with a #, optionally preceded by spaces, are treated as a comment and as a continuation of the preceding entry.
  FNestedElements.AddNew(TSmtcmd_to_list_postfix, wciOneOrNone);

  // attribute collection
  // id_seq_num      position of this item in relation to other items on the dialog; sm_cmd_opt objects in a dialog are sorted on this string field. The value of id_seq_num is a string with a maximum length of 16 characters. When this object is part of a dialog screen, the string "0" is not a valid value for this field. When this object is part of a selector screen, the id_seq_num descriptor must be set to 0.
  FAttributes.AddAttribute('id_seq_num', atID, IMPLIED, NODEFAULT, NOLIST);
  // fast path name of the next menu, if the value for the next_type descriptor of this object is "m" (menu). The next_id of a menu should be unique both to your application and within the particular SMIT database used. All non-alias sm_menu_opt objects with id values matching the value of next_id form the set of selections for that menu. string[64]
  FAttributes.AddAttribute('next_id', atID, IMPLIED, NODEFAULT, NOLIST);
  // string that should match one of the name fields in the output of the cmd_to_discover command in the associated dialog header. The value of disc_field_name is a string with a maximum length of 64 characters.
  FAttributes.AddAttribute('disc_field_name', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // Message Facility
  // Message catalogs required by an application program can be developed with the Message Facility.
  //   file name (not the full path name) that is the Message Facility catalog for the string, name. string[1024] Message catalogs required by an application program can be developed with the Message Facility.
  FAttributes.AddAttribute('name_msg_file', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // Message Facility set ID for the string, name. Set IDs can be used to indicate subsets of a single catalog. The value of name_msg_set is an integer.
  FAttributes.AddAttribute('name_msg_set', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // ID for the string, name. The value of name_msg_id is an integer.
  FAttributes.AddAttribute('name_msg_id', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // type of auxiliary operation supported for this field. The value of op_type is a string.
  FAttributes.AddAttribute('op_type', atLIST, IMPLIED, 'noop', 'noop|listselection|ringselection|Noopclearonfail|Listselectionclearonfail|Ringselectionclearonfail');
  // type of value required by the entry field. The value of entry_type is a string. Valid values are:
  FAttributes.AddAttribute('entry_type', atLIST, IMPLIED, 'noentry', 'noentry|text|#-numeric|x-hex|file|raw');
  // Limits the number of characters the user can type in the entry field. integer. A value of 0 defaults to the maximum allowed value size.
  FAttributes.AddAttribute('entry_size', atNUMBER, IMPLIED, '0', NOLIST);
  // Defines if a command field must be sent to the cmd_to_exec command defined in the associated dialog header object. The value of required is a string. If the object is part of a selector screen, the required field should normally be set to "" (empty string). If the object is part of a dialog screen,
  FAttributes.AddAttribute('required', atLIST, IMPLIED, 'n', 'n|y|+-prefix|?-except');
  // In the simplest case, defines the flag to send with the entry field value to the cmd_to_exec command defined in the associated dialog header object. string[1024]
  FAttributes.AddAttribute('prefix', atVDATA, IMPLIED, NODEFAULT, NOLIST);

  // Defines if the user can make multiple selections from a list of valid values produced by the command in the cmd_to_list field of the dialog object. The value of multi_select is a string.
  FAttributes.AddAttribute('multi_select', atLIST, IMPLIED, '', '|,-comma|y-once|m-each');
  // For an option ring, the zero-origin index to the array of disp_value fields. The value_index number indicates the value that is displayed as the default in the entry field to the user. The value of entry_size is an integer.
  FAttributes.AddAttribute('value_index', atNUMBER, IMPLIED, NODEFAULT, NOLIST);
  // array of valid values in an option ring to be presented to the user. string[1024]. The field values are separated by , (commas) with no spaces preceding or following the commas.
  FAttributes.AddAttribute('disp_values', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // Message Facility
  // Message catalogs required by an application program can be developed with the Message Facility.
  //  file name (not the full path name) that is the Message Facility catalog for the values in the disp_values fields, if the values are initialized at development time. string[1024]. Message catalogs required by an application program can be developed with the Message Facility.
  FAttributes.AddAttribute('value_msg_file', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  // set ID for the values in the disp_values fields. Set to 0 if not used.
  FAttributes.AddAttribute('value_msg_set', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // message ID for the values in the disp_values fields. Set to 0 if not used.
  FAttributes.AddAttribute('value_msg_id', atNumber, IMPLIED, NODEFAULT, NOLIST);
  // If for an option ring, an array of values specified so that each element corresponds to the element in the disp_values array in the same position; use if the natural language values in disp_values are not the actual options to be used for the command. string[1024]
  FAttributes.AddAttribute('aix_values', atVDATA, IMPLIED, NODEFAULT, NOLIST);
  FAbstract:= False;
end;

// --------- TSmtHelp ---------

constructor TSmtHelp.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  // attribute collection
  FAbstract:= False;
end;

// --------- TSmtBracket ---------

constructor TSmtBracket.Create(ACollection: TCollection);
var
  e: Integer;
begin
  inherited Create(ACollection);
  if wcServerExtensions in xmlENV.xmlCapabilities then begin
    for e:= Low(SmitElements) + 2 to High(SmitElements) do begin
      FNestedElements.AddNew(SmitElements[e], wciAny);
    end;
  end;
end;

// --------- GetDocumentTitle ---------

{
  GetDocumentTitle() calls xml parser
}

function GetDocumentTitle(const ASrc: WideString): String;
label
  fin;
var
  TxnCollection: TxmlElementCollection;
begin
  Result:= '';
  TxnCollection:= TxmlElementCollection.Create(TSmtContainer, Nil, wciOne);
  with TxnCollection do begin
    Clear1;
    xmlParse.xmlCompileText(ASrc, Nil, Nil, Nil, Items[0], TSmtContainer, TSmtSelector);
    Result:= Items[0].NestedElementText[TSmtSelector, 0];
  end;
fin:
  TxnCollection.Free;
end;


// --------- RegisterXML ---------

function RegisterXML(var AxmlDesc: TxmlClassDesc): Integer;
begin
  Result:= 0;
  with AxmlDesc do begin
    ofs:= 340; // taxon last 333. 6 reserved
    len:= 21; // last is 360
    classes:= @SmitElements;
    DocType:= edSMIT;

    xmlElementClass:= TSmtContainer;
    xmlPCDataClass:= TSmtPCData;
    DocDescClass:= TSmtDocDesc;

    deficon:= ofs;
    defaultextension:= 'smt';
    desc:= 'SMIT xml';
    extensionlist:= 'smt|smit';
    OnDocumentTitle:= GetDocumentTitle;
  end;
end;

end.
