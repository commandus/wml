unit ememocmd;
(*##*)
(*******************************************************************
*                                                                 *
*   E  M  e  m  o  C  m  d                                         *
*                                                                 *
*   Copyright © 2001, 2002 Andrei Ivanov. All rights reserved.     *
*   memo commands routines implementation                         *
*   Conditional defines:                                           *
*                                                                 *
*   Revisions    : Sep 27 2001                                     *
*   Last revision: Mar 29 2002                                    *
*   Lines        : 83                                              *
*   History      : Base on code of radu@rospotline.com            *
*                                                                  *
*                                                                 *
********************************************************************)
(*##*)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics,
  // Controls, ExtCtrls, StdCtrls,
  Clipbrd,
  EMemo;

{
Action or command

Moves to the beginning of a block
Moves to end of a file
Moves to the end of a line
Moves to the top of the window
Moves to the end of a block
Moves to previous position
Moves to the beginning of a file
Moves to the beginning of a line
Moves to the top of the window
Moves to the bottom of the window
Go to line number

Goes to bookmark
Sets bookmark

Changes a word to lowercase/uppercase

Marks the beginning of a block
Copies a selected block
Hides/shows a selected block
Indents a block by the amount specified in the Block Indent combo box on the General page of the Editor Options dialog box.
Marks the end of a block
Marks the current line as a block
Changes a block to uppercase
Changes a block to lowercase

Prints selected block
Reads a block from a file
Marks a word as a block
Outdents a block by the amount specified in the Block Indent combo box on the General page of the Editor Options dialog box.
Moves a selected block
Writes a selected block to a file
Deletes a selected block

Turns on column blocking
Marks an inclusive block

Turns off column blocking
Marks a line as a block

Selects column-oriented blocks
v	Selects column-oriented blocks

Moves to the beginning of a block
Moves to the end of a block

}
implementation

uses
  util1;

end.
