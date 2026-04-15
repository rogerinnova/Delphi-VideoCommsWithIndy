unit IsLazTimeSpan;
{$IFDEF FPC}
{$mode delphi}
{$ELSE}
{$I InnovaLibDefsLaz.inc}
// Only for Lazarus and FPC
  Provides cover for TStopwatch and TTimeSpan
{$ENDIF}
interface
uses Classes,
 BaseUnix, Linux, Time,
 SysUtils;

const
  sTimespanTooLong = 'Timespan too long';
  sInvalidTimespanDuration = 'The duration cannot be returned because the absolute value exceeds the value of TTimeSpan.MaxValue';
  sTimespanValueCannotBeNan = 'Value cannot be NaN';
  sCannotNegateTimespan = 'Negating the minimum value of a Timespan is invalid';
  sInvalidTimespanFormat = 'Invalid Timespan format';
  sTimespanElementTooLong = 'Timespan element too long';

Type
  { TTimeSpan }
  TTimeSpan = record
  private
    FTicks: Int64;
  strict private
    { function GetDays: Integer;
      function GetHours: Integer;
      function GetMinutes: Integer;
      function GetSeconds: Integer;
      function GetMilliseconds: Integer;
      function GetTotalDays: Double;
      function GetTotalHours: Double;
}
      function GetTotalMinutes: Double;
      function GetTotalSeconds: Double;
      function GetTotalMilliseconds: Double;
      class function GetScaledInterval(Value: Double; Scale: Integer): TTimeSpan; static;
    // class constructor Create;
  strict private
  class var
    FMinValue: TTimeSpan { = (FTicks: -9223372036854775808) };
    FMaxValue: TTimeSpan { = (FTicks: $7FFFFFFFFFFFFFFF) };
    FZero: TTimeSpan;
  strict private
  const
    MillisecondsPerTick = 0.0001;
    SecondsPerTick = 1E-07;
    MinutesPerTick = 1.6666666666666667E-09;
    HoursPerTick = 2.7777777777777777E-11;
    DaysPerTick = 1.1574074074074074E-12;
    MillisPerSecond = 1000;
    MillisPerMinute = 60 * MillisPerSecond;
    MillisPerHour = 60 * MillisPerMinute;
    MillisPerDay = 24 * MillisPerHour;
    MaxSeconds = 922337203685;
    MinSeconds = -922337203685;
    MaxMilliseconds = 922337203685477;
    MinMilliseconds = -922337203685477;
  public const
    TicksPerMillisecond = 10000;
    TicksPerSecond = 1000 * Int64(TicksPerMillisecond);
    TicksPerMinute = 60 * Int64(TicksPerSecond);
    TicksPerHour = 60 * Int64(TicksPerMinute);
    TicksPerDay = 24 * TicksPerHour;
  public
     constructor Create(ATicks: Int64); overload;
{     constructor Create(Hours, Minutes, Seconds: Integer); overload;
      constructor Create(Days, Hours, Minutes, Seconds: Integer); overload;
      constructor Create(Days, Hours, Minutes, Seconds, Milliseconds: Integer); overload;
}
      function Add(const TS: TTimeSpan): TTimeSpan; overload;
{      function Duration: TTimeSpan;
      function Negate: TTimeSpan; }
      function Subtract(const TS: TTimeSpan): TTimeSpan; overload;
      /// <summary>Converts the TTimeSpan value into a string</summary>
      function ToString: string;
{      class function FromDays(Value: Double): TTimeSpan; static;
      class function FromHours(Value: Double): TTimeSpan; static;
}
      class function FromMinutes(Value: Double): TTimeSpan; static;
{      class function FromSeconds(Value: Double): TTimeSpan; static;
      class function FromMilliseconds(Value: Double): TTimeSpan; static;
      class function FromTicks(Value: Int64): TTimeSpan; static;
      class function Subtract(const D1, D2: TDateTime): TTimeSpan; overload; static;
      class function Parse(const S: string): TTimeSpan; static;
      class function TryParse(const S: string; out Value: TTimeSpan): Boolean; static;
      class operator Add(const Left, Right: TTimeSpan): TTimeSpan;
      class operator Add(const Left: TTimeSpan; Right: TDateTime): TDateTime;
      class operator Add(const Left: TDateTime; Right: TTimeSpan): TDateTime;
      class operator Subtract(const Left, Right: TTimeSpan): TTimeSpan;
      class operator Subtract(const Left: TDateTime; Right: TTimeSpan): TDateTime;
      class operator Equal(const Left, Right: TTimeSpan): Boolean;
      class operator NotEqual(const Left, Right: TTimeSpan): Boolean;
      class operator GreaterThan(const Left, Right: TTimeSpan): Boolean;
      class operator GreaterThanOrEqual(const Left, Right: TTimeSpan): Boolean;
      class operator LessThan(const Left, Right: TTimeSpan): Boolean;
      class operator LessThanOrEqual(const Left, Right: TTimeSpan): Boolean;
      class operator Negative(const Value: TTimeSpan): TTimeSpan;
      class operator Positive(const Value: TTimeSpan): TTimeSpan;
      class operator Implicit(const Value: TTimeSpan): string;
      class operator Explicit(const Value: TTimeSpan): string;
    }
      property Ticks: Int64 read FTicks;
    { property Days: Integer read GetDays;
      property Hours: Integer read GetHours;
      property Minutes: Integer read GetMinutes;
      property Seconds: Integer read GetSeconds;
      property Milliseconds: Integer read GetMilliseconds;
      property TotalDays: Double read GetTotalDays;
      property TotalHours: Double read GetTotalHours;
}
      property TotalMinutes: Double read GetTotalMinutes;
      property TotalSeconds: Double read GetTotalSeconds;
      property TotalMilliseconds: Double read GetTotalMilliseconds;
    class property MinValue: TTimeSpan read FMinValue;
    class property MaxValue: TTimeSpan read FMaxValue;
    class property Zero: TTimeSpan read FZero;
  end;
  { TStopWatch }
  TStopwatch = record
  strict private
    class var FFrequency: Int64;
    class var FIsHighResolution: Boolean;
    class var TickFrequency: Double;
  strict private
    FElapsed: Int64;
    FRunning: Boolean;
    FStartTimeStamp: Int64;
    function GetElapsed: TTimeSpan;
    function GetElapsedDateTimeTicks: Int64;
    { function GetElapsedMilliseconds: Int64;
    }
    function GetElapsedTicks: Int64;
    class procedure InitStopwatchType; static;
  public
    class function Create: TStopwatch; static;
    class function GetTimeStamp: Int64; static;
    procedure Reset;
    procedure Start;
    class function StartNew: TStopwatch; static;
    procedure Stop;
    property Elapsed: TTimeSpan read GetElapsed;
    { property ElapsedMilliseconds: Int64 read GetElapsedMilliseconds;
    }
    property ElapsedTicks: Int64 read GetElapsedTicks;
    class property Frequency: Int64 read FFrequency;
    class property IsHighResolution: Boolean read FIsHighResolution;
    property IsRunning: Boolean read FRunning;
  end;
implementation
{ TTimeSpan }
function TTimeSpan.Add(const TS: TTimeSpan): TTimeSpan;
var
  NewTicks: Int64;
begin
  NewTicks := FTicks + TS.FTicks;
  if ((FTicks shr 63) = (TS.FTicks shr 63)) and ((FTicks shr 63) <> (NewTicks shr 63)) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  Result := TTimeSpan.Create(NewTicks);
end;

Constructor TTimeSpan.Create(ATicks: Int64);
begin
  FTicks := ATicks;
end;
class function TTimeSpan.FromMinutes(Value: Double): TTimeSpan;
begin

end;

class function TTimeSpan.GetScaledInterval(Value: Double;
  Scale: Integer): TTimeSpan;
var
  NewVal: Double;
begin
  if IsNan(Value) then
    raise EArgumentException.Create(sTimespanValueCannotBeNan);
  NewVal := Value * Scale;
  if Value >= 0.0 then
    NewVal := NewVal + 0.5
  else
    NewVal := NewVal - 0.5;
  if (NewVal > MaxMilliseconds) or (NewVal < MinMilliseconds) then
    raise EArgumentOutOfRangeException.Create(sTimespanTooLong);
  Result := TTimeSpan.Create(Trunc(NewVal) * TicksPerMillisecond);
end;

function TTimeSpan.GetTotalMilliseconds: Double;
begin
  Result := (FTicks/TicksPerMillisecond);
end;

function TTimeSpan.GetTotalMinutes: Double;
begin
  Result := (FTicks/TicksPerMinute);
end;

function TTimeSpan.GetTotalSeconds: Double;
begin
  Result := (FTicks/TicksPerSecond);
end;


function TTimeSpan.Subtract(const TS: TTimeSpan): TTimeSpan;
var
  NewTicks: Int64;
begin
  NewTicks := FTicks - TS.FTicks;
  if ((FTicks shr 63) <> (TS.FTicks shr 63)) and ((FTicks shr 63) <> (NewTicks shr 63)) then
    raise EArgumentOutOfRangeException.Create('Timespan TooLong');
  Result := TTimeSpan.Create(NewTicks);
end;
function TTimeSpan.ToString: string;
var
  Fmt: string;
  Days, SubSecondTicks: Integer;
  LTicks: Int64;
begin
  Fmt := '%1:.2d:%2:.2d:%3:.2d'; // do not localize
  Days := FTicks div TicksPerDay;
  LTicks := FTicks mod TicksPerDay;
  if FTicks < 0 then
    LTicks := -LTicks;
  if Days <> 0 then
    Fmt := '%0:d.' + Fmt; // do not localize
  SubSecondTicks := LTicks mod TicksPerSecond;
  if SubSecondTicks <> 0 then
    Fmt := Fmt + '.%4:.7d'; // do not localize
  Result := Format(Fmt,
    [Days,
    (LTicks div TicksPerHour) mod 24,
    (LTicks div TicksPerMinute) mod 60,
    (LTicks div TicksPerSecond) mod 60,
    SubSecondTicks]);
end;

{ TStopwatch }
class function TStopwatch.Create: TStopwatch;
begin
  InitStopwatchType;
  Result.Reset;
end;
function TStopwatch.GetElapsed: TTimeSpan;
begin
  Result := TTimeSpan.Create(GetElapsedDateTimeTicks);
end;
function TStopwatch.GetElapsedDateTimeTicks: Int64;
begin
  Result := ElapsedTicks;
  if FIsHighResolution then
    Result := Trunc(Result * TickFrequency);
end;
function TStopwatch.GetElapsedTicks: Int64;
begin
  Result := FElapsed;
  if FRunning then
    Result := Result + GetTimeStamp - FStartTimeStamp;
end;
class function TStopwatch.GetTimeStamp: Int64;
var
  res: timespec;
begin
  //GetTickCount64
  clock_gettime(CLOCK_MONOTONIC, @res);
  Result := (Int64(1000000000) * res.tv_sec + res.tv_nsec) div 100;
end;
class procedure TStopwatch.InitStopwatchType;
begin
  if FFrequency = 0 then
  begin
    FIsHighResolution := True;
    FFrequency := 10000000; // 100 Nanosecond resolution
    TickFrequency := 10000000.0 / FFrequency;
  end;
end;
procedure TStopwatch.Reset;
begin
  FElapsed := 0;
  FRunning := False;
  FStartTimeStamp := 0;
end;
procedure TStopwatch.Start;
begin
  if not FRunning then
  begin
    FStartTimeStamp := GetTimeStamp;
    FRunning := True;
  end;
end;
class function TStopwatch.StartNew: TStopwatch;
begin
  InitStopwatchType;
  Result.Reset;
  Result.Start;
end;
procedure TStopwatch.Stop;
begin
  if FRunning then
  begin
    FElapsed := FElapsed + GetTimeStamp - FStartTimeStamp;
    FRunning := False;
  end;
end;
end.
