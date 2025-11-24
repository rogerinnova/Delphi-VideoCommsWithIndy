{$I InnovaLibDefs.inc}
unit IsLogging;

interface

uses
{$IFDEF FPC}
  SyncObjs, Classes, SysUtils, IsLazarusPickup
{$ELSE}
    System.IOUtils, SyncObjs,
  Classes
{$IFDEF MSWINDOWS}
    , Windows
{$ENDIF}
    , SysUtils
{$IFDEF NextGen}
    , IsNextGenPickup
{$ENDIF}
{$ENDIF}
    ;

type
  TAnsiLogProcedure = procedure(const s: AnsiString) of Object;
  TIsLogEvent = Procedure(Const AMessage: String) Of Object;

  TLogFile = class(TObject)
  private
    FLock: TCriticalSection;
    FFileStm: TFileStream;
    FFileName: AnsiString;
    FLimitSz: Integer;
    FPurgeLogFilesOlderThan: TDateTime;
    FDisAbleLogging, FInRollLogFile: Boolean;
    fHoldStream: Boolean;
    FRollNotTruncate: Boolean;
    FLastLogMessage: AnsiString;
    FLastLoggedRepeat: Integer;
    FLastLoggedTime: TDateTime;
    FLastLoggedHour: string;
    FIngoreLogTime: Boolean;
    function AssciiOnly(s: string): AnsiString;
    function IsAssciiOnly(s: string): Boolean;
    procedure LogHourlyChange;
    procedure RollLogFile(AIgnoreTimeCheck: Boolean = false);
    procedure PurgeOldLogFiles;
    procedure OpenFileOnDelay;
    procedure OpenNewFileCopy;
    procedure SetPurgeLogFilesOlderThan(const Value: TDateTime);
    procedure SetIngoreLogTime(const Value: Boolean);
  public
    constructor Create(fName: AnsiString; AAppend: Boolean; ALimit: Integer = 0;
      ARollLogWhenFull: Boolean = false; AHoldStream: Boolean = false);
    destructor Destroy; override;
    procedure LogALineAsRawUnicode(Const s: String);
    procedure LogAUnicodeLine(Const s: String);
    procedure LogALine(const s: String);
    procedure LogAnError(const s: String);
    procedure ReleaseFileStream;
    Procedure RollAndFlagNewApplication(ANoNewAppFlag: Boolean = false);
    Procedure FlagNewApplication;
    function TotalFileSize: Int64;
    Class function LogFileAsSingleString(ALogName: string; AMaxSz: Int64)
      : AnsiString;
    property FileName: AnsiString read FFileName;
    property PurgeLogFilesOlderThan: TDateTime read FPurgeLogFilesOlderThan
      write SetPurgeLogFilesOlderThan;
    property HoldStream: Boolean read fHoldStream write fHoldStream;
    Property IngoreLogTime: Boolean read FIngoreLogTime Write SetIngoreLogTime;
  end;

function GeneralLogIsOpen: Boolean;
function GeneralLogName: AnsiString;
Function ISLogFileName(AInTemp: Boolean = true;
  AInDocs: Boolean = true): String;
function UniqueName: AnsiString;
function DefaultApplicationLogName(const ACompany
{$IFDEF NextGen}
  : AnsiString): AnsiString;
{$ELSE}
  : AnsiString = 'Innova Solutions')
: AnsiString;
{$ENDIF}
// You get an Object and you must free it
function AppendLogFileObject(FileName: AnsiString; ALimit: Integer = 0;
  ARollLog: Boolean = true): TLogFile;
// You get an Object and you must free it

// LocalAppendLogFile owns and manages  the object
function LogALineObject(s: AnsiString): TLogFile;
// Local LogALineObject owns and manages  the object
Procedure LogALine(s: AnsiString);
Procedure AppendLogFile(FileName: AnsiString; ALimit: Integer = 0;
  ARollLog: Boolean = false);
function PurgeFileStrmOverSz(AFileStream: TFileStream;
  ALimitSz: Integer): Boolean;
// Takes only the top 10% of a file over the Limit
// function FindALogFile(const ALogRootName:AnsiString=''):AnsiString;
Function LogDateStamp: String;
Function AddFormatedLogDateStamp(s: String): string;
Function AllPlatformExeFileNameFrmISProcCl: String;

Var
  SuppressChecksForTesting: Boolean = false;
  ExceptLog: TLogFile = nil;

Const
  cLogErrorFlag = 'Error:';

implementation

uses {ISStrUtl,} ISUnicodeStrUtl, IsindyUtils;

var
  LogFT: TLogFile = nil;
  IsNew: Integer = 67;

Function AllPlatformExeFileNameFrmISProcCl: String;
{ X.Env.SearchPath - Returns the currently registered search path on the system.
  X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
  X.Env.ExeFilename - Returns the actual filename of the running executable.
  X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
  X.Env.ExeFolder - Returns the full folder path to the executable.
  X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
  X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
}
{$IFDEF Android}
// {$IFDEF ISD103R_DELPHI}
// begin
// Result := System.IOUtils.TPath.GetAppPath + ApplicationNameIS;
// end;
// {$ELSE}
Const
  cPre = 'com.embarcadero.';
  cPost = '/files';
Var
  HomePath: String;
  idx: Integer;
Begin
  HomePath := System.IOUtils.TPath.GetHomePath;
  idx := Pos(cPre, HomePath);
  if idx > 3 then
  Begin
    idx := Pos(cPost, HomePath);
    if idx > 3 then
    Begin
      SetLength(HomePath, idx - 1);
      Result := HomePath;
    End
    else
      Result := 'Idx Ppst:' + IntToStr(idx);
  end;
end;
// {$ENDIF}
{$ELSE}
{$IFDEF POSIX}

Var
  i: Integer;
begin
  i := Pos('.app', Result);
  if i > 2 then
    SetLength(Result, i + 3);
end;
{$ELSE}

begin
  Result := ParamStr(0);
end;
{$ENDIF}{$ENDIF}

procedure PurgeFilesOlderThan(AMask: AnsiString; APurgeDate: TDateTime);
{$IFNDEF MsWindows}
Begin

end;
{$ELSE}

var
  SrchRec: TSearchRec;
  Rslt, FileDateVal, FileDateNow: Integer;
  FilePath: AnsiString;
  // s: AnsiString;
begin
  FilePath := ExtractFilePath(AMask);
  FileDateVal := DateTimeToFileDate(APurgeDate);
  FileDateNow := DateTimeToFileDate(Now);
  if FileDateVal >= FileDateNow then
    Exit;
  // Timeisin Error
  Inc(FileDateNow, 10);
  Rslt := FindFirst(AMask, 0, SrchRec);
  try
    while Rslt = 0 do
    begin
      if SrchRec.Time > FileDateNow then
        Exit; // Timeisin Error
      Rslt := FindNext(SrchRec);
    end;
  finally
    FindClose(SrchRec);
  end;

  Rslt := FindFirst(AMask, 0, SrchRec);
  try
    while Rslt = 0 do
    begin
      if SrchRec.Time < FileDateVal then
        // if (FilePath + SrchRec.Name)<>FFileName then
        If Not DeleteFile(FilePath + SrchRec.Name) then
        Begin
          // s := FilePath;
        end;
      Rslt := FindNext(SrchRec);
    end;
  finally
    FindClose(SrchRec);
  end;
end;
{$ENDIF}

Function ISLogFileName(AInTemp: Boolean = true;
  AInDocs: Boolean = true): String;
Begin
  if AInTemp then
    Result := TPath.Combine(TPath.GetTempPath, 'InnovaSolutionsLogs')
  else If AInDocs Then
    Result := TPath.Combine(TPath.GetDocumentsPath, 'InnovaSolutionsLogs');
  Result := TPath.Combine(Result,
    (ChangeFileExt(ExtractFileName(AllPlatformExeFileNameFrmISProcCl),
    '.log')));
End;

Function AddFormatedLogDateStamp(s: String): String;
begin
{$IFDEF NextGen}
  if s[0] = '#' then
  begin
    case s[1] of
      '1':
        Result := FormatDateTime('nn:ss.zzz ', Now) + copy(s, 2, 255);
      // Default
      '2':
        Result := FormatDateTime('hh:nn:ss ', Now) + copy(s, 2, 255);
      '3':
        Result := FormatDateTime('dd hh:nn:ss ', Now) + copy(s, 2, 255)
    Else
      Result := FormatDateTime('nn:ss.zzz ', Now) + copy(s, 1, 255); // Default
    end;
  end
{$ELSE}
  if s[1] = '#' then
  begin
    case s[2] of
      '1':
        Result := FormatDateTime('nn:ss.zzz ', Now) + copy(s, 3, 255);
      // Default
      '2':
        Result := FormatDateTime('hh:nn:ss ', Now) + copy(s, 3, 255);
      '3':
        Result := FormatDateTime('dd hh:nn:ss ', Now) + copy(s, 3, 255)
    Else
      Result := FormatDateTime('nn:ss.zzz ', Now) + copy(s, 2, 255); // Default
    end;
  end
{$ENDIF}
  else
    Result := s;
end;

Function LogDateStamp: String;
Begin
  Result := FormatDateTime('dd mmm yyyy hh:mm:ss', Now);
End;

function UniqueName: AnsiString;
var
  i: Integer;
  r: TDateTime;
begin
  r := Frac(Now) * 3333333;
  i := Trunc(r);
  Result := 'UN' + FormatDateTime('ddmmyy_ddd_hhnnssz', Now) + 'z' +
    IntToStr(i);
end;

function DefaultApplicationLogName(const ACompany: AnsiString): AnsiString;
var
  FileName: AnsiString;
begin
  FileName := ExtractFileName(ParamStr(0));
  if ACompany <> '' then
    Result := TPath.GetHomePath + TPath.PathSeparator + ACompany +
      TPath.PathSeparator + 'logs' + TPath.PathSeparator +
      ChangeFileExt(FileName, '.log')
  else
    Result := TPath.GetHomePath { GetMyAppsDataFolder } + TPath.PathSeparator +
      'logs' + TPath.PathSeparator + ChangeFileExt(FileName, '.log');
end;

function GeneralLogIsOpen: Boolean;
begin
  Result := LogFT <> nil;
end;

function GeneralLogName: AnsiString;
begin
  If LogFT = nil Then
    Result := ''
  else
    Result := LogFT.FileName;
end;

function LogALineObject(s: AnsiString): TLogFile;
begin
  try
    if LogFT = nil then
      LogFT := TLogFile.Create(UniqueName + '.log', false)
    else if IsNew = 67 then
      LogFT.LogALine(#13#10 + ' Appended on ' + LogDateStamp);
    IsNew := 0;
    if LogFT <> nil then
      LogFT.LogALine(s);
  except
    // Writeln(s);
  end;
  Result := LogFT;
end;

Procedure LogALine(s: AnsiString);
Begin
  LogALineObject(s);
end;

function AppendLogFileObject(FileName: AnsiString; ALimit: Integer;
  ARollLog: Boolean): TLogFile;
begin
  Result := TLogFile.Create(FileName, true, ALimit, ARollLog);
end;

function LocalAppendLogFile(FileName: AnsiString; ALimit: Integer;
  ARollLog: Boolean): TLogFile;
Var
  Conflict: Boolean;
  OldFileName: AnsiString;
begin
  Conflict := true;
  if LogFT = nil then
    Conflict := false
  else if FileName <> '' then
    if LogFT.FileName <> FileName then
    Begin
      OldFileName := LogFT.FileName;
      LogFT.LogALine('Potential Log Conflict ' + FileName);
      FreeAndNil(LogFT);
    end;

  if LogFT = nil then
  begin
    IsNew := 67;
    LogFT := TLogFile.Create(FileName, true, ALimit, ARollLog);
    if Conflict then
      LogFT.LogALine('Potential Log Conflict ' + OldFileName);
  End;
  Result := LogFT;
end;

Procedure AppendLogFile(FileName: AnsiString; ALimit: Integer = 0;
  ARollLog: Boolean = false);
begin
  LocalAppendLogFile(FileName, ALimit, ARollLog);
end;

function PurgeFileStrmOverSz(AFileStream: TFileStream;
  ALimitSz: Integer): Boolean;
var
  MemStream: TMemoryStream;
  OldSz: Int64;
  ToCopy: Int64;
  s: AnsiString;

begin
  raise Exception.Create
    ('Not sure PurgeFileStrmOverSz does what we want it to');

  Result := false;
  if ALimitSz < 1000 then
    raise Exception.Create('PurgeFileStrmOverSz too small');
  if AFileStream = nil then
    Exit;
  OldSz := AFileStream.Seek(Int64(0), soFromEnd);
  if (OldSz < ALimitSz) then
    Exit;

  try
    AFileStream.Position := OldSz - Trunc(ALimitSz * 0.1);
    ToCopy := OldSz - AFileStream.Position;
    MemStream := TMemoryStream.Create;
    try
      MemStream.CopyFrom(AFileStream, ToCopy);
      AFileStream.Position := 0;
      AFileStream.Size := 0;
      s := #13#10 + '<Truncating Here :: ' + LogDateStamp + '>' +
        #13#10 + #13#10;
{$IFDEF NextGen}
      s.WriteBytesToStrm(AFileStream, s.Length);
{$ELSE}
      AFileStream.Write(s[1], Length(s));
{$ENDIF}
      MemStream.Position := 0;
      AFileStream.CopyFrom(MemStream, 0);
    finally
      MemStream.Free;
    end;
    Result := true;
  except
    on E: Exception do
      raise Exception.Create('PurgeFileStrmOverSz::' + E.Message);
  end;
end;

{ TLogFile }

function TLogFile.AssciiOnly(s: string): AnsiString;
{ sub } Function NonPrintAsChar(val: Integer): String;
  Var
    ValS: String;
  begin
    ValS := IntToStr(val);
    Result := '[' + ValS + ']';
  end;

Var
  Rslt: String;
  i, val, Count: Integer;
begin
  if IsAssciiOnly(s) then
    Result := s
  else
  begin
    Rslt := '';
{$IFDEF NextGen}
    i := 0;
    Count := Length(s);
{$ELSE}
    i := 1;
    Count := Length(s) + 1;
{$ENDIF}
    while i < Count do
    begin
      val := Ord(s[i]);
      if val > 254 then
        Rslt := Rslt + NonPrintAsChar(val)
      Else
      begin
        if val > 127 then
          val := val - 128;
        if val > 31 then
          Rslt := Rslt + Char(val)
        else if (val = 10) or (val = 13) then
          Rslt := Rslt + Char(val)
        else
          Rslt := Rslt + NonPrintAsChar(val);
      end;
      Inc(i);
    end;
    Result := Rslt;
  end;
end;

constructor TLogFile.Create(fName: AnsiString; AAppend: Boolean;
  ALimit: Integer; ARollLogWhenFull: { Roll Log Now } Boolean;
  AHoldStream: { Hold Stream between entries } Boolean);

var
  sz: Integer;

begin
  Try
    fHoldStream := AHoldStream;
    FLock := TCriticalSection.Create;
    FRollNotTruncate := ARollLogWhenFull;
    If ALimit = 0 then
      FLimitSz := 1000000
    else
      FLimitSz := ALimit;

    Try
      FPurgeLogFilesOlderThan := Now - 99;

      FFileName := ExpandFileName(fName);
      if not DirectoryExists(ExtractFileDir(FFileName)) then
        ForceDirectories(ExtractFileDir(FFileName));

      if not FileExists(FFileName) then
        OpenFileOnDelay;
    Except
{$IFDEF MSWindows}
      On E: Exception do
        OutputDebugString(PChar('TLogFile.Create' + E.Message));
{$ENDIF}
    end;

    if fHoldStream or AAppend then // need to create and check for rollover
    begin
      FreeAndNil(FFileStm);
      Try
        sz := TFile.GetSize(FFileName);
        if FLimitSz < sz then
          if (FLimitSz > 100) then
            if (FRollNotTruncate) then
              RollLogFile(true)
            else if (sz > 1000) then
            Begin
              FFileStm := TFileStream.Create(FFileName, fmShareDenyNone);
              PurgeFileStrmOverSz(FFileStm, FLimitSz);
            End;
      finally
        if not fHoldStream then
          FreeAndNil(FFileStm);
      end;
    end;
  Except
    On E: Exception do
    begin
      FreeAndNil(FFileStm);
{$IFDEF MSWindows}
      OutputDebugString(PChar('TLogFile.Create outer loop' + E.Message));
{$ENDIF}
    end;
  end;

End;

destructor TLogFile.Destroy;
begin
  Try
    Try
      if FLock <> nil then
        FLock.Acquire;
    Except
    End;
    FreeAndNil(FFileStm);
    // Writeln('Closing');

    if LogFT = self then
      LogFT := nil;
    if ExceptLog = self then
      ExceptLog := nil;

    FreeAndNil(FLock);
  Except
  End;
  inherited;
end;

procedure TLogFile.FlagNewApplication;
begin
  LogALine(#13#10#13#10 + 'New Instance of Application ' +
    ExtractFileName(AllPlatformExeFileNameFrmISProcCl) + ' ::  ' +
    FormatDateTime('dd mmm hh:nn:ss', Now));
end;

function TLogFile.IsAssciiOnly(s: string): Boolean;
Var
  i, Count, val: Integer;
begin
  Result := true;
{$IFDEF NextGen}
  i := 0;
  Count := Length(s);
{$ELSE}
  i := 1;
  Count := Length(s) + 1;
{$ENDIF}
  while Result and (i < Count) do
  Begin
    val := Ord(s[i]);
    If val < 32 then
    Begin
      if (val <> 10) and (val <> 13) then
        Result := false;
    End
    else if val > 126 then
      Result := false;
    Inc(i);
  End;
end;

procedure TLogFile.LogALine(const s: String);
Var
  AsciiS, Scrlf: AnsiString;
  NewLocalLast: String;
begin
  if FDisAbleLogging then
    Exit;
  if FLock = nil then
  Begin
    Scrlf := 'Just To Break';
    Exit;
  end;
  try
    AsciiS := AssciiOnly(s);
    NewLocalLast := AsciiS;
    if NewLocalLast = FLastLogMessage then
    Begin
      Inc(FLastLoggedRepeat);
      FLastLoggedTime := Now;
      Exit;
    End;

{$IFDEF NextGen}
    if s[0] = '#' then
{$ELSE}
    if s[1] = '#' then
{$ENDIF}
    Begin
      AsciiS := AddFormatedLogDateStamp(AsciiS);
      LogHourlyChange;
    End;
{$IFDEF NextGen}
    if IsNextGenPickup.Pos(cLogErrorFlag, s) = 1 then
{$ELSE}
    if Pos(cLogErrorFlag, s) = 1 then
{$ENDIF}
      // Add Date time before Error but do not screw up repeat message count
      LogALine('Error at ' + LogDateStamp);

    FLock.Acquire;
    try
      if FFileStm = nil then
        Try
          if not FileExists(FFileName) then
            OpenFileOnDelay;
          FFileStm := TFileStream.Create(FFileName, fmOpenReadWrite,
            fmShareDenyNone);
        Except
{$IFDEF MSWindows}
          On E: Exception do
            OutputDebugString(PChar('Exception in file ' + FFileName + '::' +
              E.Message));
{$ENDIF}
        End;
      if FFileStm = nil then
        Exit;

      Try
        FFileStm.Seek(Int64(0), soFromEnd);

        if FLastLoggedRepeat > 0 then
        Begin
          FLastLogMessage := AddFormatedLogDateStamp(FLastLogMessage);
          FLastLogMessage := FLastLogMessage + '<Sent ' +
            IntToStr(FLastLoggedRepeat) + ' more times until ' +
            FormatDateTime('dd hh:nn:ss', FLastLoggedTime) + '>' + #13#10;
{$IFDEF NEXTGEN}
          FLastLogMessage.WriteBytesToStrm(FFileStm, FLastLogMessage.Length);
{$ELSE}
          FFileStm.Write(FLastLogMessage[1], Length(FLastLogMessage));
{$ENDIF}
          FLastLoggedRepeat := 0;
        End;

        FLastLogMessage := NewLocalLast;
        Scrlf := AsciiS + #13#10;
{$IFDEF NEXTGEN}
        Scrlf.WriteBytesToStrm(FFileStm, Scrlf.Length);
{$ELSE}
        FFileStm.Write(Scrlf[1], Length(Scrlf));
{$ENDIF}
      Except
        FreeAndNil(FFileStm);
      End;
      try
        if FFileStm <> nil then
          if (FFileStm.Size > Round(1.2 * FLimitSz)) then
            if (FRollNotTruncate) then
              RollLogFile(FIngoreLogTime)
            else if (FFileStm.Position > 1000) then
              PurgeFileStrmOverSz(FFileStm, FLimitSz);
      except
      end;

      If Not HoldStream then
        FreeAndNil(FFileStm);
      // FFileStm.flush;
    Finally
      FLock.Release;
    end;
  Except
    On E: Exception do
    begin
      FreeAndNil(FFileStm);
    end;
  end;
end;

procedure TLogFile.LogALineAsRawUnicode(const s: String);
const
  OpenMessage: string = 'Next Entry Raw Unicode' + #10 + #13;
Var
  ByteLength: Integer;
  Scrlf: String;

begin
  if FDisAbleLogging then
    Exit;

  if FLock = nil then
    Exit;

  FLock.Acquire;
  try
    if FFileStm = nil then
      Try
        FFileStm := TFileStream.Create(FFileName, fmOpenReadWrite or
          fmShareDenyNone);
      Except
        if not FileExists(FFileName) then
        Begin
          OpenFileOnDelay;
          Try
            FFileStm := TFileStream.Create(FFileName, fmOpenReadWrite or
              fmShareDenyNone);
          Except
          End;
        End;
      End;

    if FFileStm = nil then
      Exit;

    if FFileStm <> nil then
    Begin
      FFileStm.Seek(Int64(0), soFromEnd);
      ByteLength := Length(OpenMessage) * 2;
      FFileStm.Write(OpenMessage[1], ByteLength);
      Scrlf := s + #13#10;
      ByteLength := Length(Scrlf) * 2;
      FFileStm.Write(Scrlf[1], ByteLength);
    End;
    try
      if FFileStm <> nil then
        if (FFileStm.Size > Round(1.2 * FLimitSz)) then
          RollLogFile(FIngoreLogTime);
    except
    end;
    If Not HoldStream then
      FreeAndNil(FFileStm);
  Finally
    FLock.Release;
  end;
end;

procedure TLogFile.LogAnError(const s: String);
begin
  LogALine(cLogErrorFlag + s);
end;

procedure TLogFile.LogAUnicodeLine(const s: String);
Var
  s8: Utf8String;
begin
  s8 := s;
  LogALine(AnsiFrmUtf8(s8));
end;

class function TLogFile.LogFileAsSingleString(ALogName: string; AMaxSz: Int64)
  : AnsiString;
Var
  Stm: TFileStream;
{$IFNDEF NextGen}
  BytesRead: Int64;
{$ENDIF}
begin
  if not(FileExists(ALogName)) then
    Result := ''
  else
  begin
    Stm := nil;
    try
      try
        Stm := TFileStream.Create(ALogName, fmOpenReadWrite or fmShareDenyNone);
      except
        Stm := nil;
      end;
      if Stm = nil then
        Result := ''
      else
      begin
{$IFDEF NextGen}
        Result.ReadBytesFrmStrm(Stm, AMaxSz);
{$ELSE}
        SetLength(Result, AMaxSz);
        BytesRead := Stm.Read(Result[1], AMaxSz);
        if (BytesRead < AMaxSz) then
          SetLength(Result, BytesRead);
{$ENDIF}
      end;
    Finally
      Stm.Free;
    end;
  end;
end;

procedure TLogFile.LogHourlyChange;
Var
  ThisHour: String;
begin
  ThisHour := FormatDateTime('hh', Now);
  if ThisHour <> FLastLoggedHour then
  Begin
    FLastLoggedHour := ThisHour;
    LogALine(FormatDateTime('dd-mm-yy hh:mm', Now));
  End;
end;

procedure TLogFile.OpenFileOnDelay;
Var
  Count: Integer;
Begin
  if FInRollLogFile then
    Exit;

  Count := 5;
  while (Count > 0) and Not FileExists(FFileName) do
  begin
    Sleep(100); // give it time to Roll
    Dec(Count);
  end;

  if not FileExists(FFileName) then
    OpenNewFileCopy;
End;

procedure TLogFile.OpenNewFileCopy;
Var
  LocalStm: TFileStream;
  s: AnsiString;
begin
  if FileExists(FFileName) then
    Exit;
  if Trim(FFileName) = '' then
    Exit;
  Try
    FLock.Acquire;
    Try
      FreeAndNil(FFileStm);
      s := LogDateStamp + #13#10;
      LocalStm := TFileStream.Create(FFileName, FmCreate);
      Try
{$IFDEF NextGen}
        s.WriteBytesToStrm(LocalStm, s.Length);
{$ELSE}
        LocalStm.Write(s[1], Length(s));
{$ENDIF}
      Finally
        FreeAndNil(LocalStm);
      End;
    Finally
      FLock.Release;
    End;
  Except
{$IFDEF MSWindows}
    On E: Exception do
      OutputDebugString(PChar('NewLogFile Exception::' + E.Message));
{$ENDIF}
  End;
end;

procedure TLogFile.PurgeOldLogFiles;
var
  ExtStub, NewFileName: AnsiString;

begin
  if FFileName = '' then
    Exit;
  if (FPurgeLogFilesOlderThan < 9) then
    Exit;

  ExtStub := ExtractFileExt(FFileName);
  NewFileName := copy(FFileName, 1, Length(FFileName) - Length(ExtStub)) + '*'
    + ExtStub;
  PurgeFilesOlderThan(NewFileName, FPurgeLogFilesOlderThan);
end;

procedure TLogFile.ReleaseFileStream;
begin
  FreeAndNil(FFileStm);
end;

procedure TLogFile.RollAndFlagNewApplication(ANoNewAppFlag: Boolean);
begin
  if LogFT = nil then
    LogFT := self;

  if LogFT <> self then
  Begin
    LogALine('Error LogFt<>Self :' + FFileName);
    LogFT.LogALine('Error LogFt<>Self :' + FFileName);
  End;

  if FileExists(FFileName) then
  Begin
    FLock.Acquire;
    Try
      LogALine('Opening new copy of ' + FFileName);
      RollLogFile(true);
    Finally
      FLock.Release;
    End;
  End;
  if not ANoNewAppFlag then
    FlagNewApplication;
end;

procedure TLogFile.RollLogFile(AIgnoreTimeCheck: Boolean);
var
  NewName, CreateName, s: AnsiString;
  CrtFile: TFileStream;
  Extn: AnsiString;
  CreateTime: TDateTime;
  WillDisAbleLogging: Boolean;
begin
  If FInRollLogFile then
    Exit;
  try
    FInRollLogFile := true;
    WillDisAbleLogging := FDisAbleLogging;
    FLock.Acquire;
    try
      FDisAbleLogging := false;

      Extn := ExtractFileExt(FFileName);
      NewName := ChangeFileExt(FFileName, FormatDateTime('mmddsszzz',
        Now) + Extn);
      CreateName := ChangeFileExt(FFileName, 'crt');
      While FileExists(CreateName) do
        DeleteFile(CreateName);

      CrtFile := TFileStream.Create(CreateName, FmCreate);
      Try
        s := LogDateStamp + #13#10;
        CrtFile.Write(s[1], Length(s));
        s := 'Rolled File Prev Copy was ' + NewName + #13#10#13#10#13#10;
        CrtFile.Write(s[1], Length(s));
      Finally
        CrtFile.Free;
      End;

      LogALine('Rolling ' + FFileName + ' to ' + NewName);
      LogALine(LogDateStamp);
      CreateTime := TFile.GetCreationTime(FFileName);
      if not AIgnoreTimeCheck then
        if (CreateTime > Now - 0.25) and not SuppressChecksForTesting then
        begin
          LogALine('#Attempted Rolling of File less than 6 hours old');
          LogALine('#Logging Disabled');
          WillDisAbleLogging := true;
          FPurgeLogFilesOlderThan := Now - (Now - CreateTime) * 10;
        end;
      FreeAndNil(FFileStm);

      if RenameFile(FFileName, NewName) then
        if RenameFile(CreateName, FFileName) then
          LogALine('# Rolled File Prev Copy was ' + NewName);

      FreeAndNil(FFileStm);
    Except
{$IFDEF MSWindows}
      On E: Exception do
        OutputDebugString(PChar('LogFile Exception::' + E.Message));
{$ENDIF}
    End;
    FLock.Release;
  finally
    FInRollLogFile := false;
    FDisAbleLogging := WillDisAbleLogging;
    FreeAndNil(FFileStm);
  end;
  PurgeOldLogFiles;
end;

procedure TLogFile.SetIngoreLogTime(const Value: Boolean);
begin
  FIngoreLogTime := Value;

end;

procedure TLogFile.SetPurgeLogFilesOlderThan(const Value: TDateTime);
begin
  if Value > 99 then // This is the date
    FPurgeLogFilesOlderThan := Value
  else
    FPurgeLogFilesOlderThan := 0.0;
  PurgeOldLogFiles;
end;

function TLogFile.TotalFileSize: Int64;
Var
  Stm: TFileStream;
begin
  Stm := FFileStm;
  if Stm = nil then
    Try
      Stm := TFileStream.Create(FFileName, fmOpenReadWrite or fmShareDenyNone);
      Stm.Seek(Int64(0), soFromEnd);
    Except
      Stm := nil;
    End;
  if Stm = nil then
    Result := 0
  else
  begin
    Result := Stm.Position;
    if Result > Stm.Size then
      raise Exception.Create('FFileStm.Position>FFileStm.Size');
  end;
  if FFileStm = nil then
    Stm.Free;
end;

initialization

LogFT := nil;

finalization

FreeAndNil(LogFT);

end.
