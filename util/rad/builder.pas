unit
  builder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls;

type
  TBuilder = class(TComponent)
  private
    FCurElement: TControl;
    FParent: TWinControl;
  published
  public
    constructor Create(AWinControl: TComponent); override;
    destructor Destroy; override;
    procedure MouseMoveCurrentElement(X, Y: Integer);
    procedure SelectElement(AObject: TObject);
    procedure MouseSelectElement(X, Y: Integer);
  end;

implementation

constructor TBuilder.Create(AWinControl: TComponent);
begin
  inherited Create(AWinControl);
  FParent:= TWinControl(AWinControl);
end;

destructor TBuilder.Destroy;
begin
  inherited Destroy;
end;

procedure TBuilder.MouseMoveCurrentElement(X, Y: Integer);
begin
  if Assigned(FCurElement) then begin
    FCurElement.Left:= X;
    FCurElement.Top:= Y;
  end;
end;

procedure TBuilder.SelectElement(AObject: TObject);
begin
  FCurElement:= TControl(AObject);
end;

procedure TBuilder.MouseSelectElement(X, Y: Integer);
var
  i: Integer;
  r: TRect;
begin
  FCurElement:= Nil;
  for i:= 0 to FParent.ControlCount - 1 do begin
    if (FParent.Controls[i] is TControl) then begin
      r:= FParent.Controls[i].BoundsRect;
      if (x >= r.Left) and (x <= r.Right) and (y >= r.Top) and (x <= r.Bottom) then begin
        FCurElement:= FParent.Controls[i];
        Break;
       end;
    end;
  end;
end;

end.
