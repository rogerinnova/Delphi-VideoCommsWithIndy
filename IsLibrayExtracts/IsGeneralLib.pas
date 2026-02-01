{$I InnovaLibDefs.inc}
{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ ************************************************ }
{ General Library Functions }
{ Delphi
  {   Copyright (c) 1998
  {   Innova Solutions/R Connell }
{ ************************************************ }
{ Copyright Roger Connell 2001- }
{ Controls - mrOk mrCancel mrAbort mrRetry mrIgnore mrYes mrNo	 mrAll are in Controls }
unit IsGeneralLib;

interface

uses
{$IFDEF FPC}
 Classes, UITypes,SyncObjs,SysUtils,//IOUtils,
{$ELSE}
{$IFDEF ISXE2_DELPHI}
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ELSE}
  IsWindowsPickUp,
{$ENDIF}
  System.UITypes, System.SysUtils, System.Classes,
{$ELSE}
  Windows, SysUtils, Classes,
{$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
{$ENDIF}
  IsBase64AndEncryption;

function StartOfMonth(ADate: TDateTime): TDateTime;
{ Get Start of Current Month }

function EndOfMonth(CurDate: TDateTime): TDateTime;
{ Get End of Last Day of Current Month }
function LastDayInMonthAsInt(CurDate: TDateTime): Integer;
{ Get  No of Days in Month }
function CurUTCDateTime: TDateTime;
function UtcOffsetMinutes: Integer;

function IniFileNameFromExe:Ansistring;
{ProgramExeName.ini}

function ShortenFileName(const AFullFilName: AnsiString; AMaxLength: Integer)
  : AnsiString;
{ Derive a shorten Version when a filename goes beyond maxlength }
function BackUpFileName(const CurrentFName: AnsiString): AnsiString;
{ Derive a Filename for backup of a file to be replaced in a constistent form }
function RecoverFileNameFromBackUp(const CurrentFName: AnsiString): AnsiString;
function FileSizeInBytes(AFilename: AnsiString): Int64;
{$IFDEF MSWINDOWS}
function EncodePre1980FileDates(ADate: TDateTime): TDateTime;
function RecoverPre1980FileDates(ADate: TDateTime): TDateTime;
// Encodes dates pre DOS 1980 into a consistent post 1980 format for file dates
function ChangeFileDateEncoded(const AFilename: AnsiString; ATime: TDateTime;
  ACreateAcceesWrite: Byte): Boolean;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3 All 4: LastAccessLast Write }

function ChangeDirDate(const ADirName: AnsiString; ATime: TDateTime): Boolean;
// Uses NT date format and can set dates prior to the DOS limit of 1980
function FileOrDirectoryExistsExtended(const ADirFileName: AnsiString): Boolean;
// FileExists and directory exists requires Dos Date time ie files after 1980
function FileDateExtended(const AFilename: AnsiString;
  ACreateAcceesWrite: Byte = 0): TDateTime;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3: Earliest Date - 4: Laste Date }
function DirectoryDate(const ADirName: AnsiString; ACreateAcceesWrite: Byte = 0)
  : TDateTime;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3: Earliest Date - 4: Laste Date }
function RenameDirectory(const ACurDir, ANewName: AnsiString): Boolean;
{$ENDIF}
function DirectoryHasFilesOfType(ADirectoryName, AFileTypeFilter { *.txt|*.htm }
  : String; ADoSubDirectories: Boolean): Boolean;

{ To ISBase64AndEncryption
  function Base64Encode(AInStr: AnsiString): AnsiString;
  function BinaryToBase64Encode(Buffer: Pointer; SizeOfBuffer: Integer): AnsiString;
  function Base64ToBinaryDecode(OutBuffer: Pointer; SizeOfBuffer: Integer; EncodedBase64: AnsiString): integer;
}

function BuildCheckSumAuthorizedStrg(Base: Double): AnsiString;
function CheckAuthorizedStrg(Const StrToCheck: AnsiString): Boolean;
function UnPackAuthorString(AuthStr: AnsiString): AnsiString;
function RecoverDbleFromAuthorizedStrg(StrToCheck: AnsiString): Double;
function IsAValidObject(Obj: Pointer): Boolean;
// Not Reliable fails one in ten use IsPersistentObjectStillValid for BOs
function CompareIntegerRange(TestPositiveIfGreater, TestNegativeIfGreater,
  Range: Integer): Integer;
// Returns -1,0,1 if test values differ by more than range
function CompareRealValue(TestPositiveIfGreater, TestNegativeIfGreater
  : Double): Integer;
Function  FindObjectInTStrings(AList:TStrings;AObject:TObject):Integer;

Procedure IncObjectList(Alist: TStrings; AIdx: Integer);
Procedure SortLargeStringsByCompare(Alist: TStrings; Compare:TStringListSortCompare);
Procedure SortStringsByObjNo(Alist: TStrings);
Procedure SortStringsByLength(Alist: TStrings; AShortestFirst: Boolean = false);
procedure WrapStringList(AThisList: TStrings; AWrapTo: Integer);

const
  MaxReal48 = 200000000000000000000000000000000000.0;
  VeryBigReal = MaxReal48 / 10000;
  VerySmallReal = 0.0000000000000001;

implementation


uses Math, isStrUtl, DateUtils,
{$IfNDef FPC}
  ISProcCl,
{$ENDIF}
  IsArrayLib;
const
  BckPreStg = 'bu~~';
{$IfDef Win32}
  LocalINVALID_HANDLE_VALUE: DWord = INVALID_HANDLE_VALUE;
{$Endif}
{$IfDef Win64}
  LocalINVALID_HANDLE_VALUE: LongInt = -1;
{$ENDIF}

function ShortenFileName(const AFullFilName: AnsiString; AMaxLength: Integer)
  : AnsiString;
{ Derive a shorten Version when a filename goes beyond maxlength }
var
  FulLength: Integer;
begin
  Result := AFullFilName;
  if AMaxLength < 12 then
    exit;
  FulLength := Length(AFullFilName);

  if FulLength > AMaxLength then
    Result := Copy(AFullFilName, 1, 5) + '>...>' +
      Copy(AFullFilName, FulLength - AMaxLength + 11, FulLength);
end;

function BackUpFileName(const CurrentFName: AnsiString): AnsiString;
{ Derive a Filename for backup of a file to be replaced in a constistent form }
// oldname.old >> bu~~oldname.old
var
  FName, FPath: AnsiString;
begin
  FName := ExtractFileName(CurrentFName);
  FPath := ExtractFilePath(ExpandFileName(CurrentFName));
  Result := FPath + BckPreStg + FName;
end;

function IniFileNameFromExe:Ansistring;
{ProgramExeName.ini}
Var
  ExeName:String;
Begin
  {$IfDEF ISD10S_DELPHI}
  ExeName:=ExeFileNameAllPlatforms;
  {$Else}
  ExeName:=ParamStr(0);
  {$Endif}
  Result:=ChangeFileExt(ExeName,'.ini');
End;

function StartOfMonth(ADate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(ADate, Year, Month, Day);
  Result := EncodeDateTime(Year, Month, 1, 0, 0, 0, 0);
end;

function EndOfMonth(CurDate: TDateTime): TDateTime;
{ Get End of Last Day of Current Month }
var
  HDay, HMonth, HYear: Word;
begin
  DecodeDate(CurDate, HYear, HMonth, HDay);
  case HMonth of
    9, 4, 6, 11:
      HDay := 30;
    2:
      if IsLeapYear(HYear) then
        HDay := 29
      else
        HDay := 28;
  else
    HDay := 31;
  end; // case;
  Result := EncodeDateTime(HYear, HMonth, HDay, 23, 59, 59, 999);
end;

function LastDayInMonthAsInt(CurDate: TDateTime): Integer;
{ Get  No of Days in Month }
var
  HDay, HMonth, HYear: Word;
begin
  Result := 31;
  DecodeDate(CurDate, HYear, HMonth, HDay);
  case HMonth of
    9, 4, 6, 11:
      Result := 30;
    2:
      if IsLeapYear(HYear) then
        Result := 29
      else
        Result := 28;
  end; // case;
end;

var
  UTCOffset: Integer = MaxInt; { Minutes }
{$IFDEF NextGen}
  TextTimeZone: AnsiString;
{$ELSE}
  TextTimeZone: AnsiString = '';
{$ENDIF}

procedure GenTimeZone;
{$IFDEF MSWINDOWS}
var
  TZ: TIME_ZONE_INFORMATION;
  { typedef struct _TIME_ZONE_INFORMATION  // tzi
    LONG       Bias;
    WCHAR      StandardName[ 32 ];
    SYSTEMTIME StandardDate;
    LONG       StandardBias;
    WCHAR      DaylightName[ 32 ];
    SYSTEMTIME DaylightDate;
    LONG       DaylightBias;
    TIME_ZONE_INFORMATION; }

begin
  UTCOffset := 0;
  case GetTimeZoneInformation(TZ) of
    TIME_ZONE_ID_UNKNOWN:
      TextTimeZone := 'Time Zone Not established';
    TIME_ZONE_ID_STANDARD:
      TextTimeZone := AnsiString(PWChar(@TZ.StandardName));
    TIME_ZONE_ID_DAYLIGHT:
      begin
        TextTimeZone := AnsiString(PWChar(@TZ.DaylightName));
        UTCOffset := 60;
      end;
  else
    raise Exception.Create('Time Zone Not Set');
  end;
  UTCOffset := UTCOffset - TZ.Bias;
{$ELSE}
Begin
  UTCOffset := 0;
  TextTimeZone := 'Time Zone Not established yet on OSX';
{$ENDIF}
end;

function UtcOffsetMinutes: Integer;
begin
  if (UTCOffset = MaxInt) or (Frac(Now) < 0.1) then
    GenTimeZone;
  // Update on startup and at midnight Local
  Result := UTCOffset;
end;

function CurUTCDateTime: TDateTime;
var
  Dt: TDateTime;
begin
  Dt := Now;
  Result := Dt - UtcOffsetMinutes / 60 / 24;
end;

Procedure IncObjectList(Alist: TStrings; AIdx: Integer);
Var
  ObjectAsInterger: TObject;
  IntegerForObj: Integer;
begin
  if Alist = nil then
    exit;

  ObjectAsInterger := Alist.Objects[AIdx];
  IntegerForObj := Integer(ObjectAsInterger);
  Inc(IntegerForObj);
  Alist.Objects[AIdx] := TObject(IntegerForObj);
end;

function CompareByObjNo(List: TStringList; Index1, Index2: Integer): Integer;
{  Index1 and Index2 are indexes into the list. When these are passed to the TListSortCompare function, the CustomSort method is asking which order they should be in. 
You return 0 if the entry referred to by Index1 equals the entry referred to by Index2 
You return less than 0 if the entry referred to by Index1 is less than the entry referred to by Index2 
You return a number above 0 if the entry referred to by Index1 is greater than the entry referred to by Index2 
}
  Var 
    Obj1,Obj2:TObject;
//    Int1,Int2:Int64;
  Begin
    Obj1:=List.Objects[index1];
    Obj2:=List.Objects[index2];
    Result:=Int64(Obj2)-Int64(Obj1);
    if (result=0) and (list[index1]<>list[index2])then 
      if (list[index1]>list[index2]) then
        Result:=-1
        Else
        Result:=1;
  end;

Function  FindObjectInTStrings(AList:TStrings;AObject:TObject):Integer;
Var
  i,ListCnt: Integer;
//  Val: TObject;
begin
  Result:=-1;
  if AObject=nil then Exit;

  i:=0;
  ListCnt:=AList.Count;
  while (Result<0) and (i<ListCnt) do
    Begin
      if AObject=AList.Objects[i] then
        Result:=i;
      inc(i);
    End;
end;


Procedure SortStringsByObjNo(Alist: TStrings);
Var
  Done: Boolean;
  i: Integer;
  S: String;
  Val: TObject;
begin
  if Alist.Count > 500 then
    SortLargeStringsByCompare(Alist,CompareByObjNo)
  Else
    Try
      if Alist is TStringList then
        TStringList(Alist).Sorted := false;
      Done := false;
      while not Done do
      begin
        Done := true;
        for i := 1 to Alist.Count - 1 do
          if Integer(Alist.Objects[i - 1]) < Integer(Alist.Objects[i]) then
          begin
            S := Alist[i];
            Val := Alist.Objects[i];
            Alist.Delete(i);
            Alist.InsertObject(i - 1, S, Val);
            Done := false;
          end;
      end;
    Except
      On E: Exception do
        raise Exception.Create('SortStringsByObjNo::' + E.message);
    End;
end;

Procedure SortLargeStringsByCompare(Alist: TStrings; Compare:TStringListSortCompare);

Var
  NewList: TStringList;
Begin
  if Alist is TStringList then
    TStringList(Alist).Sorted := false;

  NewList := TStringList.Create;
  try
    NewList.AddStrings(Alist);
    NewList.CustomSort(Compare);
    Alist.Clear;
    Alist.AddStrings(NewList);
  Finally
    NewList.Free;
  end;
End;

  function CompareByLenthShortFirst(List: TStringList; Index1, Index2: Integer): Integer;
{  Index1 and Index2 are indexes into the list. When these are passed to the TListSortCompare function, the CustomSort method is asking which order they should be in. 
You return 0 if the entry referred to by Index1 equals the entry referred to by Index2 
You return less than 0 if the entry referred to by Index1 is less than the entry referred to by Index2 
You return a number above 0 if the entry referred to by Index1 is greater than the entry referred to by Index2 
}
  Var 
    Int1,Int2:Integer;
  Begin
    Begin
    Int1:=Length(List[index1]);
    Int2:=Length(List[index2]);
    Result:=Int1-Int2;
    if (result=0) and (list[index1]<>list[index2])then 
      if (list[index1]<list[index2]) then
        Result:=-1
        Else
        Result:=1;
    End;
  end;

  function CompareByLenthLongFirst(List: TStringList; Index1, Index2: Integer): Integer;

  Begin
    Result:=- CompareByLenthShortFirst(List,Index1,Index2);
  End;

  

Procedure SortStringsByLength(Alist: TStrings; AShortestFirst: Boolean = false);
Var
  Done: Boolean;
  i: Integer;
  S: String;
  Val: TObject;
begin
  if Alist.Count > 500 then
   Begin
    if AShortestFirst then
    SortLargeStringsByCompare(Alist,CompareByLenthShortFirst)
    Else
    SortLargeStringsByCompare(Alist,CompareByLenthLongFirst);
    
   End
  Else
  Begin
  if Alist is TStringList then
    TStringList(Alist).Sorted := false;
  Done := false;
  while not Done do
  begin
    Done := true;
    for i := 1 to Alist.Count - 1 do
      if (not AShortestFirst and (Length(Alist[i - 1]) < Length(Alist[i]))) or
        (AShortestFirst and (Length(Alist[i - 1]) > Length(Alist[i]))) then
      begin
        S := Alist[i];
        Val := Alist.Objects[i];
        Alist.Delete(i);
        Alist.InsertObject(i - 1, S, Val);
        Done := false;
      end;
  end;
  End;
end;

procedure WrapStringList(AThisList: TStrings; AWrapTo: Integer);
var
  i, OldSz, LineSz: Integer;
  Resize: Boolean;
  TmpList: TStringList;
  Strg: AnsiString;
begin
  if AWrapTo < 2 then
    raise Exception.Create('AWrap too small');

  OldSz := AThisList.Count;
  i := 0;
  Resize := false;
  while not Resize and (i < OldSz) do
  begin
    Resize := Length(AThisList[i]) > AWrapTo;
    Inc(i);
  end;
  if not Resize then
    exit;

  TmpList := TStringList.Create;
  try
    TmpList.AddStrings(AThisList);
    AThisList.Clear;
    i := 0;
    while i < OldSz do
    begin
      Strg := TmpList[i];
      LineSz := Length(Strg);
      while LineSz > AWrapTo do
      begin
        AThisList.AddObject(Copy(Strg, 1, AWrapTo), TmpList.Objects[i]);
        TmpList.Objects[i] := nil;
        Strg := Copy(Strg, AWrapTo + 1, LineSz);
        LineSz := Length(Strg);
      end;
      AThisList.AddObject(Strg, TmpList.Objects[i]);
      Inc(i);
    end;
  finally
    TmpList.Free;
  end;
end;

function RecoverFileNameFromBackUp(const CurrentFName: AnsiString): AnsiString;
var
  i: Integer;
begin
  i := PosNoCase(BckPreStg, CurrentFName);
  if i < 1 then
    raise Exception.Create(CurrentFName + ' is not a  backup File');
  Result := Copy(CurrentFName, 1, i - 1) + Copy(CurrentFName,
    i + Length(BckPreStg), Length(CurrentFName));
end;

function FileSizeInBytes(AFilename: AnsiString): Int64;
var
  ThisFile: TFileStream;
begin
  try
    ThisFile := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyNone);
    try
      Result := ThisFile.Size;
    finally
      ThisFile.Free;
    end;
  except
    Result := -1;
  end;
end;

{$IFDEF MSWINDOWS}

const
  C1980 = 29221; // C1980:=EncodeDate(1980,1,1);

function ChangeFileDateEncoded(const AFilename: AnsiString; ATime: TDateTime;
  ACreateAcceesWrite: Byte): Boolean;
{ 0:Creation - 1:LastAccess - 2:Last Write - 3 All 4: LastAccessLast Write }
begin
  Result := ChangeFileDate(AFilename, EncodePre1980FileDates(ATime),
    ACreateAcceesWrite);
end;

function EncodePre1980FileDates(ADate: TDateTime): TDateTime;
var
  Days: Integer;
begin
  if ADate >= C1980 + 30 then
    Result := ADate
  else
  begin
    Days := Trunc(C1980 + 30 - ADate);
    Result := C1980 + 30 - Days / 365 / 10;
  end;
end;

function RecoverPre1980FileDates(ADate: TDateTime): TDateTime;
var
  Days: Integer;
begin
  if ADate >= C1980 + 30 then
    Result := ADate
  else
  begin
    Days := Trunc((ADate - C1980 - 30) * 365 * 10);
    Result := C1980 + 30 + Days;
  end;
end;

function RenameDirectory(const ACurDir, ANewName: AnsiString): Boolean;
var
  CurDirectory, NewDirectory: AnsiString;
begin
  try
    CurDirectory := ExpandFileName(ACurDir);
    NewDirectory := ExpandFileName(ANewName);
    if not DirectoryExists(CurDirectory) then
      raise Exception.Create('Directory ' + CurDirectory + ' does not exist');
    if DirectoryExists(NewDirectory) then
      raise Exception.Create('Directory ' + NewDirectory + ' Already exists');
    if ExtractFileDrive(CurDirectory) <> ExtractFileDrive(NewDirectory) then
      raise Exception.Create('Cannot Rename a Directory across devices');

    Result := MoveFileA(PAnsiChar(CurDirectory), PAnsiChar(NewDirectory));
  except
    on E: Exception do
      raise Exception.Create('RenameDirectory::' + E.message);
  end;
end;
{$ENDIF}

function DirectoryHasFilesOfType(ADirectoryName, AFileTypeFilter { *.txt|*.htm }
  : String; ADoSubDirectories: Boolean): Boolean;

var
  FileRec: TSearchRec;
{$IFDEF UNICODE}
  FilterArray: TArrayOfUnicodeStrings;
{$ELSE}
  FilterArray: TArrayOfAnsiStrings;
{$ENDIF}
  i, FileRslt: Integer;

begin
  Result := false;
  if not DirectoryExists(ADirectoryName) then
    exit;
  if AFileTypeFilter = '' then
    exit;

  FilterArray := GetArrayStrSepString(AFileTypeFilter, '|', true, true);
  i := 0;
  while not Result and (i <= high(FilterArray)) do
  begin
    FileRslt := FindFirst(ConcatToFullFileName(ADirectoryName, FilterArray[i]),
      0, FileRec);
    try
      if (FileRslt = 0) then
        Result := true;
    finally
      FindClose(FileRec);
    end;
    Inc(i);
  end;
  if not Result and ADoSubDirectories then
  begin
    FileRslt := FindFirst(ConcatToFullFileName(ADirectoryName, '\*.'),
      faDirectory, FileRec);
    try
      while not Result and (FileRslt < 1) do
      begin
        if (FileRec.Name <> '.') and (FileRec.Name <> '..') then
          Result := DirectoryHasFilesOfType(ConcatToFullFileName(ADirectoryName,
            '\' + FileRec.Name), AFileTypeFilter, ADoSubDirectories);
        FileRslt := FindNext(FileRec);
      end;
    finally
      FindClose(FileRec);
    end;
  end;
end;

{$IFDEF MSWINDOWS}

function FileOrDirectoryExistsExtended(const ADirFileName: AnsiString): Boolean;
var
  FileH: DWord;
begin
  Result := false;
  try
    FileH := CreateFileA(PAnsiChar(ADirFileName), GENERIC_READ, FILE_SHARE_READ,
      nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
    try
      Result := FileH <> LocalINVALID_HANDLE_VALUE;
    finally
      if Result then
        FileClose(FileH);
    end;
  except
    on E: Exception do
      raise Exception.Create('FileOrDirectoryExistsExtended::' + E.message)
  end;
end;

function DirectoryDate(const ADirName: AnsiString; ACreateAcceesWrite: Byte = 0)
  : TDateTime;
begin
  Result := DirectoryOrFileDate(ADirName, ACreateAcceesWrite);
end;

function FileDateExtended(const AFilename: AnsiString;
  ACreateAcceesWrite: Byte = 0): TDateTime;
begin
  Result := DirectoryOrFileDate(AFilename, ACreateAcceesWrite);
end;

function ChangeDirDate(const ADirName: AnsiString; ATime: TDateTime): Boolean;

var
  FileH, ErrorCode: Integer;
  LocalFileTime, FileTime: TFileTime;
  S: AnsiString;
begin
  try
    FileH := CreateFileA(PAnsiChar(ADirName), GENERIC_WRITE, // GENERIC_READ,
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
            if SetFileTime(FileH, @FileTime, @FileTime, @FileTime) then
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
      end;
    Result := Abs(ATime - DirectoryDate(ADirName)) < 0.1;
  except
    on E: Exception do
      raise Exception.Create('ChangeDirDate::' + E.message)
  end;
end;
{$ENDIF}

type
  RAuthorizeRec = packed record // 9 Bytes
    case Integer of
      0:
        (Buffer: array [0 .. 8] of Byte);
      1:
        (Base: Double; cs: Byte);
      2:
        (IntVal: Int64;
          CheckSum: Byte);
  end;

const
  CheckPrime = 251;

function BuildCheckSumAuthorizedStrg(Base: Double): AnsiString;
var
  Cd: RAuthorizeRec;
  IntrimString: AnsiString;
Const
{$IFDEF NEXTGEN}
  Offset = -1;
{$ELSE}
  Offset = 0;
{$ENDIF}
begin
  Cd.Base := Base;
  Cd.CheckSum := Cd.IntVal mod CheckPrime;
  // Prime Nos  2 3 5 7 11 13 17 19 23 29
  // 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109 113 127
  // 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223
  // 227 229 233 239 241 251 257 263 269 271 277 281 283 293 307 311 313
  // 317 331 337 347
  IntrimString := BinaryToBase64Encode(@Cd, SizeOf(Cd));
  IntrimString := StringReplace(IntrimString, '+', 's', [rfReplaceAll]);
  IntrimString := StringReplace(IntrimString, '/', 'p', [rfReplaceAll]);
  Result := IntrimString[1 + Offset] + IntrimString[2 + Offset] + IntrimString
    [3 + Offset] + ' ' + IntrimString[4 + Offset] + IntrimString[5 + Offset] +
    IntrimString[6 + Offset] + ' ' + IntrimString[7 + Offset] + IntrimString
    [8 + Offset] + IntrimString[9 + Offset] + ' ' + IntrimString[10 + Offset] +
    IntrimString[11 + Offset] + IntrimString[12 + Offset];
end;

function PackAuthorString(AuthStr: AnsiString): AnsiString;
Var
  Len: Integer;
Const
{$IFDEF NEXTGEN}
  Offset = -1;
{$ELSE}
  Offset = 0;
{$ENDIF}
begin
{$IFDEF NEXTGEN}
  Len := AuthStr.Length;
{$ELSE}
  Len := Length(AuthStr);
{$ENDIF}
  if Len <> 15 then
    Result := AuthStr
  else
    Result := AuthStr[1 + Offset] + AuthStr[2 + Offset] + AuthStr[3 + Offset] +
      AuthStr[5 + Offset] + AuthStr[6 + Offset] + AuthStr[7 + Offset] +
      AuthStr[9 + Offset] + AuthStr[10 + Offset] + AuthStr[11 + Offset] +
      AuthStr[13 + Offset] + AuthStr[14 + Offset] + AuthStr[15 + Offset];
end;

function UnPackAuthorString(AuthStr: AnsiString): AnsiString;
Const
{$IFDEF NEXTGEN}
  Offset = -1;
{$ELSE}
  Offset = 0;
{$ENDIF}
var
  S: AnsiString;
begin
  S := PackAuthorString(AuthStr);
  Result := S[1 + Offset] + S[2 + Offset] + S[3 + Offset] + ' ' + S[4 + Offset]
    + S[5 + Offset] + S[6 + Offset] + ' ' + S[7 + Offset] + S[8 + Offset] +
    S[9 + Offset] + ' ' + S[10 + Offset] + S[11 + Offset] + S[12 + Offset];
end;

function CheckAuthorizedStrgSimple(Const StrToCheck: AnsiString): Boolean;
var
  Cd: RAuthorizeRec;
begin
  Result := false;
  if StrToCheck = '' then
    exit;
  try
    Base64ToBinaryDecode(@Cd, SizeOf(Cd), StrToCheck);
    Result := Cd.CheckSum = (Cd.IntVal mod CheckPrime);
  except
    Result := false;
  end;
end;

function DecodeCorrectString(Const StrToCheck: AnsiString): AnsiString;
var
  PossibleSubs: array [0 .. 12] of Integer;
  i, j, Len: Integer;
  LocalString: AnsiString;
begin
  If CheckAuthorizedStrgSimple(StrToCheck) Then
    Result := StrToCheck
  Else
  Begin
    Result := '';
    j := 0;
{$IFDEF NexrGen}
    Len := StrToCheck.Length;
    for i := 0 to Len do
{$ELSE}
    Len := (Length(StrToCheck));
    for i := 1 to Len do
{$ENDIF}
      if Char(StrToCheck[i]) in ['s', 'p'] then
      begin
        PossibleSubs[j] := i;
        Inc(j);
      end;

    i := 0;
    while (Result = '') and (i < j) do
    begin
      LocalString := StrToCheck;
{$IFDEF NextGen}
      LocalString.Length := Len; // make a unique copy
{$ELSE}
      SetLength(LocalString, Len); // make a unique copy
{$ENDIF}
      case Char(StrToCheck[PossibleSubs[i]]) of
        's':
          LocalString[PossibleSubs[i]] := '+';
        'p':
          LocalString[PossibleSubs[i]] := '/';
      else
        raise Exception.Create('Error in CheckAuthorizedStrg');
      end; // case
      Inc(i);
      If CheckAuthorizedStrgSimple(LocalString) Then
        Result := LocalString
      else
        Result := DecodeCorrectString(LocalString);
      // Iterate to other possible changes
    end;
  end;
end;

function CheckAuthorizedStrg(Const StrToCheck: AnsiString): Boolean;
var
  S: AnsiString;
begin
  try
    S := PackAuthorString(StrToCheck);
    Result := CheckAuthorizedStrgSimple(S);
    if not Result then // Check for s,p subsistution
      Result := DecodeCorrectString(S) <> '';
  except
    Result := false;
  end;
end;

function RecoverDbleFromAuthorizedStrg(StrToCheck: AnsiString): Double;
var
  Cd: RAuthorizeRec;
  S: AnsiString;
begin
  S := DecodeCorrectString(PackAuthorString(StrToCheck));
  if S = '' then
    raise Exception.Create('RecoverDbleFromAuthorizedStrg::Invalid String');

  Base64ToBinaryDecode(@Cd, SizeOf(Cd), S);
  Result := Cd.Base;
end;

function CompareIntegerRange(TestPositiveIfGreater, TestNegativeIfGreater,
  Range: Integer): Integer;
// Returns -1,0,1 if test values differ by more than range

begin
  Result := 0;
  if TestPositiveIfGreater > (TestNegativeIfGreater + Range) then
    Result := 1;
  if TestNegativeIfGreater > (TestPositiveIfGreater + Range) then
    Result := -1;
end;

function CompareRealValue(TestPositiveIfGreater, TestNegativeIfGreater
  : Double): Integer;
begin
  Result := CompareValue(TestPositiveIfGreater, TestNegativeIfGreater,
    Abs(TestPositiveIfGreater / 1000000));
end;

function IsAValidObject(Obj: Pointer): Boolean;
begin
  try
    Result := true;
    TObject(Obj).FieldAddress('NoName');
    TObject(Obj).MethodAddress('NoName');
  except
    Result := false;
  end;
end;

end.
