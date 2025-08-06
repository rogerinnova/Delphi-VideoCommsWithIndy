{$I InnovaLibDefsLaz.inc}
unit IsLazarusPickup;

{$IFDEF FPC}
{$mode delphi}
{$ELSE}
Only
for Lazarus and FPC
{$ENDIF}
  interface

  uses Classes, SysUtils;

  Type

    { TPath }

    TPath = Class(TObject)
      Class Function LazVarDirectory(AStopException:Boolean=false):UnicodeString;
      Class Function DirectorySeparatorChar: WideChar;
      Class Function GetSharedDocumentsPath: UnicodeString;
      Class Function GetHomePath: UnicodeString;
      Class Function Combine(Const APath1, APath2: UnicodeString)
        : UnicodeString;
      Class Function GetTempPath: UnicodeString;
      Class Function GetDocumentsPath: UnicodeString;
      Class Function GetDirectoryName(AFileName: String): UnicodeString;
      Class Function PathSeparator: Char;
      Class Function GetFullPath(Const APath: UnicodeString): String;
    end;

    { TFile }

    TFile = Class(TObject)
      Class Function GetCreationTime(AName: String): TDateTime;
    end;

  Function GetLastError: DWORD;
  function ExeFileNameAllPlatforms: string;
  function GetVersionField(AField: String): String;
{//Returns a pointer to the first occurrence of S2 in S1. If S2 does not occur in S1, returns Nil.
  function StrPosLaz(St1,St2:PAnsichar):PAnsichar; overload;
  function StrPosLaz(St1,St2:PWidechar):PWidechar; overload;
}

implementation

uses IsLogging;

Function GetLastError: DWORD;
Begin
  Result := GetLastOSError;
end;

function GetVersionField(AField: String): String;
Begin
  Result := AField + '::Version Feild fo Laz not yet coded';
end;

function ExeFileNameAllPlatforms: string;
{ X.Env.SearchPath - Returns the currently registered search path on the system.
  X.Env.AppFilename - Returns the "app" name of the application.  On OS X this is the application package in which the exe resides.  On Windows, this is the name of the folder in which the exe resides.
  X.Env.ExeFilename - Returns the actual filename of the running executable.
  X.Env.AppFolder - Returns the folder path to the executable, stopping at the level of the application package on OSX.
  X.Env.ExeFolder - Returns the full folder path to the executable.
  X.Env.TempFolder - Returns a writable temp folder path that can be used by your application.
  X.Env.HomeFolder - Returns the user's writable home folder.  On OS X this equates to /Users/username and on Windows,  C:\Users\username\AppData\Roaming or the appropriate path as set on the system.
}
{$IFDEF POSIX}
Var
  i: Integer;
{$ENDIF}
begin
  Result := ParamStr(0);
{$IFDEF POSIX}
  i := Pos('.app', Result);
  if i > 2 then
    SetLength(Result, i + 3);
{$ENDIF}
end;


{function StrPosLaz(St1,St2:PAnsichar):PAnsichar; overload;
Begin
  Result :=AnsiStrPos(St1,St2);
end;

function StrPosLaz(St1,St2:PWidechar):PWidechar; overload;
Begin
  Result:= StrPos(St1,St2);
end;}

{ TFile }

class function TFile.GetCreationTime(AName: String): TDateTime;
begin
  Result := FileDateToDateTime(FileAge(AName));
end;

{ TPath }

class function TPath.DirectorySeparatorChar: WideChar;
begin
{$IFDEF Unix}
  Result := '/';
{$ELSE}
  Result := '\';
{$ENDIF}
end;

class function TPath.GetSharedDocumentsPath: UnicodeString;
begin
  Result := Combine(LazVarDirectory(true),'SharedDocs');
end;

class function TPath.GetHomePath: UnicodeString;
begin
  Result := Combine(LazVarDirectory(True),'home');
end;

class function TPath.Combine(const APath1, APath2: UnicodeString)
  : UnicodeString;
begin
  Result := Trim(APath2);
  If Result = '' then
  Begin
    Result := APath1;
    Exit;
  end;
  If APath1 = '' then
    Exit;
  If APath1[Length(APath1)] = DirectorySeparatorChar then
    Result := APath1 + Result
  Else
    Result := APath1 + DirectorySeparatorChar + Result;
end;

class function TPath.GetTempPath: UnicodeString;
begin
{$IFDEF Linux}
  Result := '/tmp/innovasolutions';
{$ELSE}
  Result := 'c:\Temp';
{$ENDIF}
end;

class function TPath.LazVarDirectory(AStopException:Boolean=false): UnicodeString;

begin
{$IFDEF Linux}
  Result:='/var/innovasolutions';
{$Else}
  Result := 'c:\Documents';
{$Endif}
 if DirectoryExists(Result) then Exit;
 Try
    ForceDirectories(Result);
 Except
 End;
 if DirectoryExists(Result) then Exit;
{$IFDEF Linux}
  Result:='/home/roger/innovasolutions';
  ForceDirectories(Result);
{$Endif}
 if not AStopException then
    Raise Exception.Create('You need to add directory </var/innovasolutions> with write privilages');
end;

class function TPath.GetDocumentsPath: UnicodeString;
begin
  Result := Combine(LazVarDirectory(true),'Documents');
end;

class function TPath.GetDirectoryName(AFileName: String): UnicodeString;
begin
  Result := ExtractFileDir(AFileName);
end;

class function TPath.PathSeparator: Char;
begin
{$IFDEF Linux}
  Result := '/';
{$ELSE}
  Result := '\';
{$ENDIF}
end;

class function TPath.GetFullPath(const APath: UnicodeString): String;
Var
  s: String;
begin
  //IsLogging.LogALine('TPath.GetFullPath >>' + APath);

  s := ExpandFileName(APath);
  //IsLogging.LogALine('TPath.GetFullPath <<>' + s);

  UniqueString(s);
  Result := s;

  //IsLogging.LogALine('TPath.GetFullPath <<' + Result);
end;

end.
