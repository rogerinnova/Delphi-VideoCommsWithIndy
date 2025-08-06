unit ISIndyUtils;
{$IfDef FPC}
{$mode delphi}
{$EndIf}
{ see Also IdGlobal  To and From Bytes conversion routines
  function ToBytes(const AValue: string; ADestEncoding: TIdTextEncoding = nil
  function ToBytes(const AValue: string; const ALength: Integer; const AIndex: Integer = 1;
  function ToBytes(const AValue: Char; ADestEncoding: TIdTextEncoding = nil
  function ToBytes(const AValue: LongInt): TIdBytes; overload;
  function ToBytes(const AValue: Short): TIdBytes; overload;
  function ToBytes(const AValue: Word): TIdBytes; overload;
  function ToBytes(const AValue: Byte): TIdBytes; overload;
  function ToBytes(const AValue: LongWord): TIdBytes; overload;
  function ToBytes(const AValue: Int64): TIdBytes; overload;
  function ToBytes(const AValue: TIdBytes; const ASize: Integer; const AIndex: Integer = 0): TIdBytes; overload;
  function RawToBytes(const AValue; const ASize: Integer): TIdBytes;
  // The following functions are faster but except that Bytes[] must have enough
  // space for at least SizeOf(AValue) bytes.
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: Char; ADestEncoding: TIdTextEncoding = nil
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: LongInt); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: Short); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: Word); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: Byte); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: LongWord); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: Int64); overload;
  procedure ToBytesF(var Bytes: TIdBytes; const AValue: TIdBytes; const ASize: Integer; const AIndex: Integer = 0); overload;
  procedure RawToBytesF(var Bytes: TIdBytes; const AValue; const ASize: Integer);
  function ToHex(const AValue: TIdBytes; const ACount: Integer = -1; const AIndex: Integer = 0): string; overload;
  function ToHex(const AValue: array of LongWord): string; overload; // for IdHash
  function BytesToString(const AValue: TIdBytes; AByteEncoding: TIdTextEncoding = nil
  function BytesToString(const AValue: TIdBytes; const AStartIndex: Integer;
  function BytesToStringRaw(const AValue: TIdBytes): string; overload;
  function BytesToStringRaw(const AValue: TIdBytes; const AStartIndex: Integer;
  function BytesToChar(const AValue: TIdBytes; var VChar: Char; const AIndex: Integer = 0;
  function BytesToShort(const AValue: TIdBytes; const AIndex: Integer = 0): Short;
  function BytesToWord(const AValue: TIdBytes; const AIndex : Integer = 0): Word;
  function BytesToLongWord(const AValue: TIdBytes; const AIndex : Integer = 0): LongWord;
  function BytesToLongInt(const AValue: TIdBytes; const AIndex: Integer = 0): LongInt;
  function BytesToInt64(const AValue: TIdBytes; const AIndex: Integer = 0): Int64;
  function BytesToIPv4Str(const AValue: TIdBytes; const AIndex: Integer = 0): String;
  procedure BytesToIPv6(const AValue: TIdBytes; var VAddress: TIdIPv6Address; const AIndex: Integer = 0);
  procedure BytesToRaw(const AValue: TIdBytes; var VBuffer; const ASize: Integer);
}
{$IfDef FPC}
{$I InnovaLibDefsLaz.inc}
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}

interface

Uses
{$IFDEF MSWindows}
  WinApi.Windows,
{$ENDIF}
  IsProcCl, IdGlobal, Classes, SyncObjs, sysutils,
{$IFNDEF FPC}
  IOUtils,
{$ENDIF}
  DateUtils,
  IsLogging
{$IFDEF NextGen}
    , ISObjectCounter, IsNextGenPickup
{$ENDIF}
{$IFDEF ISXE2_DELPHI}
{$IFDEF FMXApplication}
    , fmx.Graphics // fmx.imaging.JPeg;
{$ELSE}
{$IFNDEF ISLazarus}
    , vcl.Graphics, vcl.imaging.JPeg
{$ELSE}
    , Graphics
{$ENDIF}
{$ENDIF}
    ;
/// /, JPeg;
{$ENDIF}

type
  TGblRptCount = class(TObject)
  public
    FCount: integer;
    Class Function New: TGblRptCount;
    Function Count: integer;
    Procedure IncDec(AUp: boolean);
  end;

  TGblRptComs = Class(TObject)
  private
    FListOfData: TStringlist; // Of TGblRptCount
    FLock: TCriticalSection;
    Function Report: String;
  Public
    Constructor Create;
    Destructor Destroy; override;
    Class Function ReportObjectTypes: String;
    procedure CountComsTypes(AObj: TObject; ANew: boolean);
  end;

Function ToBytesIS(const val: AnsiString): TIdBytes; overload;
{$IFDEF FPC}
Function ToBytesIS(const val: UnicodeString): TIdBytes; overload;
{$ELSE}
Function ToBytesIS(const val: String): TIdBytes; overload;
{$ENDIF}
Function BytesToAnsiStringIS(AVal: TIdBytes): AnsiString;
Function GraphicToAnsi(IGraphicOut: TObject): AnsiString;
Function GraphicToBytes(IGraphicOut: TObject): TIdBytes;
function BytesToGraphic(AData: TIdBytes): TObject; { }

function IsNotMainThread: boolean;
Procedure ISIndyUtilsException(Const AClassName, AExMessage: String); overload;
Procedure ISIndyUtilsException(AObject: TObject; AExMessage: String); overload;
Procedure ISIndyUtilsException(AObject: TObject; AException: Exception;
  AExMessage: String); overload;
Procedure ISIndyUtilsException(AObject: TObject;
  AException: Exception); overload;
Procedure ISIndyUtilsException(Const AClassName: string; AException: Exception;
  AExMessage: String); overload;
Procedure SetExceptionLog(AExceptLogName: AnsiString;
  AStartNewLogFile: boolean = false);
Function ExceptionLogName: string;
Procedure FreeSListWObjects(var ThisList: TStringlist);

Var
  GCountOfHistoricalCons, GCountOfConnections: integer; // Base Connections
  GlobalCountOfComsObjectTypes: TGblRptComs;

implementation

uses
  IsGblLogCheck, ISUnicodeStrUtl;

Const
  // Copied From ISPermObjFileStm
  NullObjectFlag = 65535 { MaxWord };
  ObjRegBitMapObj = 11115;
  ObjRegMetaFileObj = 11116;
  ObjRegIconObj = 11117;
  ObjRegJPEGObj = 11118;
{$IFDEF NEXTGEN}
  ZSISOffset = -1; // Zero Based String OffSet Cons
{$ELSE}
  ZSISOffset = 0;
{$ENDIF}

procedure FreeSListWObjects(var ThisList: TStringlist);
var
  i: integer;
  List: TStringlist;
  // s: string;
{$IFDEF AUTOREFCOUNT}
  CCount: integer;
{$ENDIF}
  Obj: TObject;

begin
  if ThisList = nil then
    Exit;

  List := ThisList;
  ThisList := nil;
  try
    if List <> nil then
      with List do
        for i := 0 to (Count - 1) do
          try
            if Objects[i] <> nil then
            begin
              Obj := Objects[i];
{$IFDEF AUTOREFCOUNT}
              // CCount := Obj.RefCount;
              // CCount := DecodeRefCount(Obj);
{$ENDIF}
              Objects[i] := nil;
{$IFDEF AUTOREFCOUNT}
              // CCount := Obj.RefCount;
              // CCount := DecodeRefCount(Obj);
              DisposeOfAndNil(Obj);
              // TObject(Obj).Free;
{$ELSE}
              Obj.Free;
{$ENDIF}
            end;
          except
            // s := 'vvvvv' + IntToStr(i);
          end;
  finally
    List.Free;
  end;
end;

Function BytesToAnsiStringIS(AVal: TIdBytes): AnsiString;
Var
  i: integer;
Begin
{$IFDEF NextGen}
  i := Length(AVal);
  Result.CopyBytesFromMemory(AVal, i);
{$ELSE}
  SetLength(Result, Length(AVal));
  for i := 1 to High(Result) do
    Result[i] := AnsiChar(AVal[i - 1]);
{$ENDIF}
End;

Function ToBytesIS(const val: AnsiString): TIdBytes; overload;
var
  Len, i: integer;
begin
  Len := Length(val);
  SetLength(Result, Len);
  For i := 0 to Len - 1 do
    Result[i] := Byte(val[i + 1]);
end;

{$IFDEF FPC}

Function ToBytesIS(const val: UnicodeString): TIdBytes; overload;
{$ELSE}

Function ToBytesIS(const val: String): TIdBytes; overload;
{$ENDIF}
var
  Len, i: integer;
  ss: AnsiString;
begin
  ss := UnicodeAsAnsi(val);
  // Len:=Length(val)*StringElementSize(Val);
  Len := Length(ss);
  SetLength(Result, Len);
  For i := 0 to Len - 1 do
    Result[i] := Byte(ss[i + 1]);
end;

Function GraphicToAnsi(IGraphicOut: TObject): AnsiString;
// From  procedure WriteStrmGraphic(s: Tstream; IGraphicOut: Pointer);
var
  Sz, Sz2: longint;
  GType: Word;
{$IFDEF FMXApplication}
  GraphicOut: TBitMap;
{$ELSE}
  GraphicOut: TGraphic;
{$ENDIF}
  m: TMemoryStream;
  s: TMemoryStream;

begin
  m := nil;
  s := nil;
  if IGraphicOut = nil then
    GType := NullObjectFlag
  else if IGraphicOut is TBitMap then
    GType := ObjRegBitMapObj
{$IFDEF FMXApplication}
{$ELSE}
{$IFNDEF ISLazarus}
  else if IGraphicOut is TMetaFile then
    GType := ObjRegMetaFileObj
{$ENDIF}
  else if IGraphicOut is TIcon then
    GType := ObjRegIconObj
  else if IGraphicOut is TJPEGImage then
    GType := ObjRegJPEGObj
{$ENDIF}
  else
    raise Exception.Create('Invalid Graphic to File');
  try
    m := TMemoryStream.Create;
    s := TMemoryStream.Create;
    if IGraphicOut <> nil then
    begin
      GraphicOut := IGraphicOut as
{$IFDEF FMXApplication}
        TBitMap;
{$ELSE}
        TGraphic;
{$ENDIF}
      GraphicOut.SaveToStream(m);
      Sz := m.Size;
      s.Write(GType, Sizeof(GType));
      GType := 0;
      s.Write(Sz, Sizeof(Sz));
      if Sz > 0 then
        s.CopyFrom(m, 0);
      Sz := Sz + Sizeof(GType) + Sizeof(Sz);
      s.Seek(longint(0), soFromBeginning);
      s.Read(GType, Sizeof(GType));
      s.Read(Sz2, Sizeof(Sz2));
      s.Seek(longint(0), soFromBeginning);
{$IFDEF NEXTGEN}
      Result.ReadBytesFrmStrm(s, Sz);
{$ELSE}
      SetLength(Result, Sz);
      s.Read(Result[1], Sz);
{$ENDIF}
    end;
  finally
    m.Free;
    s.Free;
  end; { try }
end;

Function GraphicToBytes(IGraphicOut: TObject): TIdBytes;
begin
  Result := ToBytesIS(GraphicToAnsi(IGraphicOut));
end;

function BytesToGraphic(AData: TIdBytes): TObject; { }
// From  function ReadStrmGraphic(s: Tstream): Pointer; { }
var
  m: TMemoryStream;
{$IFDEF FMXApplication}
  g: TBitMap;
{$ELSE}
  g: TGraphic;
{$ENDIF}
  Sz: longint;
  GraphicStart: Word;
begin
  m := nil;
  g := nil;
  try
    m := TMemoryStream.Create;
    // g := nil;
    m.Write(AData[0], Length(AData));
    m.Seek(longint(0), soFromBeginning);
    m.Read(GraphicStart, Sizeof(GraphicStart));
    case GraphicStart of
      ObjRegBitMapObj:
        g := TBitMap.Create;
{$IFDEF FMXApplication}
{$ELSE}
{$IFNDEF IsLazarus}
      ObjRegMetaFileObj:
        g := TMetaFile.Create;
{$ENDIF}
      ObjRegIconObj:
        g := TIcon.Create;
      ObjRegJPEGObj:
        g := TJPEGImage.Create;
{$ENDIF}
      NullObjectFlag:
        g := nil;
    else
      raise Exception.Create('Invalid Graphic in BytesToGraphic');
    end; { case }
    if g <> nil then
    begin
      m.Read(Sz, Sizeof(Sz));
      g.LoadFromStream(m);
    end;
  finally
    m.Free;
  end;
  Result := g;
end;

function IsNotMainThread: boolean;
Begin
  Result := Not(TThread.CurrentThread.ThreadID = MainThreadID);
  if Result then
    // Assign a method to WakeMainThread before calling a thread's Synchronize method.
    Result := Assigned(WakeMainThread);
End;

Var
  ExceptLog: TLogFile = nil;

Function InitialiseExceptionLog(ALogName: string; AStartNewLogFile: boolean)
  : TLogFile;
Var
  Extn, NewName: String;

Begin
  Result := ExceptLog;
  If Result <> nil then
    Exit;

  If ALogName = '' then
    ALogName := ExceptionLogName;

  if AStartNewLogFile and FileExists(ALogName) then
  Begin
    Extn := ExtractFileExt(ALogName);
    NewName := ChangeFileExt(ALogName, FormatDateTime('mmddsszzz', now) + Extn);
    RenameFile(ALogName, NewName);
  end;
  Result := TLogFile.Create(ALogName, true, 100000, true);
  if (Result<>nil) And AStartNewLogFile then
     Result.PurgeLogFilesOlderThan:= Now - 3/24;
  Result.LogALine(#13#10#13#10 + 'New Instance of Application ' +
    FormatDateTime('dd mmm hh:nn:ss', now));
  Result.LogALine(ALogName);
  // Result.HoldStream := false; // Normal case

  if not GeneralLogIsOpen then
    AppendLogFile(ALogName, 100000, false)
  else if ALogName = GeneralLogName then
    Exit
  else
  Begin
    IsLogging.LogALine(#13#10#13#10 + 'Now using ExceptLog.LogALine(LogNm)=' +
      ALogName + #13#10#13#10);
    AppendLogFile(ALogName, 100000, false);
  end;
end;

Procedure SetExceptionLog(AExceptLogName: AnsiString;
  AStartNewLogFile: boolean = false);
Begin
  If AExceptLogName = '' then
    Exit;

  If ExceptLog <> nil Then
    if not(Lowercase(AExceptLogName) = Lowercase(ExceptLog.FileName)) then
    Begin
      ISIndyUtilsException('Creating A New Exception Log ', AExceptLogName);
      FreeAndNil(ExceptLog);
    end;

  ExceptLog := InitialiseExceptionLog(AExceptLogName, AStartNewLogFile);

  if Not GLogISIndyUtilsException then
    Begin
     GLogISIndyUtilsException:=true;
     ISIndyUtilsException('SetExceptionLog','# Auto Set GLogISIndyUtilsException');
    end;
end;

Function ExceptionLogName: string;
begin
  If ExceptLog <> nil then
    Result := ExceptLog.FileName
  else
{$IFDEF Android}
    Result := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetHomePath,
      'AppExceptLog');
{
Need to follow up Chester Wilson post
https://forums.adug.org.au/t/file-access-assistance-for-android/60847

>If some of you are still struggling with Android file i/o, this may be some help.
>I have spent the last few months trying hard (with a huge amount of support and help from Dave Nottage!) to put together a programme which can find files, read files (character and getting the android system to view them), write and append to files, create directories, and delete files and directories.
>It is not the fastest, using the routines which are nearly simple enough for me to understand. If you have a directory with a thousand files, be prepared to enjoy a cup of tea while you wait!
>
>This programme “FileAccess” is available via
>https://59b7770ca3fb18e4e90d-52e2682744779750b5103bbecf998085.ssl.cf2.rackcdn.com/FileAccess.zip

}

{$ELSE}
    Result := ChangeFileExt(ExeFileNameAllPlatforms, '.log');
{$ENDIF}
end;

Procedure ISIndyUtilsException(Const AClassName, AExMessage: String);
Var
  ss, LogNm: String;
  PosTimeHash, LenHash: integer;
Begin
  if GLogISIndyUtilsException then
  begin
    if ExceptLog = nil then
    Begin
      LogNm := ExceptionLogName;
      ExceptLog := InitialiseExceptionLog(LogNm, false);
    end;
    ss := AClassName;
    ss := ss + '::' + AExMessage;
    PosTimeHash := Pos('#', ss);
    if PosTimeHash < Length(ss)+1 then
      if PosTimeHash > 1 then
        if (PosTimeHash < (Length(ss)-1))  and IsNumeric(ss[PosTimeHash + 1]) then
          ss := '#' + ss[PosTimeHash + 1+ ZSISOffset] + Stringreplace(ss,
            '#' + ss[PosTimeHash + 1 + ZSISOffset], '', [])
        else
          ss := '#' + Stringreplace(ss, '#', '', []);
    ExceptLog.LogALine(ss);
  end;
{$IFDEF Debug}
{$IFDEF MSWindows}
  OutputDebugString(PChar('ISIndyUtils::' + ss));
{$ENDIF}
{$ENDIF}
End;

Procedure ISIndyUtilsException(Const AClassName: string; AException: Exception;
  AExMessage: String); overload;
var
  Msg: string;
Begin
  Msg := AException.ClassName + '<' + AException.Message + '>::' + AExMessage;
  ISIndyUtilsException(AClassName, Msg);
End;

Procedure ISIndyUtilsException(AObject: TObject; AExMessage: String); overload;
Begin
  if AObject = nil then
    ISIndyUtilsException('Null Object', AExMessage)
  else
    ISIndyUtilsException(AObject.ClassName, AExMessage);
End;

Procedure ISIndyUtilsException(AObject: TObject; AException: Exception;
  AExMessage: String); overload;
Begin
  ISIndyUtilsException(AObject, AException.ClassName + '<' + AException.Message
    + '>::' + AExMessage);
End;

Procedure ISIndyUtilsException(AObject: TObject;
  AException: Exception); overload;
Begin
  ISIndyUtilsException(AObject, AException, '');
End;

{ TGblRptComs }

procedure TGblRptComs.CountComsTypes(AObj: TObject; ANew: boolean);
Var
  index: integer;
  val: TGblRptCount;
begin
  if Assigned(FListOfData) then
  begin
    FLock.Acquire;
    try
      if not FListOfData.Find(AObj.ClassName, Index) then
        Index := FListOfData.AddObject(AObj.ClassName, TGblRptCount.New);
      if index > -1 then
      begin
        val := FListOfData.Objects[Index] as TGblRptCount;
        val.IncDec(ANew)
      end;
    finally
      FLock.Release;
    end;
  end;
end;

constructor TGblRptComs.Create;
begin
  If Assigned(GlobalCountOfComsObjectTypes) then
    raise Exception.Create('Only one copy of TGblRptComs Permitted');

  FListOfData := TStringlist.Create;
  FListOfData.Duplicates := dupError;
  FListOfData.Sorted := true;
  FListOfData.CaseSensitive := true;
  FListOfData.OwnsObjects := false; // not objects
  FLock := TCriticalSection.Create;
end;

destructor TGblRptComs.Destroy;
begin
  FLock.Free;
  inherited;
  FreeSListWObjects(FListOfData);
end;

function TGblRptComs.Report: String;
Var
  i: integer;
begin
  Result := '';
  FLock.Acquire;
  try
    if FListOfData.Count >= 0 then
      for i := 0 to FListOfData.Count - 1 do
        Result := Result + #13#10 + FListOfData[i] + ' (' +
          IntToStr(TGblRptCount(FListOfData.Objects[i]).Count) + ')';
    Result := Result + #13#10;
  finally
    FLock.Release;
  end;
end;

class function TGblRptComs.ReportObjectTypes: String;
Var
  i: integer;
Begin
  If not Assigned(GlobalCountOfComsObjectTypes) then
  begin
    GlobalCountOfComsObjectTypes := TGblRptComs.Create;
    Result := #13#10 + 'Start Reporting IP Objects - Total Historical=' +
      IntToStr(GCountOfHistoricalCons) + FormatDateTime('  dd mmm hh:nn', now);
  end
  else
  begin
    Result := #13#10 + 'Reporting IP Objects - ' +
      FormatDateTime('  dd mmm hh:nn', now) + #13#10 + 'Total current=' +
      IntToStr(GCountOfConnections) + ' and Total Historical=' +
      IntToStr(GCountOfHistoricalCons) + GlobalCountOfComsObjectTypes.Report;
  end;
End;

{ TGblRptCount }

function TGblRptCount.Count: integer;
begin
  Result := FCount;
end;

procedure TGblRptCount.IncDec(AUp: boolean);
begin
  If AUp then
    inc(FCount)
  else
    Dec(FCount);
end;

class function TGblRptCount.New: TGblRptCount;
begin
  Result := TGblRptCount.Create;
end;

initialization

finalization

FreeAndNil(ExceptLog);
FreeAndNil(GlobalCountOfComsObjectTypes);

end.
