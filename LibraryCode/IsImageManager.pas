unit IsImageManager;

interface

uses
  System.Math, System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, IsMediaCommsObjs, IsRemoteConnectionIndyTcpObjs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  // FMX.DialogService,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.TabControl,
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
  IsArrayLib;

Type
  TImagePosObj = class;
  TImageArray = Array of TObject;
  TImagePosObjArray = Array of TImagePosObj;

  TImageCntrlManager = class(TObject)
  private
    FImagesPanel: TPanel;
    FImageArray: TImageArray;
    FPArray: TImagePosObjArray;
    FCurrentPrime: TImagePosObj;
    FDefaultBitMap: TBitmap;
    Function DefaultBitMap: TBitmap;
    Procedure SetRowsCols(APnlWidth, APnlHeight: single;
      Out AColCnt, ARowCnt: integer);
    Procedure DoOnPanelResize(Sender: TObject);
    Procedure ImageClicked(APosObj: TImagePosObj);
  public
    Constructor Create(AImagePnl: TPanel; ANoOfChnls: integer);
    Destructor Destroy; override;
    Procedure SetImagePanels(AImagePnl: TPanel);
    Procedure InsertImagesAt(AImagePnl: TPanel; AAddAt, ANoToAdd: integer);
    Procedure GrowImageLists(AImagePnl: TPanel; ANoOfChnls: integer);
    Procedure DisConnectInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: integer);
    Procedure BlankInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: integer);
    Function ImageControl(AIndx: integer): TImageControl;
    Function ImageControlArray: TImageArray;
    Function FindNullImage(AListOfCurrentRx: TStrings;
      ANoImagesReservedExternalToList: integer): TImageControl;
  end;

  TImagePosObj = class(TObject)
  Public
    Procedure OnImageClick(Sender: TObject);
    Constructor Create(AImageManager: TImageCntrlManager);
  Private
    FImageManager: TImageCntrlManager;
    FImageCtrl: TImageControl;
    FPresetBmp: TBitmap;
    FParentPanel: TPanel;
    FSz, FPos, FScale: TPointF;
    Procedure ReSetValues(AThisIndx: integer; ASz, APos, AScale: TPointF);
  end;

  TVideoChnlLink = class(TObject)
  Private
    FLinkRef: string;
    FImage: TImageControl;
    FHost: string;
    FPort: integer;
    FSyncBitmap: Boolean;
    FVideoComs: TVideoComsChannel;
    FLastRxGraphicTime: TDateTime;
    FActiveChnl: Boolean;
    Function RxAnsiString(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Procedure ChannelClosing(ASender: TObject);
    procedure SetImage(const Value: TImageControl);
  Public
    Constructor Create(AHost: String; APort: integer; ALinkRef: String;
      AImage: TImageControl);
    Destructor Destroy; override;
    Procedure DisConnectInactiveChannel(AInLastNoMins: integer);
    Procedure BlankInactiveChannel(AInLastNoMins: integer);
    Procedure RxGraphic(AGraphic: TBitmap);
    Function VideoComs: TVideoComsChannel;
    Function VideoIsActive(AInLastNoMins: integer): Boolean;
    Property Image: TImageControl write SetImage;
    Property LinkRef: string read FLinkRef;
  end;

Var
  GblDefaultBitMap: TBitmap = nil;
  cTstAspect: single = 0.5;

implementation

uses IsGblLogCheck, IsIndyUtils, IsLogging;

{ TImagePosObj }
(*
  class procedure TImagePosObj.GrowImageLists(ATab: TTabItem;
  var AImageArray: TImageArray; var APArray: TImagePosObjArray;
  ANoOfChnls: Integer);
  Var
  CurrentLength: Integer;
  Idx: Integer;
  begin
  try
  CurrentLength := Length(AImageArray);
  if CurrentLength < ANoOfChnls then
  Begin
  Setlength(AImageArray, ANoOfChnls);
  Setlength(APArray, ANoOfChnls);
  while CurrentLength < ANoOfChnls do
  Begin
  AImageArray[CurrentLength] :=
  TImageControl.Create(nil { self //I will Free Images } );
  APArray[CurrentLength] := TImagePosObj.Create;
  inc(CurrentLength);
  End;
  for Idx := 0 to CurrentLength - 1 do
  APArray[Idx].SetAllValues(Idx, ATab, AImageArray, APArray);
  End;
  // if ShortSliderForm.FNoAutoImgs <> ANoOfChnls then
  // ShortSliderForm.ReviewImages;
  except
  On E: Exception do
  ISIndyUtilsException('Class Proc ', E, 'TImagePosObj.GrowImageLists');
  end;
  end;

  class procedure TImagePosObj.SetImagePanels(ATab: TTabItem;
  ARxImageArray: TImageArray; APArray: TImagePosObjArray);
  Var
  Idx, Img, ColCnt, RowCnt, ColIdx, RowIdx: Integer;
  PnlWidth, PnlHeight, TabWidth, TabHeight: Single;
  ThisPos, ThisScale: TPointF;
  Panel: TPanel;
  Landscape: Boolean;
  begin
  try
  Img := Length(ARxImageArray);
  if Length(APArray) <> Img then
  ISIndyUtilsException('Class TImagePosObj', 'Bad # of images');
  For Idx := 0 to Img - 1 do
  APArray[Idx].ReSetValues(Idx, TPointF.Zero, TPointF.Zero, TPointF.Zero);

  if Img < 1 then
  Exit;

  Panel := APArray[0].FImagesPanel;
  PnlWidth := Panel.Width;
  PnlHeight := Panel.Height;
  Landscape := PnlWidth > PnlHeight;

  case Img of
  1:
  Begin
  ColCnt := 1;
  RowCnt := 1;
  End;
  2:
  Begin
  if Landscape then
  Begin
  ColCnt := 2;
  RowCnt := 1;
  End
  else
  Begin
  ColCnt := 1;
  RowCnt := 2;
  End;
  End;
  3 .. 4:
  Begin
  Begin
  ColCnt := 2;
  RowCnt := 2;
  End
  End;
  5 .. 6:
  Begin
  if Landscape then
  Begin
  ColCnt := 2;
  RowCnt := 2;
  End
  else
  Begin
  ColCnt := 1;
  RowCnt := 2;
  End;
  End;
  end;
  Except
  On E: Exception do
  ISIndyUtilsException('Class TImagePosObj', E, 'Set Image Panels');
  end;
  end;
*)

constructor TImagePosObj.Create(AImageManager: TImageCntrlManager);
begin
  FImageManager := AImageManager;
  if FImageManager = nil then
    Raise Exception.Create('Must Have FImageCtrlManager');
  FPresetBmp := FImageManager.DefaultBitMap; // testing
  FParentPanel := FImageManager.FImagesPanel;
  Inherited Create;
end;

procedure TImagePosObj.OnImageClick(Sender: TObject);
begin
  if Sender = FImageCtrl then
    if FImageManager <> nil then
    Begin
      FImageManager.ImageClicked(Self);
      Exit;
    End;
  raise Exception.Create('TImagePosObj.OnImageClick');
  ISIndyUtilsException(Self, 'Blank TImagePosObj.OnImageClick')
end;

procedure TImagePosObj.ReSetValues(AThisIndx: integer;
  ASz, APos, AScale: TPointF);
begin
  if (Length(FImageManager.FImageArray) <= AThisIndx) or
    (Length(FImageManager.FPArray) <= AThisIndx) or
    (Self <> (FImageManager.FPArray)[AThisIndx]) then
    raise Exception.Create('TImagePosObj.ReSetValues with bad base values');
  try
    FImageCtrl := FImageManager.ImageControl(AThisIndx);
    FImageCtrl.Align := TAlignLayout.None;
    FImageCtrl.OnDblClick := OnImageClick;
    FImageCtrl.Visible := false;
    FImageCtrl.Align := TAlignLayout.None;
    FImageCtrl.Parent := FParentPanel;

    // if ASz.IsZero then
    // Begin

    // End
    // Else
    Begin
      // if FPresetBmp <> nil then
      // FImageCtrl.Bitmap := FPresetBmp;
      FSz := ASz;
      // if not APos.IsZero then
      FPos := APos;
      // if not AScale.IsZero then
      FScale := AScale;
      FImageCtrl.Width := FSz.X;
      FImageCtrl.Height := FSz.Y;
      FImageCtrl.Position.Point := FPos;
      FImageCtrl.Scale.Point := FScale;
      FImageCtrl.Visible := true;
    End;
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'ReSetValues');
  end;
end;

{ TImageCntrlManager }

procedure TImageCntrlManager.BlankInactiveImageChannels(AListOfCurrentRx
  : TStrings; AMinutesInActive: integer);
Var
  IDX: integer;
begin
  if AListOfCurrentRx = nil then
    Exit;
  if AListOfCurrentRx.Count > 0 then
    for IDX := 0 to AListOfCurrentRx.Count - 1 do
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLink then
        TVideoChnlLink(AListOfCurrentRx.Objects[IDX])
          .BlankInactiveChannel(AMinutesInActive);
end;

constructor TImageCntrlManager.Create(AImagePnl: TPanel; ANoOfChnls: integer);
begin
  FImagesPanel := AImagePnl;
  if FImagesPanel = nil then
    Exit;

  GrowImageLists(FImagesPanel, ANoOfChnls);
end;

function TImageCntrlManager.DefaultBitMap: TBitmap;
begin
  if FDefaultBitMap = nil then
  begin
    FDefaultBitMap := TBitmap.Create;
    FDefaultBitMap.Assign(GblDefaultBitMap)
  End;

  Result := FDefaultBitMap;
end;

destructor TImageCntrlManager.Destroy;
begin
  Try
    FreeObjectArray(TArrayofObjects(FImageArray));
    // Frees Objects
    FreeObjectArray(TArrayofObjects(FPArray));
    FDefaultBitMap.Free;
    FreeAndNil(GblDefaultBitMap);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TImageCntrlManager.Destroy')
  End;
  inherited;
end;

procedure TImageCntrlManager.DisConnectInactiveImageChannels(AListOfCurrentRx
  : TStrings; AMinutesInActive: integer);
Var
  IDX: integer;
begin
  if AListOfCurrentRx = nil then
    Exit;
  if AListOfCurrentRx.Count > 0 then
    for IDX := 0 to AListOfCurrentRx.Count - 1 do
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLink then
        TVideoChnlLink(AListOfCurrentRx.Objects[IDX]).DisConnectInactiveChannel
          (AMinutesInActive);
end;

procedure TImageCntrlManager.DoOnPanelResize(Sender: TObject);
begin
  // if Sender=FTabPnl then
  SetImagePanels(FImagesPanel);
end;

function TImageCntrlManager.FindNullImage(AListOfCurrentRx: TStrings;
  ANoImagesReservedExternalToList: integer): TImageControl;
Var
  IDX, NextManual: integer;
  LImage, TstImage: TObject;
begin
  NextManual := ANoImagesReservedExternalToList;
  Result := nil;
  while (Result = nil) and (NextManual < Length(FImageArray)) do
  Begin
    IDX := 0;
    TstImage := ImageControl(NextManual);
    While IDX < AListOfCurrentRx.Count - 1 do
    begin
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLink then
        with (AListOfCurrentRx.Objects[IDX] as TVideoChnlLink) do
        Begin
          TstImage := FImage;
          if (TstImage <> nil) then
            if TstImage = LImage then
              IDX := AListOfCurrentRx.Count + 3;
        End;
      inc(IDX);
    end;
    if IDX = AListOfCurrentRx.Count then // was not found
      Result := FImageArray[NextManual] as TImageControl;

    if Result = nil then
      inc(NextManual);
  End;
end;

procedure TImageCntrlManager.GrowImageLists(AImagePnl: TPanel;
  ANoOfChnls: integer);
Var
  NewImageCtrl: TImageControl;
  CurrentLength: integer;
  IDX: integer;
begin
  if AImagePnl <> FImagesPanel then
  Begin
    ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
    Exit;
  End;
  try
    if FImagesPanel = nil then
      Exit;

    FImagesPanel.OnResize := DoOnPanelResize;
    CurrentLength := Length(FImageArray);
    if CurrentLength < ANoOfChnls then
    Begin
      Setlength(FImageArray, ANoOfChnls);
      Setlength(FPArray, ANoOfChnls);
      while CurrentLength < ANoOfChnls do
      Begin
        FPArray[CurrentLength] := TImagePosObj.Create(Self);
        NewImageCtrl := TImageControl.Create
          (nil { self //I will Free Images } );
        NewImageCtrl.Enabled := true;
        NewImageCtrl.EnableOpenDialog := false;
        NewImageCtrl.EnableDragHighlight := false;
        NewImageCtrl.OnClick := FPArray[CurrentLength].OnImageClick;
        NewImageCtrl.Bitmap := DefaultBitMap;
        NewImageCtrl.Name := AImagePnl.Name + 'Im' + IntToStr(CurrentLength);
        NewImageCtrl.Parent := FImagesPanel; // parent
        FImageArray[CurrentLength] := NewImageCtrl;
        inc(CurrentLength);
      End;
      for IDX := 0 to CurrentLength - 1 do
        FPArray[IDX].ReSetValues(IDX, TPointF.Zero, TPointF.Zero, TPointF.Zero);
    End;
    // if ShortSliderForm.FNoAutoImgs <> ANoOfChnls then
    // ShortSliderForm.ReviewImages;
    SetImagePanels(FImagesPanel);
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'GrowImageLists');
  end;
end;

procedure TImageCntrlManager.ImageClicked(APosObj: TImagePosObj);
begin
  if APosObj = FCurrentPrime then
    FCurrentPrime := nil
  else
    FCurrentPrime := APosObj;
  SetImagePanels(FImagesPanel);
end;

function TImageCntrlManager.ImageControl(AIndx: integer): TImageControl;
begin
  if AIndx < Length(FImageArray) then
    Result := FImageArray[AIndx] As TImageControl
  else
  Begin
    Result := nil;
    ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
  End;
end;

function TImageCntrlManager.ImageControlArray: TImageArray;
begin
  Result := FImageArray;
end;

procedure TImageCntrlManager.InsertImagesAt(AImagePnl: TPanel;
  AAddAt, ANoToAdd: integer);
Var
  ThisArray: TArrayofObjects;
  I, CurrentLength: integer;
  NewImage: TImageControl;
begin
  ThisArray := TArrayofObjects(FImageArray);
  InsertIntoArray(ThisArray, AAddAt, ANoToAdd);
  FImageArray := TImageArray(ThisArray);
  ThisArray := TArrayofObjects(FPArray);
  InsertIntoArray(ThisArray, AAddAt, ANoToAdd);
  FPArray := TImagePosObjArray(ThisArray);
  CurrentLength := Length(ThisArray);

  for I := AAddAt to (ANoToAdd + AAddAt - 1) do
  Begin
    FPArray[I] := TImagePosObj.Create(Self);
    NewImage := TImageControl.Create(nil { self //I will Free Images } );
    NewImage.Enabled := true;
    NewImage.EnableOpenDialog := false;
    NewImage.EnableDragHighlight := false;
    NewImage.OnClick := FPArray[I].OnImageClick;
    // NewImageCtrl.Bitmap := DefaultBitMap;
    NewImage.Name := AImagePnl.Name + 'Im' + IntToStr(CurrentLength - I);
    NewImage.Parent := FImagesPanel; // parent
    // NewImage.Stretch := true;
    // NewImage.Proportional := true;
    FImageArray[I] := NewImage;
  End;

  for I := 0 to (CurrentLength - 1) do
    FPArray[I].ReSetValues(I, TPointF.Zero, TPointF.Zero, TPointF.Zero);
  SetImagePanels(FImagesPanel);
End;

procedure TImageCntrlManager.SetImagePanels(AImagePnl: TPanel);
Var
  ImgIdx, ImgCnt, ColCnt, RowCnt, ColIdx, RowIdx: integer;
  PnlWidth, PnlHeight, ImgWidth, ImgHeight: single;
  ThisPos, ThisScale, ThisSz: TPointF;
begin
  if AImagePnl = nil then
    Exit;
  if AImagePnl <> FImagesPanel then
  Begin
    ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
    Exit;
  End;
  try
    ImgCnt := Length(FImageArray);
    if Length(FPArray) <> ImgCnt then
      ISIndyUtilsException(Self, 'Bad # of images');
    For ImgIdx := 0 to ImgCnt - 1 do
      FPArray[ImgIdx].ReSetValues(ImgIdx, TPointF.Zero, TPointF.Zero,
        TPointF.Zero);

    if ImgCnt < 1 then
      Exit;

    PnlWidth := FImagesPanel.Width;
    PnlHeight := FImagesPanel.Height;
    ThisScale := FImagesPanel.Scale.Point;

    if FCurrentPrime <> nil then
    begin
      ImgIdx := 0;
      ThisSz := TPointF.Create(PnlWidth, PnlHeight);
      ThisPos := TPointF.Create(0.0005, 0.0005);
      while ImgIdx < ImgCnt do
      Begin
        if FCurrentPrime = FPArray[ImgIdx] then
          FPArray[ImgIdx].ReSetValues(ImgIdx, ThisSz, ThisPos, ThisScale)
        else
          FPArray[ImgIdx].ReSetValues(ImgIdx, ThisPos, ThisPos, TPoint.Zero);
        inc(ImgIdx);
      End;
    end
    Else
    Begin
      SetRowsCols(PnlWidth, PnlHeight, ColCnt, RowCnt);
      ImgWidth := PnlWidth / ColCnt;
      ImgHeight := PnlHeight / RowCnt;
      ThisPos := TPointF.Create(0, 0);
      ImgIdx := 0;
      ColIdx := 0;
      RowIdx := 0;
      ThisSz := TPointF.Create(PnlWidth / ColCnt, PnlHeight / RowCnt);
      While ColIdx < ColCnt do
      begin
        while RowIdx < RowCnt do
        Begin
          if ImgIdx < ImgCnt then
          Begin
            FPArray[ImgIdx].ReSetValues(ImgIdx, ThisSz, ThisPos, ThisScale);
            inc(ImgIdx);
          End
          Else
            RowIdx := RowCnt;
          ThisPos.Y := ThisPos.Y + ImgHeight;
          inc(RowIdx);
        End;
        RowIdx := 0;
        ThisPos.Y := 0;
        ThisPos.X := ThisPos.X + ImgWidth;
        inc(ColIdx);
      end;
    End;

  Except
    On E: Exception do
      ISIndyUtilsException('Class TImagePosObj', E, 'Set Image Panels');
  end;
end;

procedure TImageCntrlManager.SetRowsCols(APnlWidth, APnlHeight: single;
  Out AColCnt, ARowCnt: integer);

{ sub } Function NextAspect(AIdx: integer; Out AValid: Boolean): single;
  Var
    ThisImage: TImageControl;
  Begin
    Result := 0;
    AValid := false;
    if (FImageArray[AIdx] is TImageControl) then
    Begin
      ThisImage := TImageControl(FImageArray[AIdx]);
      if ThisImage.Bitmap <> nil then
        if ThisImage.Bitmap.Width > 0 then
        Begin
          Result := ThisImage.Bitmap.Width / ThisImage.Bitmap.Height;
          AValid := true;
        End;
    End;
  End;

Var
  PnlAspectRatio, AverageAspectRatio, SqRtAverageAspectRatio, StdzPnlWidth,
    StdzPnlHeight, StdzImageWidth, StdzImageHeight: single;
  IDX, Images, ValidImages: integer;
  ValidImage: Boolean;
Begin
  IDX := 0;
  ValidImages := 0;
  AverageAspectRatio := 0;
  Images := Length(FImageArray);
  While IDX < Images do
  Begin
    AverageAspectRatio := AverageAspectRatio + NextAspect(IDX, ValidImage);
    if ValidImage then
      inc(ValidImages);
    inc(IDX);
  End;
  if ValidImages = 0 then
    AverageAspectRatio := 1
  else
    AverageAspectRatio := AverageAspectRatio / ValidImages;

  if not SameValue(1, AverageAspectRatio) then
    if SameValue(AverageAspectRatio, cTstAspect, 0.00001) then
      inc(ARowCnt)
    else
      inc(AColCnt);

  SqRtAverageAspectRatio := SqRt(AverageAspectRatio);
  StdzImageWidth := SqRtAverageAspectRatio;
  StdzImageHeight := 1 / SqRtAverageAspectRatio;

  if SameValue(StdzImageWidth * StdzImageHeight, 1, 0.00001) then
    inc(ARowCnt) //All OK
  else
    inc(AColCnt); //Problem

  if SameValue(StdzImageWidth / StdzImageHeight, AverageAspectRatio, 0.00001)
  then
    inc(ARowCnt) //All OK
  else
    inc(AColCnt); //Problem

  PnlAspectRatio := APnlWidth / APnlHeight;
  StdzPnlWidth := SqRt(Images * PnlAspectRatio);
  StdzPnlHeight := StdzPnlWidth / PnlAspectRatio;
   StdzPnlHeight := SqRt(Images/PnlAspectRatio);

  if SameValue(StdzImageWidth * StdzImageHeight, 1, 0.00001) then
    inc(ARowCnt) //All OK
  else
    inc(AColCnt); //Problem

  if SameValue(StdzPnlWidth * StdzPnlHeight, Images, 0.00001) then
    inc(ARowCnt) //All OK
  else
    inc(AColCnt); //Problem

//   AColCnt := Trunc(StdzPnlWidth / StdzImageWidth);
//   ARowCnt := Trunc(StdzPnlHeight / StdzImageHeight);
  AColCnt := Round(StdzPnlWidth / StdzImageWidth);
  ARowCnt := Round(StdzPnlHeight / StdzImageHeight);

  if AColCnt <= 1 then
  Begin
    AColCnt := 1;
    ARowCnt := Images;
  end;
  if ARowCnt <= 1 then
  Begin
    ARowCnt := 1;
    AColCnt := Images;
  end;

  ValidImages := AColCnt * ARowCnt;
  While ValidImages < Images do
    Begin
     if AColCnt < ARowCnt then
       Begin
         if (Images - ValidImages)<=AColCnt then
           Inc(AColCnt)
          else
           Inc(ARowCnt);
       end
       else
       Begin
         if (Images - ValidImages)<=ARowCnt then
           Inc(AColCnt)
          else
           Inc(ARowCnt);
       End;
     ValidImages := AColCnt * ARowCnt;
    end;

    if ValidImages >= (Images + ARowCnt) then
      Dec (AColCnt)
    else
      if ValidImages >= (Images + AColCnt) then
         Dec (ARowCnt);

  ValidImages := AColCnt * ARowCnt;
  if ValidImages < Images then
     ISIndyUtilsException(Self,'ValidImages < Images');
  (*
    Var
    Landscape: Boolean;
    ImgCnt: integer;
    begin
    Landscape := APnlWidth > APnlHeight;
    ImgCnt := Length(FImageArray);
    case ImgCnt of
    1:
    Begin
    AColCnt := 1;
    ARowCnt := 1;
    End;
    2:
    Begin
    if Landscape then
    Begin
    AColCnt := 2;
    ARowCnt := 1;
    End
    else
    Begin
    AColCnt := 1;
    ARowCnt := 2;
    End;
    End;
    3 .. 4:
    Begin
    Begin
    AColCnt := 2;
    ARowCnt := 2;
    End
    End;
    5 .. 6:
    Begin
    if Landscape then
    Begin
    AColCnt := 3;
    ARowCnt := 2;
    End
    else
    Begin
    AColCnt := 2;
    ARowCnt := 3;
    End;
    End;
    7 .. 9:
    Begin
    if Landscape then
    Begin
    AColCnt := 3;
    ARowCnt := 3;
    End
    else
    Begin
    AColCnt := 3;
    ARowCnt := 3;
    End;
    End;
    10 .. 12:
    Begin
    if Landscape then
    Begin
    AColCnt := 4;
    ARowCnt := 3;
    End
    else
    Begin
    AColCnt := 3;
    ARowCnt := 4;
    End;
    End;
    13 .. 15:
    Begin
    if Landscape then
    Begin
    AColCnt := 5;
    ARowCnt := 3;
    End
    else
    Begin
    AColCnt := 3;
    ARowCnt := 5;
    End;
    End;
    16:
    Begin
    AColCnt := 4;
    ARowCnt := 4;
    End;
    17 .. 20:
    Begin
    if Landscape then
    Begin
    AColCnt := 5;
    ARowCnt := 4;
    End
    else
    Begin
    AColCnt := 4;
    ARowCnt := 5;
    End;
    End;

    21 .. 24:
    Begin
    if Landscape then
    Begin
    AColCnt := 6;
    ARowCnt := 4;
    End
    else
    Begin
    AColCnt := 4;
    ARowCnt := 6;
    End;
    End;
    25 .. 30:
    Begin
    if Landscape then
    Begin
    AColCnt := 6;
    ARowCnt := 5;
    End
    else
    Begin
    AColCnt := 5;
    ARowCnt := 6;
    End;
    End;
    31 .. 36:
    Begin
    if Landscape then
    Begin
    AColCnt := 6;
    ARowCnt := 6;
    End
    else
    Begin
    AColCnt := 6;
    ARowCnt := 6;
    End;
    End;
    37 .. 49:
    Begin
    AColCnt := 7;
    ARowCnt := 7;
    End;
    Else
    Begin
    if Landscape then
    Begin
    AColCnt := 10;
    ARowCnt := 8;
    End
    else
    Begin
    AColCnt := 8;
    ARowCnt := 10;
    End;
    End;
    end;
  *)
end;

{ TVideoChnlLink }
procedure TVideoChnlLink.BlankInactiveChannel(AInLastNoMins: integer);
begin
  try
    if VideoIsActive(AInLastNoMins) then
      Exit;

    RxGraphic(nil);
    if FVideoComs <> nil then
    Begin
      if Assigned(FVideoComs.OnInComingGraphic) then
        FVideoComs.OnInComingGraphic(nil);
    End;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'DisConnectInactiveChannel');
    end;
  end;
end;

procedure TVideoChnlLink.ChannelClosing(ASender: TObject);
begin
  FVideoComs := nil;

  if GblLogAllChlOpenClose then
    if ASender is TISIndyTCPBase then
      ISIndyUtilsException(Self, 'ChannelClosing >> ' +
        TISIndyTCPBase(ASender).TextID)
    else
      ISIndyUtilsException(Self, 'ChannelClosing No Ref');
end;

constructor TVideoChnlLink.Create(AHost: String; APort: integer;
  ALinkRef: String; AImage: TImageControl);
begin
  Try
    FSyncBitmap := true;
    FLinkRef := ALinkRef;
    FImage := AImage;
    FHost := AHost;
    FPort := APort;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

destructor TVideoChnlLink.Destroy;
begin
  FreeAndNilDuplexChannel(FVideoComs);
  inherited;
end;

procedure TVideoChnlLink.DisConnectInactiveChannel(AInLastNoMins: integer);
begin
  try
    if VideoIsActive(AInLastNoMins) then
      Exit;

    if FVideoComs <> nil then
      if FVideoComs.ChannelActiveWithGraphic(AInLastNoMins / 24 / 60) then
        Exit
      else
        FreeAndNilDuplexChannel(FVideoComs);
  Except
    On E: Exception do
    begin
      FVideoComs := nil;
      ISIndyUtilsException(Self, E, 'DisConnectInactiveChannel');
    end;
  end;
end;

function TVideoChnlLink.RxAnsiString(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
begin
  Result := '';
  if ATcpSession is TVideoComsChannel then
  Begin
    if ATcpSession = FVideoComs then
      FVideoComs.OpenChannel
    Else
      ISIndyUtilsException(Self, 'Miss matched channel in RxAnsiString');
  End
  Else if ATcpSession = nil then
    ISIndyUtilsException(Self, 'Nil Channel in RxAnsiString')
  else
    ISIndyUtilsException(Self, 'Non Video channel in RxAnsiString');
end;

procedure TVideoChnlLink.RxGraphic(AGraphic: TBitmap);
begin
  if FImage = nil then
    Exit
  else if FImage is TImageControl then
  Begin
    if FSyncBitmap and IsNotMainThread then
      raise Exception.Create('RxGraphic not Synced');

    if (AGraphic = nil) then
    begin
      if FVideoComs is TVideoComsChannel then
      Begin
        if not FVideoComs.ChannelActiveWithGraphic(1 / 24 / 60) then
          if FImage.Visible then
            FImage.Visible := false;
      End
      Else
      begin
        FImage.Bitmap := nil;
        if FImage.Visible then
          FImage.Visible := false;
      end;
    end
    else
    Begin
      if FSyncBitmap and IsNotMainThread then
        raise Exception.Create('RxGraphic not Synced');
      FLastRxGraphicTime := Now;
      FActiveChnl := true;
      FImage.Bitmap := AGraphic;
      // Bitmap is assigned >> Refcount data inc

      if Not FImage.Visible then
        FImage.Visible := true;
    End;
  End;
end;

procedure TVideoChnlLink.SetImage(const Value: TImageControl);
begin
  FImage := Value;
end;

function TVideoChnlLink.VideoComs: TVideoComsChannel;
begin
  if FVideoComs = nil then
    Try
      FVideoComs := TVideoComsChannel.StartAccess(FHost, FPort);
      FVideoComs.OnInComingGraphic := RxGraphic;
      FVideoComs.OnAnsiStringAction := RxAnsiString;
      FVideoComs.OnSimpleDuplexRemoteAction := RxAnsiString;
      FVideoComs.SynchronizeResults := true;
      FVideoComs.OnDestroy := ChannelClosing;
      If not FVideoComs.ServerSetLinkConnection(FLinkRef) then
        FreeAndNil(FVideoComs)
      else
        FVideoComs.OpenChannel;
    Except
      On E: Exception do
      Begin
        ISIndyUtilsException(Self, E, 'VideoComs');
        FreeAndNil(FVideoComs);
      End;
    End;
  Result := FVideoComs;
end;

function TVideoChnlLink.VideoIsActive(AInLastNoMins: integer): Boolean;
Var
  Recent: Boolean;
begin
  try
    if AInLastNoMins < 1 then
      AInLastNoMins := 3;
    if FActiveChnl then
      Result := (FLastRxGraphicTime + AInLastNoMins / (24 * 60)) > (Now)
    else
      Result := false;
    FActiveChnl := Result;
  Except
    On E: Exception do
    begin
      FVideoComs := nil;
      ISIndyUtilsException(Self, E, 'VideoIsActive');
    end;
  end;
end;

end.
