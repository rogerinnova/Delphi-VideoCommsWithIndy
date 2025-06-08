unit FmVCLImageDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  IsImageManagerVCL, IsIndyUtils, IsArrayLib,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.StdCtrls, Vcl.Mask;

type
  TFormVCLImageDemo = class(TForm)
    PnlControls: TPanel;
    PnlImages: TPanel;
    BtnAddImages: TButton;
    LbEdtAddNumber: TLabeledEdit;
    LbEdtInsertPos: TLabeledEdit;
    BtnTestCase: TButton;
    ImageCollection1: TImageCollection;
    procedure FormCreate(Sender: TObject);
    procedure BtnAddImagesClick(Sender: TObject);
    procedure BtnTestCaseClick(Sender: TObject);
  private
    { Private declarations }
    FImageManager: TImageMngrVCL;
    Function NewImage(AInsertAt: Integer): TImageControl;
    Procedure Setup;
  public
    { Public declarations }
  end;

var
  FormVCLImageDemo: TFormVCLImageDemo;

implementation

uses IsGblLogCheck;
{$R *.dfm}

procedure TFormVCLImageDemo.BtnAddImagesClick(Sender: TObject);
Var
  NoToAdd, PosToAdd, I, ImageToAdd, ImageCount: Integer;
begin
  if FImageManager = nil then
    Setup
  else
  Begin
    ImageCount := ImageCollection1.Count;
    NoToAdd := StrToIntDef(LbEdtAddNumber.Text, 4);
    LbEdtAddNumber.Text := IntToStr(NoToAdd);
    PosToAdd := StrToIntDef(LbEdtInsertPos.Text, 3);
    LbEdtInsertPos.Text := IntToStr(PosToAdd);
    FImageManager.InsertImagesAt(PnlImages, PosToAdd, NoToAdd);
    for I := 0 to NoToAdd - 1 do
    Begin
      try
        ImageToAdd := Random(ImageCount + 1);
        if (I + PosToAdd) < Length(FImageManager.ImageControlArray) then
          FImageManager.ImageControl(I + PosToAdd).BitMap :=
            ImageCollection1.GetBitmap(ImageToAdd, 1000, 1000)
        Else
          FImageManager.ImageControl(I + PosToAdd).BitMap :=
            ImageCollection1.GetBitmap(1, 1000, 1000);
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, 'BtnAddImagesClick');
      end;
    End;
  End;
end;

Type
  TTstObj = Class(TObject)
    Val: Integer;
    Constructor Create(AVal: Integer);
  end;

procedure TFormVCLImageDemo.BtnTestCaseClick(Sender: TObject);
Type
  TTstArray = Array of TTstObj;
Var
  ThisArray: TArrayofObjects;
  ThisIntArray: TArrayofInteger;
  TestArray: TTstArray;
  I, CurrentLength: Integer;
  NewImage: TTstObj;
begin
  SetLength(ThisIntArray, 5);
  for I := 0 to 4 do
    ThisIntArray[I] := I;
  InsertIntoArray(ThisIntArray, 2, 5);
  // Check(ThisIntArray[1]=1;
  // Check(ThisIntArray[2]=0;
  // Check(ThisIntArray[7]=0;
  // Check(ThisIntArray[8]=3;
  // Check(ThisIntArray[9]=4;
  for I := 2 to 6 do
    ThisIntArray[I] := I + 10;
  // Check(ThisIntArray[1]=1;
  // Check(ThisIntArray[2]=12;
  // Check(ThisIntArray[6]=16;
  // Check(ThisIntArray[7]=2;
  // Check(ThisIntArray[8]=3;
  // Check(ThisIntArray[9]=4;
  InsertIntoArray(ThisIntArray, 2, 5);
  // Check(ThisIntArray[1]=1;
  // Check(ThisIntArray[2]=0;
  // Check(ThisIntArray[6]=0;
  // Check(ThisIntArray[7]=12;
  // Check(ThisIntArray[8]=13;
  // Check(ThisIntArray[13]=3;
  // Check(ThisIntArray[14]=4;
  for I := 2 to 6 do
    ThisIntArray[I] := I + 20;
  // Check(ThisIntArray[1]=1;
  // Check(ThisIntArray[2]=22;
  // Check(ThisIntArray[7]=26;
  // Check(ThisIntArray[8]=12;
  // Check(ThisIntArray[9]=13;
  // Check(ThisIntArray[13]=3;
  // Check(ThisIntArray[14]=4;

  SetLength(ThisArray, 5);
  for I := 0 to 4 do
    ThisArray[I] := TTstObj.Create(I);
  TestArray := TTstArray(ThisArray);

  // for I := 0 to 4 do
  // NewImage:= TTstObj.Create(I);

  InsertIntoArray(ThisArray, 2, 5);
  TestArray := TTstArray(ThisArray);
  // Check(TestArray[1].val=1;
  // Check(TestArray[2]=nil;
  // Check(TestArray[7]=nil;
  // Check(TestArray[8].val=2;
  // Check(TestArray[9].val=3;
  for I := 2 to 6 do
    ThisArray[I] := TTstObj.Create(I + 10);
  TestArray := TTstArray(ThisArray);
  // Check(TestArray[1].val=1;
  // Check(TestArray[2].val=12;
  // Check(TestArray[6].val=16;
  // Check(TestArray[7].val=2;
  // Check(TestArray[8].val=3;
  // Check(TestArray[9].val=4;

  InsertIntoArray(ThisArray, 2, 5);
  TestArray := TTstArray(ThisArray);
  for I := 2 to 6 do
    ThisArray[I] := TTstObj.Create(I + 20);
  TestArray := TTstArray(ThisArray);
  // Check(TestArray[1].val=1;
  // Check(TestArray[2].val=22;
  // Check(TestArray[6].val=26;
  // Check(TestArray[7].val=12;
  // Check(TestArray[8].val=13;
  // Check(TestArray[9].val=14;
  // Check(TestArray[12].val=2;
  // Check(TestArray[13].val=3;
  // Check(TestArray[14].val=4;
end;

procedure TFormVCLImageDemo.FormCreate(Sender: TObject);
begin
  OpenAppLogging(True);
end;

function TFormVCLImageDemo.NewImage(AInsertAt: Integer): TImageControl;
begin
  if FImageManager = nil then
    FImageManager := TImageMngrVCL.Create(PnlImages, AInsertAt + 1)
  Else
    FImageManager.InsertImagesAt(PnlImages, AInsertAt, 1);
  Result := FImageManager.ImageControl(AInsertAt);
end;

procedure TFormVCLImageDemo.Setup;
Var
  I: Integer;
begin
  if FImageManager <> nil then
    Exit;
  NewImage(4).BitMap := ImageCollection1.GetBitmap(4, 200, 200);
  for I := 0 to 3 do
    FImageManager.ImageControl(I).BitMap := ImageCollection1.GetBitmap(I,
      1000, 1000);
end;

{ TTstObj }

constructor TTstObj.Create(AVal: Integer);
begin
  Val := AVal;
end;

end.
