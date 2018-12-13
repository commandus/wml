unit
  EMemoUndoRedo;
(*##*)
(*******************************************************************************
*                                                                             *
*   E  M  e  m  o  U  n  D  o  R  e  D  o                                      *
*                                                                             *
*   Copyright © 2004-2004 Andrei Ivanov. All rights reserved.                  *
*   Part of apooed                                                            *
*   Conditional defines:                                                       *
*                                                                             *
*   Revisions    : May 07 2004                                                 *
*   Last revision: May 07 2004                                                *
*   Lines        : 4455                                                        *
*   History      :                                                            *
*                                                                              *
*                                                                             *
********************************************************************************)
(*##*)


interface

uses
  Classes, SysUtils, Windows,
  jclUnicode;

type
  TUndoRedoAction = (urNone, urInsert, urDelete, urReplace, urMove);
  PUndoRedoRec = ^TUndoRedoRec;
  TUndoRedoRec = record
    Action: TUndoRedoAction;
    Point: TPoint;
    Point2: TPoint;
    Len: Integer;
    Value: array[0..0] of WideChar;
  end;

  TUndoRedoManager = class (TObject)
  private
    FDepth: Integer;
    FCmdList: TList;
    FPtr: Integer;
    function GetCanRedo: Boolean;
    function GetCanUndo: Boolean;
  public
    constructor Create(ADepth: Integer);
    destructor Destroy; override;
    procedure AddDo(AUndoRedoAction: TUndoRedoAction; APoint, APoint2: TPoint; const AValue: WideString);
    function Redo(var APoint, APoint2: TPoint; var AValue: WideString): TUndoRedoAction;
    function Undo(var APoint, APoint2: TPoint; var AValue: WideString): TUndoRedoAction;
    property CanRedo: Boolean read GetCanRedo;
    property CanUndo: Boolean read GetCanUndo;
  end;

implementation

constructor TUndoRedoManager.Create(ADepth: Integer);
begin
  inherited Create;
  FDepth:= ADepth;
  FPtr:= -1;
  FCmdList:= TList.Create;
end;

destructor TUndoRedoManager.Destroy;
begin
  FCmdList.Free;
  inherited Destroy;
end;

function TUndoRedoManager.GetCanRedo: Boolean;
begin
  Result:= FPtr < FCmdList.Count - 1;
end;

function TUndoRedoManager.GetCanUndo: Boolean;
begin
  Result:= FPtr >= 0;
end;

procedure TUndoRedoManager.AddDo(AUndoRedoAction: TUndoRedoAction; APoint, APoint2: TPoint; const AValue: WideString);
var
  r: PUndoRedoRec;
  L: Integer;
begin
  L:= Length(AValue);
  GetMem(r, SizeOf(TUndoRedoRec) + L * SizeOf(WideChar)); // + terminated #0
  with r^ do begin
    Action:= AUndoRedoAction;
    Point:= APoint;
    Point2:= APoint2;
    Len:= L;
    Move(AValue[1], Value, L * SizeOf(WideChar));
    // do not enter last #0. What for? Use Len field!
  end;
  FCmdList.Add(r);
  FPtr:= FCmdList.Count - 1; // after AddDo can not ReDo, just UnDo
  while FPtr >= FDepth do begin // fix stack size (remove oldest records)
    FreeMem(FCmdList[0]);
    FCmdList.Delete(0);
    Dec(FPtr);
  end;
end;

function TUndoRedoManager.Undo(var APoint, APoint2: TPoint; var AValue: WideString): TUndoRedoAction;
var
  r: PUndoRedoRec;
begin
  if not CanUndo then begin
    Result:= urNone;
    AValue:= '';
    APoint:= Point(0, 0);
    APoint2:= Point(0, 0);
    Exit;
  end;
  r:= FCmdList[FPtr];
  with r^ do begin
    Result:= Action;
    APoint:= Point;
    APoint2:= Point2;
    SetLength(AValue, Len);
    Move(Value, AValue[1], Len * SizeOf(WideChar));
  end;
  Dec(FPtr);
end;

function TUndoRedoManager.Redo(var APoint, APoint2: TPoint; var AValue: WideString): TUndoRedoAction;
var
  r: PUndoRedoRec;
begin
  if not CanRedo then begin
    Result:= urNone;
    AValue:= '';
    APoint:= Point(0, 0);
    APoint2:= Point(0, 0);
    Exit;
  end;
  Inc(FPtr);
  r:= FCmdList[FPtr];
  with r^ do begin
    Result:= Action;
    APoint:= Point;
    APoint2:= Point2;
    SetLength(AValue, Len);
    Move(Value, AValue[1], Len * SizeOf(WideChar));
  end;
end;

end.
