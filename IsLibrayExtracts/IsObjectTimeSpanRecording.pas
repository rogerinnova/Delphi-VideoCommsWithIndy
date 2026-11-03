{$IFDEF FPC}
{$MODE Delphi}
{ $I InnovaLibDefsLaz.inc }
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}
unit IsObjectTimeSpanRecording;

interface

uses
{$IFDEF FPC}
  SysUtils,
  Classes,
  SyncObjs,
  IsLazTimeSpan,
  // Diagnostics,
{$ELSE}
  System.SysUtils,
  System.Classes,
  // System.Contnrs,
  System.TimeSpan,
  System.Diagnostics,
  System.SyncObjs,
{$ENDIF}
  IsLogging;

type
  TLifeTimeStats = Class;

  TObjTimeSpanRecording = Class(Tobject)
  private
    FLockTSRec: TCriticalSection;
    FDataList: TStringList; // Of LifeTimeStats Objs
    Procedure AddCountData(AObjClosing: Tobject; ADuration: TTimeSpan);
    Procedure AddCreateInfo(AObjCreated: Tobject);
    Procedure WaitTsRecRelease;
    Function WaitTSRecLock: Boolean;
    Function LifeTimeStatsObject(AObjClosing: Tobject): TLifeTimeStats;
  public
    Constructor Create; virtual;
    Destructor Destroy; Override;
    Function ObjectLifeTimeStats: string;
  End;

  TSingletonObjTimeSpanRecording = Class(TObjTimeSpanRecording)
  Public
    Constructor Create; Override;
    Class Procedure RecordObjectLifeTimeOnDestroy(AObjClosing: Tobject;
      ADuration: TTimeSpan);
    Class Procedure RecordObjectOnCreate(AObjCreating: Tobject);
    Class Function SingletonLifeTimeStats: string;
    Class Procedure ReleaseSingletonTimeStats;
  End;

  TLifeTimeStats = Class(Tobject)
  Private
    FLockLTRec: TCriticalSection;
    FObjList: TList;
    FObjectName: string;
    FCount: Integer;
    FMaxSecs, FMinSecs: Double;
    FRunningAverageSecs, FSumOfSquaresSecs: Double;
    Procedure WaitLsRecRelease;
    Function WaitLSRecLock: Boolean;
  Public
    Constructor Create(AName: String);
    Destructor Destroy; override;
    Procedure AddData(ADuration: TTimeSpan);
    Procedure CheckDoubleFree(AObject: Tobject; AAdd: Boolean);
    Function StatsReport: string;
  End;

implementation

uses IsNavUtils, ISIndyUtils;

{ TLifeTimeStats }

procedure TLifeTimeStats.AddData(ADuration: TTimeSpan);
Var
  SampleSeconds: Double;
begin
  inc(FCount);
  SampleSeconds := ADuration.TotalSeconds;
  if SampleSeconds > FMaxSecs then
    FMaxSecs := SampleSeconds;
  if (SampleSeconds < FMinSecs) or (FMinSecs < 0.000000001) then
    FMinSecs := SampleSeconds;
  CalNewDoubleAverageAndSumOfSquares(SampleSeconds, FRunningAverageSecs,
    FSumOfSquaresSecs, FCount);
end;

procedure TLifeTimeStats.CheckDoubleFree(AObject: Tobject; AAdd: Boolean);
Var
  Index: Integer;
  Err: String;
begin
  Err := '';
  if WaitLSRecLock then
    Try
      Index := FObjList.IndexOf(AObject);
      if AAdd then
      Begin
        if Index < 0 then
          FObjList.Add(AObject)
        Else
          Err := 'Object already in Stats';
      End
      else
      Begin
        if Index < 0 then
          Err := 'Object already Freed In Stats'
        Else
          FObjList.Delete(Index);
      End;
    Finally
      WaitLsRecRelease;
    End;
  // Outside lock
  if Err <> '' then
    ApplicationFlagThreadMsg(AObject, Err, True);
  if Err <> '' then
    begin
      Sleep(100);
      raise EAccessViolation.Create('CheckDoubleFree Message::' + err);
    end;
end;

constructor TLifeTimeStats.Create(AName: String);
begin
  inherited Create;
  FObjectName := AName;
  FObjList := TList.Create;
  FLockLTRec := TCriticalSection.Create;
end;

destructor TLifeTimeStats.Destroy;
begin
  FLockLTRec.Free;
  FObjList.Free;
  inherited;
end;

function TLifeTimeStats.StatsReport: string;
Var
  SD: Double;
begin
  if FMaxSecs > 0.0000000000001 then
  Begin
    SD := (CalDoubleStdDevFromSumOfSquares(FSumOfSquaresSecs, FCount));
    Result := #13#10 + FObjectName;
    if SD > 0.0000000001 then
      Result := Result + #13#10 + IntToStr(FCount) + ' Objects Ave Life ' +
        FormatFloat('###0.000 Secs', FRunningAverageSecs) + ' Max' +
        FormatFloat('(0.000)', FMaxSecs) + ' Min' + FormatFloat('(0.000)',
        FMinSecs) + ' SD' + FormatFloat('(0.00000)', SD)
    Else
      Result := Result + #13#10 + IntToStr(FCount) + ' Objects Ave Life ' +
        FormatFloat('###0.000 Secs', FRunningAverageSecs) + ' Max' +
        FormatFloat('(0.000)', FMaxSecs) + ' Min' + FormatFloat('(0.000)',
        FMinSecs);
  End;
end;

function TLifeTimeStats.WaitLSRecLock: Boolean;
var
  Count: Integer;
begin
  Result := false;
  Count := 5;
  While Not Result and (Count > 0) do
  Begin
    Result := FLockLTRec.TryEnter;
    if Not Result then
    Begin
      Dec(Count);
      Sleep(200);
    End;
  End;
  if not Result then
    ApplicationFlagThreadMsg(self, 'No Lock on TLifeTimeStats', True);
end;

procedure TLifeTimeStats.WaitLsRecRelease;
begin
  FLockLTRec.Release;
end;

{ TObjTimeSpanRecording }
Var
  GlobalRecording: TSingletonObjTimeSpanRecording = nil;

procedure TObjTimeSpanRecording.AddCountData(AObjClosing: Tobject;
  ADuration: TTimeSpan);
Var
  ThisClassObj: TLifeTimeStats;

begin
  if AObjClosing = nil then
    Exit;
  ThisClassObj := LifeTimeStatsObject(AObjClosing);
  if ThisClassObj <> nil then
    ThisClassObj.AddData(ADuration);
  if ThisClassObj = nil then
    ApplicationFlagThreadMsg(AObjClosing, 'Closing Non created Class', True)
  else
    ThisClassObj.CheckDoubleFree(AObjClosing, false);
end;

procedure TObjTimeSpanRecording.AddCreateInfo(AObjCreated: Tobject);
Var
  ThisClassObj: TLifeTimeStats;

begin
  if AObjCreated = nil then
    Exit;

  ThisClassObj := LifeTimeStatsObject(AObjCreated);

  if ThisClassObj = nil then
    ApplicationFlagThreadMsg(AObjCreated,
      'Object Class Stats Record Fail', True)
  else
    ThisClassObj.CheckDoubleFree(AObjCreated, True);
end;

constructor TObjTimeSpanRecording.Create;
begin
  inherited;
  FDataList := TStringList.Create; // Of LifeTimeStats Objs
  FDataList.Sorted := True;
  FDataList.OwnsObjects := True;
  FLockTSRec := TCriticalSection.Create;
end;

destructor TObjTimeSpanRecording.Destroy;
Var
  Msg: string;
  LogFin: TLogFile;

begin
  if GlobalRecording <> nil then
    if GlobalRecording = self then
    begin
      LogFin := TLogFile.Create(ExceptionLogName, True, 5000000, True, false);
      Try
        Msg := TSingletonObjTimeSpanRecording.SingletonLifeTimeStats;
        LogFin.LogALine('TObjTimeSpanRecording.Destroy'#13#10 + Msg);
      Finally
        LogFin.Free;
        GlobalRecording := nil;
      End;
    end;
  FDataList.Free;
  FLockTSRec.Free;
  inherited;
end;

function TObjTimeSpanRecording.LifeTimeStatsObject(AObjClosing: Tobject)
  : TLifeTimeStats;
Var
  Idx: Integer;
  ThisClassName: String;
begin
  Result := nil;
  ThisClassName := AObjClosing.ClassName;

  If WaitTSRecLock then
    Try
      if FDataList.Find(ThisClassName, Idx) then
      Begin
        if FDataList.Objects[Idx] is TLifeTimeStats then
          Result := TLifeTimeStats(FDataList.Objects[Idx]);
      End
      else
      Begin
        Result := TLifeTimeStats.Create(ThisClassName);
        FDataList.AddObject(Result.FObjectName, Result);
      End;
    Finally
      WaitTsRecRelease;
    End;
end;

function TObjTimeSpanRecording.ObjectLifeTimeStats: string;
Var
  I: Integer;
begin
  Result := #13#10'Object Life Time Stats';
  if (FDataList = nil) or (FDataList.Count < 1) then
    Exit;

  for I := 0 to FDataList.Count - 1 do
    if FDataList.Objects[I] is TLifeTimeStats then
      Result := Result + #13#10 + TLifeTimeStats(FDataList.Objects[I])
        .StatsReport;
end;

function TObjTimeSpanRecording.WaitTSRecLock: Boolean;
var
  Count: Integer;
begin
  Result := false;
  Count := 5;
  While Not Result and (Count > 0) do
  Begin
    Result := FLockTSRec.TryEnter;
    if Not Result then
    Begin
      Dec(Count);
      Sleep(200);
    End;
  End;
  if not Result then
    ApplicationFlagThreadMsg(self, 'No Lock on TObjTimeSpanRecording', True);
end;

procedure TObjTimeSpanRecording.WaitTsRecRelease;
begin
  FLockTSRec.Release;
end;

{ TSingletonObjTimeSpanRecording }

constructor TSingletonObjTimeSpanRecording.Create;
begin
  if GlobalRecording <> nil then
    raise Exception.Create('GlobalRecording exists in Singleton Create');
  inherited;
end;

class procedure TSingletonObjTimeSpanRecording.RecordObjectLifeTimeOnDestroy
  (AObjClosing: Tobject; ADuration: TTimeSpan);
begin
  if GlobalRecording = nil then
    GlobalRecording := TSingletonObjTimeSpanRecording.Create;

  if GlobalRecording <> nil then
    GlobalRecording.AddCountData(AObjClosing, ADuration);
end;

class procedure TSingletonObjTimeSpanRecording.RecordObjectOnCreate
  (AObjCreating: Tobject);
begin
  if GlobalRecording = nil then
    GlobalRecording := TSingletonObjTimeSpanRecording.Create;

  if GlobalRecording <> nil then
    GlobalRecording.AddCreateInfo(AObjCreating);
end;

class procedure TSingletonObjTimeSpanRecording.ReleaseSingletonTimeStats;
begin
  if GlobalRecording <> nil then
    FreeAndNil(GlobalRecording);
end;

class function TSingletonObjTimeSpanRecording.SingletonLifeTimeStats: string;
begin
  if GlobalRecording <> nil then
    Result := GlobalRecording.ObjectLifeTimeStats
  Else
    Result := 'No Lifetime Stats Collected';
end;

Initialization

  ;

Finalization

  ;
if GlobalRecording <> nil then
  TSingletonObjTimeSpanRecording.ReleaseSingletonTimeStats;

end.
