{$I InnovaLibDefs.inc}
{$WARNINGS off}
unit ISProcCl;
{$IFDEF FPC}
{$MODE Delphi}
// {$I InnovaLibDefsLaz.inc}
{$ELSE}
// {$I InnovaLibDefs.inc}
{$ENDIF}
{ Bug Reports
  {Mod  4 October 2015   Restart PC added
  {Mod  10 May 2015   Memleak
  FreeMem(VersionInfo); }

{ TODO -oRoger -cWhen needed :
  Process Snap shot To Do
  https://learn.microsoft.com/en-us/windows/win32/api/tlhelp32/nf-tlhelp32-createtoolhelp32snapshot
  look for looping programs }

{$WARN SYMBOL_PLATFORM OFF}
{ ************************************************ }
{ Process Control Library Functions
  {   Delphi
  {   Copyright (c) 2000 - 2014
  {   Innova Solutions/R Connell }
{ ************************************************ }

{$IfDef Android)
{$Define  FMXApplication}
{$EndIf}

interface

uses
  inifiles,
{$IFDEF ISXE2_DELPHI}
  System.IOUtils,
{$IFDEF FMXApplication}
  FMX.Controls, {ISFmxTypes,}
{$ENDIF}
  System.Classes, System.UITypes, System.SyncObjs,
{$IFDEF NEXTGEN}
  IsNextGenPickup,
{$ENDIF}
{$IFDEF MSWINDOWS}
  System.Win.ComObj, System.Win.Registry,
  WinApi.ActiveX, WinApi.PsAPI,
  WinApi.Windows, WinApi.ShlObj, WinApi.ShellAPI,
{$ELSE}
  IsWindowsPickUp,
{$ENDIF}
  System.SysUtils;
{$ELSE}
{$IFDEF FPC}
 IsLazarusPickup, Classes, SyncObjs, Registry, SysUtils;
{$ELSE}
PsAPI, Classes, ActiveX, ComObj, Windows, ShlObj, SyncObjs,
  ShellAPI, Registry, SysUtils;
{$ENDIF}
{$ENDIF}

const
  NoFileFound = '\\NOFILE\\';
  DirFileC = '.';
  HomeDirC = '..';
  TempFilePrefix = '~TIS';

  cStdOutLog = '.Olg';
  cStdInExt = '.Sti';
  // Recomended extentions for

  CTerminateOnWait = 128;
  // From Windows >> 	There are no child processes to wait for.
  CTerminateOnFinished = 18; // There are no more files.
  // Ref http://www.symantec.com/connect/articles/windows-system-error-codes-exit-codes-description

type
  FileCreateOptions = (CreateBest, BestDir, CreateAbsolute, ConfirmOnly);
  FileSearchRange = (SearchAll, SearchDisk, SearchOneDir, SearchOneDirAndSubs,
    SearchPath);
  { search path not supported }

{$IFDEF MSWINDOWS}

  TTemporyFile = class(TObject)
  private
    FFileName: AnsiString;
    FHandle: THandle;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AllowFileActions;
    property Filename: AnsiString read FFileName;
    property Handle: THandle read FHandle;
  end;

  TInternationalSettings = Record
    Error: string;
    DefaultsystemUIlanguage: String;
    Systemlocale: String;
    DefaultTimeZone: String;
    ActiveKeyboards: String; // Sep|Sep
    KeyboardLayeredDriver: String;
    InstalledLanguages: String; // en-US|en-UK
    LanguageTypes: String; // Sep|Sep    Fully localized language   FLL|.
    FallBackLanguage: String;
  End;

  TIsCriticalSection = class(TCriticalSection)
  public
    function TryEnterD7Compat: Boolean;
  end;

  TISUnsortedStringList = Class(TStringList)
    // Insert Find into a list with sort = false
  public
    Function Find(const S: string; var Index: Integer): Boolean; override;
  End;

function CreateProcessAndWaitW(AppCommandLine: String;
  ATimeOutMilliseconds: DWord; Visiblity: DWord;
  StdInFileName, StdOutFileName: String; CreateDetached: Boolean = False;
  StdInHndle: THandle = 0; StdOutHndle: THandle = 0;
  ACloseOnTimeout: Boolean = False): DWord;

function CreateProcessAndWait(AppCommandLine: AnsiString;
  ATimeOutMilliseconds: DWord; Visiblity: DWord;
  StdInFileName, StdOutFileName: AnsiString; CreateDetached: Boolean = False;
  StdInHndle: THandle = 0; StdOutHndle: THandle = 0;
  ACloseOnTimeout: Boolean = False): DWord;
// Returns Exit Code
// Ref http://www.symantec.com/connect/articles/windows-system-error-codes-exit-codes-description
{$ENDIF}
{$IFNDEF FPC}
function ProcessStillActive(AProcHndle: DWord): Boolean;
{$ENDIF}
function ExeFileNameAllPlatforms: string;
function ExeFileDirectory: string;
Procedure SetExeFileDirectory;
{$IFDEF ISXE2_DELPHI}
function ExtractuSoftFilePath(const Filename: string): string;
function ExtractuSoftFileName(const Filename: string): string;
{$ENDIF}
{$IFDEF MSWINDOWS}
function CreateProcessAndReturnHandle(AppCommandLine: AnsiString;
  Visiblity: DWord; StdInFileName, StdOutFileName: AnsiString;
  CreateDetached: Boolean = False; StdInHndle: THandle = 0;
  StdOutHndle: THandle = 0): THandle;
// You must release Handle to Process

function ShellExecuteDocument(const Command, Parameters, Directory: AnsiString;
  Visiblity: DWord = SW_RESTORE; Action: AnsiString = 'open'): Boolean;
function ShellExecuteDocumentRetError(const Command, Parameters,
  Directory: AnsiString; Visiblity: DWord = SW_RESTORE;
  Action: AnsiString = 'open'): DWord;

function ExecuteCommandLineRequest(const AInput: AnsiString;
  const ACommand: AnsiString = 'CMD'): AnsiString;

Procedure ExecuteReBootOS;
Procedure ExecuteKillOS;

function SetPrivilege(sPrivilegeName: string; bEnabled: Boolean): Boolean;
// Service Routines
Function ServicePrivilageNotOK: Boolean;
function StopISService(AName: AnsiString; out AError: AnsiString): Boolean;
function StartISService(AName: AnsiString; out AError: AnsiString): Boolean;
function RetrieveServiceDetails(AName: AnsiString;
  out ABinaryName, AStartName, ADisplayName, AError: AnsiString): Boolean;
function QueryISServiceDetails(AName: AnsiString; out AType, AStatus: DWord;
  out AError: AnsiString): Boolean;
Function QueryIsServiceExists(AName: AnsiString): Boolean; overload;
Function QueryIsServiceExists(AName: AnsiString; Out AIsRunning: Boolean)
  : Boolean; Overload;

function ViewFileInNotePad(const ALogFileName: AnsiString): Boolean;

function LockUnLockMutex(const AName: AnsiString; Lock: Boolean;
  WaitMilliSecs: Integer): Boolean;

procedure Wait(const Msec: Integer);
function GetOSPlatform: LongInt;
function MemoryManage: Integer;
function CurrentMemoryUsage: Cardinal;
function CsiGetProcessMemory: Int64;
// Return the amount of memory used by the process

{$ENDIF}
function IsAnExeFileName(AFileName: String): Boolean;
// contains .exe or .com
function NextAvailableFileName(ABaseDesiredFileName: AnsiString): AnsiString;
// Returns d:\Dir\Dir2\ThisFile22.ext from d:\Dir\Dir2\ThisFile.ext or ThisFile.ext
function OpenIniFileIS: TIniFile;
function ApplicationNameIS: String;

function ExecuteableLongFileName: AnsiString;
// some web servers use short file name
function TotalFileSizeKBytes(const ADirectoryName, AFilter: String;
  ADoSubs: Boolean): LongInt;

function DataMatch(ABuf1, ABuf2: Pointer; ASize1, ASize2: LongWord): Boolean;
function FileDataMatch(const AFileNameOne, AFileNameTwo: AnsiString): Boolean;
function NoOfFilesMatchingMask(AMask: AnsiString): Integer;
function GetMyDocsFolder: String;

{$IFNDEF FPC}
{$IFDEF MSWINDOWS}
function GetWindowsFontFolder: String;
{$ENDIF}
function GetCommonAppsDataFolder: String;
function GetCommonDocsFolder: String;
function GetTemporaryFileFolder: String;
{$ENDIF}
function GetMyAppsDataFolder: String;
{$IFDEF MSWINDOWS}
function CopyFileIS(const ASourceFilename, ADestFileName: AnsiString): LongInt;
// Is this faster than CopyFileA() no about 2.5 times slower
function CopyFileWithDates(const ASourceFilename, ADestFileName: AnsiString;
  AFailIfExists: Boolean): Boolean;
function ChangeFileDate(const AFileName: AnsiString;
  ACreateTime, ALastAccess, AWriteTime: TDateTime): Boolean; overload;
function ChangeFileDate(const AFileName: AnsiString;
  ACreateTime, ALastAccess, AWriteTime: FileTime): Boolean; overload;
procedure FileDates(const ADirFileName: AnsiString;
  out ACreateTime, ALastAccess, AWriteTime: FileTime); overload;
function FileTimeStructureToDateTime(AFileTime: TFileTime): TDateTime;
function DateTimeToFileTimeStructure(ADateTime: TDateTime): TFileTime;
function ChangeFileDate(const AFileName: AnsiString; ATime: TDateTime;
  ACreateAcceesWrite: Byte): Boolean; overload;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3 All 4: LastAccessLast Write }
procedure FileDates(const ADirFileName: AnsiString;
  out ACreateTime, ALastAccess, AWriteTime: TDateTime); overload;
  //TFile.  Alternate functions

function ACLDBRecName(AFileName: String): String;
function SetDBFileShareAll(ADbFileName: AnsiString;
  ADoDirectory, ALeaveRecord: Boolean): Boolean;
{ Not Tested - SetDBFileShareAll }
{$IFDEF Win64}
{$ENDIF}
Function RecoverInternationalOnLineSettings: TInternationalSettings;
// Have not yet worked out how to make a 32bit exe run 64bit Dism.exe

function RunAsAdmin(hWnd: hWnd; Filename: string; Parameters: string): Boolean;
{ Not Tested - Run FileName As Admin }
Function FileCreatedAfter(Const AOldFileName, ANewFilename: AnsiString)
  : Boolean;
Function FileLastWriteAfter(Const AOldFileName, ANewFilename
  : AnsiString): Boolean;

function DirectoryOrFileDate(const ADirFileName: AnsiString;
  ACreateAcceesWrite: Byte): TDateTime;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3: Earliest Date - 4: Laste Date }
{$IFDEF UNICODE}
procedure CreateShortcutLink(const PathObj, PathLink, Desc, Param: WideString);
{$ELSE}
procedure CreateShortcutLink(const PathObj, PathLink, Desc, Param: AnsiString);
{$ENDIF}
function SearchForFile(DesiredDisk, DesiredDirectory, Filename: AnsiString;
  SearchRange: FileSearchRange; var ResultRec: TSearchRec): AnsiString;
  overload;

// Consider ForceDirectories
function CreateConfirmDirectory(DesiredDisk, DesiredDirectory: AnsiString;
  CreateOption: FileCreateOptions; var ResultRec: TSearchRec)
  : AnsiString; overload;

function FindFileExecuteableAssociations(AFileName: AnsiString): AnsiString;

function SetFileAssociations(AssExtention { .myp } ,
  AssInternalName { UniqueKeyName } , AssExeFile { Full Path of Exe File }
  : AnsiString): Boolean;
// Not Built Not Tested Notes Only
function ForceTerminateThread(var ThisThread: TThread): Boolean;

function WindowsErrorString(OptionalCode: DWord): AnsiString;
// Returns Last Error as String;

{
  Function SendMailMAPI
  The MAPISendMail function sends a standard message.

  Syntax

  MAPISendMail(Session as Long,
  UIParam as Long,
  Message as MapiMessage,
  Recips as MapiRecip,
  Files as MapiFile,
  Flags as Long,
  Reserved as Long) as Long }

procedure SetupTokenPrivileges; // not tested or used
{ Sample Code Fromgchandler@gajits.com@mail.gajits.com
  Try:

  ExitWindowsEx(EWX_REBOOT, 0);


  You'll probably also need to set NT privileges to do this. I've just ripped
  this code from a program I wrote some time ago. I hope it works ok for you.

}

{ If I understand your question, Program A starts Program B.  If Program B is
  still running when Program A terminates shutdown Program B??

  If that is right use CreateProcess and TerminateProcess API calls.

}

{ From: RobertP@frontiersoftware.com.au
  To: members@adug.org.au
  Subject: RE: ADUG: Memory Leaks
  Date: Fri, 23 May 2003 13:31:51 +1000
  X-Mailer: Internet Mail Service (5.5.2653.19)
  Reply-To: members@adug.org.au
  Sender: members-request@adug.org.au

  Have you looked at extracting statistics from the memory manager itself, in
  order to derermine the nature of the problem?
  There is a method in the memory manager call GetHeapStatus which returns a
  THeapStatus record:

  THeapStatus = record
  TotalAddrSpace: Cardinal;
  TotalUncommitted: Cardinal;
  TotalCommitted: Cardinal;
  TotalAllocated: Cardinal;
  TotalFree: Cardinal;
  FreeSmall: Cardinal;
  FreeBig: Cardinal;
  Unused: Cardinal;
  Overhead: Cardinal;
  HeapErrorCode: Cardinal;
  end;

  If there is a heap growth problem you will see a steady increase in the
  value of the TotalAddrSpace member of the record.

}
{ > Flush Wondows Process Cach Memmory same as Minimise
  I'm not sure what the behaviour is for non-gui apps,
  > although I know there is a Windows Message to achieve
  > the same goal.

  You can do this with SetProcessWorkingSetSize()

  N@

}
{
  Try WM_COPYDATA. It is designed for sending data between applications. A C++ example is:

  HWND h = ::FindWindow(NULL, _T("IPCTrace"));
  if (h)
  {
  COPYDATASTRUCT cds;
  ZeroMemory(&cds, sizeof(COPYDATASTRUCT));
  cds.dwData = 0x00007a69; // your unique key for receiver to test
  cds.cbData = message.size() + 1;
  cds.lpData = (void*)message.c_str();
  ::SendMessage(h, WM_COPYDATA, NULL, (LPARAM) &cds);

}
function GetSpecialFolderLocation(Folder: Integer): AnsiString;
{ Sample Code Fromgchandler@gajits.com@mail.gajits.com
}

{ For OSX http://www.malcolmgroves.com/blog/?p=865 }
{ X.Env.SearchPath - Returns the currently registered search path on the system.
  X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
  X.Env.ExeFilename - Returns the actual filename of the running executable.
  X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
  X.Env.ExeFolder - Returns the full folder path to the executable.
  X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
  X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
}

function GetProgramFilesFolder: AnsiString;
function GetWindowsSystemDir: AnsiString;
function GetWindowsTempFileDirectory: AnsiString;
function GetDiscDriveType(Const ADrive: String): LongWord;
function IsRemoteFile(AFileName: String): Boolean;
Function FileIsNetworkDrive(AFileName: AnsiString): Boolean;
Function FileIsLocalFixed(AFileName: AnsiString): Boolean;
Function ExtractFileDirIS(Const AFileName: String): String;
// Returns '' as the file directory for c:\ so repeat calls will terminate
// with '' not 'c:\'

function GetVersionField(const Field: AnsiString): AnsiString;
{ Get version information from the Executeable }

function GetVersionFieldForFile(const Field, OptFilename: AnsiString)
  : AnsiString;
{ Get version information from File
  if File Name'' then same as GetVersionField
  Valid Field Names
  CompanyName FileDescription FileVersion InternalName LegalCopyright OriginalFilename ProductName ProductVersion
}

function GetSMPTDetailsFromOutLook: AnsiString; // Dummy
{$ENDIF}

implementation

uses
  ISStrUtl, ISDelphi2009Adjust, ISIndyUtils
{$IFDEF ISXE2_DELPHI}
{$IFDEF MSWINDOWS}
    , ISWinInetErrors, WinApi.WinSvc;
{$ELSE}
    ;
{$ENDIF}
{$ELSE}
{$IFDEF FPC}
  ;
{$ELSE}
, WinSvc;
{$ENDIF}
{$ENDIF}

Const
{$IFDEF Win32}
  LocalINVALID_HANDLE_VALUE: DWord = INVALID_HANDLE_VALUE;
{$ELSE}
  LocalINVALID_HANDLE_VALUE: DWord = DWord(-1); // INVALID_HANDLE_VALUE;
{$ENDIF}

function InheritableFileHandle(Filename: AnsiString; read: Boolean): THandle;
{$IFDEF MSWindows}
  function AvailableUnique(var FreeFileName: AnsiString): Boolean;
  // Check to see if file currently in use as stdOut
  var
    SAAU: TSecurityAttributes;
    i, DotPos: Integer;
    TestHndle: THandle;
    iStr: AnsiString;
  begin
    i := 0;
    Result := False;
    FillChar(SAAU, SizeOf(SAAU), 0);
    SAAU.nLength := SizeOf(SAAU);
    SAAU.bInheritHandle := true;
    while not Result do
    begin
      if FileExists(FreeFileName) then
      begin
        TestHndle := { Windows. } CreateFileA(PAnsiChar(FreeFileName),
          GENERIC_READ, 0, @SAAU, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        if TestHndle <> LocalINVALID_HANDLE_VALUE then
        begin
          Result := true;
          CloseHandle(TestHndle);
        end
        else
        begin
          DotPos := Pos('.', FreeFileName);
          if DotPos < 3 then
            raise Exception.Create('Illegal File Name in CreateProcessAndWait::'
              + FreeFileName);
          Inc(i);
          iStr := IntToStr(i);
          FreeFileName[DotPos - 1] := iStr[1];
          if i > 9 then
            raise Exception.Create('Looping 9 times in CreateProcessAndWait::' +
              FreeFileName);
        end;
      end
      else
        Result := true;
    end;
  end;

var
  SA: TSecurityAttributes;
begin
  Result := 0;
  FillChar(SA, SizeOf(SA), 0);
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := true;
  if read then
  begin
    if FileExists(Filename) then
      Result := { Windows. } CreateFileA(PAnsiChar(Filename), GENERIC_READ,
        FILE_SHARE_READ, @SA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  end
  else
  begin
    if AvailableUnique(Filename) then
      Result := { Windows. } CreateFileA(PAnsiChar(Filename), GENERIC_WRITE,
        FILE_SHARE_WRITE, @SA, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end;
{$ELSE}

Begin
  raise Exception.Create('Error Message InheritableFileHandle');
{$ENDIF}
end;

function InheritableFileHandleW(Filename: String; read: Boolean): THandle;
{$IFDEF MSWindows}
  function AvailableUnique(var FreeFileName: String): Boolean;
  // Check to see if file currently in use as stdOut
  var
    SAAU: TSecurityAttributes;
    i, DotPos: Integer;
    TestHndle: THandle;
    iStr: String;
  begin
    i := 0;
    Result := False;
    FillChar(SAAU, SizeOf(SAAU), 0);
    SAAU.nLength := SizeOf(SAAU);
    SAAU.bInheritHandle := true;
    while not Result do
    begin
      if FileExists(FreeFileName) then
      begin
        TestHndle := { Windows. } CreateFileW(PChar(FreeFileName), GENERIC_READ,
          0, @SAAU, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
        if TestHndle <> LocalINVALID_HANDLE_VALUE then
        begin
          Result := true;
          CloseHandle(TestHndle);
        end
        else
        begin
          DotPos := Pos('.', FreeFileName);
          if DotPos < 3 then
            raise Exception.Create('Illegal File Name in CreateProcessAndWait::'
              + FreeFileName);
          Inc(i);
          iStr := IntToStr(i);
          FreeFileName[DotPos - 1] := iStr[1];
          if i > 9 then
            raise Exception.Create('Looping 9 times in CreateProcessAndWait::' +
              FreeFileName);
        end;
      end
      else
        Result := true;
    end;
  end;

var
  SA: TSecurityAttributes;
begin
  Result := 0;
  FillChar(SA, SizeOf(SA), 0);
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := true;
  if read then
  begin
    if FileExists(Filename) then
      Result := { Windows. } CreateFileW(PChar(Filename), GENERIC_READ,
        FILE_SHARE_READ, @SA, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  end
  else
  begin
    if AvailableUnique(Filename) then
      Result := { Windows. } CreateFileW(PChar(Filename), GENERIC_WRITE,
        FILE_SHARE_WRITE, @SA, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  end;
{$ELSE}

Begin
  raise Exception.Create('Error Message InheritableFileHandle');
{$ENDIF}
end;

{$IFDEF MSWINDOWS}

function ExecuteCommandLineRequest(const AInput: AnsiString;
  const ACommand: AnsiString = 'CMD'): AnsiString;
var
  TempFile: TTemporyFile;
  FileStrm: TFileStream;
  Sz: Int64;
  Rtn: DWord;
  S, TempInputFileNm: AnsiString;

begin
  Result := '';
  TempFile := TTemporyFile.Create;
  try
    TempInputFileNm := ExtractFilePath(TempFile.FFileName) + 'zxdc' +
      IntToStr(GetTickCount) + '.tmp';
    FileStrm := TFileStream.Create(TempInputFileNm, fmCreate);
    try
      S := AInput + Crlf;
      FileStrm.Write(S[1], Length(S));
    finally
      FileStrm.Free;
    end;
    Sleep(100);
    Rtn := CreateProcessAndWait(ACommand, 20000, SW_MINIMIZE, TempInputFileNm,
      '', true, 0, TempFile.Handle);
    if Rtn = 0 then
    begin
      TempFile.AllowFileActions;
      FileStrm := TFileStream.Create(TempFile.Filename, fmOpenRead);
      try
        Sz := FileStrm.Seek(0, soFromEnd);
        FileStrm.Seek(0, soFromBeginning);
        SetLength(Result, Sz);
        FileStrm.read(Result[1], Sz);
      finally
        FileStrm.Free;
      end;
    end
    else
      raise Exception.Create('Execute Command Exitcode::' + IntToStr(Rtn));

  finally
    DeleteFileA(@TempInputFileNm[1]);
    TempFile.Free;
  end;
end;

{ Mod  4 October 2015   Restart PC added }
function SetPrivilege(sPrivilegeName: string; bEnabled: Boolean): Boolean;
// From
// http://www.chami.com/tips/delphi/120996D.html
// Prilages to use https://docs.microsoft.com/en-us/windows/win32/secauthz/privilege-constants

var
  TPPrev, TP: TTokenPrivileges;
  Token: THandle;
  dwRetLen: DWord;
begin
  Result := False;

  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, Token);

  TP.PrivilegeCount := 1;
  if (LookupPrivilegeValue(Nil, PChar(sPrivilegeName), TP.Privileges[0].LUID))
  then
  begin
    if (bEnabled) then
    begin
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    end
    else
    begin
      TP.Privileges[0].Attributes := 0;
    end;

    dwRetLen := 0;
    Result := AdjustTokenPrivileges(Token, False, TP, SizeOf(TPPrev), TPPrev,
      dwRetLen);
  end;
  CloseHandle(Token);
end;

{ Mod  4 October 2015   Restart PC added }
Procedure ExecuteReBootOS;
// TrillianShare\HgRepository\InnovaSolutionsDelphi\Delphi Projects\Sample Code\Delphi Samples\Shut Down

// From
// http://www.tek-tips.com/faqs.cfm?fid=6881

{
  Restart
  This code restarts a computer:
  CODE }

const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';

begin
  begin
    Try
      If SetPrivilege(SE_SHUTDOWN_NAME, true) then
        ExitWindowsEx(EWX_REBOOT or EWX_FORCE, 0)
      Else
        raise Exception.Create('No Shutdown Privilage')
    Except
      On E: Exception do
        raise Exception.Create('ExecuteReBootOS::' + E.message);
    End;
  end;
end;

Procedure ExecuteKillOS;
// From
// http://www.tek-tips.com/faqs.cfm?fid=6881
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';

begin
  begin
    Try
      If SetPrivilege(SE_SHUTDOWN_NAME, true) then
        ExitWindowsEx(EWX_POWEROFF or EWX_FORCE or EWX_SHUTDOWN, 0)
      Else
        raise Exception.Create('No Shutdown Privilage')
    Except
      On E: Exception do
        raise Exception.Create('ExecuteKillOS::' + E.message);
    End;
  end;
end;
{$ENDIF}

function CreateProcessAndReturnHandle(AppCommandLine: AnsiString;
  Visiblity: DWord; StdInFileName, StdOutFileName: AnsiString;
  CreateDetached: Boolean = False; StdInHndle: THandle = 0;
  StdOutHndle: THandle = 0): THandle;
// You must release Handle to Process
{ https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessa
  https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow?redirectedfrom=MSDN
  unit Winapi.Windows;
  SW_FORCEMINIMIZE	Minimizes a window, even if the thread that owns the window is not responding. This flag should only be used when minimizing windows from a different thread.
  SW_HIDE	Hides the window and activates another window.
  SW_MAXIMIZE	Maximizes the specified window.
  SW_MINIMIZE	Minimizes the specified window and activates the next top-level window in the Z order.
  SW_RESTORE	Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window.
  SW_SHOW	Activates the window and displays it in its current size and position.
  SW_SHOWDEFAULT	Sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.
  SW_SHOWMAXIMIZED	Activates the window and displays it as a maximized window.
  SW_SHOWMINIMIZED	Activates the window and displays it as a minimized window.
  SW_SHOWMINNOACTIVE	Displays the window as a minimized window. This value is similar to SW_SHOWMINIMIZED, except the window is not activated.
  SW_SHOWNA	Displays the window in its current size and position. This value is similar to SW_SHOW, except that the window is not activated.
  SW_SHOWNOACTIVATE	Displays a window in its most recent size and position. This value is similar to SW_SHOWNORMAL, except that the window is not activated.
  SW_SHOWNORMAL
  { From function CreateProcessAndWait }

{$IFDEF MSWINDOWS}
var
  SI: _StartupInfoA;
  PI: TProcessInformation;
  StdOut, Stdin: THandle;
  Proc: THandle;
  CreateFlag: DWord;

begin
  // Result := 0;
  Stdin := StdInHndle;
  StdOut := StdOutHndle;
  if CreateDetached then
    CreateFlag := DETACHED_PROCESS + Normal_Priority_Class
  else
    CreateFlag := Normal_Priority_Class;

  try
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.wShowWindow := Visiblity;
    if (StdInFileName = '') and (StdOutFileName = '') and (StdInHndle = 0) and
      (StdOutHndle = 0) then
    begin
      if not CreateProcessA(nil, PAnsiChar(AppCommandLine), nil, nil, False,
        CreateFlag, nil, nil, SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          AppCommandLine + '::' + WindowsErrorString(GetLastError));
    end
    else
    begin
      // GetStartupInfo(SI);
      SI.dwFlags := STARTF_USESTDHANDLES;
      if (StdInFileName <> '') and FileExists(StdInFileName) then
        Stdin := InheritableFileHandle(StdInFileName, true);
      if Stdin > 0 then
        SI.hStdInput := Stdin;
      if StdOutFileName <> '' then
        StdOut := InheritableFileHandle(StdOutFileName, False);
      if StdOut > 0 then
      begin
        SI.hStdOutput := StdOut;
        SI.hStdError := StdOut;
      end; { }
      if not CreateProcessA(nil, PAnsiChar(AppCommandLine), nil, nil, true,
        CreateFlag, nil, nil, SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          WindowsErrorString(GetLastError));
    end;
    Proc := PI.hProcess;
    CloseHandle(PI.hThread);
    Result := Proc;
  finally
    if StdOut > 0 then
      if StdOutHndle = 0 then
        CloseHandle(StdOut);
    if Stdin > 0 then
      if StdInHndle = 0 then
        CloseHandle(Stdin);
  end;
{$ELSE}

begin
  raise Exception.Create('Error Message CreateProcessAndReturnHandle');
{$ENDIF}
end;

{$IFNDEF FPC}

function ProcessStillActive(AProcHndle: DWord): Boolean;
begin
  Result := WaitForSingleObject(AProcHndle, 10) = WAIT_TIMEOUT;
end;
{$ENDIF}

function ExeFileNameAllPlatforms: string;
{ X.Env.SearchPath - Returns the currently registered search path on the system.
  X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
  X.Env.ExeFilename - Returns the actual filename of the running executable.
  X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
  X.Env.ExeFolder - Returns the full folder path to the executable.
  X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
  X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
}
{$IFDEF Android}
//{$IFDEF ISD103R_DELPHI}
//begin
//  Result := System.IOUtils.TPath.GetAppPath + ApplicationNameIS;
//end;
//{$ELSE}
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
//{$ENDIF}
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

function ExeFileDirectory: string;
Begin
  Result := ExtractFilePath(ExeFileNameAllPlatforms);
End;

Procedure SetExeFileDirectory;
begin
  SetCurrentDir(ExeFileDirectory);
end;

{$IFDEF ISXE2_DELPHI}

function ExtractuSoftFilePath(const Filename: string): string;
var
  i: Integer;
begin
  i := Filename.LastDelimiter('\:');
  Result := Filename.SubString(0, i + 1);
end;

function ExtractuSoftFileName(const Filename: string): string;
var
  i: Integer;
begin
  i := Filename.LastDelimiter('\:');
  Result := Filename.SubString(i + 1);
end;

{$ENDIF}
{$IFDEF MSWINDOWS}

function CreateProcessAndWaitW(AppCommandLine: String;
  ATimeOutMilliseconds: DWord; Visiblity: DWord;
  StdInFileName, StdOutFileName: String; CreateDetached: Boolean = False;
  StdInHndle: THandle = 0; StdOutHndle: THandle = 0;
  ACloseOnTimeout: Boolean = False): DWord;
// Timeout=0 wait forever

// Returns Process Exit Code
{ 0 implies Closed by timeout given ???
  1 Batch file end???
}

{ Was
  function CreateProcessAndWait( Application, AppCommandLine: string; TimeOut:DWord;
  Visiblity: DWord): DWord;
  lpCommandLine should be a full command line in which the first element
  is the application name. Because this also works well for Win32-based
  applications, it is the most robust way to set lpCommandLine. }
{ SW_HIDE	Hides the window and activates another window.
  SW_MAXIMIZE	Maximizes the specified window.
  SW_MINIMIZE	Minimizes the specified window and activates the next top-level window in the Z order.
  SW_RESTORE	Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
  SW_SHOW	Activates the window and displays it in its current size and position.
  SW_SHOWDEFAULT	Sets the show state based on the SW_ flag specified in the }
{ Original Code From ADUG List Owen Dare 20/1/00 }

{ Exit Codes  Possible ?????
  0 	The operation completed successfully.
  1 	Incorrect function.
  2 	The system cannot find the file specified.
  3 	The system cannot find the path specified.
  4 	The system cannot open the file.
  More https://www.symantec.com/connect/articles/windows-system-error-codes-exit-codes-description
}

var
  SI: _StartupInfoW;
  PI: TProcessInformation;
  StdOut, Stdin: THandle;
  Proc: THandle;
  CreateFlag: DWord;
  CMD: PChar;

begin
  Result := 0;
  CMD := @AppCommandLine[1];
  // Cmd:=PChar(AppCommandLine);
  Stdin := StdInHndle;
  StdOut := StdOutHndle;
  if CreateDetached then
    CreateFlag := DETACHED_PROCESS + Normal_Priority_Class
  else
    CreateFlag := { CREATE_NEW_CONSOLE+{Tried to overcome 32/64 bit problem }
      Normal_Priority_Class;
  // CREATE_NEW_CONSOLE
  // https://docs.microsoft.com/en-us/windows/console/creation-of-a-console?redirectedfrom=MSDN
  // https://docs.microsoft.com/en-us/windows/win32/procthread/process-creation-flags
  try
    FillChar(PI, SizeOf(PI), 0);
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    SI.wShowWindow := Visiblity;
    if (StdInFileName = '') and (StdOutFileName = '') and (StdInHndle = 0) and
      (StdOutHndle = 0) then
    begin
      if not CreateProcessW(nil, CMD, nil, nil, False, CreateFlag, nil, nil,
        SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          AppCommandLine + '::' + WindowsErrorString(GetLastError));
    end
    else
    begin
      // GetStartupInfo(SI);
      SI.dwFlags := STARTF_USESTDHANDLES;
      if (StdInFileName <> '') and FileExists(StdInFileName) then
        Stdin := InheritableFileHandle(StdInFileName, true);
      if Stdin > 0 then
        SI.hStdInput := Stdin;
      if StdOutFileName <> '' then
        StdOut := InheritableFileHandleW(StdOutFileName, False);
      if StdOut > 0 then
      begin
        SI.hStdOutput := StdOut;
        SI.hStdError := StdOut;
      end;
      {
        BOOL CreateProcessA(
        LPCSTR                lpApplicationName,
        LPSTR                 lpCommandLine,
        LPSECURITY_ATTRIBUTES lpProcessAttributes,
        LPSECURITY_ATTRIBUTES lpThreadAttributes,
        BOOL                  bInheritHandles,
        DWORD                 dwCreationFlags,
        LPVOID                lpEnvironment,
        LPCSTR                lpCurrentDirectory,
        LPSTARTUPINFOA        lpStartupInfo,
        LPPROCESS_INFORMATION lpProcessInformation
      }

      if not CreateProcessW(nil, PChar(AppCommandLine), nil, nil, true,
        CreateFlag, nil, nil, SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          WindowsErrorString(GetLastError));
    end;
    Proc := PI.hProcess;
    Try
      CloseHandle(PI.hThread);
      if WaitForSingleObject(Proc, ATimeOutMilliseconds) <> Wait_Failed then
      Begin
        if not GetExitCodeProcess(Proc, Result) then
          raise Exception.Create('Failed to Recover Exit Code  :: ' +
            WindowsErrorString(GetLastError));
      End
      Else if ACloseOnTimeout then
        TerminateProcess(Proc, CTerminateOnWait);
    finally
      CloseHandle(Proc);
    End;
  finally
    if StdOut > 0 then
      if StdOutHndle = 0 then
        CloseHandle(StdOut);
    if Stdin > 0 then
      if StdInHndle = 0 then
        CloseHandle(Stdin);
  end;
end;

function CreateProcessAndWait(AppCommandLine: AnsiString;
  ATimeOutMilliseconds: DWord; Visiblity: DWord;
  StdInFileName, StdOutFileName: AnsiString; CreateDetached: Boolean;
  StdInHndle, StdOutHndle: THandle; ACloseOnTimeout: Boolean): DWord;
// Timeout=0 wait forever

// Returns Process Exit Code
{ 0 implies Closed by timeout given ???
  1 Batch file end???
}

{ Was
  function CreateProcessAndWait( Application, AppCommandLine: string; TimeOut:DWord;
  Visiblity: DWord): DWord;
  lpCommandLine should be a full command line in which the first element
  is the application name. Because this also works well for Win32-based
  applications, it is the most robust way to set lpCommandLine. }
{ SW_HIDE	Hides the window and activates another window.
  SW_MAXIMIZE	Maximizes the specified window.
  SW_MINIMIZE	Minimizes the specified window and activates the next top-level window in the Z order.
  SW_RESTORE	Activates and displays the window. If the window is minimized or maximized, Windows restores it to its original size and position. An application should specify this flag when restoring a minimized window.
  SW_SHOW	Activates the window and displays it in its current size and position.
  SW_SHOWDEFAULT	Sets the show state based on the SW_ flag specified in the }
{ Original Code From ADUG List Owen Dare 20/1/00 }

{ Exit Codes  Possible ?????
  0 	The operation completed successfully.
  1 	Incorrect function.
  2 	The system cannot find the file specified.
  3 	The system cannot find the path specified.
  4 	The system cannot open the file.
  More https://www.symantec.com/connect/articles/windows-system-error-codes-exit-codes-description
}

var
  SI: _StartupInfoA;
  PI: TProcessInformation;
  StdOut, Stdin: THandle;
  Proc: THandle;
  CreateFlag: DWord;

begin
  Result := 0;
  Stdin := StdInHndle;
  StdOut := StdOutHndle;
  if CreateDetached then
    CreateFlag := DETACHED_PROCESS + Normal_Priority_Class
  else
    CreateFlag := Normal_Priority_Class;

  try
    FillChar(SI, SizeOf(SI), 0);
    FillChar(PI, SizeOf(PI), 0);
    SI.cb := SizeOf(SI);
    SI.wShowWindow := Visiblity;

    if (StdInFileName = '') and (StdOutFileName = '') and (StdInHndle = 0) and
      (StdOutHndle = 0) then
    begin
      if not CreateProcessA(nil, PAnsiChar(AppCommandLine), nil, nil, False,
        CreateFlag, nil, nil, SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          AppCommandLine + '::' + WindowsErrorString(GetLastError));
    end
    else
    begin
      // GetStartupInfo(SI);
      SI.dwFlags := STARTF_USESTDHANDLES;
      if (StdInFileName <> '') and FileExists(StdInFileName) then
        Stdin := InheritableFileHandle(StdInFileName, true);
      if Stdin > 0 then
        SI.hStdInput := Stdin;
      if StdOutFileName <> '' then
        StdOut := InheritableFileHandle(StdOutFileName, False);
      if StdOut > 0 then
      begin
        SI.hStdOutput := StdOut;
        SI.hStdError := StdOut;
      end;
      {
        BOOL CreateProcessA(
        LPCSTR                lpApplicationName,
        LPSTR                 lpCommandLine,
        LPSECURITY_ATTRIBUTES lpProcessAttributes,
        LPSECURITY_ATTRIBUTES lpThreadAttributes,
        BOOL                  bInheritHandles,
        DWORD                 dwCreationFlags,
        LPVOID                lpEnvironment,
        LPCSTR                lpCurrentDirectory,
        LPSTARTUPINFOA        lpStartupInfo,
        LPPROCESS_INFORMATION lpProcessInformation
      }

      if not CreateProcessA(nil, PAnsiChar(AnsiString(AppCommandLine)), nil,
        nil, true, CreateFlag, nil, nil, SI, PI) then
        raise Exception.Create('Failed to execute program.  :: ' +
          WindowsErrorString(GetLastError));
    end;
    Proc := PI.hProcess;
    Try
      CloseHandle(PI.hThread);
      if WaitForSingleObject(Proc, ATimeOutMilliseconds) <> Wait_Failed then
      Begin
        if not GetExitCodeProcess(Proc, Result) then
          raise Exception.Create('Failed to Recover Exit Code  :: ' +
            WindowsErrorString(GetLastError));
      End
      Else if ACloseOnTimeout then
        TerminateProcess(Proc, CTerminateOnWait);
    finally
      CloseHandle(Proc);
    End;
  finally
    if StdOut > 0 then
      if StdOutHndle = 0 then
        CloseHandle(StdOut);
    if Stdin > 0 then
      if StdInHndle = 0 then
        CloseHandle(Stdin);
  end;
end;

Function ServicePrivilageNotOK: Boolean;
// bit of a hack
Var
  sType, sStatus: DWord;
  SvcNam, Error: AnsiString;
begin
  Result := true;
  SvcNam := 'SomeWeirdService';
  QueryISServiceDetails(SvcNam, sType, sStatus, Error);
  if Error = '' then
    Result := False
  else if Pos('1060.', Error) > 0 then
    Result := False
  else if Pos('Access is d', Error) > 0 then
    Exit
  Else
    raise Exception.Create('ServicePriviageNotOK Error Message=' + Error);
End;

type
  ConfigDataBuffer = record
    case Integer of
      0:
        (ConfigData: TQueryServiceConfigA);
      1:
        (Buffer: array [0 .. 500] of Byte);
  end;

function QueryISServiceDetails(AName: AnsiString; out AType, AStatus: DWord;
  out AError: AnsiString): Boolean;
// See https://docs.microsoft.com/en-us/windows/win32/api/winsvc/ns-winsvc-service_status
{
  The type of service. This member can be one of the following values.
  Value 	Meaning
  SERVICE_FILE_SYSTEM_DRIVER	The service is a file system driver.
  SERVICE_KERNEL_DRIVER	The service is a device driver.
  SERVICE_WIN32_OWN_PROCESS	The service runs in its own process.
  SERVICE_WIN32_SHARE_PROCESS	The service shares a process with other services.
  SERVICE_USER_OWN_PROCESS	The service runs in its own process under the logged-on user account.
  SERVICE_USER_SHARE_PROCESS	The service shares a process with one or more other services that run under the logged-on user account.

  If the service type is either SERVICE_WIN32_OWN_PROCESS or SERVICE_WIN32_SHARE_PROCESS, and the service is running in the context of the LocalSystem account, the following type may also be specified.
  Value 	Meaning
  SERVICE_INTERACTIVE_PROCESS	The service can interact with the desktop.


  dwCurrentState
  The current state of the service. This member can be one of the following values.
  Value 	Meaning
  SERVICE_CONTINUE_PENDING	The service continue is pending.
  SERVICE_PAUSE_PENDING	The service pause is pending.
  SERVICE_PAUSED	The service is paused.
  SERVICE_RUNNING	The service is running.
  SERVICE_START_PENDING	The service is starting.
  SERVICE_STOP_PENDING The service is stopping.
  SERVICE_STOPPED	The service is not running. }
var
  Svc: Integer;
  SvcMgr: Integer;
  ServiceStatus: TServiceStatus;
begin
  Result := False;
  AError := '';
  AType := 0;
  AStatus := 0;

  try
    SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if SvcMgr = 0 then
      RaiseLastOSError;
    try
      Svc := OpenServiceA(SvcMgr, PAnsiChar(AName), SERVICE_QUERY_STATUS);
      if Svc = 0 then
        RaiseLastOSError;

      try
        if not QueryServiceStatus(Svc, ServiceStatus) then
        begin
          RaiseLastOSError;
        end;
        AType := ServiceStatus.dwServiceType;
        AStatus := ServiceStatus.dwCurrentState;
      finally
        CloseServiceHandle(Svc);
      end;
    finally
      CloseServiceHandle(SvcMgr);
    end;
    Result := true;
  except
    on E: Exception do
      AError := 'Query Service Failure::' + E.message;
  end
end;

Function QueryIsServiceExists(AName: AnsiString): Boolean; Overload;
Var
  IsRunning: Boolean;
Begin
  Result := QueryIsServiceExists(AName, IsRunning);
End;

Function QueryIsServiceExists(AName: AnsiString; Out AIsRunning: Boolean)
  : Boolean; Overload;
Var
  ServType, ServStatus: DWord;
  ServError: AnsiString;
begin
  try
    QueryISServiceDetails(AName, ServType, ServStatus, ServError);
    Result := ServError = '';
    AIsRunning := (ServStatus = SERVICE_RUNNING);
  Except
    Result := False;
  end;
end;
{$ENDIF}

function RetrieveServiceDetails(AName: AnsiString;
  out ABinaryName, AStartName, ADisplayName, AError: AnsiString): Boolean;
{$IFDEF MSWINDOWS}
var
  Svc: Integer;
  SvcMgr: Integer;
  CfdB: ConfigDataBuffer;
{$IFDEF ISXE2_DELPHI}
  ConfigDataPt: LPQuery_Service_ConfigA;
{$ELSE}
  ConfigDataPt: PQueryServiceConfigA;
{$ENDIF}
  BufSz: DWord;
  MoreDataSzReq: DWord;
begin
  Result := False;
  AError := '';
  ABinaryName := '';
  ADisplayName := '';
  AStartName := '';
  ConfigDataPt := @(CfdB.ConfigData);
  BufSz := SizeOf(CfdB);

  try
    SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if SvcMgr = 0 then
      RaiseLastOSError;
    try
      Svc := OpenServiceA(SvcMgr, PAnsiChar(AName), SERVICE_QUERY_CONFIG);
      if Svc = 0 then
        RaiseLastOSError;

      try
        if not QueryServiceConfigA(Svc, ConfigDataPt, BufSz, MoreDataSzReq) then
        begin
          RaiseLastOSError;
        end;
        AStartName := CfdB.ConfigData.lpServiceStartName;
        ABinaryName := CfdB.ConfigData.lpBinaryPathName;
        ADisplayName := CfdB.ConfigData.lpDisplayName;
      finally
        CloseServiceHandle(Svc);
      end;
    finally
      CloseServiceHandle(SvcMgr);
    end;
    Result := true;
  except
    on E: Exception do
      AError := 'Retreive Service Details Failure::' + E.message;
  end
{$ELSE}

begin
  raise Exception.Create('Error Message RetrieveServiceDetails');
{$ENDIF}
end;

{$IFDEF MSWINDOWS}

function StopISService(AName: AnsiString; out AError: AnsiString): Boolean;
var
  Svc: Integer;
  SvcMgr: Integer;
  ServiceStatus: TServiceStatus;
begin
  Result := False;
  AError := '';
  try
    SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if SvcMgr = 0 then
      RaiseLastOSError;
    try
      Svc := OpenServiceA(SvcMgr, PAnsiChar(AName), SERVICE_ALL_ACCESS);
      if Svc = 0 then
        RaiseLastOSError;

      try
        if not ControlService(Svc, SERVICE_CONTROL_STOP, ServiceStatus) then
          RaiseLastOSError;
      finally
        CloseServiceHandle(Svc);
      end;
    finally
      CloseServiceHandle(SvcMgr);
    end;
    Result := true;
  except
    on E: Exception do
      AError := 'Stop Service Failure::' + E.message;
  end
end;

function StartISService(AName: AnsiString; out AError: AnsiString): Boolean;
var
  Svc: Integer;
  SvcMgr: Integer;
  Arg: PAnsiChar;
begin
  Result := False;
  AError := '';
  Arg := '';
  try
    SvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if SvcMgr = 0 then
      RaiseLastOSError;
    try
      Svc := OpenServiceA(SvcMgr, PAnsiChar(AName), SERVICE_ALL_ACCESS);
      if Svc = 0 then
        RaiseLastOSError;

      try
        if not StartServiceA(Svc, 0, Arg) then
          RaiseLastOSError;
      finally
        CloseServiceHandle(Svc);
      end;
    finally
      CloseServiceHandle(SvcMgr);
    end;
    Result := true;
  except
    on E: Exception do
      AError := 'Stop Service Failure::' + E.message;
  end;
end;

function LockUnLockMutex(const AName: AnsiString; Lock: Boolean;
  WaitMilliSecs: Integer): Boolean;

var
  ProcessMutex: THandle;
  MutexParams: TSecurityAttributes;
  name: AnsiString;

begin
  name := AName;
  if Pos('\', name) > 0 then
    name := StringReplace(name, '\', 'B', [rfReplaceAll]);
  with MutexParams do
  begin
    nLength := SizeOf(MutexParams);
    lpSecurityDescriptor := nil;
    bInheritHandle := true;
  end;
  ProcessMutex := CreateMutexA(@MutexParams, False, @name[1]);
  if ProcessMutex = 0 then
    raise Exception.Create('Mutex Failed ::' + name)
  else if Lock then
    Result := WAIT_OBJECT_0 = WaitForSingleObject(ProcessMutex, WaitMilliSecs)
  else
    Result := ReleaseMutex(ProcessMutex);
end;
{$ENDIF}

procedure Wait(const Msec: Integer);
begin
  Sleep(Msec);
end;

{$IFDEF MSWINDOWS}

function ViewFileInNotePad(const ALogFileName: AnsiString): Boolean;
var
  SystemRootDir: AnsiString;
  NotePad: AnsiString;
begin
  Result := False;

  if FileExists(ALogFileName) then
  begin
    SystemRootDir := GetEnvironmentVariable(PAnsiChar('SystemRoot'));
    NotePad := ConcatToFullFileName(SystemRootDir, '\system32\notepad.exe');
    Result := CreateProcessAndWait(NotePad + ' "' + ALogFileName + '"', 0,
      SW_Normal, '', '') > 0;
  end;
end;

function ShellExecuteDocument(const Command, Parameters, Directory: AnsiString;
  Visiblity: DWord; Action: AnsiString): Boolean;
var
  Return: DWord;
begin
  Return := ShellExecuteDocumentRetError(Command, Parameters, Directory,
    Visiblity, Action);
  Result := Return > 32;
end;

function ShellExecuteDocumentRetError(const Command, Parameters,
  Directory: AnsiString; Visiblity: DWord; Action: AnsiString): DWord;
var
  lpParameters, lpDirectory, lpOperation: PAnsiChar;
  LocalAction: AnsiString;
begin
  if Action = '' then
    LocalAction := 'open'
  else
    LocalAction := lowercase(Action);
  lpOperation := PAnsiChar(LocalAction);
  if Parameters = '' then
    lpParameters := nil
  else
    lpParameters := @Parameters[1];
  if Directory = '' then
    lpDirectory := nil
  else
    lpDirectory := @Directory[1];
  Result := ShellExecuteA(0, // handle to parent window
    lpOperation, // pointer to string that specifies operation to perform
    @Command[1], // pointer to filename or folder name string
    lpParameters,
    // pointer to string that specifies executable-file parameters
    lpDirectory, // pointer to string that specifies default directory
    // whether file is shown when opened
    Visiblity);
end;

{$ENDIF}

function IsAnExeFileName(AFileName: String): Boolean;
var
  UFName: String;
  i: Integer;
begin
  Result := False;
  if AFileName = '' then
    Exit;
  UFName := UpperCase(AFileName);
  i := Pos('.EXE', UFName);
  if i < 1 then
    i := Pos('.COM', UFName);
  if i < 1 then
    Exit;

  if Length(UFName) < i + 4 then
    Result := true
  else
    Result := UFName[i + 4] = ' ';
end;

{$IFDEF MSWINDOWS}

function HigherValueTime(ATime1, ATime2: FileTime): FileTime;
begin
  if ATime1.dwHighDateTime > ATime2.dwHighDateTime then
    Result := ATime1
  else if ATime1.dwHighDateTime < ATime2.dwHighDateTime then
    Result := ATime2
  else if ATime1.dwLowDateTime > ATime2.dwLowDateTime then
    Result := ATime1
  else
    Result := ATime2;
end;

function LowerValueTime(ATime1, ATime2: FileTime): FileTime;
begin
  if ATime1.dwHighDateTime < ATime2.dwHighDateTime then
    Result := ATime1
  else if ATime1.dwHighDateTime > ATime2.dwHighDateTime then
    Result := ATime2
  else if ATime1.dwLowDateTime < ATime2.dwLowDateTime then
    Result := ATime1
  else
    Result := ATime2;
end;

procedure FileDates(const ADirFileName: AnsiString;
  out ACreateTime, ALastAccess, AWriteTime: TDateTime);
{ Code From
  function DirectoryOrFileDate(const ADirFileName: AnsiString;
  ACreateAcceesWrite: Byte): TDateTime;
}
{ sub } function RecoverLocalTime(AFileTime: FileTime): TDateTime;
  var
    LocalFileTime: FileTime;
  begin
    if not FileTimeToLocalFileTime(AFileTime, LocalFileTime) then
      raise Exception.Create('DirectoryDate FileTimeToLocalFileTime::' +
        WindowsErrorString(0));
    Result := FileTimeStructureToDateTime(LocalFileTime);
  end;

var
  FileH: DWord;
  CreationTime, // time the file was created
  LastAccessTime, // time the file was last accessed
  LastWriteTime: FileTime; // time the file was last written

begin
  try
    ACreateTime := 0.0;
    ALastAccess := 0.0;
    AWriteTime := 0.0;
    FileH := FileOpen(ADirFileName, fmOpenRead or fmShareDenyNone);
    {
      CreateFileA(PAnsiChar(ADirFileName), GENERIC_READ,
      FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
      FILE_FLAG_BACKUP_SEMANTICS, 0);
    }
    if FileH <> LocalINVALID_HANDLE_VALUE then
      try
        begin
          if GetFileTime(FileH, @CreationTime, @LastAccessTime, @LastWriteTime)
          then
          begin
            ACreateTime := RecoverLocalTime(CreationTime);
            ALastAccess := RecoverLocalTime(LastAccessTime);
            AWriteTime := RecoverLocalTime(LastWriteTime);
          end;
        end;
      finally
        FileClose(FileH);
      end
    Else
      Raise Exception.Create(WindowsErrorString(0));
  except
    on E: Exception do
      raise Exception.Create('FileDates::' + E.message)
  end;
end;

function DirectoryOrFileDate(const ADirFileName: AnsiString;
  ACreateAcceesWrite: Byte): TDateTime;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3: Earliest Date - 4: Laste Date }

{ The CreateFile function creates or opens the following objects and
  returns a handle that can be used to access the object:

  7	files
  7	pipes
  7	mailslots
  7	communications resources
  7	disk devices (Windows NT only)
  7	consoles
  7	directories (open only)

  Directory Operations
  Windows NT: You can obtain a handle to a directory by calling the CreateFile function with the FILE_FLAG_BACKUP_SEMANTICS flag set, as follows:

  hDir = CreateFile (
  DirName,
  GENERIC_READ,
  FILE_SHARE_READ|FILE_SHARE_DELETE,
  NULL,
  OPEN_EXISTING,
  FILE_FLAG_BACKUP_SEMANTICS,
  NULL
  );


  You can pass a directory handle to the following functions:
  BackupRead
  BackupSeek
  BackupWrite
  GetFileInformationByHandle
  GetFileSize
  GetFileTime
  GetFileType
  ReadDirectoryChangesW
  SetFileTime


}
var
  FileH: DWord;
  CreationTime, // time the file was created
  LastAccessTime, // time the file was last accessed
  LastWriteTime: FileTime; // time the file was last written

  LocalFileTime, TestTime: FileTime;

begin
  Result := 0.0;

  try
    FileH := CreateFileA(PAnsiChar(ADirFileName), GENERIC_READ,
      FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
      FILE_FLAG_BACKUP_SEMANTICS, 0);

    if FileH <> LocalINVALID_HANDLE_VALUE then
      try
        begin
          //TFile.  Alternate functions
          if GetFileTime(FileH, @CreationTime, @LastAccessTime, @LastWriteTime)
          then
          begin
            case ACreateAcceesWrite of
              0:
                if not FileTimeToLocalFileTime(CreationTime, LocalFileTime) then
                  raise Exception.Create
                    ('DirectoryDate FileTimeToLocalFileTime::' +
                    WindowsErrorString(0));
              1:
                if not FileTimeToLocalFileTime(LastAccessTime, LocalFileTime)
                then
                  raise Exception.Create
                    ('DirectoryDate FileTimeToLocalFileTime::' +
                    WindowsErrorString(0));
              2:
                if not FileTimeToLocalFileTime(LastWriteTime, LocalFileTime)
                then
                  raise Exception.Create
                    ('DirectoryDate FileTimeToLocalFileTime::' +
                    WindowsErrorString(0));
              3: // Earliest Date
                begin
                  TestTime := CreationTime;
                  TestTime := LowerValueTime(TestTime, LastAccessTime);
                  TestTime := LowerValueTime(TestTime, LastWriteTime);
                  if not FileTimeToLocalFileTime(TestTime, LocalFileTime) then
                    raise Exception.Create
                      ('DirectoryDate FileTimeToLocalFileTime::' +
                      WindowsErrorString(0));
                end;
              4: // Latest Date
                begin
                  TestTime := CreationTime;
                  TestTime := HigherValueTime(TestTime, LastAccessTime);
                  TestTime := HigherValueTime(TestTime, LastWriteTime);
                  if not FileTimeToLocalFileTime(TestTime, LocalFileTime) then
                    raise Exception.Create
                      ('DirectoryDate FileTimeToLocalFileTime::' +
                      WindowsErrorString(0));
                end;
            end; // case

            { if not FileTimeToDosDateTime(LocalFileTime, LpFatDate, LpFatTime) then
              raise Exception.Create('DirectoryDate FileTimeToDosDateTime::' + WindowsErrorString(0));

              LongRec(Age).Hi := LpFatDate;
              LongRec(Age).Lo := LpFatTime;

              Result := FileDateToDateTime(Age); }
            Result := FileTimeStructureToDateTime(LocalFileTime);
          end;
        end;
      finally
        FileClose(FileH);
      end;
  except
    on E: Exception do
      raise Exception.Create('DirectoryDate::' + E.message)
  end;
end;

Function FileCreatedAfter(Const AOldFileName, ANewFilename: AnsiString)
  : Boolean;
Begin
  Result := DirectoryOrFileDate(ANewFilename, 0) > DirectoryOrFileDate
    (AOldFileName, 0);
End;

Function FileLastWriteAfter(Const AOldFileName, ANewFilename
  : AnsiString): Boolean;
Begin
  Result := DirectoryOrFileDate(ANewFilename, 3) > DirectoryOrFileDate
    (AOldFileName, 3);
End;

const
  FileTimeDateTimeOffset = -109205;

function ACLDBRecName(AFileName: String): String;
Begin
  Result := ChangeFileExt(AFileName, 'ACL.Rec');
End;

function SetDBFileShareAll(ADbFileName: AnsiString;
  ADoDirectory, ALeaveRecord: Boolean): Boolean;
var
  TempFile: TTemporyFile; // OutputFile
  FileStrm: TFileStream; // InputFile
  Sz: Int64;
  Rtn: Integer;
  TempInputFileNm, FullDir, DbFiles, RecordFileName: String;
  S, ResultData: AnsiString;
Const
  ErrorTest: AnsiString = 'Users:(M)';
  // ErrorTest1: ansiString = 'Users:<M>';
  XpTest: AnsiString = 'is not recognized as an internal';

begin
  Result := False;
  FullDir := ExtractFileDir(ADbFileName);
  if FullDir = '' then
    Exit;
  DbFiles := ExtractFileName(ADbFileName);
  if DbFiles <> '' then
    DbFiles := ChangeFileExt(ADbFileName, '.*');
  ResultData := '';
  TempFile := TTemporyFile.Create;
  try
    TempInputFileNm := ExtractFilePath(TempFile.Filename) + 'zxdc' +
      IntToStr(GetTickCount) + '.bat';
    FileStrm := TFileStream.Create(TempInputFileNm, fmCreate);
    try

      if ADoDirectory then
        S := 'icacls "' + FullDir + '" /grant users:M' + #10 + #13 + 'icacls "'
          + DbFiles + '" /grant users:M' + #10 + #13 + 'icacls "' + ADbFileName
          + '"' + #10 + #13 + 'Dir "' + FullDir + '"'
      Else
        S := 'icacls "' + DbFiles + '" /grant users:M' + #10 + #13 + 'icacls "'
          + ADbFileName + '"' + #10 + #13 + 'Dir "' + FullDir + '"';
      FileStrm.Write(S[1], Length(S));
    finally
      FileStrm.Free;
    end;
    Sleep(100);
    Rtn := CreateProcessAndWait('"' + TempInputFileNm + '"', 20000, SW_MINIMIZE,
      '', '', False, 0, TempFile.Handle);
    if Rtn >= 0 then
    begin
      TempFile.AllowFileActions;
      FileStrm := TFileStream.Create(TempFile.Filename, fmOpenRead);
      try
        Sz := FileStrm.Seek(0, soFromEnd);
        FileStrm.Seek(0, soFromBeginning);
        SetLength(ResultData, Sz);
        FileStrm.read(ResultData[1], Sz);
        Result := Pos(ErrorTest, ResultData) > 1;
        if not Result then
          Result := Pos(XpTest, ResultData) > 1;
        // if not Result then
        // Result := Pos(ErrorTest1, ResultData) > 1;
      finally
        FreeAndNil(FileStrm);
      end;
    end
    else
      raise Exception.Create('SetDBFileShareAll Command Exitcode::' +
        IntToStr(Rtn));
    if ALeaveRecord then
      try
        FileStrm := nil;
        RecordFileName := ACLDBRecName(ADbFileName);
        DeleteFile(RecordFileName);
        if Result then
        Begin
          FileStrm := TFileStream.Create(RecordFileName, fmCreate);
          FileStrm.Write(ResultData[1], Length(ResultData));
        End;
      Finally
        FreeAndNil(FileStrm);
      End;

  finally
    DeleteFileW(@TempInputFileNm[1]);
    TempFile.Free;
  end;
end;

{$IFDEF Win64}
{$ENDIF}

Function RecoverInternationalOnLineSettings: TInternationalSettings;
var
  TempFile: TTemporyFile; // OutputFile
  FileStrm: TFileStream; // InputFile
  Sz: Int64;
  Rtn: Integer;
  Rslt: Boolean;
  TempInputFileNm, DismExe: String;
  ResultData: String;
  S, ResultDataA: AnsiString;

  { Sub } Function ExtractChr(Var ANxt: PChar; const AKey: String): String;
  Var
    Nxt, KChar: PChar;
  Begin
    Result := '';
    if AKey = '' then
      Exit;
    if PCharNotNull(ANxt) then
    begin
      KChar := PChar(AKey);
      Nxt := StrPos(ANxt, KChar);
      if PCharNotNull(Nxt) then
        Try
          Inc(Nxt, Length(AKey));
          if Nxt[1] = ':' then
            Inc(Nxt, 2)
          Else if Nxt[0] = ':' then
            Inc(Nxt, 1);
          Begin
            if Nxt[0] = ' ' then
            Begin
              Inc(Nxt);
              while PCharNotNull(Nxt) and not(Nxt[0] in [CR, LF, CRP, LFP]) do
              Begin
                Result := Result + Nxt[0];
                Inc(Nxt);
              End;
            End;
          End;
        Finally
          ANxt := Nxt;
        End;
    end;
  End;

{ Sub } Function Extract(const AKey: String): String;
  Var
    dChar: PChar;
  Begin
    Result := '';
    if ResultData = '' then
      Exit;
    if AKey = '' then
      Exit;
    dChar := PChar(ResultData);
    Result := ExtractChr(dChar, AKey);
  End;

{ Sub } Function ExtractList(const AKey: String): String;
  Var
    Values: String;
  Const
    DCIM_Sep = ';';
  begin
    Values := Extract(AKey);
    Result := StringReplace(Trim(Values), DCIM_Sep, '|', [rfReplaceAll]);
  end;

{ sub } Procedure ExtractLanguage;
  Type
    LangRec = Array [0 .. 2] of string;
  Const
    CLangKey = 'Installed language(s)';
    CLanguageTypes = '  Type';
    CLanguageFallBk = '  Fallback Languages';
  Var
    NextLang, NextType, NextFallBack: String;
    PNxtLang, PNxtType, PnxtFall: PChar;
    LangArray: Array of LangRec;
    NoOfLang, NxtNo: Integer;
    i: Integer;
  Begin
    Result.InstalledLanguages := '';
    Result.LanguageTypes := '';
    Result.FallBackLanguage := '';
    NoOfLang := 6;
    SetLength(LangArray, NoOfLang);
    NxtNo := 0;
    Try
      if ResultData = '' then
        Exit;
      PNxtLang := PChar(ResultData);
      NextLang := ExtractChr(PNxtLang, CLangKey);
      LangArray[0, 0] := NextLang;
      PNxtType := PNxtLang;
      PnxtFall := PNxtLang;
      NextType := ExtractChr(PNxtType, CLanguageTypes);
      NextFallBack := ExtractChr(PnxtFall, CLanguageFallBk);
      While NextLang <> '' do
      Begin
        NextLang := ExtractChr(PNxtLang, CLangKey);
        if NextLang = '' then
        begin
          LangArray[NxtNo, 1] := NextType;
          LangArray[NxtNo, 2] := NextFallBack;
        end
        else
        Begin;
          if (PNxtType <> nil) and (PNxtLang > PNxtType) then
          Begin
            LangArray[NxtNo, 1] := NextType;
            PNxtType := PNxtLang;
            NextType := ExtractChr(PNxtType, CLanguageTypes);
          End;
          if (PnxtFall <> nil) and (PnxtFall > PNxtType) then
          Begin
            LangArray[NxtNo, 2] := NextFallBack;
            PnxtFall := PNxtLang;
            NextFallBack := ExtractChr(PnxtFall, CLanguageFallBk);
          End;
          Inc(NxtNo);
          if NxtNo >= NoOfLang then
          begin
            Inc(NoOfLang, 6);
            SetLength(LangArray, NoOfLang);
          end;
          LangArray[NxtNo, 0] := NextLang;
        End;
      End;
      for i := 0 to NxtNo do
      begin
        Result.InstalledLanguages := Result.InstalledLanguages +
          LangArray[i, 0] + '|';
        Result.LanguageTypes := Result.LanguageTypes + LangArray[i, 1] + '|';
        Result.FallBackLanguage := Result.FallBackLanguage + LangArray
          [i, 2] + '|';
      end;
    Except
      On E: Exception do
        Result.InstalledLanguages := Result.InstalledLanguages +
          'Error InstalledLanguages::' + E.message;
    End;
  End;

Const
  ErrorTest: AnsiString = 'Reporting online international settings.';
  // ErrorTest: ansiString = The operation completed successfully.';
  // XpTest:ansiString = 'is not recognized as an internal';
Begin
  // ??
  // DismExe:=ExtractFilePath(GetProgramFilesFolder);
  // DismExe:=TPath.Combine(DismExe,'Windows\System32\Dism.exe');
  DismExe := 'Dism.exe';
  TempFile := TTemporyFile.Create;
  try
    TempInputFileNm := ExtractFilePath(TempFile.Filename) + 'zxdc' +
      IntToStr(GetTickCount) + '.bat';
    FileStrm := TFileStream.Create(TempInputFileNm, fmCreate);
    try
      S := DismExe + ' /online /get-intl /english';
      FileStrm.Write(S[1], Length(S));
    finally
      FileStrm.Free;
    end;
    Sleep(100);

    Rtn := CreateProcessAndWaitW(TempInputFileNm, 20000, SW_MINIMIZE, '', '',
      False, 0, TempFile.Handle { } );

    // Rtn := CreateProcessAndWait('"' + TempInputFileNm + '"', 20000, SW_MINIMIZE,
    // '', '', False, 0, TempFile.Handle);

    if Rtn >= 0 then
    begin
      TempFile.AllowFileActions;
      FileStrm := TFileStream.Create(TempFile.Filename, fmOpenRead);
      try
        Sz := FileStrm.Seek(0, soFromEnd);
        FileStrm.Seek(0, soFromBeginning);
        SetLength(ResultDataA, Sz);
        FileStrm.read(ResultDataA[1], Sz);
        ResultData := ResultDataA;
        Rslt := Pos(ErrorTest, ResultData) > 1;
        // if not Result then
        // Result := Pos(XpTest, ResultData) > 1;
        if not Rslt then
          Result.Error := 'Error ::' + ResultData
        Else
        Begin
          Result.DefaultsystemUIlanguage :=
            Extract('Default system UI language');
          Result.Systemlocale := Extract('System locale');
          Result.DefaultTimeZone := Extract('Default time zone');
          Result.KeyboardLayeredDriver := Extract('Keyboard layered driver');
          Result.ActiveKeyboards := ExtractList('Active keyboard(s)');
          ExtractLanguage;
        End;
      finally
        FreeAndNil(FileStrm);
      end;
    end
    else
      raise Exception.Create('SetDBFileShareAll Command Exitcode::' +
        IntToStr(Rtn));

  finally
    DeleteFileW(@TempInputFileNm[1]);
    TempFile.Free;
  end;

End;
{ $EndIF }

function RunAsAdmin(hWnd: hWnd; Filename: string; Parameters: string): Boolean;
{ Run FileName As Admin }
{ From
  http://stackoverflow.com/users/12597/ian-boyd
  Code
  http://stackoverflow.com/questions/923350/delphi-prompt-for-uac-elevation-when-needed/923551#923551

  See Step 3: Redesign for UAC Compatibility (UAC)
  http://msdn.microsoft.com/en-us/library/bb756922.aspx
}
var
  sei: TShellExecuteInfo;
begin
  ZeroMemory(@sei, SizeOf(sei));
  sei.cbSize := SizeOf(TShellExecuteInfo);
  sei.Wnd := hWnd;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := PChar('runas');
  sei.lpFile := PChar(Filename); // PAnsiChar;
  if Parameters <> '' then
    sei.lpParameters := PChar(Parameters); // PAnsiChar;
  sei.nShow := SW_SHOWNORMAL; // Integer;

  Result := ShellExecuteExW(@sei);
end;
{
  The other Microsoft suggested solution is to create an COM object out of process (using the specially created CoCreateInstanceAsAdmin function). i don't like this idea because you have to write and register a COM object.

  Note: There is no "CoCreateInstanceAsAdmin" API call. It's just some code floating around. Here's the Dephi version i stumbled around for. It is apparently based on the trick of prefixing a class guid string with the "Elevation:Administrator!new:" prefix when normally hidden code internally calls CoGetObject:

  function CoGetObject(pszName: PWideChar; pBindOptions: PBindOpts3;
  const iid: TIID; ppv: PPointer): HResult; stdcall; external 'ole32.dll';

  procedure CoCreateInstanceAsAdmin(const Handle: HWND;
  const ClassID, IID: TGuid; PInterface: PPointer);
  var
  BindOpts: TBindOpts3;
  MonikerName: WideString;
  Res: HRESULT;
  begin
  ZeroMemory(@BindOpts, Sizeof(TBindOpts3));
  BindOpts.cbStruct := Sizeof(TBindOpts3);
  BindOpts.hwnd := Handle;
  BindOpts.dwClassContext := CLSCTX_LOCAL_SERVER;

  MonikerName := 'Elevation:Administrator!new:' + GUIDToString(ClassID);

  Res := CoGetObject(PWideChar(MonikerName), @BindOpts, IID, PInterface);
  if Failed(Res) then
  raise Exception.Create(SysErrorMessage(Res));
  end; }

function DateTimeToFileTimeStructure(ADateTime: TDateTime): TFileTime;
(*
  The FILETIME structure is a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601.

  typedef struct _FILETIME { // ft
  DWORD dwLowDateTime;
  DWORD dwHighDateTime;
  } FILETIME;

  The integral part of a Delphi TDateTime value is the number of days that have passed since 12/30/1899.
  The fractional part of the TDateTime value is fraction of a 24 hour day that has elapsed.
*)
var
  NewTime, Val2: Int64;

begin
  // Val:=Trunc(EncodeDate(1601,1,1));
  NewTime := (Trunc(ADateTime) - FileTimeDateTimeOffset) * 24 * 60 * 60 * 1000 *
    1000 * 10;
  if ADateTime < 0.0 then
    Val2 := Trunc((-1 - Frac(ADateTime)) * 24 * 60 * 60 * 1000 * 1000 * 10)
  else
    Val2 := Trunc(Frac(ADateTime) * 24 * 60 * 60 * 1000 * 1000 * 10);
  Result := TFileTime(NewTime + Val2);
end;

function FileTimeStructureToDateTime(AFileTime: TFileTime): TDateTime;
var
  Days, Hours: Double;
  Val: Int64;
  RealVal: Double;
begin
  Int64Rec(Val).hi := AFileTime.dwHighDateTime;
  Int64Rec(Val).lo := AFileTime.dwLowDateTime;
  Val := Val div (24 * 60 * 60);
  RealVal := Val / 10000;
  RealVal := RealVal / (1000);
  Days := Trunc(RealVal) + FileTimeDateTimeOffset;
  Hours := Frac(RealVal);
  if Days < 0.0 then
    Result := Days + 1 - Hours
  else
    Result := Days + Hours;
end;

function ChangeFileDate(const AFileName: AnsiString;
  ACreateTime, ALastAccess, AWriteTime: FileTime): Boolean;
var
  FileH, ErrorCode: Integer;
  PCreateTime, PWriteTime, PAccessTime: PFileTime;
  S: AnsiString;
begin
  Result := False;
  PCreateTime := @ACreateTime;
  PWriteTime := @AWriteTime;
  PAccessTime := @ALastAccess;

  FileH := WinApi.Windows.CreateFileA(PAnsiChar(AFileName), GENERIC_WRITE,
    // GENERIC_READ,
    FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS, 0);

  if FileH <> Integer(LocalINVALID_HANDLE_VALUE) then
    try
      ErrorCode := 99;
      if SetFileTime(FileH, PCreateTime, PAccessTime, PWriteTime) then
        ErrorCode := 0;
      if ErrorCode <> 0 then
      begin
        ErrorCode := GetLastError;
        S := WindowsErrorString(ErrorCode);
        raise Exception.Create(S);
      end;
    finally
      if not WinApi.Windows.CloseHandle(FileH) then
      begin
        S := WindowsErrorString(GetLastError);
        raise Exception.Create(S);
      end;
      // Was FileClose(FileH);
    end;
end;

procedure FileDates(const ADirFileName: AnsiString;
  out ACreateTime, ALastAccess, AWriteTime: FileTime);
var
  FileH: DWord;

begin
  try
    ACreateTime.dwHighDateTime := 0;
    ALastAccess.dwHighDateTime := 0;
    AWriteTime.dwHighDateTime := 0;
    ACreateTime.dwLowDateTime := 0;
    ALastAccess.dwLowDateTime := 0;
    AWriteTime.dwLowDateTime := 0;
    FileH := FileOpen(ADirFileName, fmOpenRead or fmShareDenyNone);
    { FileH := CreateFileA(PAnsiChar(ADirFileName), GENERIC_READ,
      FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
      FILE_FLAG_BACKUP_SEMANTICS, 0);
    }
    if FileH <> LocalINVALID_HANDLE_VALUE then
      try
        GetFileTime(FileH, @ACreateTime, @ALastAccess, @AWriteTime);
      finally
        FileClose(FileH);
      end
    Else
      Raise Exception.Create(WindowsErrorString(0));
  except
    on E: Exception do
      raise Exception.Create('FileDates::' + E.message)
  end;
end;

function ChangeFileDate(const AFileName: AnsiString;
  ACreateTime, ALastAccess, AWriteTime: TDateTime): Boolean;
{ sub } function BuildFileStructure(ADate: TDateTime): TFileTime;
  var
    LocalFileTime: TFileTime;
  begin
    LocalFileTime := DateTimeToFileTimeStructure(ADate);
    LocalFileTimeToFileTime(LocalFileTime, Result);
  end;

var
  FileH, ErrorCode: Integer;
  CreateTime, LastAccess, WriteTime: TFileTime;
  PCreateTime, PWriteTime, PAccessTime: PFileTime;
  S: AnsiString;
begin
  Result := False;
  PCreateTime := @CreateTime;
  PWriteTime := @WriteTime;
  PAccessTime := @LastAccess;
  FileH := CreateFileA(PAnsiChar(AFileName), GENERIC_WRITE, // GENERIC_READ,
    FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS, 0);

  if FileH <> Integer(LocalINVALID_HANDLE_VALUE) then
    try
      begin
        { NewCreateDate := DateTimeToFileDate(ATime); }
        ErrorCode := 99;
        if ACreateTime > 0.0 then
          CreateTime := BuildFileStructure(ACreateTime)
        else
          PCreateTime := nil;
        if ALastAccess > 0.0 then
          LastAccess := BuildFileStructure(ALastAccess)
        else
          PAccessTime := nil;
        if AWriteTime > 0.0 then
          WriteTime := BuildFileStructure(AWriteTime)
        else
          PWriteTime := nil;
        if SetFileTime(FileH, PCreateTime, PAccessTime, PWriteTime) then
          ErrorCode := 0;
        if ErrorCode <> 0 then
        begin
          ErrorCode := GetLastError;
          S := WindowsErrorString(ErrorCode);
          raise Exception.Create(S);
        end;
      end;
    finally
      if not WinApi.Windows.CloseHandle(FileH) then
      begin
        S := WindowsErrorString(GetLastError);
        raise Exception.Create(S);
      end;
      // Was FileClose(FileH);
      // FileClose(FileH);
    end;
end;

function ChangeFileDate(const AFileName: AnsiString; ATime: TDateTime;
  ACreateAcceesWrite: Byte): Boolean;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3 All 4: LastAccessLast Write }
var
  FileH, ErrorCode: Integer;
  LocalFileTime: TFileTime;
  FileTime: TFileTime;
  PCreateTime, PWriteTime, PAccessTime: PFileTime;
  S: AnsiString;
begin
  Result := False;
  PCreateTime := nil;
  PWriteTime := nil;
  PAccessTime := nil;
  case ACreateAcceesWrite of
    0:
      PCreateTime := @FileTime;
    1:
      PAccessTime := @FileTime;
    2:
      PWriteTime := @FileTime;
    3:
      begin
        PCreateTime := @FileTime;
        PAccessTime := @FileTime;
        PWriteTime := @FileTime;
      end;
    4:
      begin
        PAccessTime := @FileTime;
        PWriteTime := @FileTime;
      end;
  end;
  FileH := CreateFileA(PAnsiChar(AFileName), GENERIC_WRITE, // GENERIC_READ,
    FILE_SHARE_READ + FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS, 0);

  if FileH <> Integer(LocalINVALID_HANDLE_VALUE) then
    try
      begin
        { NewCreateDate := DateTimeToFileDate(ATime); }
        ErrorCode := 99;
        LocalFileTime := DateTimeToFileTimeStructure(ATime);
        // if DosDateTimeToFileTime(LongRec(NewCreateDate).Hi, LongRec(NewCreateDate).Lo, LocalFileTime) then
        if LocalFileTimeToFileTime(LocalFileTime, FileTime) then
          if SetFileTime(FileH, PCreateTime, PAccessTime, PWriteTime) then
            ErrorCode := 0;
        if ErrorCode <> 0 then
        begin
          ErrorCode := GetLastError;
          S := WindowsErrorString(ErrorCode);
          raise Exception.Create(S);
        end;
      end;
    finally
      FileClose(FileH);
    end
  Else
    Raise Exception.Create(WindowsErrorString(0));
  { FileH := FileOpen(AFileName, fmOpenReadWrite + fmShareExclusive);
    try
    NewCreateDate := DateTimeToFileDate(ATime);
    if 0 = FileSetDate(FileH, NewCreateDate) then
    Result := True;
    finally
    FileClose(FileH);
    end;
    except
    Result := False;
    end; }
end;

function CopyFileWithDates(const ASourceFilename, ADestFileName: AnsiString;
  AFailIfExists: Boolean): Boolean;
var
  CreateTime, LastAccess, WriteTime: FileTime;
  Error: string;
begin
  Result := { Windows. } CopyfileA(PAnsiChar(ASourceFilename),
    PAnsiChar(ADestFileName), AFailIfExists);
  if Result then
  begin
    FileDates(ASourceFilename, CreateTime, LastAccess, WriteTime);
    ChangeFileDate(ADestFileName, CreateTime, LastAccess, WriteTime);
  end
  Else
  begin
    Error := 'CopyFileWithDates::' + WindowsErrorString(0);
    OutputDebugString(PChar(Error));
  end;
end;

function CopyFileIS(const ASourceFilename, ADestFileName: AnsiString): LongInt;
// Is this faster than CopyFileA() no about 2.5 times slower
var
  StmA, StmB: TFileStream;
  Bffer: AnsiString;
  Sz, Count: Int64;
  BufferSz, DataRead, DataWrite: LongInt;
begin
  // Result := 0;
  StmA := nil;
  StmB := nil;
  try
    StmA := TFileStream.Create(ASourceFilename, fmOpenRead or fmShareDenyNone);
    StmB := TFileStream.Create(ADestFileName, fmCreate);
    Sz := StmA.Size;
    if Sz < 1000000 then
      BufferSz := Sz
    else
      BufferSz := 1000000;
    Count := 0;
    SetLength(Bffer, BufferSz);
    StmA.Seek(0, soFromBeginning);
    while Count < Sz - 1 do
    begin
      DataRead := StmA.read(Bffer[1], BufferSz);
      DataWrite := StmB.Write(Bffer[1], DataRead);
      if DataRead <> DataWrite then
        raise Exception.Create('Error in write to ' + ADestFileName);
      Count := Count + DataWrite;
    end;
    Result := Count;
  finally
    StmA.Free;
    StmB.Free;
  end;
end;
{$ENDIF}

function DataMatch(ABuf1, ABuf2: Pointer; ASize1, ASize2: LongWord): Boolean;

const
  MaxEnSz = MaxInt;
type
  byte_buffer = record
    one_byte: array [1 .. MaxEnSz] of Byte;
  end;

  buffer_ptr = ^byte_buffer;

var
  i: LongWord;

begin
  if ASize1 <> ASize2 then
    Result := False
  else if ASize1 = 0 then
    Result := true
  else
    try
      Result := true;
      i := 1;
      while Result and (i <= ASize1) do
      begin
        Result := buffer_ptr(ABuf1)^.one_byte[i] = buffer_ptr(ABuf2)
          ^.one_byte[i];
        Inc(i);
      end;
    except
      Result := False;
    end;
end;

function FileDataMatch(const AFileNameOne, AFileNameTwo: AnsiString): Boolean;
var
  StmA, StmB: TFileStream;
  Sz: Int64;
  Count, Count2: Integer;
  Tst, Tst2: Int64;

begin
  Result := False;
  Count := 0;
  Count2 := 0;
  StmA := nil;
  StmB := nil;
  try
    StmA := TFileStream.Create(AFileNameOne, fmOpenRead or fmShareDenyNone);
    StmB := TFileStream.Create(AFileNameTwo, fmOpenRead or fmShareDenyNone);
    Sz := StmA.Size;
    Result := Sz = StmB.Size;
    StmA.Seek(Int64(0), soFromBeginning);
    StmB.Seek(Int64(0), soFromBeginning);
    Count := 8;
    while Result and (Count = SizeOf(Tst)) do
    begin
      Tst := 0;
      Tst2 := 0;
      Count := StmA.read(Tst, SizeOf(Tst));
      Count2 := StmB.read(Tst2, SizeOf(Tst2));
      Result := (Tst = Tst2) and (Count = Count2);
    end;
  except
    on E: Exception do
      if E.message <> '' then
        Result := False;
  end;
  if Count <> Count2 then
  begin
    Tst := StmA.Seek(Int64(0), soFromEnd);
    Tst2 := StmA.Seek(Int64(0), soFromEnd);
    Result := Tst = Tst2;
  end;
  StmA.Free;
  StmB.Free;
end;

function TotalFileSizeKBytes(const ADirectoryName, AFilter: String;
  ADoSubs: Boolean): LongInt;
var
  CurrentSearchRec: TSearchRec;
  FileOk: Integer;
  FullDirPath, LocalFilter: String;

begin
  Result := 0;
  if ADirectoryName = '' then
    Exit;

  FullDirPath := ADirectoryName;
  if AFilter = '' then
    LocalFilter := '*.*'
  else
    LocalFilter := AFilter;

  if FullDirPath[Length(FullDirPath)] <> '\' then
    FullDirPath := FullDirPath + '\';

  if ADoSubs then
  begin
    FileOk := FindFirst(FullDirPath + '*.*', faDirectory, CurrentSearchRec);
    try
      while FileOk = 0 do
      begin
        if (CurrentSearchRec.Attr and faDirectory) <> 0 then
{$IFDEF MSWINDOWS}
          if CurrentSearchRec.FindData.cFileName[0] <> '.' then
            Result := Result + TotalFileSizeKBytes
              (FullDirPath + CurrentSearchRec.FindData.cFileName,
              AFilter, true);
{$ENDIF}
{$IFDEF POSIX}
        Result := Result + TotalFileSizeKBytes
          (FullDirPath + CurrentSearchRec.name, AFilter, true);
{$ENDIF}
        FileOk := FindNext(CurrentSearchRec);
      end;
    finally
      FindClose(CurrentSearchRec);
    end;
  end;

  FileOk := FindFirst(FullDirPath + LocalFilter, faReadOnly, CurrentSearchRec);
  try
    while FileOk = 0 do
    begin
      Result := Result + (CurrentSearchRec.Size div 1024);
      FileOk := FindNext(CurrentSearchRec);
    end;
  finally
    FindClose(CurrentSearchRec);
  end;
  {
    TSearchRec = record
    Time: Integer;
    Size: Integer;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindData;
    end;

    faReadOnly	$00000001	Read-only files
    faHidden	$00000002	Hidden files
    faSysFile	$00000004	System files
    faVolumeID	$00000008	Volume ID files
    faDirectory	$00000010	Directory files
    faArchive	$00000020	Archive files
    faAnyFile	$0000003F	Any file
  }
end;

function ApplicationNameIS: String;
{$IFDEF Android}
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
    Result := Copy(HomePath, idx + Length(cPre), 255)
  else
    Result := 'Idx Pre:' + IntToStr(idx);
  idx := Pos(cPost, Result);
  if idx > 3 then
    SetLength(Result, idx - 1)
  else
    Result := 'Idx Ppst:' + IntToStr(idx);
{$ELSE}
begin
  Result := Trim(ChangeFileExt(ExtractFileName(ParamStr(0)), ''));
{$ENDIF}
end;

function ExecuteableLongFileName: AnsiString;
var
  S: AnsiString;
  Searchrec: TSearchRec;
begin
  S := ParamStr(0);
  if FindFirst(S, 0, Searchrec) = 0 then
{$IFDEF MSWINDOWS}
    Result := Searchrec.FindData.cFileName
{$ENDIF}
{$IFDEF POSIX}
      Result := Searchrec.name
{$ENDIF}
  else
    Result := '';
  FindClose(Searchrec);
end;

function OpenIniFileIS: TIniFile;
Var
  IniFileName: String;
  Tst:TIniFile;
begin
  try
{$IFDEF Android}
    IniFileName := System.IOUtils.TPath.Combine(
     System.IOUtils.TPath.GetHomePath,ApplicationNameIS + 'ini');
{$ELSE}
    IniFileName := ChangeFileExt(ExeFileNameAllPlatforms, '.ini');
{$ENDIF}
    if Not FileExists(IniFileName) then
      begin
         Tst:=TIniFile.Create(IniFileName);
        Try
          Tst.WriteString('Application','ThisIniFile',IniFileName);
        Finally
          Tst.Free;
        End;
      end;
    if Not FileExists(IniFileName) then
       ISIndyUtilsException('IsProcCl','No Ini File created :'+IniFileName);
    Result := TIniFile.Create(IniFileName);
{$IfDef Android}
    ISIndyUtilsException('ISProc','Ini File Name= "'+ IniFileName+'"');
{$EndIf}

  Except
    Result := nil;
  end;
end;

function NextAvailableFileName(ABaseDesiredFileName: AnsiString): AnsiString;
// Returns d:\Dir\Dir2\ThisFile22.ext from d:\Dir\Dir2\ThisFile.ext or ThisFile.ext
var
  TestBaseNm, TestFileName, Extension: AnsiString;
  TestInt: Integer;

begin
  Result := '';
  if Trim(ABaseDesiredFileName) = '' then
    Exit;

  TestBaseNm := Trim(ExpandFileName(ABaseDesiredFileName));
  Extension := ExtractFileExt(ABaseDesiredFileName);
  TestInt := 0;
  TestFileName := TestBaseNm;
  while FileExists(TestFileName) and (TestInt < 900) do
  begin
    Inc(TestInt);
    TestFileName := ChangeFileExt(TestBaseNm, IntToStr(TestInt) + Extension);
  end;
  Result := TestFileName;
end;

function GetOSPlatform: LongInt;
{ Type
  TOSVERSIONINFO=Record
  dwOSVersionInfoSize:DWord;
  dwMajorVersion:DWord;
  dwMinorVersion:DWord;
  dwBuildNumber:DWord;
  dwPlatformId:DWord;
  szCSDVersion:array[0..127]of Ansichar;
  end;
  {
  VER_PLATFORM_WIN32s	Win32s on Windows 3.1.
  VER_PLATFORM_WIN32_WINDOWS	Win32 on Windows 95.
  VER_PLATFORM_WIN32_NT	Win32 on Windows NT.
  Windows unit line 6459 }
{$IFDEF MSWInDOWS}
var
  v: TOSVERSIONINFO;
  Return: longBool;
begin
  v.dwOSVersionInfoSize := SizeOf(v);
  Return := GetVersionEx(v);
  if Return then
    Result := v.dwMajorVersion
  else
    Result := 0;
{$ELSE}
begin
{$IFDEF FPC}
  Result := 5;
{$ELSE}
  Result := VER_Platform_OSX;
{$ENDIF}
{$ENDIF}
end;

function NoOfFilesMatchingMask(AMask: AnsiString): Integer;
var
  SrchRec: TSearchRec;
  Rslt: Integer;
begin
  Result := 0;
  Rslt := FindFirst(AMask, 0, SrchRec);
  while Rslt = 0 do
  begin
    Inc(Result);
    Rslt := FindNext(SrchRec);
  end;
  FindClose(SrchRec);
end;

{$IFDEF MSWINDOWS}

function GetWindowsFontFolder: String;
begin
  Result := GetSpecialFolderLocation(CSIDL_FONTS);
end;
{$ENDIF}

function GetMyAppsDataFolder: String;
begin
  { X.Env.SearchPath - Returns the currently registered search path on the system.
    X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
    X.Env.ExeFilename - Returns the actual filename of the running executable.
    X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
    X.Env.ExeFolder - Returns the full folder path to the executable.
    X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
    X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
  }
{$IFDEF MSWINDOWS}
  Result := GetSpecialFolderLocation(CSIDL_APPDATA);
{$ELSE}
  Result := TPath.GetHomePath;
{$ENDIF}
end;
function GetMyDocsFolder: String;
begin
  { X.Env.SearchPath - Returns the currently registered search path on the system.
    X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
    X.Env.ExeFilename - Returns the actual filename of the running executable.
    X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
    X.Env.ExeFolder - Returns the full folder path to the executable.
    X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
    X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
  }
{$IFDEF MSWINDOWS}
  Result := GetSpecialFolderLocation(CSIDL_PERSONAL);
{$ELSE}
  Result := TPath.GetDocumentsPath;
{$ENDIF}
end;


{$IFNDEF FPC}
function GetCommonAppsDataFolder: String;
begin
{$IFDEF MSWINDOWS}
{$IFDEF UNICODE}
  Result := GetSpecialFolderLocation(CSIDL_COMMON_APPDATA);
{$ELSE}
  Result := '';
{$ENDIF}
{$ELSE}
  Result := TPath.GetPublicPath;
{$ENDIF}
end;

function GetCommonDocsFolder: String;
begin
  Result := TPath.GetSharedDocumentsPath;
end;

function GetTemporaryFileFolder: String;
begin
{$IFDEF ISXE2_DELPHI}
  Result := TPath.GetTempPath;
{$ELSE}
  Result := GetWindowsTempFileDirectory;
{$ENDIF}
end;
{$ENDIF}
{$IFDEF MSWINDOWS}

function WindowsErrorString(OptionalCode: DWord): AnsiString;
// Returns Last Error as String;
// Could use RaiseLastOSError
var
  ErrorStat: DWord;
  Return: AnsiString;
begin
  if OptionalCode = 0 then
    ErrorStat := GetLastError
  else
    ErrorStat := OptionalCode;
  if (ErrorStat >= 12000) and (ErrorStat < 12176) then
{$IFDEF ISXE2_DELPHI}
{$IFDEF UNICODE}
    Result := WinINetErrorString(ErrorStat)
{$ENDIF}
{$ENDIF}
  Else
  Begin
    SetLength(Return, 256);
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrorStat, 0,
      PAnsiChar(Return), 256, nil);
    Result := PAnsiChar(Return);
  End;
end;

procedure SetupTokenPrivileges;
{ sample code from gchandler@gajits.com@mail.gajits.com
}

var
{$IFDEF ISXE2_DELPHI}
  hToken: NativeUInt;
{$ELSE}
  hToken: Cardinal;
{$ENDIF}
  PreviousState, tkp: TOKEN_PRIVILEGES;
  dummy: Cardinal;
begin

  if Win32Platform <> VER_PLATFORM_WIN32_NT then
    Exit;


  // Get the current process token handle so we can get shutdown
  // privilege.

  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then
  begin

    // Get the LUID for shutdown privilege.

    LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].LUID);

    tkp.PrivilegeCount := 1; // one privilege to set
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

    // Get shutdown privilege for this process.

    AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TOKEN_PRIVILEGES),
      PreviousState, dummy);

    // Cannot test the return value of AdjustTokenPrivileges.

    if GetLastError <> ERROR_SUCCESS then
      raise Exception.Create('AdjustTokenPrivileges enable failed.');
  end
  else
    raise Exception.Create('OpenProcessToken failed');
end;

{
  >I'd like to display the project version data in an about box.
  >
  >Are these values properties of some object I haven't discovered?

}

function GetVersionField(const Field: AnsiString): AnsiString;
begin
  Result := GetVersionFieldForFile(Field, '');
end;

function GetVersionFieldForFile(const Field, OptFilename: AnsiString)
  : AnsiString;
{ Valid Field Names
  CompanyName FileDescription FileVersion InternalName LegalCopyright OriginalFilename ProductName ProductVersion

  function DoAnsi(AUncodeStr:String):ansistring;
  begin
  Result:=AUncodeStr;   //horrible patch
  end; }
var
  VersionInfoSize, Handle, ValueLen: Cardinal;
  VersionInfo: Pointer;
  Value: PAnsiChar;
  VersionInfoTranslation: ^Integer;
  Filename: AnsiString;
begin
  Result := '';
  if OptFilename <> '' then
    Filename := ExpandFileName(OptFilename)
  else
    Filename := ParamStr(0); // Application.ExeName;
  VersionInfoSize := GetFileVersionInfoSizeA(PAnsiChar(Filename), Handle);
  if VersionInfoSize > 0 then
  begin
    GetMem(VersionInfo, VersionInfoSize);
    try
      GetFileVersionInfoA(PAnsiChar(Filename), Handle, VersionInfoSize,
        VersionInfo);
      VerQueryValueA(VersionInfo, PAnsiChar('\VarFileInfo\Translation'),
        Pointer(VersionInfoTranslation), ValueLen);
      if VerQueryValueA(VersionInfo,
        PAnsiChar(AnsiString(Format('\StringFileInfo\%4.4x%4.4x\%s',
        [LoWord(VersionInfoTranslation^), HiWord(VersionInfoTranslation^),
        Field]))), Pointer(Value), ValueLen) then
        Result := AnsiString(Value);
    finally
      { Mod  10 May 2015  Memleak }
      FreeMem(VersionInfo)
    end;
  end;
end; { }

function ForceTerminateThread(var ThisThread: TThread): Boolean;
// From notes by Robert P at frontiersoftware.com.au
var
  Return: DWord;
  ThreadExitCode: Cardinal;
  S: AnsiString;
begin
  Result := False;
  if ThisThread = nil then
    Exit;
  ThisThread.Terminate;
  Return := WaitForSingleObject(ThisThread.Handle, 200);
  if (Return = WAIT_OBJECT_0) or (Return = Wait_Failed) then
    // Handle not active or not Valid
    Result := true
  else
    try // Not gone Get Rough
      Return := DWord(GetExitCodeThread(ThisThread.Handle, ThreadExitCode));
      if Return = 0 then
        S := WindowsErrorString(0);
      if ThreadExitCode = STILL_ACTIVE then
      begin
        ThreadExitCode := Wait_Failed; // DWORD($FFFFFFFF)
        Return := DWord(TerminateThread(ThisThread.Handle, ThreadExitCode));
        if Return = 0 then
          S := WindowsErrorString(0)
        else
          CloseHandle(ThisThread.Handle);
      end;
      Result := true;
    except // Something went wrong but things were wrong already
    end;
  if Result then
    try
      FreeAndNil(ThisThread);
    except // Something went wrong but things were wrong already
    end;
end;

function SetFileAssociations(AssExtention { .myp } ,
  AssInternalName { UniqueKeyName } , AssExeFile { Full Path of Exe File }
  : AnsiString): Boolean;
{ [Registry] settings from InnoSetUp Help
  Root: HKCR; Subkey: ".myp"; ValueType: string; ValueName: ""; ValueData: "MyProgramFile"; Flags: uninsdeletevalue
  ".myp" is the extension we're associating. "MyProgramFile" is the internal name for the file type as stored in the registry. Make sure you use a unique name for this so you don't inadvertently overwrite another application's registry key.

  Root: HKCR; Subkey: "MyProgramFile"; ValueType: string; ValueName: ""; ValueData: "My Program File"; Flags: uninsdeletekey
  "My Program File" above is the name for the file type as shown in Explorer.

  Root: HKCR; Subkey: "MyProgramFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "apppath\MYPROG.EXE,0"
  "DefaultIcon" is the registry key that specifies the filename containing the icon to associate with the file type. ",0" tells Explorer to use the first icon from MYPROG.EXE. (",1" would mean the second icon.)

  Root: HKCR; Subkey: "MyProgramFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """appPath\MYPROG.EXE"" ""%1"""
  "shell\open\command" is the registry key that specifies the program to execute when a file of the type is double-clicked in Explorer. The surrounding quotes are in the command line so it handles long filenames correctly. }

{ Make Explorer look up the new values ?? otherwise requires reboot }

{ var
  Reg: TRegistry; }
begin
  Result := False;
end;

function FindFileExecuteableAssociations(AFileName: AnsiString): AnsiString;
var
  ThisReg: TRegistry;
  KNames: TStringList;
  i: Integer;
  Ext, AppName, OpenExeName, Rslt, Sym, SymR: AnsiString;
  Buffer: array [0 .. 255] of AnsiChar;

begin
  Ext := ExtractFileExt(AFileName);
  AppName := '';
  OpenExeName := '';
  Rslt := '';
  ThisReg := TRegistry.Create;
  KNames := TStringList.Create;
  try
    ThisReg.RootKey := HKEY_CLASSES_ROOT;
    if ThisReg.OpenKeyReadOnly(Ext) then
    begin
      ThisReg.GetValueNames(KNames);
      for i := 0 to KNames.Count - 1 do
        if lowercase(KNames[i]) = '' then
          AppName := ThisReg.ReadString(KNames[i]);
    end;
    if AppName <> '' then
      if ThisReg.OpenKeyReadOnly('\' + AppName + '\shell') then
        if ThisReg.OpenKeyReadOnly('\' + AppName + '\shell\open\command') then
        begin
          ThisReg.GetValueNames(KNames);
          for i := 0 to KNames.Count - 1 do
            if lowercase(KNames[i]) = '' then
              Rslt := ThisReg.ReadString(KNames[i]);
        end;
  finally
    ThisReg.Free;
    KNames.Free;
  end;

  if Rslt <> '' then
  begin
    i := Pos('/', Rslt);
    if i > 0 then
      SetLength(Rslt, i - 1);
    Rslt := Trim(StringReplace(Rslt, '"', ' ', [rfReplaceAll]));
    i := Pos('%', Rslt);
    if i = 1 then
    begin
      Rslt[1] := ' ';
      i := Pos('%', Rslt);
      if i > 0 then
      begin
        Sym := Copy(Rslt, 2, i - 2);
{$IFDEF ISD12A_DELPHI}
        SetString(SymR, PChar(GetEnvironmentVariableA(Sym)), SizeOf(Buffer));
{$ELSE}
        SetString(SymR, Buffer, GetEnvironmentVariableA(PAnsiChar(Sym), Buffer,
          SizeOf(Buffer)));
{$ENDIF}
        Rslt := Trim(SymR) + Copy(Rslt, i + 1, Length(Rslt));
      end;
    end;
    i := Pos('%', Rslt);
    if i > 0 then
      SetLength(Rslt, i - 1);
    i := Pos(' -', Rslt);
    if i > 0 then
      SetLength(Rslt, i - 1);
  end;

  Result := Trim(Rslt);
end;

function SearchDir(SDir, Filename: AnsiString; GoDeep: Integer;
  var ReturnRec: TSearchRec; var FullFilePath: AnsiString): Boolean;

var
  NextFound, Newfound: TSearchRec;
  SearchSolved: Boolean;
  ThisPathName: AnsiString;
  Doserror: Integer;

begin
  SearchSolved := False;
  FullFilePath := SDir;
  if FullFilePath[Length(FullFilePath)] <> '\' then
    FullFilePath := FullFilePath + '\';
  Doserror := FindFirst(FullFilePath + Filename, faAnyfile, Newfound);
  { SysUtils. } FindClose(Newfound);
  if Doserror = 0 then
    SearchSolved := true
  else if (GoDeep > 0) then
  begin
    ThisPathName := FullFilePath;
    Doserror := FindFirst(FullFilePath + '*', faDirectory, NextFound);
    while (Doserror = 0) and (SearchSolved = False) do
    begin
      { If NextFound.name[length(NextFound.name)]<>'.' then }
      if Pos('.', NextFound.name) = 0 then
        SearchSolved := SearchDir(FullFilePath + NextFound.name, Filename,
          GoDeep - 1, Newfound, FullFilePath);
      if not SearchSolved then
      begin
        Doserror := FindNext(NextFound);
        FullFilePath := ThisPathName;
      end;
    end;
    { SysUtils. } FindClose(NextFound);
  end;
  ReturnRec := Newfound;
  SearchDir := SearchSolved;
end;

function SearchForFile(DesiredDisk, DesiredDirectory, Filename: AnsiString;
  SearchRange: FileSearchRange; var ResultRec: TSearchRec): AnsiString;
{ Desired disk as 'c:' ie no '\' }

var
  FileFound: Boolean;
  NextDisk: Byte;
  ResultPath: AnsiString;

begin
  SearchForFile := NoFileFound;
  FileFound := False;
  case SearchRange of
    SearchAll: { a: to d: }
      begin
        NextDisk := Ord('A');
        FileFound := SearchDir(DesiredDisk + DesiredDirectory, Filename, 5,
          ResultRec, ResultPath);
        if not FileFound then
          FileFound := SearchDir(DesiredDisk + '\', Filename, 99, ResultRec,
            ResultPath);
        while not FileFound and (NextDisk <= Ord('D')) do
        begin
          if Ord(DesiredDisk[1]) = NextDisk then
            NextDisk := NextDisk + 1;
          FileFound := SearchDir(AnsiChr(NextDisk) + ':\', Filename, 99,
            ResultRec, ResultPath);
          NextDisk := NextDisk + 1;
        end;
      end;
    SearchDisk:
      begin
        FileFound := SearchDir(DesiredDisk + DesiredDirectory, Filename, 5,
          ResultRec, ResultPath);
        if not FileFound then
          FileFound := SearchDir(DesiredDisk + '\', Filename, 99, ResultRec,
            ResultPath);
      end;
    SearchOneDir:
      FileFound := SearchDir(DesiredDisk + DesiredDirectory, Filename, 0,
        ResultRec, ResultPath);
    SearchOneDirAndSubs:
      FileFound := SearchDir(DesiredDisk + DesiredDirectory, Filename, 9999,
        ResultRec, ResultPath);
    SearchPath:
      begin
        Writeln('Code Not Complete 8765934');
      end;
  end; { case }
  if FileFound then
    if (Filename = DirFileC) or (Filename = HomeDirC) then
      SearchForFile := ResultPath
    else
      SearchForFile := ResultPath + ResultRec.name;
end;

function CreateConfirmDirectory(DesiredDisk, { Disk for Directory eg C:\ }
  DesiredDirectory: AnsiString; { Directory Spec }
  CreateOption: FileCreateOptions; var ResultRec: TSearchRec): AnsiString;
{ FileCreateOptions=(CreateBest      : Create new directory in best matching path
  BestDir         : Return closest directory
  CreateAbsolute  : Create full path and create directory
  ConfirmOnly     : Confirm existance of directory }

type
  PDRec = ^DirRecord;

  DirRecord = record
    Next: PDRec;
    name: AnsiString;
  end;

var
  NewPath: AnsiString;
  NewDir, FoundFile: AnsiString;
  UnResolvedDirs, NextDir: PDRec;

begin
  // Consider us of ForceDirectories

  FoundFile := NoFileFound;
  DesiredDisk := UpperCase(DesiredDisk);
  CreateConfirmDirectory := NoFileFound;
  if DesiredDisk <> '' then
    NewPath := ConcatToFullFileName(DesiredDisk, DesiredDirectory)
  else
    NewPath := ExpandFileName(DesiredDirectory);

  if NewPath[Length(NewPath)] <> '\' then
    NewPath := NewPath + '\';

  UnResolvedDirs := nil;
  NewPath := ExtractFilePath(NewPath);
  { changed from fexpand to ExtractFilePath }
  DesiredDisk := Copy(NewPath, 1, Pos('\', NewPath));
  while (Length(NewPath) > 3) and (FoundFile = NoFileFound) do
  begin
    FoundFile := SearchForFile('', NewPath, DirFileC, SearchOneDir, ResultRec);
    CreateConfirmDirectory := FoundFile;
    { Does the Dir File Exist in this directory }
    if FoundFile = NoFileFound then
    begin
      new(NextDir);
      NextDir^.Next := UnResolvedDirs;
      Delete(NewPath, Length(NewPath), 1);
      NextDir^.name := ExtractFileName(NewPath); { ????????? }
      NewDir := ExtractFilePath(NewPath);
      { was FSplit(NewPath,NewDir,NextDir^.Name,NewExt); }
      NewPath := NewDir;
      NextDir^.Next := UnResolvedDirs;
      UnResolvedDirs := NextDir;
    end;
  end;
  if (Length(NewPath) <= 3) and (NewPath <> DesiredDisk) then
    case CreateOption of
      BestDir, CreateBest:
        CreateConfirmDirectory := CreateConfirmDirectory(NewPath,
          DesiredDirectory, CreateOption, ResultRec);
      CreateAbsolute, ConfirmOnly:
        CreateConfirmDirectory := NoFileFound;
    end { CASE }
  else
    case CreateOption of
      BestDir:
        CreateConfirmDirectory := NewPath;
      CreateBest, CreateAbsolute:
        while UnResolvedDirs <> nil do
        begin
          NewPath := NewPath + UnResolvedDirs^.name;
          try
            MkDir(NewPath);
          except
            raise Exception.Create('Error in CreateConfirmDirectory' +
              'Filepath=' + NewPath);
          end;
          NewPath := NewPath + '\';
          NextDir := UnResolvedDirs;
          UnResolvedDirs := UnResolvedDirs^.Next;
          Dispose(NextDir);
          CreateConfirmDirectory := SearchForFile('', NewPath, DirFileC,
            SearchOneDir, ResultRec);
        end;
      ConfirmOnly:
        if UnResolvedDirs <> nil then
          CreateConfirmDirectory := NoFileFound
        else
          CreateConfirmDirectory := NewPath;
    end; { case }
  while UnResolvedDirs <> nil do
  begin
    NextDir := UnResolvedDirs;
    UnResolvedDirs := UnResolvedDirs^.Next;
    Dispose(NextDir);
  end;
end;

procedure CreateShortcutLink;
// (const PathObj, PathLink, Desc, Param: String);
{ From: Glen Kleidon <gklei@gippspath.com.au>
  To: 'ADUG Members list' <members@adug.org.au>
  Subject: RE: ADUG: Create a Shortcut.
  Date: Fri, 3 Oct 2003 14:21:59 +1000
  Sorry to answer my own question, but I should have checked Google first. }

{$IFDEF FMXApplication}
begin

{$ELSE}
var
  IObject: IUnknown;
  PFile: IPersistFile;
{$IFDEF UNICODE}
  SLink: IShellLinkW;
{$ELSE}
  SLink: IShellLinkA;
{$ENDIF}
begin
  IObject := CreateComObject(CLSID_ShellLink);
  SLink := IObject as IShellLink;
  PFile := IObject as IPersistFile;
  with SLink do
  begin
{$IFDEF UNICODE}
    SetArguments(PWideChar(Param));
    SetDescription(PWideChar(Desc));
    SetPath(PWideChar(PathObj));
{$ELSE}
    SetArguments(PAnsiChar(Param));
    SetDescription(PAnsiChar(Desc));
    SetPath(PAnsiChar(PathObj));
{$ENDIF}
  end;
  PFile.Save(PWChar(WideString(PathLink)), False);
{$ENDIF}
end;

(*
  From Misha Charrett  25/4/24
  https://learn.microsoft.com/en-us/windows/win32/psapi/process-memory-usage-information

  You want page file usage. Here is an old snippet of code I still use:
*)
// ------------------------------------------------------------------------------
// CsiGetProcessMemory
//
// Return the amount of memory used by the process
// ------------------------------------------------------------------------------

function CsiGetProcessMemory: Int64;
var
  lMemoryCounters: TProcessMemoryCounters;
  lSize: Integer;
begin
  lSize := SizeOf(lMemoryCounters);
  FillChar(lMemoryCounters, lSize, 0);
  { if GetProcessMemoryInfo(CsiGetProcessHandle, @lMemoryCounters, lSize) then
    Result := lMemoryCounters.PageFileUsage
    else }
  Result := 0;
end;


// From http://delphi.about.com/od/delphitips2007/qt/memory_usage.htm

function CurrentMemoryUsage: Cardinal;
var
  pmc: TProcessMemoryCounters;
begin
  Result := 0;
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
    Result := pmc.WorkingSetSize
  else
    RaiseLastOSError;
end;
{ To display the memory usage in KB, use:

  ShowMessage(FormatFloat('Memory used: ,.# K', CurrentMemoryUsage / 1024)) ;

  Note: The TProcessMemoryCounters record wraps up the Windows API PROCESS_MEMORY_COUNTERS structure. Here's the meaning of the other fields:

  * PageFaultCount - the number of page faults.
  * PeakWorkingSetSize - the peak working set size, in bytes.
  * WorkingSetSize - the current working set size, in bytes.
  * QuotaPeakPagedPoolUsage - The peak paged pool usage, in bytes.
  * QuotaPagedPoolUsage - The current paged pool usage, in bytes.
  * QuotaPeakNonPagedPoolUsage - The peak nonpaged pool usage, in bytes.
  * QuotaNonPagedPoolUsage - The current nonpaged pool usage, in bytes.
  * PagefileUsage - The current space allocated for the pagefile, in bytes. Those pages may or may not be in memory.
  * PeakPagefileUsage - The peak space allocated for the pagefile, in bytes.
}

function MemoryManage: Integer;
{ Andrew Rutherford <Andrew@objectconnections.com>

  procedure TOCMemoryInfoForm.FormShow(Sender: TObject);

  begin
  HeapStatus := GetHeapStatus;
  TotalAddressSpaceEdit.Text := IntToStr( HeapStatus.TotalAddrSpace );
  TotalUncommittedEdit.Text  := IntToStr( HeapStatus.TotalUncommitted );
  TotalCommittedEdit.Text    := IntToStr( HeapStatus.TotalCommitted );
  TotalAllocatedEdit.Text    := IntToStr( HeapStatus.TotalAllocated );
  TotalFreeEdit.Text         := IntToStr( HeapStatus.TotalFree );
  FreeSmallEdit.Text         := IntToStr( HeapStatus.FreeSmall );
  FreeBigEdit.Text           := IntToStr( HeapStatus.FreeBig );
  UnusedEdit.Text            := IntToStr( HeapStatus.Unused );
  OverheadEdit.Text          := IntToStr( HeapStatus.Overhead );
  end;

}
var
  HeapStatus: THeapStatus;
begin
  HeapStatus := GetHeapStatus;
  Result := HeapStatus.TotalAllocated;
  // Result:=MemAllocCount;
end;

procedure DisposePIDL(ID: PItemIDList);
{ Sample Code Fromgchandler@gajits.com@mail.gajits.com }
var
  Malloc: IMalloc;
begin
  if ID = nil then
    Exit;
  OLECheck(SHGetMalloc(Malloc));
  Malloc.Free(ID);
end;

function GetWindowsTempFileDirectory: AnsiString;
var
  Path: AnsiString;
  PthChr: PAnsiChar;

begin
  SetLength(Path, Max_Path);
  PthChr := PAnsiChar(Path);
  PthChr[0] := AnsiChar(0);
  GetTempPathA(256, PthChr);
  SetLength(Path, Length(PthChr));
  Result := Path;
end;

function GetWindowsSystemDir: AnsiString;
var
  Bfr: AnsiString;
  BfrPtr: PAnsiChar;

begin
  Result := '';
  SetLength(Bfr, Max_Path);
  BfrPtr := PAnsiChar(Bfr);
  if GetSystemDirectoryA(BfrPtr, Max_Path) > 0 then
    Result := BfrPtr;
end;

function GetProgramFilesFolder: AnsiString;
// var
// s: AnsiString;
begin
  { s := GetWindowsSystemDir;
    s := ExtractFileDrive(s) + '\Program Files';

    Result := s; { 'C:\program files'; }
  // ifdef WIN64  ??
  Result := GetSpecialFolderLocation(CSIDL_PROGRAM_FILES);
  // Result:=GetSpecialFolderLocation(CSIDL_COMMON_PROGRAMS);
end;

function GetSpecialFolderLocation(Folder: Integer): AnsiString;
{ Sample Code Fromgchandler@gajits.com@mail.gajits.com
  The value for Folder passed to this is one of the following:

  CSIDL_DESKTOP,                 CSIDL_PROGRAMS,
  CSIDL_CONTROLS,                CSIDL_PRINTERS,
  CSIDL_PERSONAL, mydocs         CSIDL_FAVORITES,
  CSIDL_STARTUP,                 CSIDL_RECENT,
  CSIDL_SENDTO,                  CSIDL_BITBUCKET,
  CSIDL_STARTMENU,               CSIDL_DESKTOPDIRECTORY,
  CSIDL_DRIVES,                  CSIDL_NETWORK,
  CSIDL_NETHOOD,                 CSIDL_FONTS,
  CSIDL_TEMPLATES,               CSIDL_COMMON_STARTMENU,
  CSIDL_COMMON_PROGRAMS,         CSIDL_COMMON_STARTUP,
  CSIDL_COMMON_DESKTOPDIRECTORY, CSIDL_APPDATA,
  CSIDL_PRINTHOOD

  In ShlObj.pas

}
var
  TargetDir: array [0 .. Max_Path] of AnsiChar;
  SpecialFolderLocation: PItemIDList;
begin
  SpecialFolderLocation := nil;
  Try
    SHGetSpecialFolderLocation(0, Folder, SpecialFolderLocation);
    {
      I don't have an answer for you, but you should use
      SHGetFolderPath
      instead of
      SHGetSpecialFolderPath which is no longer supported :
      https://msdn.microsoft.com/en-us/library/windows/desktop/bb762204%28v=vs.85%29.aspx
      Note  As of Windows Vista, this function is merely a wrapper for
      SHGetKnownFolderPath. The CSIDL value is translated to its associated
      KNOWNFOLDERID and then SHGetKnownFolderPath is called.
      New applications should use the known folder system rather than
      the older CSIDL system, which is supported only for backward compatibility.
      Note  As of Windows Vista, this function is merely a wrapper for SHGetKnownFolderIDList.
      The CSIDL value is translated to its associated KNOWNFOLDERID and SHGetKnownFolderIDList
      is called. New applications should use the known folder system rather than the
      older CSIDL system, which is supported only for backward compatibility.

      The SHGetFolderLocation, SHGetFolderPath, SHGetSpecialFolderLocation, and
      SHGetSpecialFolderPath functions are the preferred ways to obtain handles to
      folders on systems earlier than Windows Vista. Functions such as
      ExpandEnvironmentStrings that use the environment variable names directly,
      in the form %VariableName%, may not be reliable.

      This function is a superset of SHGetSpecialFolderLocation, included with earlier
      versions of the Shell.
    }

    if assigned(SpecialFolderLocation) then
    begin
      If SHGetPathFromIDListA(SpecialFolderLocation, TargetDir) then
        Result := TargetDir
        // Turn into real path.
      else
        Result := ''; // WindowsErrorString(0);
    end
    Else
      Result := '';
  Finally
    DisposePIDL(SpecialFolderLocation);
  End;

  { Virtual folders seem not to work
    CSIDL_BITBUCKET	Recycle bin
    file system directory containing file objects in the user's recycle bin.
    The location of this directory is not in the registry;
    it is marked with the hidden and system attributes to prevent
    the user from moving or deleting it.

    CSIDL_CONTROLS	Control Panel
    virtual folder containing icons for the control panel applications.

    CSIDL_DESKTOP	Windows desktop
    virtual folder at the root of the name space.

    CSIDL_DESKTOPDIRECTORY	File system directory used to physically store file
    objects on the desktop (not to be confused with the desktop folder itself).

    CSIDL_DRIVES	My Computer
    virtual folder containing everything on the local computer:
    storage devices, printers, and Control Panel.
    The folder may also contain mapped network drives.

    CSIDL_FONTS	Virtual folder containing fonts.

    CSIDL_NETHOOD	File system directory containing objects that
    appear in the network neighborhood.

    CSIDL_NETWORK	Network Neighborhood
    virtual folder representing the top level of the network hierarchy.

    CSIDL_PERSONAL	File system directory that serves
    as a common respository for documents.

    CSIDL_PRINTERS	Printers folder
    virtual folder containing installed printers.

    CSIDL_PROGRAMS	File system directory that contains the user's program groups
    (which are also file system directories).

    CSIDL_RECENT	File system directory that contains the user's most recently used documents.

    CSIDL_SENDTO	File system directory that contains Send To menu items.

    CSIDL_STARTMENU	File system directory containing Start menu items.

    CSIDL_STARTUP	File system directory that corresponds to the user's Startup program group.

    CSIDL_TEMPLATES	File system directory that serves as a common repository for document templates.
  }

end;
{$ENDIF}
{
  From: "rpallesen" <rpallesen@summitconsulting.com.au>
  To: ADUG Members list <members@adug.org.au>
  Subject: Re: ADUG: Setting permissions on shares

  Sharing a directory and setting the access rights are two different
  things.

  I am using the following code to change the access rights for a
  directory. You may have to modify it to suit your needs.

  Regards,

  Rene Pallesen

  --------------------------------

  unit DirectoryPermissions;

  interface

  uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,
  StdCtrls, AccCtrl;

  type

  PPSID = ^PSID;

  TDirectoryPermissions = class
  public
  ErrorMessage : string;
  function SetPermissions(ADirectory : string; AUserGroup :
  string) : boolean;
  constructor Create;
  Destructor Destroy; override;
  private
  DLLHandle : THandle;
  IsReady : boolean;
  SetEntriesInAcl : function (cCountOfExplicitEntries: ULONG;
  pListOfExplicitEntries: PEXPLICIT_ACCESS_A; OldAcl: PACL; NewAcl:
  Pointer): DWORD; stdcall;
  GetNamedSecurityInfo : function (pObjectName: PAnsiChar;
  ObjectType: SE_OBJECT_TYPE; SecurityInfo: SECURITY_INFORMATION;
  ppsidOwner, ppsidGroup: PPSID; ppDacl, ppSacl: PACL; var
  ppSecurityDescriptor: PSECURITY_DESCRIPTOR): DWORD; stdcall;
  BuildExplicitAccessWithName : procedure (pExplicitAccess:
  PEXPLICIT_ACCESS_; pTrusteeName: PAnsiChar; AccessPermissions: DWORD;
  AccessMode: ACCESS_MODE; Ineritance: DWORD); stdcall;
  SetNamedSecurityInfo : function (pObjectName: PAnsiChar;
  ObjectType: SE_OBJECT_TYPE; SecurityInfo: SECURITY_INFORMATION;
  ppsidOwner, ppsidGroup: PPSID; ppDacl, ppSacl: PACL): DWORD; stdcall;
  Function SetNTFSPermissionsOnFolder(FolderName, TrusteeName :
  string; AccessPermissions:Cardinal; AccessMode:ACCESS_MODE):integer;
  end;





  implementation

  //-------------------------------------------------------------------


  constructor TDirectoryPermissions.Create;
  begin
  ErrorMessage := '';
  IsReady := false;
  DllHandle := LoadLibrary('ADVAPI32.DLL');
  if DLLHandle >= 32 then
  begin
  @SetEntriesInAcl             := GetProcAddress
  (DLLHandle, 'SetEntriesInAclA');
  @GetNamedSecurityInfo        := GetProcAddress
  (DLLHandle, 'GetNamedSecurityInfoA');
  @BuildExplicitAccessWithName := GetProcAddress
  (DLLHandle, 'BuildExplicitAccessWithNameA');
  @SetNamedSecurityInfo        := GetProcAddress
  (DLLHandle, 'SetNamedSecurityInfoA');
  end;
  if (@SetEntriesInAcl <> nil) and (@GetNamedSecurityInfo <> nil) and
  (@BuildExplicitAccessWithName <> nil) and (@SetNamedSecurityInfo <>
  nil) then
  IsReady := true;
  end;

  //--------------------------------------------------------------


  destructor TDirectoryPermissions.Destroy;
  begin
  inherited;
  if DllHandle >= 32 then
  FreeLibrary(DllHandle);
  end;


  //------------------------------------------------------------

  function TDirectoryPermissions.SetPermissions(ADirectory : string;
  AUserGroup : string) : boolean;
  var
  Error : integer;
  begin
  ErrorMessage := '';
  Result := true;
  Error := 0;
  if IsReady then
  Error := SetNTFSPermissionsOnFolder(ADirectory, AUserGroup,
  SPECIFIC_RIGHTS_ALL, SET_ACCESS);
  if not IsReady then
  begin
  Result := false;
  ErrorMessage := 'Unable to load ADVAPI32.DLL';
  end;
  if Error <> 0 then
  begin
  Result := false;
  ErrorMessage := SysErrorMessage(Error);
  end;
  end;

  //----------------------------------------------------------------

  Function TDirectoryPermissions.SetNTFSPermissionsOnFolder(FolderName,
  TrusteeName:string; AccessPermissions:Cardinal;
  AccessMode:ACCESS_MODE):integer;
  var
  pOldDACL : PACL;
  pNewDACL : PACL;
  pSD : Pointer;
  EA : array[0..1] of EXPLICIT_ACCESS_A;
  begin
  pSD := nil;
  pNewDACL := nil;
  try
  Result := GetNamedSecurityInfo(PChar
  (FolderName),SE_FILE_OBJECT,DACL_SECURITY_INFORMATION,NIL,NIL,@pOldDACL
  ,NIL,pSD);
  if Result = 0 then
  begin
  BuildExplicitAccessWithName( @EA[0], PChar(TrusteeName),
  AccessPermissions, AccessMode, SUB_CONTAINERS_AND_OBJECTS_INHERIT);
  Result := SetEntriesInAcl( 1, @EA[0], pOldDACL, @pNewDACL);
  if (Result = 0) then
  Result := SetNamedSecurityInfo( PChar(FolderName),
  SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, NIL, NIL, pNewDACL, NIL);
  end;
  finally
  if(pSD<>nil) then
  LocalFree(Cardinal(pSD));
  if(pNewDACL<>nil) then
  LocalFree(Cardinal(pNewDACL));
  end;
  end;


  end.


}
{$IFDEF MSWINDOWS}

function GetDiscDriveType(Const ADrive: String): LongWord;
{
  0	The drive type cannot be determined.
  1	The root directory does not exist.
  DRIVE_REMOVABLE	The drive can be removed from the drive.
  DRIVE_FIXED	The disk cannot be removed from the drive.
  DRIVE_REMOTE	The drive is a remote (network) drive.
  DRIVE_CDROM	The drive is a CD-ROM drive.
  DRIVE_RAMDISK	The drive is a RAM disk.
}
Var
  Drive: String;
begin
  Drive := Trim(ADrive);
  if Drive = '' then
    Result := 0
  else
    Result := GetDriveType(@Drive[1]);
  if Result = 1 then
    if Pos('\\', Drive) = 1 then
      Result := DRIVE_REMOTE;
end;

function IsRemoteFile(AFileName: String): Boolean;
Begin
  Result := False;
  if AFileName = '' then
    Result := False
  else
    Case GetDiscDriveType(ExtractFileDrive(AFileName)) of
      1:
        Result := False; // 1	The root directory does not exist.
      0, DRIVE_FIXED:
        Result := False; // The disk cannot be removed from the drive.
      DRIVE_REMOVABLE, // The drive can be removed from the drive.
      DRIVE_REMOTE, // The drive is a remote (network) drive.
      DRIVE_CDROM, // The drive is a CD-ROM drive.
      DRIVE_RAMDISK: // The drive is a RAM disk.
        Result := true;
    end;
end;

Function FileIsNetworkDrive(AFileName: AnsiString): Boolean;
Var
  Drive: String;
  Rslt: Integer;
begin
  Result := False;
  Drive := ExtractFileDrive(AFileName);
  if Drive = '' then
    Exit;
  Rslt := GetDiscDriveType(Drive);
  Result := (Rslt = DRIVE_REMOTE) or (Rslt = DRIVE_NO_ROOT_DIR);
end;

Function FileIsLocalFixed(AFileName: AnsiString): Boolean;
Var
  Drive: String;
begin
  Result := False;
  Drive := ExtractFileDrive(AFileName);
  if Drive = '' then
    Exit;

  Result := GetDiscDriveType(Drive) = DRIVE_FIXED;
end;

Function ExtractFileDirIS(Const AFileName: String): String;
// Returns '' as the file directory for c:\ so repeat calls will terminate
// with '' not 'c:\'
begin
  try
    Result := ExtractFileDir(AFileName);
    if AFileName = Result then
      Result := ''
  Except
    Result := ''
  end;
end;

function GetSMPTDetailsFromOutLook: AnsiString;
begin

  { from Malcolm Smith
    Analyst Programmer
    Comvision Pty Ltd

    not implemented yet }

  (* typedef enum { ectNone, ectOutlook, ectOutlookExpress, ectOther }
    TEmailClientType;

    struct TOutlookAccountDetails
    {
    AnsiString  AccountName;
    AnsiString  DisplayName;
    AnsiString  EmailAddress;
    AnsiString  ReplyEmailAddress;
    AnsiString  Organisation;

    int         SMTPPort;
    AnsiString  SMTPServer;

    AnsiString  POP3UserName;
    int         POP3Port;
    AnsiString  POP3Server;  // user must provide the POP3 password
    };


    // returns details for the default account if available
    bool __fastcall IsOutlookAvailable(TOutlookAccountDetails *AccountDetails
    = 0);
    bool __fastcall IsOutlookExpressAvailable(TOutlookAccountDetails
    *AccountDetails = 0);



    and the implementation:


    bool __fastcall IsOutlookAvailable(TOutlookAccountDetails *AccountDetails)
    {
    /*
    HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Outlook.Application\CLSID
    (Default) = {0006F03A-0000-0000-C000-000000000046}

    HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0006F03A-0000-0000-C000-000000000
    046}\LocalServer32
    (Default) = path with .exe

    ** OR **

    HKEY_CLASSES_ROOT\outlook\shell\open\command
    (Default) = path with exe (in first "")
    */

    bool Available = false;

    std::auto_ptr<TRegistry> Reg(new TRegistry);
    Reg->RootKey = HKEY_LOCAL_MACHINE;

    if(Reg->OpenKey("SOFTWARE\\Classes\\Outlook.Application\\CLSID", false))
    {
    AnsiString OutlookGUID = Reg->ReadString("");

    Reg->CloseKey();

    AnsiString OutlookLocalServer32 = "SOFTWARE\\Classes\\CLSID\\" +
    OutlookGUID + "\\LocalServer32";

    if(Reg->OpenKey(OutlookLocalServer32, false))
    {
    AnsiString OutlookPath = Reg->ReadString("");

    Reg->CloseKey();

    if(FileExists(OutlookPath))
    {
    // ok, the file exists but is there a default account
    // HKEY_CURRENT_USER\Software\Microsoft\Office\Outlook\OMI Account
    Manager

    Reg->RootKey = HKEY_CURRENT_USER;
    if(Reg->OpenKey("Software\\Microsoft\\Office\\Outlook\\OMI Account
    Manager", false))
    {
    AnsiString DefaultAccount = Reg->ReadString("Default Mail Account");

    // make sure the account exists
    Reg->CloseKey();
    if(Reg->OpenKey("Software\\Microsoft\\Office\\Outlook\\OMI Account
    Manager\\Accounts\\" + DefaultAccount, false))
    {
    if(AccountDetails)
    {
    if(Reg->ValueExists("Account Name"))
    AccountDetails->AccountName = Reg->ReadString("Account Name");

    if(Reg->ValueExists("SMTP Display Name"))
    AccountDetails->DisplayName = Reg->ReadString("SMTP Display
    Name");

    if(Reg->ValueExists("SMTP Email Address"))
    AccountDetails->EmailAddress = Reg->ReadString("SMTP Email
    Address");

    if(Reg->ValueExists("SMTP Reply To Email Address"))
    AccountDetails->ReplyEmailAddress = Reg->ReadString("SMTP
    Reply To Email Address");

    if(Reg->ValueExists("SMTP Organization Name"))
    AccountDetails->Organisation = Reg->ReadString("SMTP
    Organization Name");

    if(Reg->ValueExists("SMTP Port"))
    AccountDetails->SMTPPort = Reg->ReadInteger("SMTP Port");
    else
    AccountDetails->SMTPPort = 25;    // a default

    if(Reg->ValueExists("SMTP Server"))
    AccountDetails->SMTPServer = Reg->ReadString("SMTP Server");

    if(Reg->ValueExists("POP3 User Name"))
    AccountDetails->POP3UserName = Reg->ReadString("POP3 User
    Name");

    if(Reg->ValueExists("POP3 Port"))
    AccountDetails->POP3Port = Reg->ReadInteger("POP3 Port");
    else
    AccountDetails->POP3Port = 110;   // a default

    if(Reg->ValueExists("POP3 Server"))
    AccountDetails->POP3Server = Reg->ReadString("POP3 Server");
    }

    Available = true;
    }
    }
    }

    }

    }

    return Available;
    }


    bool __fastcall IsOutlookExpressAvailable(TOutlookAccountDetails
    *AccountDetails)
    {
    bool Available = false;

    std::auto_ptr<TRegistry> Reg(new TRegistry);
    Reg->RootKey = HKEY_CURRENT_USER;

    // assuming the application is available since installed by OS
    //
    if(Reg->OpenKey("SOFTWARE\\Microsoft\\Internet Account Manager", false))
    {
    // get the next account number
    //int AccountName = Reg->ReadInteger("Account Name");   // the next
    account name that will be created

    // get the default account
    if(Reg->ValueExists("Default Mail Account"))
    {
    AnsiString DefaultAccount = Reg->ReadString("Default Mail Account");

    // make sure the account exists
    Reg->CloseKey();
    if(Reg->OpenKey("SOFTWARE\\Microsoft\\Internet Account
    Manager\\Accounts\\" + DefaultAccount, false))
    {
    if(AccountDetails)
    {
    if(Reg->ValueExists("Account Name"))
    AccountDetails->AccountName = Reg->ReadString("Account Name");

    if(Reg->ValueExists("SMTP Display Name"))
    AccountDetails->DisplayName = Reg->ReadString("SMTP Display
    Name");

    if(Reg->ValueExists("SMTP Email Address"))
    AccountDetails->EmailAddress = Reg->ReadString("SMTP Email
    Address");

    if(Reg->ValueExists("SMTP Reply To Email Address"))
    AccountDetails->ReplyEmailAddress = Reg->ReadString("SMTP Reply To
    Email Address");

    if(Reg->ValueExists("SMTP Organization Name"))
    AccountDetails->Organisation = Reg->ReadString("SMTP Organization
    Name");

    if(Reg->ValueExists("SMTP Port"))
    AccountDetails->SMTPPort = Reg->ReadInteger("SMTP Port");
    else
    AccountDetails->SMTPPort = 25;    // a default

    if(Reg->ValueExists("SMTP Server"))
    AccountDetails->SMTPServer = Reg->ReadString("SMTP Server");

    if(Reg->ValueExists("POP3 User Name"))
    AccountDetails->POP3UserName = Reg->ReadString("POP3 User Name");

    if(Reg->ValueExists("POP3 Port"))
    AccountDetails->POP3Port = Reg->ReadInteger("POP3 Port");
    else
    AccountDetails->POP3Port = 110;   // a default

    if(Reg->ValueExists("POP3 Server"))
    AccountDetails->POP3Server = Reg->ReadString("POP3 Server");
    }

    Available = true;
    }
    }
    }

    return Available;
    }



    Malcolm Smith
    Analyst Programmer
    Comvision Pty Ltd
    http://www.comvision.net.au
  *)
end;

{ TIsCriticalSection }

function TIsCriticalSection.TryEnterD7Compat: Boolean;
begin
  Result := TryEnterCriticalSection(FSection);
end;

{ TTemporyFile }

procedure TTemporyFile.AllowFileActions;
begin
  if FHandle > 0 then
    try
      CloseHandle(FHandle);
    except
    end;
  FHandle := 0;
end;

constructor TTemporyFile.Create;
var
  SA: TSecurityAttributes;
  Path, Bfr: AnsiString;
  PthChr, BfrChr: PAnsiChar;
const
  Prefix = TempFilePrefix;
begin
  SetLength(Path, Max_Path);
  PthChr := PAnsiChar(Path);
  Path[1] := AnsiChar(0);

  SetLength(Bfr, Max_Path);
  BfrChr := PAnsiChar(Bfr);
  Bfr[1] := AnsiChar(0);

  GetTempPathA(256, PthChr);
  GetTempFileNameA(PthChr, Prefix, 0, BfrChr);
  FFileName := BfrChr;
  FillChar(SA, SizeOf(SA), 0);
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := true;
  FHandle := { Windows. } CreateFileA(PAnsiChar(FFileName),
    GENERIC_WRITE + GENERIC_READ, FILE_SHARE_WRITE + FILE_SHARE_READ, @SA,
    CREATE_ALWAYS, FILE_ATTRIBUTE_TEMPORARY, 0);
end;

destructor TTemporyFile.Destroy;
begin
  try
    if FHandle > 0 then
      try
        CloseHandle(FHandle);
      except
      end;
    if FileExists(FFileName) then
      DeleteFile(FFileName);
  except
  end;
end;
{$ENDIF}
{$IFDEF MSWINDOWS}
{ TISUnsortedStringList }

function TISUnsortedStringList.Find(const S: string;
  var Index: Integer): Boolean;
Var
  i: Integer;
begin
  if Sorted then
    Result := inherited Find(S, Index)
  else
  begin
    Result := False;
    Index := -1;
    i := 0;
    while Not Result and (i < Count) do
    begin
      Result := CompareStrings(Get(i), S) = 0;
      if Result then
        Index := i
      else
        Inc(i);
    end;
  end;
end;
{$ENDIF}

end.
