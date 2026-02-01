{$I InnovaLibDefs.inc}
{$WARNINGS off}
{$IFDEF FPC}
// {$Define UNICODE}
{$MODE Delphi}
// {$ModeSwitch UnicodeStrings}
{$ENDIF}
unit IsArrayLib;

interface

uses
{$IFDEF FPC}
  UITypes, SysUtils, Classes, Math
{$ELSE}
{$IFDEF ISXE2_DELPHI}
{$IFDEF MSWINDOWS}
    WinApi.Windows,
{$ENDIF}
  System.UITypes, System.SysUtils, System.Classes, System.Math
{$ELSE}
  Windows, SysUtils, Classes, Math
{$ENDIF}
{$ENDIF}
{$IFDEF NextGen}
    , IsNextGenPickup
{$ENDIF}
  {ISUnicodeStrUtl};

type
  TArrayOfAnsiStrings = array of AnsiString;
  ArrayOfAnsiStrings = TArrayOfAnsiStrings;
{$IFDEF FPC}
  TArrayOfUnicodeStrings = TArrayOfAnsiStrings;
{$ELSE}
  TArrayOfUnicodeStrings = array of UnicodeString;
{$ENDIF}
  TArrayOfReal = array of real;
  TArrayofInteger = array of Integer;
  TArrayofLongWord = array of Longword;
  TArrayofObjects = array of TObject;
  TTwoDArrayofInteger = array of TArrayofInteger;
  TTwoDArrayOfAnsiString = array of ArrayOfAnsiStrings;
  TTwoDArrayOfUnicodeString = array of TArrayOfUnicodeStrings;
  TTwoDArrayofLongWord = array of TArrayofLongWord;
  TTwoDArrayofObjects = array of TArrayofObjects;
  TTwoDArrayofReal = array of TArrayOfReal;

  TArraySign = (asPlus, asMinus, asMult, asDivide, AsCopy);
  TByteSet = set of byte;

  { In Delphi, you can use the Slice function to pass a portion of
    an array of points to the Polyline method.
    For example, to form a line connecting the first
    ten points from an array of 100 points, use the Slice function as follows:
    Canvas.Polyline(Slice(PointArray, 10));
  }
procedure ResetArray(A: TArrayOfAnsiStrings); overload;
{$IFNDEF FPC}
procedure ResetArray(A: TArrayOfUnicodeStrings); overload;
{$ENDIF}
procedure ResetArray(A: TArrayOfReal); overload;
procedure ResetArray(A: TArrayofInteger); overload;
procedure ResetArray(A: TArrayofLongWord); overload;
procedure ResetArray(A: TArrayofObjects); overload;
procedure ResetArray(A: TTwoDArrayofObjects); overload;
procedure ResetArray(A: TTwoDArrayofInteger); overload;
procedure ResetArray(A: TTwoDArrayOfAnsiString); overload;
procedure ResetArray(A: TTwoDArrayOfUnicodeString); overload;
procedure ResetArray(A: TTwoDArrayofLongWord); overload;
procedure ResetArray(A: TTwoDArrayofReal); overload;
procedure ResetArray(Var A: Array of Boolean); overload;

procedure FreeObjectArray(A: TArrayofObjects); overload;
procedure FreeObjectArray(A: TTwoDArrayofObjects); overload;

function CalculateArrays(var A: TArrayofLongWord; B: TArrayofLongWord;
  Sgn: TArraySign): AnsiString; overload;
function CalculateArrays(var A: TArrayOfReal; B: TArrayOfReal; Sgn: TArraySign)
  : AnsiString; overload;
{ Returns Error AnsiString  A+B>>A A/B>>A etc }

Function ConcatArraysTo(AConcat, AAdd: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString; overload;
Function ConcatArraysTo(AConcat, AAdd: TArrayOfReal): TArrayOfReal; overload;
Function ConcatArraysTo(AConcat, AAdd: TArrayofInteger)
  : TArrayofInteger; overload;
Function ConcatArraysTo(AConcat, AAdd: TArrayofObjects)
  : TArrayofObjects; overload;
Function ConcatArraysTo(AConcat, AAdd: TArrayOfAnsiStrings)
  : TArrayOfAnsiStrings; overload;

procedure ConcatArrays(var AConcat: TTwoDArrayOfAnsiString;
  AAdd: TTwoDArrayOfAnsiString); overload;
procedure ConcatArrays(var AConcat: TArrayOfReal; AAdd: TArrayOfReal); overload;
procedure ConcatArrays(var AConcat: TArrayofInteger;
  AAdd: TArrayofInteger); overload;
procedure ConcatArrays(var AConcat: TArrayofObjects;
  AAdd: TArrayofObjects); overload;
procedure ConcatArrays(var AConcat: TArrayOfAnsiStrings;
  AAdd: TArrayOfAnsiStrings); overload;

procedure ConcatTwoDArrayInX(var AConcat: TTwoDArrayOfAnsiString;
  AAdd: TTwoDArrayOfAnsiString; AMinColsInLHS: Integer; ATrunk: Boolean = false;
  APadRowValue: TArrayOfAnsiStrings = nil; APadColValue: String = ''); overload;
// Add AAdd[i] to AConcat[i] starting at last Col or APad (ATrunk replace original data after APad)

Procedure InsertIntoArray(var AArray: TArrayofObjects;
  AInsertAt, AInsertNo: Integer); overload;
// Inserts nils into Array
Procedure InsertIntoArray(var AArray: TArrayofInteger;
  AInsertAt, AInsertNo: Integer); overload;
// Inserts 0s into Array

procedure MergeIntoTwoDArray(var AMergeInto, AMergeFrom: TTwoDArrayofInteger;
  AMergCol: Integer = 0; AThenMergeBack: Boolean = false;
  AActionCols: TByteSet = []; AAction: TArraySign = AsCopy); overload;
// Find Into Rows where a new From row would be inserted in a two d array sorted  on Column AMergCol
// AMergCol is No duplicates
// Create the new row if not existing
// if AsCopy Replace values in Action Column(s) else  ASSum >> add new values etc.
// Merge back brings the new merged array into AMergeFrom

function CopyArray(AToCopy: TArrayOfAnsiStrings): TArrayOfAnsiStrings; overload;
function CopyArray(AToCopy: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString; overload;
function CopyArray(AToCopy: TTwoDArrayofInteger): TTwoDArrayofInteger; overload;
function CopyArray(AToCopy: TArrayOfReal): TArrayOfReal; overload;
function CopyArray(AToCopy: TArrayofInteger): TArrayofInteger; overload;
function CopyArray(AToCopy: TArrayofObjects): TArrayofObjects; overload;

function MinLongValue(const Data: TArrayofLongWord): Longword; overload;
function MinRealArrayVal(AValArray: array of real): real;
function MaxRealArrayVal(AValArray: array of real): real;
function MaxIntegerArrayVal(AValArray: array of Integer): Integer;
function MaxLWordArrayVal(AValArray: array of Longword): Longword;

Function AnsiArrayToUCArray(A: TArrayOfAnsiStrings)
  : TArrayOfUnicodeStrings; overload;
Function AnsiArrayToUCArray(A: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfUnicodeString; overload;

Function UCArrayToAnsiArray(A: TArrayOfUnicodeStrings)
  : TArrayOfAnsiStrings; overload;

Function UCArrayToAnsiArray(A: array of String): TArrayOfAnsiStrings; overload;

Function UCArrayToAnsiArray(A: TTwoDArrayOfUnicodeString)
  : TTwoDArrayOfAnsiString; overload;

Function NextColVacant(AArray: TArrayofObjects; AStartSearch: Integer)
  : Integer; overload;
Function NextColVacant(AArray: TArrayOfAnsiStrings; AStartSearch: Integer)
  : Integer; overload;
{$IFNDEF FPC}
Function NextColVacant(AArray: TArrayOfUnicodeStrings; AStartSearch: Integer)
  : Integer; overload;
{$ENDIF}
Function NextColBlkVacant(AArray: TTwoDArrayofObjects;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;
{ returns first col => AStartColSearch that has all cells frm Start to finish vacant }
{ if finish<start go to end }
Function NextColBlkVacant(AArray: TTwoDArrayOfAnsiString;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;
Function NextColBlkVacant(AArray: TTwoDArrayOfUnicodeString;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;

Procedure SetAllSameLength(AArray: TTwoDArrayofObjects); overload;
{ Set all "rows" to same length }
Procedure SetAllSameLength(AArray: TTwoDArrayofObjects;
  ANewLength: Integer); overload;

function GetAssociatedNumberArray(AArray: TTwoDArrayofObjects;
  AMaxNumber: Integer): TTwoDArrayofInteger; overload;
{ Returns  Result[x,x]=number such that number is not the same as
  Result[x-1,x],Result[x+1,x],Result[x,x-1],Result[x,x+1] unless
  the corresponding AArray values are also equal.
  Example use - to set colour of element [x,x] }

function StringArrayOfValue(AValArray: TArrayofInteger)
  : TArrayOfAnsiStrings; overload;
{ Returns  Strings 1 , -88 in an Array }
function StringArrayOfValue(AValArray: TArrayofLongWord)
  : TArrayOfAnsiStrings; overload;
{ Returns  Strings 1 , 88 in an Array }

function ArrayTotal(const AInput: TTwoDArrayofInteger)
  : TArrayofInteger; overload;
function ArrayTotal(const AInput: TTwoDArrayofLongWord)
  : TArrayofLongWord; overload;
function ArrayTotal(const AInput: TArrayofLongWord): Longword; overload;
function ArrayTotal(const AInput: TArrayofInteger): Integer; overload;

function FindInsertArrayRow(var AArray: TTwoDArrayofInteger;
  AValue, AValueCol: Integer; AInsert: Boolean = false;
  ADefaultLen: Integer = 0): Integer; overload;
// Find Row where a new row would be inserted in a two d array sorted  on Column AValueCol
// Create a new row if AInsert = true

function StringArrayOfValue(AValArray: TTwoDArrayofLongWord)
  : TTwoDArrayOfAnsiString; overload;
{ Returns  Strings 1 , 8 in an Two D Array }
function StringArrayOfValue(AValArray: TTwoDArrayofInteger)
  : TTwoDArrayOfAnsiString; overload;
{ Returns  Strings 1 , 8 in an Two D Array }
function TransposeArray(AToTranspose: TTwoDArrayofInteger)
  : TTwoDArrayofInteger; overload;
function TransposeArray(AToTranspose: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString; overload;
function TransposeArray(AToTranspose: TTwoDArrayOfUnicodeString)
  : TTwoDArrayOfAnsiString; overload;
function TransposeArray(AToTranspose: TTwoDArrayofReal)
  : TTwoDArrayofReal; overload;
function TransposeArray(AToTranspose: TTwoDArrayofObjects)
  : TTwoDArrayofObjects; overload;
function GetAnsiArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings;

function GetArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings; overload;

function GetArrayStrSepString(const AData, ASep: AnsiString;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings; overload;

{$IFDEF ISXE8_DELPHI}
function GetArrayBracketSepString(AData: AnsiString)
  : TArrayOfAnsiStrings; overload;
{ Extracts Array ['junk','fgfgg','more junk','fg,','fg'] from some junk(fgfgg). more junk(fg,) (fg) }
{ Trims Punctuation and space outside brackets - Trims inside Bracket- Removes nulls }
{$ENDIF}
function GetArrayFromAlphaNumericString(AData: AnsiString;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TArrayOfAnsiStrings; overload;
{ Extracts Array ['junk','7777','more junk','88,','fg'] from
  junk7777more junk88fg }
{ ASepControls splits on spaces lf etc if Asigns then signs are numeric ditto Adollars
  {Splits array into numerics and non numerics - Removes nulls }

{$IFNDEF FPC}
function GetNumericArrayFromAlphaNumericString(AData: String;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TArrayOfUnicodeStrings;
{ Extracts Array ['7777','88'] from
  junk7777more junk88fg }
{ ASepControls splits on spaces lf etc if Asigns then signs are numeric ditto Adollars
  {Splits array into numerics and ignors non numerics - Removes nulls }
{$ENDIF}
function GetAnsiArrayFromAlphaNumericStringList(AStrings: TStrings;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TTwoDArrayOfAnsiString;

function IsNumArray(AArray: TTwoDArrayOfAnsiString): Boolean; overload;
function IsNumArray(AArray: TArrayOfAnsiStrings): Boolean; overload;

function GetRangeSet(AArray: TArrayOfAnsiStrings; ACaseSense: Boolean = false)
  : TArrayOfAnsiStrings; overload;
function GetRangeSet(AArray: TArrayofInteger): TArrayofInteger; overload;
function GetRangeSet(AArray: TArrayofLongWord): TArrayofLongWord; overload;
function MaxNoOccurancesInCol(AArray: TTwoDArrayOfAnsiString; ACol: Integer;
  ACaseSense: Boolean = false): Integer; overload;
function MaxNoOccurancesInCol(AArray: TTwoDArrayofInteger; ACol: Integer)
  : Integer; overload;
function MaxNoOccurancesInCol(AArray: TTwoDArrayofLongWord; ACol: Integer)
  : Integer; overload;

function GetColunmRangeSet(AArray: TTwoDArrayOfAnsiString; ACol: Integer;
  ACaseSense: Boolean = false): TArrayOfAnsiStrings; overload;

function GetColunmRangeSet(AArray: TTwoDArrayofInteger; ACol: Integer)
  : TArrayofInteger; overload;

function StrArrayToInt(AArray: TArrayOfAnsiStrings; ADef: Integer = 0)
  : TArrayofLongWord; overload;

function GetColunm(AArray: TTwoDArrayOfAnsiString; ACol: Integer)
  : TArrayOfAnsiStrings; overload;

function GetColunm(AArray: TTwoDArrayofInteger; ACol: Integer)
  : TArrayofInteger; overload;

function GetColunm(AArray: TTwoDArrayOfUnicodeString; ACol: Integer)
  : TArrayOfUnicodeStrings; overload;

function GetColunm(AArray: TTwoDArrayofLongWord; ACol: Integer)
  : TArrayofLongWord; overload;

{$IFDEF UNICODE}
Procedure SetLengthUnique(var AArray: TTwoDArrayOfUnicodeString); overload;
// creates a unique copy of the array and of all strings

function GetArrayStrSepString(const AData, ASep: UnicodeString;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfUnicodeStrings; overload;

function GetArrayFromString(const S: UnicodeString; SepVal: WideChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfUnicodeStrings; overload;

function DropZeroColsInArray(AArray: TTwoDArrayOfUnicodeString;
  AFirstCol, ALastCol: Integer; AFirstTestRow: Integer = 0;
  ALastTestRow: Integer = MaxInt; AConsiderZeroIfTextAfter: Boolean = false)
  : TArrayofInteger; overload;
// Leaves only columns that have a number somewhere
// Mod march 2014 will consider Zero if Text precedes number

function GetArrayFromAlphaNumericString(AData: string;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TArrayOfUnicodeStrings; overload;
function IsNumArray(AArray: TTwoDArrayOfUnicodeString): Boolean; overload;
function IsNumArray(AArray: TArrayOfUnicodeStrings): Boolean; overload;
function GetUnicodeArrayFromAlphaNumericStringList(AStrings: TStrings;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TTwoDArrayOfUnicodeString;
function GetRangeSet(AArray: TArrayOfUnicodeStrings;
  ACaseSense: Boolean = false): TArrayOfUnicodeStrings; overload;
function GetColunmRangeSet(AArray: TTwoDArrayOfUnicodeString; ACol: Integer;
  ACaseSense: Boolean = false): TArrayOfUnicodeStrings; overload;

function MaxNoOccurancesInCol(AArray: TTwoDArrayOfUnicodeString; ACol: Integer;
  ACaseSense: Boolean = false): Integer; overload;

function StrArrayToInt(AArray: TArrayOfUnicodeStrings; ADef: Integer = 0)
  : TArrayofLongWord; overload;

procedure IncrementArrayByStrings(Var ACountArray: TArrayofInteger;
  AListOfColNames: TStringList; AIncList: TStrings);
// ACountArray has a col for each entry in AListOfColNames;
// For each occurence of a name in AIncList the inc(ACountArray[column])

procedure RemoveArrayColumn(var AArray: TTwoDArrayOfUnicodeString;
  AColToDrop: Integer); overload;

procedure RemoveArrayColumns(var AArray: TTwoDArrayOfUnicodeString;
  AColDrop: TArrayofInteger); overload;

{$ENDIF}
function GetAnsiArrayFromConstArray(AArray: array of String)
  : TArrayOfAnsiStrings; overload;
{$IFDEF NEXTGEN}
{$ELSE}     // Functions Only in Non NextGen  >> Old Compiler
{$IFNDEF FPC}
function GetAnsiArrayFromConstArray(AArray: array of AnsiString)
  : TArrayOfAnsiStrings; overload;
{$ENDIF}
{$IFDEF ISXE8_DELPHI}
function GetArrayCompositSepString(Const AData: AnsiString;
  ASepArray: array of String; ARemoveQuote: Boolean = false;
  ATrim: Boolean = True; ADropNulls: Boolean = false;
  AIgnorBracketData: Boolean = false): TArrayOfAnsiStrings; overload;
{$ENDIF}
{$ENDIF}
function GetUnicodeArrayFromConstArray(AArray: array of UnicodeString)
  : TArrayOfUnicodeStrings;
function GetRealArrayFromConstArray(AArray: array of real): TArrayOfReal;

function GetTwoDAnsiArrayWithHeader(Const AHeader: String; ABlankRows: Integer)
  : TTwoDArrayOfAnsiString;
// Returns a Two D Array with ABlackRows followed by a single entry array with Header Data

function ArrayAsSeperatedString(AArray: TArrayOfAnsiStrings; ASepChar: AnsiChar;
  ASuppressIfNull: Boolean = True): AnsiString; overload;
// Reverse Of GetArrayFromString

function ArrayAsSeperatedString(AArray: TArrayOfUnicodeStrings;
  ASepChar: WideChar; ASuppressIfNull: Boolean = True): UnicodeString; overload;
// Reverse Of GetArrayFromString

Function ArrayAsCSVLine(AArray: TArrayOfAnsiStrings;
  ASuppressIfNull: Boolean = false): AnsiString; overload;
Function ArrayAsCSVLine(AArray: TArrayOfUnicodeStrings;
  ASuppressIfNull: Boolean = false): UnicodeString; overload;

function InArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Boolean; overload;
function IndexInArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Integer; overload;
function InArray(AArray: array of UnicodeString; const ATest: UnicodeString;
  ACaseSensitive: Boolean = True): Boolean; overload;
function IndexInArray(AArray: array of UnicodeString;
  const ATest: UnicodeString; ACaseSensitive: Boolean = True): Integer;
  overload;
function InArray(AArray: array of Integer; ATest: Integer): Boolean; overload;
function IndexInArray(AArray: array of Integer; ATest: Integer)
  : Integer; overload;
function InArray(AArray: array of Longword; ATest: Longword): Boolean; overload;
function IndexInArray(AArray: array of Longword; ATest: Longword)
  : Integer; overload;
function InArray(AArray: array of real; ATest: real): Boolean; overload;
function IndexInArray(AArray: array of real; ATest: real): Integer; overload;
function InArray(AArray: TArrayofObjects; ATest: TObject): Boolean; overload;
function IndexInArray(AArray: TArrayofObjects; ATest: TObject)
  : Integer; overload;

function PosInArray(AArray: array of AnsiString; const ATest: AnsiString)
  : Boolean; overload;
function PosInArray(AArray: array of UnicodeString; const ATest: UnicodeString)
  : Boolean; overload;

function SetIndexFromArray(AValue: AnsiString;
  AChoices: TArrayOfAnsiStrings): byte;

function ConfirmValueArrayIndexSet(const AValue1, AValue2: AnsiString): Boolean;

procedure DropArrayItemByValue(var AArray: TArrayofInteger;
  AValue: Integer); overload;

procedure DropArrayItemByValue(var AArray: TArrayOfAnsiStrings;
  const AValue: AnsiString); overload;
// Drops Array Items that match AValue (Packs array)

procedure DropDuplicateItems(var AArray: TArrayofInteger); overload;
procedure DropDuplicateItems(var AArray: TArrayOfAnsiStrings); overload;
// Drops Duplicated Array Items (Packs array)

Function DropNullColsInArray(Var AArray: TArrayOfAnsiStrings): Integer;
  overload;

function DropZeroColsInArray(AArray: TTwoDArrayOfAnsiString;
  AFirstCol, ALastCol: Integer; AFirstTestRow: Integer = 0;
  ALastTestRow: Integer = MaxInt; AConsiderZeroIfTextAfter: Boolean = false)
  : TArrayofInteger; overload;
// Leaves only columns that have a number somewhere
// Mod march 2014 will consider Zero if Text precedes number

Procedure SetLengthUnique(Var AArray: TTwoDArrayOfAnsiString); overload;
// creates a unique copy of the array and of all strings
Procedure SetLengthUnique(Var AArray: TTwoDArrayofInteger); overload;
// creates a unique copy of the array
Procedure SetLengthUnique(Var AArray: TTwoDArrayofObjects); overload;
// creates a unique copy of the array
Procedure SetLengthUnique(Var AArray: TTwoDArrayofReal); overload;
// creates a unique copy of the array

procedure DropBlankRowsInArray(var AArray: TTwoDArrayOfAnsiString;
  AFirstRow, ALastRow: Integer; AFirstTestCol: Integer = 0;
  ALastTestCol: Integer = MaxInt); overload;

procedure DropBlankRowsInArray(var AArray: TTwoDArrayOfUnicodeString;
  AFirstRow, ALastRow: Integer; AFirstTestCol: Integer = 0;
  ALastTestCol: Integer = MaxInt); overload;
// Leaves only Rows that have text somewhere

Procedure PackArray(var AArray: TArrayofObjects); overload;
// Packs Arrays with nulls,Zeros or '')
Procedure PackArray(var AArray: TArrayOfAnsiStrings); overload;
{$IFNDEF FPC}
Procedure PackArray(var AArray: TArrayOfUnicodeStrings); overload;
{$ENDIF}
Procedure PackArray(var AArray: TArrayOfReal); overload;
Procedure PackArray(var AArray: TArrayofInteger); overload;

// Drops Item or Row
procedure DropArrayItemAtPos(var AArray: TArrayofInteger;
  APos: Integer); overload;
procedure DropArrayItemAtPos(var AArray: TArrayOfReal; APos: Integer); overload;
procedure DropArrayItemAtPos(var AArray: TArrayOfAnsiStrings;
  APos: Integer); overload;
{$IFNDEF FPC}
procedure DropArrayItemAtPos(var AArray: TArrayOfUnicodeStrings;
  APos: Integer); overload;
procedure DropArrayItemAtPos(var AArray: TTwoDArrayOfUnicodeString;
  APos: Integer); overload;
{$ENDIF}
procedure DropArrayItemAtPos(var AArray: TArrayofObjects;
  APos: Integer); overload;
procedure DropArrayItemAtPos(var AArray: TTwoDArrayOfAnsiString;
  APos: Integer); overload;

procedure RemoveArrayColumn(var AArray: TTwoDArrayOfAnsiString;
  AColToDrop: Integer); overload;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofInteger;
  AColToDrop: Integer); overload;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofReal;
  AColToDrop: Integer); overload;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofObjects;
  AColToDrop: Integer); overload;

procedure RemoveArrayColumns(var AArray: TTwoDArrayOfAnsiString;
  AColDrop: TArrayofInteger); overload;

procedure RemoveArrayColumns(var AArray: TTwoDArrayofInteger;
  AColDrop: TArrayofInteger); overload;

{$IFNDEF FPC}
procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfUnicodeStrings; AObjArray: TArrayofObjects = nil); overload;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfUnicodeStrings; AObj: TObject); overload;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TTwoDArrayOfUnicodeString; ASC: WideChar = #13;
  AObjArray: TArrayofObjects = nil); overload;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfAnsiStrings; AObjArray: TArrayofObjects = nil); overload;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfAnsiStrings; AObj: TObject); overload;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TTwoDArrayOfAnsiString; ASC: Char = Char(13);
  AObjArray: TArrayofObjects = nil); overload;
{$ENDIF}
function BuildArrayFromTStrings(AList: TStrings): TArrayOfAnsiStrings; overload;

function BuildArrayFromTStrings(AList: TStrings; ASepChar: AnsiChar)
  : TTwoDArrayOfAnsiString; overload;

function BuildArrayFromTStrings(AList: TStrings; ASepChar: AnsiChar;
  out ALongwordArray: TArrayofLongWord): TTwoDArrayOfAnsiString; overload;

const
  MaxValueReal: real = 1.0E15;
  // Very Big Number But allows some overflow even with Real48
  MinValueReal: real = 1.0E-15;

implementation

uses IsIndyUtils, ISStrUtl;

procedure ResetArray(A: TArrayOfAnsiStrings);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
{$IFDEF NextGen}
    A[i].Length := 0;
{$ELSE}
    SetLength(A[i], 0);
{$ENDIF}
end;

{$IFNDEF FPC}

procedure ResetArray(A: TArrayOfUnicodeStrings); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    SetLength(A[i], 0);
end;
{$ENDIF}

procedure ResetArray(A: TArrayOfReal);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i] := 0.0;
end;

procedure ResetArray(A: TArrayofInteger);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i] := 0;
end;

procedure ResetArray(A: TArrayofLongWord);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i] := 0;
end;

procedure ResetArray(A: TArrayofObjects);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i] := nil;
end;

procedure ResetArray(A: TTwoDArrayofObjects); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(A: TTwoDArrayofInteger);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(A: TTwoDArrayOfAnsiString);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(A: TTwoDArrayOfUnicodeString); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(A: TTwoDArrayofLongWord);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(A: TTwoDArrayofReal);
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    ResetArray(A[i]);
end;

procedure ResetArray(Var A: Array of Boolean); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i] := false;
end;

procedure FreeObjectArray(A: TArrayofObjects); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    try
      FreeAndNil(A[i]);
    except
      On E: Exception do
        ISIndyUtilsException('ISArrayLib', E, 'FreeObjectArray');
    end;
end;

procedure FreeObjectArray(A: TTwoDArrayofObjects); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    try
      FreeObjectArray(A[i]);
    except
      On E: Exception do
        ISIndyUtilsException('ISArrayLib', E, '2D FreeObjectArray');
    end;
end;

function StringArrayOfValue(AValArray: TArrayofInteger)
  : TArrayOfAnsiStrings; overload;
{ Returns  Strings 1 , -8 in an Array }
var
  i, Cols: Integer;
begin
  Cols := high(AValArray) + 1;
  SetLength(Result, Cols);
  for i := 0 to Cols - 1 do
    Result[i] := IntToStr(AValArray[i]);
end;

function StringArrayOfValue(AValArray: TArrayofLongWord)
  : TArrayOfAnsiStrings; overload;
{ Returns  Strings 1 , 8 in an Array }
var
  i, Cols: Integer;
begin
  Cols := high(AValArray) + 1;
  SetLength(Result, Cols);
  for i := 0 to Cols - 1 do
    Result[i] := IntToStr(AValArray[i]);
end;

function StringArrayOfValue(AValArray: TTwoDArrayofLongWord)
  : TTwoDArrayOfAnsiString; overload;
var
  i, Rows: Integer;
begin
  Rows := high(AValArray) + 1;
  SetLength(Result, Rows);
  for i := 0 to Rows - 1 do
    Result[i] := StringArrayOfValue(AValArray[i]);
end;

function StringArrayOfValue(AValArray: TTwoDArrayofInteger)
  : TTwoDArrayOfAnsiString; overload;
var
  i, Rows: Integer;
begin
  Rows := high(AValArray) + 1;
  SetLength(Result, Rows);
  for i := 0 to Rows - 1 do
    Result[i] := StringArrayOfValue(AValArray[i]);
end;

function TransposeArray(AToTranspose: TTwoDArrayofInteger)
  : TTwoDArrayofInteger; overload;
var
  i, j, Len: Integer;
begin
  j := 0;
  Len := high(AToTranspose) + 1;
  for i := 0 to high(AToTranspose) do
    if j < high(AToTranspose[i]) then
      j := high(AToTranspose[i]);

  SetLength(Result, j + 1);
  for j := 0 to high(Result) do
    SetLength(Result[j], Len);

  for i := 0 to Len - 1 do
  begin
    for j := 0 to high(AToTranspose[i]) do
      Result[j, i] := AToTranspose[i, j];
  end;
end;

function TransposeArray(AToTranspose: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString; overload;
var
  i, j, Len: Integer;
begin
  j := 0;
  Len := high(AToTranspose) + 1;
  for i := 0 to high(AToTranspose) do
    if j < high(AToTranspose[i]) then
      j := high(AToTranspose[i]);

  SetLength(Result, j + 1);
  for j := 0 to high(Result) do
    SetLength(Result[j], Len);

  for i := 0 to Len - 1 do
  begin
    for j := 0 to high(AToTranspose[i]) do
      Result[j, i] := AToTranspose[i, j];
  end;
end;

function TransposeArray(AToTranspose: TTwoDArrayOfUnicodeString)
  : TTwoDArrayOfAnsiString; overload;
var
  i, j, Len: Integer;
begin
  j := 0;
  Len := high(AToTranspose) + 1;
  for i := 0 to high(AToTranspose) do
    if j < high(AToTranspose[i]) then
      j := high(AToTranspose[i]);

  SetLength(Result, j + 1);
  for j := 0 to high(Result) do
    SetLength(Result[j], Len);

  for i := 0 to Len - 1 do
  begin
    for j := 0 to high(AToTranspose[i]) do
      Result[j, i] := AToTranspose[i, j];
  end;
end;

function TransposeArray(AToTranspose: TTwoDArrayofReal)
  : TTwoDArrayofReal; overload;
var
  i, j, Len: Integer;
begin
  j := 0;
  Len := high(AToTranspose) + 1;
  for i := 0 to high(AToTranspose) do
    if j < high(AToTranspose[i]) then
      j := high(AToTranspose[i]);

  SetLength(Result, j + 1);
  for j := 0 to high(Result) do
    SetLength(Result[j], Len);

  for i := 0 to Len - 1 do
  begin
    for j := 0 to high(AToTranspose[i]) do
      Result[j, i] := AToTranspose[i, j];
  end;
end;

function TransposeArray(AToTranspose: TTwoDArrayofObjects)
  : TTwoDArrayofObjects; overload;
var
  i, j, Len: Integer;
begin
  j := 0;
  Len := high(AToTranspose) + 1;
  for i := 0 to high(AToTranspose) do
    if j < high(AToTranspose[i]) then
      j := high(AToTranspose[i]);

  SetLength(Result, j + 1);
  for j := 0 to high(Result) do
    SetLength(Result[j], Len);

  for i := 0 to Len - 1 do
  begin
    for j := 0 to high(AToTranspose[i]) do
      Result[j, i] := AToTranspose[i, j];
  end;
end;

{$IFDEF ISXE8_DELPHI}

function GetArrayBracketSepString(AData: AnsiString)
  : TArrayOfAnsiStrings; overload;
{ Extracts Array ['junk','fgfgg','more junk','fg,','fg'] from some junk(fgfgg). more junk(fg,) (fg) }
{ Trims Punctuation and space outside brackets - Trims inside Bracket- Removes nulls }
Var
  Rcrds, cursz: Integer;
  NextChar, StartChar: PAnsiChar;
  Nxt { , NewNxt } : Integer;
  LeftStr, BckStr, LastStr: AnsiString;
begin
  SetLength(Result, 0);
  if AData = '' then
    exit;

  Rcrds := 0;
  cursz := 0;
  LeftStr := AData;
  Nxt := 1 + ZSISOffset;
  NextChar := PAnsiChar(AData);
  while NextChar <> nil do
  begin
    if Rcrds < (cursz + 2) then
    Begin
      inc(Rcrds, 6);
      SetLength(Result, Rcrds);
    End;
    StartChar := NextChar;
    BckStr := ExtractNextBracket(NextChar);
    if BckStr = '' then
      LastStr := Copy(AData, Nxt, Length(AData))
    else
      LastStr := Copy(AData, Nxt, Pos(BckStr, AData) - 1 - Nxt);
    LastStr := TrimWthAll(LastStr, ['''', '"']);
    BckStr := Trim(BckStr);
    if NextChar <> nil then
      Nxt := Nxt + NextChar - StartChar;
    if LastStr <> '' then
    Begin
      Result[cursz] := LastStr;
      inc(cursz);
    End;
    if BckStr <> '' then
    Begin
      Result[cursz] := BckStr;
      inc(cursz);
    End;
  end;
  SetLength(Result, cursz);
end;
{$ENDIF}

function GetArrayStrSepString(const AData, ASep: AnsiString;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings;

var
  Rcrds, cursz: Integer;
  NextChar, SecondQuoteChar: PAnsiChar;
  QuoteVal: Char;
  S, QuoteString: AnsiString;
  TstChar: Char;
begin
  SetLength(Result, 0);
  if AData = '' then
    exit;
  if ASep = '' then
  begin
    SetLength(Result, 1);
    Result[0] := AData;
    exit;
  end;

  Rcrds := 0;
  cursz := 0;
{$IFDEF NextGen}
  NextChar := AData;
  while NextChar.Length <> 0 do
  begin
    inc(Rcrds);
    if Rcrds > cursz then
    begin
      inc(cursz, 5);
      SetLength(Result, cursz);
    end;

    QuoteVal := Char(NextChar[0]);
    if ARemoveQuote and (QuoteVal in ['''', '"', '[', '{', '(', '<']) then
    Begin
      TstChar := Char(NextChar[0]);
      case TstChar of
        '''', '"':
          QuoteVal := NextChar[0];
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := NextChar[0];
      end;
      QuoteString := QuoteVal;
      SecondQuoteChar := StrPos(NextChar + 1, PAnsiChar(QuoteString));
      if (Pointer(SecondQuoteChar) <> nil) and
        ((byte(SecondQuoteChar[1]) = 0) or (StrPos(SecondQuoteChar + 1,
        PAnsiChar(ASep)) = SecondQuoteChar + 1)) then
      begin
        inc(NextChar);
        S := SepStrg(NextChar, QuoteVal);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        S := SepStrg(NextChar, ASep);
    End
    else
      S := SepStrg(NextChar, ASep);
{$ELSE}
  NextChar := @AData[1];
  while NextChar <> nil do
  begin
    inc(Rcrds);
    if Rcrds > cursz then
    begin
      inc(cursz, 5);
      SetLength(Result, cursz);
    end;

    QuoteVal := Char(NextChar[0]);
    if ARemoveQuote and (QuoteVal in ['''', '"', '[', '{', '(', '<']) then
    Begin
      TstChar := Char(NextChar[0]);
      case TstChar of
        '''', '"':
          QuoteVal := Char(NextChar[0]);
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := Char(NextChar[0]);
      end;
      QuoteString := QuoteVal;
      SecondQuoteChar := StrPos(NextChar + 1, PAnsiChar(QuoteString));
      if (SecondQuoteChar <> nil) and
        ((SecondQuoteChar[1] = #0) or (StrPos(SecondQuoteChar + 1,
        PAnsiChar(ASep)) = SecondQuoteChar + 1)) then
      begin
        inc(NextChar);
        S := SepStrg(NextChar, QuoteVal);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        S := SepStrg(NextChar, ASep);
    End
    else
      S := SepStrg(NextChar, ASep);
{$ENDIF}
    if ATrim then
      S := Trim(S);

    Result[Rcrds - 1] := S;
    if (S = '') and (ADropNulls or (Rcrds = 1)) then
      Dec(Rcrds);
  end;

  SetLength(Result, Rcrds);
end;

function GetArrayFromAlphaNumericString(AData: AnsiString;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TArrayOfAnsiStrings; overload;

{ sub } function GetFlag(AChar: Char): Integer;
  begin
    case AChar of
      'A' .. 'Z', 'a' .. 'z':
        Result := 1;
      '0' .. '9':
        Result := 2;
      '+', '-':
        if ASigns then
          Result := 2
        else
          Result := 0;
      '$':
        if ADollars then
          Result := 2
        else
          Result := 0;
    else
      Result := 0;
    end;
  end;
{ sub } function UnMatchedFlags(var AFlgA, AFlgB: Integer): Boolean;
  begin
    Result := AFlgA <> AFlgB;
    if Result and not ASepControls then
      if (AFlgA < 2) and (AFlgB < 2) then
        Result := false;
    AFlgA := AFlgB;
  end;

var
  Rcrds, cursz: Integer;
  NextChar: PAnsiChar;
  BytePtr: ^byte;
  AlphaFlg, NxtAlphaFlag, i: Integer;
  S: AnsiString;
begin
  SetLength(Result, 0);
  if AData = '' then
    exit;

  Rcrds := 1;
  cursz := 0;
  NextChar := PAnsiChar(AData);
  AlphaFlg := GetFlag(Char(NextChar[0]));
  while Pointer(NextChar) <> nil do
  begin
    BytePtr := Pointer(NextChar);
    inc(BytePtr); // NextChar[1]
    S := '';
    i := 0;
    if Rcrds >= cursz then
    begin
      inc(cursz, 5);
      SetLength(Result, cursz);
    end;
    while (S = '') and (BytePtr^ <> 0) do
    begin
      NxtAlphaFlag := GetFlag(Char(BytePtr^));
      // NxtAlphaFlag := GetFlag(Char(NextChar[i + 1]));
      if UnMatchedFlags(AlphaFlg, NxtAlphaFlag) then
      begin
{$IFDEF NextGen}
        S := NextChar.Copy(0, i + 1);
{$ELSE}
        S := Copy(NextChar, 0, i + 1);
{$ENDIF}
        Result[Rcrds - 1] := S;
        inc(NextChar, i + 1);
        inc(Rcrds);
        AlphaFlg := GetFlag(Char(NextChar[0]));
        i := 0;
      end;
      inc(i);
      inc(BytePtr);
    end;
    if S = '' then
    begin
      Result[Rcrds - 1] := NextChar;
      NextChar := nil;
    end;
  end;
  SetLength(Result, Rcrds);
end;

function GetAnsiArrayFromAlphaNumericStringList(AStrings: TStrings;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TTwoDArrayOfAnsiString;
var
  i: Integer;
  Data: AnsiString;
begin
  SetLength(Result, 0);
  if AStrings = nil then
    exit;
  if AStrings.Count < 1 then
    exit;

  SetLength(Result, AStrings.Count);
  for i := 0 to AStrings.Count - 1 do
  begin
    Data := AStrings[i];
    Result[i] := GetArrayFromAlphaNumericString(Data, ASepControls, ASigns,
      ADollars);
  end;
end;

function IsNumArray(AArray: TTwoDArrayOfAnsiString): Boolean; overload;
var
  i: Integer;
  Lenz: Integer;
begin
  Result := True;
  Lenz := Length(AArray);
  i := 0;
  while Result and (i < Lenz) do
  begin
    Result := IsNumArray(AArray[i]);
    inc(i);
  end;
end;

function IsNumArray(AArray: TArrayOfAnsiStrings): Boolean; overload;
var
  i: Integer;
  Lenz: Integer;
begin
  Result := True;
  Lenz := Length(AArray);
  i := 0;
  while Result and (i < Lenz) do
  begin
    Result := ISNumeric(Trim(AArray[i]), True);
    inc(i);
  end;
end;

function GetRangeSet(AArray: TArrayofInteger): TArrayofInteger; overload;
var
  Rcrds, cursz, i, HighZ: Integer;
  Tst: Integer;
begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  Rcrds := 0;
  if InArray(AArray, 0) then
    inc(Rcrds);
  cursz := 0;
  for i := 0 to HighZ do
  begin
    Tst := AArray[i];
    if not InArray(Result, Tst) then
    begin
      If Tst <> 0 then
        inc(Rcrds);
      if Rcrds > cursz then
      begin
        inc(cursz, 5);
        SetLength(Result, cursz);
      end;
      Result[Rcrds - 1] := Tst;
    end;
  end;
  SetLength(Result, Rcrds);
end;

function GetRangeSet(AArray: TArrayofLongWord): TArrayofLongWord; overload;
Var
  Rslt: TArrayofInteger;
Begin
  Rslt := GetRangeSet(TArrayofInteger(AArray));
  Result := TArrayofLongWord(Rslt);
End;

function GetRangeSet(AArray: TArrayOfAnsiStrings; ACaseSense: Boolean = false)
  : TArrayOfAnsiStrings;
var
  Rcrds, cursz, i, HighZ: Integer;
  Tst: AnsiString;
begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  Rcrds := 0;
  if InArray(AArray, '') then
    inc(Rcrds);
  cursz := 0;
  for i := 0 to HighZ do
  begin
    if ACaseSense then
      Tst := Trim(AArray[i])
    else
      Tst := Trim(Lowercase(AArray[i]));
    if not InArray(Result, Tst) then
    begin
      If Tst <> '' then
        inc(Rcrds);
      if Rcrds > cursz then
      begin
        inc(cursz, 5);
        SetLength(Result, cursz);
      end;
      Result[Rcrds - 1] := Tst;
    end;
  end;
  SetLength(Result, Rcrds);
end;

function MaxNoOccurancesInCol(AArray: TTwoDArrayOfAnsiString; ACol: Integer;
  ACaseSense: Boolean = false): Integer; overload;
var
  Rcrd, i, HighZ, HighCnt: Integer;
  LwrCaseSet: TArrayOfAnsiStrings;
  RsltCount: TArrayofInteger;
  Tst: AnsiString;
  RsltSet: TStringList;
begin
  Result := -1;
  HighZ := Length(AArray);
  if HighZ < 1 then
    exit;

  SetLength(LwrCaseSet, HighZ);
  SetLength(RsltCount, HighZ + 1);
  Dec(HighZ);
  RsltSet := TStringList.Create;
  try
    RsltSet.Add('');
    for i := 0 to HighZ do
    begin
      if ACol > High(AArray[i]) then
        Tst := ''
      else if ACaseSense then
        Tst := Trim(AArray[i, ACol])
      else
        Tst := Trim(Lowercase(AArray[i, ACol]));
      LwrCaseSet[i] := Tst;
      Rcrd := RsltSet.indexof(Tst);
      if Rcrd < 0 then
        Rcrd := RsltSet.Add(Tst);
      inc(RsltCount[Rcrd]);
    end;
    HighCnt := -1;
    for i := 0 to RsltSet.Count - 1 do
      if RsltCount[i] > HighCnt then
      begin
        HighCnt := RsltCount[i];
        Tst := RsltSet[i];
      end;

    i := 0;
    while (Result < 0) and (i <= HighZ) do
    begin
      if Tst = LwrCaseSet[i] then
        Result := i;
      inc(i);
    end;
  finally
    RsltSet.Free;
  end;
end;

function MaxNoOccurancesInCol(AArray: TTwoDArrayofInteger; ACol: Integer)
  : Integer; overload;
var
  Rcrd, i, HighZ, HighCnt: Integer;
  RsltCount: TArrayofInteger;
  Tst: Pointer;
  RsltSet: TList;
begin
  Result := -1;
  Tst := nil;
  HighZ := Length(AArray);
  if HighZ < 1 then
    exit;

  SetLength(RsltCount, HighZ + 1);
  Dec(HighZ);
  RsltSet := TList.Create;
  try
    RsltSet.Add(nil);
    for i := 0 to HighZ do
    begin
      if ACol > High(AArray[i]) then
        Tst := nil
      else
        Tst := Pointer(AArray[i, ACol]);
      Rcrd := RsltSet.indexof(Tst);
      if Rcrd < 0 then
        Rcrd := RsltSet.Add(Tst);
      inc(RsltCount[Rcrd]);
    end;
    HighCnt := -1;
    for i := 0 to RsltSet.Count - 1 do
      if RsltCount[i] > HighCnt then
      begin
        HighCnt := RsltCount[i];
        Tst := RsltSet[i];
      end;
    i := 0;
    while (Result < 0) and (i <= HighZ) do
    begin
      if Integer(Tst) = AArray[i, ACol] then
        Result := i;
      inc(i);
    end;
  finally
    RsltSet.Free;
  end;
end;

function MaxNoOccurancesInCol(AArray: TTwoDArrayofLongWord; ACol: Integer)
  : Integer; overload;
begin
  Result := MaxNoOccurancesInCol(TTwoDArrayofInteger(AArray), ACol);
end;

function GetColunmRangeSet(AArray: TTwoDArrayOfAnsiString; ACol: Integer;
  ACaseSense: Boolean = false): TArrayOfAnsiStrings;
var
  HighZ: Integer;
  ThisCol: TArrayOfAnsiStrings;

begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  ThisCol := GetColunm(AArray, ACol);
  Result := GetRangeSet(ThisCol, ACaseSense);
end;
{ var
  Rcrds, cursz, i, HighZ: Integer;
  Tst: AnsiString;
  begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then exit;

  Rcrds := 0;
  cursz := 0;
  for i := 0 to HighZ do
  if ACol < Length(AArray[i]) then
  begin
  if ACaseSense then Tst := Trim(AArray[i, ACol])
  else Tst := Trim(Lowercase(AArray[i, ACol]));
  if not InArray(Result, Tst) then
  begin
  inc(Rcrds);
  if Rcrds > cursz then
  begin
  inc(cursz, 5);
  SetLength(Result, cursz);
  end;
  Result[Rcrds - 1] := Tst;
  end;
  end;
  SetLength(Result, Rcrds);
  end;
}

function GetColunmRangeSet(AArray: TTwoDArrayofInteger; ACol: Integer)
  : TArrayofInteger; overload;
var
  HighZ: Integer;
  ThisCol: TArrayofInteger;

begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  ThisCol := GetColunm(AArray, ACol);
  Result := GetRangeSet(ThisCol);
end;

function StrArrayToInt(AArray: TArrayOfAnsiStrings; ADef: Integer = 0)
  : TArrayofLongWord;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    Result[i] := StrToIntDef(AArray[i], ADef);
end;

{$IFDEF UNICODE}

Procedure SetLengthUnique(Var AArray: TTwoDArrayOfUnicodeString); overload;
// creates a unique copy of the array and of all strings
Var
  i, j: Integer;
  NewArray: TTwoDArrayOfUnicodeString;
begin
  SetLength(NewArray, Length(AArray));
  for i := Low(AArray) to High(AArray) do
  begin
    SetLength(NewArray[i], Length(AArray[i]));
    for j := Low(AArray[i]) to High(AArray[i]) do
    begin
      NewArray[i, j] := AArray[i, j];
      UniqueString(NewArray[i, j]);
    end;
  end;
  AArray := NewArray;
end;

function DropZeroColsInArray(AArray: TTwoDArrayOfUnicodeString;
  AFirstCol, ALastCol: Integer; AFirstTestRow: Integer = 0;
  ALastTestRow: Integer = MaxInt; AConsiderZeroIfTextAfter: Boolean = false)
  : TArrayofInteger; overload;
// Leaves only columns that have a number somewhere
// Mod march 2014 will consider Zero if Text precedes number
{ sub } function NonZeroValueText(S: String): Boolean;
  var
    i, Len: Integer;
  begin
    Result := false;
    if S = '' then
      exit;

    Len := Length(S);
    i := 1 + ZSISOffset;
    while not Result and (i <= Len) do
      if S[i] in ['a' .. 'z', 'A' .. 'Z'] then
        exit
      else if S[i] in ['1' .. '9'] then
        Result := True
      else
        inc(i);
    if Result and AConsiderZeroIfTextAfter then
      while Result and (i <= Len) do
        if S[i] in ['a' .. 'z', 'A' .. 'Z'] then
          Result := false
        else
          inc(i);
  end;

var
  c, r, cActual, Last, LastRow, CurMaxResult, ResInc: Integer;
  DropIt: Boolean;

begin
  ResInc := 0;
  CurMaxResult := 0;
  SetLength(Result, 0);
  try
    c := AFirstCol;
    cActual := c - 1;
    LastRow := ALastTestRow;
    if LastRow > high(AArray) then
      LastRow := high(AArray);
    if LastRow < 0 then
      exit;

    Last := ALastCol;
    if Last > high(AArray[0]) then
    begin
      Last := 0;
      for r := 0 to high(AArray) do
        if Last < high(AArray[r]) then
          Last := high(AArray[r]);
      if Last > ALastCol then
        Last := ALastCol;
    end;

    while c <= Last do
    begin
      inc(cActual);
      DropIt := True;
      r := AFirstTestRow;
      while DropIt and (r < LastRow) do
      begin
        if c <= high(AArray[r]) then
          if NonZeroValueText(AArray[r, c]) then
            DropIt := false;
        inc(r);
      end;
      if DropIt then
      begin
        if ResInc >= CurMaxResult then
        begin
          inc(CurMaxResult, 5);
          SetLength(Result, CurMaxResult);
        end;
        Result[ResInc] := cActual;
        inc(ResInc);
        RemoveArrayColumn(AArray, c);
        Dec(Last);
      end
      else
        inc(c);
    end;
  except
{$IFDEF MSWINDOWS}
    OutputDebugStringA('DropZeroColsInArray Unicode');
{$ENDIF}
  end;
  SetLength(Result, ResInc);
end;

function GetArrayStrSepString(const AData, ASep: UnicodeString;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfUnicodeStrings; overload;
var
  Rcrds, cursz: Integer;
  NextChar, SecondQuoteChar: PWideChar;
  TstChar: Char;
  QuoteVal: Char;
  S, QuoteString: UnicodeString;
begin
  SetLength(Result, 0);
  if AData = '' then
    exit;
  if ASep = '' then
  begin
    SetLength(Result, 1);
    Result[0] := AData;
    exit;
  end;

  Rcrds := 0;
  cursz := 0;
  NextChar := @AData[1 + ZSISOffset];
  while NextChar <> nil do
  begin
    inc(Rcrds);
    if Rcrds > cursz then
    begin
      inc(cursz, 5);
      SetLength(Result, cursz);
    end;

    QuoteVal := NextChar[0];
    if ARemoveQuote and (QuoteVal in ['''', '"', '[', '{', '(', '<']) then
    Begin
      TstChar := Char(NextChar[0]);
      case TstChar of
        '''', '"':
          QuoteVal := NextChar[0];
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := NextChar[0];
      end;
      QuoteString := QuoteVal;
      SecondQuoteChar := StrPos(NextChar + 1, PChar(QuoteString));
      if (SecondQuoteChar <> nil) and
        ((SecondQuoteChar[1] = #0) or (StrPos(SecondQuoteChar + 1, PChar(ASep))
        = SecondQuoteChar + 1)) then
      begin
        inc(NextChar);
        S := SepStrg(NextChar, QuoteVal);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        S := SepStrg(NextChar, ASep);
    End
    else
      S := SepStrg(NextChar, ASep);

    if ATrim then
      S := Trim(S);

    Result[Rcrds - 1] := S;
    if (S = '') and (ADropNulls or (Rcrds = 1)) then
      Dec(Rcrds);
  end;
  SetLength(Result, Rcrds);
end;

function GetArrayFromString(const S: UnicodeString; SepVal: WideChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfUnicodeStrings; overload;
var
  i: Integer;
  NextChar, SecondQuoteChar: PWideChar;
  QuoteVal: UnicodeString;
  TstChar: Char;
  fs: UnicodeString;
begin
  SetLength(Result, 0);
  if S = '' then
    exit;
{$IFDEF NextGen}
  NextChar := PChar(S);
{$ELSE}
  NextChar := @S[1];
{$ENDIF}
  i := 0;
  while NextChar <> nil do
  begin
    if NextChar[0] = SepVal then
    begin
      inc(NextChar);
      fs := '';
    end
    else if ARemoveQuote and (NextChar[0] in ['''', '"', '[', '{', '(', '<'])
    then
    begin
      TstChar := Char(NextChar[0]);
      case TstChar of
        '''', '"':
          QuoteVal := NextChar[0];
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := NextChar[0];
      end;
      SecondQuoteChar := StrPos(PWideChar(NextChar) + 1, PWideChar(QuoteVal));
      if (SecondQuoteChar <> nil) and
        ((SecondQuoteChar[1] = SepVal) or (SecondQuoteChar[1] = #0)) then
      begin
        inc(NextChar);
        if NextChar = SecondQuoteChar then
        Begin
          fs := '';
          inc(NextChar);
        End
        else
          fs := FieldSep(NextChar, QuoteVal[1 + ZSISOffset]);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        fs := FieldSep(NextChar, SepVal);
    end
    else
      fs := FieldSep(NextChar, SepVal);
    if i > high(Result) then
      SetLength(Result, i + 6);
    if ATrim then
      Result[i] := Trim(fs)
    else
      Result[i] := fs;
    if ADropNulls And (Result[i] = '') then
    Begin
    End
    Else
      inc(i);
  end;
  SetLength(Result, i);
end;

function GetArrayFromAlphaNumericString(AData: string;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TArrayOfUnicodeStrings; overload;
var
  AResult: TArrayOfAnsiStrings;
  Data: AnsiString;
  i: Integer;
begin
  Data := AData;
  AResult := GetArrayFromAlphaNumericString(Data, ASepControls, ASigns,
    ADollars);
  SetLength(Result, Length(AResult));
  for i := 0 to high(AResult) do
    Result[i] := AResult[i];
end;

function GetNumericArrayFromAlphaNumericString(AData: String;
  ASepControls: Boolean; ASigns: Boolean; ADollars: Boolean)
  : TArrayOfUnicodeStrings;
{ Extracts Array ['7777','88'] from
  junk7777more junk88fg }
{ ASepControls splits on spaces lf etc if Asigns then signs are numeric ditto Adollars
  {Splits array into numerics and ignors non numerics - Removes nulls }

{ sub } function GetFlag(AChar: Char): Integer;
  begin
    case AChar of
      'A' .. 'Z', 'a' .. 'z':
        Result := 1;
      '0' .. '9':
        Result := 2;
      '.':
        Result := 3; // Numeric if 66.66 or .88 but not stops. Here
      '+', '-':
        if ASigns then
          Result := 2
        else
          Result := 0;
      '$':
        if ADollars then
          Result := 2
        else
          Result := 0;
    else
      Result := 0; // Non Alpha numeric
    end;
  end;
{ sub } function UnMatchedFlags(var AFlgA, AFlgB: Integer): Boolean;
  begin
    if AFlgB = 3 then
      if AFlgA = 0 then
        Result := True
      else
      begin
        Result := Not(AFlgA = 2);
        if Not Result then
          AFlgB := 2;
      end
    else
      Result := AFlgA <> AFlgB;
    if Result and not ASepControls then
      if (AFlgA < 2) and (AFlgB < 2) then
        Result := false;
    if Result then // Numeric if 66.66 or .88 but not stops. Here
      if AFlgA = 3 then
        Result := not(AFlgB = 2);
    AFlgA := AFlgB;
  end;

var
  Rcrds, cursz: Integer;
  NextChar: PChar;
  AlphaFlg, NxtAlphaFlag, TypeFlag, TstLen, i: Integer;
  S: String;
begin
  SetLength(Result, 0);
  if AData = '' then
    exit;

  Rcrds := 1;
  cursz := 0;
  NextChar := PChar(AData);
  AlphaFlg := GetFlag(Char(NextChar[0]));
  TstLen := Length(AData);
  while Pointer(NextChar) <> nil do
  begin
    S := '';
    i := 0;
    if Rcrds >= cursz then
    begin
      inc(cursz, 5);
      SetLength(Result, cursz);
    end;
    while (S = '') and (NextChar[0] <> Char(0)) and (NextChar <> nil) do
    begin
      NxtAlphaFlag := GetFlag(Char(NextChar[i + 1]));
      TypeFlag := AlphaFlg;
      if UnMatchedFlags(AlphaFlg, NxtAlphaFlag) then
      begin
        S := Copy(NextChar, 0, i + 1);
        S := Trim(S);
        if (S <> '') and (TypeFlag = 2) then
        begin
          Result[Rcrds - 1] := S;
          inc(Rcrds, 1);
        end;
        inc(NextChar, i + 1);
        TstLen := Length(NextChar);
        AlphaFlg := GetFlag(Char(NextChar[0]));
        i := 0;
      end
      else
        inc(i);
      if i > TstLen then
        NextChar := '';
    end;
    if Length(S) = 0 then
    begin
      S := NextChar;
      S := Trim(S);
      if Length(S) > 0 then
        Result[Rcrds - 1] := S
      else
        Dec(Rcrds);
      NextChar := nil;
    end;
  end;
  SetLength(Result, Rcrds);
end;

function IsNumArray(AArray: TTwoDArrayOfUnicodeString): Boolean; overload;
var
  i: Integer;
  Lenz: Integer;
begin
  Result := True;
  Lenz := Length(AArray);
  i := 0;
  while Result and (i < Lenz) do
  begin
    Result := IsNumArray(AArray[i]);
    inc(i);
  end;
end;

function IsNumArray(AArray: TArrayOfUnicodeStrings): Boolean; overload;
var
  i: Integer;
  Lenz: Integer;
begin
  Result := True;
  Lenz := Length(AArray);
  i := 0;
  while Result and (i < Lenz) do
  begin
    Result := ISNumeric(Trim(AArray[i]), True);
    inc(i);
  end;
end;

function GetUnicodeArrayFromAlphaNumericStringList(AStrings: TStrings;
  ASepControls: Boolean = false; ASigns: Boolean = false;
  ADollars: Boolean = false): TTwoDArrayOfUnicodeString;
var
  i: Integer;
begin
  SetLength(Result, 0);
  if AStrings = nil then
    exit;
  if AStrings.Count < 1 then
    exit;

  SetLength(Result, AStrings.Count);
  for i := 0 to AStrings.Count - 1 do
    Result[i] := GetArrayFromAlphaNumericString(AStrings[i], ASepControls,
      ASigns, ADollars);
end;

function GetRangeSet(AArray: TArrayOfUnicodeStrings;
  ACaseSense: Boolean = false): TArrayOfUnicodeStrings; overload;
var
  Rcrds, cursz, i, HighZ: Integer;
  Tst: string;
begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  Rcrds := 0;
  if InArray(AArray, '') then
    inc(Rcrds);
  cursz := 0;
  for i := 0 to HighZ do
  begin
    if ACaseSense then
      Tst := Trim(AArray[i])
    else
      Tst := Trim(Lowercase(AArray[i]));
    if not InArray(Result, Tst) then
    begin
      If Tst <> '' then
        inc(Rcrds);
      if Rcrds > cursz then
      begin
        inc(cursz, 5);
        SetLength(Result, cursz);
      end;
      Result[Rcrds - 1] := Tst;
    end;
  end;
  SetLength(Result, Rcrds);
end;

function GetColunmRangeSet(AArray: TTwoDArrayOfUnicodeString; ACol: Integer;
  ACaseSense: Boolean = false): TArrayOfUnicodeStrings; overload;
var
  HighZ: Integer;
  ThisCol: TArrayOfUnicodeStrings;

begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then
    exit;

  ThisCol := GetColunm(AArray, ACol);
  Result := GetRangeSet(ThisCol, ACaseSense);
end;
{ var
  Rcrds, cursz, i, HighZ: Integer;
  Tst: string;
  begin
  SetLength(Result, 0);
  HighZ := high(AArray);
  if HighZ < 0 then exit;

  Rcrds := 0;
  cursz := 0;
  for i := 0 to HighZ do
  if ACol < Length(AArray[i]) then
  begin
  if ACaseSense then Tst := Trim(AArray[i, ACol])
  else Tst := Trim(Lowercase(AArray[i, ACol]));
  if not InArray(Result, Tst) then
  begin
  inc(Rcrds);
  if Rcrds > cursz then
  begin
  inc(cursz, 5);
  SetLength(Result, cursz);
  end;
  Result[Rcrds - 1] := Tst;
  end;
  end;
  SetLength(Result, Rcrds);
  end;
}

function MaxNoOccurancesInCol(AArray: TTwoDArrayOfUnicodeString; ACol: Integer;
  ACaseSense: Boolean = false): Integer; overload;
var
  Rcrd, i, HighZ, HighCnt: Integer;
  LwrCaseSet: TArrayOfAnsiStrings;
  RsltCount: TArrayofInteger;
  Tst: AnsiString;
  RsltSet: TStringList;
begin
  Result := -1;
  HighZ := Length(AArray);
  if HighZ < 1 then
    exit;

  SetLength(LwrCaseSet, HighZ);
  SetLength(RsltCount, HighZ + 1);
  Dec(HighZ);
  RsltSet := TStringList.Create;
  try
    RsltSet.Add('');
    for i := 0 to HighZ do
    begin
      if ACol > High(AArray[i]) then
        Tst := ''
      else if ACaseSense then
        Tst := Trim(AArray[i, ACol])
      else
        Tst := Trim(Lowercase(AArray[i, ACol]));
      LwrCaseSet[i] := Tst;
      Rcrd := RsltSet.indexof(Tst);
      if Rcrd < 0 then
        Rcrd := RsltSet.Add(Tst);
      inc(RsltCount[Rcrd]);
    end;
    HighCnt := -1;
    for i := 0 to RsltSet.Count - 1 do
      if RsltCount[i] > HighCnt then
      begin
        HighCnt := RsltCount[i];
        Tst := RsltSet[i];
      end;

    i := 0;
    while (Result < 0) and (i <= HighZ) do
    begin
      if Tst = LwrCaseSet[i] then
        Result := i;
      inc(i);
    end;
  finally
    RsltSet.Free;
  end;
end;

function StrArrayToInt(AArray: TArrayOfUnicodeStrings; ADef: Integer = 0)
  : TArrayofLongWord; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    Result[i] := StrToIntDef(AArray[i], ADef);
end;

procedure IncrementArrayByStrings(Var ACountArray: TArrayofInteger;
  AListOfColNames: TStringList; AIncList: TStrings);
// ACountArray has a col for each entry in AListOfColNames;
// For each occurence of a name in AIncList the inc(ACountArray[column])
Var
  Idx, i: Integer;
begin
  if AListOfColNames = nil then
    exit;
  if AIncList = nil then
    exit;

  if Length(ACountArray) < AListOfColNames.Count then
    SetLength(ACountArray, AListOfColNames.Count);

  for i := 0 to AIncList.Count - 1 do
    if AListOfColNames.Find(AIncList[i], Idx) then
      inc(ACountArray[Idx]);
end;

procedure RemoveArrayColumn(var AArray: TTwoDArrayOfUnicodeString;
  AColToDrop: Integer); overload;
var
  i: Integer;
begin
  if high(AArray) < 0 then
    exit;
  for i := 0 to high(AArray) do
    DropArrayItemAtPos(AArray[i], AColToDrop);
end;

procedure RemoveArrayColumns(var AArray: TTwoDArrayOfUnicodeString;
  AColDrop: TArrayofInteger); overload;
var
  Test: Integer;
begin
  for Test := MaxIntegerArrayVal(AColDrop) downto 0 do
    if InArray(AColDrop, Test) then
      RemoveArrayColumn(AArray, Test);
end;

{$ENDIF}

function GetAnsiArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings;
begin
  Result := GetArrayFromString(S, SepVal, ARemoveQuote, ATrim, ADropNulls);
end;

function GetArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings;

var
  i: Integer;
{$IFDEF NextGen}
  NextChar, SecondQuoteChar: PChar;
  CSepVal: Char;
  QuoteVal: String;
  ThisS, fs: String;
{$ELSE}
  NextChar, SecondQuoteChar: PAnsiChar;
  CSepVal: AnsiChar;
  QuoteVal: AnsiString;
  ThisS, fs: AnsiString;
{$ENDIF}
begin
  SetLength(Result, 0);
  if S = '' then
    exit;
  ThisS := S;
{$IFDEF NextGen}
  NextChar := PChar(ThisS);
  CSepVal := Char(Ord(SepVal));
{$ELSE}
  NextChar := @ThisS[1];
  CSepVal := SepVal;
{$ENDIF}
  i := 0;
  while Pointer(NextChar) <> nil do
  begin
    if NextChar[0] = CSepVal then
    begin
      inc(NextChar);
      fs := '';
    end
    else if ARemoveQuote and (Char(NextChar[0]) in ['''', '"', '[', '{', '(',
      '<']) then
    begin
      case Char(NextChar[0]) of
        '''', '"':
          QuoteVal := NextChar[0];
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := NextChar[0];
      end;

{$IFDEF NextGen}
      SecondQuoteChar := StrPos(PChar(NextChar) + 1, PChar(QuoteVal));
{$ELSE}
      SecondQuoteChar := StrPos(PAnsiChar(NextChar + 1), PAnsiChar(QuoteVal));
{$ENDIF}
      if (Pointer(SecondQuoteChar) <> nil) and
        ((SecondQuoteChar[1] = CSepVal) or (SecondQuoteChar[1] = #0)) then
      begin
        inc(NextChar);
        if NextChar = SecondQuoteChar then
        Begin
          fs := '';
          inc(NextChar);
        End
        else
          fs := FieldSep(NextChar, QuoteVal[1 + ZSISOffset]);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        fs := FieldSep(NextChar, CSepVal);
    end
    else
      fs := FieldSep(NextChar, CSepVal);
    if i > high(Result) then
      SetLength(Result, i + 6);
    if ATrim then
      Result[i] := Trim(fs)
    else
      Result[i] := fs;
    if ADropNulls And (Result[i] = '') then
    Begin
    End
    Else
      inc(i);
  end;
  SetLength(Result, i);
end;

function GetAnsiArrayFromConstArray(AArray: array of String)
  : TArrayOfAnsiStrings;
var
  i, offset, topend: Integer;
begin
  SetLength(Result, Length(AArray));
  i := 0;
  offset := low(AArray);
  topend := high(AArray) - offset;
  while i <= topend do
  begin
    Result[i] := AArray[i + offset];
    inc(i);
  end;
end;
{$IFDEF NEXTGEN}
{$ELSE}  // Functions Only in Non NextGen  >> Old Compiler
{$IFNDEF FPC}

function GetAnsiArrayFromConstArray(AArray: array of AnsiString)
  : TArrayOfAnsiStrings;

var
  i, offset, topend: Integer;
begin
  SetLength(Result, Length(AArray));
  i := 0;
  offset := low(AArray);
  topend := high(AArray) - offset;
  while i <= topend do
  begin
    Result[i] := AArray[i + offset];
    inc(i);
  end;
end;
{$ENDIF}

Const
{$IFDEF FPC}
  CheckArray = ['|', '#', '=', '&', '%', '@'];
{$ELSE}
  CheckArray: array of AnsiChar = ['|', '#', '=', '&', '%', '@'];
{$ENDIF}
{$IFDEF ISXE8_DELPHI}

function GetArrayCompositSepString(Const AData: AnsiString;
  ASepArray: array of String; ARemoveQuote: Boolean = false;
  ATrim: Boolean = True; ADropNulls: Boolean = false;
  AIgnorBracketData: Boolean = false): TArrayOfAnsiStrings; overload;
Var
  Check: AnsiChar;
  LData: AnsiString;
  i, NxtUnwind, CountUnWind, BrktPos: Integer;
  BracketArray, UnWindArray, TstUnWArray, LSepArray: TArrayOfAnsiStrings;
begin
  LData := AData;
  if AIgnorBracketData then
  Begin
    LSepArray := UCArrayToAnsiArray(ASepArray);
    BracketArray := GetArrayBracketSepString(LData);
    SetLength(UnWindArray, Length(BracketArray));
    NxtUnwind := 0;
    For i := 0 to High(BracketArray) do
    Begin
      BrktPos := Pos(BracketArray[i], LData);
      if (BrktPos > 1) then
      begin
        While (BrktPos > 1) and
          Not(Char(LData[BrktPos - 1]) in OpenBracketAnsi) do
          BrktPos := PosFrmHere(BracketArray[i], LData, BrktPos + 1);
        if (BrktPos > 1) then
        begin
          TstUnWArray := GetArrayCompositSepString(BracketArray[i], ASepArray,
            false, false, false);
          if High(TstUnWArray) > 0 then
          begin
            UnWindArray[NxtUnwind] := BracketArray[i];
            LData := StringReplace(LData, UnWindArray[NxtUnwind],
              ReplaceSeps(UnWindArray[NxtUnwind], '<>', LSepArray), []);
            inc(NxtUnwind);
          end;
        End;
      end;
    End;
    SetLength(UnWindArray, NxtUnwind);
  End;
  Check := 'a';
  i := low(CheckArray);
  while (Check = 'a') and (i <= high(CheckArray)) do
  begin
    if (Pos(CheckArray[i], LData) < 1) or InArray(ASepArray, CheckArray[i]) then
      Check := CheckArray[i]
    else
      inc(i);
  end;
  if Check = 'a' then
    raise Exception.Create
      ('Error GetArrayCompositSepString unable to find suitable check char::' +
      LData);

  for i := Low(ASepArray) to High(ASepArray) do
    if not(Check = ASepArray[i]) then
      LData := StringReplace(LData, ASepArray[i], Check, [rfReplaceAll]);
  Result := GetArrayFromString(LData, Check, ARemoveQuote, ATrim, ADropNulls);

  if AIgnorBracketData and (NxtUnwind > 0) Then
  Begin
    i := 0;
    CountUnWind := NxtUnwind;
    While (i <= High(Result)) Do
    begin
      NxtUnwind := 0;
      while (Pos('<>', Result[i]) > 0) and (NxtUnwind < CountUnWind) do
      begin
        Result[i] := StringReplace(Result[i],
          ReplaceSeps(UnWindArray[NxtUnwind], '<>', LSepArray),
          UnWindArray[NxtUnwind], []);
        inc(NxtUnwind);
      end;
      inc(i);
    End;
  End;
end;
{$ENDIF}
{$ENDIF}

function GetTwoDAnsiArrayWithHeader(Const AHeader: String; ABlankRows: Integer)
  : TTwoDArrayOfAnsiString;
// Returns a Two D Array with ABlackRows followed by a single entry array with Header Data
Var
  Count: Integer;
begin
  if AHeader = '' then
    Count := ABlankRows
  else
    Count := ABlankRows + 1;
  SetLength(Result, Count);

  if AHeader <> '' then
  Begin
    Dec(Count);
    SetLength(Result[Count], 1);
    Result[Count, 0] := AHeader;
  End;
end;

function GetUnicodeArrayFromConstArray(AArray: array of UnicodeString)
  : TArrayOfUnicodeStrings;
var
  i, offset, topend: Integer;
begin
  SetLength(Result, Length(AArray));
  i := 0;
  offset := low(AArray);
  topend := high(AArray) - offset;
  while i <= topend do
  begin
    Result[i] := AArray[i + offset];
    inc(i);
  end;
end;

function GetRealArrayFromConstArray(AArray: array of real): TArrayOfReal;
var
  i, offset, topend: Integer;
begin
  SetLength(Result, Length(AArray));
  i := 0;
  offset := low(AArray);
  topend := high(AArray) - offset;
  while i <= topend do
  begin
    Result[i] := AArray[i + offset];
    inc(i);
  end;
end;

function GetColunm(AArray: TTwoDArrayOfAnsiString; ACol: Integer)
  : TArrayOfAnsiStrings; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    if ACol < Length(AArray[i]) then
      Result[i] := AArray[i, ACol]
    else
      Result[i] := '';
end;

function GetColunm(AArray: TTwoDArrayofInteger; ACol: Integer)
  : TArrayofInteger; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    if ACol < Length(AArray[i]) then
      Result[i] := AArray[i, ACol]
    else
      Result[i] := 0;
end;

function GetColunm(AArray: TTwoDArrayOfUnicodeString; ACol: Integer)
  : TArrayOfUnicodeStrings; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    if ACol < Length(AArray[i]) then
      Result[i] := AArray[i, ACol]
    else
      Result[i] := '';
end;

function GetColunm(AArray: TTwoDArrayofLongWord; ACol: Integer)
  : TArrayofLongWord; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AArray));
  for i := 0 to high(Result) do
    if ACol < Length(AArray[i]) then
      Result[i] := AArray[i, ACol]
    else
      Result[i] := 0;
end;

function ArrayAsSeperatedString(AArray: TArrayOfUnicodeStrings;
  ASepChar: WideChar; ASuppressIfNull: Boolean = True): UnicodeString; overload;
var
  TopSlot: Integer;
  Valid: Boolean;
  i: Integer;
  S: UnicodeString;
begin
  Result := '';
  Valid := false;
  if Length(AArray) > 0 then
  begin
    TopSlot := high(AArray);
    if TopSlot >= 0 then
      Result := Trim(AArray[0]);
    Valid := Result <> '';
    for i := 1 to TopSlot do
    begin
      S := Trim(AArray[i]);
      if S <> '' then
        Valid := True;
      Result := Result + ASepChar + S;
    end;
  end;
  if (not Valid) and ASuppressIfNull then
    Result := '';
end;

function ArrayAsSeperatedString(AArray: TArrayOfAnsiStrings; ASepChar: AnsiChar;
  ASuppressIfNull: Boolean = True): AnsiString;
var
  TopSlot: Integer;
  Valid: Boolean;
  i: Integer;
  S: AnsiString;
begin
  Result := '';
  Valid := false;
  if Length(AArray) > 0 then
  begin
    TopSlot := high(AArray);
    if TopSlot >= 0 then
      Result := Trim(AArray[0]);
    Valid := Result <> '';
    for i := 1 to TopSlot do
    begin
      S := Trim(AArray[i]);
      if S <> '' then
        Valid := True;
      Result := Result + ASepChar + S;
    end;
  end;
  if (not Valid) and ASuppressIfNull then
    Result := '';
end;

Function ArrayAsCSVLine(AArray: TArrayOfAnsiStrings;
  ASuppressIfNull: Boolean = false): AnsiString; overload;
Var
  i: Integer;
begin
  if High(AArray) < 0 then
  begin
    Result := crlf;
    exit;
  end;
  Result := '"';
  for i := 0 to High(AArray) do
  begin
    if ASuppressIfNull and (Trim(AArray[i]) = '') then
    begin

    end
    Else
      Result := Result + AArray[i] + '","';
  end;

  i := Length(Result);
  if i < 3 then
    Result := crlf
  else
  begin
    Result[i - 1] := cr;
    Result[i] := lf;
  end;
end;

Function ArrayAsCSVLine(AArray: TArrayOfUnicodeStrings;
  ASuppressIfNull: Boolean = false): UnicodeString; overload;
Var
  i: Integer;
begin
  if High(AArray) < 0 then
  begin
    Result := crlf;
    exit;
  end;
  Result := '"';
  for i := 0 to High(AArray) do
  begin
    if ASuppressIfNull and (Trim(AArray[i]) = '') then
    begin

    end
    Else
      Result := Result + AArray[i] + '","';
  end;

  i := Length(Result);
  if i < 3 then
    Result := crlf
  else
  begin
    Result[i - 1] := cr;
    Result[i] := lf;
  end;
end;

function InArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Boolean; overload;
begin
  Result := IndexInArray(AArray, ATest, ACaseSensitive) >= 0;
end;

function IndexInArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  if ACaseSensitive then
  begin
    for i := low(AArray) to high(AArray) do
      if AArray[i] = ATest then
      begin
        Result := i;
        break;
      end;
  end
  else
    for i := low(AArray) to high(AArray) do
      if CompareText(AArray[i], ATest) = 0 then
      begin
        Result := i;
        break;
      end;
end;

function InArray(AArray: array of UnicodeString; const ATest: UnicodeString;
  ACaseSensitive: Boolean = True): Boolean; overload;
begin
  Result := IndexInArray(AArray, ATest, ACaseSensitive) >= 0;
end;

function IndexInArray(AArray: array of UnicodeString;
  const ATest: UnicodeString; ACaseSensitive: Boolean = True): Integer;
  overload;
var
  i: Integer;
begin
  Result := -1;
  if ACaseSensitive then
  Begin
    for i := low(AArray) to high(AArray) do
      if AArray[i] = ATest then
      begin
        Result := i;
        break;
      end;
  End
  Else
    for i := low(AArray) to high(AArray) do
      if CompareText(AArray[i], ATest) = 0 then
      begin
        Result := i;
        break;
      end;
end;

function InArray(AArray: array of Integer; ATest: Integer): Boolean; overload;
begin
  Result := IndexInArray(AArray, ATest) >= 0;
end;

function IndexInArray(AArray: array of Integer; ATest: Integer)
  : Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := low(AArray) to high(AArray) do
    if AArray[i] = ATest then
    begin
      Result := i;
      break;
    end;
end;

function InArray(AArray: array of Longword; ATest: Longword): Boolean; overload;
begin
  Result := IndexInArray(AArray, ATest) >= 0;
end;

function IndexInArray(AArray: array of Longword; ATest: Longword)
  : Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := low(AArray) to high(AArray) do
    if AArray[i] = ATest then
    begin
      Result := i;
      break;
    end;
end;

function InArray(AArray: array of real; ATest: real): Boolean; overload;
Begin
  Result := IndexInArray(AArray, ATest) >= 0;
End;

function IndexInArray(AArray: array of real; ATest: real): Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := low(AArray) to high(AArray) do
    if AArray[i] = ATest then
    begin
      Result := i;
      break;
    end;
end;

function InArray(AArray: TArrayofObjects; ATest: TObject): Boolean; overload;
Begin
  Result := IndexInArray(AArray, ATest) >= 0;
End;

function IndexInArray(AArray: TArrayofObjects; ATest: TObject)
  : Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := low(AArray) to high(AArray) do
    if AArray[i] = ATest then
    begin
      Result := i;
      break;
    end;
end;

function PosInArray(AArray: array of AnsiString; const ATest: AnsiString)
  : Boolean; overload;
var
  i: Integer;
begin
  Result := false;
  for i := low(AArray) to high(AArray) do
    if Pos(ATest, AArray[i]) > 0 then
      Result := True;
end;

function PosInArray(AArray: array of UnicodeString; const ATest: UnicodeString)
  : Boolean; overload;
var
  i: Integer;
begin
  Result := false;
  for i := low(AArray) to high(AArray) do
    if Pos(ATest, AArray[i]) > 0 then
      Result := True;
end;

function ConfirmValueArrayIndexSet(const AValue1, AValue2: AnsiString): Boolean;
begin
  Result := Trim(Uppercase(AValue1)) = Trim(Uppercase(AValue2));
end;

function SetIndexFromArray(AValue: AnsiString;
  AChoices: TArrayOfAnsiStrings): byte;
var
  i, max: Integer;
  S: AnsiString;
begin
  Result := 255;
  if AValue = '' then
    exit;

  i := 0;
  S := Trim(Uppercase(AValue));
  max := high(AChoices) + 1;
  while (i < max) and (Trim(Uppercase(AChoices[i])) <> S) do
    inc(i);
  if i < max then
    Result := i
    { else
      Result := 255 };
end;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfAnsiStrings; AObjArray: TArrayofObjects);
var
  i, ObjMx: Integer;
begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  if AObjArray = nil then
    ObjMx := -1
  else
    ObjMx := high(AObjArray);
  for i := 0 to high(AArray) do
    if i > ObjMx then
      AStrings.Add(AArray[i])
    else
      AStrings.AddObject(AArray[i], AObjArray[i]);
end;

{$IFNDEF FPC}

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfUnicodeStrings; AObjArray: TArrayofObjects = nil);

var
  i, ObjMx: Integer;
begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  if AObjArray = nil then
    ObjMx := -1
  else
    ObjMx := high(AObjArray);
  for i := 0 to high(AArray) do
    if i > ObjMx then
      AStrings.Add(AArray[i])
    else
      AStrings.AddObject(AArray[i], AObjArray[i]);
end;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TTwoDArrayOfAnsiString; ASC: Char = #13;
  AObjArray: TArrayofObjects = nil);

var
  i, ObjMx: Integer;

begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  if AObjArray = nil then
    ObjMx := -1
  else
    ObjMx := high(AObjArray);
  for i := 0 to high(AArray) do
    if i > ObjMx then
      AStrings.Add(ArrayAsSeperatedString(AArray[i], AnsiChar(ASC), false))
    else
      AStrings.AddObject(ArrayAsSeperatedString(AArray[i], AnsiChar(ASC),
        false), AObjArray[i]);
end;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfUnicodeStrings; AObj: TObject);
var
  i: Integer;
begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  for i := 0 to high(AArray) do
    if AObj = nil then
      AStrings.Add(AArray[i])
    else
      AStrings.AddObject(AArray[i], AObj);
end;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TArrayOfAnsiStrings; AObj: TObject);
var
  i: Integer;
begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  for i := 0 to high(AArray) do
    if AObj = nil then
      AStrings.Add(AArray[i])
    else
      AStrings.AddObject(AArray[i], AObj);
end;

procedure PopulateStringsFromArray(AStrings: TStrings;
  AArray: TTwoDArrayOfUnicodeString; ASC: WideChar = #13;
  AObjArray: TArrayofObjects = nil);
var
  i, ObjMx: Integer;

begin
  if AStrings = nil then
    raise Exception.Create('PopulateStringsFromArray');
  AStrings.Clear;
  if AObjArray = nil then
    ObjMx := -1
  else
    ObjMx := high(AObjArray);
  for i := 0 to high(AArray) do
    if i > ObjMx then
      AStrings.Add(ArrayAsSeperatedString(AArray[i], ASC, false))
    else
      AStrings.AddObject(ArrayAsSeperatedString(AArray[i], ASC, false),
        AObjArray[i]);
end;
{$ENDIF}

function BuildArrayFromTStrings(AList: TStrings): TArrayOfAnsiStrings;
var
  i: Integer;
begin
  if AList <> nil then
    SetLength(Result, AList.Count)
  else
  begin
    SetLength(Result, 0);
    exit;
  end;

  for i := 0 to AList.Count - 1 do
    Result[i] := AList[i];
end;

function BuildArrayFromTStrings(AList: TStrings; ASepChar: AnsiChar;
  out ALongwordArray: TArrayofLongWord): TTwoDArrayOfAnsiString; overload;
var
  i: Integer;
begin
  if AList <> nil then
  begin
    SetLength(Result, AList.Count);
    SetLength(ALongwordArray, AList.Count);
    for i := 0 to AList.Count - 1 do
    begin
      Result[i] := GetArrayFromString(AnsiString(AList[i]), ASepChar);
      ALongwordArray[i] := Longword(Pointer(AList.Objects[i]));
    end;
  end
  else
  begin
    SetLength(Result, 0);
    SetLength(ALongwordArray, 0);
    exit;
  end;
end;

function BuildArrayFromTStrings(AList: TStrings; ASepChar: AnsiChar)
  : TTwoDArrayOfAnsiString; overload;
var
  LongwordArray: TArrayofLongWord;
begin
  Result := BuildArrayFromTStrings(AList, ASepChar, LongwordArray);
end;

Function ConcatArraysTo(AConcat, AAdd: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString;
Begin
  Result := AConcat;
  ConcatArrays(Result, AAdd);
End;

Function ConcatArraysTo(AConcat, AAdd: TArrayOfReal): TArrayOfReal;
Begin
  Result := AConcat;
  ConcatArrays(Result, AAdd);
End;

Function ConcatArraysTo(AConcat, AAdd: TArrayofInteger): TArrayofInteger;
Begin
  Result := AConcat;
  ConcatArrays(Result, AAdd);
End;

Function ConcatArraysTo(AConcat, AAdd: TArrayofObjects): TArrayofObjects;
Begin
  Result := AConcat;
  ConcatArrays(Result, AAdd);
End;

Function ConcatArraysTo(AConcat, AAdd: TArrayOfAnsiStrings)
  : TArrayOfAnsiStrings;
Begin
  Result := AConcat;
  ConcatArrays(Result, AAdd);
End;

procedure ConcatArrays(var AConcat: TTwoDArrayOfAnsiString;
  AAdd: TTwoDArrayOfAnsiString);
var
  i, AddAt: Integer;

begin
  AddAt := Length(AConcat);
  SetLength(AConcat, AddAt + Length(AAdd));
  for i := 0 to high(AAdd) do
    AConcat[i + AddAt] := AAdd[i];
end;

procedure ConcatArrays(var AConcat: TArrayOfReal; AAdd: TArrayOfReal); overload;
var
  i, AddAt: Integer;

begin
  AddAt := Length(AConcat);
  SetLength(AConcat, AddAt + Length(AAdd));
  for i := 0 to high(AAdd) do
    AConcat[i + AddAt] := AAdd[i];
end;

procedure ConcatArrays(var AConcat: TArrayOfAnsiStrings;
  AAdd: TArrayOfAnsiStrings); overload;
var
  i, AddAt: Integer;

begin
  AddAt := Length(AConcat);
  SetLength(AConcat, AddAt + Length(AAdd));
  for i := 0 to high(AAdd) do
    AConcat[i + AddAt] := AAdd[i];
end;

procedure ConcatArrays(var AConcat: TArrayofInteger;
  AAdd: TArrayofInteger); overload;
var
  i, AddAt: Integer;

begin
  AddAt := Length(AConcat);
  SetLength(AConcat, AddAt + Length(AAdd));
  for i := 0 to high(AAdd) do
    AConcat[i + AddAt] := AAdd[i];
end;

procedure ConcatArrays(var AConcat: TArrayofObjects;
  AAdd: TArrayofObjects); overload;
begin
  ConcatArrays(TArrayofInteger(AConcat), TArrayofInteger(AAdd));
end;

procedure ConcatTwoDArrayInX(var AConcat: TTwoDArrayOfAnsiString;
  AAdd: TTwoDArrayOfAnsiString; AMinColsInLHS: Integer; ATrunk: Boolean = false;
  APadRowValue: TArrayOfAnsiStrings = nil; APadColValue: String = ''); overload;
var
  i, ri, OldHigh, NewHigh, InHigh, RowHigh: Integer;
begin
  if AMinColsInLHS > 9999 then
    AMinColsInLHS := 20;
  OldHigh := high(AConcat);
  NewHigh := high(AAdd);
  InHigh := NewHigh;
  if OldHigh > NewHigh then
    NewHigh := OldHigh;

  if NewHigh > OldHigh then
    SetLength(AConcat, NewHigh + 1);
  for i := 0 to OldHigh do
  begin
    RowHigh := high(AConcat[i]);
    if (ATrunk and (RowHigh > AMinColsInLHS - 1)) or
      (RowHigh < AMinColsInLHS - 1) then
      SetLength(AConcat[i], AMinColsInLHS);
    if APadColValue <> '' then
      for ri := RowHigh + 1 to AMinColsInLHS - 1 do
        AConcat[i, ri] := APadColValue;

    if i <= InHigh then
      ConcatArrays(AConcat[i], AAdd[i])
    else
      ConcatArrays(AConcat[i], APadRowValue);
  end;

  for i := OldHigh + 1 to NewHigh do
  begin
    AConcat[i] := APadRowValue;
    SetLength(AConcat[i], AMinColsInLHS); // Padding so trunk anyway
    // if i<=InHigh then
    ConcatArrays(AConcat[i], AAdd[i]);
  end;
end;

procedure DropArrayItemByValue(var AArray: TArrayofInteger;
  AValue: Integer); overload;
var
  HIdx, ThisIdx: Integer;
begin
  HIdx := high(AArray);
  ThisIdx := 0;
  while ThisIdx <= HIdx do
  begin
    if AArray[ThisIdx] = AValue then
    begin
      DropArrayItemAtPos(AArray, ThisIdx);
      Dec(HIdx);
    end
    else
      inc(ThisIdx);
  end;
end;

procedure DropArrayItemByValue(var AArray: TArrayOfAnsiStrings;
  const AValue: AnsiString); overload;
var
  HIdx, ThisIdx: Integer;
begin
  HIdx := high(AArray);
  ThisIdx := 0;
  while ThisIdx <= HIdx do
  begin
    if AArray[ThisIdx] = AValue then
    begin
      DropArrayItemAtPos(AArray, ThisIdx);
      Dec(HIdx);
    end
    else
      inc(ThisIdx);
  end;
end;

procedure DropDuplicateItems(var AArray: TArrayofInteger); overload;
var
  HIdx, ChkIdx, RptPos, MvIdx, Sz: Integer;
begin
  HIdx := high(AArray);
  Sz := HIdx + 1;
  for ChkIdx := 0 to HIdx - 1 do
    if ChkIdx < Sz - 1 then
      for RptPos := ChkIdx + 1 to HIdx - 1 do
        if RptPos < Sz then
          if AArray[ChkIdx] = AArray[RptPos] then
          begin
            Dec(Sz);
            for MvIdx := RptPos to Sz - 1 do
              AArray[MvIdx] := AArray[MvIdx + 1];
          end;
  SetLength(AArray, Sz);
end;

procedure DropDuplicateItems(var AArray: TArrayOfAnsiStrings); overload;
var
  HIdx, ChkIdx, RptPos, MvIdx, Sz: Integer;
begin
  HIdx := high(AArray);
  Sz := HIdx + 1;
  for ChkIdx := 0 to HIdx - 1 do
    if ChkIdx < Sz - 1 then
      for RptPos := ChkIdx + 1 to HIdx - 1 do
        if RptPos < Sz then
          if AArray[ChkIdx] = AArray[RptPos] then
          begin
            Dec(Sz);
            for MvIdx := RptPos to Sz - 1 do
              AArray[MvIdx] := AArray[MvIdx + 1];
          end;
  SetLength(AArray, Sz);
end;

procedure DropArrayItemAtPos(var AArray: TArrayofInteger;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;

procedure DropArrayItemAtPos(var AArray: TArrayOfReal; APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;

procedure DropArrayItemAtPos(var AArray: TArrayOfAnsiStrings;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;

{$IFNDEF FPC}

procedure DropArrayItemAtPos(var AArray: TTwoDArrayOfUnicodeString;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;
{$ENDIF}

procedure DropArrayItemAtPos(var AArray: TArrayofObjects;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;

procedure DropArrayItemAtPos(var AArray: TTwoDArrayOfAnsiString;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;

{$IFNDEF FPC}

procedure DropArrayItemAtPos(var AArray: TArrayOfUnicodeStrings;
  APos: Integer); overload;
var
  HIdx, MvIdx: Integer;
begin
  if APos < 0 then
    exit;
  HIdx := high(AArray);
  if APos > HIdx then
    exit;

  for MvIdx := APos to HIdx - 1 do
    AArray[MvIdx] := AArray[MvIdx + 1];
  SetLength(AArray, HIdx);
end;
{$ENDIF}

Procedure PackArray(var AArray: TArrayofObjects);
// Packs Arrays with nulls,Zeros or '' Reduces length
Var
  NxtWrite, NxtRead: Integer;
begin
  NxtWrite := 0;
  NxtRead := 0;
  while NxtRead < Length(AArray) do
  begin
    if AArray[NxtRead] <> nil then
    Begin
      if NxtRead <> NxtWrite then
        AArray[NxtWrite] := AArray[NxtRead];
      inc(NxtWrite);
    End;
    inc(NxtRead)
  end;
  if NxtRead <> NxtWrite then
    SetLength(AArray, NxtWrite);
end;

Procedure PackArray(var AArray: TArrayOfAnsiStrings);
// Packs Arrays with  '')
Var
  NxtWrite, NxtRead: Integer;
begin
  NxtWrite := 0;
  NxtRead := 0;
  while NxtRead < Length(AArray) do
  begin
    if AArray[NxtRead] <> '' then
    Begin
      if NxtRead <> NxtWrite then
        AArray[NxtWrite] := AArray[NxtRead];
      inc(NxtWrite);
    End;
    inc(NxtRead)
  end;
  if NxtRead <> NxtWrite then
    SetLength(AArray, NxtWrite);
end;
{$IFNDEF FPC}

Procedure PackArray(var AArray: TArrayOfUnicodeStrings);
// Packs Arrays with  '')
Var
  NxtWrite, NxtRead: Integer;
begin
  NxtWrite := 0;
  NxtRead := 0;
  while NxtRead < Length(AArray) do
  begin
    if AArray[NxtRead] <> '' then
    Begin
      if NxtRead <> NxtWrite then
        AArray[NxtWrite] := AArray[NxtRead];
      inc(NxtWrite);
    End;
    inc(NxtRead)
  end;
  if NxtRead <> NxtWrite then
    SetLength(AArray, NxtWrite);
end;
{$ENDIF}

Procedure PackArray(var AArray: TArrayOfReal);
// Packs Arrays with nulls,Zeros or '')
Var
  NxtWrite, NxtRead: Integer;
begin
  NxtWrite := 0;
  NxtRead := 0;
  while NxtRead < Length(AArray) do
  begin
    if not IsZero(AArray[NxtRead]) then
    Begin
      if NxtRead <> NxtWrite then
        AArray[NxtWrite] := AArray[NxtRead];
      inc(NxtWrite);
    End;
    inc(NxtRead)
  end;
  if NxtRead <> NxtWrite then
    SetLength(AArray, NxtWrite);
end;

Procedure PackArray(var AArray: TArrayofInteger);
// Packs Arrays with Zeros)
Var
  NxtWrite, NxtRead: Integer;
begin
  NxtWrite := 0;
  NxtRead := 0;
  while NxtRead < Length(AArray) do
  begin
    if AArray[NxtRead] <> 0 then
    Begin
      if NxtRead <> NxtWrite then
        AArray[NxtWrite] := AArray[NxtRead];
      inc(NxtWrite);
    End;
    inc(NxtRead)
  end;
  if NxtRead <> NxtWrite then
    SetLength(AArray, NxtWrite);
end;

Procedure InsertIntoArray(var AArray: TArrayofObjects;
  AInsertAt, AInsertNo: Integer); overload;
// Inserts nils into Array
Var
  NxtWrite, NxtRead, NewLength, OldLength: Integer;
begin
  if AInsertNo < 1 then
    exit;
  OldLength := Length(AArray);
  NewLength := OldLength + AInsertNo;
  SetLength(AArray, NewLength);

  NxtWrite := NewLength - 1;
  NxtRead := OldLength - 1;
  while NxtRead >= AInsertAt do
  begin
    AArray[NxtWrite] := AArray[NxtRead];
    AArray[NxtRead] := nil;
    Dec(NxtWrite);
    Dec(NxtRead);
  end;
end;

Procedure InsertIntoArray(var AArray: TArrayofInteger;
  AInsertAt, AInsertNo: Integer); overload;
// Inserts 0s into Array
Var
  NxtWrite, NxtRead, NewLength, OldLength: Integer;
begin
  if AInsertNo < 1 then
    exit;
  OldLength := Length(AArray);
  NewLength := OldLength + AInsertNo;
  SetLength(AArray, NewLength);

  NxtWrite := NewLength - 1;
  NxtRead := OldLength - 1;
  while NxtRead >= AInsertAt do
  begin
    AArray[NxtWrite] := AArray[NxtRead];
    AArray[NxtRead] := 0;
    Dec(NxtWrite);
    Dec(NxtRead);
  end;
end;

procedure MergeIntoTwoDArray(var AMergeInto, AMergeFrom: TTwoDArrayofInteger;
  AMergCol: Integer = 0; AThenMergeBack: Boolean = false;
  AActionCols: TByteSet = []; AAction: TArraySign = AsCopy); overload;
var
  i, Row, MfrmTop, RwLen: Integer;
  ib: byte;

begin
  RwLen := 0;
  MfrmTop := high(AMergeFrom);
  for i := 0 to MfrmTop do
  begin
    if Length(AMergeFrom[i]) < AMergCol then
      raise Exception.Create('MergeIntoTwoDArray::Source Incomplete');
    if RwLen < Length(AMergeFrom[i]) then
      RwLen := Length(AMergeFrom[i]);
    Row := FindInsertArrayRow(AMergeInto, AMergeFrom[i, AMergCol], AMergCol,
      True, RwLen);
    if AActionCols <> [] then
      for ib := 0 to 255 do
        if ib in AActionCols then
        begin
          if ib = AMergCol then
            raise Exception.Create('MergeIntoTwoDArray::Modifying ref col');
          if Length(AMergeFrom[i]) < ib + 1 then
          begin
            if Length(AMergeInto[Row]) < ib + 1 then
              SetLength(AMergeInto[Row], ib + 1);
            case AAction of
              asPlus:
                AMergeInto[Row, ib] := AMergeInto[Row, ib] + AMergeFrom[i, ib];
              asMinus:
                AMergeInto[Row, ib] := AMergeInto[Row, ib] - AMergeFrom[i, ib];
              asMult:
                AMergeInto[Row, ib] := AMergeInto[Row, ib] * AMergeFrom[i, ib];
              asDivide:
                AMergeInto[Row, ib] := AMergeInto[Row, ib]
                  div AMergeFrom[i, ib];
              AsCopy:
                AMergeInto[Row, ib] := AMergeFrom[i, ib];
            end;
          end;
        end;
  end;

  if AThenMergeBack then
    MergeIntoTwoDArray(AMergeFrom, AMergeInto, AMergCol, false);
end;

function CopyArray(AToCopy: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfAnsiString; overload;
var
  i, j: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
  begin
    SetLength(Result[i], Length(AToCopy[i]));
    for j := 0 to high(AToCopy[i]) do
      Result[i, j] := AToCopy[i, j];
  end;
end;

function CopyArray(AToCopy: TArrayOfReal): TArrayOfReal; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
    Result[i] := AToCopy[i];
end;

function CopyArray(AToCopy: TArrayofInteger): TArrayofInteger; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
    Result[i] := AToCopy[i];
end;

function CopyArray(AToCopy: TArrayOfAnsiStrings): TArrayOfAnsiStrings; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
    Result[i] := AToCopy[i];
end;

function CopyArray(AToCopy: TArrayofObjects): TArrayofObjects; overload;
var
  i: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
    Result[i] := AToCopy[i];
end;

function CopyArray(AToCopy: TTwoDArrayofInteger): TTwoDArrayofInteger; overload;
var
  i, j: Integer;
begin
  SetLength(Result, Length(AToCopy));
  for i := 0 to high(AToCopy) do
  begin
    SetLength(Result[i], Length(AToCopy[i]));
    for j := 0 to high(AToCopy[i]) do
      Result[i, j] := AToCopy[i, j];
  end;
end;

Function AnsiArrayToUCArray(A: TArrayOfAnsiStrings)
  : TArrayOfUnicodeStrings; overload;
Var
  i: Integer;
Begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := A[i];
End;

Function AnsiArrayToUCArray(A: TTwoDArrayOfAnsiString)
  : TTwoDArrayOfUnicodeString; overload;
Var
  i: Integer;
Begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := AnsiArrayToUCArray(A[i]);
End;

Function UCArrayToAnsiArray(A: TArrayOfUnicodeStrings)
  : TArrayOfAnsiStrings; overload;
Var
  i: Integer;
Begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := A[i];
End;

Function UCArrayToAnsiArray(A: array of String): TArrayOfAnsiStrings; overload;
Var
  i: Integer;
Begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := A[i];
End;

Function UCArrayToAnsiArray(A: TTwoDArrayOfUnicodeString)
  : TTwoDArrayOfAnsiString; overload;
Var
  i: Integer;
Begin
  SetLength(Result, Length(A));
  for i := Low(A) to High(A) do
    Result[i] := UCArrayToAnsiArray(A[i]);
End;

function CalculateArrays(var A: TArrayofLongWord; B: TArrayofLongWord;
  Sgn: TArraySign): AnsiString;
var
  i, CalEnd, AEnd: Integer;

begin
  Result := '';
  i := 0;
  CalEnd := Length(B);
  AEnd := Length(A);
  if AEnd < CalEnd then
    SetLength(A, CalEnd);

  while i < CalEnd do
  begin
    try
      case Sgn of
        asPlus:
          if i < AEnd then
            A[i] := A[i] + B[i]
          else
            A[i] := B[i];
        asMinus:
          if i < AEnd then
            A[i] := A[i] - B[i]
          else
            A[i] := -B[i];
        asMult:
          if i < AEnd then
            A[i] := A[i] * B[i]
          else
            A[i] := 0;
        asDivide:
          if i < AEnd then
            A[i] := A[i] div B[i]
          else
            raise Exception.Create('Divide exceeds Array Size ');
        AsCopy:
          if i < AEnd then
            A[i] := B[i];
      end;
    except
      on E: Exception do
      begin
        if Result = '' then
          Result := 'CalculateArrays Error:';
        Result := Result + IntToStr(i) + '::' + E.Message;
      end;
    end;
    inc(i);
  end;
end;

function CalculateArrays(var A: TArrayOfReal; B: TArrayOfReal; Sgn: TArraySign)
  : AnsiString;
var
  i, CalEnd, AEnd: Integer;
begin
  Result := '';
  i := 0;
  CalEnd := Length(B);
  AEnd := Length(A);
  if AEnd < CalEnd then
    SetLength(A, CalEnd);

  while i < CalEnd do
  begin
    try
      case Sgn of
        asPlus:
          if i < AEnd then
            A[i] := A[i] + B[i]
          else
            A[i] := B[i];
        asMinus:
          if i < AEnd then
            A[i] := A[i] - B[i]
          else
            A[i] := -B[i];
        asMult:
          if i < AEnd then
            A[i] := A[i] * B[i]
          else
            A[i] := 0;
        asDivide:
          if i < AEnd then
            A[i] := A[i] / B[i]
          else
            raise Exception.Create('Divide exceeds Array Size ');
        AsCopy:
          if i < AEnd then
            A[i] := B[i];
      end;
    except
      on E: Exception do
      begin
        if Result = '' then
          Result := 'CalculateArrays Error:';
        Result := Result + IntToStr(i) + '::' + E.Message;
      end;
    end;
    inc(i);
  end;
end;

function MinLongValue(const Data: TArrayofLongWord): Longword;
var
  i: Longword;
begin
  Result := Data[Low(Data)];
  for i := Low(Data) + 1 to High(Data) do
    if Result > Data[i] then
      Result := Data[i];
end;

function MinRealArrayVal(AValArray: array of real): real;
var
  i, Top: Integer;
begin
  Top := high(AValArray);
  if Top < 0 then
    Result := MinValueReal
  else
    Result := AValArray[0];
  for i := 1 to Top do
    if Result > AValArray[i] then
      Result := AValArray[i];
end;

function MaxRealArrayVal(AValArray: array of real): real;
var
  i, Top: Integer;
begin
  Top := high(AValArray);
  if Top < 0 then
    Result := MaxValueReal
  else
    Result := AValArray[0];
  for i := 1 to Top do
    if Result < AValArray[i] then
      Result := AValArray[i];
end;

function MaxIntegerArrayVal(AValArray: array of Integer): Integer;
var
  i, Top: Integer;
begin
  Top := high(AValArray);
  if Top < 0 then
    Result := MaxInt
  else
    Result := AValArray[0];
  for i := 1 to Top do
    if Result < AValArray[i] then
      Result := AValArray[i];
end;

function MaxLWordArrayVal(AValArray: array of Longword): Longword;
var
  i, Top: Integer;
begin
  Top := high(AValArray);
  if Top < 0 then
    Result := MaxInt
  else
    Result := AValArray[0];
  for i := 1 to Top do
    if Result < AValArray[i] then
      Result := AValArray[i];
end;

Function NextColVacant(AArray: TArrayofObjects; AStartSearch: Integer): Integer;
Var
  Nxt, New: Integer;
begin
  New := Length(AArray);
  Nxt := 0;
  if AStartSearch > Nxt then
    Nxt := AStartSearch;
  while Nxt < New do
    if AArray[Nxt] <> nil then
      inc(Nxt);
  Result := Nxt;
end;

Function NextColVacant(AArray: TArrayOfAnsiStrings;
  AStartSearch: Integer): Integer;
Var
  Nxt, New: Integer;
begin
  New := Length(AArray);
  Nxt := 0;
  if AStartSearch > Nxt then
    Nxt := AStartSearch;
  while Nxt < New do
    if AArray[Nxt] <> '' then
      inc(Nxt);
  Result := Nxt;
end;

{$IFNDEF FPC}

Function NextColVacant(AArray: TArrayOfUnicodeStrings;
  AStartSearch: Integer): Integer;
Var
  Nxt, New: Integer;
begin
  New := Length(AArray);
  Nxt := 0;
  if AStartSearch > Nxt then
    Nxt := AStartSearch;
  while Nxt < New do
    if AArray[Nxt] <> '' then
      inc(Nxt);
  Result := Nxt;
end;
{$ENDIF}

Function NextColBlkVacant(AArray: TTwoDArrayofObjects;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;
Var
  NxtRw, NxtCol, LstRw, ReStart: Integer;
begin
  NxtRw := AFirstRow;
  if NxtRw < 0 then
    NxtRw := 0;
  NxtCol := AStartColSearch;
  if NxtCol < 0 then
    NxtCol := 0;
  ReStart := NxtRw;
  LstRw := ALastRow;
  if LstRw < NxtRw then
    LstRw := high(AArray);
  if LstRw > high(AArray) then
    LstRw := high(AArray);
  while NxtRw <= LstRw do
  begin
    if (High(AArray[NxtRw]) < NxtCol) or (AArray[NxtRw, NxtCol] = nil) then
      inc(NxtRw)
    else
    Begin
      NxtRw := ReStart;
      inc(NxtCol);
    End;
  end;
  Result := NxtCol;
end;

Function NextColBlkVacant(AArray: TTwoDArrayOfAnsiString;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;
Var
  NxtRw, NxtCol, LstRw, ReStart: Integer;
begin
  NxtRw := AFirstRow;
  if NxtRw < 0 then
    NxtRw := 0;
  NxtCol := AStartColSearch;
  if NxtCol < 0 then
    NxtCol := 0;
  ReStart := NxtRw;
  LstRw := ALastRow;
  if LstRw < NxtRw then
    LstRw := high(AArray);
  if LstRw > high(AArray) then
    LstRw := high(AArray);
  while NxtRw <= LstRw do
  begin
    if (High(AArray[NxtRw]) < NxtCol) or (AArray[NxtRw, NxtCol] = '') then
      inc(NxtRw)
    else
    Begin
      NxtRw := ReStart;
      inc(NxtCol);
    End;
  end;
  Result := NxtCol;
end;

Function NextColBlkVacant(AArray: TTwoDArrayOfUnicodeString;
  AStartColSearch: Integer = 0; AFirstRow: Integer = 0; ALastRow: Integer = -1)
  : Integer; overload;
Var
  NxtRw, NxtCol, LstRw, ReStart: Integer;
begin
  NxtRw := AFirstRow;
  if NxtRw < 0 then
    NxtRw := 0;
  NxtCol := AStartColSearch;
  if NxtCol < 0 then
    NxtCol := 0;
  ReStart := NxtRw;
  LstRw := ALastRow;
  if LstRw < NxtRw then
    LstRw := high(AArray);
  if LstRw > high(AArray) then
    LstRw := high(AArray);
  while NxtRw <= LstRw do
  begin
    if (High(AArray[NxtRw]) < NxtCol) or (AArray[NxtRw, NxtCol] = '') then
      inc(NxtRw)
    else
    Begin
      NxtRw := ReStart;
      inc(NxtCol);
    End;
  end;
  Result := NxtCol;
end;

Procedure SetAllSameLength(AArray: TTwoDArrayofObjects; ANewLength: Integer);
Var
  i: Integer;
begin
  for i := 0 to High(AArray) do
    if High(AArray[i]) <> ANewLength then
      SetLength(AArray[i], ANewLength);
end;

Procedure SetAllSameLength(AArray: TTwoDArrayofObjects);
Var
  FirstRowMax, max, ThisRowHi, i: Integer;
begin
  if Length(AArray) > 1 then
    exit;

  FirstRowMax := High(AArray[0]);
  max := FirstRowMax;
  for i := 0 to High(AArray) do
  begin
    ThisRowHi := High(AArray[i]);
    if ThisRowHi > max then
      max := High(AArray[i])
    else if ThisRowHi < max then
      SetLength(AArray[i], max);
  end;

  if max > FirstRowMax then
    SetAllSameLength(AArray, max);
end;

function GetAssociatedNumberArray(AArray: TTwoDArrayofObjects;
  AMaxNumber: Integer): TTwoDArrayofInteger;
{ sub } function NextVal(AThisVal: Integer): Integer;
  begin
    Result := AThisVal + 1;
    if Result > AMaxNumber then
      Result := 0;
  end;

Var
  ThisNumber, i, j, z: Integer;
begin
  SetAllSameLength(AArray);
  SetLength(Result, Length(AArray));
  for i := 0 to High(Result) do
    SetLength(Result[i], Length(AArray[i]));
  if Length(Result) < 1 then
    exit;
  if Length(Result[0]) < 1 then
    exit;

  Result[0, 0] := 0;
  for j := 0 to High(Result[0]) do
    for i := 0 to High(Result) do
      if i = 0 then
      begin
        if j > 0 then
          Result[0, j] := NextVal(Result[0, j - 1]);
      end
      else
      begin
        if Pointer(AArray[i, j]) = Pointer(AArray[i - 1, j]) then
          Result[i, j] := Result[i - 1, j]
        else
          Result[i, j] := NextVal(Result[i - 1, j]);
        if j > 0 then
        begin
          if Result[i, j - 1] = Result[i, j] then
          begin
            ThisNumber := Result[i, j];
            Result[i, j] := NextVal(ThisNumber);
            z := 1;
            while (i - z >= 0) and (Result[i - z, j] = ThisNumber) do
            begin
              Result[i - z, j] := Result[i, j];
              inc(z);
            end;
          end;
        end;
      end;
end;

function ArrayTotal(const AInput: TTwoDArrayofInteger): TArrayofInteger;
var
  i, j: Integer;
begin
  SetLength(Result, 0);
  for i := low(AInput) to high(AInput) do
  begin
    if Length(Result) < Length(AInput[i]) then
      SetLength(Result, Length(AInput[i]));
    for j := 0 to high(AInput[i]) do
      if j < Length(AInput[i]) then
        Result[j] := Result[j] + AInput[i, j];
  end;
end;

function ArrayTotal(const AInput: TTwoDArrayofLongWord): TArrayofLongWord;
var
  i, j: Integer;
begin
  SetLength(Result, 0);
  for i := low(AInput) to high(AInput) do
  begin
    if Length(Result) < Length(AInput[i]) then
      SetLength(Result, Length(AInput[i]));
    for j := 0 to high(AInput[i]) do
      if j < Length(AInput[i]) then
        Result[j] := Result[j] + AInput[i, j];
  end;
end;

function ArrayTotal(const AInput: TArrayofLongWord): Longword;
var
  i: Integer;
begin
  Result := 0;
  for i := low(AInput) to high(AInput) do
    Result := Result + AInput[i];
end;

function ArrayTotal(const AInput: TArrayofInteger): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := low(AInput) to high(AInput) do
    Result := Result + AInput[i];
end;



// Find Row where a new row would be inserted in a two d array sorted  on Column AValueCol
// Create a new row if AInsert = true

function FindInsertArrayRow(var AArray: TTwoDArrayofInteger;
  AValue, AValueCol: Integer; AInsert: Boolean = false;
  ADefaultLen: Integer = 0): Integer; overload;
var
  i, Top, SortNxt, Nxt: Integer;
begin
  Result := -1;
  SortNxt := -200000000;
  i := 0;
  Top := high(AArray);
  while (i <= Top) and (Result < 0) and (SortNxt < AValue) do
  begin
    if high(AArray[i]) < AValueCol then
      raise Exception.Create('FindInsertArrayRow:Incomplete Array');
    Nxt := AArray[i, AValueCol];
    if Nxt <= SortNxt then
      raise Exception.Create('FindInsertArrayRow:Unsorted Array');
    if Nxt = AValue then
      Result := i
    else
      SortNxt := Nxt;
    if SortNxt < AValue then
      inc(i);
  end;
  if (Result < 0) and AInsert then
  begin
    Result := i;
    i := high(AArray) + 1;
    SetLength(AArray, i + 1);
    while i > Result do
    begin
      AArray[i] := AArray[i - 1];
      Dec(i);
    end;
    SetLength(AArray[Result], 0);
    if ADefaultLen < (AValueCol + 1) then
      SetLength(AArray[Result], AValueCol + 1)
    else
      SetLength(AArray[Result], ADefaultLen);
    AArray[Result, AValueCol] := AValue;
  end;
end;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofInteger;
  AColToDrop: Integer); overload;
var
  i: Integer;
begin
  if high(AArray) < 0 then
    exit;
  for i := 0 to high(AArray) do
    DropArrayItemAtPos(AArray[i], AColToDrop);
end;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofReal;
  AColToDrop: Integer); overload;
var
  i: Integer;
begin
  if high(AArray) < 0 then
    exit;
  for i := 0 to high(AArray) do
    DropArrayItemAtPos(AArray[i], AColToDrop);
end;

procedure RemoveArrayColumn(var AArray: TTwoDArrayofObjects;
  AColToDrop: Integer); overload;
var
  i: Integer;
begin
  if high(AArray) < 0 then
    exit;
  for i := 0 to high(AArray) do
    DropArrayItemAtPos(AArray[i], AColToDrop);
end;

procedure RemoveArrayColumn(var AArray: TTwoDArrayOfAnsiString;
  AColToDrop: Integer);
var
  i: Integer;
begin
  if high(AArray) < 0 then
    exit;
  for i := 0 to high(AArray) do
    DropArrayItemAtPos(AArray[i], AColToDrop);
end;

Procedure SetLengthUnique(var AArray: TTwoDArrayOfAnsiString); overload;
// creates a unique copy of the array and of all strings
Var
  i, j: Integer;
  NewArray: TTwoDArrayOfAnsiString;
begin
  SetLength(NewArray, Length(AArray));
  for i := Low(AArray) to High(AArray) do
  begin
    SetLength(NewArray[i], Length(AArray[i]));
    for j := Low(AArray[i]) to High(AArray[i]) do
    begin
      NewArray[i, j] := AArray[i, j];
{$IFDEF NextGen}
      NewArray[i, j].UniqueString;
{$ELSE}
      UniqueString(NewArray[i, j]);
{$ENDIF}
    end;
  end;
  AArray := NewArray;
end;

Procedure SetLengthUnique(var AArray: TTwoDArrayofInteger); overload;
// creates a unique copy of the array
Var
  i, j: Integer;
  NewArray: TTwoDArrayofInteger;
begin
  SetLength(NewArray, Length(AArray));
  for i := Low(AArray) to High(AArray) do
  begin
    SetLength(NewArray[i], Length(AArray[i]));
    for j := Low(AArray[i]) to High(AArray[i]) do
      NewArray[i, j] := AArray[i, j];
  end;
  AArray := NewArray;
end;

Procedure SetLengthUnique(var AArray: TTwoDArrayofObjects); overload;
// creates a unique copy of the array
Var
  i, j: Integer;
  NewArray: TTwoDArrayofObjects;
begin
  SetLength(NewArray, Length(AArray));
  for i := Low(AArray) to High(AArray) do
  begin
    SetLength(NewArray[i], Length(AArray[i]));
    for j := Low(AArray[i]) to High(AArray[i]) do
      NewArray[i, j] := AArray[i, j];
  end;
  AArray := NewArray;
end;

Procedure SetLengthUnique(var AArray: TTwoDArrayofReal); overload;
// creates a unique copy of the array
Var
  i, j: Integer;
  NewArray: TTwoDArrayofReal;
begin
  SetLength(NewArray, Length(AArray));
  for i := Low(AArray) to High(AArray) do
  begin
    SetLength(NewArray[i], Length(AArray[i]));
    for j := Low(AArray[i]) to High(AArray[i]) do
      NewArray[i, j] := AArray[i, j];
  end;
  AArray := NewArray;
end;

procedure RemoveArrayColumns(var AArray: TTwoDArrayofInteger;
  AColDrop: TArrayofInteger); overload;
var
  Test: Integer;
begin
  for Test := MaxIntegerArrayVal(AColDrop) downto 0 do
    if InArray(AColDrop, Test) then
      RemoveArrayColumn(AArray, Test);
end;

procedure RemoveArrayColumns(var AArray: TTwoDArrayOfAnsiString;
  AColDrop: TArrayofInteger); overload;
var
  Test: Integer;
begin
  for Test := MaxIntegerArrayVal(AColDrop) downto 0 do
    if InArray(AColDrop, Test) then
      RemoveArrayColumn(AArray, Test);
end;

Function DropNullColsInArray(var AArray: TArrayOfAnsiStrings): Integer;
Var
  col: Integer;
begin
  Result := 0;
  col := High(AArray);
  while col >= 0 do
  Begin
    if Trim(AArray[col]) = '' then
    begin
      DropArrayItemAtPos(AArray, col);
      inc(Result);
    end;
    Dec(col);
  End;
end;

function DropZeroColsInArray(AArray: TTwoDArrayOfAnsiString;
  AFirstCol, ALastCol: Integer; AFirstTestRow: Integer = 0;
  ALastTestRow: Integer = MaxInt; AConsiderZeroIfTextAfter: Boolean = false)
  : TArrayofInteger;
// Leaves only columns that have a number somewhere
// Mod march 2014 will consider Zero if Alpha Text precedes number

{ sub } function NonZeroValueText(S: AnsiString): Boolean;
  var
    i, Len: Integer;
  begin
    Result := false;
    if S = '' then
      exit;

    Len := Length(S);
    i := 1 + ZSISOffset;
    while not Result and (i <= Len) do
      if Char(S[i]) in ['a' .. 'z', 'A' .. 'Z'] then
        exit
      else if Char(S[i]) in ['1' .. '9'] then
        Result := True
      else
        inc(i);
    if Result and AConsiderZeroIfTextAfter then
      while Result and (i <= Len) do
        if Char(S[i]) in ['a' .. 'z', 'A' .. 'Z'] then
          Result := false
        else
          inc(i);
  end;

var
  c, r, cActual, Last, LastRow, CurMaxResult, ResInc: Integer;
  DropIt: Boolean;

begin
  ResInc := 0;
  CurMaxResult := 0;
  SetLength(Result, 0);
  try
    c := AFirstCol;
    cActual := c - 1;
    LastRow := ALastTestRow;
    if LastRow > high(AArray) then
      LastRow := high(AArray);
    if LastRow < 0 then
      exit;

    Last := ALastCol;
    if Last > high(AArray[0]) then
    begin
      Last := 0;
      for r := 0 to high(AArray) do
        if Last < high(AArray[r]) then
          Last := high(AArray[r]);
      if Last > ALastCol then
        Last := ALastCol;
    end;

    while c <= Last do
    begin
      inc(cActual);
      DropIt := True;
      r := AFirstTestRow;
      while DropIt and (r <= LastRow) do
      begin
        if c <= high(AArray[r]) then
          if NonZeroValueText(AArray[r, c]) then
            DropIt := false;
        inc(r);
      end;
      if DropIt then
      begin
        if ResInc >= CurMaxResult then
        begin
          inc(CurMaxResult, 5);
          SetLength(Result, CurMaxResult);
        end;
        Result[ResInc] := cActual;
        inc(ResInc);
        RemoveArrayColumn(AArray, c);
        Dec(Last);
      end
      else
        inc(c);
    end;
  except
{$IFDEF MSWINDOWS}
    OutputDebugStringA('DropZeroColsInArray');
{$ENDIF}
  end;
  SetLength(Result, ResInc);
end;

procedure DropBlankRowsInArray(var AArray: TTwoDArrayOfAnsiString;
  AFirstRow, ALastRow: Integer; AFirstTestCol: Integer = 0;
  ALastTestCol: Integer = MaxInt);

var
  c, r, LastCol: Integer;
  DropIt: Boolean;

begin
  try
    if ALastRow > high(AArray) then
      ALastRow := high(AArray);
    if ALastRow < 0 then
      exit;

    r := ALastRow;
    // NewLast;
    while r >= AFirstRow do
    begin
      DropIt := True;
      LastCol := ALastTestCol;
      if LastCol > high(AArray[r]) then
        LastCol := high(AArray[r]);
      c := AFirstTestCol;
      while DropIt and (c < LastCol) do
      begin
        if (Trim(AArray[r, c]) <> '') then
          DropIt := false;
        inc(c);
      end;
      if DropIt then
        DropArrayItemAtPos(AArray, r);

      Dec(r);
    end;
  except
{$IFDEF MSWINDOWS}
    OutputDebugStringA('DropBlankRowsInArray');
{$ENDIF}
  end;
end;

procedure DropBlankRowsInArray(var AArray: TTwoDArrayOfUnicodeString;
  AFirstRow, ALastRow: Integer; AFirstTestCol: Integer = 0;
  ALastTestCol: Integer = MaxInt);
var
  c, r, LastCol: Integer;
  DropIt: Boolean;

begin
  try
    if ALastRow > high(AArray) then
      ALastRow := high(AArray);
    if ALastRow < 0 then
      exit;

    r := ALastRow;
    // NewLast;
    while r >= AFirstRow do
    begin
      DropIt := True;
      LastCol := ALastTestCol;
      if LastCol > high(AArray[r]) then
        LastCol := high(AArray[r]);
      c := AFirstTestCol;
      while DropIt and (c < LastCol) do
      begin
        if (Trim(AArray[r, c]) <> '') then
          DropIt := false;
        inc(c);
      end;
      if DropIt then
        DropArrayItemAtPos(AArray, r);

      Dec(r);
    end;
  except
{$IFDEF MSWINDOWS}
    OutputDebugStringA('DropBlankRowsInArray');
{$ENDIF}
  end;
end;

end.
