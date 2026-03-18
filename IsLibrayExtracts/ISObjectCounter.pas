unit ISObjectCounter;

interface

uses
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
  Classes, SysUtils, SyncObjs;

Type

  TCtrReportArray = Array Of String;

Procedure IncObjectCount(AObj: Pointer);
Procedure DecObjectCount(AObj: Pointer);
Function CurrentObjectCount: Integer;
Function ObjectCountWithReset: Integer; // Testing
Procedure TrackObjectTypes;
Function ReportObjectTypes: TCtrReportArray;
Function ObjectTypesAsString: String;
Procedure DisposeOfAndNil(Var AObj: TObject);
Function DecodeInDispose(AObj: TObject): Boolean;
Function DecodeAfterDispose(AObj: TObject): Boolean;
Function DecodeRefCount(AObj: TObject): Integer;

{ AutoRefCount is mandatory with the new generation compiler, this theoretically
  removes the obligation and necessity of managing object lifetimes.
  ( http://docwiki.embarcadero.com/RADStudio/Seattle/en/Automatic_Reference_Counting_in_Delphi_Mobile_Compilers )
  However for any system which has any sort of complex object relationships
  this does not work and the task of making sure objects are freed becomes more
  difficult with ARC than without it.

  More details http://delphinotes.innovasolutions.com.au/posts/checking-object-lifetimes-with-autorefcount
}
implementation

{$IFDEF SOMEDEBUG}

Uses LibTstNewCrossPlatformObjs;
{$ENDIF}

type
  TSortedPointerList = class(TObject)
  private
    FList: TList;
    FLock: TCriticalSection;
    constructor Create;
    destructor Destroy; override;
    function GetItem(index: Integer): Pointer;
    procedure PutItem(index: Integer; const Value: Pointer);
    // function IndexOf(Item: Pointer): Integer;
    function DropObject(AItem: Pointer): Boolean;
    function FindObject(AItem: Pointer; out ALocation: Integer): Boolean;
    function Add(Item: Pointer): Integer;
    function Count: Integer;
  public
    property Items[index: Integer]: Pointer read GetItem write PutItem; default;
  end;

  { TSortedPointerList }

function TSortedPointerList.Add(Item: Pointer): Integer;
var
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
  P: TObject;
  Count: Integer;
{$ENDIF}
{$ENDIF}
  LocIndex: Integer;
begin
  Result := -1;
  Try
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
    if Item <> nil then
      Count := DecodeRefCount(TObject(Item));
{$ENDIF}
{$ENDIF}
    if FLock <> nil then
      FLock.Acquire;
    try
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
      if Item <> nil then
        Count := TObject(Item).RefCount;
{$ENDIF}
{$ENDIF}
      if not FindObject(Item, LocIndex) then
        FList.Insert(LocIndex, Item);
      Result := LocIndex;
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
      if Item <> nil then
        Count := DecodeRefCount(TObject(Item));
{$ENDIF}
{$ENDIF}
    finally
      if FLock <> nil then
        FLock.Release;
    end;

{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
    if Item <> nil then
      Count := DecodeRefCount(TObject(Item));
{$ENDIF}
{$ENDIF}
  Except
    // Do not crash if problem
  End;
end;

function TSortedPointerList.Count: Integer;
begin
  Result := FList.Count;
end;

constructor TSortedPointerList.Create;
begin
  FList := TList.Create;
  FLock := TCriticalSection.Create;
end;

destructor TSortedPointerList.Destroy;
begin
  FList.Free;
  FLock.Free;
  inherited;
end;

function TSortedPointerList.DropObject(AItem: Pointer): Boolean;
var
  LocIndex: Integer;
begin
  Result := false;
  Try
    if FLock <> nil then
      FLock.Acquire;
    try
      Result := true;
      if FindObject(AItem, LocIndex) then
        FList.Delete(LocIndex)
      else
        Result := false;
    finally
      if FLock <> nil then
        FLock.Release;
    end;
  Except
  End; // Do not crash if Problem
end;

function TSortedPointerList.FindObject(AItem: Pointer;
  out ALocation: Integer): Boolean;
var
  HighIdx, LowIdx, TstIdx: Integer;
  PLow, Phigh, PTest: Pointer;
begin
  if FLock <> nil then
    FLock.Acquire;
  try
    ALocation := 0;
    Result := false;
    HighIdx := FList.Count - 1;
    if HighIdx < 0 then
      exit;

    ALocation := -1;
    LowIdx := 0;
    PLow := FList[LowIdx];
    if (HighIdx = 0) or (PLow = AItem) then
    begin
      ALocation := 0;
      Result := PLow = AItem;
      if not Result and (Integer(PLow) < Integer(AItem)) then
        Inc(ALocation);
    end
    else
    begin
      Phigh := FList[HighIdx];
      if (Phigh = AItem) then
      begin
        ALocation := HighIdx;
        Result := true;
      end
      else if (Integer(Phigh) < Integer(AItem)) then
        ALocation := HighIdx + 1;
    end;

    while ALocation < 0 do
      if HighIdx = (LowIdx + 1) then
        ALocation := LowIdx + 1
      else
      begin
        TstIdx := (HighIdx + LowIdx) div 2;
        PTest := FList[TstIdx];
        Result := PTest = AItem;
        if Result then
          ALocation := TstIdx
        else if Integer(PTest) > Integer(AItem) then
          HighIdx := TstIdx
        else
          LowIdx := TstIdx;
      end;
  finally
    if FLock <> nil then
      FLock.Release;
  end;
end;

function TSortedPointerList.GetItem(index: Integer): Pointer;
begin
  Result := FList[index];
end;

{ function TSortedPointerList.IndexOf(Item: Pointer): Integer;
  var
  LocIndex: Integer;
  begin
  if FindObject(Item, LocIndex) then
  Result := (LocIndex)
  else
  Result := -1;
  end;
}
procedure TSortedPointerList.PutItem(index: Integer; const Value: Pointer);
begin
  Add(Value);
end;

Var
  LocalObjectList: TSortedPointerList = nil;
  LeftOverArray: TCtrReportArray;
  LocalObjectCount: Integer = 0;

Procedure IncObjectCount(AObj: Pointer);
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
Var
  Count: Integer;
{$ENDIF}
{$ENDIF}
Begin
  Inc(LocalObjectCount);
  if LocalObjectList = nil then
    exit;
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
  if AObj <> nil then
    Count := TObject(AObj).RefCount;
{$ENDIF}
{$ENDIF}
  LocalObjectList.Add(AObj);
{$IFDEF DEBUG}
{$IFDEF AutoRefCount}
  if AObj <> nil then
    Count := TObject(AObj).RefCount;
{$ENDIF}
{$ENDIF}
End;

Procedure DecObjectCount(AObj: Pointer);
Begin
  Dec(LocalObjectCount);
  if LocalObjectList = nil then
    exit;

  LocalObjectList.DropObject(AObj);
End;

Function CurrentObjectCount: Integer;
begin
  Result := LocalObjectCount;
end;

Function ObjectCountWithReset: Integer; // Testing
begin
  Result := LocalObjectCount;
  if LocalObjectList <> nil then
  begin
    LocalObjectList := nil;
    TrackObjectTypes;
  end;
  LocalObjectCount := 0;
end;

{ private }
const
  objDestroyingFlag = Integer($80000000);
  objDisposedFlag = Integer($40000000);

Function DecodeRefCount(AObj: TObject): Integer;
begin
  if AObj = nil then
    Result := 0
  Else
    Result :=
{$IFDEF AUTOREFCOUNT}
      (AObj.RefCount and not(objDisposedFlag or objDestroyingFlag))
{$ENDIF}
      - 1; // function adds one
end;

Function DecodeAfterDispose(AObj: TObject): Boolean;
begin
  if AObj = nil then
    Result := true
  Else
{$IFDEF AUTOREFCOUNT}
    Result := (AObj.RefCount and objDisposedFlag) > 0;
{$ELSE}
    Result := true;
{$ENDIF}
end;

Function DecodeInDispose(AObj: TObject): Boolean;
begin
  if AObj = nil then
    Result := false
  Else
{$IFDEF AUTOREFCOUNT}
    Result := (AObj.RefCount and objDestroyingFlag) > 0;
{$ELSE}
    Result := false;
{$ENDIF}
end;

Procedure DisposeOfAndNil(Var AObj: TObject);

Var
  P: TObject;
{$IFDEF AUTORefCount}
{$IFDEF DEBUG}
  CurCount: Integer;
  s: string;
{$ENDIF}
{$ENDIF}
Begin
{$IFDEF AUTORefCount}
  Try
    if Pointer(AObj) = nil then
      exit;

{$IFDEF DEBUG}
    CurCount := DecodeRefCount(TObject(AObj));
    P := TObject(AObj); // add one
    s := P.ClassName;
    TObject(AObj) := nil; // Sub One
    CurCount := DecodeRefCount(P);
{$ELSE}
    P := TObject(AObj); // add one
    TObject(AObj) := nil; // Sub One
{$ENDIF}
    P.DisposeOf; // still incoming
    P := nil;
  Except
  end;
{$ELSE}
  FreeAndNil(AObj);
  P := nil;
  AObj := P;
{$ENDIF}
End;

Procedure TrackObjectTypes;
Begin
  if LocalObjectList <> nil then
    exit;

  LocalObjectList := TSortedPointerList.Create;
End;

Function ObjectTypesAsString: String;
Var
  ReportTypes: TCtrReportArray;
  i: Integer;
  s: String;
begin
  s := '';
  if LocalObjectCount > 0 then
  Begin
    ReportTypes := ReportObjectTypes;
    for i := 0 to High(ReportTypes) do
      s := s + ':' + ReportTypes[i];
  end;
  Result := s;
end;

Function ReportObjectTypes: TCtrReportArray;
Var
  i, RptTotal: Integer;
Begin
  SetLength(Result, 0);
  if LocalObjectList = nil then
    exit;
  RptTotal := LocalObjectList.Count;
  if RptTotal > 20 then
    RptTotal := 20;
  SetLength(Result, RptTotal);
  for i := 0 to RptTotal - 1 do
  Begin
    Try
      if LocalObjectList[i] <> nil then
        Result[i] := TObject(LocalObjectList[i]).ClassName;
{$IFDEF MSWINDOWS}
      OutputDebugString(Pchar(Result[i] + ' Object Created but not Destroyed'));
{$ENDIF}
    Except
      on e: Exception do
      Begin
        Result[i] := 'Object Exception::' + e.message;
        // Do not crash if problem
{$IFDEF MSWINDOWS}
        OutputDebugString(Pchar(Result[i]));
{$ENDIF}
      End;
    End;
  End;
End;

Initialization

Finalization

if LocalObjectCount > 0 then
  LeftOverArray := ReportObjectTypes; // Set Break Here
if LocalObjectList <> nil then
  FreeAndNil(LocalObjectList);
end.
