unit FmFMXImageDemo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  FMX.Edit, IsMobileCaptureDevices, IsIndyUtils, IsImageManager;

type
  TDemoMediaCapture = class(TIsMediaCapture)
  private
    FDemoBitMap: TBitmap;
    FListOfImageConnections: TStringList; // Of TVideoChnlLink
    procedure DoSetDemoBitMaps;
  protected
    procedure SendToVideoCommsChannels(AData: TBitmap); Override;
    // For Video Demo Code
  Public
    Destructor Destroy; Override;
    Function ListOfImageConnections: TStringList;
    Procedure AddConnectionObject(AConnection: TVideoChnlLink);
  end;

  TTFormFMXImageDemo = class(TForm)
    PnlControls: TPanel;
    PnlImages: TPanel;
    LblNoToAdd: TLabel;
    LblPosToInsert: TLabel;
    LbEdtInsertPos: TEdit;
    LbEdtAddNumber: TEdit;
    BtnAddImages: TButton;
    BtnAddCamera: TButton;
    ImgCamera: TImageControl;
    Timer1: TTimer;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure BtnAddImagesClick(Sender: TObject);
    procedure BtnAddCameraClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FCameraOn: Boolean;
    FImageManager: TImageCntrlManager;
    FMediaDevices: TDemoMediaCapture;
    Function NewImage(AInsertAt: Integer): TImageControl;
    Procedure GetNoToAdd(Out ANoToAdd, APosToAdd: Integer);
    Procedure Setup;
    Function MediaDevices: TDemoMediaCapture;
    Procedure SetCamera;
  public
    { Public declarations }
  end;

var
  TFormFMXImageDemo: TTFormFMXImageDemo;

implementation

Uses IsLogging, IsGblLogCheck;
{$R *.fmx}

procedure TTFormFMXImageDemo.BtnAddCameraClick(Sender: TObject);
Var
  NoToAdd, PosToAdd, I, ImageCount: Integer;
  NewConnection: TVideoChnlLink;
begin
  SetCamera;
  If FMediaDevices = nil then
    Exit;

  if FCameraOn then
  Begin
    ImageCount := ImageList1.Count;
    GetNoToAdd(NoToAdd, PosToAdd);
    FImageManager.InsertImagesAt(PnlImages, PosToAdd, NoToAdd);
    for I := 0 to NoToAdd - 1 do
    Begin
      try
        if (I + PosToAdd) < Length(FImageManager.ImageControlArray) then
        begin
          NewConnection := TVideoChnlLink.Create('TestHost', 1200,
            IntToStr(I) + FormatdateTime('hh:nn:ss.zzz', now),
            FImageManager.ImageControl(I + PosToAdd));
          FMediaDevices.AddConnectionObject(NewConnection);
        end;
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, 'BtnAddImagesClick');
      end;
    End;
  End;

End;

procedure TTFormFMXImageDemo.BtnAddImagesClick(Sender: TObject);
Var
  NoToAdd, PosToAdd, I, ImageToAdd, ImageCount: Integer;
  Size: TSizeF;
  RandomRslt :Array of integer;
{Interesting
As I did not call Randomize I expected running the program with the same action
would produce the same results (Images added) running Delphi 10.3 Sydney this
was not the case A call to TPah Create before Application.Initialize does the
Randomize.

class constructor TPath.Create;
begin
  Randomize;
}




begin
  NoToAdd:=2;
  if FImageManager = nil then
    Setup
  else
  Begin
    Size.Create(500, 500);
    ImageCount := ImageList1.Count;
    GetNoToAdd(NoToAdd, PosToAdd);
    SetLength(RandomRslt,NoToAdd+1);
    FImageManager.InsertImagesAt(PnlImages, PosToAdd, NoToAdd);
    for I := 0 to NoToAdd - 1 do
    Begin
      try
        ImageToAdd := Random(ImageCount);
        RandomRslt[i]:=ImageToAdd;
        If ImageToAdd<1 Then
           ImageToAdd:=0;
        if ImageToAdd>ImageCount-1 then
           ImageToAdd:=0;


        if (I + PosToAdd) < Length(FImageManager.ImageControlArray) then
          FImageManager.ImageControl(I + PosToAdd).BitMap :=
            ImageList1.BitMap(Size, ImageToAdd)
        Else
          FImageManager.ImageControl(I + PosToAdd).BitMap :=
            ImageList1.BitMap(Size, ImageToAdd);
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, 'BtnAddImagesClick');
      end;
    End;
  End;
  SetLength(RandomRslt,NoToAdd+1);
end;

procedure TTFormFMXImageDemo.FormCreate(Sender: TObject);
begin
  OpenAppLogging(True);
end;

procedure TTFormFMXImageDemo.GetNoToAdd(Out ANoToAdd, APosToAdd: Integer);
begin
  ANoToAdd := StrToIntDef(LbEdtAddNumber.Text, 4);
  LbEdtAddNumber.Text := IntToStr(ANoToAdd);
  APosToAdd := StrToIntDef(LbEdtInsertPos.Text, 3);
  LbEdtInsertPos.Text := IntToStr(APosToAdd);
end;

function TTFormFMXImageDemo.MediaDevices: TDemoMediaCapture;
begin
  Try
    if FMediaDevices = nil then
    Begin
      if CurrentMediaCapture <> nil then
        raise Exception.Create('LocalMediaCaptureDevices <> nil');
      TDemoMediaCapture.Create(200, 200, False, True, True);
      FMediaDevices := CurrentMediaCapture as TDemoMediaCapture;
    end;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
  Result := FMediaDevices;
end;

function TTFormFMXImageDemo.NewImage(AInsertAt: Integer): TImageControl;
begin
  if FImageManager = nil then
    FImageManager := TImageCntrlManager.Create(PnlImages, AInsertAt + 1)
  Else
    FImageManager.InsertImagesAt(PnlImages, AInsertAt, 1);
  Result := FImageManager.ImageControl(AInsertAt);
end;

procedure TTFormFMXImageDemo.SetCamera;
begin
  try
    FCameraOn := not FCameraOn;
    MediaDevices.SetBitMap(ImgCamera.BitMap, MediaDevices.DefaultCameraSelect);
    MediaDevices.ActivateDeactivateVideo(MediaDevices.DefaultCameraSelect,
      Not FCameraOn);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TTFormFMXImageDemo.Setup;
Var
  I: Integer;
  Size: TSizeF;
begin
  if FImageManager <> nil then
    Exit;
  Size.Create(500, 500);
  NewImage(4).BitMap := ImageList1.BitMap(Size, 4);  //0..4>>5th Image
  for I := 0 to 4 do
    FImageManager.ImageControl(I).BitMap := ImageList1.BitMap(Size, I);
end;

procedure TTFormFMXImageDemo.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=false;
  Try
    if FMediaDevices<>nil then
      if FImageManager<>nil then
        FImageManager.BlankInactiveImageChannels(FMediaDevices.ListOfImageConnections,1);
  Finally
     Timer1.Enabled:=True;
  End;
end;

{ TDemoMediaCapture }

procedure TDemoMediaCapture.AddConnectionObject(AConnection: TVideoChnlLink);
begin
  if AConnection = nil then
    Exit;
  ListOfImageConnections.AddObject(AConnection.LinkRef, AConnection);
end;

destructor TDemoMediaCapture.Destroy;
begin
  FListOfImageConnections.Free;
  inherited;
end;

procedure TDemoMediaCapture.DoSetDemoBitMaps;
Var
  ThisConnection: TVideoChnlLink;
  I: Integer;
begin
  if FDemoBitMap = nil then
    Exit;
  if FListOfImageConnections = nil then
    Exit;
  for I := 0 to FListOfImageConnections.Count - 1 do
    if FListOfImageConnections.Objects[I] is TVideoChnlLink then
    Begin
      ThisConnection := TVideoChnlLink(FListOfImageConnections.Objects[I]);
      ThisConnection.RxGraphic(FDemoBitMap);
    End;
end;

function TDemoMediaCapture.ListOfImageConnections: TStringList;
begin
  if FListOfImageConnections = nil then
  Begin
    AddVideoCommsChannel(nil);
    //to set FVideoComsChannels<>nil

    FListOfImageConnections := TStringList.Create;
    FListOfImageConnections.Sorted := True;
    FListOfImageConnections.OwnsObjects := True;
    FListOfImageConnections.Duplicates := dupAccept;
  End;
  Result := FListOfImageConnections;
end;

procedure TDemoMediaCapture.SendToVideoCommsChannels(AData: TBitmap);
begin
  if AData = nil then
    Exit;
  inherited;
  FDemoBitMap := TBitmap.Create(AData.Width, AData.Height);
  Try
    FDemoBitMap.CopyFromBitmap(AData);
    if IsNotMainThread then
      TThread.Synchronize(nil, DoSetDemoBitMaps)
    else
      DoSetDemoBitMaps;
  Finally
    FreeAndNil(FDemoBitMap);
  End;
end;

end.
