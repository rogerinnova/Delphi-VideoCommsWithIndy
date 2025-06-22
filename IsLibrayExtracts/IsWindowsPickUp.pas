unit IsWindowsPickUp;

// look at {$I UnistdAPI.inc}

interface

uses
{$IFDEF POSIX}
   Posix.Unistd, Posix.StdIo,
{$ENDIF}
{$IFDEF NextGen}
   IsNextGenPickup,
{$ENDIF}
  System.SysUtils, System.Classes;

Type
  DWord = LongWord;
  // TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

Procedure ZeroMemory(ADestination: Pointer; AMemLen: LongWord);
//Function ZeroMemory(ADestination: Pointer; AMemLen: LongWord):LongWord;
//Function CopyMemory(ADestination, ASource: Pointer; AMemLen: LongWord): LongWord;
Procedure CopyMemory(ADestination, ASource: Pointer; AMemLen: LongWord);//: LongWord;
function LockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: LongWord;
  nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: LongWord): Boolean;
function UnlockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: LongWord;
  nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: LongWord): Boolean;
function CloseHandle(hObject: THandle): Boolean;
function WaitForSingleObject(hHandle: THandle; dwMilliseconds: LongWord)
  : LongWord;
function ShellExecuteA(hWnd: LongWord; Operation, FileName, Parameters,
  Directory: Pointer; ShowCmd: Integer): THandle;
Function GetTickCount: LongInt;
procedure OutputDebugString(lpOutputString: PChar);
Function RecoverSpecialFileDirectory(AChoose:Word):String;

procedure OutputDebugStringA(lpOutputString: PAnsiChar);
Function CopyFileA(ASourceName, ADestinationName: PAnsiChar;
  AFailIfExists: Boolean): Boolean;
Function CopyFileW(ASourceName, ADestinationName: PChar;
  AFailIfExists: Boolean): Boolean;
Function DeleteFileA(ASourceName: PAnsiChar): Boolean;

const
  WAIT_TIMEOUT = 7777;
  { ShowWindow() Commands }
  SW_HIDE = 0;
  SW_SHOWNORMAL = 1;
  SW_NORMAL = 1;
  SW_SHOWMINIMIZED = 2;
  SW_SHOWMAXIMIZED = 3;
  SW_MAXIMIZE = 3;
  SW_SHOWNOACTIVATE = 4;
  SW_SHOW = 5;
  SW_MINIMIZE = 6;
  SW_SHOWMINNOACTIVE = 7;
  SW_SHOWNA = 8;
  SW_RESTORE = 9;
  SW_SHOWDEFAULT = 10;
  SW_FORCEMINIMIZE = 11;
  SW_MAX = 11;

  VER_Platform_OSX = 9999;

implementation

Procedure ZeroMemory(ADestination: Pointer; AMemLen: LongWord);
Const
  BufMax = 200000;
Type
  Bfr = Array [0 .. BufMax] of byte;
  BfrPtr = ^Bfr;
Var
  Dest: BfrPtr;
  i: Integer;
begin
  if AMemLen > BufMax then
    raise Exception.Create('ZeroMemory Length exceeeded ' + IntToStr(AMemLen));
  Dest := ADestination;
  for i := 0 to AMemLen - 1 do
    Dest[i] := 0;
end;


Procedure CopyMemory(ADestination, ASource: Pointer; AMemLen: LongWord);//: LongWord;
Const
  BufMax = 200000;
Type
  Bfr = Array [0 .. BufMax] of byte;
  BfrPtr = ^Bfr;
Var
  Src, Dest: BfrPtr;
  i: Integer;
begin
  if AMemLen > BufMax then
    raise Exception.Create('CopyMemory Length exceeded ' + IntToStr(AMemLen));
  Src := ASource;
  Dest := ADestination;
  for i := 0 to AMemLen - 1 do
    Dest[i] := Src[i];
//  Result:=LongWord(@Dest[i]);
end;

Function CopyFileW(ASourceName, ADestinationName: PChar;
  AFailIfExists: Boolean): Boolean;
Const
  BufMax = 200000;
Var
  FileToCopy, FileCopy: TFileStream;
  Read: LongInt;
  Buffer: Array [0 .. BufMax] of byte;
  // BufferPtr:Pointer;

begin
  Result := False;
  If FileExists(ADestinationName) then
    if AFailIfExists then
      exit
    else
      DeleteFile(ADestinationName);
  if Not FileExists(ASourceName) then
    exit;
  // BufferPtr:=@Buffer[0];
  Try
    FileToCopy:=nil;
    FileCopy := nil;
    Try
      FileToCopy := TFileStream.Create(ASourceName, fmOpenRead,
        fmShareDenyNone);
//      FileCopy := TFileStream.Create(ADestinationName, fmCreate,
//        fmShareExclusive);    seems to
      FileCopy := TFileStream.Create(ADestinationName, fmcreate);
      Read := FileToCopy.Read(Buffer, BufMax);
      while Read > 0 do
      Begin
        FileCopy.Write(Buffer, Read);
        if Read < BufMax then
          Read := 0
        Else
          Read := FileToCopy.Read(Buffer, BufMax);
      End;
    Finally
      FileCopy.Free;
      FileToCopy.Free;
    End;
    Result := true;
  Except
    Result := False;
  End;
end;

Function CopyFileA(ASourceName, ADestinationName: PAnsiChar;
  AFailIfExists: Boolean): Boolean;
Const
  BufMax = 200000;
Var
  FileToCopy, FileCopy: TFileStream;
  Read: LongInt;
  Buffer: Array [0 .. BufMax] of byte;
  // BufferPtr:Pointer;

begin
  Result := False;
  If FileExists(ADestinationName) then
    if AFailIfExists then
      exit
    else
      DeleteFile(ADestinationName);
  if Not FileExists(ASourceName) then
    exit;
  // BufferPtr:=@Buffer[0];
  Try
    FileToCopy:=nil;
    FileCopy := nil;
    Try
      FileToCopy := TFileStream.Create(ASourceName, fmOpenRead,
        fmShareDenyNone);
//      FileCopy := TFileStream.Create(ADestinationName, fmCreate,
//        fmShareExclusive);    seems to
      FileCopy := TFileStream.Create(ADestinationName, fmcreate);
      Read := FileToCopy.Read(Buffer, BufMax);
      while Read > 0 do
      Begin
        FileCopy.Write(Buffer, Read);
        if Read < BufMax then
          Read := 0
        Else
          Read := FileToCopy.Read(Buffer, BufMax);
      End;
    Finally
      FileCopy.Free;
      FileToCopy.Free;
    End;
    Result := true;
  Except
    Result := False;
  End;
end;

Function DeleteFileA(ASourceName: PAnsiChar): Boolean;
begin
  Result := DeleteFile(ASourceName);
end;


function LockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: LongWord;
  nNumberOfBytesToLockLow, nNumberOfBytesToLockHigh: LongWord): Boolean;
begin
  // look at lockf {$I UnistdAPI.inc}
  Result := true; // ??
end;

function UnlockFile(hFile: THandle; dwFileOffsetLow, dwFileOffsetHigh: LongWord;
  nNumberOfBytesToUnlockLow, nNumberOfBytesToUnlockHigh: LongWord): Boolean;
begin
  // look at lockf {$I UnistdAPI.inc}
  Result := true; // ??
end;

function CloseHandle(hObject: THandle): Boolean;
begin
  // Close Process Handle  ShellExecuteA Create Process and wait
  Result := true;
end;

function WaitForSingleObject(hHandle: THandle; dwMilliseconds: LongWord)
  : LongWord;
begin
  // Process Handle  ShellExecuteA Create Process and wait
  Result := 0;
end;

Function RecoverSpecialFileDirectory(AChoose:Word):String;
Begin
  Result:='users';
  case AChoose  of
    0:Result:=Result+'/Me';
  end;
End;

function ShellExecuteA(hWnd: LongWord; Operation, FileName, Parameters,
  Directory: Pointer; ShowCmd: Integer): THandle;
begin
  // Process Handle  ShellExecuteA Create Process and wait
  Result := 0;
end;

Function GetTickCount: LongInt;
Var
  Base: TDateTime;
begin
  Base := Now;
  Result := Round((Base - Round(Base) * 1000000000));
end;

procedure OutputDebugString(lpOutputString: PChar);
begin
  Sleep(10);
end;

procedure OutputDebugStringA(lpOutputString: PAnsiChar);
begin
  Sleep(10);
end;

end.
