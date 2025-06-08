unit ISBase64AndEncryption;
//See Also unit  IsIndyLib
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$H+}

interface
uses Sysutils
{$IFDEF NextGen}
,IsNextGenPickup
{$ENDIF}
;
function Base64Encode(AInStr: AnsiString): AnsiString;
function Base64ToBinaryDecode(OutBuffer: Pointer; SizeOfBuffer: Integer; EncodedBase64: AnsiString): integer;
function BinaryToBase64Encode(Buffer: Pointer; SizeOfBuffer: Integer): AnsiString;
{$IfDef FPC}
//procedure EncryptFPC(ABufferSize: Longword;  Var ABufferPointer; AKeySize: word;  Var AKeyPointer);
{$Endif}
procedure encrypt(ABufferSize: Longword;  ABufferPointer: pointer;  AKeySize: word;  AKeyPointer: pointer);
{Xor a block of data}

implementation
//Uses ISDelphi2009Adjust;

function Base64Encode(AInStr: AnsiString): AnsiString;
begin
{$IfDef NextGen}
  Result := BinaryToBase64Encode(Pointer(AInStr), AInStr.Length);
{$ELSE}
  Result := BinaryToBase64Encode(PAnsiChar(AInStr), Length(AInStr));
{$ENDIF}
end;

const
CR = #13;
LF = #10;
CRLF = #13+#10;
Base64Code: array[0..63] of Char = (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l',
    'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/');


function BinaryToBase64Encode(Buffer: Pointer; SizeOfBuffer: Integer): AnsiString;

var
  NextByte,NextByte1,NextByte2: ^Byte;
  NoInRow, NoToCode: integer;
  CodeInt: LongWord;
  CodeStr: AnsiString;
  {sub} function MakeCodeStr(Code: Cardinal): String;
  var
    NextCode, j: Byte;
    CodeInt: Cardinal;
  begin
    SetLength(Result, 4);
    CodeInt := Code;
{$IFDEf NextGen}
    for j := 3 downto 0 do
{$ELSE}
    for j := 4 downto 1 do
{$ENDIF}
    begin
      NextCode := CodeInt and $3F;
      Result[j] := Base64Code[NextCode];
      CodeInt := CodeInt shr 6;
    end;
    if CodeInt > 0 then
      raise Exception.Create('Base64Encode error');
  end;
begin
  NextByte := Buffer;
  NoInRow := 0;
  NoToCode := SizeOfBuffer;
  Result := '';
  while NoToCode > 0 do
  begin
     NextByte1:=NextByte;
     inc(NextByte1);
     NextByte2:=NextByte1;
     inc(NextByte2);
    if NoToCode > 2 then
    begin
      CodeInt := NextByte^ * 65536 + NextByte1^ * 256 + NextByte2^;
      Result := Result + MakeCodeStr(CodeInt);
    end
    else
      case NoToCode of
        2:
          begin
            CodeInt := NextByte^ * 65536 + NextByte1^ * 256;
            CodeStr := MakeCodeStr(CodeInt);
{$IFDEf NextGen}
            CodeStr[3] := '=';
{$ELSE}
            CodeStr[4] := '=';
{$ENDIF}
            Result := Result + CodeStr;
          end;
        1:
          begin
            CodeInt := NextByte^ * 65536;
            CodeStr := MakeCodeStr(CodeInt);
{$IFDEf NextGen}
            CodeStr[3] := '=';
            CodeStr[2] := '=';
{$ELSE}
            CodeStr[4] := '=';
            CodeStr[3] := '=';
{$ENDIF}
            Result := Result + CodeStr;
          end;
      end;
    Inc(NextByte, 3);
    Dec(NoToCode, 3);
    Inc(NoInRow, 4);
    if (NoInRow > 72)and (NoToCode>0) then
    begin
      Result := Result + CRLF;
      NoInRow := 0;
    end;
  end;
end;

function Base64ToBinaryDecode(OutBuffer: Pointer; SizeOfBuffer: Integer;
     EncodedBase64: AnsiString): integer;

var
  NextChar, NextByte: ^Byte;
  i, Padding: Integer;
  CodeOut: record
    case Boolean of
      True: (lw: LongWord);
      False: (Bytes: packed array[0..3] of byte);
  end;
    {sub} function Decode(Value: Char): Byte;
  begin
    result := 0;
    case Value of
      'A'..'Z': Result := Ord(Value) - Ord('A');
      'a'..'z': Result := Ord(Value) - Ord('a') + 26;
      '0'..'9': Result := Ord(Value) - Ord('0') + 52;
      '+': Result := 62;
      '/': Result := 63;
      '=': Result := 0;
    end;
  end;
begin
  try
    Result := 0;
    if EncodedBase64 = '' then exit;
{$IFDEF NextGen}
    NextChar := EncodedBase64;
{$ELSE}
    NextChar := @EncodedBase64[1];
{$ENDIF}
    NextByte := OutBuffer;
    Padding := 0;
    while (NextChar^ <> 0)
    and (Result < SizeOfBuffer) and (Result > -1) do
    begin
      CodeOut.lw := 0;
      if Padding > 0 then
        raise Exception.Create('MisConstructed Base 64 Code 1:: Internal Padding "="');
      for i := 0 to 3 do
      begin
        CodeOut.lw := CodeOut.lw shl 6;
        while (NextChar^ in [13, 10]) do
          inc(NextChar);
        if (NextChar^ = 0) then
        begin
          raise Exception.Create('MisConstructed Base 64 Code 2:: No Padding "="')
        end
        else
          CodeOut.lw := CodeOut.lw + Decode(Char(NextChar^));
        if NextChar^ = 61 {Ord('=')} then
           Inc(Padding);
        inc(NextChar);
      end;
      for i := 2 downto Padding do
        if Result < SizeOfBuffer then
        begin
          NextByte^ := CodeOut.Bytes[i];
          Inc(NextByte);
          Inc(Result);
        end
        else
        begin
          Result := -1;
          break;
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Base64ToBinaryDecode :<' + EncodedBase64 + '>:' + e.Message);
  end;
end;
{$IfDef FPC}
procedure EncryptFPC(ABufferSize: Longword;
  Var ABufferPointer;
  AKeySize: word;
  Var AKeyPointer);

{const
  MaxEnSz= 50;
type
  one_byte= array[1..MaxEnSz] of byte;}
var
  i, j: Longword;
  Data,Encrt:PAnsiChar;
  //BufferArray,KeyArray:One_Byte;
  Val:AnsiChar;
begin
 Try
//BufferArray:=one_byte(ABufferPointer);
//KeyArray:=one_byte(AKeyPointer);
  Data:=PAnsiChar(ABufferPointer);
  Encrt:=PansiChar(AKeyPointer);
  i := 0;
  j := 0;
  while i <= (ABufferSize-1) do
  begin
      Val := AnsiChar(Byte(Data[i]) xor Byte(Encrt[j]));
      Data[i]:=Val;
    j := j + 1;
    if j > (AKeySize-1) then
      j := 1;
    i := i + 1;
  end;
 Except
   On E:Exception do
     Raise Exception.Create('Encrypt::'+E.Message);
 end;
end;
{$EndIf}


procedure Encrypt(ABufferSize: Longword;
  ABufferPointer: pointer;
  AKeySize: word;
  AKeyPointer: pointer);

const
  MaxEnSz= MaxInt;

type
  byte_buffer = record
    one_byte: array[1..MaxEnSz] of byte;
  end;
  buffer_ptr = ^byte_buffer;
var
  i, j: Longword;
{$IfDef Debug}
  Enc,Dta:array[1..16]of byte;
{$EndIf}
begin
 Try
{$IfDef Debug}
  for i:= 1 to 16 do
    Begin
       Dta[i]:= buffer_ptr(ABufferPointer)^.one_byte[i];
       Enc[i]:= buffer_ptr(AKeyPointer)^.one_byte[i];
    end;
{$EndIf}
  i := 1;
  j := 1;
  while i <= (ABufferSize) do
  begin
    buffer_ptr(ABufferPointer)^.one_byte[i] :=
      (buffer_ptr(ABufferPointer)^.one_byte[i] xor
      buffer_ptr(AKeyPointer)^.one_byte[j]);
    j := j + 1;
    if j > (AKeySize) then
      j := 1;
    i := i + 1;
  end;
 {$IfDef Debug}
  for i:= 1 to 16 do
    Begin
       Dta[i]:= buffer_ptr(ABufferPointer)^.one_byte[i];
       Enc[i]:= buffer_ptr(AKeyPointer)^.one_byte[i];
    end;
{$EndIf}
 Except
   On E:Exception do
     Raise Exception.Create('Encrypt::'+E.Message);
 end;
end;

end.

