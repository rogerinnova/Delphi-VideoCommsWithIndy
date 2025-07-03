unit IsImageManagerVCL;
{$IFDEF FPC}
{$MODE Delphi}
// {$I InnovaLibDefsLaz.inc}
{$H+}
{$ELSE}
// {$I InnovaLibDefs.inc}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  SysUtils, Types, UITypes, Classes,
  Variants, Math,
  Controls,
  Graphics,
  ExtCtrls,
{$ELSE}
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math,
  VCL.Controls,
  VCL.Graphics,
  VCL.ExtCtrls,
{$ENDIF}
  IsMediaCommsObjs, IsRemoteConnectionIndyTcpObjs, IsArrayLib;

Type
  // {$IFDEF UseVCLBITMAP}

  TImageControl = class(TImage)
  private
    function GetBitmap: TGraphic;
    procedure SetBitMap(const Value: TGraphic);
  Public
    Property BitMap: TGraphic Read GetBitmap write SetBitMap;
  end;
  // {$ENDIF}

  TImagePosObjVCL = class;
  TImageArray = Array of TObject;
  TImagePosObjArray = Array of TImagePosObjVCL;

  TImageMngrVCL = class(TObject)
  private
    FTabPnl: TPanel;
    FDefaultBitMap: TBitmap;
    FImageArray: TImageArray;
    FCurrentPrime: TImagePosObjVCL;
    FPArray: TImagePosObjArray;
    Function DefaultBitMap: TBitmap;
    Procedure DoOnPanelResize(Sender: TObject);
    Procedure ImageClicked(APosObj: TImagePosObjVCL);
    Procedure SetRowsCols(APnlWidth, APnlHeight: single;
      Out AColCnt, ARowCnt: integer);
  public
    Constructor Create(ATabPnl: TPanel; ANoOfChnls: Integer);
    Destructor Destroy; override;
    Procedure SetImagePanels(ATabPnl: TPanel);
    Procedure InsertImagesAt(ATabPnl: TPanel; AAddAt, ANoToAdd: Integer);
    Procedure GrowImageLists(ATabPnl: TPanel; ANoOfMangedImages: Integer);
    Procedure DisConnectInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: Integer);
    Procedure BlankInactiveImageChannels(AListOfCurrentRx: TStrings;
      AMinutesInActive: Integer);
    Function ImageControl(AIndx: Integer): TImageControl;
    Function ImageControlArray: TImageArray;
    Function FindNullImage(AListOfCurrentRx: TStrings;
      ANoImagesReservedExternalToList: Integer): TImageControl;
  end;

  TImagePosObjVCL = class(TObject)
  Public
    Procedure OnImageClick(Sender: TObject);
    Constructor Create(AImageCtrlManager: TImageMngrVCL);
  Private
    FImagelManager: TImageMngrVCL;
    FImage: TImageControl;
    FPresetBmp: TBitmap;
    FParentPanel: TPanel;
    FSz, FPos : TPointF;
    Procedure ReSetValues(AThisIndx: Integer; ASz, APos : TPointF);
  end;

  TVideoChnlLinkVCL = class(TObject)
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
    Procedure RxGraphic(AGraphic: TGraphic);
    Procedure ChannelClosing(ASender: TObject);
    procedure SetImage(const Value: TImageControl);
  Public
    Constructor Create(AHost: String; APort: Integer; ALinkRef: String;
      AImage: TImageControl);
    Destructor Destroy; override;
    Procedure DisConnectInactiveChannel(AInLastNoMins: Integer);
    Procedure BlankInactiveChannel(AInLastNoMins: Integer);
    Function VideoComs: TVideoComsChannel;
    Function VideoIsActive(AInLastNoMins: Integer): Boolean;
    Property Image: TImageControl write SetImage;
    Property LinkRef: string read FLinkRef;
  end;

Var
  GblDefaultBitMap: TBitmap = nil;
  cTstAspect: single = 0.5;

implementation

uses IsGblLogCheck, IsIndyUtils, IsLogging;

function TPointFZero: TPointF;
begin
  Result.X := 0;
  Result.Y := 0;
end;

{ TImageCntrlManager }

procedure TImageMngrVCL.BlankInactiveImageChannels(AListOfCurrentRx: TStrings;
  AMinutesInActive: Integer);
Var
  IDX: Integer;
begin
  if AListOfCurrentRx = nil then
    Exit;
  if AListOfCurrentRx.Count > 0 then
    for IDX := 0 to AListOfCurrentRx.Count - 1 do
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLinkVCL then
        TVideoChnlLinkVCL(AListOfCurrentRx.Objects[IDX])
          .BlankInactiveChannel(AMinutesInActive);
end;

constructor TImageMngrVCL.Create(ATabPnl: TPanel; ANoOfChnls: Integer);
begin
  FTabPnl := ATabPnl;
  if FTabPnl = nil then
    Exit;
  FCurrentPrime := nil;

  GrowImageLists(FTabPnl, ANoOfChnls);
end;

function TImageMngrVCL.DefaultBitMap: TBitmap;
begin
  if FDefaultBitMap = nil then
  begin
    FDefaultBitMap := TBitmap.Create;
    FDefaultBitMap.Assign(GblDefaultBitMap)
  End;

  Result := FDefaultBitMap;
end;

destructor TImageMngrVCL.Destroy;
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

procedure TImageMngrVCL.DisConnectInactiveImageChannels(AListOfCurrentRx
  : TStrings; AMinutesInActive: Integer);
Var
  IDX: Integer;
begin
  if AListOfCurrentRx = nil then
    Exit;
  if AListOfCurrentRx.Count > 0 then
    for IDX := 0 to AListOfCurrentRx.Count - 1 do
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLinkVCL then
        TVideoChnlLinkVCL(AListOfCurrentRx.Objects[IDX])
          .DisConnectInactiveChannel(AMinutesInActive);
end;

procedure TImageMngrVCL.DoOnPanelResize(Sender: TObject);
begin
  // if Sender=FTabPnl then
  SetImagePanels(FTabPnl);
end;

function TImageMngrVCL.FindNullImage(AListOfCurrentRx: TStrings;
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
      if AListOfCurrentRx.Objects[IDX] is TVideoChnlLinkVCL then
        with (AListOfCurrentRx.Objects[IDX] as TVideoChnlLinkVCL) do
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

  if Result = nil then
  begin
    GrowImageLists(FTabPnl, NextManual + 1);
    Result := ImageControl(NextManual);
  end;
end;

procedure TImageMngrVCL.GrowImageLists(ATabPnl: TPanel;
  ANoOfMangedImages: Integer);
Var
  NewImage: TImageControl;
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
    if CurrentLength < ANoOfMangedImages then
    Begin
      Setlength(FImageArray, ANoOfMangedImages);
      Setlength(FPArray, ANoOfMangedImages);
      while CurrentLength < ANoOfMangedImages do
      Begin
        FPArray[CurrentLength] := TImagePosObjVCL.Create(Self);
        NewImage := TImageControl.Create(nil { self //I will Free Images } );
        NewImage.Enabled := true;
        // NewImageCtrl.EnableOpenDialog := false;
        // NewImageCtrl.EnableDragHighlight := false;
        NewImage.OnClick := FPArray[CurrentLength].OnImageClick;
        // NewImageCtrl.Bitmap := DefaultBitMap;
        NewImage.Name := ATabPnl.Name + 'Im' + IntToStr(CurrentLength);
        NewImage.Parent := FTabPnl; // parent
        NewImage.Stretch := true;
        NewImage.Proportional := true;
        FImageArray[CurrentLength] := NewImage;
        inc(CurrentLength);
      End;
      for IDX := 0 to CurrentLength - 1 do
        FPArray[IDX].ReSetValues(IDX, TPointFZero, TPointFZero);
    End;
    SetImagePanels(FTabPnl);
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'GrowImageLists');
  end;
end;

procedure TImageMngrVCL.ImageClicked(APosObj: TImagePosObjVCL);
begin
  if APosObj = FCurrentPrime then
    FCurrentPrime := nil
  else
    FCurrentPrime := APosObj;
  SetImagePanels(FTabPnl);
end;

function TImageMngrVCL.ImageControl(AIndx: Integer): TImageControl;
begin
  if AIndx < Length(FImageArray) then
    Result := FImageArray[AIndx] As TImageControl
  else
  Begin
    Result := nil;
    ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
  End;
end;

function TImageMngrVCL.ImageControlArray: TImageArray;
begin
  Result := FImageArray;
end;

procedure TImageMngrVCL.InsertImagesAt(ATabPnl: TPanel;
  AAddAt, ANoToAdd: Integer);
Var
  ThisArray: TArrayofObjects;
  I, CurrentLength: Integer;
  NewImage: TImage;
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
    FPArray[I] := TImagePosObjVCL.Create(Self);
    NewImage := TImageControl.Create(nil { self //I will Free Images } );
    NewImage.Enabled := true;
    // NewImageCtrl.EnableOpenDialog := false;
    // NewImageCtrl.EnableDragHighlight := false;
    NewImage.OnClick := FPArray[I].OnImageClick;
    // NewImageCtrl.Bitmap := DefaultBitMap;
    NewImage.Name := ATabPnl.Name + 'Im' + IntToStr(CurrentLength - I);
    NewImage.Parent := FTabPnl; // parent
    NewImage.Stretch := true;
    NewImage.Proportional := true;
    FImageArray[I] := NewImage;
  End;

  for I := 0 to (CurrentLength - 1) do
    FPArray[I].ReSetValues(I, TPointFZero, TPointFZero);
  SetImagePanels(FTabPnl);
End;

procedure TImageMngrVCL.SetImagePanels(ATabPnl: TPanel);
Var
  ImgIdx, ImgCnt, ColCnt, RowCnt, ColIdx, RowIdx: integer;
  PnlWidth, PnlHeight, ImgWidth, ImgHeight: single;
  ThisPos, ThisSz: TPointF;
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
      FPArray[ImgIdx].ReSetValues(ImgIdx, TPointF.Zero, TPointF.Zero);

    if ImgCnt < 1 then
      Exit;

    PnlWidth := FTabPnl.Width;
    PnlHeight := FTabPnl.Height;
    if FCurrentPrime <> nil then
    begin
      ImgIdx := 0;
      ThisSz := TPointF.Create(PnlWidth, PnlHeight);
      ThisPos := TPointF.Create(0.0005, 0.0005);
      while ImgIdx < ImgCnt do
      Begin
        if FCurrentPrime = FPArray[ImgIdx] then
          FPArray[ImgIdx].ReSetValues(ImgIdx, ThisSz, ThisPos)
        else
          FPArray[ImgIdx].ReSetValues(ImgIdx, ThisPos, ThisPos);
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
            FPArray[ImgIdx].ReSetValues(ImgIdx, ThisSz, ThisPos);
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

procedure TImageMngrVCL.SetRowsCols(APnlWidth, APnlHeight: single; out AColCnt,
  ARowCnt: integer);

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

{ TImagePosObjVCL }

constructor TImagePosObjVCL.Create(AImageCtrlManager: TImageMngrVCL);
begin
  FImagelManager := AImageCtrlManager;
  if FImagelManager = nil then
    Raise Exception.Create('Must Have FImageCtrlManager');
  FPresetBmp := FImagelManager.DefaultBitMap; // testing
  FParentPanel := FImagelManager.FTabPnl;
  Inherited Create;
end;

procedure TImagePosObjVCL.OnImageClick(Sender: TObject);
begin
  if Sender = FImage then
    if FImagelManager <> nil then
    Begin
      FImagelManager.ImageClicked(Self);
      Exit;
    End;
  raise Exception.Create('TImagePosObj.OnImageClick');
  ISIndyUtilsException(Self, 'Blank TImagePosObj.OnImageClick')
end;

procedure TImagePosObjVCL.ReSetValues(AThisIndx: Integer;
  ASz, APos: TPointF);

begin
  if (Length(FImagelManager.FImageArray) <= AThisIndx) or
    (Length(FImagelManager.FPArray) <= AThisIndx) or
    (Self <> (FImagelManager.FPArray)[AThisIndx]) then
    raise Exception.Create('TImagePosObj.ReSetValues with bad base values');
  try
    FImage := FImagelManager.ImageControl(AThisIndx);
    FImage.Align := alNone;
    FImage.OnDblClick := OnImageClick;
    FImage.Visible := false;
    FImage.Align := alNone;
    FImage.Parent := FParentPanel;

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
      // FScale := AScale;
      FImage.Width := Round(FSz.X);
      FImage.Height := Round(FSz.Y);
      FImage.Left := Round(FPos.X);
      FImage.Top := Round(FPos.Y);
      FImage.Proportional := true;
      FImage.Stretch := true;
      // FImageCtrl.Scale.Point := FScale;
      FImage.Visible := true;
    End;
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'ReSetValues');
  end;
end;

{ TVideoChnlLink }

procedure TVideoChnlLinkVCL.BlankInactiveChannel(AInLastNoMins: Integer);
begin
  try
    if VideoIsActive(AInLastNoMins) then
      Exit;

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

procedure TVideoChnlLinkVCL.ChannelClosing(ASender: TObject);
begin
  FVideoComs := nil;

  if GblLogAllChlOpenClose then
    if ASender is TISIndyTCPBase then
      ISIndyUtilsException(Self, 'ChannelClosing >> ' +
        TISIndyTCPBase(ASender).TextID)
    else
      ISIndyUtilsException(Self, 'ChannelClosing No Ref');
end;

constructor TVideoChnlLinkVCL.Create(AHost: String; APort: Integer;
  ALinkRef: String; AImage: TImageControl);
begin
  Try
    FSyncBitmap := true;
    // ErrorMessage('Calling '+CommsServerName+':'+IntToStr(CommsPort));
    FLinkRef := ALinkRef;
    FImage := AImage;
    FHost := AHost;
    FPort := APort;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

destructor TVideoChnlLinkVCL.Destroy;
begin
  // GlobalSelectDebugChn:= FVideoComs;
  FreeAndNil(FVideoComs);
  inherited;
end;

procedure TVideoChnlLinkVCL.DisConnectInactiveChannel(AInLastNoMins: Integer);
begin
  try
    if VideoIsActive(AInLastNoMins) then
      Exit;

    if FVideoComs <> nil then
      if FVideoComs.ChannelActiveWithGraphic(AInLastNoMins / 24 / 60) then
        Exit
      else
      Begin
        FVideoComs.OffThreadDestroy(true);
        FVideoComs := nil;
      End;
  Except
    On E: Exception do
    begin
      FVideoComs := nil;
      ISIndyUtilsException(Self, E, 'DisConnectInactiveChannel');
    end;
  end;
end;

function TVideoChnlLinkVCL.RxAnsiString(ACommand: ansistring;
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

procedure TVideoChnlLinkVCL.RxGraphic(AGraphic: TGraphic);
begin
  if FImage = nil then
    Exit
  else if FImage is TImageControl then
  Begin
    if (AGraphic = nil) then
    begin
      if FVideoComs is TVideoComsChannel then
        if not FVideoComs.ChannelActiveWithGraphic(1 / 24 / 60) then
          if FImage.Visible then
            FImage.Visible := false;
    end
    else
    Begin
      if FSyncBitmap and IsNotMainThread then
        raise Exception.Create('RxGraphic not Synced');
      FLastRxGraphicTime := Now;
      FActiveChnl := true;
      FImage.Picture.Graphic := AGraphic;
      // Bitmap is assigned >> Refcount data inc

      if Not FImage.Visible then
        FImage.Visible := true;
    End;
  End;
end;

procedure TVideoChnlLinkVCL.SetImage(const Value: TImageControl);
begin
  FImage := Value;
end;

function TVideoChnlLinkVCL.VideoComs: TVideoComsChannel;
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

function TVideoChnlLinkVCL.VideoIsActive(AInLastNoMins: Integer): Boolean;
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

{ TImageControl }

function TImageControl.GetBitmap: TGraphic;
begin
  Result := Picture.BitMap;
end;

procedure TImageControl.SetBitMap(const Value: TGraphic);
begin
  if Value Is TBitmap then
    Picture.BitMap := TBitmap(Value)
  else if Value = nil then
    Picture.BitMap := TBitmap(Value)
  else
    raise Exception.Create('Must Provide BitMap');
end;

end.
