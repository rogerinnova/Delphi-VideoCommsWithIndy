{$I InnovaLibDefs.inc}
{$IFDEF FPC}
{$MODE Delphi}
// {$ModeSwitch UnicodeStrings}
{$DEFINE ISD102T_DELPHI}
// {$Define Unicode}
{$ENDIF}
unit ISStrUtl;
{ ************************************************ }
{ Strings Utilities
  {   Delphi
  {   Copyright (c) 1999 - 2012
  {   Innova Solutions/R Connell
  {************************************************ }

interface

{$WARNINGS off}

uses
{$IFDEF FPC}
  Classes, UITypes, SyncObjs, SysUtils, // IOUtils,

{$ELSE}
{$IFDEF ISXE2_DELPHI}
  System.Classes, System.UITypes,
{$IFNDEF NextGen}
{$IFNDEF ISD102T_DELPHI}
  System.AnsiStrings,
{$ENDIF}
{$ENDIF}
  System.SyncObjs,
  System.IOUtils,
{$IFDEF MSWINDOWS}
  System.Win.ComObj, System.Win.Registry,
  Winapi.Windows, Winapi.ShlObj, Winapi.ShellAPI,
{$ELSE}
  IsWindowsPickUp,
{$ENDIF}
  System.SysUtils,
{$ELSE}
  Windows, Classes, SysUtils,
{$ENDIF}
{$IFDEF ISXE3_DELPHI}
  XE3LibPickup,
{$ENDIF}
{$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ELSE}
  IsGeneralLib,
{$ENDIF}
  ISUnicodeStrUtl, IsArrayLib, ISDelphi2009Adjust;

{$IFDEF NextGen}

Type
  UniCodeCharSet = set of Char;

const
  CR = #13;
  LF = #10;
  TAB = #9;
  // var
  CRP = #141; // (13 + 128);
  LFP = #138; // (10 + 128);
  FirstStrCharNo = 0;
{$ELSE}

Type

  AnsiCharSet = set of Ansichar;
{$IFDEF FPC}
  UniCodeCharSet = AnsiCharSet;
{$ELSE}
  UniCodeCharSet = set of Char;
{$ENDIF}

const
  CR = Ansichar(#13);
  LF = Ansichar(#10);
  TAB = Ansichar(#9);
  // var
  CRP = Ansichar(#141); // (13 + 128);
  LFP = Ansichar(#138); // (10 + 128);
  FirstStrCharNo = 1;
{$ENDIF}

Function IsEmptyString(Var AString:String):Boolean; Overload;
function BlankLine(aStrg: AnsiString): Boolean;
{ only spaces }
{$IFNDEF FPC}
Function PCharNotNull(Var AChar: PAnsiChar): Boolean; Overload;
Function IsEmptyString(Var AString:AnsiString):Boolean; Overload;
{$ENDIF}
{$IFDEF ISXE8_DELPHI}
function BackScanFromHere(Var cs: PAnsiChar; AInSet: AnsiCharSet;
  AMax: Integer = 100): PAnsiChar; overload;
{ Reverse scan from cs to first occurance of a member of the set }
function ExtractNextBracket(var APchr: PAnsiChar;
  AAllowMismatch: Boolean = False): AnsiString;
{ Extracts fgfgg from some junk(fgfgg) more junk
  and returns pointer to  more junk
  Extracts fgfgg from some junk(fgfgg
  and returns nil
}
Function RemoveBracketedText(ADataTxt: AnsiString;
  AAllowMismatch: Boolean = False): AnsiString;
{ Remove text in Brackets ffgf {hhhhh) nnnn becomes ffgf nnnn }
{ On Exception Use RemoveMismatchedBracket }
Function RemoveMismatchedBracket(ADataTxt: AnsiString;
{$IFDEF NextGen}
  AReplaceWith: Ansichar): AnsiString;
{$ELSE}
  AReplaceWith: Ansichar = ',')
: AnsiString;
{$ENDIF}
{ Drops a outside Bracket that is not terminated Brackets
  ffgf {hhhhh (nnnn) becomes ffgf hhhh (nnnn)
  But
  ffgf (hhhhh (nnnn) becomes ffgf (hhhh (nnnn)
  On Exception handler for RemoveMismatchedBracket }
{$ENDIF}
function FieldSep(var ss: PAnsiChar; SepVal: Ansichar): AnsiString; overload;
{ Returns AnsiString and pointer to next field (Var ss) in AnsiString }
function SepStrg(var aStrg: PAnsiChar; ASep: AnsiString): AnsiString; overload;
{ Returns ansistring and pointer to next field (Var AStrg) in AnsiString }
function SepStrg(var aStrg: AnsiString; const ASep: AnsiString)
  : AnsiString; overload;
{ Returns ansistring and an ansiString of rest of AnsiString Slower than the above but
  handles strings containing nulls }
procedure GetFields(var Fields: TArrayOfAnsiStrings; const S: AnsiString;
  SepVal: Ansichar; ARemoveQuote: Boolean = False;
  ATrim: Boolean = True); overload;
{ Returns AnsiString Array of all separeted strings }

{$IFDEF UNICODE}
function BackScanFromHere(Var cs: PWideChar; AInSet: UniCodeCharSet;
  AMax: Integer = 100): PWideChar; overload;
{ Reverse scan from cs to first occurance of a member of the set }

Function PCharNotNull(Var AChar: PChar): Boolean; Overload;
// Checks not (AChar='' or AChar=nil) will set Achar=nil if was ''
function FieldSep(var ss: PWideChar; SepVal: WideChar): UnicodeString; overload;
{ Returns String and pointer to next field (Var ss) in AnsiString }
function SepStrg(var aStrg: PWideChar; ASep: UnicodeString)
  : UnicodeString; overload;
{ Returns unicodestring and pointer to next field (Var AStrg) in AnsiString }
procedure GetFields(var Fields: TArrayOfUnicodeStrings; const S: UnicodeString;
  SepVal: WideChar; ARemoveQuote: Boolean = False;
  ATrim: Boolean = True); overload;
{ Returns unicodeString Array of all separeted strings }
{$ENDIF}
function FirstField(const ANextChar: PAnsiChar; SepVal: Ansichar): AnsiString;
{ Wraps FieldSep for simplicicty to access first Field only }
function ReadValueFrmTStrings(AData, AHeaders: TStrings; AHdrRef: AnsiString)
  : AnsiString;
{ Retuns the value in Adata at the index of AhdrRef in AHeaders }
function ArrayOfFieldToText(Fields: TArrayOfAnsiStrings; SepVal: Ansichar;
  AddQuote: Integer): AnsiString;
{ Returns separeted strings from AnsiString Array  AddQuote> 0: no Quotes 1:" 2:' }
function LongWordSetAsString(AData: LongWord; ASepVal: AnsiString;
  AStringValues: array of AnsiString): AnsiString;
{ Returns separeted strings from AnsiString Array in Longword set }
function FileNameFriendly(const S: String; ReplaceWith: Char = '-'): String;
{ Returns Only Characters that are valid in a file name including path specifiers /&\ Relaced with }
Function ShortenFileName(Const AFileName: String;
  ATotalLength: Integer): String;
// Chop the middle from a long file name to fit within Total Length
// eg c:\bigdata\fifty\today\xxxx\bbbbb\text.txt
// to c:\bigdata\...\bbbbb\text.txt
function FileRelativePathBuild(ABasePath: string; ARelFileName: string): string;
{ takes relative path and a base base and generates new path }

Function ReplaceSeps(Const AText, NewValue: AnsiString;
  AChangeArray: array of AnsiString): AnsiString; Overload;
// Replaces all in AChangeArray with NewValue

function RemoveQuotes(const S: AnsiString): AnsiString; overload;
{ Removes Matched ' or " from ends of AnsiString }
function RemoveBlankLines(const S: AnsiString): AnsiString; overload;
{ Removes Blanklines from StringList.Text }

Function MaskNumbers(Var AText: AnsiString): Boolean;
// Changes Numerics Chars to a Code in DLE to Em
Function UnMaskNumbers(Var AText: AnsiString): Boolean;
// Recovers Numerics Chars From a Code in DLE to Em

function ExtractNumberChars(var APchr: PAnsiChar;
  AAceptDpAndSign: Boolean = False): AnsiString; overload;
{ Returns numeric text from start of an AnsiString }
function ExtractNumber(var APchr: PAnsiChar): Integer; overload;
{ Returns Integer from within an AnsiString }

{$IFDEF UNICODE}
function PosNoCase(Const ASubstr: UnicodeString; AFullString: UnicodeString)
  : Integer; overload;
{ Pos but ignors case }

function PosFrmHere(const ASubstr: String; AFullString: String;
  AStartAt: Integer; AIgnorCase: Boolean = False): Integer; overload;
{ Pos but Start at offset }

function StrEquNoCase(const s1, s2: UnicodeString): Boolean; overload;
{ Strings Equal except for case }
function RemoveQuotes(const S: UnicodeString): UnicodeString; overload;
{ Removes Matched ' or " from ends of String }
function RemoveBlankLines(const S: UnicodeString): UnicodeString; overload;
{ Removes Blanklines from StringList.Text }
function ExtractNumberChars(var APchr: PWideChar;
  AAceptDpAndSign: Boolean = False): AnsiString; overload;
{ Returns numeric text from start of an AnsiString }
function ExtractNumber(var APchr: PWideChar): Integer; overload;
{ Returns Integer from within an AnsiString }
function TakeOneLine(var InStr: PWideChar; AddTerms: UniCodeCharSet = [];
  ATrimOff: UniCodeCharSet = [CR, LF]): UnicodeString; overload;
{ With addterms= [] returns a String from Instr[0] to the first Cr, Lf or nul
  InStr is nul if end is encountered otherwise advance to first no termination AnsiChar
  Termination chars can be increased by adding to [addterms] }

function ISNumeric(a: WideChar; AAceptSign: Boolean = False): Boolean; overload;
{ True indicates Char is a numeric digit in the range '0'..'9
  accept sign includes .+- }
function ISNumeric(a: string; AAceptSign: Boolean = False): Boolean; overload;
{ True indicates String contains only numeric digits in the range '0'..'9
  accept sign includes .+- }

{ function TakeOneCleanLine(var InStr: PWideChar): UnicodeString; overload;
  {One line without <Html Fields> }
{ function HTMLExtractNextTagByType(var CurrentLoc: PWideChar; const LowerCaseTagIndicator:
  UnicodeString): UnicodeString; overload;
  function HTMLExtractNextEndTab(var CurrentLoc: PWideChar): UnicodeString; overload;
  {Exposed for XML }
{$ENDIF}
function ExtractInt(const ss: String): Integer;
{ Returns Integer from start of AnsiString, Hides non integer errors }
function ExtractReal(const ss: String): Real;
{ Returns Real from start of AnsiString, Hides non real errors }
function ExtractHexAsLongWord(const AStr: String): LongWord;
{ Returns Longword from Hex at start of AnsiString }
function ExtractHexByte(S: PChar): Byte;
{ Returns Byte from Hex at start of String AnsiString }
function ExtractTime(const S: String; ADefault: TDateTime): TDateTime;
{ Returns Time From hh:nn am }
function CompareSeparatedNumbers(const ANumberStrgItem1, ANumberStrgItem2
  : String): Integer;
{ Compares 2004.2.5 and 2004.12.1 and gives 12>2
  Compare returns < 0 if Item1 is less than Item2,
  0 if they are equal and
  > 0 if Item1 is greater than Item2. }
function ContainsReplace(var AString: String; const AFind, AReplace: String;
  AFlags: TReplaceFlags): Boolean;
{ Replace in AString Return True If Replaced }
function DataBlockToStringHex(BufferPointer: Pointer; Sz: Integer): AnsiString;
{ Converts Double/Real/Binary Data etc to Hex AnsiString) }
function StringHexToDataBlock(AStr: String; ResultPointer: Pointer;
  ResultSz: Integer): Integer;
{ Returns Double/Real/Binary Data etc From Hex AnsiString Returns Bytes decoded -1 means buffer overflow }
{ procedure encrypt(BufferSize: byte; BufferPointer: pointer; KeySize: byte; KeyPointer: pointer);
  {Xor a block of data }
{ To ISBase64AndEncryption }
function PhonicForChar(AC: Ansichar): AnsiString;
{ Returns Lima for L }
{$IFNDEF FPC}
function PosFirstNumeric(Const S: AnsiString): Integer; overload;
{$ELSE}
function ISNumeric(a: AnsiString; AAceptSign: Boolean = False)
  : Boolean; overload;
{$ENDIF}
function PosFirstNumeric(Const S: String): Integer; overload;
{ Returns Pos of First Numeric Char }

function ContainsNumeric(const AStg: AnsiString): Boolean;
// AnsiString contains at least one Numeric
function ISNumeric(a: Byte; AAceptSign: Boolean = False): Boolean; overload;
function ISNumeric(a: Ansichar; AAceptSign: Boolean = False): Boolean; overload;
{ True indicates AnsiChar is a numeric digit in the range '0'..'9
  accept sign includes .+- }
{$IFNDEF FPC}
function ISNumeric(a: AnsiString; AAceptSign: Boolean = False)
  : Boolean; overload;
{$ENDIF}
{ True indicates AnsiString is a numeric digit in the range '0'..'9
  accept sign includes .+- }
function FrontInteger(const S: String): Integer;
{ Returns Integer from front of AnsiString even if bad chars are later }
function IntOnly(const ss: String): Boolean;
{ returns true if AnsiString contains only numbers and arithmetic signs+or- }

{$IFDEF FPC}
Function CopyMemory(ADest, ASrc: PAnsiChar; Count: Integer): Integer;
{$ENDIF}
{$IFNDEF NextGen}
function CopyNullStrToPascal(InStr: PAnsiChar; Count: Integer): AnsiString;
{ use count=-1 to copy full AnsiString }
function AssignCopyofNullStr(InStr: PAnsiChar; Count: Integer): PAnsiChar;
{ Assign memory to an new null AnsiString copy ; use count=-1 to copy full AnsiString }
function StringFixedLength(Input: AnsiString; FixedLength: Integer): AnsiString;
{ Sets a AnsiString to a fixed length by padding with spaces or Truncation }
{$ENDIF}
function StreamAsString(AStrm: TStream): AnsiString;
function StreamAsStringLimitLen(AStrm: TStream;
  AMaxSz, ASoFromEndBegin: Integer): AnsiString;
procedure StringAsStrm(AData: AnsiString; AStm: TStream);

{$IFDEF UNICODE}
function U8A(Const AUCode: String): AnsiString; // untested
{ String to UTF8 as Ansi }
function A8U(Const AUCode: AnsiString): UTF8String;
{ String Ansi as UTF8 }
{$ENDIF}
Function AnsiCharPtr(
{$IFNDEF NEXTGEN}
  Var {$ENDIF}
  S: AnsiString): PAnsiChar;
Function AsAnsi(AWord: Word): AnsiString; overload;
Function AsAnsi(AWord: LongWord; ABytes: Integer = 4): AnsiString; overload;
Function AsAnsi(AInt: Integer; ABytes: Integer = 4): AnsiString; overload;
Function ValFromAnsi(AStr: PAnsiChar; ABytes: Integer): LongWord;

function ConcatToFullFileName(const Path, AFileNam: String): String;
{ Join file to path resolving '\' or'/' or ..\ or ../
  Tpath.combine does not handle  c:\dir1\, \dir2\file
  Only handles current platform }

function ExtractFileNameWeb(const FileName: String): String;
{ Accepts '\' or'/' or ..\ or ../ }

function ExpandYear(AYear: Integer; FutureWindow: Integer): Integer; Overload;
function ExpandYear(const S: String; FutureWindow: Integer): Integer; Overload;
{ Expands two digit date within sliding window Futurewindow-100 to Futurewindow
  Where Futurewindow can be -ve }

function SpaceFill(InString: String; FillLength: Integer): String;
{ tested }
{ Left justfies a AnsiString and pads with spaces to FillLength
}
function Compact(InString: String; Front, Tail: Boolean): String;
{ tested }
{ Compacts the front and or tail of a AnsiString removing spaces
  eg              '     yyyyyy    '
  with tail       '     yyyyyy'
  with head       'yyyyyy    '
  with head and tail 'yyyyyy'
}

function DollarAmountPadded(AValue: Real; ADecPiont: Integer = 0): String;
function DollarAmount(AValue: Real): String; overload;
function DollarAmount(AValue: Real; var APositive: Boolean): String; overload;
{ Returns $ 400.00 from 400.0000 }

function RealFromDollarAmount(const ADollarStrg: String;
  ATestFormat: String = ''): Real;
{ Returns 400.00 from "$400.00 }
function CentsFromDollarAmount(const ADollarStrg: String): LongInt;
{ Returns 40000 from "$400.00 }
function FormatCurrencyStringArray(ARealArray: TArrayOfReal)
  : TArrayOfAnsiStrings; overload;
{ Returns Formated Currency Strings $9.00 ($9.00) in an Array }
function FormatCurrencyStringArray(ARealArray: TTwoDArrayOfReal)
  : TTwoDArrayOfAnsiString; overload;
{ Returns Formated Currency Strings $9.00 ($9.00) in an Array }

function ReadLineFrmStream(AStream: TStream): AnsiString;
procedure WriteLineToStream(AStream: TStream; const AData: AnsiString);

function TakeOneLine(var InStr: PAnsiChar; AddTerms: AnsiCharSet = [];
{$IFDEF NEXTGEN}
  ATrimOff: AnsiCharSet = [13, 10]): AnsiString; overload;
{$ELSE}
  ATrimOff: AnsiCharSet = [CR, LF])
: AnsiString;
overload;
{$ENDIF}
{ With addterms= [] returns a AnsiString from Instr[0] to the first Cr, Lf or nul
  InStr is nul if end is encountered otherwise advance to first no termination AnsiChar
  Termination chars can be increased by adding to [addterms] }

{$IFNDEF NextGen}
function TakeOneCleanLine(var InStr: PAnsiChar): String; overload;
{ One line without <Html Fields> }

function FindAndInc(ss, AFndText: PAnsiChar; AdditionalPlaces: Integer = 0)
  : PAnsiChar;

function MakeOneLine(InChar: PAnsiChar): PAnsiChar;
{ Remove Cr and Lf from PAnsiChar AnsiString Leaves old untouched }
function AllocateAndAssignNullString(const ss: AnsiString): PAnsiChar;
{ Allocates Memory and Assigns ss to PAnsiChar }
function StrPosFromPStrg(SourceStg: PAnsiChar; const SubStrg: AnsiString)
  : PAnsiChar;
{ StrPos but SubStr is Type Pascal }
function PosNoCase(const ASubstr: AnsiString; AFullString: AnsiString)
  : Integer; overload;
{ Pos but ignors case }
{$IFNDEF FPC}
function PosFrmHere(const ASubstr: AnsiString; AFullString: AnsiString;
  AStartAt: Integer; AIgnorCase: Boolean = False): Integer; overload;
{ Pos but Start at offset }
{$ENDIF}
function StrEquNoCase(const s1, s2: AnsiString): Boolean; overload;
{ Strings Equal except for case }
{$ENDIF}
function MonthAsInt(const sm: String): Integer;
function InternetDateTime(const SourceStg: PChar): TDateTime;
{ Source strg    Wdy, DD-Mon-YYYY HH:MM:SS GMT }
{ Returns Delphi DateTime from Restricted RFC 882,RFP 850 RFC 1036 RFC 1123 }
{ Restrictions Time Zone =GMT, Separators must be - }
{$IFDEF MSWINDOWS}
function DateTimeToInternetDateTime(Time: TDateTime): String;
{ Result strg    Wdy, DD-Mon-YYYY HH:MM:SS GMT }
{ Returns AnsiString from Delphi DateTime }
{$ENDIF}
Function IsTxtToYear(ATxt: String): Integer;

Function ISDecodeDashYears(ADateTxt: String;
  Out AYearFrm, AYearTo: Integer): Boolean;

function ISStrToDateRecovery(const ADate: String; ALatestDate: TDateTime = 0.0;
  ADefault: TDateTime = 0.0): TDateTime;
// Still very basic date only
function StringToDateTimeRecovery(const S: String): TDateTime;
// Still very basic date only
function DateAsFinancialYear(ADate: TDateTime): String;
{ returns 2001/2002 }
function TimeToAgeString(AAge: TDateTime;
  ALimitAgeInYears: Integer = 0): String;
{ returms 12 Yrs 3 Mths }
function StarQuestionFilterLength(const Filter: AnsiString): Integer;
{ Returns length of last non filter AnsiChar * ? }

{$IFNDEF NextGen}
function StarQuestionMatch(const Filter, Value: AnsiString): Integer;
{ return -1 for Filter less than Value
  return 0 for Filter  Match Value
  return 1 for Filter greater than Value }
// * matches to end while ?Matches one AnsiChar

{$ENDIF}
function InsertCharAfterChars(const AStr: String;
  ATestChars: UniCodeCharSet = [',', '.', ':', ';']; AInsert: Char = ' ';
  AMakeSingle: Boolean = False): String;
{ Use to Make 'Word,Word  Word ,Word' into 'Word, Word Word, Word' }
function ExtractInitials(const ss: String): String;
{ Returns ABIS from 'Arnie,bill INNOVA solutions' }
function Capitalize(S: String): String;
{ Returns 'Arnie,Bill Innova Solutions' from 'Arnie,bill INNOVA solutions' }

function LwrCaseIS(AChar: WideChar): WideChar; overload;
function LwrCaseIS(const ATxt: UnicodeString): UnicodeString; overload;
{ Lowercase which applies to Greek etc also }
function UprCaseIS(AChar: WideChar): WideChar; overload;
function UprCaseIS(const ATxt: UnicodeString): UnicodeString; overload;
{ Uppercase Which applies to Greek etc also }

function Abbreviate(S: String): String;
{ Returns 'Inn Sol' from 'INNOVA solutions' }

function DbHonerific(S: String): String;
{ Returns MRS, MR, MS }
function FormalAddressHonerfic(S: String): String;

function HonerificIsMale(S: String): Boolean;

procedure ReConstructName(const AFullName: String; var FirstInitial: Char;
  var Honerific, GivenName, FamilyName: String); overload;
{ Returns Var G + MRS + GivenName + FamilyName }

{$IFNDEF FPC}
procedure ReConstructName(const AFullName: AnsiString;
  var FirstInitial: Ansichar; var Honerific, GivenName,
  FamilyName: AnsiString); overload;
{$ENDIF}
{ Returns Var G + MRS + GivenName + FamilyName }

procedure ReConstructAddressLine1(const AStrAd1: String;
  var AStrNo, AStreetName, AStrAve: String); overload;
{ Returns Var 1/48A + THISWAY + RD }

function MatchStrAveTypes(const AStrAve1, AStrAve2: AnsiString): Boolean;
{ Compares two entries in CAveRoadArray,CAveRoadFullArray  for a logical match }

function MatchRoadStreet(ATestValue: String; ABestFit: Boolean = False)
  : Integer;
{ Returns -1 or index to best match values in CAveRoadArray,CAveRoadFullArray }

function MatchRoadStreetQual(ATestValue: AnsiString): Integer;
{ Returns -1 or index to best match values in CAveRoadQual,CAveRoadFullQual }

procedure ReconstructUnitStreetNo(const ATotalNo: AnsiString;
  var AText, AUnitNo, AStrNo: AnsiString); overload;
{ Returns Var 1 + 48A  from   FLAT 1/48A }
function MatchStreetNo(AStrNo1, AStrNo2: AnsiString): Boolean;
{$IFNDEF FPC}
procedure ReConstructAddressLine1(const AStrAd1: String;
  var AStrNo, AStreetName, AStrAve: AnsiString); overload;
{ Returns Var 1/48A + THISWAY + RD }
procedure DeconstructPhoneNumber(const Value: AnsiString;
  var Std, PhoneNumber: AnsiString); overload;
procedure ReconstructFullAddress(const AAddressInFull: AnsiString;
  var AAddressSt, ASuburb, AZipCode: AnsiString); overload;
{ Returns Var "unit 2 14 Globe St"+"MOUNT WAVERLY" + "3195" (Or NY56789  ????) }
procedure ReConstructAddressLine2(const strAd2: AnsiString;
  var City, ZipCode: AnsiString); overload;
{ Returns Var MOUNT WAVERLY + 3195 (Or NY56789  ????) }
{$ENDIF}
procedure ReConstructAddressLine2(const strAd2: String;
  var City, ZipCode: String); overload;
{ Returns Var MOUNT WAVERLY + 3195 (Or NY56789  ????) }
procedure ReconstructFullAddress(const AAddressInFull: String;
  var AAddressSt, ASuburb, AZipCode: String); overload;
{ Returns Var "unit 2 14 Globe St"+"MOUNT WAVERLY" + "3195" (Or NY56789  ????) }

procedure DeconstructPhoneNumber(const Value: String;
  var Std, PhoneNumber: String); overload;

function ReconstructPhoneNumber(const AStd, APhoneNumber: String)
  : String; overload;

function ListCompareAsciiOrder(List: TStringList;
  Index1, Index2: Integer): Integer;
// To make a stringlist compare in asscii order assign to custom sort

procedure WrapListText(ListOfSS: TStrings; WrapChrSet: UniCodeCharSet;
  WrapLength: Byte);
// Object pointers will be lost
procedure CopyStringsOnly(var ResultList: Pointer; SourceList: TStrings);
{ Copy a stringlist without the associated objects }
procedure TrimLeadingAndTrailingBlankLines(AListOfLines: TStrings);

function PosSet(const S: String; PosChrSet: UniCodeCharSet): Integer;
{ Position of first instance of any AnsiChar in AnsiCharSet }

function StandardSearchPhoneFormat(const Value: String;
  var AStd, ALocalNo: String): String;

Function IsValidAustralianStateTeritory(ATest: String): Boolean;
// Returns true for Tas of Tasmania
Function IsValidAustralianCapital(ATest: String): Boolean;
// Returns true for Melbourne not case sensitive

function ValidEmailAddress(const Value: String): Boolean;
{ Exposed for XML }
function RecoverCommandLineValuePair(const ValueChar: Ansichar;
  const Buffer: AnsiString): AnsiString;
{ Expect Form   Program.exe   /R:Full /P:8080 }
function EndTagRequired(const TagIndicator: AnsiString): Boolean;

{$IFNDEF NextGen}
function HTMLExtractNextTab(var CurrentLoc: PAnsiChar): AnsiString;
{ Returns Next Tag and Moves CurrentLoc to '>' }

function HTMLExtractNextTagByType(var CurrentLoc: PAnsiChar;
  const LowerCaseTagIndicator: AnsiString): AnsiString; overload;
{ Returns Next Tag by type and Moves CurrentLoc to '>' }

function HTMLExtractToNextTagByType(var CurrentLoc: PAnsiChar;
  const LowerCaseTagIndicator: AnsiString): AnsiString; overload;
{ Returns text before Next Tag by type and Moves CurrentLoc to '>'+1 }

function HTMLExtractNextEndTab(var CurrentLoc: PAnsiChar): AnsiString; overload;
{ Exposed for XML }

{ From Tony Rietwyk 21/11/08
  The HTTPApp unit contains HTTPEncode and HTTPDecode routines for URL
  encoding.  Note that this encoding is different to HTML content itself.  For
  example, spaces are '+' in URL, but not HTML; special characters are %hex in
  URL, but &#dec; in HTML, etc.  The POST data is also URL encoded.
}

function HTMLExtractTagContents(var CurrentLoc: PAnsiChar;
  var TagText: AnsiString; const TagIndicator: AnsiString): AnsiString;
{ Extract LowerCase(TagText) and TagContents from <TI TagText>TagContents</TI> Moves currentloc to > }

procedure HTMLExtractTagWithOptionalContents(var CurrentLoc: PAnsiChar;
  var TagText, TagContent: AnsiString; const TagIndicator: AnsiString);
{ Extract Lwr(TagText) and TagContents if present from <TI TagText>[TagContents</TI>] Moves currentloc to > }

Function HTMLListItemArray(const AListTxt: AnsiString): TArrayOfAnsiStrings;
Function HTMLBrArray(Const AListTxt: AnsiString): TArrayOfAnsiStrings;

Function HtmlExtractHeaders(AData: AnsiString; ALvl: Ansichar;
  ATrim: Boolean = False): TArrayOfAnsiStrings;
{ Resturns all Headers of Lvl }

{$ENDIF}
function GenerateHTTPTextValuePair(const ValueName, TextValue: String): String;
{ Codes &Name=Value&Name=Value& as &#38;Name }
function HtmlChars(AData: String): AnsiString;
// Takes non HTML Ascii Chars eg & and make &#38; and Unicode Wide Char into &#556;
function HtmlFrmWideChar(AData: String; AAllow8bitControl: Boolean = False)
  : AnsiString;
// Takes Unicode Wide Char into &#556;     was HtmlFrmUniCode ????
// AAllow8bitControl Lets '<' , '>' etc pass

Function ConvertCharValForHtml(ACharVal: Integer): Boolean;
// Char needs handling for HTML
function RecoverPostValue(const S: AnsiString): String;
{ Decodes Roger+Connell%21 }
// 'Connell%2C+R.W.+%281196%29' >>  'Connell, R.W. (1196)'
// Text%26%2320219%3B >>   'Text任何'

{$IFNDEF NextGen}
function HTTPInsertFormValue(const ATemplate, AName, AValue: AnsiString)
  : AnsiString;
{ Fills the form ?msg=035&name=&Name2=&Name3=OldValue
  to return      ?msg=035&name=Value&Name2=&Name3=OldValue
  any oldvalue will be replaced }

function CreateHTTPTextValuePair(const ValueName, Value: AnsiString)
  : AnsiString;
{ use valuename='' to terminate AnsiString }
function RecoverHTTPTextValuePair(const ValueName, Buffer: AnsiString): String;
{ Decodes &Name=Value&Name=Value& }
// See PostValuePairs in ISCgiObjects

Function CodeAsInHTMLSubmit(const S: String): AnsiString;
{ Codes Resticted HTML Chars and WideChar for upload }
// 'Connell, R.W. (1196)'>>'Connell%2C+R.W.+%281196%29'
// 'Text任何'  >> 'Text%26%2320219%3B'

{$ENDIF}
function RecoverTagParameter(const ATagTxt, AParameter: AnsiString): AnsiString;
{ Returns value from ParameterName=Value }

function ReplaceControlWithSpace(const AInString: AnsiString): AnsiString;
function RemoveControlChar(const AInString: AnsiString): AnsiString;
{$IFNDEF FPC}
procedure NumericOnly(var S: AnsiString; AAllowSome: AnsiCharSet); overload;
{ Removes non Numeric removes Alpha punctuation & etc }
{$ENDIF}
function ReplaceSpecialHTMLChars(const AInString: AnsiString)
  : AnsiString; Overload;
{ Removes &#37 and gives % etc }

{$IFNDEF NextGen}
function ReplaceBreakWithCR(const AInString: AnsiString): AnsiString;
{ Replace <BR> with CR+LF }

function ReplaceSpecialHTMLChars(const AInString: UTF8String)
  : UTF8String; Overload;
{ <p>I will display &#9986;</p>
  <p>I will display &#x2702;</p> }
{$ENDIF}
Function PAnsiChrLen(APChar: PAnsiChar): Integer;
// Vecters to StrLen( for Mobile

function GenerateSpecialHTMLChars(const InString: String): AnsiString;
{ Removes % etc and gives &#37 etc }

function GenerateHTMLLineBreaksChars(const InString: String): String;
{ Replace EOL CR LF with <BR> }

procedure AlphaOnly(var S: String);
{ Replaces non alpha with spaces removes Numerals punctuation & etc }

function AlphaNumeric(const S: String; ASqueeze: Boolean;
  AAllowSome: UniCodeCharSet = [',', '.', '+', '-', ' ']): String;

procedure AlphaNumericPlusSome(var S: String; ASqueeze: Boolean;
  AAllowSome: UniCodeCharSet);

function TrimWthAll(const S: String; AAllowSome: UniCodeCharSet = ['.']
  ): String;
{ Remove LeadingAnd Trailing non Alpha numeric Chars Except AAllowSome }

function Numeric(const S: String;
  AAllowSome: UniCodeCharSet = [',', '.', '+', '-', ' ']): String;
{ Removes non Numeric }
procedure NumericOnly(var S: String;
  AAllowSome: UniCodeCharSet = [',', '.', '+', '-', ' ']); overload;
{ Removes non Numeric }

{$IFNDEF FPC}
procedure AlphaNumericOnly(var S: AnsiString;
  ASqueeze: Boolean = False); overload;
{$ENDIF}
procedure AlphaNumericOnly(var S: String; ASqueeze: Boolean = False); overload;
{ Replaces non alphanumeric with spaces (ASqueeze removes) punctuation & etc }
function TrimMenuItemCaption(const S: AnsiString): AnsiString;
{ Remove & from caption }

{$IFNDEF NextGen}
function MailToUrl(Eto, Ecc, Ebcc, Subject, Body: AnsiString): AnsiString;
function ExtractDomainFromEmail(const AEmailAddress: AnsiString): AnsiString;

// Representing Byte Data
function BytesToTextString(const ByteData: AnsiString): AnsiString;
// [Hex] unless (^m} Control Char or a LETTER or a L!E!T!T!E!R! above 128

function ObjIntToStr(AObj: TObject): AnsiString;
function PointerIntToStr(APtr: Pointer): AnsiString;
function BytesToWordString(const ByteData: AnsiString): AnsiString;
function BytesToByteString(const ByteData: AnsiString): AnsiString;
procedure HTTPHostAndFile(Url: PAnsiChar; var Hoststr, FileStr: AnsiString);
{ http://    >> host
  //         >> host
  nodot/z    >> file only
  localhost/z>>host & file
  yes.dot/z  >>host & file }
Function GetAnyPortRedirection(var Hoststr: AnsiString): Word;
{ LocalHost:8080 >> 8080 and HostStr=Localhost }

procedure HTTPAddWords(var S: AnsiString);
{ makes "Bacchus Marsh" into "Bacchus+Marsh"
  and   "Bacchus     Marsh" into "Bacchus+Marsh"
  and   "Bacchus@#$? Marsh" into "Bacchus+Marsh" }

{ Controls - mrOk mrCancel mrAbort mrRetry mrIgnore mrYes mrNo	 mrAll are in Controls }

{$ENDIF}
Function ISLastChar(S: AnsiString): Integer;

{$IFDEF NEXTGEN}

const
  CRLF = Char(#13) + Char(#10);
  EscChar = Char(#27);
{$ELSE}

const
  CRLF = Ansichar(#13) + Ansichar(#10);
  EscChar = Ansichar(#27);
{$ENDIF}
  HtmlPc = '&#37;'; // %
  HtmlPairMarker = '&#38;'; // &
  HtmlEq = '&#61;'; // =
  CAndRepTxt = '%26';
  CHashRepTxt = '%23';
  CSemiRepTxt = '%3B';

  CAveRoadArray: array [0 .. 48] of String = ('AV', 'RD', 'ST', 'CT', 'CR',
    'PDE', 'BLV', 'LINK', 'PL', 'HWY', 'TCE', 'GV', 'DR', 'LA', 'CL', 'MWS',
    'CIRT', 'RISE', 'WAY', 'GLA', 'GRA', 'GRND', 'AL', 'ARC', 'BND', 'CEN',
    'CHA', 'CIR', 'CIRT', 'CL', 'CON', 'ESP', 'WLK', 'WYD', 'SQ', 'TR', 'FWY',
    'GDN', 'PT', 'PRM', ' ', 'CROSS', 'MT', 'HTS', 'QD', 'RND', 'SLP',
    'CT', 'AV');
  CAveRoadFullArray: array [0 .. 48] of String = ('Avenue', 'Road', 'Street',
    'Court', 'Cresent', 'Parade', 'Boulevard', 'Link', 'Place', 'Highway',
    'Terrace', 'Grove', 'Drive', 'Lane', 'Close', 'Mews', 'Circuit', 'Rise',
    'Way', 'Glade', 'Grange', 'Ground', 'Alley', 'Arcade', 'Bend', 'Centre',
    'Chase', 'Circle', 'Circuit', 'Close', 'Concourse', 'Esplanade', 'Walk',
    'Wynd', 'Square', 'Track', 'Freeway', 'Gardens', 'Point', 'Promenade', ' ',
    'Crossing', 'Mount', 'Heights', 'Quarant', 'Round', 'Slope', 'Crt', 'Ave');
  CAveRoadQual: array [0 .. 6] of String = (' ', ' N', ' S', ' E', ' W',
    ' L', ' U');
  CAveRoadFullQual: array [0 .. 6] of String = (' ', ' North', ' South',
    ' East', ' West', ' Lower', ' Upper');

  CNameHonerificArray: array [0 .. 31] of String = ('MR', 'MASTER', 'MRS',
    'MISS', 'MS', 'MLLE', 'MME', 'M', 'MESSRS', 'MMES', 'DR', 'PROF', 'HON',
    'REV', 'FR', 'MSGR', 'SR', 'BR', 'PVT', 'CPL', 'SGT', 'ENS', 'ADM', 'MAJ',
    'CAPT', 'CMDR', 'LT', 'LT COL', 'COL', 'GEN', 'ING', 'PASTOR');

  CNameHonerificArrayWithFullName: array [0 .. 31] of String = ('Mr.', 'Master',
    'Mrs.', 'Miss', 'Ms.', 'Mlle.', 'Mme.', 'M.', 'Messrs.', 'Mmes.', 'Dr.',
    'Prof.', 'Hon.', 'Rev.', 'Fr.', 'Msgr.', 'Sr.', 'Br.', 'Pvt.', 'Cpl.',
    'Sgt.', 'Ens.', 'Adm.', 'Maj.', 'Capt.', 'Cmdr.', 'Lt.', 'Lt. Col.', 'Col.',
    'Gen.', 'Ing', 'Pastor');

  CNameHonerificArrayFull: array [0 .. 31] of String = ('Mister', 'Master',
    'Missus', 'Miss', 'Ms.', 'Mademoiselle ', 'Madame', 'M.', 'Misters',
    'Mesdames', 'Doctor', 'Professor', 'Honorable', 'Reverend', 'Father',
    'Monsignor', 'Sister', 'Brother', 'Private', 'Corporal', 'Sergeant',
    'Ensign', 'Admiral', 'Major', 'Captain', 'Commander', 'Lieutenant',
    'Lieutenant Colonel', 'Colonel', 'General', 'Ing', 'Pastor');

  CNameHonerificArrayFormalAddress: array [0 .. 31] of String = // Electrac?
    ('Mr', 'Master', 'Mrs', 'Miss', 'Ms.', 'Mlle.', 'Mme.', 'M.', 'Messrs.',
    'Mmes', 'Doctor', 'Professor', 'The Honorable', 'Reverend', 'Father',
    'Monsignor', 'Sister', 'Brother', 'Private', 'Corporal', 'Sergeant',
    'Ensign', 'Admiral', 'Major', 'Captain', 'Commander', 'Lieutenant',
    'Lieutenant Colonel', 'Colonel', 'General', 'Ing', 'Pastor');

  HonIsMale = [0, 1, 7, 8, 12, 13, 14, 15, 17, 18, 19, 22, 23, 24, 25, 26,
    27, 28, 29];

  CNameHonerificArrayForUnSortedComboBox: array [0 .. 37] of String = ('Mr',
    'Mrs', 'Miss', 'Ms', 'Master', 'Messrs', 'Dr', 'Prof', 'Hon', 'Rev', 'Fr',
    'Br', 'Sr', // 13
    'Mademoiselle', 'Madame', 'Mesdames', 'Doctor', 'Professor', 'Honorable',
    'Reverend', // 20
    'Father', 'Monsignor', 'Sister', 'Brother', 'Private', 'Corporal',
    'Sergeant', 'Ensign', 'Admiral', 'Major', // 30
    'Captain', 'Commander', 'Lieutenant', 'Lieutenant Colonel', 'Colonel',
    'General', 'Ing', 'Pastor'); // 37

  ValidEndWordChars = [' ' .. '/', ':' .. '@'];
  // ??? [' ', ',', '.',':', ';','/','-','_']);

  OpenBracket: UniCodeCharSet = ['{', '[', '(', '<'];
  CloseBracket: UniCodeCharSet = ['}', ']', ')', '>'];

{$IFDEF NEXTGEN}
  ZSISOffset = -1;
  IsFirstChar = 0;
  OpenBracketAnsi: AnsiCharSet = [Ord('{'), Ord('['), Ord('('), Ord('<')];
  CloseBracketAnsi: AnsiCharSet = [Ord('}'), Ord(']'), Ord(')'), Ord('>')];
  // ZSISOffset = -1; // Zero Based String OffSet Cons
{$ELSE}
  OpenBracketAnsi: AnsiCharSet = ['{', '[', '(', '<'];
  CloseBracketAnsi: AnsiCharSet = ['}', ']', ')', '>'];
  ZSISOffset = 0;
  IsFirstChar = 1;
{$ENDIF}
  ZSISCopyOffset = 0; // String Copy is i ref in new gen compiler at D10S
  // http://docwiki.embarcadero.com/RADStudio/Tokyo/en/Zero-based_strings_(Delphi)
  // {$IF not defined(NEXTGEN) or defined(LINUX)}
  // {$ZEROBASEDSTRINGS OFF} // Desktop platforms use One-based string
  // {$ENDIF}

implementation

function BlankLine(aStrg: AnsiString): Boolean;
var
  AnsiChr: PAnsiChar;
begin
{$IFDEF NextGen}
  Result := aStrg.IsBlank;
{$ELSE}
  Result := True;
  AnsiChr := PAnsiChar(aStrg);
  while Result and (AnsiChr[0] <> Ansichar(0)) do
  begin
    if AnsiChr[0] <> ' ' then
      Result := False;
    inc(AnsiChr);
  end;
{$ENDIF}
end;

Function IsEmptyString(Var AString:AnsiString):Boolean; Overload;
begin
  Result:=Length(AString)=0;
  if Result then
     AString:='';
end;

Function PCharNotNull(Var AChar: PAnsiChar): Boolean; Overload;
// Checks not (AChar='' or AChar=nil) will set Achar=nil if was ''
Begin
  Result := False;
  if AChar = nil then
    Exit;
  if AChar[0] = #0 then
  Begin
    AChar := nil;
    Exit;
  End;
  Result := True;
End;

function SepStrg(var aStrg: PAnsiChar; ASep: AnsiString): AnsiString;
{ Returns ansistring and pointer to next field (Var AStrg) in AnsiString }
var
  CharPointer: PAnsiChar;
  lrslt, lsep, i: Integer;
  Fnd: Boolean;

begin
{$IFDEF NextGen}
  Result := aStrg.SepStrg(ASep);
{$ELSE}
  Result := '';
  if (aStrg = nil) then
    Exit;

  if ASep = '' then
  begin
    Result := aStrg;
    aStrg := nil;
    Exit;
  end;
  lsep := length(ASep);
  Fnd := False;
{$IFDEF ISD102T_DELPHI}
  CharPointer := StrScan(aStrg, ASep[1]);
{$ELSE}
  CharPointer := System.AnsiStrings.StrScan(aStrg, ASep[1]);
{$ENDIF}
  while (CharPointer <> nil) do
  begin
    Fnd := True;
    if lsep > 1 then
      for i := 2 to lsep do
        if CharPointer[i - 1] <> ASep[i] then
          Fnd := False;
    if Fnd then
    begin
      lrslt := CharPointer - aStrg;
      SetLength(Result, lrslt);
      if lrslt > 0 then
{$IFDEF ISD102T_DELPHI}
        StrLCopy(@Result[1], aStrg, lrslt);
{$ELSE}
        System.AnsiStrings.StrLCopy(@Result[1], aStrg, lrslt);
{$ENDIF}
      if Ord(CharPointer[lsep]) = 0 then
        aStrg := nil
      else
        aStrg := CharPointer + lsep;
      CharPointer := nil;
    end
    else
    begin
      inc(CharPointer);
      if Ord(CharPointer[0]) = 0 then
        CharPointer := nil
      else
{$IFDEF ISD102T_DELPHI}
        CharPointer := StrScan(CharPointer, ASep[1]);
{$ELSE}
        CharPointer := System.AnsiStrings.StrScan(CharPointer, ASep[1]);
{$ENDIF}
    end;
  end;
  if not Fnd then
  begin
    lrslt := length(aStrg);
    SetLength(Result, lrslt);
{$IFDEF ISD102T_DELPHI}
    StrLCopy(@Result[1], aStrg, lrslt);
{$ELSE}
    System.AnsiStrings.StrLCopy(@Result[1], aStrg, lrslt);
{$ENDIF}
    aStrg := nil;
  end;
{$ENDIF}
end;

function SepStrg(var aStrg: AnsiString; Const ASep: AnsiString)
  : AnsiString; overload;
{ Returns ansistring and an ansiString of rest of AnsiString Slower than the above but
  handles strings containing nulls }
Var
  i: Integer;
Begin
  Result := aStrg;
  i := Pos(ASep, aStrg);
  if i < 1 then
    aStrg := ''
  Else
  Begin
    Result := Copy(aStrg, 1, i - 1);
    i := (length(ASep) + i);
    if length(aStrg) <= i then
      aStrg := ''
    else
      aStrg := Copy(aStrg, i, length(aStrg) - i + 1);
  End;
End;

{$IFDEF UNICODE}

function SepStrg(var aStrg: PWideChar; ASep: UnicodeString)
  : UnicodeString; overload;
var
  CharPointer: PWideChar;
  lrslt, lsep, i: Integer;
  Fnd: Boolean;

begin
  Result := '';
  if (aStrg = nil) then
    Exit;

  if ASep = '' then
  begin
    Result := aStrg;
    aStrg := nil;
    Exit;
  end;
  lsep := length(ASep);
  Fnd := False;
  CharPointer := StrScan(aStrg, ASep[1 + ZSISOffset]);
  while (CharPointer <> nil) do
  begin
    Fnd := True;
    if lsep > 1 then
      for i := 2 to lsep do
        if Fnd then
          if CharPointer[i - 1] <> ASep[i + ZSISOffset] then
            Fnd := False;
    if Fnd then
    begin
      lrslt := CharPointer - aStrg;
      SetLength(Result, lrslt);
      if lrslt > 0 then
        StrLCopy(PWideChar(Result), aStrg, lrslt);
      if Ord(CharPointer[lsep]) = 0 then
        aStrg := nil
      else
        aStrg := CharPointer + lsep;
      CharPointer := nil;
    end
    else
    begin
      inc(CharPointer);
      if Ord(CharPointer[0]) = 0 then
        CharPointer := nil
      else
        CharPointer := StrScan(CharPointer, ASep[1 + ZSISOffset]);
    end;
  end;
  if not Fnd then
  begin
    lrslt := StrLen(aStrg);
    SetLength(Result, lrslt);
    StrLCopy(PWideChar(Result), aStrg, lrslt);
    aStrg := nil;
  end;
end;

function BackScanFromHere(Var cs: PWideChar; AInSet: UniCodeCharSet;
  AMax: Integer = 100): PWideChar;
{ Reverse scan from cs to first occurance of a member of the set }

begin
  Result := cs;
  if AInSet = [] then
    Exit;

  while (AMax > 0) and Not(Result[0] in AInSet) do
  begin
    Dec(Result);
    Dec(AMax);
  end;

  if AMax < 1 then
    Result := nil;
end;

{$IFNDEF FPC}
Function IsEmptyString(Var AString:String):Boolean; Overload;
Begin
    Result:=Length(AString)=0;
    if Result then
     AString:='';
End;


Function PCharNotNull(Var AChar: PChar): Boolean; Overload;
// Checks not (AChar='' or AChar=nil) will set Achar=nil if was ''
Begin
  Result := False;
  if AChar = nil then
    Exit;
  if AChar[0] = #0 then
  Begin
    AChar := nil;
    Exit;
  End;
  Result := True;
End;
{$ENDIF}

function FieldSep(var ss: PWideChar; SepVal: WideChar): UnicodeString;
var
  CharPointer: PWideChar;
  j: Integer;

begin
  if ss <> nil then
  begin
    if (SepVal <> WideChar(0)) then
      while ss[0] = SepVal do
        inc(ss);
{$IFDEF FPC}
    CharPointer := StrScan(ss, SepVal);
{$ELSE}
    CharPointer := AnsiStrScan(ss, SepVal);
{$ENDIF}
    if CharPointer = nil then
      Result := StrPas(ss) { Last Field }
    else
    begin
      j := CharPointer - ss;
      Result := System.Copy(ss, 0, j);
    end;
    if CharPointer = nil then
      ss := nil
    else
      ss := CharPointer + 1;
  end
  else
    Result := '';
end;

procedure GetFields(var Fields: TArrayOfUnicodeStrings; const S: UnicodeString;
  SepVal: WideChar; ARemoveQuote: Boolean = False;
  ATrim: Boolean = True); overload;
{ Returns unicodeString Array of all separeted strings }
var
  Sz: Integer;

begin
  Sz := length(Fields);
  Fields := GetArrayFromString(S, SepVal, ARemoveQuote, ATrim);
  if length(Fields) < Sz then
    SetLength(Fields, Sz);
end;

{$ENDIF}
{$IFDEF ISXE8_DELPHI}

function BackScanFromHere(Var cs: PAnsiChar; AInSet: AnsiCharSet;
  AMax: Integer = 100): PAnsiChar;
{ Reverse scan from cs to first occurance of a member of the set }
begin
  Result := cs;
  if AInSet = [] then
    Exit;

  while (AMax > 0) and Not(Result[0] in AInSet) do
  begin
    Dec(Result);
    Dec(AMax);
  end;

  if AMax < 1 then
    Result := nil;
end;
{$ENDIF}

function FieldSep(var ss: PAnsiChar; SepVal: Ansichar): AnsiString;
var
  CharPointer: PAnsiChar;
  j: Integer;

begin
{$IFDEF NextGen}
  Result := ss.FieldSep(SepVal);
{$ELSE}
  if ss <> nil then
  begin
    if (SepVal <> AnsiChr(0)) then
      while ss[0] = SepVal do
        ss := ss + 1;
{$IFDEF ISD102T_DELPHI}
    CharPointer := StrScan(ss, SepVal);
    if CharPointer = nil then
      Result := StrPas(ss) { Last Field }
{$ELSE}
    CharPointer := System.AnsiStrings.StrScan(ss, SepVal);
    if CharPointer = nil then
      Result := System.AnsiStrings.StrPas(ss) { Last Field }
{$ENDIF}
    else
    begin
      j := CharPointer - ss;
      Result := Copy(ss, 0, j);
    end;
    if CharPointer = nil then
      ss := nil
    else
      ss := CharPointer + 1;
  end
  else
    Result := '';
{$ENDIF}
end;

function FirstField(const ANextChar: PAnsiChar; SepVal: Ansichar): AnsiString;
{ Wraps FieldSep for simplicicty to access first Field only }
var
  CharPointer: PAnsiChar;
begin
  if ANextChar = nil then
    Exit;

  CharPointer := ANextChar;
  Result := FieldSep(CharPointer, SepVal);
end;

function FileRelativePathBuild(ABasePath: string; ARelFileName: string): string;
var
  NewPath, BitLeft: string;
  EndChr, StartChr: PChar;
  i: Integer;
begin
  Result := ConcatToFullFileName(ABasePath, ARelFileName);
  i := Pos('.\', ARelFileName);
  if (i < 1) or (i > 2) then
  begin
    i := Pos('./', ARelFileName);
    if (i < 1) or (i > 2) then
      Exit;
  end;

  NewPath := ExpandFileName(ABasePath);
  EndChr := @NewPath[length(NewPath)];
  if (EndChr <> nil) then
    if (EndChr[0] = '\') then
      EndChr[0] := Ansichar(0)
    else if (EndChr[0] = '/') then
      EndChr[0] := Ansichar(0);

  BitLeft := ARelFileName;

  StartChr := PChar(NewPath);
  while Pos('..\', BitLeft) = 1 do
  begin
    EndChr := StrRScan(StartChr, '\');
    if (EndChr <> nil) then
      EndChr[0] := Ansichar(0);
    BitLeft := System.Copy(BitLeft, 4 + ZSISCopyOffset, 99);
  end;

  while Pos('../', BitLeft) = 1 do
  begin
    EndChr := StrRScan(StartChr, '/');
    if (EndChr <> nil) then
      EndChr[0] := Ansichar(0);
    BitLeft := System.Copy(BitLeft, 4 + ZSISCopyOffset, 99);
  end;

  if Pos('.\', BitLeft) = 1 then
    BitLeft := System.Copy(BitLeft, 3 + ZSISCopyOffset, 99);
  if Pos('./', BitLeft) = 1 then
    BitLeft := System.Copy(BitLeft, 3 + ZSISCopyOffset, 99);

  SetLength(NewPath, StrLen(StartChr));
  Result := ConcatToFullFileName(NewPath, BitLeft);
end;

Function ShortenFileName(Const AFileName: String;
  ATotalLength: Integer): String;
// Chop the middle from a long file name to fit within Total Length
// eg c:\bigdata\fifty\today\xxxx\bbbbb\text.txt
// to c:\bigdata\...\bbbbb\text.txt

Var
{$IFDEF UNICODE}
  Parts: TArrayOfUnicodeStrings;
{$ELSE}
  Parts: TArrayOfAnsiStrings;
{$ENDIF}
  Chopped: Array Of Boolean;
  ServerFlag, InsertSep: Boolean;
  OrgLen, ToLoose, Dirs, MidDir, ThisDir, StartLen, TopLen, idx: Integer;
  DirSep: Char;

  { sub } Procedure ChopArrayField(Var ALeftToGo: Integer; AIdx: Integer;
    AChopEnd: Boolean);
  Var
    len: Integer;
  begin
    len := length(Parts[AIdx]);
    if ALeftToGo > 0 then
      Chopped[AIdx] := True;
    if len < ALeftToGo then
    begin
      ALeftToGo := ALeftToGo - len - 1;
      Parts[AIdx] := '';
    end
    else
    begin
      If AChopEnd then
        SetLength(Parts[AIdx], len - ALeftToGo)
      else if AIdx = Dirs then
        Parts[AIdx] := System.Copy(Parts[AIdx],
          ALeftToGo + 2 + ZSISCopyOffset, len)
      else
        Parts[AIdx] := System.Copy(Parts[AIdx],
          ALeftToGo + 1 + ZSISCopyOffset, len);
      ALeftToGo := 0;
    end;
  end;

begin
  DirSep := '\';
  if Pos('\', AFileName) < 1 then
    DirSep := '/';

  OrgLen := length(AFileName);
  if OrgLen <= ATotalLength then
    Result := AFileName
  else
  begin
    if Pos('\\', AFileName) > 0 then
    begin
      Result := StringReplace(AFileName, '\\', '||', [rfReplaceAll]);
      ServerFlag := True;
    end
    else
    begin
      Result := AFileName;
      ServerFlag := False;
    end;
    ToLoose := OrgLen - ATotalLength + 4 + 1; // \.... or .....
    Parts := GetArrayFromString(Result, DirSep);
    if Parts[0] = '' then
    Begin
      DropArrayItemAtPos(Parts, 0);
      InsertSep := True;
    end
    else
      InsertSep := False;
    Dirs := High(Parts);
    SetLength(Chopped, Dirs + 1);
    MidDir := Dirs div 2;
    // MidDir := Dirs - MidDir;
    ThisDir := 0;
    while (ThisDir < MidDir) and (ToLoose > 0) do
    begin
      ChopArrayField(ToLoose, MidDir - ThisDir, True);
      if (ToLoose > 0) and (ThisDir > 0) then
        ChopArrayField(ToLoose, MidDir + ThisDir, False);
      inc(ThisDir);
    end;
    if (ToLoose > 0) then
      ChopArrayField(ToLoose, Dirs - 1, False); // Does a repeat if already done

    if (ToLoose > 0) then
    begin
      StartLen := length(Parts[0]);
      TopLen := length(Parts[Dirs]);
      if Abs(StartLen - TopLen) > 3 * ToLoose then
        if StartLen < TopLen then
          ChopArrayField(ToLoose, Dirs, False)
        else
          ChopArrayField(ToLoose, 0, True)
      else if StartLen > 2 * ToLoose then
        ChopArrayField(ToLoose, 0, True)
      else
      begin
        StartLen := StartLen div 2;
        ToLoose := ToLoose - StartLen;
        if (TopLen - ToLoose) < 8 then // must leave 8 in final directory
        Begin
          if (ToLoose + StartLen - length(Parts[0])) > 8 then
          Begin
            ToLoose := ToLoose - length(Parts[0]) + StartLen;
            StartLen := length(Parts[0]); // Delete HomeDirectory
          End
          else
          begin
            Result := AFileName;
            Exit; // File too short
          end;
        end;
        ChopArrayField(StartLen, 0, True);
        ChopArrayField(ToLoose, Dirs, False)
      end;
    end;
    Result := '';
    for idx := 0 to Dirs - 1 do
      if Parts[idx + 1] = '' then
      begin
        If Parts[idx] <> '' then
          if Chopped[idx] then
            Result := Result + Parts[idx]
          Else
            Result := Result + Parts[idx] + DirSep;

        if Pos('....', Result) < 1 then
          if Chopped[idx] then
            Result := Result + '.....'
          else
            Result := Result + '....';
      end
      else if Parts[idx] <> '' then
        Result := Result + Parts[idx] + DirSep
      else if Chopped[idx + 1] then
        Result := Result + '.'
      Else
        Result := Result + DirSep;

    Result := Result + Parts[Dirs];
    if ServerFlag then
      Result := StringReplace(Result, '|', '\', [rfReplaceAll]);
    if InsertSep then
      Result := DirSep + Result;
  end;
end;

function FileNameFriendly(const S: String; ReplaceWith: Char): String;
{ Returns Only Characters that are valid in a file name including path specifiers /&\ Relaced with }
var
  i: Integer;
begin
  Result := S;
  for i := 1 to length(Result) do
    if not(Result[i] in ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '.', '_', '-'])
    then
      Result[i] := ReplaceWith;
end;

function RemoveBlankLines(const S: AnsiString): AnsiString;
var
  NextChar: PAnsiChar;
  Line: AnsiString;
begin
  NextChar := PAnsiChar(S);
  Result := '';
  while NextChar <> nil do
  begin
    Line := TakeOneLine(NextChar);
    if Trim(Line) <> '' then
      if Result <> '' then
        Result := Result + CRLF + Line
      else
        Result := Line;
  end;
end;

Function ReplaceSeps(Const AText, NewValue: AnsiString;
  AChangeArray: array of AnsiString): AnsiString;
// Replaces all in AChangeArray with NewValue
Var
  i: Integer;
begin
  Result := AText;
  for i := 0 to High(AChangeArray) do
  Begin
    if Pos(AChangeArray[i], Result) > 0 then
      Result := StringReplace(Result, AChangeArray[i], NewValue,
        [rfReplaceAll]);
  End;
end;

function RemoveQuotes(const S: AnsiString): AnsiString;
Var
  len: Integer;
{$IFDEF NEXTGEN}
  ts: Char;
{$ELSE}
  ts: Ansichar;
{$ENDIF}
begin
  Result := S;
{$IFDEF NEXTGEN}
  len := S.length;
{$ELSE}
  len := length(S);
{$ENDIF}
  if S <> '' then
  begin
    ts := S[1 + ZSISOffset];
    case ts of
      '''', '"':
        if S[len + ZSISOffset] = S[1 + ZSISOffset] then
          Result := Copy(S, 2, len - 2);
    end; // case
  end;
end;

function LongWordSetAsString(AData: LongWord; ASepVal: AnsiString;
  AStringValues: array of AnsiString): AnsiString;
{ Returns separeted strings from AnsiString Array in Longword set }
var
  i, Mask: Integer;
begin
  Mask := 1;
  Result := '';
  for i := 0 to high(AStringValues) do
  begin
    if (Mask and AData) > 0 then
      if Result = '' then
        Result := AStringValues[i]
      else
        Result := Result + ASepVal + AStringValues[i];
    Mask := Mask shl 1;
  end;
end;

function ArrayOfFieldToText(Fields: TArrayOfAnsiStrings; SepVal: Ansichar;
  AddQuote: Integer): AnsiString;
{ Returns separeted strings from AnsiString Array 0 no Quotes 1:" 2:' }

var
  i: Integer;

begin
  Result := '';
  for i := 0 to high(Fields) do
  begin
    case AddQuote of
      0:
        Result := Result + Fields[i];
      1:
        Result := Result + '''' + Fields[i] + '''';
      2:
        Result := Result + '"' + Fields[i] + '"';
    end; // case
    Result := Result + SepVal;
  end;
  if Result <> '' then
{$IFDEF NextGen}
    Result.length := Result.length - 1;
{$ELSE}
    SetLength(Result, length(Result) - 1);
{$ENDIF}
end;

function ReadValueFrmTStrings(AData, AHeaders: TStrings; AHdrRef: AnsiString)
  : AnsiString;
var
  i: Integer;
begin
  Result := '';
  if AHdrRef = '' then
    Exit;
  if AHeaders = nil then
    Exit;
  if AData = nil then
    Exit;

  i := AHeaders.IndexOf(AHdrRef);
  if (i > -1) and (i < AData.Count) then
    Result := AData[i];
end;

procedure GetFields(var Fields: TArrayOfAnsiStrings; const S: AnsiString;
  SepVal: Ansichar; ARemoveQuote: Boolean = False; ATrim: Boolean = True);
var
  Sz: Integer;

begin
  Sz := length(Fields);
  Fields := GetArrayFromString(S, SepVal, ARemoveQuote, ATrim);
  if length(Fields) < Sz then
    SetLength(Fields, Sz);
end;

{$IFDEF NEXTGEN}

Function MatchingCloseBracket(AOpenBrkt: Byte): Ansichar;
begin
  case AOpenBrkt of
    Ord('('):
      Result := ')';
    Ord('{'):
      Result := '}';
    Ord('['):
      Result := ']';
    Ord('<'):
      Result := '>';
  Else
    raise Exception.Create('No MatchingCloseBracket for ' + Char(AOpenBrkt));
  end;

end;
{$ELSE}

Function MatchingCloseBracket(AOpenBrkt: Ansichar): Ansichar;
begin
  case AOpenBrkt of
    '(':
      Result := ')';
    '{':
      Result := '}';
    '[':
      Result := ']';
    '<':
      Result := '>';
  Else
    raise Exception.Create('No MatchingCloseBracket for ' + AOpenBrkt);
  end;

end;
{$ENDIF}
{$IFDEF ISXE8_DELPHI}

function ExtractNextBracket(var APchr: PAnsiChar; AAllowMismatch: Boolean)
  : AnsiString;
{ Extracts fgfgg from some junk(fgfgg) more junk
  and returns pointer to  more junk
  Extracts fgfgg from some junk(fgfgg
  and returns nil
}

Var
  CloseBracket, ThisBrkt: Ansichar;
  CntDepth: Integer;
begin
  Result := '';
  if APchr <> nil then
    if APchr[0] = PAnsiChar(0) then
      APchr := nil;
  if APchr = nil then
    Exit;

  CntDepth := 0;
  ThisBrkt := ' ';
  CloseBracket := ' ';
  while (APchr <> nil) and (ThisBrkt = ' ') do
    if APchr[0] = #0 then
      APchr := nil
    else
    begin
      if APchr[0] in OpenBracketAnsi then
      Begin
        ThisBrkt := APchr[0];
        CloseBracket := MatchingCloseBracket(ThisBrkt);
      End;
      inc(APchr);
    end;

  while (APchr <> nil) and (CloseBracket <> ' ') do
    if APchr[0] = #0 then
    Begin
      APchr := nil;
      if not AAllowMismatch then
        if CloseBracket <> ' ' then
          raise Exception.Create('Mismatched Brackets in >>' + ThisBrkt
            + Result);
    End
    else
    begin
      if APchr[0] <> CloseBracket then
      begin
        Result := Result + APchr[0];
        if APchr[0] = ThisBrkt then
          inc(CntDepth);
      end
      else If CntDepth > 0 then
      begin
        Dec(CntDepth);
        Result := Result + CloseBracket;
      end
      else
        CloseBracket := ' ';
      inc(APchr);
    end;

end;
{$ENDIF}
{$IFDEF ISXE8_DELPHI}

Function RemoveBracketedText(ADataTxt: AnsiString; AAllowMismatch: Boolean)
  : AnsiString;
{ Remove text in Brackets ffgf {hhhhh) nnnn becomes ffgf nnnn }
{ On Exception Use RemoveMismatchedBracket }
var
  NxtChr, StrtChr: PAnsiChar;
  StrtBrk, EndBrk, LnAft: Integer;
  ExcludeTxt, FrntTxt, BckTxt: AnsiString;
Begin
  Result := ADataTxt;
  NxtChr := PAnsiChar(Result);
  while NxtChr <> nil do
  Begin
    StrtChr := NxtChr;
    ExcludeTxt := ExtractNextBracket(NxtChr, AAllowMismatch);
    if ExcludeTxt <> '' then
    begin
      if NxtChr <> nil then
        EndBrk := NxtChr - StrtChr + ZSISCopyOffset
      else
      Begin
        EndBrk := length(Result) + ZSISOffset;
        if not(Result[EndBrk] in CloseBracketAnsi) then
          inc(EndBrk);
      End;
      StrtBrk := EndBrk - length(ExcludeTxt) - 2;
      LnAft := length(Result) - EndBrk;
      FrntTxt := Trim(Copy(Result, 1 + ZSISCopyOffset, StrtBrk));
      if LnAft > 0 then
        BckTxt := Trim(Copy(Result, EndBrk + 1 + ZSISCopyOffset, LnAft))
      else
        BckTxt := '';
      Result := Trim(FrntTxt + ' ' + BckTxt);
    end;
    if NxtChr <> nil then
      NxtChr := PAnsiChar(Result);
  end
end;
{$ENDIF}
{$IFDEF ISXE8_DELPHI}

Function RemoveMismatchedBracket(ADataTxt: AnsiString; AReplaceWith: Ansichar)
  : AnsiString;
{ Drops a outside Bracket that is not terminated Brackets
  ffgf {hhhhh (nnnn) becomes ffgf ,hhhh (nnnn)
  And
  ffgf (hhhhh (nnnn) becomes ffgf ,hhhh (nnnn) ???
  { On Exception handler for RemoveMismatchedBracket }
Var
  CloseBracket, ThisBrkt: Ansichar;
  ThisChr, StartChr, LastStartChr: PAnsiChar;
  StartBracketPos, CntDepth: Integer;
  ExcludeTxt: AnsiString;
begin
  Result := ADataTxt;
  if ADataTxt = '' then
    Exit;

  ThisChr := AnsiCharPtr(ADataTxt);
  StartChr := ThisChr;
  ExcludeTxt := 'mmm';
  while ExcludeTxt <> '' do
    Try
      LastStartChr := ThisChr;
      ExcludeTxt := ExtractNextBracket(ThisChr);
    Except
      ExcludeTxt := '';
      ThisChr := LastStartChr;
    End;

  StartBracketPos := 0;
  if ThisChr <> nil then
    if ThisChr[0] = PAnsiChar(0) then
      ThisChr := nil;
  if ThisChr = nil then
    Exit;

  CntDepth := 0;
  ThisBrkt := ' ';
  CloseBracket := ' ';
  while (ThisChr <> nil) and (ThisBrkt = ' ') do
    if ThisChr[0] = #0 then
      ThisChr := nil
    else
    begin
      if ThisChr[0] in OpenBracketAnsi then
      Begin
        ThisBrkt := ThisChr[0];
        CloseBracket := MatchingCloseBracket(ThisBrkt);
      End;
      inc(ThisChr);
    end;
  if (CloseBracket <> ' ') then
    StartBracketPos := ThisChr - StartChr;

  while (ThisChr <> nil) and (CloseBracket <> ' ') do
    if ThisChr[0] = #0 then
    Begin
      ThisChr := nil;
      if CloseBracket <> ' ' then
        if StartBracketPos > 0 then
          Result[StartBracketPos] := AReplaceWith;
    End
    else
    begin
      if ThisChr[0] <> CloseBracket then
      begin
        // Result := Result + ThisChr[0];
        if ThisChr[0] = ThisBrkt then
          inc(CntDepth);
      end
      else If CntDepth > 0 then
      begin
        Dec(CntDepth);
        // Result := Result + CloseBracket;
      end
      else
        CloseBracket := ' ';
      inc(ThisChr);
    end;
end;
{$ENDIF}

Function MaskNumbers(Var AText: AnsiString): Boolean;
// Changes Numerics Chars to a Code in DLE to Em
Var
  i: Integer;
Begin
  Result := False;
  for i := IsFirstChar to ISLastChar(AText) do
{$IFDEF Nextgen}
    if Byte(AText[i]) in [Ord('0') .. Ord('9')] then
{$ELSE}
    if AText[i] in ['0' .. '9'] then
{$ENDIF}
    begin
      AText[i] := Ansichar(Ord(AText[i]) - 32);
      Result := True;
    end;
End;

Function UnMaskNumbers(Var AText: AnsiString): Boolean;
// Recovers Numerics Chars From a Code in DLE to Em
Var
  i: Integer;
Begin
  Result := False;
  for i := IsFirstChar to ISLastChar(AText) do
{$IFDEF Nextgen}
    if Byte(AText[i]) in [16 .. 16 + 9] then
{$ELSE}
    if AText[i] in [Ansichar(16) .. Ansichar(16 + 9)] then
{$ENDIF}
    begin
      AText[i] := Ansichar(Ord(AText[i]) + 32);
      Result := True;
    end;
End;

function ExtractNumberChars(var APchr: PAnsiChar;
  AAceptDpAndSign: Boolean = False): AnsiString;
begin
  Result := '';
  while (Byte(APchr[0]) <> 0) and not ISNumeric(APchr[0], AAceptDpAndSign) do
    inc(APchr);
  while (Byte(APchr[0]) <> 0) and ISNumeric(APchr[0], AAceptDpAndSign) do
  begin
    Result := Result + APchr[0];
    inc(APchr);
  end;
  if Byte(APchr[0]) = 0 then
    APchr := nil;
end;

function ExtractNumber(var APchr: PAnsiChar): Integer;
var
  S: AnsiString;

begin
  Result := 0;
  S := '';
  while (Byte(APchr[0]) <> 0) and not ISNumeric(APchr[0]) do
    inc(APchr);
  while (Byte(APchr[0]) <> 0) and ISNumeric(APchr[0]) do
  begin
    S := S + APchr[0];
    inc(APchr);
  end;
  if Byte(APchr[0]) = 0 then
    APchr := nil;
  if S <> '' then
    Result := StrToInt(S);
end;

function ExtractInt(const ss: String): Integer;
var
  Value, ErrorCode: Integer;
  s1: String;
begin
  s1 := ss;
  Val(s1, Value, ErrorCode);
  if ErrorCode <> 0 then
  begin
    Delete(s1, ErrorCode, 255);
    Val(s1, Value, ErrorCode);
  end;
  Result := Value;
end;

function ExtractTime(const S: String; ADefault: TDateTime): TDateTime;
var
  ts, Sp: Integer;
  TimeS: String;
begin
  TimeS := S;
{$IFDEF FMXApplication}
  ts := Pos(FormatSettings.TimeSeparator, S);
{$ELSE}
{$IFDEF ISXE3_DELPHI}
  ts := Pos(FormatSettings.TimeSeparator, S);
{$ELSE}
  ts := Pos(TimeSeparator, S);
{$ENDIF}
{$ENDIF}
  if ts > 3 then
  begin
    Sp := Pos(' ', S);
    if (Sp > 0) and (Sp < ts) then
      TimeS := System.Copy(S, Sp + 1 + ZSISCopyOffset, length(S));
  end;
  Result := StrToTimeDef(TimeS, ADefault);
end;

function ExtractHexByte(S: PChar): Byte;
{ Returns Byte from Hex at start of AnsiString }
var
  i: Integer;
begin
  Result := 0;
  if S = nil then
    Exit;
  for i := 0 to 1 do
  begin
    if i = 1 then
      Result := Result shl 4;
    case S[i] of
      #0:
        Exit;
      '0' .. '9':
        Result := Result + Byte(Ord(S[i])) - Byte(Ord('0'));
      'a' .. 'f':
        Result := Result + 10 + Byte(Ord(S[i])) - Byte(Ord('a'));
      'A' .. 'F':
        Result := Result + 10 + Byte(Ord(S[i])) - Byte(Ord('A'));
    end; // case
  end;
end;

function ExtractHexAsLongWord(const AStr: String): LongWord;
// Reverse is Format('$%4x',[AVal])

var
  S: String;
  len, i: Integer;
  NxtByte: Byte;
  Nxt: PChar;

begin
  Result := 0;
  S := Trim(AStr);
  len := length(S);
  i := 1;
  while (len >= i) and (S[i + ZSISOffset] in ['0' .. '9', 'a' .. 'f',
    'A' .. 'F', '$']) do
    inc(i);
  if i < len then
    SetLength(S, i - 1);
  if S[1 + ZSISOffset] = '$' then
    S := System.Copy(S, 2 + ZSISCopyOffset, i);
  if length(S) mod 2 = 1 then
    S := '0' + S;
  if S = '' then
    S := '00';
  Nxt := PChar(S);

  while Nxt[0] <> Char(0) do
  begin
    Result := Result shl 8;
    NxtByte := ExtractHexByte(Nxt);
    inc(Nxt, 2);
    Result := Result + NxtByte;
  end;
end;

function ExtractReal(const ss: String): Real;
var
  Value: Real;
  ErrorCode: Integer;
var
  s1: String;
begin
  s1 := ss;
  Val(s1, Value, ErrorCode);
  if ErrorCode <> 0 then
  begin
    Delete(s1, ErrorCode, 255);
    Val(s1, Value, ErrorCode);
  end;
  Result := Value;
end;

function ISNumeric(a: Ansichar; AAceptSign: Boolean = False): Boolean;

{$IFDEF NEXTGEN}
Var
  ab: Byte;
begin
  ab := a;
  if AAceptSign then
    Result := ab in [Byte(Ord('0')) .. Byte(Ord('9')), Byte(Ord('.')),
      Byte(Ord('-')), Byte(Ord('+'))]
  else
    Result := ab in [Byte(Ord('0')) .. Byte(Ord('9'))];
{$ELSE}
begin
  if AAceptSign then
    Result := a in ['0' .. '9', '.', '-', '+']
  else
    Result := a in ['0' .. '9'];
{$ENDIF}
end;

function ISNumeric(a: Byte; AAceptSign: Boolean = False): Boolean;
begin
  if AAceptSign then
    Result := a in [Byte(Ord('0')) .. Byte(Ord('9')), Byte(Ord('.')),
      Byte(Ord('-')), Byte(Ord('+'))]
  else
    Result := a in [Byte(Ord('0')) .. Byte(Ord('9'))];
end;

function ISNumeric(a: AnsiString; AAceptSign: Boolean = False)
  : Boolean; overload;
var
  i, lenz: Integer;
begin
  Result := True;
  i := 1 + ZSISOffset;
  lenz := length(a) + ZSISOffset;
  while Result and (i <= lenz) do
  begin
    Result := ISNumeric(a[i], AAceptSign);
    inc(i);
  end;
end;

function ContainsNumeric(const AStg: AnsiString): Boolean;
// AnsiString contains at least one Numeric
var
  i: Integer;
begin
  Result := False;
  i := length(AStg);
  while not Result and (i > 0) do
  begin
    Result := ISNumeric(AStg[i]);
    Dec(i);
  end;
end;

function CompareSeparatedNumbers(const ANumberStrgItem1, ANumberStrgItem2
  : String): Integer;
{ Compares 2004.2.5 and 2004.12.1 and gives 12>2
  Compare returns < 0 if Item1 is less than Item2,
  0 if they are equal and
  > 0 if Item1 is greater than Item2. }
{ sub } function TestNumeric(Achr: PChar): Integer;
  begin
    Result := 0;
    while (Result = 0) and (Achr[0] <> Char(0)) do
    begin
      if Achr[0] in ['0' .. '9'] then
        Result := 1;
      inc(Achr);
    end
  end;

var
  i1, i2: Integer;
  pc1, pc2: PChar;
begin
  Result := 0;
  if (ANumberStrgItem1 = ANumberStrgItem2) then
    Exit;

  pc1 := PChar(ANumberStrgItem1);
  pc2 := PChar(ANumberStrgItem2);

  if length(pc2) = 0 then
    Result := TestNumeric(pc1)
  else if length(pc1) = 0 then
    Result := -TestNumeric(pc2)
  else
    while (Result = 0) and (pc1 <> nil) and (pc2 <> nil) do
    begin
      i1 := ExtractNumber(pc1);
      i2 := ExtractNumber(pc2);
      if i1 < i2 then
        Result := -1
      else if i1 > i2 then
        Result := 1;
    end;
end;

function ContainsReplace(var AString: String; const AFind, AReplace: String;
  AFlags: TReplaceFlags): Boolean;

begin
  if rfIgnoreCase in AFlags then
    Result := Pos(Lowercase(AFind), Lowercase(AString)) > 0
  else
    Result := Pos(AFind, AString) > 0;
  if Result then
    AString := StringReplace(AString, AFind, AReplace, AFlags);
end;

function StringHexToDataBlock(AStr: String; ResultPointer: Pointer;
  ResultSz: Integer): Integer;
// Reverse DataBlockToStringHex
{ Returns Double/Real/Binary Data etc From Hex AnsiString Returns Bytes decoded -1 means buffer overflow }
type
  byte_buffer = record
    one_byte: array [1 .. 256] of Byte;
  end;

  buffer_ptr = ^byte_buffer;

var
  i, iis, Ls: Integer;

begin
  Result := 0;
  Ls := length(AStr);
  i := 1;
  iis := 1;
  if Ls mod 2 > 0 then
    raise Exception.Create('Non Hex AnsiString (odd) in StringHexToDataBlock::"'
      + AStr + '"');

  while iis < Ls do
  begin
    if i <= ResultSz then
    begin
      buffer_ptr(ResultPointer)^.one_byte[i] :=
        ExtractHexByte(@AStr[iis + ZSISOffset]);
      i := i + 1;
      inc(Result);
    end
    else
      Result := -1;
    inc(iis, 2);
  end;

  while i < ResultSz do
  begin
    buffer_ptr(ResultPointer)^.one_byte[i] := 0;
    inc(i);
  end;
end;

function DataBlockToStringHex(BufferPointer: Pointer; Sz: Integer): AnsiString;
// Reverse = StringHexToDataBlock(AStr:AnsiString;ResultPointer: Pointer;ResultSz:Integer);
type
  byte_buffer = record
    one_byte: array [1 .. 256] of Byte;
  end;

  buffer_ptr = ^byte_buffer;

var
  i, ByteVal: Integer;

begin
  Result := '';
  i := 1;
  while i <= Sz do
  begin
    ByteVal := buffer_ptr(BufferPointer)^.one_byte[i];
    Result := Result + IntToHex(ByteVal, 2);
    i := i + 1;
  end;
end;

function PhonicForChar(AC: Ansichar): AnsiString;
Var
  c: Char;
begin
  c := Char(AC);
  case c of
    'a', 'A':
      Result := 'Alpha';
    'b', 'B':
      Result := 'Bravo';
    'c', 'C':
      Result := 'Charlie';
    'd', 'D':
      Result := 'Delta';
    'e', 'E':
      Result := 'Echo';
    'f', 'F':
      Result := 'Foxtrot';
    'g', 'G':
      Result := 'Golf';
    'h', 'H':
      Result := 'Hotel';
    'i', 'I':
      Result := 'India';
    'j', 'J':
      Result := 'Juliet';
    'k', 'K':
      Result := 'Kilo';
    'l', 'L':
      Result := 'Lima';
    'm', 'M':
      Result := 'Mike';
    'n', 'N':
      Result := 'November';
    'o', 'O':
      Result := 'Oscar';
    'p', 'P':
      Result := 'Papa';
    'q', 'Q':
      Result := 'Quebec';
    'r', 'R':
      Result := 'Romeo';
    's', 'S':
      Result := 'Siera';
    't', 'T':
      Result := 'Tango';
    'u', 'U':
      Result := 'Uniform';
    'v', 'V':
      Result := 'Victor';
    'w', 'W':
      Result := 'Whiskey';
    'x', 'X':
      Result := 'Xray';
    'y', 'Y':
      Result := 'Yankie';
    'z', 'Z':
      Result := 'Zulu';
    '0':
      Result := 'Zero';
    '1':
      Result := 'One';
    '2':
      Result := 'Two';
    '3':
      Result := 'Three';
    '4':
      Result := 'Four';
    '5':
      Result := 'Five';
    '6':
      Result := 'Six';
    '7':
      Result := 'Seven';
    '8':
      Result := 'Eight';
    '9':
      Result := 'Nine';
  else
    Result := '';
  end; // Case
end;

function IntOnly(const ss: String): Boolean;
const
  IntSet = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  SignSet = ['-', '+'];
var
  i: Integer;
begin
  Result := True;
  for i := 1 to length(ss) do
    if not(ss[i] in IntSet) then
      if not((i = 1) and (ss[1] in SignSet)) then
        Result := False;
end;

function FrontInteger(const S: String): Integer;
var
  code: Integer;
  sInt: AnsiString;
begin
  Result := 0;
  if S = '' then
    Exit;
  sInt := S;
  Val(sInt, Result, code);
  if code > 0 then
  begin
    sInt := System.Copy(sInt, 1 + ZSISCopyOffset, code - 1);
    Val(sInt, Result, code);
  end;
end;

{$IFDEF FPC}

Function CopyMemory(ADest, ASrc: PAnsiChar; Count: Integer): Integer;
Begin
  // ???
end;

{$ENDIF}
{$IFNDEF NextGen}

function CopyNullStrToPascal(InStr: PAnsiChar; Count: Integer): AnsiString;
begin
  if InStr = nil then
    Result := ''
  else
  begin
    if Count < 0 then
{$IFDEF ISD102T_DELPHI}
      Count := StrLen(InStr);
{$ELSE}
      Count := System.AnsiStrings.StrLen(InStr);
{$ENDIF}
    SetLength(Result, Count);
    if Count > 0 then
      CopyMemory(PAnsiChar(Result), InStr, Count);
  end;
end;

function AssignCopyofNullStr(InStr: PAnsiChar; Count: Integer): PAnsiChar;
var
  CountOfCopy: DWord;
begin
  try
    if InStr = nil then
      Result := nil
    else
    begin
      if Count < 0 then
        CountOfCopy := PAnsiChrLen(InStr)
      else
        CountOfCopy := Count;
{$IFDEF UNICODE}
      Result := AnsiStrAlloc(CountOfCopy + 1);
{$ELSE}
      Result := AnsiStrAlloc(CountOfCopy + 1);
{$ENDIF}
      CopyMemory(Result, InStr, CountOfCopy);
      Result[CountOfCopy] := #0;
      // StrLCopy(Result, Instr, Count);
    end;
  except
    on E: Exception do
      raise Exception.Create('AssignCopyofNullStr ::' + E.Message);
  end;
end;

function StringFixedLength(Input: AnsiString; FixedLength: Integer): AnsiString;
{ Sets a AnsiString to a fixed length by padding with spaces or Truncation }
var
  i: Integer;
begin
  Result := Input;
  if length(Result) >= FixedLength then
    SetLength(Result, FixedLength)
  else
  begin
    SetLength(Result, FixedLength);
    for i := (length(Input) + 1) to FixedLength do
      Result[i] := ' ';
  end;
end;
{$ENDIF}

function StreamAsStringLimitLen(AStrm: TStream;
  AMaxSz, ASoFromEndBegin: Integer): AnsiString;
var
  Sz: int64;
  st: LongInt;
  Rptr: PAnsiChar;
begin
  Sz := AStrm.seek(0, TSeekOrigin.soEnd);
  if (AMaxSz > 20000000) and (Sz > 20000000) then
    raise Exception.Create('StreamAsString 20 Meg Limit');
  if Sz < AMaxSz then
    Result := StreamAsString(AStrm)
  else
  begin
    AStrm.seek(-AMaxSz, TSeekOrigin.soEnd);
{$IFDEF NextGen}
    Result.ReadBytesFrmStrm(AStrm, AMaxSz)
{$ELSE}
    SetLength(Result, AMaxSz);
    Rptr := PAnsiChar(Result);
    st := AMaxSz;
    st := AStrm.Read(Rptr[0], st);
    if st < Sz then
      SetLength(Result, st);
{$ENDIF}
  end;
end;

function StreamAsString(AStrm: TStream): AnsiString;
var
  Sz: int64;
  st: LongInt;
  Rptr: PAnsiChar;
begin
  Sz := AStrm.Size;
  if Sz > 20000000 then
    raise Exception.Create('StreamAsString 20 Meg Limit');
  Try
    AStrm.seek(0, TSeekOrigin.soBeginning);
{$IFDEF NextGen}
    Result.ReadBytesFrmStrm(AStrm, Sz);
{$ELSE}
    SetLength(Result, Sz);
    Rptr := PAnsiChar(Result);
    st := Sz;
    st := AStrm.Read(Rptr[0], st);
    if st < Sz then
      SetLength(Result, st);
{$ENDIF}
  Except
    On E: Exception do
      raise Exception.Create('StreamAsString Error::' + E.Message);
  End;
end;

procedure StringAsStrm(AData: AnsiString; AStm: TStream);
var
  B: PAnsiChar;
begin
  if AStm = nil then
    Exit;

  AStm.seek(0, TSeekOrigin.soBeginning);
{$IFDEF NextGen}
  AData.WriteBytesToStrm(AStm);
{$ELSE}
  B := PAnsiChar(AData);
  AStm.Write(B[0], length(AData));
{$ENDIF}
end;

{$IFDEF UNICODE}

function U8A(Const AUCode: String): AnsiString;
{ String  UTF8 as Ansi }
Var
  Val: UTF8String;
  i: Integer;

begin
  Val := AUCode;
{$IFDEF NextGen}
  Result.length := length(Val);
{$ELSE}
  SetLength(Result, length(Val));
{$ENDIF}
{$IFDEF DelphiXE5}
  for i := Low(Val) to High(Val) do
{$ELSE}
  for i := 1 to length(Val) do
{$ENDIF}
    Result[i] := Val[i];
end;

function A8U(Const AUCode: AnsiString): UTF8String;
{ String Ansi as UTF8 }
{$IFNDEF NextGen}
Var
  i: Integer;
{$ENDIF}
begin
{$IFDEF NextGen}
  Result := AUCode;
{$ELSE}
  SetLength(Result, length(AUCode));
{$IFDEF DelphiXE5}
  for i := Low(AUCode) to High(AUCode) do
{$ELSE}
  for i := 1 to length(AUCode) do
{$ENDIF}
    Result[i] := AUCode[i];
{$ENDIF}
end;
{$ENDIF}

Function ISLastChar(S: AnsiString): Integer; inline;
Begin
{$IFDEF NEXTGEN}
  Result := S.LastChar;
{$ELSE}
  Result := length(S);
{$ENDIF}
End;

{$IFDEF NEXTGEN}

Function AnsiCharPtr(S: AnsiString): PAnsiChar;
Begin
  Result := PAnsiChar(S);
{$ELSE}

Function AnsiCharPtr(Var S: AnsiString): PAnsiChar;
Begin
  Result := @S[1];
{$ENDIF}
End;

Function AsAnsi(AWord: Word): AnsiString; overload;
Var
  a, B: Ansichar;
Begin
  a := Ansichar(AWord Div 256);
  B := Ansichar(AWord Mod 256);
  Result := B + a;
End;

Function AsAnsi(AWord: LongWord; ABytes: Integer = 4): AnsiString; overload;
Var
  High, Low: Word;
Begin
  High := AWord Div 65536;
  Low := AWord mod 65536;
  case ABytes of
    1:
      If (Low > 255) or (High > 0) then
        raise ERangeError.Create('AsAnsi Overload')
      Else
        Result := Ansichar(Low);
    2:
      If (High > 0) then
        raise ERangeError.Create('AsAnsi Overload')
      Else
        Result := AsAnsi(Low);
    3:
      If (High > 255) then
        raise ERangeError.Create('AsAnsi Overload')
      else
        Result := Ansichar(High) + AsAnsi(Low);
    4:
      Result := AsAnsi(Low) + AsAnsi(High);
  else
    Result := '';
  end;
End;

Function AsAnsi(AInt: Integer; ABytes: Integer = 4): AnsiString; overload;
Var
  AsWord: LongWord;
Begin
  AsWord := LongWord(AInt);
  Result := AsAnsi(AsWord, ABytes);
End;

Function PAnsiChrLen(APChar: PAnsiChar): Integer;
begin
{$IFDEF NEXTGEN}
  Result := APChar.length;
{$ELSE}
{$IFDEF ISD102T_DELPHI}
  Result := StrLen(APChar);
{$ELSE}
  Result := System.AnsiStrings.StrLen(APChar);
{$ENDIF}
{$ENDIF}
end;

Function ValFromAnsi(AStr: PAnsiChar; ABytes: Integer): LongWord;
var
  a, B, c, d: Byte;

Begin
  a := Byte(AStr[0]);
  B := Byte(AStr[1]);
  c := Byte(AStr[2]);
  d := Byte(AStr[3]);
  case ABytes of
    1:
      Result := a;
    2:
      Result := a + 256 * B;
    3:
      Result := a + 256 * B + 256 * 256 * c;
    4:
      Result := a + 256 * B + 256 * 256 * c + 256 * 256 * 256 * d;
  else
    Result := 0;
  end;
End;

function FoldUpDirectory(AFileName: String; ASepChar: Char): String;
var
  Part1, Part2: String;
  i: Integer;
  PNxt, PSlash: PChar;
begin
  i := Pos(ASepChar + '..' + ASepChar, AFileName);
  if i = 0 then
  begin
    i := Pos(ASepChar + '.' + ASepChar, AFileName);
    if i > 0 then
      Result := System.Copy(AFileName, 1 + ZSISCopyOffset, i) +
        System.Copy(AFileName, i + 3 + ZSISCopyOffset, 9999)
    else
      Result := AFileName;
  end
  else
  begin
    Part1 := System.Copy(AFileName, 1 + ZSISCopyOffset, i - 1);
    Part2 := System.Copy(AFileName, i + ZSISCopyOffset + 4, 999999);
    PNxt := PChar(Part1);
    PSlash := StrRScan(PNxt, ASepChar);
    if PSlash = nil then
      Result := ASepChar + Part2
    else
    begin
      PSlash[0] := Ansichar(0);
      Part1 := PNxt + ASepChar;
      Result := ConcatToFullFileName(Part1, Part2);
    end
  end;
end;

function ExtractFileNameWeb(const FileName: String): String;
var
  i: Integer;
begin
  i := LastDelimiter('\' + ':' + '/' + '?' + '=', FileName);
  Result := System.Copy(FileName, i + 1 + ZSISCopyOffset, MaxInt);
end;

function ConcatToFullFileName(const Path, AFileNam: String): String;
var
  ConCatChr, LastAnsiChar: Char;
  FileNam: String;
begin
  FileNam := AFileNam;
  Result := FileNam;
  if Path = '' then
    Exit;
  if (Pos(':\', FileNam) > 0) or (Pos(':\', FileNam) > 0) or
    (Pos('\\', FileNam) > 0) then
    Exit;
  // Filename includes root or directory

  ConCatChr := '\';

  if (FileNam = '') then
    Result := Path
  else
  begin
    if Pos('\', Path) > 0 then
      ConCatChr := '\'
    else if Pos('/', Path) > 0 then
      ConCatChr := '/'
    else if Pos('/', FileNam) > 0 then
      ConCatChr := '/'
    else
      ConCatChr := '\';

    if ConCatChr = '/' then
      FileNam := StringReplace(FileNam, '\', ConCatChr, [rfReplaceAll]);
    LastAnsiChar := AnsiLastChar(Path)^;
    if LastAnsiChar <> ConCatChr then
      if FileNam[1 + ZSISOffset] = ConCatChr then
        Result := Path + FileNam
      else
        Result := Path + ConCatChr + FileNam
    else if FileNam[1 + ZSISOffset] = ConCatChr then
      Result := Path + System.Copy(FileNam, 2 + ZSISCopyOffset, 99)
    else // ???
      Result := Path + FileNam;
  end;
  if (Pos(ConCatChr + '..' + ConCatChr, Result) > 0) or
    (Pos(ConCatChr + '.' + ConCatChr, Result) > 0) then
    Result := FoldUpDirectory(Result, ConCatChr);
end;

{$IFNDEF NextGen}

function FindAndInc(ss, AFndText: PAnsiChar; AdditionalPlaces: Integer)
  : PAnsiChar;
var
  len: Integer;
begin
  Result := nil;
  if ss = nil then
    Exit;

{$IFDEF ISD102T_DELPHI}
  Result := StrPos(ss, AFndText);
{$ELSE}
  Result := System.AnsiStrings.StrPos(ss, AFndText);
{$ENDIF}
  len := length(AFndText) + AdditionalPlaces;
  if length(Result) > len then
    inc(Result, len)
  else
    Result := nil;
end;
{$ENDIF}

function ReadLineFrmStream(AStream: TStream): AnsiString;
{$IFDEF NextGen}
Begin
  Result.ReadOneLineFrmStrm(AStream);
{$ELSE}
var
  CurPos, EndPos: int64;
  i, EndSZ: Integer;
  Nxt: Ansichar;
begin
  CurPos := AStream.Position;
  EndPos := AStream.seek(0, soFromEnd);
  AStream.seek(CurPos, soFromBeginning);

  if 256 > EndPos - CurPos then
    EndSZ := Word(EndPos - CurPos)
  else
    EndSZ := 256; // Max Line Size
  SetLength(Result, EndSZ);
  if EndSZ < 1 then
    Exit;

  i := 0;
  AStream.Read(Nxt, 1);
  while not(Nxt in [CR, LF, CRP, LFP]) and (i < EndSZ) do
    try
      inc(i);
      Result[i] := Nxt;
      AStream.Read(Nxt, 1);
    except
      Nxt := CR;
    end;
  SetLength(Result, i);
  while (Nxt in [CR, LF, CRP, LFP]) and (AStream.Position < EndPos) do
    AStream.Read(Nxt, 1);
  CurPos := AStream.Position;
  if CurPos < EndPos then
    AStream.seek(CurPos - 1, soFromBeginning);
{$ENDIF}
end;

procedure WriteLineToStream(AStream: TStream; const AData: AnsiString);
{$IFNDEF NEXTGEN}
var
  S: AnsiString;
{$ENDIF}
begin
  AStream.seek(0, TSeekOrigin.soEnd);
{$IFDEF NextGen}
  AData.WriteLineToStream(AStream);
{$ELSE}
  if AData[length(AData)] in [CR, LF, LFP, CRP] then
    S := AData
  else
    S := AData + CR + LF;
  AStream.Write(S[1], length(S));
{$ENDIF}
end;

function TakeOneLine(var InStr: PAnsiChar; AddTerms: AnsiCharSet;
  ATrimOff: AnsiCharSet): AnsiString;

{ See Old implementation Below }
var
  i: Integer;
  Done: Boolean;
begin
  i := 0;
  Result := '';
  if InStr = nil then
    Exit;
  Done := False;
  while not Done do
  begin
{$IFDEF NEXTGEN}
    if (Byte(InStr[i]) in ([13, 10] + AddTerms)) or (Byte(InStr[i]) = 0) then
    begin
      Result.CopyBytesFromMemory(Pointer(InStr), i);
{$ELSE}
    if (Char(InStr[i]) in ([CR, LF] + AddTerms)) or (InStr[i] = AnsiChr(0)) then
    begin
      Result := Copy(InStr, 0, i);
{$ENDIF}
      Done := True;
    end;
    i := i + 1;
  end;
  if Byte(InStr[i - 1]) = 0 then
    InStr := nil;
  if InStr <> nil then
  begin
{$IFDEF NEXTGEN}
    while (Byte(InStr[i]) in ATrimOff) and (Byte(InStr[i]) <> 0) do
{$ELSE}
    while (InStr[i] in ATrimOff) and (Byte(InStr[i]) <> 0) do
{$ENDIF}
      i := i + 1;
    if Byte(InStr[i]) = 0 then
      InStr := nil
    else
      InStr := Pointer(int64(InStr) + i);
  end;
end;
{ var
  i: integer;
  begin
  i := 0;
  Result := '';
  if InStr = nil then exit;
  while Result = '' do
  begin
  if (InStr[i] in ([CR, LF] + AddTerms)) or
  (InStr[i] = chr(0)) then
  Result := Copy(InStr, 0, i);
  i := i + 1;
  end;
  if InStr[i - 1] = chr(0) then Instr := nil;
  if Instr <> nil then
  begin
  while (InStr[i] in ATrimOff and (Instr[i] <> Chr(0)) do
  i := i + 1;
  if InStr[i] = chr(0) then
  InStr := nil
  else
  InStr := @InStr[i];
  end;
  end;
}
{$IFNDEF NextGen}

function MakeOneLine(InChar: PAnsiChar): PAnsiChar;
var
  S: AnsiString;
begin
  S := '';
  while InChar <> nil do
    S := S + TakeOneLine(InChar, []) + ' ';
  Result := AllocateAndAssignNullString(Trim(S));
end;

function AllocateAndAssignNullString(const ss: AnsiString): PAnsiChar;

begin
  // Could Be Simply StrNew(ss)???????
{$IFDEF UNICODE}
  Result := AnsiStrAlloc(length(ss) + 4);
{$ELSE}
  Result := AnsiStrAlloc(length(ss) + 4);
{$ENDIF}
{$IFDEF ISD102T_DELPHI}
  Result := StrPCopy(Result, ss);
{$ELSE}
  Result := System.AnsiStrings.StrPCopy(Result, ss);
{$ENDIF}
end;

function StrPosFromPStrg(SourceStg: PAnsiChar; const SubStrg: AnsiString)
  : PAnsiChar;
var
  Sub: PAnsiChar;
begin
  Sub := AllocateAndAssignNullString(SubStrg);
{$IFDEF ISD102T_DELPHI}
  Result := StrPos(SourceStg, Sub);
  StrDispose(Sub);
{$ELSE}
  Result := System.AnsiStrings.StrPos(SourceStg, Sub);
  System.AnsiStrings.StrDispose(Sub);
{$ENDIF}
end;

function PosNoCase(const ASubstr: AnsiString; AFullString: AnsiString): Integer;
var
  Substr: AnsiString;
  S: AnsiString;
begin
  if (ASubstr = '') or (AFullString = '') then
  begin
    Result := -1;
    Exit;
  end;
  Substr := Lowercase(ASubstr);
  S := Lowercase(AFullString);
  Result := Pos(Substr, S);
end;

function PosFrmHere(const ASubstr: AnsiString; AFullString: AnsiString;
  AStartAt: Integer; AIgnorCase: Boolean = False): Integer; overload;
{ Pos but Start at offset }

var
  TstStr: AnsiString;
  newpos: Integer;
begin
  Result := 0;
  if AStartAt < 2 then
  begin
    if AIgnorCase then
      Result := PosNoCase(ASubstr, AFullString)
    else
      Result := Pos(ASubstr, AFullString);
    Exit
  end;

  TstStr := Copy(AFullString, AStartAt, length(AFullString));
  if TstStr = '' then
    Exit;

  if AIgnorCase then
    newpos := PosNoCase(ASubstr, TstStr)
  else
    newpos := Pos(ASubstr, TstStr);

  if newpos > 0 then
    Result := newpos + AStartAt - 1;
end;

function StrEquNoCase(const s1, s2: AnsiString): Boolean;
begin
  Result := length(s1) = length(s2);
  if Result then
    Result := PosNoCase(s1, s2) = 1;
end;
{$ENDIF}
{$IFNDEF FPC}

function PosFirstNumeric(Const S: AnsiString): Integer; overload;
{ Returns Pos of First Numeric Char }
Var
  i, Limit: Integer;
  NotDone: Boolean;
Begin
  i := ZSISOffset + 1;
  Limit := ISLastChar(S);
  Result := ZSISOffset;
  NotDone := True;
  while NotDone and (i <= Limit) do
  Begin
{$IFDEF NextGen}
    if Byte(S[i]) in [Ord('0') .. Ord('9')] then
{$ELSE}
    if S[i] in ['0' .. '9'] then
{$ENDIF}
    Begin
      Result := i;
      NotDone := False;
    End
    else
      inc(i);
  End;
End;
{$ENDIF}

function PosFirstNumeric(Const S: String): Integer; overload;
{ Returns Pos of First Numeric Char }
Var
  i, Limit: Integer;
  NotDone: Boolean;
Begin
  i := ZSISOffset + 1;
  Limit := ISLastChar(S);
  Result := ZSISOffset;
  NotDone := True;
  while NotDone and (i <= Limit) do
  Begin
    if S[i] in ['0' .. '9'] then
    Begin
      Result := i;
      NotDone := False;
    End
    else
      inc(i);
  End;
End;

function StarQuestionFilterLength(const Filter: AnsiString): Integer;
{ Returns length of last non filter AnsiChar * ? }
var
  i: Integer;
begin
{$IFDEF NextGen}
  i := Filter.length - 1;
  while (i >= 0) and (Char(Filter[i]) in ['*', '?']) do
{$ELSE}
  i := length(Filter);
  while (i > 0) and (Filter[i] in ['*', '?']) do
{$ENDIF}
    Dec(i);
  Result := i;
end;

{$IFNDEF NextGen}

function StarQuestionMatch(const Filter, Value: AnsiString): Integer;
{ return -1 for Filter less than Value
  return 0 for Filter  Match Value
  return 1 for Filter greater than Value }
// * matches to end while ?Matches one AnsiChar
var
  i, vl, fl: Integer;
begin
  Result := -1;
  vl := length(Value);
  fl := length(Filter);
  if (fl < 1) or (vl < 1) then
    raise Exception.Create('Null AnsiString in StarQuestionMatch');
  i := 1;
  while (i <= vl) and (i <= fl) do
  begin
    case Filter[i] of
      '*':
        begin
          i := vl + fl; // exit
          Result := 0; // match
        end; // case
      '?':
        if i < vl then
        begin
          if i = fl then
            Result := 1; // Longer   aaaa is greater than ???
        end
        else { //i=vl }
          if (vl = fl) or (Filter[i + 1] = '*') then
            Result := 0;
      // else Result:=-1 //Shorter   aa is less than ???
    else // is any other AnsiChar
      if Filter[i] = Value[i] then
      begin // check only if an end
        if i = fl then // else short -1
          if fl = vl then
            Result := 0
          else { if vl > fl then }
            Result := 1;
        if (i = vl) and (vl < fl) then
          if Filter[i + 1] = '*' then
            Result := 0;
      end
      else
      begin
        if Ord(Filter[i]) < Ord(Value[i]) then
          Result := 1; // Else Result:=-1
        i := vl + fl; // exit
      end;
    end; // case
    inc(i);
  end;
end;
{$ENDIF}

function DollarAmount(AValue: Real; var APositive: Boolean): String;
{ Returns $ 400.00 from 400.0000 }
begin
  APositive := AValue > -0.005;
  Result := FormatFloat('"$",0.00', Abs(AValue));
  if not APositive then
    Result := '(' + Result + ')';
end;

function DollarAmount(AValue: Real): String; overload;
var
  Pos: Boolean;
begin
  Result := DollarAmount(AValue, Pos);
end;

function DollarAmountPadded(AValue: Real; ADecPiont: Integer): String;
var
  S: AnsiString;
  Positive: Boolean;
  CurDecPiont: Integer;

begin
  S := DollarAmount(AValue, Positive);
  CurDecPiont := length(S) - 3;
  if not Positive then
  begin
    Dec(CurDecPiont);
  end;
  while CurDecPiont < ADecPiont do
  begin
    S := ' ' + S;
    inc(CurDecPiont);
  end;
  Result := S;
end;

function CentsFromDollarAmount(const ADollarStrg: String): LongInt;
var
  Val: Real;
begin
  Val := RealFromDollarAmount(ADollarStrg);
  Result := Round(Val * 100);
end;

function ConvertToGBFloatFormat(const AFLoatStrg: string;
  var ACurrentSettings: TFormatSettings): string;
var
  DecPointChar, Sep1000Char: Char;
  S: string;
begin
{$IFDEF UNICODE}
  Sep1000Char := ACurrentSettings.ThousandSeparator;
  DecPointChar := ACurrentSettings.DecimalSeparator;
  S := StringReplace(AFLoatStrg, Sep1000Char, ' ', [rfReplaceAll]);
  Result := StringReplace(S, DecPointChar, '.', [rfReplaceAll]);
{$IFDEF FPC}
  ACurrentSettings := FormatSettings; // ('en-GB');
{$ELSE}
  ACurrentSettings := TFormatSettings.Create('en-GB');
{$ENDIF}
{$ENDIF}
end;

function RealFromDollarAmount(const ADollarStrg: String;
  ATestFormat: String = ''): Real;
{ Returns 400.00 from "$400.00 }

{ German  $4.000,199     = $4,000 and    19.9 cents
  High Likelyhood that even with GB Formats Germans and others
  will use , for decimal separator

  Eg   4000,19

}
var
  S, DollarStrg: String;
  i, iSn, IMax, iSl: Integer;
  PointDone: Boolean;
  DecPointChar: Char;
  LocalFormatSettings: TFormatSettings;

begin
{$IFDEF UNICODE}
  // LocalFormatSettings: TFormatSettings;
{$IFDEF FPC}
  LocalFormatSettings := FormatSettings;
{$ELSE}
  if ATestFormat <> '' then
    LocalFormatSettings := TFormatSettings.Create(ATestFormat)
  else
    LocalFormatSettings := TFormatSettings.Create;
{$ENDIF}
  DollarStrg := Trim(ADollarStrg);
  DecPointChar := LocalFormatSettings.DecimalSeparator;
  if DecPointChar <> '.' then
    DollarStrg := ConvertToGBFloatFormat(DollarStrg, LocalFormatSettings);

  S := '';
  PointDone := False;
  IMax := length(DollarStrg);
  if (IMax > 3) and (DollarStrg[IMax - 2 + ZSISOffset] = ',') then
  begin
    DollarStrg := StringReplace(DollarStrg, '.', ',', [rfReplaceAll]);
    DollarStrg[IMax - 2 + ZSISOffset] := '.';
  end;
  if (IMax > 2) and (DollarStrg[IMax - 1 + ZSISOffset] = ',') then
  begin
    DollarStrg := StringReplace(DollarStrg, '.', ',', [rfReplaceAll]);
    DollarStrg[IMax - 1 + ZSISOffset] := '.';
  end;
  for i := 1 to IMax do
    if i <= IMax then
      case DollarStrg[i + ZSISOffset] of
        '0' .. '9':
          S := S + DollarStrg[i + ZSISOffset];
        '.':
          if not PointDone then
          begin
            S := S + DollarStrg[i + ZSISOffset];
            iSl := length(S);
            if (iSl > 2) and (i > 3) and (DollarStrg[i - 3 + ZSISOffset] = ',')
            then
            begin
              S[iSl + ZSISOffset] := S[iSl - 1 + ZSISOffset];
              S[iSl - 1 + ZSISOffset] := S[iSl - 2 + ZSISOffset];
              S[iSl - 2 + ZSISOffset] := '.';
            end;
            PointDone := True;
          end;
        '+', '-':
          if (S = '') then
            S := DollarStrg[i + ZSISOffset];
        '(':
          if S = '' then
          begin
            iSn := Pos(')', DollarStrg);
            if iSn > i + 2 then
            begin
              IMax := iSn - 1;
              S := '-';
            end;
          end;
      end; // case
  if S = '' then
    Result := 0.0
  else // if APositive then
    Result := StrToFloat(S, LocalFormatSettings);
  // else
  // Result := -StrToFloat(s);
{$ENDIF}
end;

function FormatCurrencyStringArray(ARealArray: TArrayOfReal)
  : TArrayOfAnsiStrings;
var
  i, Cols: Integer;
  Pos: Boolean;
begin
  Cols := high(ARealArray) + 1;
  SetLength(Result, Cols);
  for i := 0 to Cols - 1 do
    Result[i] := DollarAmount(ARealArray[i], Pos);
end;

function FormatCurrencyStringArray(ARealArray: TTwoDArrayOfReal)
  : TTwoDArrayOfAnsiString;
var
  i, Rows: Integer;
begin
  Rows := high(ARealArray) + 1;
  SetLength(Result, Rows);
  for i := 0 to Rows - 1 do
    Result[i] := FormatCurrencyStringArray(ARealArray[i]);
end;

function SpaceFill(InString: String; FillLength: Integer): String;
{ Left justfies a AnsiString and pads with space to Fill Length
}
var
  i: Integer;
  localString: String;

begin
  localString := '';
  i := 1;
  while (i <= length(InString)) and (InString[i] = ' ') do
    i := i + 1;
  while (i <= length(InString)) and (length(localString) < FillLength) do
  begin
    localString := localString + InString[i];
    i := i + 1;
  end;
  while length(localString) < FillLength do
    localString := localString + ' ';
  SpaceFill := localString;
end;

function Compact(InString: String; Front, Tail: Boolean): String;
{ Compacts the front and or tail of a AnsiString removing spaces
  eg              '     yyyyyy    '
  with tail       '     yyyyyy'
  with head       'yyyyyy    '
  with head and tail 'yyyyyy'
}
var
  i, SpaceCount: Integer;
  localString: String;

begin
  localString := '';
  i := 1;
  if Front then
    while (i <= length(InString)) and (InString[i] = ' ') do
      i := i + 1;
  SpaceCount := 0;
  while (i <= length(InString)) do
  begin
    if InString[i] <> ' ' then
    begin
      while SpaceCount > 0 do
      begin
        localString := localString + ' ';
        SpaceCount := SpaceCount - 1;
      end;
      localString := localString + InString[i];
    end
    else
      SpaceCount := SpaceCount + 1;
    i := i + 1;
  end;
  if not Tail then
    while SpaceCount > 0 do
    begin
      localString := localString + ' ';
      SpaceCount := SpaceCount - 1;
    end;
  Compact := localString;
end;

function ExpandYear(AYear: Integer; FutureWindow: Integer): Integer;
Var
  Year, Month, Day: Word;
Begin
  if (AYear > 99) then
    Result := AYear
  Else
  Begin

    DecodeDate(now, Year, Month, Day);

    if AYear > ((Year + FutureWindow) mod 100) then { go back a century }
      Result := ((Year + FutureWindow - 100) div 100) * 100 + AYear
    else
      Result := ((Year + FutureWindow) div 100) * 100 + AYear;
  End;
End;

function ExpandYear(const S: String; FutureWindow: Integer): Integer;
var
  i, errorpos: Integer;
  sl: String;
begin
  if length(S) > 2 then
    sl := System.Copy(Trim(S), 1 + ZSISCopyOffset, 2)
  else
    sl := S;
  Val(sl, i, errorpos);
  if (errorpos = 0) or ((errorpos > 1)) then
    Result := ExpandYear(i, FutureWindow);
end;

function MonthAsInt(const sm: String): Integer;
begin
  Result := 0;
  if length(sm) < 3 then
    Exit;
  case sm[1] of
    'J', 'j':
      case sm[3] of
        'N', 'n':
          case sm[2] of
            'A', 'a':
              Result := 1;
          else
            Result := 6;
          end; // case
      else
        Result := 7;
      end; // case
    'M', 'm':
      case sm[3] of
        'Y', 'y':
          Result := 5;
      else
        Result := 3;
      end; // case
    'D', 'd':
      Result := 12;
    'A', 'a':
      case sm[2] of
        'P', 'p':
          Result := 4;
      else
        Result := 8;
      end; // case
    'F', 'f':
      Result := 2;
    'S', 's':
      Result := 9;
    'O', 'o':
      Result := 10;
    'N', 'n':
      Result := 11;
  else
    Result := 0;
  end; // case
end;

Function IsTxtToYear(ATxt: String): Integer;
Begin
  // function ExpandYear(const S: String; FutureWindow: Integer): Integer;
  Result := StrToIntDef(ATxt, 0);
  if Result = 0 then
    Exit;
  if Result < 100 then
    if Result < (CurrentYear - 1990) then
      Result := Result + 2000
    else
      Result := Result + 1900;

  if Result > 2100 then
    raise Exception.Create('Error IsTxtToYear ' + ATxt);
End;

Function ISDecodeDashYears(ADateTxt: String;
  Out AYearFrm, AYearTo: Integer): Boolean;
Var
  ss: string;
  Sz: Integer;

begin
  Result := False;
  ss := TrimWthAll(Numeric(ADateTxt, ['-', '.', '/', '_', ' ']), []);
  Sz := length(ss);
  if Sz < 2 then
    Exit;
  if Sz > 9 then
    Exit;

  AYearFrm := 0;
  AYearTo := 0;
  Try
    case Sz of
      0, 1:
        Exit;
      2:
        AYearFrm := IsTxtToYear(ss); // 58 >> 1968  20 >>2020
      3:
        Exit;
      4:
        AYearFrm := IsTxtToYear(ss); // 1945
      5:
        if ss[2 + FirstStrCharNo] in ['/', '-', ' '] then
        begin
          AYearFrm := IsTxtToYear(ss[FirstStrCharNo] + ss[FirstStrCharNo + 1]);
          AYearTo := IsTxtToYear(ss[FirstStrCharNo + 3] +
            ss[FirstStrCharNo + 4]);
        end // 47-67
        else
          Exit;
      6:
        Exit;
      7:
        if ss[4 + FirstStrCharNo] in ['/', '-', ' '] then
        begin
          AYearFrm := IsTxtToYear(ss[FirstStrCharNo] + ss[FirstStrCharNo + 1] +
            ss[FirstStrCharNo + 2] + ss[FirstStrCharNo + 3]);
          AYearTo := IsTxtToYear(ss[FirstStrCharNo + 5] +
            ss[FirstStrCharNo + 6]);
        end // 1947-67
        else
          Exit;

      8:
        Exit;
      9:
        if ADateTxt[4 + FirstStrCharNo] in ['/', '-', ' '] then
        begin
          AYearFrm := IsTxtToYear(ADateTxt[FirstStrCharNo + 1] +
            ADateTxt[FirstStrCharNo + 2] + ADateTxt[FirstStrCharNo + 3]);
          AYearTo := IsTxtToYear(ADateTxt[FirstStrCharNo + 5] +
            ADateTxt[FirstStrCharNo + 6] + ADateTxt[FirstStrCharNo + 7] +
            ADateTxt[FirstStrCharNo + 8]);
        end // 1967-2016
        else
          Exit;
    else
      Exit
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function ISStrToDateRecovery(const ADate: String;
  ALatestDate, ADefault: TDateTime): TDateTime;
// 3/4/76  1986

var
  // DateArray: TArrayOfUnicodeStrings;
  DSep: Char;
  NewTst: String;
  S: String;
  Year, Month, Day: Word;
  NumericArray: TArrayOfUnicodeStrings;
  Col1, Col2, Col3: Integer;
begin
  S := TrimWthAll(ADate, []);
  NewTst := '';
  Result := StrToDateDef(S, 0.0);

  if Result < 0.1 then
  Begin
    if length(S) > 3 then
    Begin
      DSep := FormatSettings.DateSeparator;
      if Pos(DSep, S) < 1 then
        if Pos('/', S) > 1 then
          NewTst := StringReplace(S, '/', DSep, [rfReplaceAll])
        else if Pos('-', S) > 1 then
          NewTst := StringReplace(S, '-', DSep, [rfReplaceAll])
        else if Pos('.', S) > 1 then
          NewTst := StringReplace(S, '.', DSep, [rfReplaceAll])
        else if Pos(' ', S) > 1 then
          NewTst := StringReplace(S, ' ', DSep, [rfReplaceAll]);
      if NewTst <> '' then
      Begin
        Result := StrToDateDef(NewTst, ADefault);
        if Result = ADefault then // try other orders
        Begin
          NewTst := Numeric(NewTst, [DSep]);
          NumericArray := GetArrayFromString(NewTst, DSep, True, True, True);
          If length(NumericArray) = 3 then
          begin // 2009/06/05   05/06/2009 dd/mm/yyyy yyyy/mm/dd
            Col1 := StrToIntDef(NumericArray[0], 0);
            Col2 := StrToIntDef(NumericArray[1], 0);
            Col3 := StrToIntDef(NumericArray[2], 0);
            Year := 0;
            Month := 0;
            Day := 0;
            if (Col2 > 0) and (Col3 > 0) then
              Case Col1 of
                0:
                  ;
                1 .. 31:
                  if (Col3 > 31) then
                  Begin
                    if (Col2 < 12) then
                    Begin
                      Year := Col3;
                      Month := Col2;
                      Day := Col1;
                    end
                    else
                    Begin
                      Year := Col3;
                      Month := Col1;
                      Day := Col2;
                    end;
                  end
                  else // 12/   /31
                    if (Col2 > 12) and (Col2 < 32) then
                    Begin
                      Year := Col3;
                      Month := Col2;
                      Day := Col1;
                    end;
              else
                Begin
                  Year := Col1;
                  if (Col3 > 0) and (Col2 > 0) and (Col2 < 32) then
                    if (Col3 < 31) then
                    Begin
                      Month := Col2;
                      Day := Col3; // yyyy mm dd
                      If Col2 > 12 then
                        if Col3 > 12 then
                          Year := 0
                        else
                        Begin
                          Month := Col3; // yyyy dd mm
                          Day := Col2;
                        End;
                    End
                    else
                      Year := 0;
                end;
              End;
            if Year > 0 then
            Begin
              if Year < 100 then
                Year := ExpandYear(Year, 0);
              Result := EncodeDate(Year, Month, Day);
            End;
          End;
        End;

      End;
    End;

    if Result < 0.1 then
      if ISNumeric(S, False) then
        Try
          Year := IsTxtToYear(S);
          if Year > 1 then
            Result := EncodeDate(Year, 1, 1);
        Except
        End;
  End;

  if Result > 0.1 then
  Begin
    if (Result < 101) then
    Begin
      DecodeDate(Result, Year, Month, Day);
      Year := ExpandYear(Year, 0);
      Result := EncodeDate(Year, Month, Day);
    End;
  End;

  if ALatestDate > 0.1 then
    While (Result > ALatestDate) do
    begin
      DecodeDate(Result, Year, Month, Day);
      Year := Year - 100;
      Result := EncodeDate(Year, Month, Day);
    end;

  if Result > 0.1 then
    Exit;

  Result := ADefault;
end;

function StringToDateTimeRecovery(const S: String): TDateTime;
// Still very basic
// 25/05/2001 24:12

var
  TimeArray: TArrayOfUnicodeStrings;

  { sub } function ExtractTime(AStuf: String): String;
  var
    Dt: TArrayOfUnicodeStrings;
  begin
    Result := AStuf;
    GetFields(TimeArray, AStuf, ':', True, True);
    if length(TimeArray) > 0 then
      if Pos(' ', TimeArray[0]) > 1 then
      begin
        GetFields(Dt, TimeArray[0], ' ', True, True);
        TimeArray[0] := Dt[1];
        Result := Dt[0];
      end
      else if Pos(' ', TimeArray[high(TimeArray)]) > 1 then
      begin
        GetFields(Dt, TimeArray[high(TimeArray)], ' ', True, True);
        TimeArray[high(TimeArray)] := Dt[0];
        Result := Dt[high(Dt)];
        if high(Dt) > 1 then
          TimeArray[high(TimeArray)] := Dt[0] + Dt[1];
      end;
  end;

var
  DateArray: TArrayOfUnicodeStrings;
  DResult, TResult: TDateTime;
begin
  // Result := 0.0;
  DResult := 0.0;
  TResult := 0.0;
  TimeArray := nil;
  try
    GetFields(DateArray, S, '/', True, True);
    if length(DateArray) > 0 then
    begin
      if Pos(':', DateArray[0]) > 1 then
        DateArray[0] := ExtractTime(DateArray[0])
      else if Pos(':', DateArray[high(DateArray)]) > 1 then
        DateArray[high(DateArray)] := ExtractTime(DateArray[high(DateArray)])
    end
    else
      ExtractTime(S);
    if length(DateArray) > 2 then
      DResult := EncodeDate(StrToInt(DateArray[2]), StrToInt(DateArray[1]),
        StrToInt(DateArray[0]));
    try
      if length(TimeArray) > 2 then
        TResult := StrToTime(TimeArray[0] + ':' + TimeArray[1] + ':' +
          TimeArray[3])
      else if length(TimeArray) > 1 then
        TResult := StrToTime(TimeArray[0] + ':' + TimeArray[1]);
    except
      TResult := 0.0;
    end;
    Result := TResult + DResult;
  except
    Result := 0.0;
  end;
end;

function DateAsFinancialYear(ADate: TDateTime): String;
var
  Year, Month, Day: Word;

begin
  try
    DecodeDate(ADate, Year, Month, Day);
    if Month < 7 then
      Dec(Year);
  except
    Year := 1900;
  end;
  Result := IntToStr(Year) + '/' + IntToStr(Year + 1);
end;

{$IFDEF MSWINDOWS}

function DateTimeToInternetDateTime(Time: TDateTime): String;
{ Result strg    Wdy, DD-Mon-YYYY HH:MM:SS GMT }
{ Returns AnsiString from Delphi DateTime }

var
  UTCTime: TDateTime;
{$IFDEF UNICODE}
{$IFDEF FPC}
  Rslt: UnicodeString;
{$ELSE}
  Rslt: String;
{$ENDIF}
{$ELSE}
  Rslt: AnsiString;
{$ENDIF}
begin
  UTCTime := Time - UtcOffsetMinutes / 60 / 24;
  DateTimeToString(Rslt, 'ddd dd-mmm-yyyy hh:nn:ss', UTCTime);
  Result := Rslt + ' GMT';
end;
{$ENDIF}

function TimeToAgeString(AAge: TDateTime;
  ALimitAgeInYears: Integer = 0): String;
var
  Years, Months: Real;
  yy, mm: Integer;
begin
  Result := '';
  if AAge < 0.1 then
    Exit;
  Years := AAge / 365.25;
  if (ALimitAgeInYears > 0) and (Years > ALimitAgeInYears) then
    Exit;
  if Years > 106 then
    Exit;

  yy := Trunc(Years);
  Months := Years - yy;
  if (Years < 18) then
    mm := Round(Months * 12)
  else
    mm := 0;
  if mm > 11 then
  begin
    mm := 0;
    inc(yy);
  end;

  Result := IntToStr(yy) + ' Yrs';
  if mm > 0 then
    Result := Result + ' ' + IntToStr(mm) + ' Mths';
end;

function InternetDateTime(const SourceStg: PChar): TDateTime;
var
  Fs: String;
  NextChr: PChar;
begin
  try
    NextChr := SourceStg;
    Fs := FieldSep(NextChr, ','); // Wdy,   Forget
    Fs := FieldSep(NextChr, ' '); // DD-Mon-YYYY
    if length(Fs) = 11 then
      Result := EncodeDate(StrToInt(Fs[1] + Fs[2] + Fs[3] + Fs[4]),
        MonthAsInt(Fs[4] + Fs[5] + Fs[6]), StrToInt(Fs[1] + Fs[2]))
    else
      Result := 0.0;
    if Result > 0 then
    begin
      Fs := FieldSep(NextChr, ' '); // HH:MM:SS
      Result := Result + EncodeTime(StrToInt(Fs[1] + Fs[2]),
        StrToInt(Fs[4] + Fs[5]), StrToInt(Fs[7] + Fs[8]), 0);
    end;
  except
    Result := 0.0;
  end;
end;

function InsertCharAfterChars(const AStr: String;
  ATestChars: UniCodeCharSet = [',', '.', ':', ';']; AInsert: Char = ' ';
  AMakeSingle: Boolean = False): String;
var
  i, j, Sz, ResultLength: Integer;
  ExtSet: UniCodeCharSet;

  { sub after var }
  procedure AddChar(AAChar: Char);
  begin
    if j > ResultLength then
    begin
      inc(ResultLength, 20);
      SetLength(Result, ResultLength);
    end;
    Result[j] := AAChar;
    inc(j);
  end;

begin
  ExtSet := ATestChars + [AInsert];
  Sz := length(AStr);
  ResultLength := Sz + 20;
  SetLength(Result, ResultLength);
{$IFDEF NEXTGEN}
  i := 0;
  j := 0;
  Dec(Sz);
  while i <= Sz do
{$ELSE}
  i := 1;
  j := 1;
  while i <= Sz do
{$ENDIF}
  begin
    if (AMakeSingle and (AStr[i] in ExtSet)) then
      if ((i > 0) and (j > 1) and (Result[j - 1] = AInsert)) then
        Dec(j);
    if AStr[i] in ATestChars then
    begin
      AddChar(AStr[i]);
      if (i < Sz - 1) and (AStr[i + 1] <> AInsert) then
        AddChar(' ');
    end
    else
      AddChar(AStr[i]);
    inc(i);
  end;
{$IFDEF NEXTGEN}
  SetLength(Result, j);
{$ELSE}
  SetLength(Result, j - 1);
{$ENDIF}
end;

function ExtractInitials(const ss: String): String;
var
  i: Integer;
  S: String;
begin
  S := Capitalize(ss);
  Result := '';
  for i := 1 to length(S) do
    if S[i] in ['A' .. 'Z'] then
      Result := Result + S[i];
end;

function LwrCaseIS(AChar: WideChar): WideChar;
var
  R: Word;
  Tst: Word;
const
  Mask: Word = $F0;
  Mask2: Word = $F;
begin
  R := Ord(AChar);
  Tst := (R and Mask);
  Tst := Tst shr 4;
  Result := AChar;
  case Tst of
    $4:
      if (Mask2 and R) > 0 then
        Result := WideChar(R + $20);
    $5:
      if (Mask2 and R) < 11 then
        Result := WideChar(R + $20);
    $A:
      if (Mask2 and R) < 11 then
        Result := WideChar(R + $20);
    $9:
      if (Mask2 and R) > 0 then
        Result := WideChar(R + $20);
  end;
end;

function LwrCaseIS(const ATxt: UnicodeString): UnicodeString;
var
  i, Sz: Integer;
  Rslt: UnicodeString;
begin
  Sz := length(ATxt);
  SetLength(Rslt, Sz);
{$IFDEF NextGen}
  for i := 0 to Sz - 1 do
{$ELSE}
  for i := 1 to Sz do
{$ENDIF}
    Rslt[i] := LwrCaseIS(WideChar(ATxt[i]));
  Result := Rslt;
end;

function UprCaseIS(AChar: WideChar): WideChar;
var
  R: Word;
  Tst: Word;
const
  Mask: Word = $F0;
  Mask2: Word = $F;
begin
  R := Ord(AChar);
  Tst := (R and Mask);
  Tst := Tst shr 4;
  Result := AChar;
  case Tst of
    $6:
      if (Mask2 and R) > 0 then
        Result := WideChar(R - $20);
    $7:
      if (Mask2 and R) < 11 then
        Result := WideChar(R - $20);
    $C:
      if (Mask2 and R) < 11 then
        Result := WideChar(R - $20);
    $B:
      if (Mask2 and R) > 0 then
        Result := WideChar(R - $20);
  end;
end;

function UprCaseIS(const ATxt: UnicodeString): UnicodeString;
var
  i, Sz: Integer;
  Rslt: UnicodeString;
begin
  Sz := length(ATxt);
  SetLength(Rslt, Sz);
{$IFDEF NextGen}
  for i := 0 to Sz - 1 do
{$ELSE}
  for i := 1 to Sz do
{$ENDIF}
    Rslt[i] := UprCaseIS(WideChar(ATxt[i]));
  Result := Rslt;
end;

function Capitalize(S: String): String;
{ Returns 'Innova Solutions' from 'INNOVA solutions' }

  procedure UpperChar(var ch: Char);
  begin
    if ch in ['a' .. 'z'] then
      ch := Char(Ord(ch) - 32);
  end;

var
  i, TotLen: Integer;
begin
  if length(S) = 0 then
    Result := ''
  else
    Result := Lowercase(Trim(S));

  if Result = '' then
    Exit;

  UpperChar(Result[1 + ZSISOffset]);

  TotLen := length(Result) - 1;
  for i := 1 to TotLen do
    if Result[i + ZSISOffset] in [' ', ',', '.', ':', ';', '-', '''', '(',
      '[', '{'] then
      UpperChar(Result[i + 1 + ZSISOffset])
    else { //McAlpine }
      if (Result[i + ZSISOffset] = 'c') and (i > 1) and
        (Result[i - 1 + ZSISOffset] = 'M') then
        UpperChar(Result[i + 1 + ZSISOffset]);
  // else { //MacAlpine }
  // if (Result[i + Offset] = 'c') and (i > 2) and ((TotLen-i)>3)
  // (Result[i - 2 + Offset] = 'M') then
  // UpperChar(Result[i + 1 + Offset]);

end;

function Abbreviate(S: String): String;
{ Returns 'Inn Sol' from 'INNOVA solutions' }
var
  i, j, wl, len: Integer;
begin
  Result := Capitalize(Trim(S));
  if Result = '' then
    Exit;

  len := length(Result);
  i := 2;
  j := 2;
  wl := 1;
  while i <= len do
  begin
    case Result[i] of
      'A' .. 'Z':
        begin
          wl := 1;
          Result[j] := Result[i];
          inc(j);
        end;
      'a' .. 'z':
        if wl < 3 then
        begin
          Result[j] := Result[i];
          inc(j);
          inc(wl);
        end;
      '0' .. '9':
        begin
          Result[j] := Result[i];
          inc(j);
          inc(wl);
        end;
      ' ', ',', '.', ':', ';', '-', '''':
        begin
          Result[j] := Result[i];
          inc(j);
          inc(wl);
        end;
    else
      begin
      end;
    end; // case
    inc(i);
  end;
  SetLength(Result, j - 1);
end;

function HonerificIndex(S: String; AGuess: Boolean): Integer;

{ http://englishplus.com/grammar/00000053.htm
  http://englishplus.com/grammar/abbrcont.htm
  Mr. Master Mrs. Miss Ms.
  Mlle. Mme. M. Messrs. (Plural of Mr. or M.)
  Mmes. (Plural of Mrs., Ms., Mme.) }
{
  (Sister)   Br.(Brother)   St.

  Political: Pres.    Supt.    Rep.    Sen.    Gov.   Amb.    Treas.  Sec.

  Military: Pvt.   Cpl.   Spec.   Sgt.   Ens.   Adm.    Maj.    Capt.
  Cmdr. (or Cdr.)    Lt.   Lt. Col.   Col.    Gen.

  );


  There are a number of common titles of position and rank which are abbreviated. Except for Dr., they are only used before a person's full name (i.e., at least first and last names); otherwise, the title is spelled out.

  Correct: Sgt. Alvin York   Fr. Robert Drinan
  Prof. William Alfred    Dr. Milton Friedman

  Incorrect: Sgt. York    Fr. Drinan    Prof. Alfred
  (Abbreviated without first name or initial.)

  Correct: Sergeant York    Father Drinan
  Professor Alfred   Dr. Friedman
  (Dr. is OK to abbreviate with a last name only.)

  Practice for internal correspondence within military commands may differ.

  Abbreviations of position and rank include the following.

  Professional: Dr.    Atty.   Prof. Hon.

  Religious: Rev.    Fr.   Msgr.   Sr.(Sister)   Br.(Brother)   St.

  Political: Pres.    Supt.    Rep.    Sen.    Gov.   Amb.    Treas.  Sec.

  Military: Pvt.   Cpl.   Spec.   Sgt.   Ens.   Adm.    Maj.    Capt.
  Cmdr. (or Cdr.)    Lt.   Lt. Col.   Col.    Gen.
}
var
  i, Hc: Integer;
  ss, ssc: String;
begin
  Result := -1;
  ss := Trim(Uppercase(StringReplace(S, '.', '', [rfReplaceAll])));
  if ss = '' then
    Exit;

  ssc := Capitalize(ss);
  Hc := high(CNameHonerificArray);
  i := -1;
  while (Result < 0) and (i < Hc) do
  begin
    inc(i);
    if (ss = CNameHonerificArray[i]) or (ssc = CNameHonerificArrayFull[i]) then
      Result := i;
  end;
  if (Result < 0) and AGuess then
    case ss[1] of
      'A':
        Result := HonerificIndex('ADM', False);
      'B':
        Result := HonerificIndex('BR', False);
      'D':
        Result := HonerificIndex('DR', False);
      'E':
        Result := HonerificIndex('ENS', False);
      'I':
        Result := HonerificIndex('ING', False);
      'H', 'T':
        Result := HonerificIndex('HON', False);
      'R':
        Result := HonerificIndex('REV', False);
      'F':
        Result := HonerificIndex('FR', False);
      'S':
        Result := HonerificIndex('SR', False);
      'P':
        if length(ss) > 2 then // professor,Pastor,Private
          case ss[3] of
            'O':
              Result := HonerificIndex('PROF', False);
            'V', 'I':
              Result := HonerificIndex('PRVT', False);
            'S':
              Result := HonerificIndex('PASTOR', False);
          end;
      'L':
        begin
          i := length(ss);
          if (i > 12) and (ss[13] = 'C') then
            Result := HonerificIndex('LT COL', False)
          else if (i > 2) then
            case ss[3] of
              ' ':
                Result := HonerificIndex('LT COL', False);
              'E':
                Result := HonerificIndex('LT', False);
            end
          else
            Result := HonerificIndex('LT', False);
        end;
      'C':
        begin
          i := length(ss);
          if (i > 3) then
            case ss[4] of
              'M', 'R':
                Result := HonerificIndex('CMDR', False);
              'O':
                Result := HonerificIndex('COL', False);
              'P':
                case ss[2] of
                  'A':
                    Result := HonerificIndex('CPT', False);
                  'O':
                    Result := HonerificIndex('CPL', False);
                end;
            end
          else if i > 2 then
            case ss[3] of
              'D':
                Result := HonerificIndex('CMDR', False);
              'L':
                case ss[2] of
                  'O':
                    Result := HonerificIndex('COL', False);
                  'P':
                    Result := HonerificIndex('CPL', False);
                end;
              'T':
                Result := HonerificIndex('CPT', False);
            end;
        end;
      'M':
        begin
          i := length(ss);
          if (i > 6) then
            case ss[7] of
              'S':
                Result := HonerificIndex('MESSRS', False);
              'I':
                Result := HonerificIndex('MLLE', False);
              'E':
                Result := HonerificIndex('MMES', False);
              'N':
                Result := HonerificIndex('MSGR', False);
            end
            { 'Mister', 'Master', 'Missus', 'Miss', 'Ms.', 'Mademoiselle ', 'Madame.', 'M.', 'Misters', 'Mesdames',
              'Monsignor', 'Major' }
          else if i > 5 then
            case ss[6] of
              'R':
                case ss[2] of
                  'A':
                    Result := HonerificIndex('MASTER', False);
                  'I':
                    Result := HonerificIndex('MR', False);
                end;
              'S':
                Result := HonerificIndex('MRS', False);
              'O':
                Result := HonerificIndex('MLLE', False);
              'E':
                Result := HonerificIndex('MME', False);
            end
          else if i > 2 then
            case ss[3] of
              'L':
                Result := HonerificIndex('MLLE', False);
              'E':
                Result := HonerificIndex('MME', False);
              'G':
                Result := HonerificIndex('MSGR', False);
              'J':
                Result := HonerificIndex('MAJ', False);
            end;
        end;
    end;
end;

function FormalAddressHonerfic(S: String): String;
var
  i: Integer;
begin
  i := HonerificIndex(S, True);
  if i < 0 then
    Result := ''
  else
    Result := CNameHonerificArrayFormalAddress[i];
end;

function DbHonerific(S: String): String;
{ Returns MRS, MR, MS }
var
  i: Integer;
begin
  i := HonerificIndex(S, True);
  if i < 0 then
    Result := ''
  else
    Result := CNameHonerificArray[i];
end;

function HonerificIsMale(S: String): Boolean;
var
  i: Integer;
begin
  i := HonerificIndex(S, False);
  Result := i in HonIsMale;
end;

{$IFNDEF FPC}

procedure ReConstructName(const AFullName: AnsiString;
  var FirstInitial: Ansichar; var Honerific, GivenName, FamilyName: AnsiString);
Var
  LFirstInitial: Char;
  LHonerific, LGivenName, LFamilyName: String;
begin
  LFirstInitial := Char(FirstInitial);
  LHonerific := Honerific;
  LGivenName := GivenName;
  LFamilyName := FamilyName;
  ReConstructName(AFullName, LFirstInitial, LHonerific, LGivenName,
    LFamilyName);
  FirstInitial := Ansichar(LFirstInitial);
  Honerific := LHonerific;
  GivenName := LGivenName;
  FamilyName := LFamilyName;
end;
{$ENDIF}

procedure ReConstructName(const AFullName: String; var FirstInitial: Char;
  var Honerific, GivenName, FamilyName: String);
{ Returns Var MRS + J + SURNAME }
{ sub } function TestInitial(const S: String): String;
  begin
    Result := '';
{$IFDEF NEXTGEN}
    case S.length of
      1:
        Result := S[0];
      2:
        if S[2] in ['.', ','] then
          Result := S[0];
    end;
{$ELSE}
    case length(S) of
      1:
        Result := S[1];
      2:
        if S[2] in ['.', ','] then
          Result := S[1];
    end;
{$ENDIF}
  end;

var
  NextChar: PChar;
  S, ss, SSave: String;
  hi: Integer;
begin
  if AFullName = '' then
    Exit;
  SSave := Uppercase(Trim(AFullName));
  NextChar := PChar(SSave);
  S := FieldSep(NextChar, ' ');
  hi := HonerificIndex(S, False);
  if hi < 0 then
  begin
    NextChar := PChar(SSave);
    Honerific := '';
  end
  else
  begin
    Honerific := CNameHonerificArray[hi];
    S := FieldSep(NextChar, ' ');
  end;
  ss := TestInitial(S);
  if ss <> '' then
{$IFDEF NEXTGEN}
{$IFDEF ISD104S_DELPHI}
    FirstInitial := PChar(ss)[0]
{$ELSE}
    FirstInitial := ss[0]
{$ENDIF}
{$ELSE}
      FirstInitial := ss[1]
{$ENDIF}
  else
  Begin
    FirstInitial := ' ';
    If (StrComp(PChar(S), NextChar) <> 0) then
      GivenName := S;
  end;
  NextChar := StrRScan(PChar(SSave), ' ');
  if NextChar = nil then
    FamilyName := Trim(SSave)
  else
    FamilyName := PChar(@NextChar[1]);
end;

function MatchRoadStreetQual(ATestValue: AnsiString): Integer;
{ Returns -1 or index to best match values in CAveRoadQual,CAveRoadFullQual }
var
  i, TestLen: Integer;
  TestValue2: AnsiString;
begin
  Result := -1;
  i := -1;
  ATestValue := ' ' + Uppercase(Trim(ATestValue));
  if ATestValue = '' then
    Exit;
  TestValue2 := ' ' + Capitalize(ATestValue);
  while (Result = -1) and (i < high(CAveRoadQual)) do
  begin
    inc(i);
    if (ATestValue = CAveRoadQual[i]) or (TestValue2 = CAveRoadFullQual[i]) then
      Result := i;
  end;
  if (Result = -1) then
  begin
    TestLen := length(Trim(ATestValue));
    if TestLen > 2 then
      Result := MatchRoadStreetQual(ATestValue[1]);
  end;
end;

function MatchStrAveTypes(const AStrAve1, AStrAve2: AnsiString): Boolean;
var
  i1, i2: Integer;
begin
  i1 := MatchRoadStreet(AStrAve1, True);
  i2 := MatchRoadStreet(AStrAve2, True);
  Result := (i1 = i2) or (i1 = -1) or (i2 = -1) or
    (CAveRoadFullArray[i1] = CAveRoadFullArray[i2]);
end;

function MatchRoadStreet(ATestValue: String; ABestFit: Boolean): Integer;
{ Returns -1 or index to best match values in CAveRoadArray,CAveRoadFullArray }

var
  i, TestLen: Integer;
  TestValue2: String;
begin
  Result := -1;
  i := -1;
  ATestValue := Uppercase(Trim(ATestValue));
  TestValue2 := Capitalize(Trim(ATestValue));
  while (Result = -1) and (i < high(CAveRoadArray)) do
  begin
    inc(i);
    if (ATestValue = CAveRoadArray[i]) or (TestValue2 = CAveRoadFullArray[i])
    then
      Result := i;
  end;
  if (Result = -1) and ABestFit then
  begin
    TestLen := length(ATestValue);
    if TestLen > 1 then
      case ATestValue[1 + ZSISOffset] of
        'A':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'V':
                Result := MatchRoadStreet('AV');
              'L':
                Result := MatchRoadStreet('AL');
              'R':
                Result := MatchRoadStreet('ARC');
            end; // case
        'B':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'N', 'E':
                Result := MatchRoadStreet('BND');
              'L', 'O':
                Result := MatchRoadStreet('BLV');
            end; // case
        'C':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'T', 'O':
                Result := MatchRoadStreet('CT');
              'I':
                if TestLen < 4 then
                  Result := MatchRoadStreet('CIR')
                else
                  case ATestValue[4 + ZSISOffset] of
                    'T':
                      Result := MatchRoadStreet('CIRT');
                    'C':
                      if TestLen > 4 then
                        case ATestValue[5 + ZSISOffset] of
                          'U':
                            Result := MatchRoadStreet('CIRT');
                          'L':
                            Result := MatchRoadStreet('CIR');
                        end // case
                  end; // case
            else
              Result := MatchRoadStreet('C' + ATestValue[2 + ZSISOffset]);
            end;
        // case
        'D':
          Result := MatchRoadStreet('DR');
        'E':
          Result := MatchRoadStreet('ESP');
        'F':
          Result := MatchRoadStreet('FWY');
        'G':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'L':
                Result := MatchRoadStreet('GL');
              'A', 'D':
                Result := MatchRoadStreet('GDN');
              'R':
                if TestLen > 2 then
                  // GR already matched
                  case ATestValue[3 + ZSISOffset] of
                    'O':
                      if TestLen > 3 then
                        case ATestValue[4 + ZSISOffset] of
                          'V':
                            Result := MatchRoadStreet('GR');
                          'U':
                            Result := MatchRoadStreet('GRND');
                        end;
                    // case
                    'A':
                      Result := MatchRoadStreet('GRA');
                    'N':
                      Result := MatchRoadStreet('GRND');
                  end; // case
            end; // case Result := MatchRoadStreet('GV');
        'H':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'I', 'W':
                Result := MatchRoadStreet('HWY');
              'E', 'T':
                Result := MatchRoadStreet('HTS');
            end; // case
        'L':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'A':
                Result := MatchRoadStreet('LA');
              'I':
                Result := MatchRoadStreet('LINK');
            end; // case
        'M':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'O', 'T':
                Result := MatchRoadStreet('MT');
              'E', 'W':
                Result := MatchRoadStreet('MWS');
            end; // case
        'P':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'L':
                Result := MatchRoadStreet('PL');
              'D', 'A':
                Result := MatchRoadStreet('PDE');
              'R':
                Result := MatchRoadStreet('PRM');
              'T', 'O':
                Result := MatchRoadStreet('PT');
            end; // case
        'R':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'I':
                Result := MatchRoadStreet('RISE');
              'D':
                Result := MatchRoadStreet('RD');
              'N':
                Result := MatchRoadStreet('RND');
              'T', 'E':
                Result := MatchRoadStreet('RT');
              'O':
                if TestLen > 2 then
                  case ATestValue[3 + ZSISOffset] of
                    'A':
                      Result := MatchRoadStreet('RD');
                    'U':
                      Result := MatchRoadStreet('RND');
                  end; // case
            end; // case
        'S':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'T':
                Result := MatchRoadStreet('ST');
              'Q':
                Result := MatchRoadStreet('SQ');
              'L':
                Result := MatchRoadStreet('SL');
            end; // case

        'T':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'R':
                Result := MatchRoadStreet('TR');
              'C', 'E':
                Result := MatchRoadStreet('TCE');
            end; // case
        'W':
          if TestLen > 1 then
            case ATestValue[2 + ZSISOffset] of
              'L', 'A':
                Result := MatchRoadStreet('WLK');
              'Y':
                Result := MatchRoadStreet('WYD');
            end; // case
      end; // case
  end;
end;

function MatchStreetNo(AStrNo1, AStrNo2: AnsiString): Boolean;
var
  UnitNo1, StrNo1, UnitNo2, StrNo2, AddTxt: AnsiString;
begin
  ReconstructUnitStreetNo(AStrNo1, AddTxt, UnitNo1, StrNo1);
  ReconstructUnitStreetNo(AStrNo2, AddTxt, UnitNo2, StrNo2);
  Result := (UnitNo1 = UnitNo2) and (StrNo1 = StrNo2);
end;

procedure ReconstructUnitStreetNo(const ATotalNo: AnsiString;
  var AText, AUnitNo, AStrNo: AnsiString);
{ Returns Var FLAT + 1 + 48A  from   FLAT 1/48A }
{ Returns Var MARLAND HOUSE + '' + 48A  from   Marland House, 48A }
var
  i, snol: Integer;
  UnitNo, StrNo, ExistingNo, TextBit: String;
  IsNonChar: Boolean;

begin
  // IsNum:=false;
  IsNonChar := False;
  ExistingNo := Uppercase(Trim(ATotalNo));
  UnitNo := '';
  StrNo := '';
  TextBit := '';
  snol := length(ExistingNo);
  for i := snol downto 1 do
  begin
    if IsNonChar then
    begin
      if (ExistingNo[i + ZSISOffset] in ['0' .. '9']) and (TextBit = '') then
        UnitNo := ExistingNo[i + ZSISOffset] + UnitNo
      else if ExistingNo[i + ZSISOffset] in ['A' .. 'Z', '0' .. '9', '-', ' ']
      then
        TextBit := ExistingNo[i + ZSISOffset] + TextBit;
      if TextBit = ' ' then
        TextBit := '';
    end
    else if ExistingNo[i + ZSISOffset] in ['A' .. 'Z', '0' .. '9', '-'] then
    begin
      StrNo := ExistingNo[i + ZSISOffset] + StrNo;
    end
    else if i < snol then
      IsNonChar := True
    else
      Dec(snol);
  end;
  AUnitNo := UnitNo;
  AStrNo := StrNo;
  AText := Trim(TextBit);
end;

procedure ReConstructAddressLine1(const AStrAd1: String;
  var AStrNo, AStreetName, AStrAve: String);
{ Returns Var FLAT 1/48A + THISWAY + RD }
var
  WordArray: TArrayOfUnicodeStrings;
  SSave: String;
  i, iq, Sz, FirstNum: Integer;
  Done: Boolean;
begin
  AStrNo := '';
  AStreetName := '';
  AStrAve := '';
  SetLength(WordArray, 0);
  // Stop Warning
  if AStrAd1 = '' then
    Exit;
  try
    SSave := Uppercase(Trim(AStrAd1));
    Sz := length(SSave);
    while SSave[Sz] in ['.', ',', ';', ':'] do
      Dec(Sz);
    SetLength(SSave, Sz);

    WordArray := GetArrayFromString(SSave, ' ', False, True);
    Sz := high(WordArray);
    while WordArray[Sz] = '' do
      Dec(Sz);

    Sz := high(WordArray);
    i := MatchRoadStreet(WordArray[Sz]);
    if (i < 0) then
    begin
      if Sz > 0 then
        i := MatchRoadStreet(WordArray[Sz - 1]);
      if i > -1 then
      begin
        iq := MatchRoadStreetQual(WordArray[Sz]);
        if iq > -1 then
        begin
          AStrAve := Trim(CAveRoadArray[i]) + ' ' + Trim(CAveRoadQual[iq]);
          Dec(Sz, 2);
        end
        else
          AStrAve := '';
      end
    end
    else
    begin
      AStrAve := Trim(CAveRoadArray[i]);
      Dec(Sz);
    end;

    FirstNum := Sz;
    Done := False;
    while not Done and (FirstNum > 0) do
    begin
      Dec(FirstNum);
      // Must leave at least Street Name    45th St
      Done := ContainsNumeric(WordArray[FirstNum]);
    end;
    if not Done then
      Dec(FirstNum);
    if FirstNum >= 0 then
      for i := 0 to FirstNum do
        AStrNo := AStrNo + WordArray[i] + ' ';
    AStrNo := Trim(AStrNo);
    for i := FirstNum + 1 to Sz do
      AStreetName := AStreetName + WordArray[i] + ' ';
    AStreetName := Trim(AStreetName);
  except
  end;
end;

function ReconstructPhoneNumber(const AStd, APhoneNumber: String): String;
{ Sub } function InsertPhoneSpaces(Ano: String): String;
  var
    len: Integer;
  begin
    Result := Ano;
    len := length(Ano);
    if IntOnly(Ano) and (len > 7) then
      Result := Trim(System.Copy(Ano, 1 + ZSISCopyOffset, 4) + ' ' +
        System.Copy(Ano, 5 + ZSISCopyOffset, len));
  end;

begin
  if AStd <> '' then
    Result := '(' + Trim(AStd) + ') ' + InsertPhoneSpaces(APhoneNumber)
  else
    Result := InsertPhoneSpaces(APhoneNumber);
end;

procedure DeconstructPhoneNumber(const Value: AnsiString;
  var Std, PhoneNumber: AnsiString);
var
  i, j: Integer;
  LValue, LPhoneNumber, LStd: String;
begin
  LValue := Trim(Value);
  PhoneNumber := LValue;
  Std := '';
  if Value = '' then
    Exit;

  i := Pos('(', LValue);
  j := Pos(')', LValue);

  if (j > 1) and (i = 1) and (i < (j - 1)) then
  begin
    LStd := Copy(LValue, i + 1, j - i - 1);
    LPhoneNumber := Copy(LValue, j + 1, 256);
  end;
  NumericOnly(LPhoneNumber, []);
  NumericOnly(LStd, []);
  PhoneNumber := LPhoneNumber;
  Std := LStd;
end;

{$IFNDEF FPC}

procedure ReConstructAddressLine1(const AStrAd1: String;
  var AStrNo, AStreetName, AStrAve: AnsiString);
{ Returns Var FLAT 1/48A + THISWAY + RD }
var
  WordArray: TArrayOfAnsiStrings;
  SSave: AnsiString;
  i, iq, Sz, FirstNum: Integer;
  Done: Boolean;
begin
  AStrNo := '';
  AStreetName := '';
  AStrAve := '';
  SetLength(WordArray, 0);
  // Stop Warning
  if AStrAd1 = '' then
    Exit;
  try
    SSave := Uppercase(Trim(AStrAd1));
{$IFDEF NEXTGEN}
    Sz := SSave.High;
    while (Sz > 0) and (Char(SSave[Sz]) in ['.', ',', ';', ':']) do
      Dec(Sz);
    SSave.length := Sz + 1;
{$ELSE}
    Sz := length(SSave);
    while (Sz > 1) and (SSave[Sz] in ['.', ',', ';', ':']) do
      Dec(Sz);
    SetLength(SSave, Sz);
{$ENDIF}
    WordArray := GetArrayFromString(SSave, Ansichar(' '), False, True);
    Sz := high(WordArray);
    while WordArray[Sz] = '' do
      Dec(Sz);

    Sz := high(WordArray);
    i := MatchRoadStreet(WordArray[Sz]);
    if (i < 0) then
    begin
      if Sz > 0 then
        i := MatchRoadStreet(WordArray[Sz - 1]);
      if i > -1 then
      begin
        iq := MatchRoadStreetQual(WordArray[Sz]);
        if iq > -1 then
        begin
          AStrAve := Trim(CAveRoadArray[i]) + ' ' + Trim(CAveRoadQual[iq]);
          Dec(Sz, 2);
        end
        else
          AStrAve := '';
      end
    end
    else
    begin
      AStrAve := Trim(CAveRoadArray[i]);
      Dec(Sz);
    end;

    FirstNum := Sz;
    Done := False;
    while not Done and (FirstNum > 0) do
    begin
      Dec(FirstNum);
      // Must leave at least Street Name    45th St
      Done := ContainsNumeric(WordArray[FirstNum]);
    end;
    if not Done then
      Dec(FirstNum);
    if FirstNum >= 0 then
      for i := 0 to FirstNum do
        AStrNo := AStrNo + WordArray[i] + ' ';
    AStrNo := Trim(AStrNo);
    for i := FirstNum + 1 to Sz do
      AStreetName := AStreetName + WordArray[i] + ' ';
    AStreetName := Trim(AStreetName);
  except
  end;
end;

procedure ReconstructFullAddress(const AAddressInFull: AnsiString;
  var AAddressSt, ASuburb, AZipCode: AnsiString);
{ Returns Var "unit 2 14 Globe St"+"MOUNT WAVERLY" + "3195" (Or NY56789  ????) }
var
  WordArray: TArrayOfAnsiStrings;
  // ZipArray: TArrayOfAnsiStrings;
  Sz, i, EndAd1: Integer;
  TstLine2: AnsiString;
  LocalAddressInFull: AnsiString;
  { sub after var }
  procedure NextComma;
  var
    Last: Integer;
    Done: Boolean;
  begin
    Done := False;
    while not Done do
    begin
      Dec(EndAd1);
      if EndAd1 >= 0 then
      begin
{$IFDEF NEXTGEN}
        Last := WordArray[EndAd1].High;
        Done := (Char(WordArray[EndAd1][Last]) in [',', ':', ';', '.']);
{$ELSE}
        Last := length(WordArray[EndAd1]);
        Done := (WordArray[EndAd1][Last] in [',', ':', ';', '.']);
{$ENDIF}
      end;
      if EndAd1 < 1 then
        Done := True;
    end;
  end;

begin
  LocalAddressInFull := InsertCharAfterChars(AAddressInFull, [',', ';'],
    ' ', True);
  WordArray := GetArrayFromString(LocalAddressInFull, Ansichar(' '),
    False, True);
  Sz := high(WordArray);
  if Sz < 1 then
    Exit;

  EndAd1 := Sz;
  NextComma;
  if (AZipCode = '') and (EndAd1 = Sz - 1) then
    NextComma;

  if (Sz > 2) and (EndAd1 = Sz - 2) and (length(WordArray[Sz - 1]) = 2) then
    NextComma; // NY 56765

  if (EndAd1 < 2) and (EndAd1 > -1) then
    for i := EndAd1 to Sz - 1 do
    begin
      if MatchRoadStreet(WordArray[i]) > -1 then
        EndAd1 := i;
    end;

  TstLine2 := '';
  for i := EndAd1 + 1 to Sz do
    TstLine2 := Trim(TstLine2 + ' ' + WordArray[i]);
  if (AZipCode <> '') and (Pos(AZipCode, TstLine2) < 1) then
    if (TstLine2 <> '') and (TstLine2[length(TstLine2)] <> ',') then
      TstLine2 := Trim(TstLine2 + ', ' + AZipCode)
    else
      TstLine2 := Trim(TstLine2 + ' ' + AZipCode);

  AAddressSt := '';
  for i := 0 to EndAd1 do
    AAddressSt := AAddressSt + WordArray[i] + ' ';

  AAddressSt := Trim(AAddressSt);
  ReConstructAddressLine2(TstLine2, ASuburb, AZipCode);
  i := Pos(AnsiString('  '), ASuburb);
  if i > 0 then
  begin
    AAddressSt := AAddressSt + ' ' + Trim(Copy(ASuburb, 1, i));
    ASuburb := Trim(Copy(ASuburb, i + 1, 256));
  end;
{$IFDEF NEXTGEN}
  i := AAddressSt.High;
{$ELSE}
  i := length(AAddressSt);
{$ENDIF}
  while (i > 1) and (Char(AAddressSt[i]) in [',', '.', ';', ':']) do
  begin
    Dec(i);
{$IFDEF NEXTGEN}
    AAddressSt.length := i + 1;
{$ELSE}
    SetLength(AAddressSt, i);
{$ENDIF}
  end;
end;

procedure ReConstructAddressLine2(const strAd2: AnsiString;
  var City, ZipCode: AnsiString);

{ Returns Var MOUNT WAVERLY + 3195 (Or NY56789  ????) }
{ Sub } function TestZipCode(StrZip: AnsiString): AnsiString;
  var
    i, snol: Integer;
  begin
    Result := '';
{$IFDEF NEXTGEN}
    snol := StrZip.length;
{$ELSE}
    snol := length(StrZip);
{$ENDIF}
    if not(snol in [4, 7, 8]) then
      Exit;

    i := 0;
    while i < snol do
    begin
      inc(i);
      if ISNumeric(StrZip[i + ZSISOffset]) then
        case snol of
          7, 8:
            if i < 2 then
              Exit;
        end
      else if (snol < 6) or ((i + ZSISOffset) > 3) then
        // NY 34567, CA34567 ????
        Exit
      else
        case snol of
          4:
            Exit;
          7:
            if i = 3 then
              Exit;
          8:
            if StrZip[3 + ZSISOffset] <> ' ' then
              Exit;
        end;

    end;
    case snol of
      7:
        Result := Uppercase(StrZip);
      8:
        if StrZip[3 + ZSISOffset] = ' ' then
          Result := Uppercase(StrZip[1 + ZSISOffset] + StrZip[2 + ZSISOffset]) +
            Copy(StrZip, 4, 5);
      4:
        Result := StrZip;

    end;

  end;

var
  WordArray: TArrayOfAnsiStrings;
  S, SSave: AnsiString;
  Sz: Integer;
  i: Integer;
begin
  City := '';
  ZipCode := '';
  SetLength(WordArray, 0);
  // Stop Warning
  try
    if strAd2 = '' then
      Exit;
    WordArray := GetArrayFromString(AnsiString(Uppercase(strAd2)),
      Ansichar(','), False, True);
    Sz := high(WordArray);

    S := '';
    if Sz >= 0 then
      S := TestZipCode(WordArray[Sz]);
    if S <> '' then
      for i := 0 to Sz - 1 do
        City := City + WordArray[i]
    else
    begin
      SSave := Uppercase(StringReplace(Trim(strAd2), ',', ' ', [rfReplaceAll]));
      WordArray := GetArrayFromString(SSave, Ansichar(' '), False, False);
      Sz := high(WordArray);
      if Sz < 1 then
        S := ''
      else
        S := TestZipCode(WordArray[Sz]);
      if (S = '') and (Sz > 2) then
      begin
        S := TestZipCode(WordArray[Sz - 1] + ' ' + WordArray[Sz]);
        if S <> '' then
          Dec(Sz);
      end;
      if S = '' then
        inc(Sz); // No Zip

      for i := 0 to Sz - 1 do
        City := City + WordArray[i] + ' ';
    end;
    ZipCode := S;
    City := Trim(City);
  except
  end;
end;

procedure DeconstructPhoneNumber(const Value: String;
  var Std, PhoneNumber: String);
var
  i, j: Integer;
  LValue: String;
begin
  LValue := Trim(Value);
  PhoneNumber := LValue;
  Std := '';
  if Value = '' then
    Exit;

  i := Pos('(', LValue);
  j := Pos(')', LValue);

  if (j > 1) and (i = 1) and (i < (j - 1)) then
  begin
    Std := System.Copy(LValue, i + 1 + ZSISCopyOffset, j - i - 1);
    PhoneNumber := System.Copy(LValue, j + 1 + ZSISCopyOffset, 256);
  end;
  NumericOnly(PhoneNumber, []);
  NumericOnly(Std, []);
end;
{$ENDIF}

procedure ReconstructFullAddress(const AAddressInFull: String;
  var AAddressSt, ASuburb, AZipCode: String);
{ Returns Var "unit 2 14 Globe St"+"MOUNT WAVERLY" + "3195" (Or NY56789  ????) }
var
  WordArray: TArrayOfUnicodeStrings;
  // ZipArray: TArrayOfAnsiStrings;
  Sz, i, EndAd1: Integer;
  TstLine2: String;
  LocalAddressInFull: String;
  { sub after var }
  procedure NextComma;
  var
    Last: Integer;
    Done: Boolean;
  begin
    Done := False;
    while not Done do
    begin
      Dec(EndAd1);
      if EndAd1 >= 0 then
      begin
{$IFDEF NEXTGEN}
        Last := length(WordArray[EndAd1]) - 1;
{$ELSE}
        Last := length(WordArray[EndAd1]);
{$ENDIF}
        Done := (WordArray[EndAd1][Last] in [',', ':', ';', '.']);
      end;
      if EndAd1 < 1 then
        Done := True;
    end;
  end;

begin
  LocalAddressInFull := InsertCharAfterChars(AAddressInFull, [',', ';'],
    ' ', True);
  WordArray := GetArrayFromString(LocalAddressInFull, ' ', False, True);
  Sz := high(WordArray);
  if Sz < 1 then
    Exit;

  EndAd1 := Sz;
  NextComma;
  if (AZipCode = '') and (EndAd1 = Sz - 1) then
    NextComma;

  if (Sz > 2) and (EndAd1 = Sz - 2) and (length(WordArray[Sz - 1]) = 2) then
    NextComma; // NY 56765

  if (EndAd1 < 2) and (EndAd1 > -1) then
    for i := EndAd1 to Sz - 1 do
    begin
      if MatchRoadStreet(WordArray[i]) > -1 then
        EndAd1 := i;
    end;

  TstLine2 := '';
  for i := EndAd1 + 1 to Sz do
    TstLine2 := Trim(TstLine2 + ' ' + WordArray[i]);
  if (AZipCode <> '') and (Pos(AZipCode, TstLine2) < 1) then
    if (TstLine2 <> '') and (TstLine2[length(TstLine2)] <> ',') then
      TstLine2 := Trim(TstLine2 + ', ' + AZipCode)
    else
      TstLine2 := Trim(TstLine2 + ' ' + AZipCode);

  AAddressSt := '';
  for i := 0 to EndAd1 do
    AAddressSt := AAddressSt + WordArray[i] + ' ';

  AAddressSt := Trim(AAddressSt);
  ReConstructAddressLine2(TstLine2, ASuburb, AZipCode);
  i := Pos('  ', ASuburb);
  if i > 0 then
  begin
    AAddressSt := AAddressSt + ' ' +
      Trim(System.Copy(ASuburb, 1 + ZSISCopyOffset, i));
    ASuburb := Trim(System.Copy(ASuburb, i + 1 + ZSISCopyOffset, 256));
  end;
  i := length(AAddressSt);
  while (i > 1) and (AAddressSt[i + ZSISOffset] in [',', '.', ';', ':']) do
  begin
    Dec(i);
    SetLength(AAddressSt, i);
  end;
end;

procedure ReConstructAddressLine2(const strAd2: String;
  var City, ZipCode: String);

{ Returns Var MOUNT WAVERLY + 3195 (Or NY56789  ????) }
{ Sub } function TestZipCode(StrZip: String): String;
  var
    i, snol: Integer;
  begin
    Result := '';
    snol := length(StrZip);
    if not(snol in [4, 7, 8]) then
      Exit;

    i := 0;
    while i < snol do
    begin
      inc(i);
      if ISNumeric(StrZip[i + ZSISOffset]) then
        case snol of
          7, 8:
            if i < 2 then
              Exit;
        end
      else if (snol < 6) or ((i + ZSISOffset) > 3) then
        // NY 34567, CA34567 ????
        Exit
      else
        case snol of
          4:
            Exit;
          7:
            if i = 3 then
              Exit;
          8:
            if StrZip[3 + ZSISOffset] <> ' ' then
              Exit;
        end;

    end;
    case snol of
      7:
        Result := Uppercase(StrZip);
      8:
        if StrZip[3 + ZSISOffset] = ' ' then
          Result := Uppercase(StrZip[1 + ZSISOffset] + StrZip[2 + ZSISOffset]) +
            System.Copy(StrZip, 4 + ZSISCopyOffset, 5);
      4:
        Result := StrZip;

    end;

  end;

var
  WordArray: TArrayOfUnicodeStrings;
  S, SSave: String;
  Sz: Integer;
  i: Integer;
begin
  City := '';
  ZipCode := '';
  SetLength(WordArray, 0);
  // Stop Warning
  try
    if strAd2 = '' then
      Exit;
    WordArray := GetArrayFromString(Uppercase(strAd2), Char(','), False, True);
    Sz := high(WordArray);

    S := '';
    if Sz >= 0 then
      S := TestZipCode(WordArray[Sz]);
    if S <> '' then
      for i := 0 to Sz - 1 do
        City := City + WordArray[i]
    else
    begin
      SSave := Uppercase(StringReplace(Trim(strAd2), ',', ' ', [rfReplaceAll]));
      WordArray := GetArrayFromString(SSave, ' ', False, False);
      Sz := high(WordArray);
      if Sz < 1 then
        S := ''
      else
        S := TestZipCode(WordArray[Sz]);
      if (S = '') and (Sz > 2) then
      begin
        S := TestZipCode(WordArray[Sz - 1] + ' ' + WordArray[Sz]);
        if S <> '' then
          Dec(Sz);
      end;
      if S = '' then
        inc(Sz); // No Zip

      for i := 0 to Sz - 1 do
        City := City + WordArray[i] + ' ';
    end;
    ZipCode := S;
    City := Trim(City);
  except
  end;
end;

function PosSet(const S: String; PosChrSet: UniCodeCharSet): Integer;
var
  i, j: Integer;
begin
  Result := 0;
  j := length(S) + 1;
  i := 1;
  while (Result = 0) and (i < j) do
    if S[i] in PosChrSet then
      Result := i
    else
      i := i + 1;
end;

function ListCompareAsciiOrder(List: TStringList;
  Index1, Index2: Integer): Integer;
begin
  Result := (CompareStr(List[Index1], List[Index2]));
end;

procedure WrapListText(ListOfSS: TStrings; WrapChrSet: UniCodeCharSet;
  WrapLength: Byte);
var
  S: String;
  TempList: TStringList;
  i, j, sl: Integer;
begin
  TempList := nil;
  try
    TempList := TStringList.Create;
    TempList.addStrings(ListOfSS);
    ListOfSS.Clear;
    for i := 0 to TempList.Count - 1 do
    begin
      S := TempList[i];
      sl := length(S);
      while sl > WrapLength do
      begin
        j := WrapLength;
        while (j > 0) and not(S[j] in WrapChrSet) do
          j := j - 1;
        if j = 0 then
          j := WrapLength;
        ListOfSS.Add(System.Copy(S, 1 + ZSISCopyOffset, j));
        S := System.Copy(S, j + 1 + ZSISCopyOffset, sl);
        sl := length(S);
      end;
      ListOfSS.Add(S);
    end; // for i
  finally
    TempList.free;
  end;
end;

procedure CopyStringsOnly(var ResultList: Pointer; SourceList: TStrings);
var
  i: Integer;
begin
  if not(SourceList is TStrings) then
    Exit;
  if ResultList = nil then
    ResultList := SourceList.Create;
  if not(TObject(ResultList) is TStrings) then
    Exit;
  for i := 0 to SourceList.Count - 1 do
    TStrings(ResultList).Add(SourceList[i]);
end;

procedure TrimLeadingAndTrailingBlankLines(AListOfLines: TStrings);
var
  i: Integer;
begin
  while (AListOfLines.Count > 0) and (Trim(AListOfLines[0]) = '') do
    AListOfLines.Delete(0);
  i := AListOfLines.Count;
  Dec(i);
  if i > 0 then
    while (Trim(AListOfLines[i]) = '') do
      Dec(i);
  inc(i);
  while (AListOfLines.Count > i) do
    AListOfLines.Delete(i);

end;

{$IFNDEF NextGen}

Function HTMLBrArray(Const AListTxt: AnsiString): TArrayOfAnsiStrings;
{ <ul>
  Description: outer metropolitan.<br />Location: south-eastern Melbourne; it includes the suburbs of Aspendale, Aspendale Gardens, Bonbeach, Braeside, Carrum, Chelsea, Chelsea Heights, Dandenong South, Edithvale, Keysborough, Mordialloc, Parkdale, Patterson Lakes and Waterways, and parts of Carrum Downs, Lyndhurst, Mentone, Noble Park and Skye.<br />Area: 166 sq km.<br />Electors enrolled: 105 756 (at 2.7.16).<br />Industries: light manufacturing.<br />State electorates: Isaacs includes parts of the Victorian Legislative Assembly electorates of Carrum, Dandenong, Keysborough, Mordialloc and Sandringham.
  </ul>
}
Var
  ListText, NxtItem, TagTxt: AnsiString;
  NxtChr { , StartChr } : PAnsiChar;
  Sz, i: Integer;
begin
  SetLength(Result, 0);
  if AListTxt = '' then
    Exit;

  Sz := 5;
  i := 0;
  SetLength(Result, Sz);
  NxtChr := PAnsiChar(AListTxt);

  ListText := HTMLExtractTagContents(NxtChr, TagTxt, 'ul');

  if ListText = '' then
  begin
    NxtChr := PAnsiChar(AListTxt);
    ListText := HTMLExtractTagContents(NxtChr, TagTxt, 'ol');
  end;
  if ListText = '' then
    ListText := AListTxt;
  ListText := TrimWthAll(ListText, ['<', '>']);
  NxtChr := PAnsiChar(ListText);
  // StartChr := NxtChr;

  while NxtChr <> '' do
  begin
    NxtItem := HTMLExtractToNextTagByType(NxtChr, 'br');
    Result[i] := NxtItem;
    inc(i);
    if i >= Sz then
    begin
      inc(Sz, 5);
      SetLength(Result, Sz);
    end;
  end;
  SetLength(Result, i);
end;
{$ENDIF}
{$IFNDEF NextGen}

Function HTMLListItemArray(Const AListTxt: AnsiString): TArrayOfAnsiStrings;
{ <ul>
  <li>Member, ALP from 1979.</li><li>ALP Assistant General Secretary (NSW) 1989-95.</li><li>Delegate, ALP State Conference (NSW) 1983-2008.</li><li>President, NSW Young Labor 1985-87.</li><li>Delegate, ALP National Conference 1986, 1990, 1991, 1994, 1998, 2000, 2002, 2004, 2007, 2009, 2011 and 2015.</li><li>Member, National Organisational Review Committee 1990-94.</li><li>Secretary, Warren Branch 1991-99.</li><li>President, Grayndler Federal Electorate Council 1992-96.</li><li>Member, ALP National Executive from 2004.</li><li>Member, ALP National Executive Committee from 2004.</li>
  </ul>
  or
  <li>Member, ALP from 1979.</li><li>ALP Assistant General Secretary (NSW) 1989-95.</li><li>Delegate, ALP State Conference (NSW) 1983-2008.</li><li>President, NSW Young Labor 1985-87.</li><li>Delegate, ALP National Conference 1986, 1990, 1991, 1994, 1998, 2000, 2002, 2004, 2007, 2009, 2011 and 2015.</li><li>Member, National Organisational Review Committee 1990-94.</li><li>Secretary, Warren Branch 1991-99.</li><li>President, Grayndler Federal Electorate Council 1992-96.</li><li>Member, ALP National Executive from 2004.</li><li>Member, ALP National Executive Committee from 2004.</li>
}
Var
  ListText, NxtItem, TagTxt: AnsiString;
  NxtChr: PAnsiChar;
  Sz, i: Integer;
begin
  SetLength(Result, 0);
  if AListTxt = '' then
    Exit;

  Sz := 0;
  i := 0;
  NxtChr := PAnsiChar(AListTxt);
  ListText := HTMLExtractTagContents(NxtChr, TagTxt, 'ul');
  if ListText = '' then
  begin
    NxtChr := PAnsiChar(AListTxt);
    ListText := HTMLExtractTagContents(NxtChr, TagTxt, 'ol');
  end;
  if ListText = '' then
    ListText := AListTxt;
  NxtChr := PAnsiChar(ListText);

  NxtItem := HTMLExtractTagContents(NxtChr, TagTxt, 'li');
  while NxtItem <> '' do
  begin
    inc(i);
    if i > Sz then
    begin
      inc(Sz, 5);
      SetLength(Result, Sz);
    end;
    Result[i - 1] := NxtItem;
    NxtItem := HTMLExtractTagContents(NxtChr, TagTxt, 'li');
  end;
  SetLength(Result, i);
end;
{$ENDIF}
{$IFNDEF NextGen}

Function HtmlExtractHeaders(AData: AnsiString; ALvl: Ansichar; ATrim: Boolean)
  : TArrayOfAnsiStrings;
{ Resturns all Headers of Lvl }
Var
  i, Sz: Integer;
  ThisVal, TagTxt, Hdr: AnsiString;
  NxtChr: PAnsiChar;
Begin
  i := 0;
  Sz := -1;
  Hdr := 'h' + ALvl;
  if AData <> '' then
  begin
    NxtChr := PAnsiChar(AData);
    while NxtChr <> nil do
    begin
      ThisVal := HTMLExtractTagContents(NxtChr, TagTxt, Hdr);
      if ThisVal <> '' then
      Begin
        ThisVal := ReplaceBreakWithCR(ThisVal);
        ThisVal := ReplaceSpecialHTMLChars(ThisVal);
        if ATrim then
        Begin
          ThisVal := Trim(ReplaceControlWithSpace(ThisVal));
          ThisVal := StringReplace(ThisVal, '  ', ' ', [rfReplaceAll]);
        End;
        if i >= Sz then
        Begin
          inc(Sz, 5);
          SetLength(Result, Sz);
        End;
      End;
      Result[i] := ThisVal;
      inc(i);
    end;
  end;
  SetLength(Result, i);
End;
{$ENDIF}
{$IFNDEF NextGen}

function HTMLExtractNextTab(var CurrentLoc: PAnsiChar): AnsiString;
const
  BufSize = 300;
var
  IChar, OChar, Nested: PAnsiChar;
  TagStart, TagEnd: Ansichar;
  Tag: array [0 .. BufSize] of Ansichar;
  S: AnsiString;
{$IFDEF DEBUG}
  ds, ds1, ds2: string;
{$ENDIF}
begin
  Result := '';
  if CurrentLoc = nil then
    Exit;
  TagStart := Ansichar('<');
  TagEnd := Ansichar('>');

{$IFDEF ISD102T_DELPHI}
  IChar := StrScan(CurrentLoc, TagStart);
  if IChar <> nil then
    OChar := StrScan(IChar, TagEnd)
{$ELSE}
  IChar := System.AnsiStrings.StrScan(CurrentLoc, TagStart);
  if IChar <> nil then
    OChar := System.AnsiStrings.StrScan(IChar, TagEnd)
{$ENDIF}
  else
    OChar := nil;
  CurrentLoc := OChar;
  if OChar = nil then
    Exit;
{$IFDEF DEBUG}
  ds1 := OChar;
  ds2 := IChar;
{$ENDIF}
{$IFDEF ISD102T_DELPHI}
  Nested := StrScan(IChar + 1, TagStart);
{$ELSE}
  Nested := System.AnsiStrings.StrScan(IChar + 1, TagStart);
{$ENDIF}
{$IFDEF DEBUG}
  ds := Nested;
  ds2 := IChar;
{$ENDIF}
  while (Nested <> nil) and (OChar <> nil) and (OChar > Nested) do
  // raise Exception.Create('Nested HTML Tags Not Supported in HTMLExtactNextTab');
  begin
    S := HTMLExtractNextTab(Nested);
    Nested := OChar + 1;
{$IFDEF ISD102T_DELPHI}
    OChar := StrScan(Nested, TagEnd);
    Nested := StrScan(Nested, TagStart);
{$ELSE}
{$IFDEF ISD102T_DELPHI}
    OChar := StrScan(Nested, TagEnd);
    Nested := StrScan(Nested, TagStart);
{$ELSE}
    OChar := System.AnsiStrings.StrScan(Nested, TagEnd);
    Nested := System.AnsiStrings.StrScan(Nested, TagStart);
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
    ds := Nested;
    ds2 := OChar;
{$ENDIF}
  end;
  // Try
  if OChar = nil then
    Exit;

{$IFDEF ISD102T_DELPHI}
  if (int64(OChar - IChar) > BufSize) then

    StrLCopy(@Tag[0], IChar, BufSize - 1)
  else
    StrLCopy(@Tag[0], IChar, int64(OChar - IChar) + 1);
{$ELSE}
  if (int64(OChar - IChar) > BufSize) then
    System.AnsiStrings.StrLCopy(@Tag[0], IChar, BufSize - 1)
  else
    System.AnsiStrings.StrLCopy(@Tag[0], IChar, int64(OChar - IChar) + 1);
{$ENDIF}
  IChar := @Tag[0];
  Result := IChar;
  // except
  // Result := '';
  // End;
end;
{$ENDIF}
{$IFNDEF NextGen}

function HTMLExtractToNextTagByType(var CurrentLoc: PAnsiChar;
  const LowerCaseTagIndicator: AnsiString): AnsiString; overload;
var
  StartLoc: PAnsiChar;
  ResultLen, TagLen, BrLen: Integer;
Begin
  StartLoc := CurrentLoc;
  TagLen := length(HTMLExtractNextTagByType(CurrentLoc, LowerCaseTagIndicator));
  if CurrentLoc = nil then
{$IFDEF ISD102T_DELPHI}
    ResultLen := StrLen(StartLoc)
{$ELSE}
    ResultLen := System.AnsiStrings.StrLen(StartLoc)
{$ENDIF}
  else
    ResultLen := int64(CurrentLoc - StartLoc) - TagLen;
  if ResultLen < 1 then
    Result := ''
  else
  begin
    // {$IFDEF NEXTGEN}
    // Result.CopyBytesFromMemory(Pointer(CurrentLoc), ResultLen);
    // {$ELSE}
    SetLength(Result, ResultLen);
{$IFDEF ISD102T_DELPHI}
    StrLCopy(PAnsiChar(Result), StartLoc, ResultLen);
{$ELSE}
    System.AnsiStrings.StrLCopy(PAnsiChar(Result), StartLoc, ResultLen);
{$ENDIF}
    // {$ENDIF}
  end;
  if CurrentLoc = nil then
  begin
    BrLen := Pos(AnsiString('<b'), Result) - 1;
    If BrLen < 1 then
      BrLen := Pos(AnsiString('<B'), Result) - 1;
    If BrLen > 1 then
      if (BrLen < ResultLen) then
        // {$IFDEF NEXTGEN}
        // Result.length := ResultLen;
        // {$ELSE}
        SetLength(Result, BrLen);
    // {$ENDIF}
  end
  else if CurrentLoc[0] = '>' then
  begin
    inc(CurrentLoc);
    if CurrentLoc[0] = #0 then
      CurrentLoc := nil;
  end;
End;
{$ENDIF}
{$IFNDEF NextGen}

function HTMLExtractNextTagByType(var CurrentLoc: PAnsiChar;
  const LowerCaseTagIndicator: AnsiString): AnsiString;
var
  S, Tst: AnsiString;
  i, sLen: Integer;
begin
  { Result := HTMLExtractNextTab(CurrentLoc);
    s := Lowercase(Result);
    while (s <> '') and (1 <> Pos('<' + LowerCaseTagIndicator, S)) do
    begin
    Result := HTMLExtractNextTab(CurrentLoc);
    s := Lowercase(Result);
    end; }
  // {$IFDEF NEXTGEN}
  // sLen := LowerCaseTagIndicator.length + 1;
  // {$ELSE}
  sLen := length(LowerCaseTagIndicator) + 1;
  // {$ENDIF}
  Result := HTMLExtractNextTab(CurrentLoc);
  S := Lowercase(Result);
  Tst := '<' + LowerCaseTagIndicator;
  while (S <> '') and (CurrentLoc <> nil) do
  begin
    i := Pos(Tst, S);
    if (i = 1) and not(Char(S[i + sLen + ZSISOffset]) in ['a' .. 'z', '-', '_',
      '0' .. '9']) then
      S := ''
    else
    begin
      Result := HTMLExtractNextTab(CurrentLoc);
      if Result <> '' then
        S := Lowercase(Result);
    end;
  end;
end;
{$ENDIF}

function ReplaceControlWithSpace(const AInString: AnsiString): AnsiString;
var
  i: Integer;
  LastIsSpace: Boolean;
begin
  LastIsSpace := True;
  Result := '';
  for i := 1 to length(AInString) do
    if Char(AInString[i]) < ' ' then
    begin
      if not LastIsSpace then
        Result := Result + ' ';
      LastIsSpace := True;
    end
    else
    begin
      Result := Result + AInString[i];
      LastIsSpace := False;
    end;

end;

function RemoveControlChar(const AInString: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to length(AInString) do
    if Char(AInString[i]) < ' ' then
    begin
    end
    else
      Result := Result + AInString[i];
end;

{$IFNDEF NextGen}

function ReplaceBreakWithCR(const AInString: AnsiString): AnsiString;
var
  iStart: PAnsiChar;
  StrLen, TagLen: Integer;
  ss, strtag: AnsiString;

  InstrBr: PAnsiChar;

begin
  iStart := PAnsiChar(AInString);
  InstrBr := iStart;
  strtag := HTMLExtractNextTagByType(InstrBr, 'br');
  if InstrBr = nil then
    Result := AInString // back to what was
  else
  begin
    Result := '';
    while (InstrBr <> nil) do
    begin
      // {$IFDEF NEXTGEN}
      // TagLen := strtag.length - 1;
      // {$ELSE}
      TagLen := length(strtag) - 1;
      // {$ENDIF}
      StrLen := int64(InstrBr - iStart) - TagLen;
      if StrLen > 0 then
      // {$IFDEF NEXTGEN}
      // ss.CopyBytesFromMemory(Pointer(iStart), StrLen);
      // {$ELSE}
      begin
        SetLength(ss, StrLen);
{$IFDEF ISD102T_DELPHI}
        ss := StrLCopy(PAnsiChar(ss), iStart, StrLen);
{$ELSE}
        ss := System.AnsiStrings.StrLCopy(PAnsiChar(ss), iStart, StrLen);
{$ENDIF}
      end;
      // {$ENDIF}
      Result := Result + ss;
      if InstrBr <> nil then
        Result := Result + CRLF;
      if InstrBr[1] = Ansichar(0) then
        InstrBr := nil
      else
        inc(InstrBr);
      iStart := InstrBr;
      if InstrBr <> nil then
      begin
        strtag := HTMLExtractNextTagByType(InstrBr, 'br');
        if InstrBr = nil then
          Result := Result + AnsiString(iStart);
      end;
    end
  end;
end;
{$ENDIF}
{$IFNDEF NextGen}

function TakeOneCleanLine(var InStr: PAnsiChar): String;
var
  iStart, iEnd, StrLen, TagLen: Integer;
  ss, ss2, strtag: AnsiString;
  InStrCR, InstrBr: PAnsiChar;
begin

  // Mod jan 2005 Add <br> as line terminator

  InStrCR := InStr;
  InstrBr := InStr;

  ss := TakeOneLine(InStrCR, []);
  strtag := HTMLExtractNextTagByType(InstrBr, 'br');
  if InstrBr = nil then
    InStr := InStrCR // back to what was
  else if (InStrCR = nil) or (InStrCR > InstrBr) then
  begin
    TagLen := length(strtag) - 1;
    StrLen := int64(InstrBr - InStr) - TagLen;
    // {$IFDEF NEXTGEN}
    // ss.CopyBytesFromMemory(Pointer(InStr), StrLen);
    // {$ELSE}
    SetLength(ss, StrLen);
{$IFDEF ISD102T_DELPHI}
    ss := StrLCopy(PAnsiChar(ss), InStr, StrLen);
{$ELSE}
    ss := System.AnsiStrings.StrLCopy(PAnsiChar(ss), InStr, StrLen);
{$ENDIF}
    // {$ENDIF}
    if InstrBr[1] = Ansichar(0) then
      InStr := nil
    else
      InStr := InstrBr + 1;
  end
  else
    InStr := InStrCR; // back to what was

  iStart := 1;
  while iStart <> 0 do
  begin
    iStart := Pos(AnsiString('<'), ss);
    iEnd := Pos(AnsiString('>'), ss);
    if (iStart < iEnd) and (iStart > 0) then
    begin
      ss2 := Copy(ss, 1, iStart - 1) + Copy(ss, iEnd + 1, 255);
      ss := ss2;
    end
    else
      iStart := 0;
  end;
  Result := ss;
end;
{$ENDIF}
{$IFNDEF NextGen}

function HTMLExtractNextEndTab(var CurrentLoc: PAnsiChar): AnsiString;

const
  BufSize = 200;
var
  IChar, OChar: PAnsiChar;
  Tag: array [0 .. BufSize] of Ansichar;

begin
  if (CurrentLoc = nil) or (Ord(CurrentLoc[0]) = 0) then
  Begin
    Result := ''; // in tstcase Result points to CurrentLoc
    Exit;
  End;

{$IFDEF ISD102T_DELPHI}
  IChar := StrPos(CurrentLoc, AnsiString('</'));
  if IChar <> nil then
    OChar := StrScan(IChar, Ansichar('>'))
{$ELSE}
  IChar := System.AnsiStrings.StrPos(CurrentLoc, AnsiString('</'));
  if IChar <> nil then
    OChar := System.AnsiStrings.StrScan(IChar, Ansichar('>'))
{$ENDIF}
  else
    OChar := nil;
  CurrentLoc := OChar;
  if OChar = nil then
    Exit;
{$IFDEF ISD102T_DELPHI}
  if ((OChar - IChar) > BufSize) then
    StrLCopy(@Tag[0], IChar, BufSize - 1)
  else
    StrLCopy(@Tag[0], IChar, OChar - IChar + 1);
  IChar := @Tag[0];
  Result := StrUpper(IChar);
{$ELSE}
  if ((OChar - IChar) > BufSize) then
    System.AnsiStrings.StrLCopy(@Tag[0], IChar, BufSize - 1)
  else
    System.AnsiStrings.StrLCopy(@Tag[0], IChar, OChar - IChar + 1);
  IChar := @Tag[0];
  Result := System.AnsiStrings.StrUpper(IChar);
{$ENDIF}
end;
{$ENDIF}
{$IFNDEF NEXTGEN}

function ExtractDomainFromEmail(const AEmailAddress: AnsiString): AnsiString;
var
  NxtChar: PAnsiChar;
begin
  NxtChar := PAnsiChar(AEmailAddress);
  FieldSep(NxtChar, '@');
  Result := Trim(FieldSep(NxtChar, '>'));
end;
{$ENDIF}

function StandardSearchPhoneFormat(const Value: String;
  var AStd, ALocalNo: String): String;
// (06) 787878787 or 787878788 +613 7878787888
begin
  DeconstructPhoneNumber(Value, AStd, ALocalNo);

  if AStd <> '' then
    Result := ReconstructPhoneNumber(AStd, ALocalNo)
  else
    Result := ALocalNo;
end;

Function IsValidAustralianStateTeritory(ATest: String): Boolean;
// Returns true for Tas of Tasmania
Const
  TestArray: Array [0 .. 15] of string = ('Tas', 'Tasmania', 'Vic', 'Victoria',
    'NSW', 'New South Wales', 'SA', 'South Australia', 'WA',
    'Western Australia', 'NT', 'Northern Territory', 'Qld', 'Queensland', 'ACT',
    'Australian Capital Territory');

Begin
  Result := InArray(TestArray, ATest, False);
end;

Function IsValidAustralianCapital(ATest: String): Boolean;
// Returns true for Melbourne not case sensitive
Const
  TestArray: Array [0 .. 7] of string = ('Melbourne', 'Hobart', 'Sydney',
    'Canberra', 'Perth', 'Adelaide', 'Brisbane', 'Darwin');
Begin
  Result := InArray(TestArray, ATest, False);
end;

function ValidEmailAddress(const Value: String): Boolean;
var
  NextChar: PChar;
  L: Integer;
begin
  L := length(Value);
  Result := (L < 100) and (L > 2);
  if Result then
    NextChar := StrPos(PChar(Value), '<')
  else
    Exit;

  if NextChar <> nil then // <email@nnnn.bbbb>
    Result := StrPos(NextChar, '>') <> nil
  else
    NextChar := PChar(Value);

  if Result then
    Result := StrPos(NextChar, ' ') = nil;
  if Result then
  begin
    NextChar := StrPos(NextChar, '@');
    Result := NextChar <> nil;
  end;

  if Result then
    Result := StrPos(NextChar, '.') <> nil;
end;

{$IFNDEF NextGen}

procedure HTMLExtractTagWithOptionalContents(var CurrentLoc: PAnsiChar;
  var TagText, TagContent: AnsiString; const TagIndicator: AnsiString);
var
  S, Tf, Tfi: AnsiString;
  IChar, OChar, EChar: PAnsiChar;
  i: Integer;

begin
  TagContent := '';
  TagText := '';
  if CurrentLoc = nil then
    Exit;
  if CurrentLoc[0] = AnsiChr(0) then
    CurrentLoc := nil;
  if CurrentLoc = nil then
    Exit;

  Tfi := Lowercase(TagIndicator);
  IChar := CurrentLoc;
  S := HTMLExtractNextTagByType(IChar, Tfi);
  Tf := S;
  i := 2;
  S := Lowercase(S);
  while (i < length(S)) and (Char(S[i]) in ['A' .. 'Z', '0' .. '9']) do
    i := i + 1;
  if i > 2 then
    Tfi := Copy(S, 2, i - 2);
  OChar := IChar;

  while (S <> '') and (1 <> Pos('</' + Tfi, S)) do
    S := Lowercase(HTMLExtractNextEndTab(OChar));

  // Check Termination
  if OChar <> nil then
  begin
    EChar := IChar;
    HTMLExtractNextTagByType(EChar, Tfi);
    if (EChar <> nil) and (EChar < OChar) then
      OChar := nil;
  end;

  TagText := Tf;
  if OChar <> nil then
  begin
    TagContent := Copy(AnsiString(IChar), 2, int64(OChar - IChar) - length(S));
    CurrentLoc := OChar;
  end
  else
    CurrentLoc := IChar;

end;
{$ENDIF}

function EndTagRequired(const TagIndicator: AnsiString): Boolean;
var
  i: Integer;
begin
  Result := True;
{$IFDEF NEXTGEN}
  i := TagIndicator.length;
{$ELSE}
  i := length(TagIndicator);
{$ENDIF}
  if i < 1 then
    Exit;
  case Char(TagIndicator[1 + ZSISOffset]) of
    'I', 'i':
      if i = 3 then
        case Char(TagIndicator[2 + ZSISOffset]) of
          'M', 'm':
            case Char(TagIndicator[2 + ZSISOffset]) of
              'G', 'g':
                Result := False; // img
            end;
        end;
    'B', 'b', 'H', 'h':
      if (i = 2) and ((TagIndicator[2 + ZSISOffset] = 'r') or
        (TagIndicator[2 + ZSISOffset] = 'R')) then
        Result := False; // Br,Hr
    'L', 'l':
      case i of
        4:
          if Lowercase(TagIndicator) = 'link' then
            Result := False;
      end;
  end;

end;

{$IFNDEF NextGen}

function HTMLExtractTagContents(var CurrentLoc: PAnsiChar;
  var TagText: AnsiString; const TagIndicator: AnsiString): AnsiString;
var
  S, Tf, Tfi: AnsiString;
  IChar, OChar, EChar: PAnsiChar;
  i, StrLen: Integer;
  LoopDone: Boolean;
begin
  Result := '';
  TagText := '';
  if CurrentLoc = nil then
    Exit;
  if CurrentLoc[0] = AnsiChr(0) then
    CurrentLoc := nil;
  if CurrentLoc = nil then
    Exit;
  Tfi := Lowercase(TagIndicator);
  IChar := CurrentLoc;
  S := HTMLExtractNextTagByType(IChar, Tfi);
  Tf := S;
  S := Lowercase(S);
  // {$IFDEF NEXTGEN}
  // StrLen := S.length;
  // {$ELSE}
  StrLen := length(S);
  // {$ENDIF}
  i := 2;
  while (i < StrLen) and (Char(S[i + ZSISOffset]) in ['a' .. 'z',
    '0' .. '9']) do
    inc(i);
  if i > 2 then
    Tfi := Copy(S, 2, i - 2);

  OChar := IChar;

  // make do embeded
  EChar := OChar;
  if EndTagRequired(Tfi) then
  begin
    HTMLExtractNextTagByType(EChar, Tfi);
    LoopDone := False;
    while not LoopDone do
    begin
      while (S <> '') and (1 <> Pos('</' + Tfi, S)) do
        S := Lowercase(HTMLExtractNextEndTab(OChar));
      // Echar ptr <tab> Ochar ptr to </anytab>
      // <tab><tab>         </anytab></tab>

      if (EChar <> nil) and (EChar < OChar) then
      begin
        HTMLExtractNextTagByType(EChar, Tfi);
        S := 'm';
      end
      else
        LoopDone := True;
    end;
  end
  else
    S := '';

  TagText := Tf;
  if S <> '' then // s=</tab>
  begin
    inc(IChar);
    // {$IFDEF NEXTGEN}
    // StrLen := int64(OChar - IChar) - S.length + 1;
    // {$ELSE}
    StrLen := int64(OChar - IChar) - length(S) + 1;
    // {$ENDIF}
    if StrLen > 0 then
    begin
      SetLength(Result, StrLen);
{$IFDEF ISD102T_DELPHI}
      StrLCopy(PAnsiChar(Result), IChar, StrLen);
{$ELSE}
      System.AnsiStrings.StrLCopy(PAnsiChar(Result), IChar, StrLen);
{$ENDIF}
    end;
  end;
  CurrentLoc := OChar;
end;
{$ENDIF}
{$IFNDEF BEXTGEN}

function GenerateHTTPTextValuePair(const ValueName, TextValue: String): String;
{ Makes Form
  <HTML>
  &Name=Value&Name=Value&
  </HTML>
  In HTML Acceptable Form }
  function ReplaceAnds(AValue: String): String;
  Var
    HtmlCharVersion: String;
  begin
    HtmlCharVersion := HtmlFrmWideChar(AValue);
    HtmlCharVersion := StringReplace(HtmlCharVersion, '#', CHashRepTxt,
      [rfReplaceAll]);
    HtmlCharVersion := StringReplace(HtmlCharVersion, ';', CSemiRepTxt,
      [rfReplaceAll]);
    Result := StringReplace(HtmlCharVersion, '&', CAndRepTxt, [rfReplaceAll]);
  end;

begin
  Result := HtmlPairMarker;
  if ValueName = '' then
    Exit;
  Result := HtmlPairMarker + ValueName + HtmlEq + ReplaceAnds(TextValue);
end;

function HtmlChars(AData: String): AnsiString;
// Takes non HTML Ascii Chars eg & and make &#38;
Var
  Ass: AnsiString;
  i, Val: Integer;
Const
  AlphaNum: set of Byte = [Ord('A') .. Ord('_'), Ord('a') .. Ord('z'),
    Ord('''') .. Ord('?'), Ord(' ') .. Ord('!')];
  // Ord('0')..ord('9')] is in Ord('''') .. Ord('?');

begin
  Result := '';
  for i := Low(AData) to High(AData) do
  begin
    Val := Ord(AData[i]);
    if (Val < 266) and (Val in AlphaNum) then
      Result := Result + Ansichar(Val)
    else
    begin
      Ass := '&#' + IntToStr(Val) + ';';
      Result := Result + Ass;
    end;
  end;
end;

Function ConvertCharValForHtml(ACharVal: Integer): Boolean;
// Char needs handling for HTML
Begin
  Result := (ACharVal > Ord('z')) or (ACharVal < Ord(' ')) or
    ((ACharVal > Ord(' ')) and (ACharVal < Ord('0'))) or
    ((ACharVal > Ord('9')) and (ACharVal < Ord('A'))) or
    ((ACharVal > Ord('Z')) and (ACharVal < Ord('a')));
End;

function HtmlFrmWideChar(AData: String; AAllow8bitControl: Boolean = False)
  : AnsiString;
// Takes Unicode Wide Char into &#556;     was HtmlFrmUniCode ????
// AAllow8bitControl Lets '<' , '>' etc pass
Var
  Ass: AnsiString;
  i, Val: Integer;

begin
  Result := '';
  if AData = '' then
    Exit;

  for i := Low(AData) to High(AData) do
  { if AData[i] = ' ' then
    Result := Result + '+'
    else }
  begin
    Val := Ord(AData[i]);
    if AAllow8bitControl and (Val < 255) then
      Result := Result + Ansichar(Val)
    else if ConvertCharValForHtml(Val) then
    begin
      Ass := '&#' + IntToStr(Val) + ';';
      Result := Result + Ass;
    end
    else
      Result := Result + Ansichar(Val);
  end;
end;

{$ENDIF}

function RecoverCommandLineValuePair(const ValueChar: Ansichar;
  const Buffer: AnsiString): AnsiString;
{ Expect Form
  Program.exe   /R:Full /P:8080
}
var
  i, StepIn: Integer;
  PStart, PEnd: PAnsiChar;
begin
  Result := '';
  i := Pos(AnsiString('/' + ValueChar + ':'), Buffer);
  if i > 0 then
    StepIn := i + 3
  else
    StepIn := 0;
  if StepIn = 0 then
    Exit;
{$IFDEF NEXTGEN}
  PStart := PAnsiChar(Buffer);
  PStart := PStart + StepIn;
  if PStart = nil then
    Exit;
  PEnd := StrPos(PStart, PAnsiChar(' '));
{$ELSE}
  PStart := @Buffer[StepIn];
  if PStart = Ansichar(0) then
    Exit;
{$IFDEF ISD102T_DELPHI}
  PEnd := StrPos(PStart, PAnsiChar(' '));
{$ELSE}
  PEnd := System.AnsiStrings.StrPos(PStart, PAnsiChar(' '));
{$ENDIF}
{$ENDIF}
  if PEnd = nil then
    i := PAnsiChrLen(PStart)
  else
    i := int64(PEnd - PStart);
  if i > 255 then
    Exit;
{$IFDEF NEXTGEN}
  Result.CopyBytesFromMemory(Pointer(PStart), i);
{$ELSE}
  SetLength(Result, i);
{$IFDEF ISD102T_DELPHI}
  StrLCopy(@Result[1], PStart, i);
{$ELSE}
  System.AnsiStrings.StrLCopy(@Result[1], PStart, i);
{$ENDIF}
{$ENDIF}
end;

function CreateHTTPTextValuePair(const ValueName, Value: AnsiString)
  : AnsiString;
begin
  Result := GenerateHTTPTextValuePair(ValueName, Value);
  {
    if ValueName = '' then
    Result := HtmlPairMarker
    // To Terminate
    else
    Result := HtmlPairMarker + ValueName + HtmlEq + Trim(Value); }
end;

Function ExtractIncNextPercentHex(Var APchr: PAnsiChar): String;
  Function ExtractOnlyNumBytes(Var NxtChr: PAnsiChar; MaxCount: Integer)
    : AnsiString;
  Var
    i: Integer;
  begin
    i := 0;
{$IFDEF Nextgen}
    while (Char(NxtChr[i]) in ['0' .. '9']) And (i < MaxCount + 1) do
      inc(i);
    Result.CopyBytesFromMemory(Pointer(NxtChr), i);
{$ELSE}
    while (NxtChr[i] in ['0' .. '9']) And (i < MaxCount + 1) do
      inc(i);
    SetLength(Result, i);
    if i > 0 then
{$IFDEF ISD102T_DELPHI}
      StrLCopy(@Result[1], NxtChr, i); // else result:='';
{$ELSE}
      System.AnsiStrings.StrLCopy(@Result[1], NxtChr, i); // else result:='';
{$ENDIF}
{$ENDIF}
    if NxtChr[i] = #0 then
      NxtChr := nil
    else
      inc(NxtChr, i);
  end;

  Function ExtractOnlyHexNumBytes(Var NxtChr: PAnsiChar; MaxCount: Integer)
    : AnsiString;
  Var
    i: Integer;
  begin
    i := 0;

{$IFDEF Nextgen}
    while (Char(NxtChr[i]) in ['0' .. '9', 'A' .. 'F']) And (i < MaxCount) do
      inc(i);
    Result.CopyBytesFromMemory(Pointer(NxtChr), i);
{$ELSE}
    while (NxtChr[i] in ['0' .. '9', 'A' .. 'F']) And (i < MaxCount) do
      inc(i);
    SetLength(Result, i);
    if i > 0 then
{$IFDEF ISD102T_DELPHI}
      StrLCopy(@Result[1], NxtChr, i); // else result:='';
{$ELSE}
      System.AnsiStrings.StrLCopy(@Result[1], NxtChr, i); // else result:='';
{$ENDIF}
{$ENDIF}
    if NxtChr[i] = #0 then
      NxtChr := nil
    else
      inc(NxtChr, i);
  end;

Var
  NxtPerCentChr, NxtPerCentChrNo2: PAnsiChar;
  AnsiBit: AnsiString;
{$IFNDEF NextGen}
  NxtBit, NxtBitNo2: AnsiString;
  Utf8Bit: UTF8String;
{$ENDIF}
  FirstBitLen, BitVal: Integer;
  NewString, FirstBitString: String;
  HexCode: Boolean;

Begin
  Result := '';
  if (APchr[0] = #0) then
    APchr := nil;

  if (APchr = nil) then
    Exit;

  if APchr[1] = #0 then
  Begin
    Result := APchr[0];
    APchr := nil;
    Exit;
  end;

  NxtPerCentChr := APchr;
{$IFDEF NextGen}
  while (Byte(NxtPerCentChr) <> 0) and (Byte(NxtPerCentChr) <> Ord('%')) do
    inc(NxtPerCentChr);

  if (Byte(NxtPerCentChr) = 0) then
  begin
    AnsiBit.CopyBytesFromMemory(Pointer(NxtPerCentChr), NxtPerCentChr - APchr);
    APchr := nil;
    Result := AnsiBit;
  end;
  // while (NxtPerCentChr^ <> #0) and (NxtPerCentChr^ <> '%') do
  inc(NxtPerCentChr);

  // if (NxtPerCentChr^ = #0) then
  begin
    AnsiBit := APchr;
    FirstBitString := DeCompressUnicode(AnsiBit);
    Result := FirstBitString;
    APchr := nil;
  end
  // else
  // ? ? ? needs fixup for NextGen);
    ;

{$ENDIF}
{$IFNDEF Nextgen}
  while (NxtPerCentChr^ <> #0) and (NxtPerCentChr^ <> '%') do
    inc(NxtPerCentChr);

  if (NxtPerCentChr^ = #0) then
  begin
    AnsiBit := APchr;
    FirstBitString := DeCompressUnicode(AnsiBit);
    Result := FirstBitString;
    APchr := nil;
  end
  else
  begin
    NxtBitNo2 := '';
    inc(NxtPerCentChr);
    FirstBitLen := NxtPerCentChr - APchr - 1;
    if FirstBitLen > 0 then
    Begin
      SetLength(AnsiBit, FirstBitLen);
{$IFDEF ISD102T_DELPHI}
      StrLCopy(@AnsiBit[1], APchr, FirstBitLen);
{$ELSE}
      System.AnsiStrings.StrLCopy(@AnsiBit[1], APchr, FirstBitLen);
{$ENDIF}
      FirstBitString := DeCompressUnicode(AnsiBit);
    end
    else
      FirstBitString := '';

    NxtBit := ExtractOnlyHexNumBytes(NxtPerCentChr, 2);
    APchr := NxtPerCentChr;
    if (NxtPerCentChr <> nil) and (NxtPerCentChr^ = '%') then
    begin
      BitVal := Ord(StrToHexChar(NxtBit));
      NxtPerCentChrNo2 := NxtPerCentChr + 1;
      NxtBitNo2 := ExtractOnlyHexNumBytes(NxtPerCentChrNo2, 2);
      if (BitVal = 38) { (NxtBit = '26') } and (NxtBitNo2 = '23') then
      Begin // &#
        HexCode := False;
        if NxtPerCentChrNo2^ in ['x', 'X'] then
        Begin
          HexCode := True;
          inc(NxtPerCentChrNo2);
          NxtBit := ExtractOnlyHexNumBytes(NxtPerCentChrNo2, 8);
        End
        Else
          NxtBit := ExtractOnlyNumBytes(NxtPerCentChrNo2, 8);
        APchr := NxtPerCentChrNo2;
        if (NxtPerCentChrNo2[0] = '%') and (NxtPerCentChrNo2[1] = '3') and
          (NxtPerCentChrNo2[2] = 'B') then // &#666666:  and   %26%236666666%3B
        Begin
          Try
            If HexCode then
              NewString := StrToHexChar(NxtBit)
            else
              NewString := Char(StrToInt(NxtBit));
          Except
            NewString := '?'
          End;
          FirstBitString := FirstBitString + NewString;
          APchr := NxtPerCentChrNo2 + 3;
        end
        Else
        begin
          FirstBitString := FirstBitString + '&#' + NxtBitNo2;
          // Not sure we should get here
          APchr := NxtPerCentChrNo2;
        end;
      End
      Else
      Begin // not &#
        if (NxtBitNo2 = '') or (BitVal < 128) then
          FirstBitString := FirstBitString + Char(BitVal)
        else
        begin
          Utf8Bit := 'AA';
          Utf8Bit[1] := Ansichar(BitVal);
          Utf8Bit[2] := Ansichar(Ord(StrToHexChar(NxtBitNo2)));
          FirstBitString := FirstBitString + Utf8Bit;
          APchr := NxtPerCentChrNo2;
        end;
      end;
    end
    else
      FirstBitString := FirstBitString + Char(Ord(StrToHexChar(NxtBit)));
    Result := FirstBitString;
  end;
{$ENDIF}
end;

function RecoverPostValue(const S: AnsiString): String;
// 'Connell%2C+R.W.+%281196%29' >>  'Connell, R.W. (1196)'
// Text%26%2320219%3B >>   'Text任何'
var
  ss: AnsiString;
  sss: String;
  NxtChr: PAnsiChar;

begin
  Result := '';
  if length(S) < 1 then
    Exit;
  ss := StringReplace(S, AnsiString('+'), AnsiString(' '), [rfReplaceAll]);

  sss := '';
  NxtChr := AnsiCharPtr(ss);
  while NxtChr <> nil do
    sss := sss + ExtractIncNextPercentHex(NxtChr);
  Result := sss;
end;

Function CodeAsInHTMLSubmit(const S: String): AnsiString;
{ Codes Resticted HTML Chars and WideChar for upload }
// 'Connell, R.W. (1196)'>>'Connell%2C+R.W.+%281196%29'
// 'Text任何'  >> 'Text%26%2320219%3B'
Var
  HtmlCoded: AnsiString;

Begin
  HtmlCoded := HtmlFrmWideChar(S);
  Result := '';

  if HtmlCoded = '' then
    Exit;

End;

function RecoverTagParameter(const ATagTxt, AParameter: AnsiString): AnsiString;
{ Expect <dd href="jjjjjjjj" /dd> }
var
  PStart, PNxt: PAnsiChar;
  Tag: AnsiString;
  LwrCs, ResultLwr: AnsiString;
  Quote: Ansichar;

begin
  ResultLwr := '';
  if ATagTxt = '' then
    Exit;
  if length(AParameter) < 2 then
    Exit;

  LwrCs := Lowercase(ATagTxt);
  Tag := Lowercase(AParameter);
  PNxt := PAnsiChar(LwrCs);
  PStart := PNxt;
  while (PNxt <> nil) and (ResultLwr = '') do
  begin
{$IFDEF Nextgen}
    PNxt := StrPos(PNxt, PAnsiChar(Tag));
{$ELSE}
{$IFDEF ISD102T_DELPHI}
    PNxt := StrPos(PNxt, PAnsiChar(Tag));
{$ELSE}
    PNxt := System.AnsiStrings.StrPos(PNxt, PAnsiChar(Tag));
{$ENDIF}
{$ENDIF}
    if PNxt <> nil then
      case Char(PNxt[-1]) of
        ' ', CR, LF, '"', '''':
          if (Tag = Trim(FieldSep(PNxt, '='))) then
          begin
            if PNxt <> nil then
            begin
              Quote := PNxt[0];
              if (Char(Quote) in ['"', '''']) and (Char(PNxt[1]) <> #0) then
              begin
                inc(PNxt);
                ResultLwr := FieldSep(PNxt, Quote);
              end
              else
                ResultLwr := FieldSep(PNxt, Ansichar(' '));
            end;
          end
          else
            PNxt := {$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.
              AnsiStrings.{$ENDIF}{$ENDIF}StrPos(PNxt, PAnsiChar(Tag));
      else
        PNxt := {$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.
          AnsiStrings.{$ENDIF}{$ENDIF}StrPos(PNxt, PAnsiChar(Tag));
      end;
  end;
  if ResultLwr = '' then
    Result := ''
  else
  begin
    PNxt := {$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.
      AnsiStrings.{$ENDIF}{$ENDIF}StrPos(PStart, PAnsiChar(ResultLwr));
    if PNxt > PStart then
      Result := Copy(ATagTxt, int64(PNxt - PStart) + 1, length(ResultLwr));
  end;
end;

function RecoverHTTPTextValuePair(const ValueName, Buffer: AnsiString): String;
{ Expect Form
  <HTML>
  &Name=Value&Name=Value+Value%21&
  </HTML>
  Was  Wrong     %Name=Value%Name=Value%
}
// See PostValuePairs in ISCgiObjects

var
  i, StepIn: Integer;
  PStart, PEnd: PAnsiChar;
  UseRaw: Boolean;
  S: AnsiString;
begin
  Result := '';
  if Buffer = '' then
    Exit;
  try
    if length(ValueName) < 3 then
      Exit;

    UseRaw := False;
    i := Pos(HtmlPairMarker + ValueName + HtmlEq, Buffer);
    if i > 0 then
      StepIn := i + length(ValueName) + length(HtmlPairMarker) + length(HtmlEq)
    else
    begin
      StepIn := 0;
      i := Pos('&' + ValueName + '=', Buffer);
      if i > 0 then
      begin
        StepIn := i + length(ValueName) + 2;
        UseRaw := True;
      end
      else
      begin
        i := Pos(ValueName + '=', Buffer);
        if i > 0 then
          StepIn := i + length(ValueName) + 1;
        UseRaw := Pos(AnsiString(HtmlPairMarker), Buffer) < 3;
      end;
    end;
    if StepIn = 0 then
      Exit;
{$IFDEF NEXTGEN}
    if StepIn > Buffer.length then
      Exit;
    PStart := Pointer(int64(Pointer(Buffer)) + StepIn);
    if PStart = nil then
      Exit;
{$ELSE}
    if StepIn > length(Buffer) then
      Exit;
    PStart := @Buffer[StepIn];
    if PStart = Ansichar(0) then
      Exit;
{$ENDIF}
    if UseRaw then
      PEnd := {$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.
        AnsiStrings.{$ENDIF}{$ENDIF}StrPos(PStart, PAnsiChar(AnsiString('&')))
    else
      PEnd := {$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.
        AnsiStrings.{$ENDIF}{$ENDIF}StrPos(PStart, PAnsiChar(HtmlPairMarker));
    if PEnd = nil then
      i := PAnsiChrLen(PStart)
    else
      i := int64(PEnd - PStart);
    if i > 12800 then
      Exit;
    if i < 1 then
      Exit;
{$IFDEF NEXTGEN}
    S.CopyBytesFromMemory(Pointer(PStart), i);
{$ELSE}
    SetLength(S, i);
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrLCopy(@S[1], PStart, i);
{$ENDIF}
    Result := RecoverPostValue(S);

    { if (length(Result) > length(CAndRepTxt)) then
      Result := StringReplace(Result, CAndRepTxt, '&', [rfReplaceAll]);
      if (length(Result) > length(CHashRepTxt)) then
      Result := StringReplace(Result, CHashRepTxt, '#', [rfReplaceAll]); }
  except
    on E: Exception do
      raise Exception.Create('RecoverHTTPTextValuePair error <' + ValueName +
        '>   ' + E.Message);
  end;
end;
{$IFNDEF FPC}

procedure NumericOnly(var S: AnsiString; AAllowSome: AnsiCharSet);
{ Removes non Numeric removes Alpha punctuation & etc }
var
  i, j: Integer;
begin
  if S = '' then
    Exit;

  UniqueString(S);
  j := 1;
  for i := 1 to length(S) do
  begin
    S[j] := S[i];
    case Char(S[i]) of
      '0' .. '9':
        inc(j);
    else
{$IFDEF NEXTGEN}
      if Byte(Ord(S[i])) in AAllowSome then
        inc(j);
    end; // case
  end;
  S.length := j - 1;
{$ELSE}
      if S[i] in AAllowSome then
        inc(j);
    end; // case
  end;
  SetLength(S, j - 1);
{$ENDIF}
end;
{$ENDIF}

function Numeric(const S: String;
  AAllowSome: UniCodeCharSet = [',', '.', '+', '-', ' ']): String;
{ Removes non Numeric }
begin
  Result := S;
  NumericOnly(Result, AAllowSome);
end;

procedure NumericOnly(var S: String; AAllowSome: UniCodeCharSet);
{ Removes non Numeric removes Alpha punctuation & etc }
var
  i, j: Integer;
begin
  if S = '' then
    Exit;

  UniqueString(S);
  j := 1;
  for i := 1 to length(S) do
  begin
    S[j] := S[i];
    case S[i] of
      '0' .. '9':
        inc(j);
    else
      if S[i] in AAllowSome then
        inc(j);
    end; // case
  end;
  SetLength(S, j - 1);
end;

procedure AlphaOnly(var S: String);
{ Replaces non alpha with spaces removes Numerals punctuation & etc }
var
  i: Integer;
begin
  UniqueString(S);
  for i := 1 to length(S) do
  begin
    case S[i] of
      'a' .. 'z', 'A' .. 'Z':
        begin
        end;
    else
      S[i] := ' ';
    end; // case
  end;
end;

function TrimWthAll(const S: String; AAllowSome: UniCodeCharSet = ['.']
  ): String;
{ Remove LeadingAnd Trailing non Alpha numeric Chars Except AAllowSome }
var
  i: Integer;
  TrailingCount, RLen: Integer;
  DoneStart: Boolean;
begin
  DoneStart := False;
  Result := '';
  for i := 1 to length(S) do
  begin
    case S[i] of
      'a' .. 'z', 'A' .. 'Z', '0' .. '9':
        begin
          DoneStart := True;
          Result := Result + S[i];
          TrailingCount := 0;
        end;
    else
      begin
        if S[i] in AAllowSome then
        begin
          DoneStart := True;
          TrailingCount := 0;
        end
        Else
          inc(TrailingCount);
        if DoneStart then
          Result := Result + S[i];
      end;
    end; // case
  end;

  RLen := length(Result);
  if TrailingCount > 0 then
    if (RLen > TrailingCount) then
      SetLength(Result, RLen - TrailingCount);

end;

function AlphaNumeric(const S: String; ASqueeze: Boolean;
  AAllowSome: UniCodeCharSet): String;
var
  Data: String;
begin
  Data := S;
  if AAllowSome = [] then
    AlphaNumericOnly(Data, ASqueeze)
  Else
    AlphaNumericPlusSome(Data, ASqueeze, AAllowSome);
  Result := Data;
end;

{$IFNDEF FPC}

procedure AlphaNumericOnly(var S: AnsiString; ASqueeze: Boolean = False);
Var
  ss: String;
Begin
  ss := S;
  AlphaNumericOnly(ss, ASqueeze);
  S := ss;
End;
{$ENDIF}

procedure AlphaNumericPlusSome(var S: String; ASqueeze: Boolean;
  AAllowSome: UniCodeCharSet);
{ Replaces non alphanumeric with spaces (ASqueeze removes) punctuation & etc }
var
  i, j: Integer;
  Tst: UniCodeCharSet;
begin
  UniqueString(S);
  if AAllowSome = [] then
    AlphaNumericOnly(S, ASqueeze)
  Else
  Begin
    j := 0;
    Tst := ['a' .. 'z', 'A' .. 'Z', '0' .. '9'] + AAllowSome;
    for i := 1 to length(S) do
    begin
      if S[i] in Tst then
      begin
        inc(j);
        S[j] := S[i];
      end
      else if ASqueeze then
      begin
        if (S[i] = ' ') then
        Begin
          if (j > 0) and (S[j] <> ' ') then
          begin
            inc(j);
            S[j] := ' ';
          end;
        End;
      end
      else
      begin
        inc(j);
        S[j] := ' ';
      end;
    end;
    if j < length(S) then
      SetLength(S, j);
  end;
end;


procedure AlphaNumericOnly(var S: String; ASqueeze: Boolean = False);
{ Replaces non alphanumeric with spaces (ASqueeze removes) punctuation & etc }
var
  i, j: Integer;
begin
  UniqueString(S);
  j := 0;
  for i := 1 to length(S) do
  begin
    case S[i] of
      'a' .. 'z', 'A' .. 'Z', '0' .. '9':
        begin
          inc(j);
          S[j] := S[i];
        end;
    else
      if ASqueeze then
      begin
        if (S[i] = ' ') then
        Begin
          if (j > 0) and (S[j] <> ' ') then
          begin
            inc(j);
            S[j] := ' ';
          end;
        End;
      end
      else
      begin
        inc(j);
        S[j] := ' ';
      end;
    end; // case
  end;
  if j < length(S) then
    SetLength(S, j);
end;

function TrimMenuItemCaption(const S: AnsiString): AnsiString;
{ Remove & from caption }
begin
  Result := StringReplace(S, '&', '', [rfReplaceAll, rfIgnoreCase]);
end;

{$IFNDEF Nextgen}

function ReplaceSpecialHTMLChars(const AInString: UTF8String)
  : UTF8String; Overload;
{ <p>I will display &#9986;</p>
  <p>I will display &#x2702;</p> }
Var
  S: string;
begin
  S := AInString;
  Result := ReplaceSpecialHTMLChars(S);
end;
{$ENDIF}

function ReplaceSpecialHTMLChars(const AInString: AnsiString): AnsiString;
var
  Startchar, NextChar, NextFlag, RChar:
{$IFDEF NEXTGEN}
    IsNextGenPickup.PAnsiChar;
{$ELSE}
  PAnsiChar;
{$ENDIF}
IntAsStr, InString: AnsiString;
begin
{$IFDEF NEXTGEN}
  InString := AInString;
  Result.length := InString.length + 3;
  RChar := Result;
  RChar[0] := Byte(0);
{$ELSE}
  InString := ReplaceBreakWithCR(AInString);
  SetLength(Result, length(InString) + 3);
  RChar := @Result[1];
  RChar[0] := AnsiChr(0);
{$ENDIF}
  // should be shorter than original
  if InString <> '' then
{$IFDEF NEXTGEN}
    Startchar := InString
{$ELSE}
    Startchar := @InString[1]
{$ENDIF}
  else
    Startchar := nil;
  NextChar := Startchar;
  while NextChar <> nil do
  begin
    IntAsStr := '';
    NextFlag :=
{$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}{$ENDIF}StrPos(NextChar, AnsiString('&#'));
    if NextFlag = nil then
    begin
{$IFNDEF Nextgen}{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}{$ENDIF}StrCopy(RChar, NextChar);
      NextChar := nil;
    end
    else
    begin
{$IFDEF NEXTGEN}
      IsNextGenPickup.StrLCopy(RChar, NextChar, int64(NextFlag - NextChar));
{$ELSE}
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrLCopy(RChar, NextChar, NextFlag - NextChar);
{$ENDIF}
      NextChar := NextFlag + 2;
      while Char(NextChar[0]) in ['0' .. '9'] do
      begin
        IntAsStr := IntAsStr + NextChar[0];
        inc(NextChar);
      end;
      if NextChar[0] = ';' then
        inc(NextChar);
    end;
    RChar := RChar + PAnsiChrLen(RChar);
    if IntAsStr <> '' then
    begin
      IntAsStr := AnsiChr(StrToInt(IntAsStr));
{$IFDEF NEXTGEN}
      StrCopy(RChar, IntAsStr);
{$ELSE}
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrCopy(RChar, @IntAsStr[1]);
{$ENDIF}
      inc(RChar);
    end;
  end;
{$IFDEF NEXTGEN}
  RChar := Result;
  Result.length := PAnsiChrLen(RChar);
{$ELSE}
  RChar := @Result[1];
  SetLength(Result, PAnsiChrLen(RChar));
{$ENDIF}
end;

function GenerateSpecialHTMLChars(const InString: String): AnsiString;
{ Removes % etc and gives &#37 etc }
var
  i: Integer;
  LastEOL: Integer;
begin
  Result := '';
  LastEOL := -1;
{$IFDEF NEXTGEN}
  for i := 1 to InString.length do
{$ELSE}
  for i := 1 to length(InString) do
{$ENDIF}
    case InString[i + ZSISOffset] of
      ' ', 'a' .. 'z', 'A' .. 'Z', '0' .. '9', '.':
        Result := Result + InString[i + ZSISOffset];
      #10, #13:
        if LastEOL < i - 1 then
        begin
          Result := Result + '<BR>';
          LastEOL := i;
        end;
    else
      Result := Result + '&#' + IntToStr(Ord(InString[i + ZSISOffset])) + ';';
    end; // case

end;

function GenerateHTMLLineBreaksChars(const InString: String): String;
{ Replace EOL CR LF with <BR> }
var
  i: Integer;
  LastEOL: Integer;
begin
  Result := '';
  LastEOL := -1;
{$IFDEF NEXTGEN}
  for i := 1 to InString.length do
{$ELSE}
  for i := 1 to length(InString) do
{$ENDIF}
    case InString[i + ZSISOffset] of
      #10, #13:
        if LastEOL < i - 1 then
        begin
          Result := Result + '<BR>';
          LastEOL := i;
        end;
    else
      Result := Result + InString[i + ZSISOffset];
    end; // case
end;

{$IFNDEF NextGen}

function MailToUrl(Eto, Ecc, Ebcc, Subject, Body: AnsiString): AnsiString;

begin
  if Eto = '' then
    Result := ''
  else
  begin
    Result := 'mailto:' + Trim(Eto) + '?subject=' + StringReplace(Trim(Subject),
      ' ', '%20', [rfReplaceAll]);
    if Ecc <> '' then
      Result := Result + '&cc=' + Ecc;
    if Ebcc <> '' then
      Result := Result + '&bcc=' + Ebcc;
    if Body <> '' then
      Result := Result + '&body=' + StringReplace(Trim(Body), ' ', '%20',
        [rfReplaceAll]);
  end;
end;

function BytesToByteString(const ByteData: AnsiString): AnsiString;
var
  i: Integer;
  Sub: ^Byte;
  Val: LongInt;
  rr: AnsiString;
begin
  i := 1;
  rr := '';
  while i <= length(ByteData) do
  begin
    Sub := @ByteData[i];
    Val := Sub^;
    rr := rr + IntToHex(Val, 2) + '.';
    i := i + 1;
  end;
  Result := rr;
end;

function BytesToTextString(const ByteData: AnsiString): AnsiString;
const
  a: set of ' ' .. '}' = [(' ') .. '~'];
  Ctrl: set of #0 .. #255 = [#1 .. #31];
var
  i: Integer;
  Sub: LongInt;
  rr: AnsiString;
  x: Ansichar;
  GreaterThan127: Boolean;
begin
  i := 1;
  rr := '';
  while i <= length(ByteData) do
  begin
    Sub := Ord(ByteData[i]);
    GreaterThan127 := Sub > 127;
    if GreaterThan127 then
      Sub := Sub - 128;
    x := (AnsiChr(Sub));
    if (x in a) then
    Begin
      rr := rr + x;
      if GreaterThan127 then
        rr := rr + '!';
    End
    else
    begin
      if GreaterThan127 then
        rr := rr + '[' + IntToHex(Sub + 128, 2) + ']'
      else if (x in Ctrl) then
        rr := rr + '(' + '^' + AnsiChr(Sub + 64) + ')'
      Else
        rr := rr + '[' + IntToHex(Sub, 2) + ']';
    end;
    i := i + 1;
  end;
  Result := rr;
end;

function ObjIntToStr(AObj: TObject): AnsiString;
Var
  i: LongInt;
begin
  i := Integer(AObj);
  Result := IntToStr(i);
end;

function PointerIntToStr(APtr: Pointer): AnsiString;
Var
  i: LongInt;
begin
  i := Integer(APtr);
  Result := IntToStr(i);
end;

function BytesToWordString(const ByteData: AnsiString): AnsiString;
var
  i: Integer;
  Sub: ^Word;
  Val: LongInt;
  rr: AnsiString;
begin
  i := 1;
  rr := '';
  while i <= length(ByteData) do
  begin
    Sub := @ByteData[i];
    Val := Sub^;
    rr := rr + IntToHex(Val, 4) + ':';
    i := i + 2;
  end;
  Result := rr;
end;

function HTTPInsertFormValue(const ATemplate, AName, AValue: AnsiString)
  : AnsiString;
{ Fills the form ?msg=035&name=&Name2=&Name3=OldValue
  to return      ?msg=035&name=Value&Name2=&Name3=OldValue
  any oldvalue will be replaced }

var
  CurrentValue: AnsiString;
  NextChar: PAnsiChar;
  i, NameLength: Integer;
begin
  Result := '';
  i := Pos(AName + '=', ATemplate);
  if i < 1 then
    Exit;
  // Failed Could not find
  NameLength := length(AName);
  NextChar := @ATemplate[i + NameLength];
  // =
  // NextChar:=NextChar+1; //skip =
  CurrentValue := FieldSep(NextChar, '&');
  i := i + NameLength;
  Result := Copy(ATemplate, 1, i) + AValue;
  i := i + length(CurrentValue);
  if NextChar <> nil then
    Result := Result + Copy(ATemplate, i, length(ATemplate));
end;

procedure HTTPAddWords(var S: AnsiString);
{ makes "Bacchus Marsh" into "Bacchus+Marsh"
  and   "Bacchus     Marsh" into "Bacchus+Marsh"
  and   "Bacchus@#$? Marsh" into "Bacchus+Marsh" }
var
  i: Integer;

begin
  Trim(S);
  for i := 1 to length(S) do
    if not(S[i] in ['A' .. 'Z', 'a' .. 'z', '-', '0' .. '9']) then
      S[i] := '+';
  i := 1;
  while i > 0 do
  begin
    i := Pos('++', S);
    if i > 0 then
      S := Copy(S, 1, i - 1) + Copy(S, i + 1, length(S))
  end;
end;

Function GetAnyPortRedirection(var Hoststr: AnsiString): Word;
Var
  ColunPos: Integer;
  Ns: AnsiString;
Begin
  Result := 0;
  ColunPos := Pos(':', Hoststr);
  if ColunPos < 1 then
    Exit;
{$IFDEF NEXTGEN}
  Ns := Copy(Hoststr, ColunPos + 1, 99);
  Hoststr := Copy(Hoststr, 0, ColunPos);
  Result := StrToIntDef(Ns, 0);
{$ELSE}
  Ns := Copy(Hoststr, ColunPos + 1, 99);
  Result := StrToIntDef(Ns, 0);
  Hoststr := Copy(Hoststr, 1, ColunPos - 1);
{$ENDIF}
End;

procedure HTTPHostAndFile(Url: PAnsiChar; var Hoststr, FileStr: AnsiString);
var
  NextChr, DotChar, BSlshChar, DBSlash: PAnsiChar;
begin
  Hoststr := '';
  FileStr := '';
  if Url = '' then
    Exit;

  DBSlash :=
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrPos(Url, PAnsiChar('//'));
  if DBSlash = '' then
  begin
    NextChr := Url;
    BSlshChar :=
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrPos(NextChr,
      PAnsiChar('/'));
    DotChar :=
{$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrPos(NextChr,
      PAnsiChar('.'));
    if DotChar < BSlshChar then
      Hoststr := FieldSep(NextChr, '/')
    else if (BSlshChar = nil) then
    begin
      if (DotChar = nil) then
        if {$IFNDEF ISD102T_DELPHI}System.AnsiStrings.{$ENDIF}StrIComp(Url,
          'localhost') = 0 then
        begin
          NextChr := nil;
          Hoststr := Url;
        end
    end
    else if PosNoCase('localhost', Url) = 1 then
      Hoststr := FieldSep(NextChr, '/');
  end
  else
  begin
    NextChr := DBSlash;
    Hoststr := FieldSep(NextChr, '/')
  end;
  if NextChr <> nil then
    FileStr := FieldSep(NextChr, ' ');
  if FileStr <> '' then
    FileStr := '/' + FileStr;
end;
{$ENDIF}
{$IFDEF UNICODE}

function PosNoCase(Const ASubstr: UnicodeString; AFullString: UnicodeString)
  : Integer; overload;
{ Pos but ignors case }
var
  Substr: String;
  S: String;
begin
  if (ASubstr = '') or (AFullString = '') then
  begin
    Result := -1;
    Exit;
  end;
  Substr := Lowercase(ASubstr);
  S := Lowercase(AFullString);
  Result := Pos(Substr, S);
end;

function PosFrmHere(const ASubstr: String; AFullString: String;
  AStartAt: Integer; AIgnorCase: Boolean = False): Integer; overload;
{ Pos but Start at offset }

var
  TstStr: String;
  newpos: Integer;
begin
  Result := 0;
  if AStartAt < 2 then
  begin
    if AIgnorCase then
      Result := PosNoCase(ASubstr, AFullString)
    else
      Result := Pos(ASubstr, AFullString);
    Exit
  end;

  TstStr := Copy(AFullString, AStartAt, length(AFullString));
  if TstStr = '' then
    Exit;

  if AIgnorCase then
    newpos := PosNoCase(ASubstr, TstStr)
  else
    newpos := Pos(ASubstr, TstStr);

  if newpos > 0 then
    Result := newpos + AStartAt - 1;
end;

function StrEquNoCase(const s1, s2: UnicodeString): Boolean; overload;
{ Strings Equal except for case }
begin
  Result := length(s1) = length(s2);
  if Result then
    Result := PosNoCase(s1, s2) = 1;
end;

function RemoveQuotes(const S: UnicodeString): UnicodeString;
{ Removes Matched ' or " from ends of String }
Var
  len: Integer;
begin
  Result := S;
{$IFDEF NEXTGEN}
  len := S.length;
{$ELSE}
  len := length(S);
{$ENDIF}
  if S <> '' then
    case S[1 + ZSISOffset] of
      '''', '"':
        if S[len + ZSISOffset] = S[1 + ZSISOffset] then
          Result := Copy(S, 2, length(S) - 2);
    end; // case
end;

function RemoveBlankLines(const S: UnicodeString): UnicodeString;
{ Removes Blanklines from StringList.Text }
var
  NextChar: PWideChar;
  Line: UnicodeString;
begin
  NextChar := PWideChar(S);
  Result := '';
  while NextChar <> nil do
  begin
    Line := TakeOneLine(NextChar);
    if Trim(Line) <> '' then
      if Result <> '' then
        Result := Result + CRLF + Line
      else
        Result := Line;
  end;
end;

function ExtractNumberChars(var APchr: PWideChar;
  AAceptDpAndSign: Boolean = False): AnsiString; overload;
{ Returns numeric text from start of a String }
const
  n = #0;
begin
  Result := '';
  while (APchr[0] <> n) and not ISNumeric(APchr[0], AAceptDpAndSign) do
    inc(APchr);
  while (APchr[0] <> n) and ISNumeric(APchr[0], AAceptDpAndSign) do
  begin
    Result := Result + APchr[0];
    inc(APchr);
  end;
  if APchr[0] = n then
    APchr := nil;
end;

function ExtractNumber(var APchr: PWideChar): Integer;
{ Returns Integer from within an AnsiString }
var
  S: UnicodeString;
const
  n = #0;
begin
  Result := 0;
  S := '';
  while (APchr[0] <> n) and not ISNumeric(APchr[0]) do
    inc(APchr);
  while (APchr[0] <> n) and ISNumeric(APchr[0]) do
  begin
    S := S + APchr[0];
    inc(APchr);
  end;
  if APchr[0] = n then
    APchr := nil;
  if S <> '' then
    Result := StrToInt(S);
end;

function TakeOneLine(var InStr: PWideChar; AddTerms: UniCodeCharSet = [];
  ATrimOff: UniCodeCharSet = [CR, LF]): UnicodeString;
{ With addterms= [] returns a String from Instr[0] to the first Cr, Lf or nul
  InStr is nul if end is encountered otherwise advance to first no termination AnsiChar
  Termination chars can be increased by adding to [addterms] }
var
  i: Integer;
  Done: Boolean;
begin
  i := 0;
  Result := '';
  if InStr = nil then
    Exit;
  Done := False;
  while not Done do
  begin
    if (InStr[i] in ([CR, LF] + AddTerms)) or (InStr[i] = #0) then
    begin
      Result := System.Copy(InStr, 0, i);
      Done := True;
    end;
    i := i + 1;
  end;
  if InStr[i - 1] = #0 then
    InStr := nil;
  if InStr <> nil then
  begin
    while (InStr[i] in ATrimOff) and (InStr[i] <> #0) do
      i := i + 1;
    if InStr[i] = #0 then
      InStr := nil
    else
      InStr := @InStr[i];
  end;
end;
{$ENDIF}
{$IFNDEF FPC}

function ISNumeric(a: WideChar; AAceptSign: Boolean = False): Boolean;
begin
  if AAceptSign then
    Result := a in ['0' .. '9', '.', '-', '+']
  else
    Result := a in ['0' .. '9'];
end;

function ISNumeric(a: string; AAceptSign: Boolean = False): Boolean;
var
  i, lenz: Integer;
begin
  Result := True;
  i := 1 + ZSISOffset;
  lenz := length(a) + ZSISOffset;
  while Result and (i <= lenz) do
  begin
    Result := ISNumeric(a[i], AAceptSign);
    inc(i);
  end;
end;
{$ENDIF}
(*
  function TakeOneCleanLine(var InStr: PWideChar): UnicodeString; overload;
  {One line without <Html Fields>}
  var
  iStart, iEnd, StrLen, TagLen: integer;
  ss, ss2, strtag: UnicodeString;

  InStrCR, InstrBr: PWideChar;
  begin

  InStrCR := InStr;
  InstrBr := InStr;

  ss := TakeOneLine(InStrCR, []);
  strtag := HTMLExtractNextTagByType(InstrBr, 'br');
  if InstrBr = nil then
  InStr := InStrCR //back to what was
  else if (InStrCR = nil) or (InStrCR > InstrBr) then
  begin
  TagLen := Length(strtag) - 1;
  StrLen := InstrBr - Instr - TagLen;
  SetLength(ss, StrLen);
  ss := StrLCopy(PAnsiChar(ss), InStr, StrLen);
  if InstrBr[1] = AnsiChar(0) then
  Instr := nil
  else
  InStr := InstrBr + 1;
  end
  else
  InStr := InStrCR; //back to what was

  iStart := 1;
  while istart <> 0 do
  begin
  iStart := pos('<', ss);
  iEnd := pos('>', ss);
  if (iStart < iend) and (istart > 0) then
  begin
  ss2 := copy(ss, 1, istart - 1) + copy(ss, iend + 1, 255);
  ss := ss2;
  end
  else
  iStart := 0;
  end;
  Result := ss;
  end;
*)

end.
