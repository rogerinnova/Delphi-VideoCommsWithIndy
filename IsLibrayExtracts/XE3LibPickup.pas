unit XE3LibPickup;

interface
uses
{$IFDEF NEXTGEN}
  IsNextGenPickup,
{$ENDIF}
  Sysutils
{$IFDEF FMXApplication}
,Fmx.Types,Fmx.Graphics;
{$Else}
;
{$EndIf}

{$IFDEF NEXTGEN}
function GetTokenXE3(var S: AnsiString; Separators: AnsiString; Stop: AnsiString): AnsiString;
{$Else}
function GetTokenXE3(var S: AnsiString; Separators: AnsiString; Stop: AnsiString = ''): AnsiString;
{$ENDIF}
function AnsiLastChar(const S: AnsiString): PAnsiChar;   overload;
{$IFDEF FMXApplication}
function GetMeasureBitmap: TBitmap;
{$Else}
function   CurrencyString: string;
function    CurrencyFormat: Byte;
function    CurrencyDecimals: Byte;
function    DateSeparator: Char;
function    TimeSeparator: Char;
function    ListSeparator: Char;
function    ShortDateFormat: string;
//function    LongDateFormat: string;
//function    TimeAMString: string;
//function    TimePMString: string;
function    ShortTimeFormat: string;
function    LongTimeFormat: string;
//function    ShortMonthNames: array[1..12] of string;
//function    LongMonthNames: array[1..12] of string;
//function    ShortDayNames: array[1..7] of string;
//function    LongDayNames: array[1..7] of string;
function    ThousandSeparator: Char;
function    DecimalSeparator: Char;
function    TwoDigitYearCenturyWindow: Word;
//function    NegCurrFormat: Byte;
{$EndIf}

{$Warnings off}
implementation

function AnsiLastChar(const S: AnsiString): PAnsiChar;
{$IFDEF NEXTGEN}
begin
  result:=s.AnsiLastChar;
end;
{$Else}
var
  LastByte: Integer;
begin
  LastByte := Length(S);
  if LastByte <> 0 then
  begin
    while ByteType(S, LastByte) = mbTrailByte do Dec(LastByte);
    Result := @S[LastByte];
  end
  else
    Result := nil;
end;
{$EndIf}


function GetTokenXE3(var S: AnsiString; Separators: AnsiString; Stop: AnsiString): AnsiString;
var
  I, len: Integer;
  CopyS: AnsiString;
begin
  Result := '';
  CopyS := S;
  len := Length(CopyS);
  for I := 1 to len do
  begin
    if Pos(CopyS[I], Stop) > 0 then
      Break;
{$IfDef NextGen}
    s.Delete(1, 1);
{$Else}
    Delete(S, 1, 1);
{$ENDIF}
    if Pos(CopyS[I], Separators) > 0 then
    begin
      Result := Result;
      Break;
    end;
    Result := Result + CopyS[I];
  end;
  Result := Trim(Result);
  S := Trim(S);
end;

{$IFDEF FMXApplication}
Var
MeasureBitmap:TBitmap=nil;

function GetMeasureBitmap: TBitmap;
begin
  if MeasureBitmap = nil then
    MeasureBitmap := TBitmap.Create(1, 1);
  Result := MeasureBitmap;
end;
{$Else}
function   CurrencyString: string;
Begin
  Result:=FormatSettings.CurrencyString;
End;
function    CurrencyFormat: Byte;
Begin
  Result:=FormatSettings.CurrencyFormat;
End;
function    CurrencyDecimals: Byte;
Begin
  Result:=FormatSettings.CurrencyDecimals;
End;
function    DateSeparator: Char;
Begin
  Result:=FormatSettings.DateSeparator;
End;
function    TimeSeparator: Char;
Begin
  Result:=FormatSettings.TimeSeparator;
End;
function    ListSeparator: Char;
Begin
  Result:=FormatSettings.ListSeparator;
End;
function    ShortDateFormat: string;
Begin
  Result:=FormatSettings.ShortDateFormat;
End;
//function    LongDateFormat: string;
//function    TimeAMString: string;
//function    TimePMString: string;
function    ShortTimeFormat: string;
Begin
  Result:=FormatSettings.ShortTimeFormat;
End;
function    LongTimeFormat: string;
Begin
  Result:=FormatSettings.LongTimeFormat;
End;
//function    ShortMonthNames: array[1..12] of string;
//function    LongMonthNames: array[1..12] of string;
//function    ShortDayNames: array[1..7] of string;
//function    LongDayNames: array[1..7] of string;
function    ThousandSeparator: Char;
Begin
  Result:=FormatSettings.ThousandSeparator;
End;

function    DecimalSeparator: Char;
Begin
  Result:=FormatSettings.DateSeparator;
End;
function    TwoDigitYearCenturyWindow: Word;
Begin
  Result:=FormatSettings.TwoDigitYearCenturyWindow;
End;
//function    NegCurrFormat: Byte;

{$EndIf}

end.
