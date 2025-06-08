unit ISDelphi2009Adjust;

interface
{$IFDEF NextGen}
Uses  IsNextGenPickup;
{$ENDIF}

{$Warnings off}


function AnsiChr(Val:Byte):AnsiChar;

{$IFDEF UNICODE}
{$ELSE}
{$ENDIF}
{$IFDEF UNICODE}
  function AnsiPos(const Substr, S: Ansistring): Integer; overload;
  procedure DateTimeToString(var Result: ansistring; const Format: string;
     DateTime: TDateTime); overload;
{$ELSE}
  Function AnsiStrAlloc(ALength:Cardinal):PAnsiChar;
{$ENDIF}

function GetEnvironmentVariableA(const Name: AnsiString): AnsiString; Overload;



implementation

uses SysUtils;

function AnsiChr(Val:Byte):AnsiChar;
Begin
  Result:=AnsiChar(Val);
End;

function GetEnvironmentVariableA(const Name: AnsiString): AnsiString;
{$IFDEF UNICODE}
Var
  NewNm,Rslt:UnicodeString;
Begin
  NewNm:=Name;
  Rslt:=GetEnvironmentVariable(NewNm);
  Result:=Rslt;
End;
{$ELSE}
Begin
 Result:=GetEnvironmentVariable(Name);
end;
{$Endif}

{$IFDEF UNICODE}
procedure DateTimeToString(var Result: Ansistring; const Format: string;
     DateTime: TDateTime); overload;
  Var
    s:String;
  begin
    DateTimeToString(s,Format,DateTime);
    Result:=s;
  end;

function AnsiPos(const Substr, S: Ansistring): Integer;
var
  P: PAnsiChar;
begin
  Result := 0;
{$IFDEF NextGen}
   Result:= Pos(SubStr,S);
{$ELSE}
  P := AnsiStrPos(PAnsiChar(S), PAnsiChar(SubStr));
  if P <> nil then
    Result := (Integer(P) - Integer(PAnsiChar(S))) + 1;
{$ENDIF}
end;


{$ELSE}
Function AnsiStrAlloc(ALength:Cardinal):PAnsiChar;
Begin
  Result:=StrAlloc(ALength);
end;
{$ENDIF}
end.
