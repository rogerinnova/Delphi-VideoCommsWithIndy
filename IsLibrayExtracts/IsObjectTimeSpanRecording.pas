{$IFDEF FPC}
{$MODE Delphi}
{$I InnovaLibDefsLaz.inc}
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}
unit IsObjectTimeSpanRecording;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TimeSpan,
  System.Diagnostics;

type

  TObjTimeSpanRecording = Class(Tobject)
  private
    FDataList: TStringList; // Of LifeTimeStats Objs
    Procedure AddCount(AObjClosing: Tobject; ADuration: TTimeSpan);
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
    Class Function SingletonLifeTimeStats: string;
  End;

  TLifeTimeStats = Class(Tobject)
  Private
    FObjectName: string;
    FCount: Integer;
    FMaxSecs, FMinSecs: Double;
    FRunningAverageSecs, FSumOfSquaresSecs: Double;
  Public
    Constructor Create(AName: String);
    Procedure AddData(AClassName: String; ADuration: TTimeSpan);
    Function StatsReport: string;
  End;

implementation

uses IsNavUtils, ISIndyUtils;

{ TLifeTimeStats }

procedure TLifeTimeStats.AddData(AClassName: String; ADuration: TTimeSpan);
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

constructor TLifeTimeStats.Create(AName: String);
begin
  inherited Create;
  FObjectName := AName;
end;

function TLifeTimeStats.StatsReport: string;
Var
  SD: Double;
begin
  if FMaxSecs > 0.0000000000001 then
  Begin
    SD := (CalDoubleStdDevFromSumOfSquares(FSumOfSquaresSecs, FCount));
    Result := FObjectName;
    if SD > 0.0000000001 then
      Result := Result + #13#10' Read ' + FormatFloat('###0.000 Secs',
        FRunningAverageSecs) + ' Max' + FormatFloat('(0.000)', FMaxSecs) +
        ' Min' + FormatFloat('(0.000)', FMinSecs) + ' SD' +
        FormatFloat('(0.00000)', SD)
    Else
      Result := Result + #13#10' Read ' + FormatFloat('###0.000 Secs',
        FRunningAverageSecs) + ' Max' + FormatFloat('(0.000)', FMaxSecs) +
        ' Min' + FormatFloat('(0.000)', FMinSecs);
  End;
end;

{ TObjTimeSpanRecording }
Var
  GlobalRecording: TSingletonObjTimeSpanRecording = nil;

procedure TObjTimeSpanRecording.AddCount(AObjClosing: Tobject;
  ADuration: TTimeSpan);
Var
  Idx: Integer;
  ThisClassObj: TLifeTimeStats;
  ThisClassName: String;
begin
  if AObjClosing = nil then
    Exit;

  ThisClassObj := nil;
  ThisClassName := AObjClosing.ClassName;
  if FDataList.Find(ThisClassName, Idx) then
  Begin
    if FDataList.Objects[Idx] is TLifeTimeStats then
      ThisClassObj := TLifeTimeStats(FDataList.Objects[Idx]);
  End
  else
  Begin
    ThisClassObj := TLifeTimeStats.Create(ThisClassName);
    FDataList.AddObject(ThisClassObj.FObjectName, ThisClassObj);
  End;
end;

constructor TObjTimeSpanRecording.Create;
begin
  inherited;
  FDataList := TStringList.Create; // Of LifeTimeStats Objs
  FDataList.Sorted := true;
  FDataList.OwnsObjects := true;
end;

destructor TObjTimeSpanRecording.Destroy;
begin
  if GlobalRecording <> nil then
    if GlobalRecording = self then
      GlobalRecording := nil;
  FDataList.Free;
  inherited;
end;

function TObjTimeSpanRecording.ObjectLifeTimeStats: string;
Var
  I: Integer;
begin
  Result := 'Object Life Time Stats';
  if (FDataList = nil) or (FDataList.Count < 1) then
    Exit;

  for I := 0 to FDataList.Count - 1 do
    if FDataList.Objects[I] is TLifeTimeStats then
      Result := Result + #13#10 + TLifeTimeStats(FDataList.Objects[I])
        .StatsReport;
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
    GlobalRecording.AddCount(AObjClosing, ADuration);
end;

class function TSingletonObjTimeSpanRecording.SingletonLifeTimeStats: string;
begin
  if GlobalRecording <> nil then
    Result := GlobalRecording.ObjectLifeTimeStats
  Else
    Result := 'No Lifetime Stats Collected';
end;

end.
