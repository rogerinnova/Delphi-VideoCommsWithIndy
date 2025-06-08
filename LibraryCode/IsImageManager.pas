unit IsImageManager;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
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
    FTabPnl: TPanel;
    FDefaultBitMap: TBitmap;
    // FImagesPanel: TPanel;
    FImageArray: TImageArray;
    FCurrentPrime: TImagePosObj;
    FPArray: TImagePosObjArray;
    Function DefaultBitMap: TBitmap;
    Procedure DoOnPanelResize(Sender: TObject);
    Procedure ImageClicked(APosObj: TImagePosObj);
  public
    Constructor Create(ATabPnl: TPanel; ANoOfChnls: Integer);
    Destructor Destroy; override;
    Procedure SetImagePanels(ATabPnl: TPanel);
    Procedure InsertImagesAt(ATabPnl: TPanel; AAddAt, ANoToAdd: Integer);
    Procedure GrowImageLists(ATabPnl: TPanel; ANoOfChnls: Integer);
    Procedure DisConnectInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: Integer);
    Procedure BlankInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: Integer);
    Function ImageControl(AIndx: Integer): TImageControl;
    Function ImageControlArray: TImageArray;
    Function FindNullImage(AListOfCurrentRx: TStrings;
      ANoImagesReservedExternalToList: Integer): TImageControl;
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
    Procedure ReSetValues(AThisIndx: Integer; ASz, APos, AScale: TPointF);
  end;

  TVideoChnlLink = class(TObject)
  Private
    FLinkRef: string;
    FImage: TImageControl;
    FHost: string;
    FPort: Integer;
    FSyncBitmap: Boolean;
    FVideoComs: TVideoComsChannel;
    FLastRxGraphicTime: TDateTime;
    FActiveChnl: Boolean;
    Function RxAnsiString(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Procedure ChannelClosing(ASender: TObject);
    procedure SetImage(const Value: TImageControl);
  Public
    Constructor Create(AHost: String; APort: Integer; ALinkRef: String;
      AImage: TImageControl);
    Destructor Destroy; override;
    Procedure DisConnectInactiveChannel(AInLastNoMins: Integer);
    Procedure BlankInactiveChannel(AInLastNoMins: Integer);
    Procedure RxGraphic(AGraphic: TBitmap);
    Function VideoComs: TVideoComsChannel;
    Function VideoIsActive(AInLastNoMins: Integer): Boolean;
    Property Image: TImageControl write SetImage;
    Property LinkRef: string read FLinkRef;
  end;

Var
  GblDefaultBitMap: TBitmap = nil;

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
  FParentPanel := FImageManager.FTabPnl;
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

procedure TImagePosObj.ReSetValues(AThisIndx: Integer;
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
  : TStrings; AMinutesInActive: Integer);
Var
  IDX: Integer;
begin
  if AListOfCurrentRx = nil then
    Exit;
  if AListOfCurrentRx.Count > 0 then
    for IDX := 0 to AListOfCurrentRx.Count - 1 do
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLink then
        TVideoChnlLink(AListOfCurrentRx.Objects[IDX])
          .BlankInactiveChannel(AMinutesInActive);
end;

constructor TImageCntrlManager.Create(ATabPnl: TPanel; ANoOfChnls: Integer);
begin
  FTabPnl := ATabPnl;
  if FTabPnl = nil then
    Exit;

  GrowImageLists(FTabPnl, ANoOfChnls);
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
  : TStrings; AMinutesInActive: Integer);
Var
  IDX: Integer;
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
  SetImagePanels(FTabPnl);
end;

function TImageCntrlManager.FindNullImage(AListOfCurrentRx: TStrings;
  ANoImagesReservedExternalToList: Integer): TImageControl;
Var
  IDX, NextManual: Integer;
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

procedure TImageCntrlManager.GrowImageLists(ATabPnl: TPanel;
  ANoOfChnls: Integer);
Var
  NewImageCtrl: TImageControl;
  CurrentLength: Integer;
  IDX: Integer;
begin
  if ATabPnl <> FTabPnl then
  Begin
    ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
    Exit;
  End;
  try
    if FTabPnl = nil then
      Exit;

    FTabPnl.OnResize := DoOnPanelResize;
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
        NewImageCtrl.Name := ATabPnl.Name + 'Im' + IntToStr(CurrentLength);
        NewImageCtrl.Parent := FTabPnl; // parent
        FImageArray[CurrentLength] := NewImageCtrl;
        inc(CurrentLength);
      End;
      for IDX := 0 to CurrentLength - 1 do
        FPArray[IDX].ReSetValues(IDX, TPointF.Zero, TPointF.Zero, TPointF.Zero);
    End;
    // if ShortSliderForm.FNoAutoImgs <> ANoOfChnls then
    // ShortSliderForm.ReviewImages;
    SetImagePanels(FTabPnl);
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
  SetImagePanels(FTabPnl);
end;

function TImageCntrlManager.ImageControl(AIndx: Integer): TImageControl;
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

procedure TImageCntrlManager.InsertImagesAt(ATabPnl: TPanel;
  AAddAt, ANoToAdd: Integer);
Var
  ThisArray: TArrayofObjects;
  I, CurrentLength: Integer;
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
    NewImage.Name := ATabPnl.Name + 'Im' + IntToStr(CurrentLength - I);
    NewImage.Parent := FTabPnl; // parent
    // NewImage.Stretch := true;
    // NewImage.Proportional := true;
    FImageArray[I] := NewImage;
  End;

  for I := 0 to (CurrentLength - 1) do
    FPArray[I].ReSetValues(I, TPointF.Zero, TPointF.Zero, TPointF.Zero);
  SetImagePanels(FTabPnl);
End;

procedure TImageCntrlManager.SetImagePanels(ATabPnl: TPanel);
Var
  ImgIdx, ImgCnt, ColCnt, RowCnt, ColIdx, RowIdx: Integer;
  PnlWidth, PnlHeight, ImgWidth, ImgHeight: Single;
  ThisPos, ThisScale, ThisSz: TPointF;
  Landscape: Boolean;
begin
  if ATabPnl = nil then
    Exit;
  if ATabPnl <> FTabPnl then
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

    PnlWidth := FTabPnl.Width;
    PnlHeight := FTabPnl.Height;
    ThisScale := FTabPnl.Scale.Point;
    Landscape := PnlWidth > PnlHeight;

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
      case ImgCnt of
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
              RowCnt := 3;
            End
            else
            Begin
              ColCnt := 3;
              RowCnt := 2;
            End;
          End;
        7 .. 12:
          Begin
            if Landscape then
            Begin
              ColCnt := 3;
              RowCnt := 4;
            End
            else
            Begin
              ColCnt := 4;
              RowCnt := 3;
            End;
          End;
        13 .. 15:
          Begin
            if Landscape then
            Begin
              ColCnt := 3;
              RowCnt := 5;
            End
            else
            Begin
              ColCnt := 5;
              RowCnt := 3;
            End;
          End;
        16 .. 24:
          Begin
            if Landscape then
            Begin
              ColCnt := 4;
              RowCnt := 6;
            End
            else
            Begin
              ColCnt := 6;
              RowCnt := 4;
            End;
          End;
        25 .. 30:
          Begin
            if Landscape then
            Begin
              ColCnt := 5;
              RowCnt := 6;
            End
            else
            Begin
              ColCnt := 6;
              RowCnt := 5;
            End;
          End;
        31 .. 36:
          Begin
            if Landscape then
            Begin
              ColCnt := 6;
              RowCnt := 6;
            End
            else
            Begin
              ColCnt := 6;
              RowCnt := 6;
            End;
          End;
        37.. 49:
          Begin
              ColCnt := 7;
              RowCnt := 7;
          End;
      Else
        Begin
          if Landscape then
          Begin
            ColCnt := 10;
            RowCnt := 8;
          End
          else
          Begin
            ColCnt := 8;
            RowCnt := 10;
          End;
        End;
      end;
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

{ TVideoChnlLink }
procedure TVideoChnlLink.BlankInactiveChannel(AInLastNoMins: Integer);
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

constructor TVideoChnlLink.Create(AHost: String; APort: Integer;
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

procedure TVideoChnlLink.DisConnectInactiveChannel(AInLastNoMins: Integer);
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

function TVideoChnlLink.VideoIsActive(AInLastNoMins: Integer): Boolean;
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
