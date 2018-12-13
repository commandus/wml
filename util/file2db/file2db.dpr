program file2db;
(*##*)
(*******************************************************************************
*                                                                             *
*   f  i  l  e  2  d  b                                                        *
*                                                                             *
*   Copyright © 2001-2005 Andrei Ivanov. All rights reserved.                  *
*   utility to load text and blob data to the Interbase/Firebird or any ADO   *
*   database                                                                   *
*                                                                             *
*   Conditional defines:  USE_IB  Ib/Fb database                               *
*                         USE_ADO ADO compliant database                      *
*   Usage: file2db -[?|e|a|x] [Options] File(s)|Mask|Path                      *
*     File list: e.g. file1.txt ..\file2.xml                                  *
*     File mask can include willcards e.g. *.htm                               *
*     Commands:                                                               *
*       e - register program -u "user name" -t "registration code"             *
*       l <field delimiter> - load delimited text. Use f to list fields       *
*       n - add content files to database                                      *
*       x - extract files from database                                       *
*       b <index name> - build index files: .key, .fld, .loc,. wrd             *
*                                                                             *
*     Options:  ? - this screen                                                *
*       s <database connection string file>                                   *
*         or -h <DB> -@ <USER> -k <PWD> -# <DIALECT> -! <ROLE> -w <CODEPAGE>   *
*       t <table> - table name                                                *
*       f <field list> - comma separated list e.g. fld1,"Fld 2"                *
*       u <column name> - url column. Use U to cipher                         *
*       c <column1>{,<column2>} - content column(s). Use C to cipher column    *
*       b <column delimiter type>. NONE or TAB. Default is NONE               *
*       y <column name> - content type column. Use Y to cipher                 *
*       m <prefix> - remove file name prefix                                  *
*       q <prefix> - add file name prefix                                      *
*       z <mime type> - default MIME type(default text/html)                  *
*       i - clear table before add or after extract                            *
*       j <cipher> - cipher key                                               *
*       o <folder> - extract database to folder                                *
*       v - verbose                                                           *
*       r - recurse subfolders                                                 *
*       a - any files, otherwise:' + DEF_EXTENSIONS                           *
*       g - get command line options from QUERY_STRING env. var. <GET>         *
*       p - get command line options from input <POST>                        *
* ADO:  + <0..37> - ADO blob type [16- represents memo]                        *
*          Unknown String Smallint Integer Word Boolean Float Currency BCD    *
*          Date Time DateTime Bytes VarBytes AutoInc Blob Memo Graphic FmtMemo *
*          ParadoxOle DBaseOle TypedBinary Cursor FixedChar WideString        *
*          Largeint ADT Array Reference DataSet OraBlob OraClob Variant        *
*          Interface IDispatch Guid TimeStamp FMTBcd                          *
*                                                                              *
*       1 <1..n> - excel column list (field names row number) [1]             *
*       2 <1..n> - first data row [1]. Excel: 1,2,3.. Text: 1|2                *
*       9 <record delimiter>. [#13#10]                                        *
*       0 - make NULL                                                          *
*                                                                             *
*       d - skip default settings (don't load file2db.ini)';                   *
*                                                                             *
*   Revisions    :                                                             *
*   Last revision: Oct 25 2005                                                *
*   Lines        : 75                                                          *
*   History      :                                                            *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)

{$APPTYPE CONSOLE}
{$R *.res}    
{ TODO -oUser -cConsole Main : Insert code here }
uses
  SysUtils,
  file2db_util;
var
  o: Text;
begin
  AssignFile(o, '');
  Rewrite(o);
  Writeln(MSG_COPYRIGHT);
  DoCmd;
  CloseFile(o);
end.
