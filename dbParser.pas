unit
  dbparser;
(*##*)
(*******************************************************************************
*                                                                             *
*   d  b  p  a  r  s  e  r                                                     *
*                                                                             *
*   Copyright © 2001-2004 Andrei Ivanov. All rights reserved.                  *
*   wireless markup language parser                                           *
*   Conditional defines: USE_BDE|USE_IB|USE_ADO|USE_DBE|USE_LDAP               *
*                                                                             *
*   xmlsupported.pas: Jul 2004 added $(var:singlequote:esc|u|n)                *
*              suppress usage of MASK_VAR_ESCAPESINGLEQUOTE                   *
*   serverside syntax, (values can be quoted by " or ')                        *
*   IB:                                                                       *
*   a. File path: db="[servername:]<db file path>";user='SYSDBA';password=...; *
*     lc_ctype="WIN1251";sql_role_name=;                                      *
*   b. IB client alias: db=employee;user=SYSDBA;password=masterkey;            *
*                                                                             *
*                                                                              *
*   BDE: db=DBDEMOS; [user=;][password=;]                                     *
*                                                                              *
*   ADO:  db="FILE NAME=E:\..\Ole DB\Data Links\DBDEMOS.udl;";                *
*                                                                              *
*   variable special literals:                                                *
*    now today time maxthreads dataset.pageline copyright                              *
*    q-get q-post q-combined  u-{g|p|c} p-{g|p|c}                             *
*    query                    url       path                                   *
*   request-related variables (passed from wdbxml.dll):                       *
*     _url _host _scriptname _pathinfo _serverport _useragent                  *
*   e.g.                                                                      *
*   <td loop="global">$(dsResource#pageline#first-last)</td>                   *
*                                                                             *
*                                                                              *
*   Revisions    : Apr 22 2002                                                *
*   Revisions    : Dec 16 2002                                                 *
*   Last fix     : May 27 2002                                                *
*   Lines        : 1590                                                        *
*   History      :                                                            *
*   Printed      : ---                                                         *
*                                                                             *
********************************************************************************)
(*##*)
{ dbExpress drivers available: INTERBASE, MYSQL, INFORMIX, ORACLE, DB2
  In case of Inyterbase you must provide information:
    DriverName=Interbase
    User_Name=sysdba
    Password=masterkey
    Database=database.gdb
    RoleName=RoleName
    ServerCharSet=
    SQLDialect=1
    ErrorResourceFile=
    LocaleCode=0000
    BlobSize=-1
    CommitRetain=False
    WaitOnLocks=True
    Interbase TransIsolation=ReadCommit4ed
    Trim Char=False

}

{$IFNDEF USE_BDE}{$IFNDEF USE_IB}{$IFNDEF USE_ADO}{$IFNDEF USE_DBE}{$IFNDEF USE_LDAP}
Select menu Project|Options|Directories / Conditionals|Conditional defines, define USE_BDE, USE_IB, USE_DBE, USE_ADO or USE_LDAP
{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}{$ENDIF}

// BDE, DBE, ADO is very smilar
{$IFNDEF USE_IB}{$IFNDEF USE_LDAP}
{$DEFINE USE_BDE_ADO_DBE}
{$ENDIF}{$ENDIF}

interface
uses
  Classes, Windows, SysUtils, httpProd,
  jclUnicode, Registry, SyncObjs, util1,
  oebdoc, oebpkg, xhtml, biotaxon, smit, dbxmlint,
{$IFDEF USE_BDE}
  Db, DBTables,
{$ENDIF}
{$IFDEF USE_DBE}
  DbXPress, SqlExpr, Db, DbTables,
{$ENDIF}
{$IFDEF USE_ADO}
  ActiveX, ADODb, Db, DbTables,
{$ENDIF}
{$IFDEF USE_IB}
  IBSQL, IBDatabase, IbHeader,
{$ENDIF}
{$IFDEF USE_LDAP}
  uLDAP,
{$ENDIF}
{$IFDEF USE_NCOCI}
  NCOci, NCOciWrapper, NCOciDB, Db, DBTables, // declarations of Db.TFld, DbTables.TBlobStream
{$ENDIF}
  customxml, xmlsupported, xmlParse, wml,
  DECUtil, Cipher, Hash;
const
  { version }
  LNVERSION = '1.0';
  { resource language }
  LNG = ''; { DLL language usa, 409 }
  { registry path }
  RGPATH = 'Software\ensen\apoo editor\' + LNVERSION;
  RGW2SVCALIAS = '\SYSTEM\CurrentControlSet\Services\W3SVC\Parameters\Virtual Roots';
  DEFBLOBRESULTBUFSIZE = $10000;
  DEF_CONTENT_TYPE = 'application/octet-stream';
  MAX_WAITLOOPS = $100;

  STR_DB = 'db';
  STR_USER = 'user';
  STR_ROLE = 'role';
  STR_PASSWORD = 'password';
  STR_SQLDIALECT = 'dialect';
  STR_DRIVER = 'opt';
  STR_DRIVERBDE = 'bde';
  STR_DRIVERDBE = 'dbExpress';
  STR_DRIVERADO = 'ado';
  STR_DRIVERIB = 'ib';
  STR_DRIVERLDAP = 'ldap';

  STR_QUERY = 'query';
  STR_EXECUTE = 'execute';

  STR_SEND = 'send';
  STR_SENDOPT_COOKIE = 'cookie';
  STR_SENDOPT_MAIL = 'mail';

  STR_MOVE = 'move';
  STR_DEFPARAM = 'defaultparam';
  STR_DEFPARAMS = 'defaultparams';
  STR_GLOBAL = 'global';
  STR_COOKIE = 'cookie';
  STR_DATASET = 'dataset';
  STR_EXPRESSION = 'value';
  STR_ACTION = 'action';
  STR_LOOP = 'loop';
  STR_DBS_ID = 'id';
  STR_COMMENTATTR = 'value';
  STR_1ST = 'first';
  STR_LAST = 'last';

  IND_SEND_COOKIE = 1; // set to 1 indicates to set cookie
  IND_SEND_MAIL = 2; // set to 2 indicates to send mail

  FMT_VARVALUE = '%s.%s=%s'; // for example, employee.lastname=McDuck
  FMT_VARNAME = '%s.%s'; // for example, employee.lastname=McDuck

  ERR_CONVERSION = 'Can''t represent column "%s" as string.';
  ERR_NOFIELD = 'Column "%s" of dataset "%s" does not exists.';
  ERR_MISSEDDATASET = 'Dataset "%s" is not defined.';
  ERR_DATASETCLOSED = 'Dataset "%s" is not opened.';
  ERR_DATASETCLOSEDF = 'Can''t evaluate field "%s" value- dataset "%s" is not opened.';
  ERR_SQLERROR = '%s,'#13#10'sql:'#13#10'%s';

{$IFDEF USE_BDE}
  STR_CURDRIVER = STR_DRIVERBDE;
{$ENDIF}
{$IFDEF USE_DBE}
  STR_CURDRIVER = STR_DRIVERDBE;
{$ENDIF}
{$IFDEF USE_ADO}
  STR_CURDRIVER = STR_DRIVERADO;
{$ENDIF}
{$IFDEF USE_IB}
  STR_CURDRIVER = STR_DRIVERIB;
{$ENDIF}
{$IFDEF USE_LDAP}
  STR_CURDRIVER = STR_DRIVERLDAP;
  STR_HOST = 'host';
  STR_PORT = 'port';
  STR_BINDDN = 'binddn';
  STR_BASEDN = 'basedn';
  STR_PWD = 'bindpwd';
{$ENDIF}

{$IFDEF USE_BDE}
type
  TEDatabase = TDatabase;
  TDS = TQuery;
  TFLD = TField;
const
  DBPAR_USERNAME = 'USER NAME';
  DBPAR_PASSWORD = 'PASSWORD';
  DBPAR_ROLE = 'RoleName'; // I'm not sure
{$ENDIF}
{$IFDEF USE_DBE}
type
  TEDatabase = TSQLConnection;
  TDS = TSQLQuery;
  TFLD = TField;
const
  DBPAR_DBXDRIVERAME = 'DriverName';
  DBPAR_DBXDB = 'Database';
  DBPAR_ROLE = 'RoleName';
  DBPAR_USERNAME = 'User_Name';
  DBPAR_PASSWORD = 'Password';
{$ENDIF}
{$IFDEF USE_ADO}
type
  TEDatabase = TADOConnection;
  TDS = TADOQuery;
  TFLD = TField;
const
  DBPAR_USERNAME = 'User Name';
  DBPAR_PASSWORD = 'Password';
{$ENDIF}
{$IFDEF USE_IB}
type
  TEDatabase = TIBDatabase;
  TDS = TIBSQL;
  TFLD = TIBXSQLVAR;
const
  DBPAR_USERNAME = 'user_name';
  DBPAR_PASSWORD = 'password';
  // for Interbase only
  DBPAR_CP = 'lc_ctype'; // WIN1251 - cyrillic
  DBPAR_ROLE = 'sql_role_name'; // reserved
{$ENDIF}
{$IFDEF USE_LDAP}
type
  TEDatabase = TldapConnection;
  TDS = TldapDataset; // TldapConnEnv
  // TEntry = TldapEntry;
  TFLD = TldapAttribute;
const
  DBPAR_USERNAME = 'BindDN';
  DBPAR_PASSWORD = 'BindPwd';
  DBPAR_BASEDN = 'BaseDN'; // I'm not sure
{$ENDIF}

type
  { formatting routine <#f name= fmt=external dll= func= [modifier=]>}
  TFuncFmtDll = function(AData, ASpecifier: PChar; var ABuf: PChar; var ABufSize: Integer): Boolean; stdcall;

  TXMLDbParser = class;

  TDatasets = class(TStringList)
  private
    FDatabaseNameCount: Integer;
    FParentParser: TXMLDbParser;
    FNamedDatabases: array of TEDatabase;
    // FCriticalErrorListPtr: ^TWideStrings;
    FOnError: TReportEvent;
    FAdditionalDBAlias: TStrings; { list of direct DB access (IB) aliases, not used in BDE }
{$IFDEF USE_ADO}
    FConnectionStr: string;
{$ENDIF}

{$IFDEF USE_BDE}
//    FSession: TSession;
{$ENDIF}
{$IFDEF USE_DBE}
    FTransactionDesc: array of TTransactionDesc;
{$ENDIF}
{$IFDEF USE_IB}
//    FTransaction: TIBTransaction;
{$ENDIF}

    // function GetCriticalErrorList: TWideStrings;
    // procedure SetCriticalErrorList(AValue: TWideStrings);
    function GetDataSet(Index: Integer): TDS;
    procedure PutDataSet(Index: Integer; AValue: TDS);
    function GetDataSetByName(const ADataSetName, AExpression, ADatabaseId: String;
      var ADataSet: TDS): Integer;
    // called by SetDataset action="db"
    function OpenDbConn(const ADatabaseIdentifier, ADbConnStr, AOptions: String;
      var ADbCodePage: Integer): Boolean;

    function GetActiveDataSource(Index: Integer): Boolean;
    procedure SetActiveDataSource(Index: Integer; AValue: Boolean);
    function GetSQLTemplate(Index: Integer): string;
    // search databases by opt=''
    function GetNamedDatabasesIndex(const ADatabaseId: String): Integer;
  protected
    function ReloadInterbaseAliases(const AKey: DWORD = HKEY_CURRENT_USER;
      const APath: string = '\Software\Borland\InterBase\IBConsole\Servers'): Integer;
    function CheckCriticalDbError(const AErrorDesc: string): Boolean;
    procedure DoReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: string; AWhere: TPoint; const ADesc: string; var AContinueParse: Boolean);
    function CheckIsSameDbSets(ADatabase: TEDatabase; AParameterList: TStrings): Boolean;
    procedure CreateDatabase(var ADatabase: TEDatabase; const ADatabaseName: String);
    procedure DestroyDatabase(ADatabase: TEDatabase);
  public
    constructor Create(AParentParser: TxmlDbParser);
    destructor Destroy; override;
    function SetDataSet(const ADataset, AAction, AOptional, ADbsId: String;
      const AExpression: WideString; var AResult: String): Integer;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
    procedure ExecSQL(AIndex: Integer);

    // used by 'action=move:'
    function OpenSQL(AIndex: Integer): Boolean; // Dec 2002
    function CountSQL(AIndex: Integer): Integer; //
    // useb by default parameter serverside element
    function GetSQLRecVal1(AIndex: Integer): string; // used to retrieve default parameter, read first record and first attribute
    function GetSQLRecVals(AIndex: Integer): string; // first and second fields pairs
    function CloseSQL(AIndex: Integer): Boolean; // Dec 2002
    function DoSetSend(AIndex: Integer; const ACommaText: WideString; AProvider: Integer): Integer;
    property DataSets[AIndex: Integer]: TDS read GetDataSet write PutDataSet; default;
    property ActiveDataSets[AIndex: Integer]: Boolean read GetActiveDataSource write SetActiveDataSource;
    property SQLTemplate[AIndex: Integer]: string read GetSQLTemplate;
    procedure Open(ADatabase: TEDatabase);
    procedure Close(ADatabase: TEDatabase);
    procedure Commit(ADatabase: TEDatabase);
    procedure CommitAll;
    procedure Rollback(ADatabase: TEDatabase);
    procedure StartTransaction(ADatabase: TEDatabase);
  published
    // property CriticalErrors: TWideStrings read GetCriticalErrorList write SetCriticalErrorList;
    property OnError: TReportEvent read FOnError write FOnError;
  end;

  TDbParserThreadPool = class;

  TXMLDbParser = class(TPersistent)
  private
    FContentType: String; // loaded from database content type e.g. 'application/octet-stream'

    FDbCodePage: Integer;
    FRow_Num: Integer;  // 0..
    FParent: TDbParserThreadPool; // TObject; //
    FGlobalVarsOfs: Integer; // points to the FVars index where global vars is stored (at the end of variables)
    FVars: TWideStrings;
    FCookies: TWideStrings;
    FDatasets: TDatasets;
    FOnReport: TReportEvent;
    FModulePath: string;
    FFormatDll: string;
    FFuncFmtDllHandle: THandle; // TFuncFmtDll

    FAlias: TStrings; { list of web server directory aliases }
    FState: Integer; // 0 - continue, 1- move: action 2- set default parameter value
    FCharSet: Integer; // csUTF8 is default
    FStateValue: string;
    procedure SetOnReport(AValue: TReportEvent);
  protected
    FEnv: Pointer;
    procedure DoReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
      const ASrc: PWideChar; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean);
    procedure OnEachElement(var AxmlElement: TxmlElement);
    procedure OnEachErrorElement(var AxmlElement: TxmlElement);
    function GetAttributeValue(AxmlElement: TxmlElement; const AAttrName: string; AMaskVar: Integer): WideString;
    function EvaluateVars(var ws: WideString; AMaskVar: Integer): Integer;
    function EvaluateCookies(var ws: WideString; AMaskVar: Integer): Integer;
    // get variable value. If variable does not set, keep it intact
    procedure OnEachVar(var AxmlElement: TxmlElement);
    // get variable value. If variable does not set, remove variables related to closed datasets, called from OnEachErrorElement
    procedure OnEachVar0(var AxmlElement: TxmlElement);
    // get cookie variable value
    procedure OnEachCookie(var AxmlElement: TxmlElement);
    function Alias2FileName(const AFn: string): string;
    function FormatBlobByDLL(const Adll, AFunc, Aspecifier: String; AFld: TFld): string;
    function GetVariableValue(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
    function GetCookieValue(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
    // similar to GetVariableValue except if varibale not found, replace it to ''
    function GetVariableValue0(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
    procedure ParseSQLParameters(ADatasetIndex: Integer);
    // function GetVars: WideString;
    procedure SetVars(AValue: TWideStrings);
    procedure SetCookies(AValue: TWideStrings);
    //
    // functions try to search special literals
    function CalcSpecialLiterals(const AVarName: string; AEsc: Integer; var AValue: WideString): Integer;
    function CalcSpecialDatasetLiterals(const AVarName: string; AEsc: Integer; var AValue: WideString): Integer;
    function MkPageLine(const ADsn: String; const AFirst, ALast: String): WideString; // generate page line
    function MkCurrentQuery(AQuery, AContent: Boolean): WideString; // generate current query/content
    function MkCurrentPath(AQuery, AContent: Boolean): WideString; // generate current scriptname, pathinfo, query/content
    function MkCurrentUrl(AQuery, AContent: Boolean): WideString; // generate current url with query and post as query
  public
    constructor Create(ADbParserThreadPool: TDbParserThreadPool; AEnv: Pointer);
    destructor Destroy; override;
    function Parse(AxmlElement: TxmlElement; var AStateValue: WideString): Integer;
    procedure Clear;
    // load page content from the database with specified db connection
    function DbLoadContent(const AUrl: WideString; var AContent: WideString;
      const ADbConnectString, AContentSQL, AContentTypeSQL, AContentKey: String): Boolean;
    property Vars: TWideStrings read FVars write SetVars;
    property Cookies: TWideStrings read FCookies write SetCookies;
    property Datasets: TDatasets read FDatasets;
    // property VarsAsCommaText: WideString read GetVars write SetVars;  // comma text like "var0=", "var1=1"
     property ContentType: String read FContentType write FContentType; // loaded from database content type e.g. 'application/octet-stream'
  published
    property DbCodePage: Integer read FDbCodePage write FDbCodePage; // 0- ANSI, 1 OEM MAC THREAD SYMBOL UTF7 UTF8
    property OnReport: TReportEvent read FOnReport write SetOnReport;
  end;


  TDbParserThread = class(TObject)
  private
    FHandle: THandle;
    FThreadID: THandle;
    FSuspended: Boolean;
    FTerminated: Boolean;
    FDbParserThreadPool: TDbParserThreadPool;

    FxmlCollection: TxmlElementCollection;
    FDocType: TEditableDoc;
    FXMLElementSrc: PWideChar;
    FXMLDbParser: TXMLDbParser;
    FLocalVarsPtr: PWideChar;
    FLocalCookiesPtr: PWideChar;
    // FLocalVars: TWideStrings;
    // function GetVars: WideString;
    // procedure SetVars(AValue: WideString);
    FNewCookieStr: WideString; // storage

    FContentPassed: TPassContentSet;
  protected
    FEnv: Pointer;
  public
    constructor Create(ADbParserThreadPool: TDbParserThreadPool; AOnReport: TReportEvent;
      AEnv: Pointer);
    destructor Destroy; override;
    procedure Execute;
    procedure Suspend;
    procedure Resume;
    // remove cookies or mail in FCookies
    procedure PrepareCookies2Send;

    property Suspended: Boolean read FSuspended;
    property Terminated: Boolean read FTerminated write FTerminated;
    property LocalVars: PWideChar read FLocalVarsPtr write FLocalVarsPtr; // read GetVars write SetVars;  // comma text like "var0=", "var1=1"
    property LocalCookies: PWideChar read FLocalCookiesPtr write FLocalCookiesPtr; // read GetVars write SetVars;  // comma text like "var0=", "var1=1"
  end;

  TDbParserThreadPool = class(TObject)
  private
    FOptions: TParsersOptionSet;
    FThreadPool: TList;
    FLock: TCriticalSection;
    FPoolIndex: Integer;
    FMin: Integer;
    FMax: Integer;

    FGlobalVars: TWideStrings;
    FCriticalErrors: TWideStrings;
    FDefOnReport: TReportEvent;
    procedure SetDefOnReport(AValue: TReportEvent);
    procedure AdjustThreadPool;
    function CreateThread(AOnReport: TReportEvent; AEnv: Pointer): TDbParserThread;
    function GetThreadCount: Integer;
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    function GetVars: WideString;
    procedure SetVars(AValue: WideString);
  protected
  public
    constructor Create(ACriticalErrors: PWideChar; AOptions: TParsersOptionSet);
    destructor Destroy; override;
    function DispatchThread(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
      AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
      AEnv: Pointer): Integer; overload; //
    // use default report event
    function DispatchThread(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
      AVars: PWideChar; ACookies: PWideChar; AContentPassed: TPassContentSet;
      AEnv: Pointer): Integer; overload; // return thread handle
    function RemoveThread(ADbParserThread: TDbParserThread): Boolean;
    procedure Clear;

    property Min: Integer read FMin write SetMin default 1;
    property Max: Integer read FMax write SetMax default 32;
    property ThreadCount: Integer read GetThreadCount;
    property DefOnReport: TReportEvent read FDefOnReport write SetDefOnReport;
    property GlobalVars: WideString read GetVars write SetVars; // comma delimited text like "var0=", "var1=1"
  end;

var
  DbParserThreadPoolManager: TDbParserThreadPool;
  // return thread handle:
  DispatchThread: function(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
    AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
    AEnv: Pointer): Integer of object;

implementation

uses
  util_xml, wmlc;

const
  ERR_WRONGDBDRIVER = '%s driver is not loaded, ' + STR_CURDRIVER + ' driver can not parse document.';
  // internal name of database connection where content is resides
  OPT_DBCONT = '_dbC_';

{-------------------------------- utility -----------------------------------}

// get string repesent of BLOB or field of other kinds
{$IFDEF USE_IB}

function GetBlob(AFld: TFld): String;
begin
  try
    Result:= AFld.AsString; // Interbase is simple
  except
    Result:= ''; // in some cases raise Interbase exception
  end;
end;
{$ENDIF}
{$IFDEF USE_LDAP}

function GetBlob(AFld: TFld): String;
begin
  Result:= AFld.ValueList.Text;
end;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}

function GetBlob(AFld: TFld): String;
var
  BlobStream: TBlobStream;
  StringStream: TStringStream;
begin
  Result:= '';
  StringStream:= TStringStream.Create('');
  try
    if AFld.IsBlob then begin
      BlobStream:= TBlobStream.Create(AFld as TBlobField, bmRead);
      StringStream.CopyFrom(BlobStream, BlobStream.Size);
      Result:= StringStream.DataString;
      BlobStream.Free;
    end else begin
      SetLength(Result, AFld.DataSize);
      AFld.GetData(@Result[1]);
    end;
  finally
    StringStream.Free;
  end;
end;
{$ENDIF}

{-------------------------------- TDatasets -----------------------------------}

constructor TDatasets.Create(AParentParser: TxmlDbParser);
begin
  inherited Create;
  FDatabaseNameCount:= 0;
  FParentParser:= AParentParser;
  { list of direct DB access (IB) aliasesm, not used in BDE }
  FAdditionalDBAlias:= TStringList.Create;
  // FCriticalErrorListPtr:= Nil;

  // set array of named databases to zero + 1 for default
  SetLength(FNamedDatabases, 1);
  // create default database
  CreateDatabase(FNamedDatabases[0], '');

{$IFDEF USE_DBE}
  SetLength(FTransactionDesc, 0);
{$ENDIF}
  FOnError:= nil;
end;

procedure TDatasets.CreateDatabase(var ADatabase: TEDatabase; const ADatabaseName: String);
var
{$IFDEF USE_IB}
  fbTransaction: TIBTransaction;
{$ENDIF}
{$IFDEF USE_BDE}
  bdeSession: TSession;
{$ENDIF}
  idx: Integer;
begin
{$IFDEF USE_BDE}
  bdeSession:= TSession.Create(nil);
  with bdeSession do begin
    AutoSessionName:= True; // AutoSessionName:= False; SessionName:= 'Session1_1';
    KeepConnections:= True;
    Active:= True;
  end;
  ADatabase:= TEDatabase.Create(nil);
  with ADatabase do begin
    DatabaseName:= Format('db%d', [FDatabaseNameCount]); // ?!! what for?
    SessionName:= bdeSession.SessionName;
    HandleShared:= True;
    LoginPrompt:= False;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  SetLength(FTransactionDesc, FDatabaseNameCount + 1);

  ADatabase:= TEDatabase.Create(nil);
  with ADatabase do begin
    ConnectionName:= Format('dbxml%d', [FDatabaseNameCount]);
    // DriverName:= 'DB2';
    LoginPrompt:= False;
    with FTransactionDesc[FDatabaseNameCount] do begin
      IsolationLevel:= xilREADCOMMITTED;
      if TransactionsSupported then begin
        TransactionID:= FDatabaseNameCount;
      end else begin
      end;
    end;
  end;
{$ENDIF}

{$IFDEF USE_IB}
  ReloadInterbaseAliases();
  fbTransaction:= TIBTransaction.Create(nil);
  ADatabase:= TEDatabase.Create(nil);
  with fbTransaction do begin
    IdleTimer:= 0; // default- no time out. in seconds?
    DefaultDatabase:= ADatabase;
  end;
  with ADatabase do begin
    // IdleTimer:= 0; SQLDialect:= 1;
    DefaultTransaction:= fbTransaction;
    LoginPrompt:= False;
  end;
{$ENDIF}

{$IFDEF USE_ADO}
  FConnectionStr:= '';
// Call CoInitialize on every thread before TADOConnection creation
  ADatabase:= TEDatabase.Create(nil);
  with ADatabase do begin     
    LoginPrompt:= False;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  ADatabase:= TEDatabase.Create();
{$ENDIF}
  // set up component name for VCL and component number (to relate session using DBX)
  with ADatabase do begin
    if Length(ADatabaseName) = 0
    then Name:= Format('db%d', [FDatabaseNameCount]) // VCL requires unique component name
    else Name:= ADatabaseName;
    Tag:= FDatabaseNameCount;
  end;
  Inc(FDatabaseNameCount);
end;

procedure TDatasets.DestroyDatabase(ADatabase: TEDatabase);
begin
  try
  with ADatabase do begin
{$IFDEF USE_BDE}
    Self.Commit(ADatabase);
    Free;
    Session.Free;
{$ENDIF}
{$IFDEF USE_DBE}
    Self.Commit(ADatabase);
    Free;
{$ENDIF}
{$IFDEF USE_IB}
    if Connected then with DefaultTransaction do begin
      Self.Commit(ADatabase);
      Free;
    end;
    Free;
{$ENDIF}
{$IFDEF USE_ADO}
    if Connected then begin
      Self.Commit(ADatabase);
    end;
    Free;
{$ENDIF}
{$IFDEF USE_LDAP}
    Free;
{$ENDIF}
  end;
  except
    on E: Exception do begin
    end;
  end;
end;

destructor TDatasets.Destroy;
begin
  Clear;
  DestroyDatabase(FNamedDatabases[0]);
  // FCriticalErrorListPtr:= Nil;
  FAdditionalDBAlias.Free;
  inherited Destroy;
end;

const
{ TCP/IP  <server_name>:<filename>.
  NetBEUI \\<server_name>\<filename>.
  SPX     <server_name>@<filename>.
}
  REMOTEDB_FMT: array[0..3] of string = ('%s:', '\\%s\', '%s%', '%s');

function TDatasets.ReloadInterbaseAliases(const AKey: DWORD = HKEY_CURRENT_USER;
  const APath: string = '\Software\Borland\InterBase\IBConsole\Servers'): Integer;
var
  i, d: Integer;
  Rg: TRegistry;
  charset, databasefilename,
    servername, role, curserverpath: string;
  protocol: Integer; // 0-tcp/ip 1- NetBEUI 2- SPX 3- local
  servers, databases: TStrings;
begin
  Result:= 0;
  FAdditionalDBAlias.Clear;
  servers:= TStringList.Create;
  databases:= TStringList.Create;
  Rg:= TRegistry.Create;
  Rg.RootKey:= AKey;
  if Rg.OpenKeyReadOnly(APath) then begin
    try
      Rg.GetKeyNames(servers);
      for i:= 0 to servers.Count - 1 do begin
        try
          curserverpath:= APath + '\' + servers[i];
          Rg.OpenKeyReadOnly(curserverpath);
          protocol:= 3;
          if Rg.ValueExists('ServerName') then begin
            try
              serverName:= Rg.ReadString('ServerName');
              if Rg.ValueExists('Protocol') then begin
                protocol:= Rg.ReadInteger('Protocol') and $3;
              end;
            except
            end;
          end;

          curserverpath:= APath + '\' + servers[i] + '\Databases';
          if protocol = 3 then serverName:= '';
          if Rg.OpenKeyReadOnly(curserverpath) then begin
            // default local server
            // get databases
            Rg.GetKeyNames(databases);
            for d:= 0 to databases.Count - 1 do begin
              try
                if Rg.OpenKeyReadOnly(curserverpath + '\' + databases[d]) then begin
                  // get first filename (CRLF delimited)
                  databasefilename:= util1.GetToken(1, #13, Rg.ReadString('DatabaseFiles'));
                  role:= Rg.ReadString('Role');
                  charset:= Rg.ReadString('CharacterSet');
                  FAdditionalDBAlias.Add(databases[d] + '=' +
                    Format(REMOTEDB_FMT[protocol], [serverName]) + databasefilename + ';' + charset + ';' + role);
                end;
              except
              end;
            end; { for }
          end;
        except
        end;
      end;
    except
      Result:= FAdditionalDBAlias.Count;
    end;
  end;
  Rg.Free;
  databases.Free;
  servers.Free;
end;

procedure TDatasets.DoReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: string; AWhere: TPoint; const ADesc: string; var AContinueParse: Boolean);
var
  cont: Boolean;
  s: WideString;
begin
  // look for critical database errors and do close connections
  // if ALevel = rlInternal then
  CheckCriticalDbError(ADesc);
  if Assigned(FOnError) then begin
    s:= ADesc;
    util1.DeleteControlsStrCRLF2Space(s);
    FOnError(ALevel, AxmlElement, '', 0, AWhere, PWideChar(s), cont, FParentParser.FEnv);
  end;
end;

{ return True if fatal database error occured
  In this case database closed and is not avaliable for entire deck
  until new deck is loaded.
}

function TDatasets.CheckCriticalDbError(const AErrorDesc: string): Boolean;
var
  i, d: Integer;
begin
  Result:= False;
{$IFNDEF USE_LDAP}
  for i:= 0 to TDbParserThreadPool(FParentParser.FParent).FCriticalErrors.Count - 1 do begin
    if Pos(TDbParserThreadPool(FParentParser.FParent).FCriticalErrors[i], AErrorDesc) > 0 then begin
      //
      try
        for d:= 0 to Length(FNamedDatabases) - 1 do begin
          FNamedDatabases[i].Connected:= False;
        end;  
      except
      end;
      Result:= True;
      Exit;
    end;
  end;
{$ENDIF}
end;

function TDatasets.GetDataSet(Index: Integer): TDS;
begin
  Result:= TDS(GetObject(Index));
end;

procedure TDatasets.PutDataSet(Index: Integer; AValue: TDS);
begin
  PutObject(Index, AValue);
end;

function TDatasets.GetActiveDataSource(Index: Integer): Boolean;
var
  ds: TDS;
begin
  if (Index < 0) or (Index >= Count) then begin
    Result:= False;
    Exit;
  end;
  ds:= GetDataSet(Index);
{$IFDEF USE_BDE_ADO_DBE}
  Result:= ds.Active;
{$ENDIF}
{$IFDEF USE_IB}
  Result:= ds.Open;
{$ENDIF}
{$IFDEF USE_LDAP}
  Result:= ds.Connected;
{$ENDIF}
end;

procedure TDatasets.SetActiveDataSource(Index: Integer; AValue: Boolean);
var
  ds: TDS;
  xy: TPoint;
  cont: Boolean;
begin
  if (Index < 0) or (Index >= Count) then Exit;
  ds:= GetDataSet(Index);
  if AValue then begin
    if GetActiveDataSource(Index) then Exit; // allready opened
    try
{$IFDEF USE_IB}
      ds.Database.DefaultTransaction.Active:= True; // looks like transaction sometimes is closed
      ds.ExecQuery;
{$ENDIF}
{$IFDEF USE_BDE}
      ds.Open;
{$ENDIF}
{$IFDEF USE_DBE}
      ds.Open;
{$ENDIF}
{$IFDEF USE_ADO}
      ds.Open;
{$ENDIF}
{$IFDEF USE_LDAP}
      ds.Open;
{$ENDIF}
    except
      on E: Exception do begin
        xy.x:= 0;
        xy.y:= 0;
        cont:= True;
        DoReportEvent(rlInternal, nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
      end;
    end;
  end else begin
    if not GetActiveDataSource(Index) then Exit; // allready closed
    try
      // IB:     FTransaction.Active:= False;
      ds.Close;
    except
      on E: Exception do begin
        xy.x:= 0;
        xy.y:= 0;
        cont:= True;
        DoReportEvent(rlInternal, nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
      end;
    end;
  end;
end;

function TDatasets.GetSQLTemplate(Index: Integer): string;
var
  p: Integer;
begin
  if (Index < 0) or (Index >= Count) then begin
    Result:= '';
    Exit;
  end;
  Result:= Strings[Index];
  p:= Pos('=', Result);
  if p > 0 then System.Delete(Result, 1, p);
end;

procedure TDatasets.Open(ADatabase: TEDatabase);
begin
{$IFDEF USE_IB}
  with ADatabase do begin
    try
      Connected:= True;
    except
    end;
  end;
{$ENDIF}
{$IFDEF USE_BDE}
  try
    with ADatabase do begin
      Connected:= True
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  try
    with ADatabase do begin
      Connected:= True
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  try
    with ADatabase do begin
      CoInitialize(nil);
      Connected:= True
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  { it is not neccesary to open connection to ldap
  with ADatabase do begin
    try
      Connected:= True;
    except
    end;
  end;
  }
{$ENDIF}
end;

procedure TDatasets.Close(ADatabase: TEDatabase);
begin
{$IFDEF USE_IB}
  with ADatabase do begin
    try
      Connected:= False;
    except
    end;
  end;
{$ENDIF}
{$IFDEF USE_BDE}
  try
    with ADatabase do begin
      Connected:= False;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  try
    with ADatabase do begin
      Connected:= False;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  try
    with ADatabase do begin
      Connected:= False;
      CoUninitialize;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  try
    with ADatabase do begin
      Connected:= False;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
end;

procedure TDatasets.CommitAll;
var
  t: Integer;
begin
  for t:= 0 to Length(FNamedDatabases) - 1 do begin
    Commit(FNamedDatabases[t]);
  end;
end;

procedure TDatasets.Commit(ADatabase: TEDatabase);
begin
{$IFDEF USE_IB}
  with ADatabase.DefaultTransaction do begin
    try
      if Active then begin
        if (True) then begin
          if InTransaction
          then Commit;
        end;
      end;
    except
    end;
  end;
{$ENDIF}
{$IFDEF USE_BDE}
  try
    with ADatabase do begin
      if (IsSQLBased or (TransIsolation = tiDirtyRead)) and InTransaction then Commit;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  try
    with ADatabase do begin
      // tag of database component relates to the session
      if (TransactionsSupported or (FTransactionDesc[ADatabase.Tag].IsolationLevel = xilDIRTYREAD)) and (InTransaction) then begin
        Commit(FTransactionDesc[ADatabase.Tag]);
      end;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
      Self.RollBack(ADatabase);
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  try
    with ADatabase do begin
      if InTransaction then CommitTrans;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  try
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
end;

procedure TDatasets.Rollback(ADatabase: TEDatabase);
begin
{$IFDEF USE_IB}
  with ADatabase.DefaultTransaction do begin
    try
      if Active then begin
        if InTransaction then Rollback;
      end;
    except
    end;
  end;
{$ENDIF}
{$IFDEF USE_BDE}
  try
    with ADatabase do begin
      if (IsSQLBased or (TransIsolation = tiDirtyRead)) and InTransaction
      then Rollback;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  try
    with ADatabase do begin
      // tag of database component is used for store transaction session 
      if (TransactionsSupported or (FTransactionDesc[Tag].IsolationLevel = xilDirtyRead)) and InTransaction
      then Rollback(FTransactionDesc[Tag]);
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  try
    with ADatabase do begin
      if InTransaction
      then RollbackTrans;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  try
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
end;

procedure TDatasets.StartTransaction(ADatabase: TEDatabase);
begin
{$IFDEF USE_IB}
  with ADatabase.DefaultTransaction do begin
    try
      // if InTransaction then Commit;
      if InTransaction
      then Self.Commit(ADatabase);
      StartTransaction;
    except
    end;
  end;
{$ENDIF}
{$IFDEF USE_BDE}
  try
    with ADatabase do begin
      // if InTransaction then Commit;
      if IsSQLBased or (TransIsolation = tiDirtyRead)
      then StartTransaction;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_DBE}
  try
    with ADatabase do begin
      // if InTransaction then Commit;
      if TransactionsSupported or (FTransactionDesc[Tag].IsolationLevel = xilDirtyRead)
      then StartTransaction(FTransactionDesc[Tag]);
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_ADO}
  try
    with ADatabase do begin
      // if InTransaction then CommitTrans;
      BeginTrans;
    end;
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
{$IFDEF USE_LDAP}
  try
  except
    on E: Exception do begin
      // Start transaction failed
    end;
  end;
{$ENDIF}
end;

procedure TDatasets.ExecSQL(AIndex: Integer);
var
  ds: TDS;
begin
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  try
{$IFDEF USE_IB}
    ds.Database.DefaultTransaction.Active:= True;
    ds.ExecQuery;
    // ds.Transaction.Commit;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
    ds.ExecSQL;
{$ENDIF}
{$IFDEF USE_LDAP}
    // ds.Delete;
{$ENDIF}
  except
  end;
end;

function TDatasets.OpenSQL(AIndex: Integer): Boolean; // Dec 2002
var
  ds: TDS;
begin
  Result:= False;
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  try
{$IFDEF USE_IB}
    ds.Database.DefaultTransaction.Active:= True; // looks like transaction sometimes is closed
    ds.ExecQuery;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
    ds.Open;
{$ENDIF}
{$IFDEF USE_LDAP}
    ds.Open;
{$ENDIF}
    Result:= True;
  except
    {
    on E: Exception do begin
      xy.x:= 0;
      xy.y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, Nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
    }
  end;
end;

function TDatasets.CloseSQL(AIndex: Integer): Boolean; // Dec 2002
var
  ds: TDS;
begin
  Result:= False;
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  try
    ds.Close;
    Result:= True;
  except
    {
    on E: Exception do begin
      xy.x:= 0;
      xy.y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, Nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
    }
  end;
end;

{ DoSetSend
  Purspose
    Set FCookies values (or add new ones) with TObject indicates transport to be send to the user back
  Parameters:
    AProvider: IND_SEND_COOKIE or IND_SEND_MAIL
}

function TDatasets.DoSetSend(AIndex: Integer; const ACommaText: WideString; AProvider: Integer): Integer;
var
  sl: TStrings;
  n, v: string;
  i, p: Integer;
begin
  sl:= TStringList.Create;
  sl.CommaText:= Trim(ACommaText);
  case AProvider of
  IND_SEND_COOKIE: begin
    for i:= 0 to sl.Count - 1 do begin
      n:= sl[i];
      p:= Pos('=', n);
      if p = 0 then begin
        v:= '';
      end else begin
        v:= Copy(n, p + 1, MaxInt);
        n:= Copy(n, 1, p - 1);
      end;
      p:= FParentParser.FCookies.IndexOfName(n);
      if p >= 0 then FParentParser.FCookies.Delete(p); // replace old cookie
      FParentParser.FCookies.AddObject(n + '=' + v, TObject(AProvider));
    end;
  end;
  IND_SEND_MAIL: begin
    // send mail
  end;
  end; { case }
  sl.Free;
end;

{ count records returned in SQL statement.
  SQL Statement can be
    1. SELECT f1, ...
    2. SELECT COUNT(f1) ...
  Second case is prefererable

  Limitations:
    2048 rows is affected in case 1 and no limit in case 2   
}
function TDatasets.CountSQL(AIndex: Integer): Integer; // Dec 2002
const
  SCANLIMIT = 500;
var
  ds: TDS;
begin
  Result:= 0;
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  try
{$IFDEF USE_IB}
  // go to the first row
    while (not ds.EOF) and (Result < SCANLIMIT) do begin
      ds.Next;
      Inc(Result);
    end;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
    while (not ds.EOF) and (Result < SCANLIMIT) do begin
      ds.Next;
      Inc(Result);
    end;
{$ENDIF}
{$IFDEF USE_LDAP}
    Result:= ds.ldapEntryList.Count;
{$ENDIF}
  except
    {
    on E: Exception do begin
      xy.x:= 0;
      xy.y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, Nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
    }
  end;
  // check is it COUNT in First column?
  if (Result = 1) and (ds.Current.Count = 1) then begin // ds.Current.Count = 1 May 18 2007
{$IFDEF USE_IB}
    try
      Result:= ds.Fields[0].AsInt64;
    except
      // still 1
    end;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
    try
      Result:= ds.Fields[0].AsInteger;
    except
      // still 1
    end;
{$ENDIF}
  end;
end;

{ GetSQLRecVal1
  retrieve first record
  Returns
    first attribute of first record in dataset
  Purpose
    used to retrieve default parameter (action="defaultparam")
}

function TDatasets.GetSQLRecVal1(AIndex: Integer): String; // Dec 2002
var
  ds: TDS;
begin
  Result:= '';
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  try
    if ds.EOF then Exit;
{$IFDEF USE_LDAP}
    Result:= ds.Fields[0].ValueList.Text;
{$ELSE}
    Result:= ds.Fields[0].AsString;
{$ENDIF}
  except
    {
    on E: Exception do begin
      xy.x:= 0;
      xy.y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, Nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
    }
  end;
end;

function TDatasets.GetSQLRecVals(AIndex: Integer): string; // Sep 2003
const
  SCANLIMIT = 1024;
var
  ds: TDS;
  cnt: Integer;
begin
  Result:= '';
  if (AIndex < 0) or (AIndex >= Count) then Exit;
  ds:= GetDataSet(AIndex);
  cnt:= 0;
  try
    while (not ds.EOF) and (cnt < SCANLIMIT) do begin

{$IFDEF USE_IB}
      Result:= Result + ds.Fields[0].Value + '=' + ds.Fields[1].Value + #13#10;
{$ENDIF}
{$IFDEF USE_LDAP}
      Result:= Result + ds.Fields[0].ValueList.Text + '=' + ds.Fields[1].ValueList.Text;
{$ELSE}
      Result:= Result + ds.Fields[0].AsString + '=' + ds.Fields[1].AsString + #13#10;
{$ENDIF}
    // go to the first row
      ds.Next;
      Inc(cnt);
    end;
  except
    {
    on E: Exception do begin
      xy.x:= 0;
      xy.y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, Nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
    }
  end;
end;

{ check is database is opened with same parameters
}

function TDatasets.CheckIsSameDbSets(ADatabase: TEDatabase; AParameterList: TStrings): Boolean;
{$IFDEF USE_IB}
var
  s, s1, s2, s3: string;
{$ENDIF}
begin
{$IFDEF USE_LDAP}
  Result:= False;
  Exit;
{$ENDIF}

  Result:= ADatabase.Connected;

  if not Result then Exit; // database is not opened
{$IFDEF USE_BDE}
  Result:= (CompareText(ADatabase.AliasName, AParameterList.Values[STR_DB]) = 0) and
    (CompareText(ADatabase.Params.Values[DBPAR_USERNAME], AParameterList.Values[STR_USER]) = 0) and
    (CompareText(ADatabase.Params.Values[DBPAR_PASSWORD], AParameterList.Values[STR_PASSWORD]) = 0);
{$ENDIF}
{$IFDEF USE_DBE}
  with ADatabase.Params do begin
    Result:= (CompareText(Values[DBPAR_DBXDRIVERAME], AParameterList.Values[STR_DB]) = 0) and
      (CompareText(Values[DBPAR_USERNAME], AParameterList.Values[STR_USER]) = 0) and
      (CompareText(Values[DBPAR_ROLE], AParameterList.Values[STR_ROLE]) = 0) and
      (CompareText(Values[DBPAR_PASSWORD], AParameterList.Values[STR_PASSWORD]) = 0);
  end;
{$ENDIF}
{$IFDEF USE_IB}
  S:= FAdditionalDBAlias.Values[AParameterList.Values[STR_DB]];
  if Length(S) > 0 then begin
      // IB alias exists
    s1:= GetToken(1, ';', S);
    s2:= GetToken(2, ';', S);
    s3:= GetToken(3, ';', S);
  end else begin
    s1:= AParameterList.Values[STR_DB];
    s2:= AParameterList.Values[DBPAR_CP];
    s3:= AParameterList.Values[DBPAR_ROLE];
  end;

  Result:= (CompareText(ADatabase.DatabaseName, s1) = 0) and
    (CompareText(ADatabase.Params.Values[DBPAR_CP], s2) = 0) and
    (CompareText(ADatabase.Params.Values[DBPAR_ROLE], s3) = 0) and
    (CompareText(ADatabase.Params.Values[DBPAR_USERNAME], AParameterList.Values[STR_USER]) = 0) and
    (ADatabase.Params.Values[DBPAR_PASSWORD] = AParameterList.Values[STR_PASSWORD]);
{$ENDIF}
{$IFDEF USE_ADO}
  Result:= CompareText(AParameterList.Values[STR_DB], FConnectionStr) = 0; // ?!!
{$ENDIF}
end;

function TDatasets.GetDataSetByName(const ADataSetName, AExpression, ADatabaseId: String;
  var ADataSet: TDS): Integer;
var
  idx: Integer;
begin
  Result:= IndexOfName(ADataSetName);
  if Result < 0 then begin     // create a new dataset
    // get a database by name passed in opt
    idx:= GetNamedDatabasesIndex(ADatabaseId);
    ADataSet:= TDS.Create(nil);
    with ADataSet do begin
{$IFDEF USE_BDE}
      DatabaseName:= FNamedDatabases[idx].Name; // FNamedDatabases[idx].Name - equil ''. I dont know why;
      SessionName:= FNamedDatabases[idx].SessionName;
      CachedUpdates:= False;
{$ENDIF}
{$IFDEF USE_DBE}
      SQLConnection:= FNamedDatabases[idx];
      // TransactionLevel:= ;
{$ENDIF}
{$IFDEF USE_ADO}
      Connection:= FNamedDatabases[idx];
{$ENDIF}
{$IFDEF USE_IB}
      // GoToFirstRecord:= True;
      // ParamCheck:= True;
      Database:= FNamedDatabases[idx];
      Transaction:= Database.DefaultTransaction;
{$ENDIF}
{$IFDEF USE_LDAP}
      Host:= FNamedDatabases[idx].Host;
      Port:= FNamedDatabases[idx].Port;
      BindDN:= FNamedDatabases[idx].BindDN;
      BindPwd:= FNamedDatabases[idx].BindPwd;
      BaseDN:= FNamedDatabases[idx].BaseDN;
      Scope:= FNamedDatabases[idx].DefaultScope;
{$ENDIF}
    end;
    Result:= AddObject(ADataSetName + '=' + AExpression, ADataSet);  // AExpression
  end else begin
    // datase already exists
    ADataSet:= DataSets[Result];
  end;
end;

// find out index of database by the name
function TDatasets.GetNamedDatabasesIndex(const ADatabaseId: String): Integer;
var
  i: Integer;
begin
  Result:= 0; // default database
  if Length(ADatabaseId) = 0
  then Exit;
  for i:= 1 to Length(FNamedDatabases) - 1 do begin
    if Assigned(FNamedDatabases[i]) then begin
      if CompareText(FNamedDatabases[i].Name, ADatabaseId) = 0 then begin
        Result:= i;
        Exit;
      end;
    end;
  end;
end;

function TDatasets.OpenDbConn(const ADatabaseIdentifier, ADbConnStr, AOptions: String;
  var ADbCodePage: Integer): Boolean;
var
  sl: TStrings;
  s: String;
  i, L: Integer;
  xy: TPoint;
  cont: Boolean;
  idx: Integer;
{$IFDEF USE_ADO}
  conn: TStrings;
  connstr: String;
{$ENDIF}
  dbCP: String;

{$IFDEF USE_IB}
  procedure GetDbCodePage;
  begin
    S:= FAdditionalDBAlias.Values[sl.Values[STR_DB]];
    if Length(S) > 0
    then dbcp:= GetToken(2, ';', S)
    else dbcp:= sl.Values[DBPAR_CP];
    if CompareText(dbcp, 'UTF8') = 0
    then ADbCodePage:= CP_UTF8
    else ADbCodePage:= CP_ACP;
  end;
{$ENDIF}

begin
  Result:= True;
  // dbs=db01;user=SYSDBA;password=CHANGE_ON_INSTALL;
  sl:= TStringList.Create;

  // sl.Delimiter:= ';';   sl.QuoteChar:= '"'; sl.DelimitedText:= expr;
  util1.SetStringsDelimitedTextWithSpace(sl, '"', ';', ADbConnStr);

  idx:= GetNamedDatabasesIndex(ADatabaseIdentifier);
  if (idx = 0) and (Length(ADatabaseIdentifier) > 0) then begin // check is the database name (alias) exists
    // need to create a new named database connection or override existing
    // database name NOT exists, so create new one
    idx:= Length(FNamedDatabases);
    SetLength(FNamedDatabases, idx + 1);
    // make sure is new element is Nil. Just in case
    FNamedDatabases[idx]:= Nil;
    CreateDatabase(FNamedDatabases[idx], ADatabaseIdentifier);
  end;

  try
    if CheckIsSameDbSets(FNamedDatabases[idx], sl) then begin
      // Open;

      if (ADatabaseIdentifier <> OPT_DBCONT)
      then Self.StartTransaction(FNamedDatabases[idx]); // 2006-05-16 hmm it works?
{$IFDEF USE_IB}
      GetDbCodePage;
{$ENDIF}
      sl.Free;
      Exit;
    end;
    Close(FNamedDatabases[idx]);
{$IFDEF USE_BDE}
    FNamedDatabases[idx].AliasName:= sl.Values[STR_DB];
{$ENDIF}
{$IFDEF USE_DBE}
    FNamedDatabases[idx].DriverName:= sl.Values[DBPAR_DBXDRIVERAME];
    with FNamedDatabases[idx].Params do begin
      Assign(sl);
      i:= IndexOfName(STR_DB);
      if i >= 0 then Delete(i);
      i:= IndexOfName(STR_USER);
      if i >= 0 then Delete(i);
      i:= IndexOfName(STR_PASSWORD);
      if i >= 0 then Delete(i);
    end;

    with FNamedDatabases[idx].Params do begin
      Values[DBPAR_DBXDB]:= sl.Values[STR_DB];
    end;
{$ENDIF}
{$IFDEF USE_IB}
    S:= FAdditionalDBAlias.Values[sl.Values[STR_DB]];
    if Length(S) > 0 then begin
      // IB alias exists
      FNamedDatabases[idx].DatabaseName:= GetToken(1, ';', S);
      GetDbCodePage; // set dbcp
      FNamedDatabases[idx].Params.Values[DBPAR_CP]:= dbcp;
      FNamedDatabases[idx].Params.Values[DBPAR_ROLE]:= GetToken(3, ';', S);
      { set SQL dialect }
      L:= StrToIntDef(GetToken(4, ';', S), -1);
      if (L >= 1) and (FNamedDatabases[idx].SQLDialect <> L)
      then FNamedDatabases[idx].SQLDialect:= L;
      if Length(FNamedDatabases[idx].DatabaseName) = 0 then begin
        FNamedDatabases[idx].DatabaseName:= ADatabaseIdentifier; // as is
      end;
    end else begin
      FNamedDatabases[idx].DatabaseName:= sl.Values[STR_DB];
      { set SQL dialect }
      i:= sl.IndexOfName(STR_SQLDIALECT);
      if i >= 0 then begin
        L:= StrToIntDef(sl.Values[STR_SQLDIALECT], -1);
        if (L >= 1) and (FNamedDatabases[idx].SQLDialect <> L)
        then FNamedDatabases[idx].SQLDialect:= L;
        sl.Delete(i);
      end;
      GetDbCodePage;
      { other parameters }
      FNamedDatabases[idx].Params.Assign(sl);
      // delete 'db', 'user', 'password', 'dialect'
      with FNamedDatabases[idx].Params do begin
        i:= IndexOfName(STR_DB);
        if i >= 0 then Delete(i);
        i:= IndexOfName(STR_USER);
        if i >= 0 then Delete(i);
        i:= IndexOfName(STR_PASSWORD);
        if i >= 0 then Delete(i);
      end;
    end;
{$ENDIF}
{$IFDEF USE_ADO}
// Provider	The name of the provider to use for the connection.
// File name	The name of a file containing connection information.
// Remote Provider	The name of the provider to use for a client-side connection.
// Remote Server	The path name of the server to use for a client-side connection.

    conn:= TStringList.Create;
    with conn do begin
      Delimiter:= ';';
      QuoteChar:= '"';
      FConnectionStr:= sl.Values[STR_DB];
      connstr:= FConnectionStr;
      // delete quotes from conn str
      L:= Length(connstr);
      if (L > 0) and (connstr[1] = '"') then begin
        System.Delete(connstr, 1, 1);
        Dec(L);
        if (L > 0) and (connstr[L] = '"') then System.Delete(connstr, L, 1);
      end;

      // add new username and password
      util1.SetStringsDelimitedTextWithSpace(conn, '"', ';', connstr);
      if Length(sl.Values[STR_USER]) > 0 then Values[DBPAR_USERNAME]:= sl.Values[STR_USER];
      if Length(sl.Values[STR_PASSWORD]) > 0 then Values[DBPAR_PASSWORD]:= sl.Values[STR_PASSWORD];
      connstr:= '';
      for l:= 0 to Count - 1 do begin
        connstr:= connstr + Strings[l] + ';';
      end;
      L:= Length(connstr);
      if L > 0 then System.Delete(connstr, L, 1); // delete last ';'
      FNamedDatabases[idx].ConnectionString:= connstr;
    end;
{$ELSE}
{$IFDEF USE_LDAP}
    with FNamedDatabases[idx] do begin
      Host:= sl.Values[STR_HOST];
      Port:= StrToIntDef(sl.Values[STR_PORT], 389);
      BindDN:= sl.Values[STR_BINDDN];
      BindPwd:= sl.Values[STR_PWD];
      BaseDN:= sl.Values[STR_BASEDN];
    end;
{$ELSE}
    with FNamedDatabases[idx].Params do begin
      Values[DBPAR_USERNAME]:= sl.Values[STR_USER];
      Values[DBPAR_ROLE]:= sl.Values[STR_ROLE];
      Values[DBPAR_PASSWORD]:= sl.Values[STR_PASSWORD];
    end;
{$ENDIF}
{$ENDIF}
    // I hope dataset still closed
    Open(FNamedDatabases[idx]);
    StartTransaction(FNamedDatabases[idx]);
  except
    on E: Exception do begin
      xy.X:= 0;
      xy.Y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, nil, '', xy, Format(ERR_SQLERROR, [E.Message, '--']), Cont); // do not provide ADbConnStr to secure
      Result:= False;
    end;
  end;
  sl.Free;
end;

{
  <serverside>  element evaluates
  Return
    Result 0 - DML operator (select, insert, execute)
           1 - move
           2 - set default parameter
           3 - set default parameters
}

function TDatasets.SetDataSet(const ADataset, AAction, AOptional, ADbsId: String;
  const AExpression: WideString; var AResult: String): Integer;
var
  ds: TDS;
  i, idx: Integer;
  expr: String;
  xy: TPoint;
  cont: Boolean;
  dbCP: Integer;
{$IFDEF USE_IB}
{$ENDIF}
{$IFDEF USE_ADO}
  conn: TStrings;
  connstr: string;
{$ENDIF}
begin
  AResult:= '';
  Result:= 0;
  expr:= util_xml.HTMLExtractEntityStr(AExpression);
  {
  // strip control characters
  expr:= '';
  for i:= 1 to Length(AExpression) do begin
    if AExpression[i] >= #32 then expr:= expr + AExpression[i];
  end;
  }

  if CompareText(AAction, STR_DB) = 0 then begin
    // <serverside action="db" id="interbase1" opt="dbx">$DBS</serverside>
    if not OpenDbConn(ADbsId, expr, AOptional, dbCP)
    then ;
    Exit;
  end;

  idx:= GetDatasetByName(ADataset, expr, ADbsId, ds);
  if ds = Nil
  then Exit; // ?!!

  try
    ds.Close;

    if CompareText(AAction, STR_QUERY) = 0 then begin
      Self.Strings[idx]:= ADataset + '=' + expr; // 2004/01/10
      // include parameters
      // ds.Prepare;
      // -- OpenSQL(idx);
    end;

    if CompareText(AAction, STR_EXECUTE) = 0 then begin
      ds.SQL.Text:= expr;
      ExecSQL(idx);
    end;
    { Dec 2002 }
    if CompareText(AAction, STR_MOVE) = 0 then begin
      ds.SQL.Text:= expr;
      OpenSQL(idx);
      i:= CountSQL(idx);
      if i <= 0 then begin
        Result:= 1;
        AResult:= AOptional;
      end;
      CloseSQL(idx);
    end;
    { Dec 2002 }
    if CompareText(AAction, STR_DEFPARAM) = 0 then begin
      Result:= 2;
      ds.SQL.Text:= expr;
      OpenSQL(idx);
      AResult:= jclUnicode.StringToWideStringEx(GetSQLRecVal1(idx), FParentParser.FDbCodePage); // Windows.CP_ACP
      CloseSQL(idx);
    end;
    { Sep 2003 }
    if CompareText(AAction, STR_DEFPARAMS) = 0 then begin
      Result:= 3;
      ds.SQL.Text:= expr;
      OpenSQL(idx);
      AResult:= jclUnicode.StringToWideStringEx(GetSQLRecVals(idx), FParentParser.FDbCodePage); // Windows.CP_ACP
      CloseSQL(idx);
    end;
    { <serverside action=send opt=cookie|mail> "cookiename1=val1","cookiename2=val2" </serverside>}
    if CompareText(AAction, STR_SEND) = 0 then begin
      if CompareText(AOptional, STR_SENDOPT_COOKIE) = 0 then DoSetSend(idx, AExpression, IND_SEND_COOKIE)
      else if CompareText(AOptional, STR_SENDOPT_MAIL) = 0 then DoSetSend(idx, AExpression, IND_SEND_MAIL);
    end;
  except
    on E: Exception do begin
      xy.X:= 0;
      xy.Y:= 0;
      cont:= True;
      DoReportEvent(rlInternal, nil, '', xy, Format(ERR_SQLERROR, [E.Message, ds.sql.text]), Cont);
    end;
  end;
end;

procedure TDatasets.Delete(Index: Integer);
begin
  if (Index < Count) and (Index >= 0) then Objects[Index].Free;
  inherited Delete(Index);
end;

procedure TDatasets.Clear;
var
  i: Integer;
begin
//  Close;
  i:= Count - 1;
  while i >= 0 do begin
    try
      Objects[i].Free;
    except
    end;
    Dec(i);
  end;

  for i:= 1 to Length(FNamedDatabases) - 1 do begin
    try
      DestroyDatabase(FNamedDatabases[i]);
    except
    end;
  end;

  SetLength(FNamedDatabases, 1); // keep default database live
{$IFDEF USE_DBE}
  // clear array of DBX transaction descriptoprs list
  SetLength(FTransactionDesc, 1);  // keep default database transaction descriptor alive
{$ENDIF}

  FDatabaseNameCount:= 1; // 0 is reserved for default database

  inherited Clear;
end;

{-------------------------------- TXMLDbParser --------------------------------}

constructor TXMLDbParser.Create(ADbParserThreadPool: TDbParserThreadPool; AEnv: Pointer);
var
  FN: array[0..MAX_PATH - 1] of Char;
begin
  inherited Create;
  FEnv:= AEnv;
  FDbCodePage:= Windows.CP_ACP;
  FParent:= ADbParserThreadPool;
  FDatasets:= TDatasets.Create(Self);
  SetString(FModulePath, FN, GetModuleFileName(hInstance, FN, SizeOf(FN)));
  FModulePath:= ExtractFilePath(FModulePath);
  { external variables to replace }
  FVars:= TWideStringList.Create;
  FCookies:= TWideStringList.Create;
  { list of web server directory aliases }
  FAlias:= TStringList.Create;

  AddEntireKey(RGW2SVCALIAS, FAlias);
  AddEntireKey(RGPATH + '\Virtual Roots', FAlias);

  FFuncFmtDllHandle:= 0;
  FFormatDll:= '';

  FOnReport:= nil;
end;

destructor TXMLDbParser.Destroy;
begin
  FAlias.Free;
  FCookies.Free;
  FVars.Free;
  FDatasets.Free;
  inherited Destroy;
end;

procedure TXMLDbParser.Clear;
begin
  FDatasets.Clear;
end;

{ DelFirstLastUrl()
  Purpose:
    find first=xx&last=xx and delete it
}

procedure DelFirstLastUrl(const AFamilyName: string; var AUrl: WideString);
var
  p1, p2, cnt, L: Integer;
begin
  p1:= ANSIPos(AFamilyName + '.first=', AURL);
  if p1 > 0 then begin
    cnt:= PosFrom(p1, '&', AURL);
    if cnt <= 0 then cnt:= Length(AURL);
    Delete(AURL, p1, cnt - p1 + 1);
  end;
  p2:= ANSIPos(AFamilyName + '.last=', AURL);
  if p2 > 0 then begin
    cnt:= PosFrom(p2, '&', AURL);
    if cnt <= 0 then cnt:= Length(AURL);
    Delete(AURL, p2, cnt - p2 + 1);
  end;
  L:= Length(AURL);
  if (L > 0) and (AURL[L] = '&') then Delete(AURL, L, 1)
end;

{ MkPageLine()
  Purpose:
    generate next/prev anchors
    used by CalcSpecialLiterals() called by 'pageline' literal
  Parameters:
    AFirst, ALast - names of $first and $last ariables (usually $first and $last)
  Return
    Result: page list line
}

function TXMLDbParser.MkPageLine(const ADsn: String; const AFirst, ALast: String): WideString;
const
  PAGELINESTART = ' ';
  PAGELINEFINISH = '';
  PAGELINEDELIMITER = ' | ';
  PAGELINELIMIT = 10; // no more than 20 links
var
  pagelineactive, pagelineinactive: ShortString;
  dsidx, RecordQty, PageLineStep,
  p, i, f, l, first, last, cnt, st0, st1, First10, Last10: Integer;
  HasMore: Boolean;
  curUrl, S, ss, get_query: String;
  FormatString: String;
  wfirst, wlast: WideString;
begin
  pagelineactive:= ' %d-%d ';
  pagelineinactive:= '<a href="%s">%d-%d</a>';

  // e.g. loop=dataset1 first="1" last="20" >
  dsidx:= FDatasets.IndexOfName(ADsn);
  if dsidx < 0 then begin
    Result:= '';
    Exit;
  end;

  wfirst:= '$' + AFirst;
  wlast:= '$' + ALast;
  first:= EvaluateVars(wfirst, MASK_VAR_ESCAPESINGLEQUOTE);
  last:= EvaluateVars(wlast, MASK_VAR_ESCAPESINGLEQUOTE);
  // get first and last attributes
  if first < 0
  then f:= 1
  else f:= first;
  if last < 0
  then l:= f + 9
  else l:= last;
  PageLineStep:= l - f + 1;
  if PageLineStep <= 1
  then PageLineStep:= 10;

  Dec(f);
  Dec(l);

  // re-open dataset
  FDatasets.ActiveDataSets[dsidx]:= False;
  ParseSQLParameters(dsidx);
  FDatasets.ActiveDataSets[dsidx]:= True;

  RecordQty:= FDatasets.CountSQL(dsidx);

  cnt:= RecordQty div PageLineStep;

  if (RecordQty mod PageLineStep) <> 0
  then Inc(cnt);

  HasMore:= cnt > PAGELINELIMIT;
  if HasMore then begin
    if f >= (PAGELINELIMIT * PageLineStep) then begin
      // more than 10*10=100
      First10:= (f div PageLineStep) - 1;
      Last10:= PAGELINELIMIT + First10 - 1;
      if Last10 > cnt
      then Last10:= cnt;
    end else begin
      // first hundred
      if f >= (PageLineStep * (PAGELINELIMIT - 1)) then begin
        // last hundred
        First10:= 2;
        Last10:= PAGELINELIMIT + 1;
      end else begin
        // not a last 10 in first 100
        First10:= 1;
        Last10:= PAGELINELIMIT;
      end;
    end;
  end else begin
    First10:= 1;
    Last10:= cnt;
  end;

  // create url
  CurUrl:= MkCurrentUrl(True, True);
  // delete first and last in url if exists
  s:= UpperCase(CurUrl);
  p:= Pos(Uppercase(Afirst), s);
  if p > 0 then begin
    Delete(CurUrl, p, Length(Afirst));
    i:= util1.PosFrom(p, '&', CurUrl);
    if i <= 0
    then i:= MaxInt;
    Delete(CurUrl, p, i - p + 1);
    s:= UpperCase(CurUrl);
  end;
  p:= Pos(Uppercase(Alast), s);
  if p > 0 then begin
    Delete(CurUrl, p, Length(Alast));
    i:= util1.PosFrom(p, '&', CurUrl);
    if i <= 0
    then i:= MaxInt;
    Delete(CurUrl, p, i - p + 1);
  end;

  Result:= PageLineStart;

  for i:= First10 to Last10 do begin
    st0:= (i - 1) * PageLineStep + 1;
    st1:= i * PageLineStep;

    // add a new first and last in url
    S:= curUrl  + '&' + Afirst + '=' + IntToStr(st0) + '&' +
      Alast + '=' + IntToStr(st1);

    if (f + 1 >= st0) and (f + 1 <= st1)
    then Result:= Result + SysUtils.Format(PageLineActive, [st0, st1])
    else Result:= Result + SysUtils.Format(PageLineInActive, [S, st0, st1]);

    if i < cnt
    then Result:= Result + PAGELINEDELIMITER;
  end;
  Result:= Result + PAGELINEFINISH;
end;

{ MkCurrentQuery()
  Purpose:
    generate current query (GET, POST or both)
    called by 'q-get' 'q-post' 'q-combined' literals
  Parameters:
  Return
    Result: current url
  Notes:
    Obtains request-related variables are generated by wdbxml dll:
      _url _host _scriptname _pathinfo _serverport _useragent
}

function TXMLDbParser.MkCurrentQuery(AQuery, AContent: Boolean): WideString; // generate current query/content
var
  i, cnt, q_wo_global: Integer;
  ws: string;
  querypass: Integer; // 0 - start(query), 1 - query finished(server side), 2 - server side finished (post)
begin
  Result:= '';
  querypass:= 0; // start(query)
  // skip request-related variables from url and globals (stored at the end of variables)
  q_wo_global:= FVars.Count;
  if q_wo_global > FGlobalVarsOfs then q_wo_global:= FGlobalVarsOfs;
  for i:= 0 to q_wo_global - 1 do begin
    ws:= FVars[i];
    if Pos('_', ws) = 1 then begin
      querypass:= 1; //  query finished(server side), 2 - server side finished (post)
      Continue;
    end else if querypass = 1 then querypass:= 2;
    if (AQuery and (queryPass = 0)) or (AContent and (queryPass = 2)) then begin
      cnt:= Pos('=', ws);
      if cnt > 0
      then Result:= Result + util1.httpEncode(Copy(ws, 1, cnt - 1), FCharSet = csUTF8) + '=' + util1.httpEncode(Copy(ws, cnt + 1, MaxInt), FCharSet = csUTF8) + '&'
      else Result:= Result + util1.httpEncode(ws, FCharSet = csUTF8) + '&';
    end;
  end;

  cnt:= Length(Result);
  if cnt > 0 then Delete(Result, cnt, 1); // delete last '&'
end;

{ MkCurrentPath()
  Purpose:
    generate current query (GET, POST or both)
    called by 'p-get' 'p-post' 'p-combined' literals
  Parameters:
  Return
    Result: current url
  Notes:
    Obtains request-related variables are generated by wdbxml dll:
      _url _host _scriptname _pathinfo _serverport _useragent
}

function TXMLDbParser.MkCurrentPath(AQuery, AContent: Boolean): WideString; // generate current scriptname, pathinfo, query/content
begin
  Result:= FVars.Values['_scriptname'] + FVars.Values['_pathinfo'] + '?' + MkCurrentQuery(AQuery, AContent);
end;

{ MkCurrentUrl()
  Purpose:
    generate current url (GET and POST together)
    called by 'u-get' 'u-post' 'u-combined' literals
  Parameters:
  Return
    Result: current url
  Notes:
    Request-related variables are generated by wdbxml.dll:
      _url _host _scriptname _pathinfo _serverport _useragent
}

function TXMLDbParser.MkCurrentUrl(AQuery, AContent: Boolean): WideString;
var
  host, serverport: string;
begin
  Result:= '';
  host:= FVars.Values['_host'];
  serverport:= FVars.Values['_serverport'];
  Result:= MkCurrentPath(AQuery, AContent);
  if (Length(host) <= 0) or (host = '/') then begin
  end else begin
    if CompareText(host, 'isapi') = 0
    then Result:= 'ap://' + host + Result
    else Result:= 'http://' + host + ':' + serverport + Result;
  end;
end;

{ CalcSpecialLiterals()
  Purpose:
    search special literals AVarName and replace value of it if found
  Parameters:
    AVarName: literal name
    AEscape:  parameter for MkEscUnesc() (used for return value of AValue)
  Return
    Result: index of special literal (0..) or -1 if not found
    AValue: calculated value of the literal or keep unchanged if literal is not found
}

function TXMLDbParser.CalcSpecialLiterals(const AVarName: string; AEsc: Integer; var AValue: WideString): Integer;
var
  literal: String;
  p1, p2, p3: Integer;
begin
  Result:= -1;
  literal:= LowerCase(AVarName);
  if literal = 'now' then begin
    Result:= 0;
    AValue:= MkEscUnesc(AEsc, DateTimeToStr(Now));
  end else begin
    if literal = 'today' then begin
      Result:= 1;
      AValue:= MkEscUnesc(AEsc, DateToStr(Now));
    end else begin
      if literal = 'time' then begin
        Result:= 2;
        AValue:= MkEscUnesc(AEsc, TimeToStr(Now));
      end else begin
        if literal = 'maxthreads' then begin
          Result:= 3;
          AValue:= IntToStr(-1); // Application.MaxConnections
        end else begin
          { page line }
          if Pos('#pageline#', literal) > 1 then begin
            Result:= 4;
            p1:= Pos('#', literal);
            p2:= util1.PosFrom(p1 + 1, '#', literal);
            p3:= Pos('-', literal);
            if (p1 = 0) or (p2 = 0) or (p3 = 0) then begin
              AValue:= 'ds#pageline#fst-lst';
            end else begin
              AValue:= MkEscUnesc(AEsc, MkPageLine(Copy(literal, 1, p1 - 1),
                Copy(literal, p2 + 1, p3 - p2 - 1),
                Copy(literal, p3 + 1, MaxInt)));
              if Length(AValue) = 0 then begin
                Result:= -1; 
                AValue:= literal;   
              end;
            end;
          end else begin
            { full url }
            if literal = 'copyright' then begin
              Result:= 5;
              AValue:= MkEscUnesc(AEsc, 'http://commandus.com/');
            end else begin
              if Pos('u-', literal) = 1 then begin
                if Pos('g', literal) = 3 then begin // get
                  Result:= 6;
                  AValue:= MkEscUnesc(AEsc, MkCurrentUrl(True, False));
                end else begin
                  if Pos('p', literal) = 3 then begin // post
                    Result:= 7;
                    AValue:= MkEscUnesc(AEsc, MkCurrentUrl(False, True));
                  end else begin // both
                    Result:= 8;
                    AValue:= MkEscUnesc(AEsc, MkCurrentUrl(True, True));
                  end;
                end;
              end else begin
                if Pos('q-', literal) = 1 then begin
                  if Pos('g', literal) = 3 then begin // get
                    Result:= 6;
                    AValue:= MkEscUnesc(AEsc, MkCurrentQuery(True, False));
                  end else begin
                    if Pos('p', literal) = 3 then begin // post
                      Result:= 7;
                      AValue:= MkEscUnesc(AEsc, MkCurrentQuery(False, True));
                    end else begin // both
                      Result:= 8;
                      AValue:= MkEscUnesc(AEsc, MkCurrentQuery(True, True));
                    end;
                  end;
                end else begin
                  if Pos('p-', literal) = 1 then begin
                    if Pos('g', literal) = 3 then begin // get
                      Result:= 9;
                      AValue:= MkEscUnesc(AEsc, MkCurrentPath(True, False));
                    end else begin
                      if Pos('p', literal) = 3 then begin // post
                        Result:= 10;
                        AValue:= MkEscUnesc(AEsc, MkCurrentPath(False, True));
                      end else begin // both
                        Result:= 11;
                        AValue:= MkEscUnesc(AEsc, MkCurrentPath(True, True));
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{ CalcSpecialDatasetLiterals()
  Purpose:
    search special literals AVarName and replace value of it if found
  Parameters:
    AVarName: literal name
    AEscape:  parameter for MkEscUnesc() (used for return value of AValue)
  Return
    Result: index of special literal (0..) or -1 if not found
    AValue: calculated value of the literal or keep unchanged if literal is not found
}

function TXMLDbParser.CalcSpecialDatasetLiterals(const AVarName: string; AEsc: Integer; var AValue: WideString): Integer;
var
  literal: string;
  p1, p2: Integer;
begin
  Result:= -1;
  literal:= LowerCase(AVarName);
  if Pos('rowodd', literal) = 1 then begin
    Result:= 1;
    literal:= Trim(Copy(literal, 7, MaxInt));
    p1:= Pos('#', literal);
    if p1 = 0 then begin
      p1:= Length(literal);
      p2:= 0;
    end else begin
      if p1 > 0
      then literal[p1]:= #32;
      p2:= Pos('#', literal);
      if p2 = 0 then begin
        p2:= Length(literal);
      end;
    end;
    if Odd(FRow_Num)
    then AValue:= MkEscUnesc(AEsc, Copy(literal, p1 + 1, p2 - p1 - 1))
    else AValue:= MkEscUnesc(AEsc, Copy(literal, p2 + 1, Length(literal) - p2));
  end else begin
  end;
end;

procedure TXMLDbParser.SetVars(AValue: TWideStrings);
begin
  FVars.Assign(AValue);
end;

procedure TXMLDbParser.SetCookies(AValue: TWideStrings);
begin
  FCookies.Assign(AValue);
end;

// load page content from the database with specified db connection
function TXMLDbParser.DbLoadContent(const AUrl: WideString; var AContent: WideString;
  const ADbConnectString, AContentSQL, AContentTypeSQL, AContentKey: String): Boolean;
var
  s,
  EncodingName: String;
  idx, Encoding: Integer;
  ds: TDS;
begin
  Result:= False;
  AContent:= '';
  // create database connection
  if not FDatasets.OpenDbConn(OPT_DBCONT, ADbConnectString, '', FdbCodePage) then begin
    Exit;
  end;
  // create data set
  idx:= FDatasets.GetDatasetByName(OPT_DBCONT, AContentSQL, OPT_DBCONT, ds);
  if not Assigned(ds)
  then Exit;
  // try to get content
  FDatasets.CloseSQL(idx);
  ds.SQL.Text:= Format(AContentSQL, [AUrl]);
  if FDatasets.OpenSQL(idx) then begin;
    s:= FDatasets.GetSQLRecVal1(idx);
     //jclUnicode.StringToWideStringEx(FDatasets.GetSQLRecVal1(idx), FDbCodePage); // FDatasets.GetSQLRecVal1(idx); //
    if Length(AContentKey) > 0 then begin
      // Decrypt the Data
      with TCipher_Blowfish.Create(AContentKey, nil) do begin
        try
          Mode:= TCipherMode(cmCTS);
          s:= CodeString(s, paDecode, fmtCOPY);
        finally
          Free;
        end;
      end;
    end;
  end else s:= '';
  FDatasets.CloseSQL(idx);

  // try to get content
  if Length(AContentTypeSQL) > 0 then begin
    ds.SQL.Text:= Format(AContentTypeSQL, [AUrl]);
    if FDatasets.OpenSQL(idx) then begin;
      ContentType:= Trim(jclUnicode.StringToWideStringEx(FDatasets.GetSQLRecVal1(idx), FDbCodePage)); // Trim is used in case of CHAR vs VARCHAR
    end else ContentType:= 'text';
    FDatasets.CloseSQL(idx);
  end;
  {
  if Length(s) = 0 then begin
    // try to load document from file
    s:= util1.File2String(AUrl); // it is potentially dangerous!
  end;
  }
  if Pos('text', ContentType) = 1 then begin
    EncodingName:= GetEncodingName(s);
    Encoding:= CharSetName2Code(EncodingName);
    if Encoding < 0 then begin
      Encoding:= csUTF8;
      EncodingName:= 'utf-8'
    end;
    AContent:= util_xml.CharSet2WideStringLine(Encoding, s, []);
  end else begin
    AContent:= s;
  end;
  Result:= True;
end;

function TXMLDbParser.Parse(AxmlElement: TxmlElement; var AStateValue: WideString): Integer;
begin
  Clear;
  FState:= 0;
  FCharSet:= csUTF8;
  FStateValue:= '';
  Inc(customxml.XMLENV.dbParsing); // counter used by TBracket in CreateText() method 
  AxmlElement.ForEachInOut(OnEachElement, nil);
  Dec(customxml.XMLENV.dbParsing);
  Result:= FState;
  AStateValue:= FStateValue;
  FDatasets.CommitAll;
end;

function TXMLDbParser.Alias2FileName(const AFn: string): string;
begin
  if Pos('..', AFn) > 0 then Result:= '' // return nothing, no '../..'
  else Result:= util1.ConCatAliasPath(FAlias, FModulePath, AFn);
end;

function TXMLDbParser.FormatBlobByDLL(const Adll, AFunc, ASpecifier: String; AFld: TFld): String;
var
  DllName,
  S: String;
  FmtFunc: TFuncFmtDll;
  p: PChar;
  len: Integer;
begin
  Result:= '';
  DllName:= ReplaceExt('dll', Alias2FileName(ADll));
  if not ((FFuncFmtDllHandle <> 0) and (ANSICompareText(DllName, FFormatDll) = 0)) then begin
    FFuncFmtDllHandle:= LoadLibrary(PChar(DllName));
  end;
  if FFuncFmtDllHandle = 0 then begin
    // PathsList[fpFormatDll]:= ''; // no matter
    Result:= Format('No %s found (%s)', [ADll, DllName]);
    Exit;
  end else begin
    FFormatDll:= ADll; // keeping ADLL value is better than DllName
  end;
  // library loaded allready
  @FmtFunc:= GetProcAddress(FFuncFmtDllHandle, PChar(AFunc));
  if not Assigned(FmtFunc) then begin
    Result:= Format('No function %s found in %s(%s)', [AFunc, ADll, DllName]);
    Exit;
  end;
  S:= GetBlob(AFld);
  try
    p:= Nil;
    len:= Length(S);
    if FmtFunc(PChar(S), PChar(ASpecifier), p, len) then begin
      if len > 0 then begin
        SetLength(Result, len);
        Move(p^, Result[1], len);
      end else begin
        Result:= p;
      end;
    end else begin
      if Assigned(p)
      then Result:= Format('BLOB fault "%s", formatter %s of ext %s', [p, AFunc, ADll])
      else Result:= Format('BLOB fault, formatter %s of ext %s', [AFunc, ADll]);
    end;
  except
    on E: Exception do begin
      Result:= Format('Exception "%s", function %s of %s', [E.Message, AFunc, ADll]);
    end;
  end;
end;

{ TGetVarValueCallback callback prototype
  search variables in AxmlElement and replace variables
  if variables is related to dataset
  Parameters
    AEsc:
      escape        0
      unesc         1
      noesc         2
      formatblob    4
      singlequote   $80 escape ' (replace ' to '')
  Returns
    Result:
      not found     False
      found         True
}
function TXMLDbParser.GetVariableValue(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
var
  p, pbracket: Integer;
  blobbracket, blobfunc, blobdll, blobmodifier: String;
  fldn,
  dsn: String;
  errs: WideString;
  ds: TDS;
  Cont: Boolean;
  DataSetIdx,
  FieldIdx: Integer;
  xy: TPoint;
begin
  Result:= False;
  // parse 'dataset.var'
  p:= Pos('.', AVarName);
  if p <= 0 then begin
    // look for predefined variable ready to replace
    p:= FVars.IndexOfName(AVarName);
    if p >= 0 then begin
      AValue:= MkEscUnesc(AEsc, Copy(FVars[p], Length(AVarName) + 2, MaxInt));  // Jun 2004 - AEsc and (not MASK_VAR_ESCAPESINGLEQUOTE
      Result:= True;
      Exit;
    end;
    // try to search special literals
    if CalcSpecialLiterals(AVarName, AEsc, AValue) >= 0 then begin
      Result:= True;
    end;
    // dataset.var - variable or dataset specifier missed; do not parse and skip it
    Exit;
  end;
  dsn:= Copy(AVarName, 1, p - 1);
  // get dataset index
  DataSetIdx:= FDataSets.IndexOfName(dsn);
  if DataSetIdx < 0 then begin
    // dataset.var - variable or dataset specifier missed; do not parse and skip it
    // do not! AValue:= '';
    Exit;
  end;
  // get dataset
  ds:= FDataSets.DataSets[DataSetIdx];
  // get field name, first try find out brackets
  pbracket:= util1.PosFrom(p + 1, '[', AVarName);
  if pbracket > 0
  then fldn:= Copy(AVarName, p + 1, pbracket - p - 1) // array indexes found
  else fldn:= Copy(AVarName, p + 1, MaxInt);
  if not FDataSets.ActiveDataSets[DatasetIdx] then begin
    // dataset is not opened yet
    {
    Result:= True;
    errs:= Format(ERR_DATASETCLOSEDF, [fldn, dsn]);
    DoReportEvent(rlError, Nil, '', xy, PWideChar(errs), Cont);
    }
    Exit;
  end;
  // fill variables
  // try to find out field name in found dataset
{$IFDEF USE_IB}
  FieldIdx:= ds.FieldIndex[fldn];
  // fldExists:= p >= 0;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
  FieldIdx:= ds.FieldDefs.IndexOf(fldn);
{$ENDIF}
{$IFDEF USE_LDAP}
  FieldIdx:= ds.ldapEntryList[ds.Cursor].NameList.IndexOf(fldn);
{$ENDIF}

  if FieldIdx < 0 then begin
    if CalcSpecialDatasetLiterals(fldn, AEsc, AValue) >= 0 then begin
      Result:= True;
      Exit;
    end else begin
      xy.X:= 0;
      xy.Y:= 0;
      cont:= True;
      errs:= Format(ERR_NOFIELD, [fldn, dsn]);
      DoReportEvent(rlError, nil, '', xy, PWideChar(errs), Cont);
      AValue:= '';
      Result:= True; // dataset is correct, but field does not exists
      Exit;
    end;
  end;
  try
{$IFDEF USE_LDAP}
    AValue:= MkEscUnesc(AEsc, TldapAttribute(ds.ldapEntryList[ds.Cursor].NameList.Objects[FieldIdx]).ValueList.Text);
{$ELSE}
    if (AEsc and 4) <= 0
    then AValue:= MkEscUnesc(AEsc, jclUnicode.StringToWideStringEx(ds.Fields[FieldIdx].AsString, FDbCodePage))
    else begin
      if pbracket <= 0
      then AValue:= ds.Fields[FieldIdx].AsString // ?!!
        // jclUnicode.StringToWideStringEx(ds.Fields[FieldIdx].AsString, FDbCodePage)
        // ds.Fields[FieldIdx].AsString
      else begin
        blobbracket:= Copy(AVarName, pbracket + 1, MaxInt);
        p:= Pos(']', blobbracket);
        if p > 0
        then Delete(blobbracket, p, MaxInt);
        p:= Pos('@', blobbracket);
        if p > 0 then begin
          blobfunc:= Copy(blobbracket, 1, p - 1);
          Delete(blobbracket, 1, p);
        end else blobfunc:= '';
        p:= Pos('?', blobbracket);
        if p > 0 then begin
          blobmodifier:= Copy(blobbracket, p + 1, MaxInt);
          blobdll:= Copy(blobbracket, 1, p - 1);
        end else begin
          blobmodifier:= '';
          blobdll:= blobbracket;
        end;
        AValue:= FormatBlobByDLL(blobdll, blobfunc, blobmodifier, ds.Fields[FieldIdx]);
      end;
    end;
{$ENDIF}
    Result:= True;
  except
    xy.X:= 0;
    xy.Y:= 0;
    cont:= True;
    errs:= Format(ERR_CONVERSION, [fldn]);
    DoReportEvent(rlError, nil, '', xy, PWideChar(errs), Cont);
  end;
end;

{ search variables in AxmlElement and replace variables
  if variables is related to dataset. If no, remove it.
  Parameters
    AEsc:
      escape        0
      unesc         1
      noesc         2
      + mask (start with $80)
  Returns
    Result:
      not found     False
      found         True
}

function TXMLDbParser.GetVariableValue0(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
var
  i, pbracket: Integer;
  fldn, dsn: string;
  errs: WideString;
  ds: TDS;
  Cont: Boolean;
  DataSetIdx,
  FieldIdx: Integer;
  xy: TPoint;
begin
  Result:= False;
  // parse 'dataset.var'
  i:= Pos('.', AVarName);
  if i <= 0 then begin
    // look for predefined variable ready to replace
    i:= FVars.IndexOfName(AVarName);
    if i >= 0 then begin
      AValue:= MkEscUnesc(AEsc, Copy(FVars[i], Length(AVarName) + 2, MaxInt));
      Result:= True;
      Exit;
    end;
    // try to search special literals
    if CalcSpecialLiterals(AVarName, AEsc, AValue) >= 0 then begin
      Result:= True;
    end;
    // dataset.var - variable or dataset specifier missed; do not parse and skip it
    Exit;
  end;
  dsn:= Copy(AVarName, 1, i - 1);
  // get dataset index
  DataSetIdx:= FDataSets.IndexOfName(dsn);
  if DataSetIdx < 0 then begin
    // dataset.var - variable or dataset specifier missed; do not parse and skip it
    AValue:= '';
    Exit;
  end;
  // get dataset
  ds:= FDataSets.DataSets[DataSetIdx];
  // get field name, first try find out brackets
  pbracket:= util1.PosFrom(i + 1, '[', AVarName);
  if pbracket > 0
  then fldn:= Copy(AVarName, i + 1, pbracket - i - 1) // array indexes found
  else fldn:= Copy(AVarName, i + 1, MaxInt);
  if not FDataSets.ActiveDataSets[DatasetIdx] then begin
    // dataset is not opened yet
    {
    Result:= True;
    errs:= Format(ERR_DATASETCLOSEDF, [fldn, dsn]);
    DoReportEvent(rlError, Nil, '', xy, PWideChar(errs), Cont);
    }
    Result:= True;
    Exit;
  end;
  // fill variables
{$IFDEF USE_IB}
  FieldIdx:= ds.FieldIndex[fldn];
  // fldExists:= i >= 0;
{$ENDIF}
{$IFDEF USE_BDE_ADO_DBE}
  FieldIdx:= ds.FieldDefs.IndexOf(fldn);
{$ENDIF}
{$IFDEF USE_LDAP}
  FieldIdx:= ds.ldapEntryList[ds.Cursor].NameList.IndexOf(fldn);
{$ENDIF}

  if FieldIdx < 0 then begin
    xy.X:= 0;
    xy.Y:= 0;
    cont:= True;
    errs:= Format(ERR_NOFIELD, [fldn, dsn]);
    DoReportEvent(rlError, nil, '', xy, PWideChar(errs), Cont);
    AValue:= '';
    Result:= True; // dataset is correct, but field does not exists
    Exit;
  end;
  try
{$IFDEF USE_LDAP}
    AValue:= MkEscUnesc(AEsc, TldapAttribute(ds.ldapEntryList[ds.Cursor].NameList.Objects[FieldIdx]).ValueList.Text);
{$ELSE}
    AValue:= MkEscUnesc(AEsc, jclUnicode.StringToWideStringEx(ds.Fields[FieldIdx].AsString, FDbCodePage));
{$ENDIF}
    Result:= True;
  except
    xy.X:= 0;
    xy.Y:= 0;
    cont:= True;
    errs:= Format(ERR_CONVERSION, [fldn]);
    DoReportEvent(rlError, nil, '', xy, PWideChar(errs), Cont);
  end;
end;

function TXMLDbParser.GetCookieValue(const AVarName: string; AEsc: Integer; var AValue: WideString): Boolean;
var
  i: Integer;
  errs: WideString;
  Cont: Boolean;
  xy: TPoint;
begin
  Result:= False;
  // parse 'var'
  i:= Pos('.', AVarName);
  if i <= 0 then begin
    // look for predefined variable ready to replace
    i:= FCookies.IndexOfName(AVarName);
    if i >= 0 then begin
      AValue:= MkEscUnesc(AEsc, Copy(FCookies[i], Length(AVarName) + 2, MaxInt));
      Result:= True;
      Exit;
    end;
    // try to search special literals
    if CalcSpecialLiterals(AVarName, AEsc, AValue) >= 0 then begin
      Result:= True;
      Exit;
    end;
  end;
end;

procedure TXMLDbParser.ParseSQLParameters(ADatasetIndex: Integer);
var
  sql: WideString;
//  errs: WideString; xy: TPoint; cont: Boolean;
begin
  // FDatasets.ActiveDataSets[ADatasetIndex]:= False;
  sql:= FDatasets.SQLTemplate[ADatasetIndex];
  // there are no reason to call EvaluateVars(): all expression here MUST BE evaluated earlier in parent element <.. loop="">
  ExtractAndFillVars(sql, GetVariableValue, MASK_VAR_ESCAPESINGLEQUOTE);
  FDatasets[ADatasetIndex].SQL.Text:= sql;
//DoReportEvent(rlError, Nil, '', xy, PWideChar(sql), Cont);
end;

{ get variables from FDataSetvars
}

procedure TXMLDbParser.OnEachVar(var AxmlElement: TxmlElement);
var
  i: Integer;
  s: WideString;
  mask: Integer;
begin
  for i:= 0 to AxmlElement.Attributes.Count - 1 do begin
    // if AxmlElement.Attributes.Items[i].AttrType = atVData then begin
    s:= AxmlElement.Attributes.Items[i].Value;
    if Length(s) > 0 then begin
      // if one or more variables found, update variable
      { -- Dec 03 2003 }
      mask:= MASK_VAR_ESCAPESINGLEQUOTE;
      {
      if FCharSet = csUTF8
      then mask:= mask or MASK_VAR_UTF8;
      }
      if EvaluateVars(s, mask) >= 0 then AxmlElement.Attributes.Items[i].Value:= s;
    end;
  end;
end;

{ get variables from cookies
}

procedure TXMLDbParser.OnEachCookie(var AxmlElement: TxmlElement);
var
  i, mask: Integer;
  s: WideString;
begin
  for i:= 0 to AxmlElement.Attributes.Count - 1 do begin
    // if AxmlElement.Attributes.Items[i].AttrType = atVData then begin
    s:= AxmlElement.Attributes.Items[i].Value;
    if Length(s) > 0 then begin
      // if one or more cookies found, update variable
      { -- Dec 03 2003  }
      mask:= MASK_VAR_ESCAPESINGLEQUOTE;
      {
      if FCharSet = csUTF8
      then mask:= mask or MASK_VAR_UTF8;
      }
      if EvaluateCookies(s, mask) >= 0 then AxmlElement.Attributes.Items[i].Value:= s;
    end;
  end;
end;

{ get variables from FDataSetvars and REMOVE all closed variables
}

procedure TXMLDbParser.OnEachVar0(var AxmlElement: TxmlElement);
var
  i, mask: Integer;
  s: WideString;
begin
  for i:= 0 to AxmlElement.Attributes.Count - 1 do begin
    // if AxmlElement.Attributes.Items[i].AttrType = atVData then begin
    s:= AxmlElement.Attributes.Items[i].Value;
    if Length(s) > 0 then begin
      // if one or more variables found, update variable
      { -- Dec 03 2003 }
      mask:= MASK_VAR_ESCAPESINGLEQUOTE;
      {
      if FCharSet = csUTF8
      then mask:= mask or MASK_VAR_UTF8;
      }

      if EvaluateVars(s, mask) >= 0 then AxmlElement.Attributes.Items[i].Value:= s;
    end;
  end;
end;

procedure GoToFirstRecord(ADS: TDS; const f: Integer; var rowno: Integer);
begin
{$IFDEF USE_IB}
  ADS.Close;
  ADS.ExecQuery;
  rowno:= 0;
  // go to the first row
  while (not Ads.EOF) and (rowno <> f) do begin
    Ads.Next;
    Inc(rowno);
  end;
{$ELSE}
  Ads.First;
  Ads.MoveBy(f - rowno);
{$ENDIF}
end;

// set var related to invalid dataset to the value ''

procedure TXMLDbParser.OnEachErrorElement(var AxmlElement: TxmlElement);
begin
  OnEachVar0(AxmlElement);
end;

function TXMLDbParser.GetAttributeValue(AxmlElement: TxmlElement; const AAttrName: string; AMaskVar: Integer): WideString;
begin
  Result:= AxmlElement.Attributes.ValueByName[AAttrName];
  EvaluateVars(Result, AMaskVar);
end;

{ return
    0  if expression have variables
    1  if expression is evaluated
    -1 if no changes are made
}

function TXMLDbParser.EvaluateVars(var ws: WideString; AMaskVar: Integer): Integer;
var
  vl, errp: Integer;
begin
  Result:= -1;
  if Length(ws) > 0 then begin
    // if one or more variables found, update variable
    if ExtractAndFillVars(ws, GetVariableValue, AMaskVar) > 0 then Result:= 0;

    case Length(ws) of
      0: Exit; // empty string '' is not a valid formulas
      1: Result:= StrToIntDef(ws, 0);
      else begin
        if ws[1] = '='  then begin
          Delete(ws, 1, 1);
          vl:= EvalSafeInt(ws, errp);
          if errp = 0 then begin
            ws:= IntToStr(vl);
            Result:= 1;
          end else ws:= '=' + ws;
        end else begin
          Result:= StrToIntDef(ws, 0);
        end;
      end; // else
    end; // case    
  end;
end;

{ return
    0  if expression have variables
    1  if expression is evaluated
    -1 if no changes are made
}

function TXMLDbParser.EvaluateCookies(var ws: WideString; AMaskVar: Integer): Integer;
var
  vl, errp: Integer;
begin
  Result:= -1;
  if Length(ws) > 0 then begin
    // if one or more variables found, update variable
    if ExtractAndFillVars(ws, GetCookieValue, AMaskVar) > 0 then Result:= 0;

    if Length(ws) <= 1 then Exit; // empty string '' is not a valid formulas
    if ws[1] <> '='  then Exit;
    Delete(ws, 1, 1);

    vl:= EvalSafeInt(ws, errp);
    if errp = 0 then begin
      ws:= IntToStr(vl);
      Result:= 1;
    end else ws:= '=' + ws;
  end;
end;

procedure TXMLDbParser.OnEachElement(var AxmlElement: TxmlElement);
var
  Cont: Boolean;
  dsidx: Integer;
  dsn: string;
  expr: WideString;
  f, l: Integer;
  e, p: TxmlElement;
  APClass: TPersistentClass;
  ds: TDS;
  where2insert, oldorder: Integer;
  ElementCopy: TxmlElement;
  ec: TxmlElementCollection;
  errs: WideString;
  Optional, action: string;
  sl: TStrings;

  procedure RmAttr(const AAttrName: string);
  var
    indx: Integer;
  begin
    indx:= AxmlElement.Attributes.IndexOf(AAttrName);
    if indx >= 0 then AxmlElement.Attributes[indx].Value:= '';
  end;

  procedure RmServerSideAttrs;
  begin
    RmAttr(STR_LOOP);
    RmAttr(STR_1ST);
    RmAttr(STR_LAST);
    RmAttr(STR_DBS_ID);
  end;

begin
  if FState <> 0 then Exit;
  Cont:= True;
  if (AxmlElement is TServerSide) then begin // AxmlElement.GetElementName = 'serverside'  (AxmlElement.ClassName = 'serverside' )
    // server side element
    // DoReportEvent(rlHint, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
    //   Format('%s removed', [AxmlElement.Name]), Cont);
    with TServerSide(AxmlElement) do begin
      // [dataset=DATASRC] action=db|query|execute|move|defaultparams
      if not IsEmpty then begin
        // expression stored in pcdata
        expr:= GetAttributeValue(GetNested1ElementByOrder(0, APClass), STR_EXPRESSION, MASK_VAR_ESCAPESINGLEQUOTE);
      end else Expr:= '';
      Optional:= GetAttributeValue(AxmlElement, STR_DRIVER, MASK_VAR_ASIS);

      action:= GetAttributeValue(AxmlElement, STR_ACTION, MASK_VAR_ASIS);

      if (CompareText(Action, STR_DB) = 0) then begin
        if Length(Optional) = 0
        then Optional:= STR_CURDRIVER;

        if (CompareText(Optional, STR_CURDRIVER) <> 0) then begin
          errs:= Format(ERR_WRONGDBDRIVER, [Optional]);
          DoReportEvent(rlInternal, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
            PWideChar(errs), Cont);
        end;
      end;

      EvaluateVars(expr, MASK_VAR_ESCAPESINGLEQUOTE);
      f:= FDatasets.SetDataSet(
        GetAttributeValue(AxmlElement, STR_DATASET, MASK_VAR_ASIS),
        action, Optional,
        GetAttributeValue(AxmlElement, STR_DBS_ID, MASK_VAR_ASIS),
        expr, FStateValue);
      case f of
        1: FState:= 1; // move
        2: begin // set default parameter
           // add variable var if not exists
            f:= FVars.IndexOfName(Optional);
            if f < 0 then begin
              Inc(FGLobalVarsOfs);
              if FGLobalVarsOfs >= FVars.Count
              then FVars.AddObject(Optional + '=' + Trim(FStateValue), nil)
              else FVars.InsertObject(FGLobalVarsOfs, Optional + '=' + Trim(FStateValue), nil);
            end;
          end;
        3: begin // set default parameters
           // add variables var if not exists
            sl:= TStringList.Create;
            sl.Text:= FStateValue;
            for l:= 0 to sl.Count - 1 do begin
              f:= FVars.IndexOfName(sl.Names[l]);
              if f < 0 then begin
                Inc(FGLobalVarsOfs);
                if FGLobalVarsOfs >= FVars.Count
                then FVars.AddObject(Trim(sl[l]), nil)
                else FVars.InsertObject(FGLobalVarsOfs, Trim(sl[l]), nil);
              end;
            end;
            sl.Free;
          end;
      end;
      AxmlElement.Free; // ---BUGBUG
      AxmlElement:= nil;
    end;
    // end serverside
  end else begin
    // NOT a serverside or bracket element
    if (AxmlElement is TxmlComment) then begin
      // comment element
      expr:= GetAttributeValue(AxmlElement, STR_COMMENTATTR, MASK_VAR_ASIS);
      EvaluateVars(expr, MASK_VAR_ESCAPESINGLEQUOTE);
      AxmlElement.Attributes.ValueByName[STR_COMMENTATTR]:= expr;
      // end comment
    end else begin
      // NOT a serverside or comment
      with AxmlElement do begin
        if AxmlElement is TXMLDesc then begin
          FCharSet:= CharSetName2Code(AxmlElement.Attributes.ValueByName['encoding']);
        end;
        // e.g. loop="dataset1" first="1" last="20" >
        dsn:= GetAttributeValue(AxmlElement, STR_LOOP, MASK_VAR_ASIS);
        dsidx:= FDatasets.IndexOfName(dsn);
        if Length(dsn) = 0 then begin
  //      ForEachInOut(OnEachVar, Nil);
          Exit;
        end;
        if (dsidx < 0) then begin
          if dsn = STR_GLOBAL then begin
            // remove all server extensions attributes
            RmServerSideAttrs;
            AxmlElement.ForEachInOut(OnEachVar, nil);
            // Nov 29 2003 -- globals now inludes cookies
            AxmlElement.ForEachInOut(OnEachCookie, nil);
          end else begin
            if dsn = STR_COOKIE then begin
              // remove all server extensions attributes
              RmServerSideAttrs;
              AxmlElement.ForEachInOut(OnEachCookie, nil);
            end else begin
              errs:= Format(ERR_MISSEDDATASET, [GetAttributeValue(AxmlElement, STR_LOOP, MASK_VAR_ASIS)]);
              DoReportEvent(rlError, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
                PWideChar(errs), Cont);
            end;
          end;
        end else begin
          // dsidx >= 0
          ds:= FDatasets.DataSets[dsidx];
          // get first and last attributes
          f:= StrToIntDef(GetAttributeValue(AxmlElement, STR_1ST, MASK_VAR_ASIS), 1);
          l:= StrToIntDef(GetAttributeValue(AxmlElement, STR_LAST, MASK_VAR_ASIS), 0);
          Dec(f);
          Dec(l);
          // re-open dataset
          FDatasets.ActiveDataSets[dsidx]:= False;
          ParseSQLParameters(dsidx);
          FDatasets.ActiveDataSets[dsidx]:= True;

          // remove all server extensions attributes
          RmServerSideAttrs;
          // if not, report error

          if not FDatasets.ActiveDataSets[dsidx] then begin
            // insert empty element
            p:= AxmlElement.ParentElement;
            if not Assigned(p) then Exit;
            // fill first element
            AxmlElement.ForEachInOut(OnEachErrorElement, nil);
            AxmlElement.ForEachInOut(OnEachVar, nil);

            // send error notification
            errs:= Format(ERR_DATASETCLOSED, [GetAttributeValue(AxmlElement, STR_LOOP, MASK_VAR_ASIS)]);
            DoReportEvent(rlError, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
              PWideChar(errs), Cont);
            Exit;
          end;

          // go to the specified row
          GoToFirstRecord(ds, f, FRow_Num);
          // get parent element
          p:= AxmlElement.ParentElement;
          if not Assigned(p) then begin
            // DoReportEvent(rlError, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
            //   Format(ERR_MISSEDDATASET, [GetAttributeValue(AxmlElement, STR_LOOP)]), Cont);
            Exit;
          end;
          try
            // copy element to local variable
            ElementCopy:= AxmlElement.Copy;
            where2insert:= AxmlElement.Index; // AxmlElement.Order;
            oldorder:= AxmlElement.Order;
            // get collection
            ec:= TxmlElementCollection(AxmlElement.Collection); // or ec:= p.NestedElements.GetByClass(AxmlElement.ClassType);
            if ds.Eof then begin
              AxmlElement.Free;
              AxmlElement:= nil;
            end else begin
              // fill first element
              // ...
              AxmlElement.ForEachInOut(OnEachElement, nil);
              AxmlElement.ForEachInOut(OnEachVar, nil);
              // go to the next row
              ds.Next;
              Inc(FRow_Num);  // Dec 11 2003
            end;
            Inc(l);  // Dec 11 2003
            // process all others rows if exists
            while (FRow_Num <> l) do begin
              if ds.EOF then Break;
              Inc(where2insert);
              // reorder elements
              TxmlElementCollection(AxmlElement.Collection).ReOrder(oldorder + 1);
              // add new element
              e:= ec.Add;

              // create all nested elements and assign their attributes
              e.Assign(ElementCopy);
              Inc(oldOrder);
              e.Order:= oldorder;
              e.Index:= where2insert;
              // add new elements of class to be copied
              e.ForEachInOut(OnEachElement, nil);
              e.ForEachInOut(OnEachVar, nil);

              if not ds.EOF then begin // can be closed in internal loops
                ds.Next;
                Inc(FRow_Num);
              end;
            end;
            ElementCopy.Collection.Free;
          except
            on E: Exception do begin
              errs:= Format(ERR_SQLERROR, [E.Message, ds.sql.text]);
              DoReportEvent(rlInternal, AxmlElement, '', AxmlElement.DrawProperties.TagXYStart,
                PWideChar(errs), Cont);
              // ds.Close;
            end;
          end; // try
        end; // end else - dsidx >= 0
      end; // with
    end; // end NOT a serverside or comment
  end; // end NOT a serverside
end;

procedure TXMLDbParser.SetOnReport(AValue: TReportEvent);
begin
  // set handler for both
  FOnReport:= AValue;
  FDatasets.OnError:= AValue;
end;

procedure TXMLDbParser.DoReportEvent(ALevel: TReportLevel; AxmlElement: TxmlElement;
  const ASrc: PWideChar; AWhere: TPoint; const ADesc: PWideChar; var AContinueParse: Boolean);
var
  cont: Boolean;
begin
  // look for critical database errors and do close connections
  if ALevel = rlInternal then FDatasets.CheckCriticalDbError(ADesc);
  if Assigned(FOnReport) then begin
    FOnReport(ALevel, AxmlElement, '', 0, AWhere, ADesc, cont, FEnv);
  end;
end;

{------------------------------------------------------------------------------}

{ search for '"var:esc=value", '
  and remove :esc, :noesc characters.
  Objects reflects escape rule (0-escape, 1- unescape, 2-noescape)
}

procedure CheckEscapeSuffixes(AValues: TWideStrings);
var
  i, p1, p2, L: Integer;
  ws: string;
begin
  for i:= 0 to AValues.Count - 1 do begin
    AValues.Objects[i]:= TObject(2); // noescape
    ws:= AValues[i];
    L:= Length(ws);
    p2:= Pos('=', ws);
    if p2 = 0 then p2:= L + 1;
    p1:= Pos(':', ws);
    if (p1 < p2) then begin
      if p1 < L then begin
        case ws[p1 + 1] of
          'E', 'e': AValues.Objects[i]:= TObject(1); // escape
          'U', 'u': AValues.Objects[i]:= TObject(0); // unescape
        end; { case }
      end; { if }
      // delete :esc
      Delete(ws, p1, p2 - p1);
      AValues[i]:= ws;
    end;
  end;
end;

constructor TDbParserThreadPool.Create(ACriticalErrors: PWideChar; AOptions: TParsersOptionSet);
begin
  inherited Create;

  FOptions:= AOptions;
  FGlobalVars:= TWideStringList.Create;
  FCriticalErrors:= TWideStringList.Create;
  FCriticalErrors.CommaText:= ACriticalErrors;
  CheckEscapeSuffixes(FCriticalErrors);

  FThreadPool:= TList.Create;
  FLock:= TCriticalSection.Create;
  FPoolIndex:= 0;
  FMin:= 1;
  FMax:= 32;
  AdjustThreadPool;
  FDefOnReport:= nil;
end;

destructor TDbParserThreadPool.Destroy;
var
  cnt: Integer;
begin
  Clear;
  cnt:= MAX_WAITLOOPS;
  while (FThreadPool.Count > 0) and (cnt > 0) do begin
    Sleep(10);
    Dec(cnt);
  end;
  FLock.Free;
  FThreadPool.Free;
  FCriticalErrors.Free;
  FGlobalVars.Free;
  inherited Destroy;
end;

// return thread handle

function TDbParserThreadPool.DispatchThread(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
  AVars: PWideChar; ACookies: PWideChar; AOnReport: TReportEvent; AContentPassed: TPassContentSet;
  AEnv: Pointer): Integer;
var
  T: TDbParserThread;
  cont: Boolean;
  xy: TPoint;
begin
  FLock.Acquire;
  try
    T:= CreateThread(AOnReport, AEnv);
    if Assigned(T) then with T do begin
      // set source
      FXMLElementSrc:= AXMLElementSrc;
      // set document type
      FDocType:= ADoc;
      // copy vaiables
      LocalVars:= AVars;
      // get cookies
      LocalCookies:= ACookies;

      FContentPassed:= AContentPassed;

      Resume;
      Result:= FThreadID;
    end else begin
      Result:= 0;
      // inform errors occured
      if Assigned(AOnReport) then begin
        cont:= True;
        xy.X:= -1;
        xy.Y:= ThreadCount;
        AOnReport(rlFinishThread, nil, '', 0, xy, '*', cont, AEnv);
      end;
    end;
  finally
    FLock.Release;
  end;
end;

function TDbParserThreadPool.DispatchThread(ADoc: TEditableDoc; AXMLElementSrc: PWideChar;
  AVars: PWideChar; ACookies: PWideChar; AContentPassed: TPassContentSet; AEnv: Pointer): Integer;
begin
  Result:= DispatchThread(ADoc, AXMLElementSrc, AVars, ACookies, FDefOnReport, AContentPassed, AEnv);
end;

function TDbParserThreadPool.RemoveThread(ADbParserThread: TDbParserThread): Boolean;
begin
  FLock.Acquire;
  try
    Result:= FThreadPool.Remove(ADbParserThread) >= 0;
  finally
    FLock.Release;
  end;
  AdjustThreadPool; // Dec 2002
end;

procedure TDbParserThreadPool.AdjustThreadPool;
begin
  FLock.Acquire;
  try
    while FMin > FThreadPool.Count do begin
      FThreadPool.Add(TDbParserThread.Create(Self, Nil, Nil));
    end;
  finally
    FLock.Release;
  end;
end;

procedure TDbParserThreadPool.SetDefOnReport(AValue: TReportEvent);
var
  I: Integer;
begin
  FLock.Acquire;
  try
    for I:= FThreadPool.Count - 1 downto 0 do begin
      if TDbParserThread(FThreadPool[I]).FSuspended
      then TDbParserThread(FThreadPool[I]).FXMLDbParser.OnReport:= AValue;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TDbParserThreadPool.Clear;
var
  I: Integer;
begin
  FLock.Acquire;
  try
    for i:= FThreadPool.Count - 1 downto 0 do with TDbParserThread(FThreadPool[i]) do begin
        Terminated:= True;
        if Suspended then Resume;
      end;
  finally
    FLock.Release;
  end;
end;

function TDbParserThreadPool.CreateThread(AOnReport: TReportEvent; AEnv: Pointer): TDbParserThread;
var
  IndexRef: Integer;
begin
  IndexRef:= FPoolIndex;
  // AdjustThreadPool; // Dec 2002
  repeat
    FPoolIndex:= (FPoolIndex + 1) mod FThreadPool.Count;
    Result:= FThreadPool[FPoolIndex];
  until (FPoolIndex = IndexRef) or Result.Suspended;

  if not Result.Suspended then begin
    if ThreadCount < FMax then begin
      Result:= TDbParserThread.Create(Self, AOnReport, AEnv);
      FThreadPool.Add(Result);
    end
    else Result:= nil;
  end else begin
    // assign new environment
    Result.FEnv:= AEnv;
    // set new OnReport
    Result.FXMLDbParser.OnReport:= AOnReport;
  end;
end;

function TDbParserThreadPool.GetThreadCount: Integer;
begin
  Result:= FThreadPool.Count;
end;

procedure TDbParserThreadPool.SetMin(Value: Integer);
begin
  if FMin <> Value then begin
    if Value < 1 then Value:= 1;
    FMin:= Value;
    AdjustThreadPool;
  end;
end;

procedure TDbParserThreadPool.SetMax(Value: Integer);
begin
  if FMax <> Value then begin
    if FMin > Value then
      Value:= FMin;
    FMax:= Value;
    AdjustThreadPool;
  end;
end;

function TDbParserThreadPool.GetVars: WideString;
begin
  Result:= FGlobalVars.CommaText;
end;

procedure TDbParserThreadPool.SetVars(AValue: WideString);
begin
  FGlobalVars.CommaText:= AValue;
  // search for '"var:esc=value" and remove :esc, :noesc characters.
  CheckEscapeSuffixes(FGlobalVars);
end;

{ TDbParserThread }

function ThreadProc(DbParserThread: TDbParserThread): Integer;
begin
  Result:= 0;
  try
    if not DbParserThread.Terminated then
    try
      DbParserThread.Execute;
    except
      AcquireExceptionObject;
    end;
  finally
    DbParserThread.Free;
    EndThread(Result);
  end;
end;

constructor TDbParserThread.Create(ADbParserThreadPool: TDbParserThreadPool; AOnReport: TReportEvent;
  AEnv: Pointer);
begin
  inherited Create;
  FEnv:= AEnv;
  FSuspended:= True;
  FTerminated:= False;

  // FLocalVars:= TWideStringList.Create;
  FLocalVarsPtr:= nil;
  FLocalCookiesPtr:= nil;

  FXMLDbParser:= TXMLDbParser.Create(ADbParserThreadPool, AEnv);
  // FXMLDbParser.OnReport:= ADbParserThreadPool.FOnReport;
  FXMLDbParser.OnReport:= AOnReport;
  FDbParserThreadPool:= ADbParserThreadPool;

  FHandle:= BeginThread(nil, 0, @ThreadProc, Pointer(Self), CREATE_SUSPENDED, FThreadID);
end;

destructor TDbParserThread.Destroy;
begin
  if Assigned(FDbParserThreadPool) then begin
    FDbParserThreadPool.RemoveThread(Self);
  end;
  FXMLDbParser.Free;
  // FLocalVars.Free;
  inherited Destroy;
end;

{
function TDbParserThread.GetVars: WideString;
begin
  Result:= FLocalVars.CommaText;
end;

procedure TDbParserThread.SetVars(AValue: WideString);
begin
  FLocalVars.CommaText:= AValue;
end;
}

{
  SearchSuffixDbContentVarsInURL

  1. Extract /alias/ from the url if possible
  2. Search for 'dbContentConnect_URL' string in
  Return:
    Result: _SUFFIX if /alias/ was found in
    '' if not found
}
function SearchSuffixDbContentVarsInURL(const APrefix: String; const AUrl: String; AVars: TWideStrings): String;
var
  p: Integer;
  s: String;
begin
  Result:= '';
  if Length(AUrl) = 0
  then Exit;
  if AUrl[1] <> '/'
  then Exit;
  p:= util1.PosFrom(2, '/', AUrl);
  if p <= 0
  then Exit;
  s:= Copy(AUrl, 2, p - 2);
  if AVars.IndexOfName(APrefix + s) >= 0
  then Result:= '_' + s;
end;

procedure TDbParserThread.Execute;
label
  fin;
var
  cont: Boolean;
  xy: TPoint;
  ws,
  StateValue: WideString;
  xmlcontainerClass: TxmlElementClass;
  wct: WideString;
  suffix: String;
  r: Boolean;
begin
  wct:= DEF_CONTENT_TYPE;
  xmlcontainerClass:= nil; // just for compiler warning
  while not Terminated do begin
    Inc(customxml.XMLENV.dbParsing);
    if pcUrl in FContentPassed then begin
      suffix:= SearchSuffixDbContentVarsInURL('dbContentConnect_', FXMLElementSrc, FDbParserThreadPool.FGlobalVars);
      // try to load content from database to the ws (FXMLElementSrc is pointer to data in other application
      //
      with FDbParserThreadPool.FGlobalVars do begin
        r:= FXMLDbParser.DbLoadContent(FXMLElementSrc, ws,
          Values['dbContentConnect' + suffix], Values['dbContentSQL' + suffix],
          Values['dbContentTypeSQL' + suffix], Values['dbContentKey' + suffix]);
        wct:= FXMLDbParser.ContentType;
        if not r then begin
          ws:= '<html><body><h1>' + FXMLElementSrc + ' does not exists.</h1></body></html>';
          // Response.StatusCode:= 404;
          goto fin;
        end;
      end;
    end;
    if pcParse in FContentPassed then begin
      xmlcontainerClass:= TxmlElementClass(xmlsupported.getContainerClassByDoctype(FDocType));
      if not Assigned(xmlcontainerClass) then begin
        if Assigned(FXMLDbParser.OnReport) then begin
          ws:= '';
          cont:= True;
          xy.X:= 0; xy.Y:= 0;
          wct:= FXMLDbParser.ContentType;
          FXMLDbParser.OnReport(rlFinishThread, nil, PWideChar(ws), 0, xy, PWideChar(wct), cont,
            FEnv);
        end;
        goto fin;
      end;

      try
        FxmlCollection:= TxmlElementCollection.Create(xmlcontainerClass, nil, wciOne);
        FxmlCollection.Clear1;

        if pcUrl in FContentPassed
        then xmlparse.xmlCompileText(ws, FXMLDbParser.OnReport, nil, nil,
          FxmlCollection.Items[0], xmlcontainerClass)
        else xmlparse.xmlCompileText(FXMLElementSrc, FXMLDbParser.OnReport, nil, nil,
          FxmlCollection.Items[0], xmlcontainerClass);
        // and add local variables
        if Assigned(FLocalVarsPtr) then begin
          FXMLDbParser.Vars.CommaText:= FLocalVarsPtr;
          CheckEscapeSuffixes(FXMLDbParser.Vars);
        end else FXMLDbParser.Vars.Clear; // BUGBUG ?!! it was FXMLDbParser.Clear. may be FXMLDbParser.Vars.Clear; ?
        // add cookies
        if Assigned(FLocalCookiesPtr) then begin

          FXMLDbParser.Cookies.CommaText:= FLocalCookiesPtr;
          CheckEscapeSuffixes(FXMLDbParser.Cookies);
        end else FXMLDbParser.Cookies.Clear;

        // use global variables ..
        FXMLDbParser.FGLobalVarsOfs:= FXMLDbParser.Vars.Count;
        FXMLDbParser.Vars.AddStrings(FDbParserThreadPool.FGlobalVars);

        xy.x:= FXMLDbParser.Parse(FxmlCollection.Items[0], StateValue);

        ws:= FxmlCollection.Items[0].CreateText(0, [ftAsIs]);
      finally
        // remove cookies or mail in FCookies and set pointer to the storage
        PrepareCookies2Send;
        if Assigned(FXMLDbParser.OnReport) then begin
          cont:= True;
          xy.Y:= 0;
          // instead of FxmlCollection.Items[0] returns cookie pointer,
          wct:= FXMLDbParser.ContentType;
          FXMLDbParser.OnReport(rlFinishThread, TxmlElement(PWideChar(FNewCookieStr)),
            PWideChar(ws), Length(ws), xy, PWideChar(wct), cont, FEnv); // PWideChar(IntToHex(FHandle, 8))
        end;
      end;
      FxmlCollection.Free;
    end else begin
      if Assigned(FXMLDbParser.OnReport) then begin
        cont:= True;
        xy.Y:= 0;
        //
        wct:= FXMLDbParser.ContentType;
        FXMLDbParser.OnReport(rlFinishThread, TxmlElement(PWideChar(FNewCookieStr)),
          PWideChar(ws), Length(ws), xy, PWideChar(wct), cont,
          FEnv);
      end;

    end;
fin:
    Dec(customxml.XMLENV.dbParsing);
    if not Terminated then Suspend;
  end;
end;

procedure TDbParserThread.Suspend;
//var r: DWORD;
begin
  FSuspended:= True;
  //r:=
  SuspendThread(FHandle);
end;

procedure TDbParserThread.Resume;
//var  r: DWORD;
begin
  FSuspended:= False;
  //r:=
  ResumeThread(FHandle);
end;

// remove cookies or mail in FCookies

procedure TDbParserThread.PrepareCookies2Send;
var
  i: Integer;
begin
  // clear up all local cookies
  i:= 0;
  with FXMLDbParser.FCookies do begin
    while i < Count do begin
      if Objects[i] = nil then Delete(i)
      else Inc(i);
    end;
    // after parsing some variables can have :escape, :unesc and :noesc suffixes
    CheckEscapeSuffixes(FXMLDbParser.FCookies);
    // get comma delimited text
    FNewCookieStr:= CommaText;
  end;

  // ACookiePlacement is used for temporary storing data
  // FLocalCookiesPtr:= PWideChar(CookieStr); -- allready done
end;

begin
  customxml.BlockIndent:= 2;
  customxml.TextRightEdgeCol:= -1; // do not wrap long text to the separate lines (right edge)
end.

