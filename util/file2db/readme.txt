
	file2db
	=======

This file contains last release notes to help you obtain maximum 
performance from your copy of file2db.

This version is intended for users of Windows 95/98/ME/NT 4.0 
with Service Pack 3 or higher, Windows 2000 with Service Pack 1 or higher, 
Windows XP.

	What's new
	----------

It is version 1.0

	System requirements
	-------------------

To run this program your computer must meet the following minimum requirements:

- Windows 98, ME, NT, 2000, XP;
- 5 MB of available hard disk space;
- installed Firebird/Interbase client.

	Overview
	--------

file2db offers developers an command line tool for import/export text and Excel
files to Firebird or Interbase SQL databases, or any ADO compliant databases

Note that there are two different versions exists:
	- native Interbase/Firebird;
	- ADO (ADO driver is requred to connect to the database)

Refer to the user manual of database you use to obtain information about
restrictions and compatibility with SQL-92 standard for more information.

	Commands
	--------
	l <delimiter> - load delimited text. Use f to list fields
	n <column delimiter> - add content files to database
	x - extract files from database

	Options
	-------
	s <database connection string file>
		or -h <DB> -@ <USER> -k <PWD> -# <DIALECT> -! <ROLE> -w <CODEPAGE>
	t <table> - table name
	f <field list> - comma separated list e.g. fld1,"Fld 2"
	u <column name> - url column. Use U to cipher
	c <column1>{,<column2>} - content column(s). Use C to cipher column
	y <column name> - content type column. Use Y to cipher
	m <prefix> - remove file name prefix
	q <prefix> - add file name prefix
	z <mime type> - default MIME type(default text/html)
	i - clear table before add or after extract
	j <cipher> - cipher key
	o <folder> - extract database to folder
	v - verbose
	r - recurse subfolders
	a - any files, otherwise:.wml.htm.xhtm.xhtml.oeb.pkg.txn.xml.txt.gif.png.jpg.jpeg.tif.tiff.wav.css.xls
	g - get command line options from QUERY_STRING environment variable <GET>
	p - get command line options from input <POST>
	+ <0..n> - ADO blob type [16]
	0 - make NULL
	1 <1..n> - excel column list (field names row number) [1]
	2 <1..n> - first data row [1]. Excel: 1,2,3.. Text: 1|2
	9 <record delimiter>. [#13#10, ^M^J, #$C#$A]
	d - skip default settings (don't load file2db.ini)

Note: Option "+" - used in ADO version only.
Command n <column delimiter> where <column delimiter type> are #9 - tab, ";" or ",".
If not specified, default is none that means load file entirely in one column.
Otherwise, file2db try to split file into pieces (delimiter is not included) and load
them into columns.

	Usage
	-----

Load table from the text or Excel file:

	file2db -L <column delimiter> -f <fields> -9 <line delimiter>

Line delimiter for text files is CR LF sequence, this is default value of line 
delimiter.
Some kind of texts can use other control character sequence. For instance,
1Dh character (<end of file> control symbol) is used in some formats.

Load entire file into BLOB column:
	file2db -N #9 -u <URL> -c <content1>{,<content2>}  -y < content MIME type>

-c lists one or more columns.

Extract data from BLOB columns to the files:
	file2db -X ...

	Database connection options
	---------------------------

There are two different ways to connect to the database:

	- One option -s
	- Set of options -h -@ -k -# -! -w

First case is suitable if you are using OS enviromnent variables passing 
connection string.
Second is more affordable in most cases.
	-h - path to the database server
	-@ - database user, such as SYSDBA
	-k - database user connaction password such as masterkey
	-! - role
Next two options are provided for Firebird/Interbase version only:
	-# - SQL dialect
	-w - connection codepage

For example, this is small chunk of batch code:

...
SET DB=localhost:\src\aims\db\aims.fdb
SET USER=SYSDBA
SET PWD=masterkey

SET DB_OPTS=-h "%DB%" -@ "%USER%" -k "%PWD%" -w "%CP%" -! "%ROLE%" -# %DIALECT%
SET F_CUSTOMER=CNO,CNAME,CINN,CMODIFIER,CCREATED

file2db -L "|" %DB_OPTS% -v -r -i -t customer -f %F_CUSTOMER% customer.txt
...

	Record delimiter option
	-----------------------
Used in -L command. Indicates record delimiter character(s). Defaukt value
is CR LF sequence.

	-9 <record delimiter>. [#13#10, ^M^J, #$C#$A]

Note there are 4 ways to enter characters:
	- enter character such 'A' or '5' as is;
	- enter control characters such as ^A - Chr(1), ^M - Chr(13);
	- enter character in decimal representaion: #9;
	- enter character in hexdecimal representaion: #$9;

	Column delimiter type option
	----------------------------
-b <column delimiter type>
where column delimiter type is one of 
	none - no delimiter
	tab - tabulation
	comma - comma
	semicolon - semicolon

Default is tab.

	N/A -> NULL option 
	------------------

	-0 - enable insert NULL if no data is available

	Cipher options
	--------------

Used in -N command (cipher) and -X command (decipher).
Cipher alghorytm is Blowfish (Bruce Schneier, 1994). 

-j < cipher key>

if no key is provided, defalt key is 'NONE'

To indicate that column data must be cipher o decipher, you must use CAPITAL options: 
-n -U <URL> -C <content1>{,<content2>}  -Y < content MIME type> - enable cipher/decipher
-n -u <URL> -c <content1>{,<content2>}  -y < content MIME type> - disable cipher/decipher

Except -u, -c and -y (-U, -C and -Y), all other options is not case-sensitive.

Loadable files, (commands -L and -N) can be listed using file masks.
In most cases it is useful pass folder name instead of file names, do not
forget enable recurse with -r option.
Please note that relative path is included as file name, and '\' are replaced
to '/' character (it is not a bug, it is feature).

Because folders can contain a lot of files that operation system creates for
internal usage, file2db by default load only files with file name extensions:

.wml	
.htm	
.xhtm
.xhtml	
.oeb	
.pkg	
.txn	
.xml	
.txt	
.gif	
.png	
.jpg	
.jpeg	
.tif	
.tiff	
.wav	
.css	
.xls

If you want to load all other files, enable it with -a option
Option -y (-Y) set column where fil2db stores MIME type of loaded files.
If MIME type is unknown, default MIME type is used- text/html.
Option -z <defaut MIME> changes this value.

Option -2 <line number> indicates line where data is resides.
For instance, text or Excel file contains in line 1 header so you must
use -2 2. By default text files has no header (-2 1) it means data starts
from first line.

For Excel books -1 <line number> options indicates line where column list is.
Default value is 1.
Excel's book can contains more than 1 sheets related to the different tables.
Therefore name of each table must be unique. Please check are there empty
sheets, if they are exists, you must remove them. Note that name of sheet is
used as table name.
It is recommended that you are lists of all columns in each sheet of Excel book.
Therefore -f option is not usable, if -1 option is provided.
Excel sheet cant contains empty cells because file2db search edges first.
To make sure that meaning cells region is find out correctly, provide
 -1 option.
 
-X options controls extraction. Option -o set destination folder. By default,
current folder is used to extraction.

Prefix(-m) Suffix (-q).

	What Firebird is
	----------------

Please refer to the offcial site of Firebird database http://www.firebirdsql.org/

You can download the relevant version from this site free.

	What Interbase is
	-----------------

Please refer to the http://borland.com/

	INSTALLATION
	------------

Read license agreement (file license.txt) first before use of it. 

Note that for Windows NT and Windows 2000 machines, the user logged
in during the installation much have local (machine) administrator
rights.
  
	REGISTRATION
	------------

No registration is required.
   

	Version limitations
	-------------------

You have full version with no any limitations.

	New versions
	------------

I have been constantly improving editor through your feedback. New version 
is available at http://file2db.commandus.com/ for visitors free.

	Contacts
	--------

I appreciate and encourage your feedback.  
Should you have any questions concerning this program, please contact:
mailto:support@commandus.com or send fax (toll free) 1 801 880 0903. 

---------------------------------------------------------------------
file2db, Copyright (c) 2003-2006 by Andrei Ivanov. All rights reserved.