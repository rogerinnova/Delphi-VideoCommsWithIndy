{$IFDEF FPC}
  {$MODE Delphi}
  {$I InnovaLibDefsLaz.inc}
{$Else}
{$I InnovaLibDefs.inc}
{$EndIf}

unit ISUnicodeStrUtl;
{ ************************************************ }
{ Unicode Strings Utilities
  {   Delphi
  {   Copyright (c) 2010
  {   Innova Solutions/R Connell
  {************************************************ }

interface
uses
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
{$IfDef FPC}
  UITypes, SysUtils, Classes,
  IsWindowsPickUp
{$ELSE}
{$IFDEF ISXE2_DELPHI}
{$IFDEF MSWindows}
  WinApi.Windows,
{$ELSE}
  IsWindowsPickUp,
{$ENDIF}
  System.UITypes, System.SysUtils, System.Classes
{$ELSE}
  Windows, SysUtils, Classes
{$ENDIF}
  (*{$IF (System.CompilerVersion<19.00)}
    ;
    {$ELSE}
    ; // ,UnicodeConst;
    {$ENDIf}
  *)
{$ENDIF}
;

const
  Alpha = WideChar($0391);
  Beta = WideChar($0392);
  Gamma = WideChar($0393);
  Delta = WideChar($0394);
  Epsilon = WideChar($0395);
  Zeta = WideChar($0396);
  Eta = WideChar($0397);
  Theta = WideChar($0398);
  Iota = WideChar($0399);
  Kappa = WideChar($039A);
  Lambda = WideChar($039B);
  Mu = WideChar($039C);
  Nu = WideChar($039D);
  Xi = WideChar($039E);
  Omnicron = WideChar($039F);
  Pi = WideChar($03A0);
  Rho = WideChar($03A1);

  Sigma = WideChar($03A3);
  Tau = WideChar($03A4);
  Upsilon = WideChar($03A5);
  Phi = WideChar($03A6);
  Chi = WideChar($03A7);
  Psi = WideChar($03A8);
  Omega = WideChar($03A9);

  AlphaLw = WideChar($03B1);
  BetaLw = WideChar($03B2);
  GammaLw = WideChar($03B3);
  DeltaLw = WideChar($03B4);
  EpsilonLw = WideChar($03B5);
  ZetaLw = WideChar($03B6);
  EtaLw = WideChar($03B7);
  ThetaLw = WideChar($03B8);
  IotaLw = WideChar($03B9);
  KappaLw = WideChar($03BA);
  LambdaLw = WideChar($03BB);
  MuLw = WideChar($03BC);
  NuLw = WideChar($03BD);
  XiLw = WideChar($03BE);
  OmnicronLw = WideChar($03BF);
  PiLw = WideChar($03C0);
  RhoLw = WideChar($03C1);

  SigmaLw = WideChar($03C3);
  TauLw = WideChar($03C4);
  UpsilonLw = WideChar($03C5);
  PhiLw = WideChar($03C6);
  ChiLw = WideChar($03C7);
  PsiLw = WideChar($03C8);
  OmegaLw = WideChar($03C9);

{$IfNDef FPC}
{$IF System.CompilerVersion<19.00}
{$Define CompileLesthan19}
{$Endif}
{$Endif}

{$IfDef CompileLesthan19}
type
  UnicodeString = WideString;
  // RawByteString = AnsiString;

function ReadUnicodeFrmStrmAndCompressToAnsi(s: TStream; ANoSymbls: LongInt)
  : AnsiString;
function ReadAnsiFrmStrmAndExpandToUniCode(s: TStream; Sz: LongInt)
  : UnicodeString;
function UnicodeAsAnsi(const AUCode: UnicodeString): AnsiString;
function AnsiAsUnicode(const AAnsiCode: AnsiString): UnicodeString;
function CompressedUnicode(const AUCode: UnicodeString): AnsiString;
function DeCompressUnicode(const AAnsiCode: AnsiString): UnicodeString;
{$ELSE}


type

  StrCodeInfoRec = record
    CodePage: Word; // 2
    ElementLength: Word; // 2
    RefCount: Integer; // 4
    Length: Integer; // 4
  end;

function UnicodeAsAnsi(const AUCode: UnicodeString): AnsiString;
// Bypasses Conversion Routines Byte for Byte conversion Unicode Length 10 = Ansi len 20
// For std Unicode with actual AnsiChars every second byte in new string will be a null
// Byte Contents unchanged

function AnsiAsUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reinstates String following UnicodeAsAnsi
// Bypasses Conversion Routines
// Byte Contents unchanged

Procedure RecoverAnsiAsUnicodeListToUnicodeList(ASource, ADest: TStrings);
// Recovers TString Values Stored using UnicodeAsAnsi Typically in Object File Indexes
// Bypasses Conversion Routines
// Byte Contents unchanged

function AnsiFrmUtf8(const AUtf8Code: UTF8String): AnsiString;
// Bypasses Conversion Routines
function Utf8FrmAnsi(const AAnsiCode: AnsiString): UTF8String;
// Bypasses Conversion Routines

function Utf8FrmUnicodedPadding(const AUnicode: String): UTF8String;
// Bypasses Conversion Routines unless 2 byte characters found
// Byte Contents Drops nulls in uncode unless 2 byte characters found

function CompressedUnicode(const AUCode: UnicodeString): AnsiString;
// Compresses Unicode characters with upper byte of zero into an ansistring
// Stops Conversion inserting ?
// Contains Ascii version of Unicode but '' if 2 byte characters found
// Reverse of DeCompressUnicode
// Byte Contents Drops nulls in uncode

function DeCompressUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reverse of CompressedUnicode
// Byte Contents inserted nulls

function ReadAnsiFrmStrmAndExpandToUniCode(s: TStream; ABytes: LongInt)
  : UnicodeString;

function ReadUnicodeFrmStrmAndCompressToAnsi(s: TStream; ANoSymbls: LongInt)
  : AnsiString;

function ReplaceSpecialHTMLChars(const AInString: String): String; Overload;
{ <p>I will display &#9986;</p>
  <p>I will display &#x2702;</p>
}

function HexChar(c: Char): Byte;

Function StrToHexChar(s: String): Char;
// s must contain only Hex
function StrCodeInfo(const s: UnicodeString): StrCodeInfoRec; overload; inline;
function StrCodeInfo(const s: RawByteString): StrCodeInfoRec; overload; inline;

const
  NullStrCodeInfo: StrCodeInfoRec = (CodePage: 0; ElementLength: 0; RefCount: 0;
    Length: 0);

type
  PStrCodeInfoRec = ^StrCodeInfoRec;
{$ENDIF}

implementation
//uses IsStrUtl;
Const
{$IFDEF NEXTGEN}
  ZSISOffset = -1; // Zero Based String OffSet Cons
{$ELSE}
  ZSISOffset = 0;
{$ENDIF}


function HexChar(c: Char): Byte;
begin
  case c of
    '0' .. '9':
      Result := Byte(c) - Byte('0');
    'a' .. 'f':
      Result := (Byte(c) - Byte('a')) + 10;
    'A' .. 'F':
      Result := (Byte(c) - Byte('A')) + 10;
  else
    Raise Exception.Create(c + ' is not in Hex');
  end;
end;

Function StrToHexChar(s: String): Char;
// s must contain only Hex

Var
  i, len: Integer;
  Val: Word;
begin
  Result := '?';
  Try
    len := Length(s);
    if (len < 1) or (len > 4) then
      Exit;
    Val := 0;
    for i := 1 to len do
      Val := Val * 16 + HexChar(s[i + ZSISOffset]);
    Result := Char(Val);
  Except
    Result:='?';
  End;
end;

{$IFDef CompileLesthan19}

function ReadUnicodeFrmStrmAndCompressToAnsi(s: TStream; ANoSymbls: LongInt)
  : AnsiString;
var
  Intrim: UnicodeString;

begin
  SetLength(Intrim, ANoSymbls);
  s.Read(Intrim[1], ANoSymbls * 2);
  Result := Intrim;
end;

function ReadAnsiFrmStrmAndExpandToUniCode(s: TStream; Sz: LongInt)
  : UnicodeString;
var
  Intrim: AnsiString;

begin
  SetLength(Intrim, Sz);
  if Sz > 0 then
    s.Read(Intrim[1], Sz);
  Result := Intrim;
end;

// Pre Unicode delphi
function UnicodeAsAnsi(const AUCode: UnicodeString): AnsiString;
begin
  Result := AUCode;
end;

// Pre Unicode delphi
function AnsiAsUnicode(const AAnsiCode: AnsiString): UnicodeString;
begin
  Result := AAnsiCode;
end;

function CompressedUnicode(const AUCode: UnicodeString): AnsiString;
begin
  Result := AUCode;
end;

function DeCompressUnicode(const AAnsiCode: AnsiString): UnicodeString;
begin
  Result := AAnsiCode;
end;

end.
{$ELSE}          //Not {$IF System.CompilerVersion<19.00}
{$IFNDEF Windows}
Procedure CopyMemoryIS(Destination, Source: Pointer; MemLen: LongWord);
begin
end;
{$ENDIF}
{$Endif}

function StrCodeInfo(const s: RawByteString): StrCodeInfoRec; overload; inline;
var
  AtS: NativeInt;
begin
  AtS := NativeInt(s);
  if AtS = 0 then
    Result := NullStrCodeInfo
  else
    Result := PStrCodeInfoRec(AtS - 12)^
end;

function StrCodeInfo(const s: UnicodeString): StrCodeInfoRec; overload; inline;
var
  AtS: NativeInt;
begin
  AtS := NativeInt(s);
  if AtS = 0 then
    Result := NullStrCodeInfo
  else
    Result := PStrCodeInfoRec(AtS - 12)^
end;

{ MyNativeInt    = NativeInt;
  function StringElementSize(const S: UnicodeString): Word; overload; inline;
  function StringCodePage(const S: RawByteString): Word; overload; inline;
  function StringRefCount(const S: UnicodeString): Integer; overload; inline;
}

function UnicodeAsAnsi(const AUCode: UnicodeString): AnsiString;
// Bypasses Conversion Routines Byte for Byte conversion Unicode Length 10 = Ansi len 20
// For std Unicode with actual AnsiChars every second byte in new string will be a null
// Byte Contents unchanged
{$IfDef ISLazarus}
var
  MemLen,Li: Integer;
  Nxt, Dest: Pointer;
begin
  Li := Length(AUCode);
  if Li < 1 then
    Result := ''
  else
  begin
    MemLen := Li * 2;
    SetLength(Result, MemLen);
    Nxt := @AUCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$Else}
var
  MemLen: Integer;
  Nxt, Dest: Pointer;
  R: StrCodeInfoRec;
  // RstAnsiCode:RawByteString;
begin
  // RstAnsiCode:= AAnsiCode;
  // SetCodepage(RstAnsiCode,DefaultUnicodeCodePage,false);
  // Result:=RstAnsiCode;
  R := StrCodeInfo(AUCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    // if R.CodePage<>DefaultUnicodeCodePage then
    // raise Exception.Create('Error Message');
    // ULen:=Length(AUCode);

    // if R.CodePage<>DefaultUnicodeCodePage then
    // raise Exception.Create('Error Message');

{$IFDEF NextGen}
    Result.UnicodeAsAnsi(AUCode);
{$ELSE}
    MemLen := R.ElementLength * R.Length;
    SetLength(Result, MemLen);
    Nxt := @AUCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
{$ENDIF}
  end;
{$ENdif //ISLazarus}
end;

function AnsiAsUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reinstates String following UnicodeAsAnsi
// Bypasses Conversion Routines
// Byte Contents unchanged
{$IfDef ISLazarus}
var
  MemLen, ULen, Li: Integer;
  Nxt, Dest: Pointer;
begin
  Li:= Length(AAnsiCode);
  if Li < 1 then
    Result := ''
  else
  begin
     MemLen := Li;
    if (MemLen mod 2) > 0 then
      Inc(MemLen); // now points to null terminator

    ULen := MemLen div 2;
    SetLength(Result, ULen);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$Else}
var
  MemLen, ULen: Integer;
  Nxt, Dest: Pointer;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AAnsiCode.RecoverFullUnicode;
{$ELSE}
  R := StrCodeInfo(AAnsiCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    // if R.CodePage=DefaultUnicodeCodePage then
    // raise Exception.Create('Error Message');

    MemLen := R.ElementLength * R.Length;
    if (MemLen mod 2) > 0 then
      Inc(MemLen); // now points to null terminator

    ULen := MemLen div 2;
    SetLength(Result, ULen);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$ENDIF}
{$ENdIf ISLazarus}
end;

Procedure RecoverAnsiAsUnicodeListToUnicodeList(ASource,ADest:TStrings);
Var
  i:Integer;
begin
  for I := 0 to ASource.Count-1 do
     ADest.AddObject(AnsiAsUnicode(ASource[i]),ASource.Objects[i])
end;


function AnsiFrmUtf8(const AUtf8Code: UTF8String): AnsiString;
// Bypasses Conversion Routines
// Ansi Code Page=1252
// Utf8 Code Page=65001
var
  MemLen: Integer;
  Nxt, Dest: Pointer;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AUtf8Code;
{$ELSE}
  R := StrCodeInfo(AUtf8Code);
  if R.Length < 1 then
    Result := ''
  else
  begin
    MemLen := R.Length;
    SetLength(Result, MemLen);
    Nxt := @AUtf8Code[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$ENDIF}
end;

function Utf8FrmAnsi(const AAnsiCode: AnsiString): UTF8String;
// Bypasses Conversion Routines
// Ansi Code Page=1252
// Utf8 Code Page=65001

var
  MemLen: Integer;
  Nxt, Dest: Pointer;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AAnsiCode;
{$ELSE}
  R := StrCodeInfo(AAnsiCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    MemLen := R.Length;
    SetLength(Result, MemLen);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$ENDIF}
end;

function Utf8FrmUnicodedPadding(const AUnicode: String): UTF8String;
// Bypasses Conversion Routines unless 2 byte characters found
// Byte Contents Drops nulls in uncode unless 2 byte characters found
Var
  InLen: Integer;
  LocalResult: AnsiString;
begin
  Result := '';
  InLen := Length(AUnicode);
  if InLen < 1 then
    Exit;

  LocalResult := CompressedUnicode(AUnicode);
  if LocalResult = '' then
    Result := AUnicode // Let internal conversion run
  else
    Result := Utf8FrmAnsi(LocalResult);
end;

function CompressedUnicode(const AUCode: UnicodeString): AnsiString;
// Compresses Unicode characters with upper byte of zero into an ansistring
// Stops Conversion inserting ?
// Contains Ascii version of Unicode but '' if 2 byte characters found
// Reverse of DeCompressUnicode
// Byte Contents Drops nulls in uncode
{$IfDef ISLazarus}
var
  Ri, Ui, Li: Integer;
  Nxt, Dest: PAnsiChar;
begin
  Li:= Length(AUCode);
  If Li<1 then
      Result := ''
    else
    begin
      SetLength(Result, Li);
      Nxt := @AUCode[1];
      Dest := @Result[1];
      Ri := 0;
      Ui := 0;
      while (Nxt[Ui + 1] = AnsiChar(0)) and (Ri < Li) do
      begin
        Dest[Ri] := Nxt[Ui];
        Inc(Ui, 2);
        Inc(Ri);
      end;
      if Ri < Li then
        Result := '';
    end;
{$Else}
var
  Ri, Ui: Integer;
  Nxt, Dest: PAnsiChar;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result.CompressedUnicode(AUCode);
{$ELSE}
  R := StrCodeInfo(AUCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    if R.CodePage <> DefaultUnicodeCodePage then
      raise Exception.Create('Non Unicode Unicode');
    SetLength(Result, R.Length);
    // AllDone:=r.Length-1;
    Nxt := @AUCode[1];
    Dest := @Result[1];
    Ri := 0;
    Ui := 0;
    while (Nxt[Ui + 1] = AnsiChar(0)) and (Ri < R.Length) do
    begin
      Dest[Ri] := Nxt[Ui];
      Inc(Ui, 2);
      Inc(Ri);
    end;
    if Ri < R.Length then
      Result := '';
  end;
{$ENDIF}
{$Endif //ISLazarus}
end;

function DeCompressUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reverse of CompressedUnicode
// Byte Contents inserted nulls
{$IfDef ISLazarus}
var
  Ri, Ai, li: Integer;
  Nxt, Dest: PAnsiChar;
begin
  Li := Length(AAnsiCode);
  if Li < 1 then
    Result := ''
  else
  begin
    SetLength(Result, Li);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    Ri := 0;
    Ai := 0;
    while (Ai < Li) do
    begin
      Dest[Ri + 1] := AnsiChar(0);
      Dest[Ri] := Nxt[Ai];
      Inc(Ai);
      Inc(Ri, 2);
    end;
  end;

{$Else}
var
  Ri, Ai: Integer;
  Nxt, Dest: PAnsiChar;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AAnsiCode;
{$ELSE}
  R := StrCodeInfo(AAnsiCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    if R.CodePage = DefaultUnicodeCodePage then
      raise Exception.Create('Unicoded non Unicode');
    SetLength(Result, R.Length);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    Ri := 0;
    Ai := 0;
    while (Ai < R.Length) do
    begin
      Dest[Ri + 1] := AnsiChar(0);
      Dest[Ri] := Nxt[Ai];
      Inc(Ai);
      Inc(Ri, 2);
    end;
  end;
{$ENDIF}
{$Endif //ISLazarus}
end;

function ReadAnsiFrmStrmAndExpandToUniCode(s: TStream; ABytes: LongInt)
  : UnicodeString;
var
  IntrimRslt: AnsiString;
begin
  if (s = nil) or (ABytes < 1) then
    Result := ''
  else
  begin
{$IFDEF NextGen}
    IntrimRslt.ReadBytesFrmStrm(s, ABytes);
    Result := IntrimRslt;
{$ELSE}
    SetLength(IntrimRslt, ABytes);
    s.Read(IntrimRslt[1], ABytes);
    Result := DeCompressUnicode(IntrimRslt);
{$ENDIF}
  end;
end;

function ReadUnicodeFrmStrmAndCompressToAnsi(s: TStream; ANoSymbls: LongInt)
  : AnsiString;
var
  IntrimRslt: UnicodeString;
begin
  if (s = nil) or (ANoSymbls < 1) then
    Result := ''
  else
  begin
    SetLength(IntrimRslt, ANoSymbls);
    s.Read(IntrimRslt[1], ANoSymbls * 2);
    Result := CompressedUnicode(IntrimRslt);
  end;
end;

function ReplaceSpecialHTMLChars(const AInString: String): String; Overload;
{ <html>
  <body>
  <p>I will display &#9996;</p>
  <p>I will display &#x270C;</p>
  </body>
  </html> }
var
  StartChar, NextChar, NextFlag, RChar: PChar;
  IntAsStr, HexAsStr, InString: String;
begin
  InString := StringReplace(AInString, '<Br>', #10#13,
    [rfReplaceAll, rfIgnoreCase]);
{$IFDEF NEXTGEN}
  SetLength(Result, Length(InString) + 3);
{$IFDEF ISD104S_DELPHI}
  RChar := PChar(Result);
  RChar[0] := Chr(0);
{$ELSE}
  RChar := @Result[0];
  RChar[0] := Chr(0);
{$ENDIF}
{$ELSE}
  SetLength(Result, Length(InString) + 3);
  RChar := @Result[1];
  RChar[0] := Chr(0);
{$ENDIF}
  // should be shorter than original
  if InString <> '' then
{$IFDEF NEXTGEN}
{$IFDEF ISD104S_DELPHI}
    StartChar := PChar(InString)
{$ELSE}
    StartChar := @InString[0]
{$ENDIF}
{$ELSE}
      StartChar := @InString[1]
{$ENDIF}
  else
    StartChar := nil;
  NextChar := StartChar;
  while NextChar <> nil do
  begin
    IntAsStr := '';
    HexAsStr := '';
    NextFlag := StrPos(NextChar, '&#');
    if NextFlag = nil then
    begin
      StrCopy(RChar, NextChar);
      NextChar := nil;
    end
    else
    begin
      StrLCopy(RChar, NextChar, NextFlag - NextChar);
      NextChar := NextFlag + 2;
      if (NextChar[0] = 'x') or (NextChar[0] = 'X') then
      begin
        Inc(NextChar);
        if NextChar[0] in ['0' .. '9', 'A' .. 'F', 'a' .. 'f'] then
          while Char(NextChar[0]) in ['0' .. '9', 'A' .. 'F', 'a' .. 'f'] do
          begin
            HexAsStr := HexAsStr + NextChar[0];
            Inc(NextChar);
          end;
      end
      Else if NextChar[0] in ['0' .. '9'] then
        while Char(NextChar[0]) in ['0' .. '9'] do
        begin
          IntAsStr := IntAsStr + NextChar[0];
          Inc(NextChar);
        end;
      if NextChar[0] = ';' then
        Inc(NextChar);
    end;
    RChar := RChar + StrLen(RChar);
    if IntAsStr <> '' then
    begin
      IntAsStr := Chr(StrToInt(IntAsStr));
{$IFDEF ISD104S_DELPHI}
      StrCopy(RChar, PChar(IntAsStr));
{$ELSE}
      StrCopy(RChar, @IntAsStr[1 + ZSISOffset]);
{$ENDIF}
      Inc(RChar);
    end
    Else if HexAsStr <> '' then
    begin
      HexAsStr := StrToHexChar(HexAsStr);
{$IFDEF ISD104S_DELPHI}
      StrCopy(RChar, PChar(HexAsStr));
{$ELSE}
      StrCopy(RChar, @HexAsStr[1 + ZSISOffset]);
{$ENDIF}
      Inc(RChar);
    end;

  end;
{$IFDEF ISD104S_DELPHI}
  RChar := PChar(Result);
{$ELSE}
  RChar := @Result[1 + ZSISOffset];
{$ENDIF}
  SetLength(Result, StrLen(RChar));
end;


end.
