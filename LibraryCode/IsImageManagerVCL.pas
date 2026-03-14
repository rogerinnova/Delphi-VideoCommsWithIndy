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
  SyncObjs,
{$ELSE}
  System.SyncObjs,
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math,
  VCL.Controls,
  VCL.Graphics,
  VCL.ExtCtrls,
{$ENDIF}
  TimeSpan, IsMediaCommsObjs, IsRemoteConnectionIndyTcpObjs, IsArrayLib;

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
  TVideoChnlLinkVCL = class;
  TImageArray = Array of TObject;
  TImagePosObjArray = Array of TImagePosObjVCL;

  TImageMngrVCL = class(TObject)
  private
    FManagerLock: TCriticalSection;
    FImagePnll: TPanel;
    FDefaultBitMap: TBitmap;
    FImageArray: TImageArray;
    FFixedImages: Integer;
    FCurrentPrime: TImagePosObjVCL;
    FPArray: TImagePosObjArray;
    FListOfCurrentVideoRx: TStringList;
    Function DefaultBitMap: TBitmap;
    Function ListOfCurrentVideoRx: TStringList;
    Procedure DoOnPanelResize(Sender: TObject);
    Procedure ImageClicked(APosObj: TImagePosObjVCL);
    Procedure SetRowsCols(APnlWidth, APnlHeight: single;
      Out AColCnt, ARowCnt: Integer);
  public
    Constructor Create(AImagePnl: TPanel; ANoOfFixedImages: Integer);
    Destructor Destroy; override;
    Procedure SetImagePanels(AImagePnl: TPanel);
    Procedure InsertImagesAt(AImagePnl: TPanel; AAddAt, ANoToAdd: Integer);
    Procedure GrowImageLists(AImagePnl: TPanel; ANoOfMangedImages: Integer);
    Procedure DisConnectInactiveImageChannels(AMinutesInActive: Integer);
    Procedure BlankInactiveImageChannels(AMinutesInActive: Integer);
    Procedure RemoveVideoLink(ALink: TVideoChnlLinkVCL);
    Function ImageControl(AIndx: Integer): TImageControl;
    Function ImageControlArray: TImageArray;
    Function FindNullImage(AListOfCurrentRx: TStrings;
      ANoImagesReservedExternalToList: Integer): TImageControl;
    Function ConnectChannel(ALinkData, ASrvAddress: String; APort: Integer)
      : TVideoChnlLinkVCL;
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
    FSz, FPos: TPointF;
    Procedure ReSetValues(AThisIndx: Integer; ASz, APos: TPointF);
  end;

  TVideoChnlLinkVCL = class(TObject)
  Private
    FVideoManagerOwner: TImageMngrVCL;
    FLinkRef: string;
    FImage: TImageControl;
    FHost: string;
    FPort: Integer;
    FSyncBitmap: Boolean;
    FLinkVideoComs: TVideoComsChannel;
    FLastRxGraphicTime: TTimeSpan;
    FActiveChnl: Boolean;
    Function RxAnsiString(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Procedure RxGraphic(AGraphic: TGraphic);
    Procedure LnkChnlClosing(ASender: TObject);
    procedure SetImage(const Value: TImageControl);
  Public
    Constructor Create(AOwner: TImageMngrVCL; AHost: String; APort: Integer;
      ALinkRef: String; AImage: TImageControl);
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

procedure TImageMngrVCL.BlankInactiveImageChannels(AMinutesInActive: Integer);
Var
  IDX: Integer;
begin
  if FListOfCurrentVideoRx = nil then
    Exit;

  if FListOfCurrentVideoRx.Count < 1 then
    Exit;
  // list may change
  IDX := FListOfCurrentVideoRx.Count - 1;
  while IDX > -1 do
  Begin
    if FManagerLock.TryEnter then
      try
        if IDX < FListOfCurrentVideoRx.Count then
          if FListOfCurrentVideoRx.Objects[IDX] is TVideoChnlLinkVCL then
            TVideoChnlLinkVCL(FListOfCurrentVideoRx.Objects[IDX])
              .BlankInactiveChannel(AMinutesInActive)
          else
          Begin
            if FListOfCurrentVideoRx.Objects[IDX] <> nil then
              ISIndyUtilsException(Self,
                'BlankInactiveImageChannels Objects[IDX] Not Video' +
                FListOfCurrentVideoRx[IDX])
            else
              FListOfCurrentVideoRx.Delete(IDX);
          end;
      finally
        FManagerLock.Leave;
      end
    Else
      ISIndyUtilsException(Self, 'DisConnectInactiveImageChannels no lock' +
        FListOfCurrentVideoRx[IDX]);
    Dec(IDX);
  End;
end;

function TImageMngrVCL.ConnectChannel(ALinkData, ASrvAddress: String;
  APort: Integer): TVideoChnlLinkVCL;
Var
  ChnlIdx: Integer;
  ChnlObj: TVideoChnlLinkVCL;
  NxtImage: TImageControl;
begin
  try
    if ListOfCurrentVideoRx = nil then
      Exit;
    ChnlObj := nil;

    if FListOfCurrentVideoRx.Find(ALinkData, ChnlIdx) then
    Begin
      ChnlObj := FListOfCurrentVideoRx.Objects[ChnlIdx] as TVideoChnlLinkVCL;
      if (ChnlObj.FHost <> ASrvAddress) or (ChnlObj.FPort <> APort) then
        ChnlObj := nil;
    end;
    if ChnlObj = nil then
    begin
      NxtImage := FindNullImage(FListOfCurrentVideoRx, 1);
      FManagerLock.Enter;
      Try
        ChnlObj := TVideoChnlLinkVCL.Create(Self, ASrvAddress, APort, ALinkData,
          NxtImage);
        FListOfCurrentVideoRx.AddObject(ALinkData, ChnlObj);
      finally
        FManagerLock.Release;
      end;
      ISIndyUtilsException(Self, '#Added Rx Video Channel ' + ALinkData +
        '  No ' + IntToStr(FListOfCurrentVideoRx.Count));
    end;

    if (ChnlObj = Nil) or (ChnlObj.VideoComs = Nil) then
      ISIndyUtilsException(Self, 'Failed ConnectChannel =' + ALinkData + ' on '
        + ASrvAddress);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Failed ConnectChannel =' + ALinkData +
        ' on ' + ASrvAddress);
  end;
end;

constructor TImageMngrVCL.Create(AImagePnl: TPanel; ANoOfFixedImages: Integer);
begin
  FFixedImages := ANoOfFixedImages;
  FManagerLock := TCriticalSection.Create;
  FImagePnll := AImagePnl;
  if FImagePnll = nil then
    Exit;
  FCurrentPrime := nil;

  GrowImageLists(FImagePnll, FFixedImages);
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
Var
  SaveArray: array of TVideoChnlLinkVCL;
  Sz, IDX: Integer;
begin
  Try
    ISIndyUtilsException(Self, '#Start Destroy');

    FManagerLock.Acquire;
    try
      ISIndyUtilsException(Self, '#FManagerLock.Acquire');
      if FListOfCurrentVideoRx <> nil then
        Sz := FListOfCurrentVideoRx.Count
      else
        Sz := 0;
      SetLength(SaveArray, Sz);
      for IDX := 0 to Sz - 1 do
        if FListOfCurrentVideoRx.Objects[IDX] is TVideoChnlLinkVCL then
          SaveArray[IDX] := TVideoChnlLinkVCL
            (FListOfCurrentVideoRx.Objects[IDX])
        else
          SaveArray[IDX] := nil;
    finally
      FManagerLock.Release;
    end;
    ISIndyUtilsException(Self, 'FManagerLock.Release');

    for IDX := 0 to Length(SaveArray) - 1 do
      if SaveArray[IDX] <> nil then
        FreeAndNil(SaveArray[IDX]);

    IDX := 30;
    if FListOfCurrentVideoRx <> nil then
      while (IDX > 0) and (FListOfCurrentVideoRx <> nil) and
        (FListOfCurrentVideoRx.Count > 0) do
      begin
        Dec(IDX);
        Sleep(1000);
      end;

    if IDX < 1 then
      ISIndyUtilsException(Self, 'Idx Count out in Destroy');

    ISIndyUtilsException(Self, 'Idx =' + IntToStr(IDX));
    FreeAndNil(FListOfCurrentVideoRx);
    FreeObjectArray(TArrayofObjects(FPArray));
    // Frees Objects
    FreeObjectArray(TArrayofObjects(FImageArray));
    // Frees Objects
    ISIndyUtilsException(Self, 'FreeObjectArray');
    FDefaultBitMap.Free;
    FreeAndNil(GblDefaultBitMap);
    ISIndyUtilsException(Self, 'GblDefaultBitMap');
    FreeAndNil(FManagerLock);
    ISIndyUtilsException(Self, 'FreeAndNil(FManagerLock)');
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TImageCntrlManager.Destroy')
  End;
  inherited;
end;

procedure TImageMngrVCL.DisConnectInactiveImageChannels(AMinutesInActive
  : Integer);
Var
  IDX: Integer;
begin
  if FListOfCurrentVideoRx = nil then
    Exit;
  if FListOfCurrentVideoRx.Count < 1 then
    Exit;
  // DisConnectInactiveChannel may change list
  IDX := FListOfCurrentVideoRx.Count - 1;
  while IDX > -1 do
  Begin
    if FManagerLock.TryEnter then
      try
        if FListOfCurrentVideoRx.Objects[IDX] is TVideoChnlLinkVCL then
          TVideoChnlLinkVCL(FListOfCurrentVideoRx.Objects[IDX])
            .DisConnectInactiveChannel(AMinutesInActive)
        else
        Begin
          if FListOfCurrentVideoRx.Objects[IDX] <> nil then
            ISIndyUtilsException(Self,
              'DisConnectInactiveImageChannels Objects[IDX] Not Video' +
              FListOfCurrentVideoRx[IDX])
          else
            FListOfCurrentVideoRx.Delete(IDX);
        end;
      finally
        FManagerLock.Leave;
      end
    Else
      ISIndyUtilsException(Self, 'DisConnectInactiveImageChannels no lock' +
        FListOfCurrentVideoRx[IDX]);
    Dec(IDX);
  End;
end;

procedure TImageMngrVCL.DoOnPanelResize(Sender: TObject);
begin
  // if Sender=FTabPnl then
  SetImagePanels(FImagePnll);
end;

function TImageMngrVCL.FindNullImage(AListOfCurrentRx: TStrings;
  ANoImagesReservedExternalToList: Integer): TImageControl;
Var
  IDX, NextPosibleImage, LenImageArray: Integer;
  VideoObj: TVideoChnlLinkVCL;
  LImage, TstImage: TObject;
  HighCurrentRxChnls: Integer;
begin
  LenImageArray := Length(FImageArray);
  HighCurrentRxChnls := AListOfCurrentRx.Count - 1;

  NextPosibleImage := ANoImagesReservedExternalToList;
  Result := nil;
  IDX := HighCurrentRxChnls;

  while (Result = nil) and (NextPosibleImage < LenImageArray) do
  Begin
    IDX := 0;
    TstImage := ImageControl(NextPosibleImage);
    HighCurrentRxChnls := AListOfCurrentRx.Count - 1;
    if TstImage <> nil then
      While IDX <= HighCurrentRxChnls do
        try
          try
            if AListOfCurrentRx.Objects[IDX] is TVideoChnlLinkVCL then
            Begin
              VideoObj := AListOfCurrentRx.Objects[IDX] as TVideoChnlLinkVCL;
              LImage := VideoObj.FImage;
              if (TstImage = LImage) then
              begin
                IDX := HighCurrentRxChnls + 4;
                // Image at NextPosibleImage is in use
              end;
            End
            Else
              ISIndyUtilsException(Self, 'FindNullImage Non Link on List');
          finally
            inc(IDX);
          end;
        Except
          on E: Exception do
            ISIndyUtilsException(Self, E, 'FindNullImage Found Image :Indx=' +
              IntToStr(IDX) + '  Rx Chls=' + IntToStr(HighCurrentRxChnls));
        end;

    if IDX < HighCurrentRxChnls + 2 then // was not found
      Result := FImageArray[NextPosibleImage] as TImageControl;

    if Result = nil then
      inc(NextPosibleImage);
  End;

  if Result = nil then
  begin
    GrowImageLists(FImagePnll, NextPosibleImage + 1);
    Result := ImageControl(NextPosibleImage);
  end;
end;

procedure TImageMngrVCL.GrowImageLists(AImagePnl: TPanel;
  ANoOfMangedImages: Integer);
Var
  NewImage: TImageControl;
  CurrentLength: Integer;
  IDX: Integer;
begin
  FManagerLock.Acquire;
  try
    if AImagePnl <> FImagePnll then
    Begin
      ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
      Exit;
    End;
    try
      if FImagePnll = nil then
        Exit;

      FImagePnll.OnResize := DoOnPanelResize;
      CurrentLength := Length(FImageArray);
      if CurrentLength < ANoOfMangedImages then
      Begin
        SetLength(FImageArray, ANoOfMangedImages);
        SetLength(FPArray, ANoOfMangedImages);
        while CurrentLength < ANoOfMangedImages do
        Begin
          FPArray[CurrentLength] := TImagePosObjVCL.Create(Self);
          NewImage := TImageControl.Create(nil { self //I will Free Images } );
          NewImage.Enabled := true;
          // NewImageCtrl.EnableOpenDialog := false;
          // NewImageCtrl.EnableDragHighlight := false;
          NewImage.OnClick := FPArray[CurrentLength].OnImageClick;
          // NewImageCtrl.Bitmap := DefaultBitMap;
          NewImage.Name := AImagePnl.Name + 'Im' + IntToStr(CurrentLength);
          NewImage.Parent := FImagePnll; // parent
          NewImage.Stretch := true;
          NewImage.Proportional := true;
          FImageArray[CurrentLength] := NewImage;
          inc(CurrentLength);
        End;
        for IDX := 0 to CurrentLength - 1 do
          FPArray[IDX].ReSetValues(IDX, TPointFZero, TPointFZero);
      End;
      SetImagePanels(FImagePnll);
    except
      On E: Exception do
        ISIndyUtilsException(Self, E, 'GrowImageLists');
    end;
  finally
    FManagerLock.Release;
  end;
end;

procedure TImageMngrVCL.ImageClicked(APosObj: TImagePosObjVCL);
begin
  if APosObj = FCurrentPrime then
    FCurrentPrime := nil
  else
    FCurrentPrime := APosObj;
  SetImagePanels(FImagePnll);
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

procedure TImageMngrVCL.InsertImagesAt(AImagePnl: TPanel;
  AAddAt, ANoToAdd: Integer);
Var
  ThisArray: TArrayofObjects;
  I, CurrentLength: Integer;
  NewImage: TImage;
begin
  FManagerLock.Acquire;
  try
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
      NewImage.Name := AImagePnl.Name + 'Im' + IntToStr(CurrentLength - I);
      NewImage.Parent := FImagePnll; // parent
      NewImage.Stretch := true;
      NewImage.Proportional := true;
      FImageArray[I] := NewImage;
    End;

    for I := 0 to (CurrentLength - 1) do
      FPArray[I].ReSetValues(I, TPointFZero, TPointFZero);
    SetImagePanels(FImagePnll);
  finally
    FManagerLock.Release;
  end;
End;

function TImageMngrVCL.ListOfCurrentVideoRx: TStringList;
begin
  // Private Thread Protected
  if FListOfCurrentVideoRx = nil then
    if FManagerLock.TryEnter then
      Try
        FListOfCurrentVideoRx := TStringList.Create;
        FListOfCurrentVideoRx.Sorted := true;
        FListOfCurrentVideoRx.CaseSensitive := False;
        FListOfCurrentVideoRx.OwnsObjects := true; // TVideoChnlLinkVCL
      Finally
        FManagerLock.Leave;
      End
    Else
      ISIndyUtilsException(Self, 'FListOfCurrentVideoRx Lock rejected');
  Result := FListOfCurrentVideoRx;
end;

procedure TImageMngrVCL.RemoveVideoLink(ALink: TVideoChnlLinkVCL);
Var
  ListIdx: Integer;
begin
  if ALink = nil then
    Exit;
  if FListOfCurrentVideoRx = nil then
    Exit;

  if FManagerLock.TryEnter then
    try
      ListIdx := FListOfCurrentVideoRx.IndexOfObject(ALink);
      if ListIdx < 0 then
        ISIndyUtilsException(Self, 'RemoveVideoLink Object ' + ALink.FLinkRef +
          ' not in List ')
      else
      begin
        ISIndyUtilsException(Self, 'RemoveVideoLink Object ' + ALink.FLinkRef);
        FListOfCurrentVideoRx.Objects[ListIdx] := nil;
        FListOfCurrentVideoRx.Delete(ListIdx);
      end;
    finally
      FManagerLock.Leave;
    end
  Else
    ISIndyUtilsException(Self, 'RemoveVideoLink No Lock ' + ALink.FLinkRef);
end;

procedure TImageMngrVCL.SetImagePanels(AImagePnl: TPanel);
Var
  ImgIdx, ImgCnt, ColCnt, RowCnt, ColIdx, RowIdx: Integer;
  PnlWidth, PnlHeight, ImgWidth, ImgHeight: single;
  ThisPos, ThisSz: TPointF;
{$IFDEF FPC}
Var
  PtfZero: TPointF;
Begin
  PtfZero.X := 0.0;
  PtfZero.Y := 0.0;
{$ELSE}
begin
{$ENDIF}
  FManagerLock.Acquire;
  try

    if AImagePnl = nil then
      Exit;
    if AImagePnl <> FImagePnll then
    Begin
      ISIndyUtilsException(Self, 'ATab<>FTab GrowImageLists');
      Exit;
    End;
    try
      ImgCnt := Length(FImageArray);
      if Length(FPArray) <> ImgCnt then
        ISIndyUtilsException(Self, 'Bad # of images');
      For ImgIdx := 0 to ImgCnt - 1 do
{$IFDEF FPC}
        FPArray[ImgIdx].ReSetValues(ImgIdx, PtfZero, PtfZero);
{$ELSE}
        FPArray[ImgIdx].ReSetValues(ImgIdx, TPointF.Zero, TPointF.Zero);
{$ENDIF}
      if ImgCnt < 1 then
        Exit;

      PnlWidth := FImagePnll.Width;
      PnlHeight := FImagePnll.Height;
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
  finally
    FManagerLock.Release;
  end;
end;

procedure TImageMngrVCL.SetRowsCols(APnlWidth, APnlHeight: single;
  out AColCnt, ARowCnt: Integer);

{ sub } Function NextAspect(AIdx: Integer; Out AValid: Boolean): single;
  Var
    ThisImage: TImageControl;
  Begin
    Result := 0;
    AValid := False;
    if (FImageArray[AIdx] is TImageControl) then
    Begin
      ThisImage := TImageControl(FImageArray[AIdx]);
      if ThisImage.BitMap <> nil then
        if ThisImage.BitMap.Width > 0 then
        Begin
          Result := ThisImage.BitMap.Width / ThisImage.BitMap.Height;
          AValid := true;
        End;
    End;
  End;

Var
  PnlAspectRatio, AverageAspectRatio, SqRtAverageAspectRatio, StdzPnlWidth,
    StdzPnlHeight, StdzImageWidth, StdzImageHeight: single;
  IDX, Images, ValidImages: Integer;
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
    inc(ARowCnt) // All OK
  else
    inc(AColCnt); // Problem

  if SameValue(StdzImageWidth / StdzImageHeight, AverageAspectRatio, 0.00001)
  then
    inc(ARowCnt) // All OK
  else
    inc(AColCnt); // Problem

  PnlAspectRatio := APnlWidth / APnlHeight;
  StdzPnlWidth := SqRt(Images * PnlAspectRatio);
  StdzPnlHeight := StdzPnlWidth / PnlAspectRatio;
  StdzPnlHeight := SqRt(Images / PnlAspectRatio);

  if SameValue(StdzImageWidth * StdzImageHeight, 1, 0.00001) then
    inc(ARowCnt) // All OK
  else
    inc(AColCnt); // Problem

  if SameValue(StdzPnlWidth * StdzPnlHeight, Images, 0.00001) then
    inc(ARowCnt) // All OK
  else
    inc(AColCnt); // Problem

  // AColCnt := Trunc(StdzPnlWidth / StdzImageWidth);
  // ARowCnt := Trunc(StdzPnlHeight / StdzImageHeight);
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
      if (Images - ValidImages) <= AColCnt then
        inc(AColCnt)
      else
        inc(ARowCnt);
    end
    else
    Begin
      if (Images - ValidImages) <= ARowCnt then
        inc(AColCnt)
      else
        inc(ARowCnt);
    End;
    ValidImages := AColCnt * ARowCnt;
  end;

  if ValidImages >= (Images + ARowCnt) then
    Dec(AColCnt)
  else if ValidImages >= (Images + AColCnt) then
    Dec(ARowCnt);

  ValidImages := AColCnt * ARowCnt;
  if ValidImages < Images then
    ISIndyUtilsException(Self, 'ValidImages < Images');
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
  FParentPanel := FImagelManager.FImagePnll;
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

procedure TImagePosObjVCL.ReSetValues(AThisIndx: Integer; ASz, APos: TPointF);

begin
  if (Length(FImagelManager.FImageArray) <= AThisIndx) or
    (Length(FImagelManager.FPArray) <= AThisIndx) or
    (Self <> (FImagelManager.FPArray)[AThisIndx]) then
    raise Exception.Create('TImagePosObj.ReSetValues with bad base values');
  try
    FImage := FImagelManager.ImageControl(AThisIndx);
    FImage.Align := alNone;
    FImage.OnDblClick := OnImageClick;
    FImage.Visible := False;
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

    if FLinkVideoComs is TVideoComsChannel then
    Begin
      if Assigned(FLinkVideoComs.OnInComingGraphic) then
        FLinkVideoComs.OnInComingGraphic(nil);
    End;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'BlankInactiveChannel');
    end;
  end;
end;

procedure TVideoChnlLinkVCL.LnkChnlClosing(ASender: TObject);
begin
  if ASender = FLinkVideoComs then
    FLinkVideoComs := nil
  Else
    ISIndyUtilsException(Self, '#LnkChnlClosing Not FVideoComs');

  if GblLogAllChlOpenClose then
    if ASender is TISIndyTCPBase then
      ISIndyUtilsException(Self, '#LnkChnlClosing >> ' +
        TISIndyTCPBase(ASender).TextID)
    else
      ISIndyUtilsException(Self, '#LnkChnlClosing No Ref');

  if FLinkVideoComs = nil then
    Free;
end;

constructor TVideoChnlLinkVCL.Create(AOwner: TImageMngrVCL; AHost: String;
  APort: Integer; ALinkRef: String; AImage: TImageControl);
begin
  Try
    FVideoManagerOwner := AOwner;
    if (FVideoManagerOwner = nil) then
      raise Exception.Create('TVideoChnlLinkVCL must have TImageMngrVCL');
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
  Try
    if FLinkVideoComs <> nil then
    Begin
      FLinkVideoComs.OnDestroy := nil;
      // Shold happen in FreeAndNilDuplexChannel
      FreeAndNilDuplexChannel(Pointer(FLinkVideoComs));
    End;
    // GlobalSelectDebugChn:= FVideoComs;
    if FVideoManagerOwner <> nil then
      FVideoManagerOwner.RemoveVideoLink(Self)
    else
      ISIndyUtilsException(Self, 'Destroy No Owner');
    if FImage <> nil then
      FImage.Picture.Graphic := nil;
    inherited;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Destroy');
  End;
end;

procedure TVideoChnlLinkVCL.DisConnectInactiveChannel(AInLastNoMins: Integer);
begin
  try
    if VideoIsActive(AInLastNoMins) then
      Exit;

    if FLinkVideoComs = nil Then
    Begin
      if FImage <> nil then
        Try
          RxGraphic(nil);
        Except
          On E: Exception do
            ISIndyUtilsException(Self, E,
              'DisConnectInactiveChannel RxGraphic 1');
        End;
      FImage := nil;
      Free;
    End
    else if FLinkVideoComs.ChannelActiveWithGraphic(AInLastNoMins) then
      Exit
    else
    Begin
      if FImage <> nil then
        Try
          RxGraphic(nil);
        Except
          On E: Exception do
            ISIndyUtilsException(Self, E,
              'DisConnectInactiveChannel RxGraphic 1');
        End;
      FImage := nil;
      FLinkVideoComs.OffThreadDestroy(False);
      FLinkVideoComs := nil;
      Free;
    End;
  Except
    On E: Exception do
    begin
      FLinkVideoComs := nil;
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
    if FLinkVideoComs = nil then
      FLinkVideoComs := ATcpSession as TVideoComsChannel;
    if ATcpSession = FLinkVideoComs then
      FLinkVideoComs.OpenChannel
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
    if FSyncBitmap and IsNotMainThread then
      raise Exception.Create('RxGraphic not Synced');
    if (AGraphic = nil) then
    begin
      if FLinkVideoComs is TVideoComsChannel then
        if not FLinkVideoComs.ChannelActiveWithGraphic(60) then
          if FImage.Visible then
            FImage.Visible := False;
    end
    else
    Begin
      if FLinkVideoComs <> nil then
        FLastRxGraphicTime := FLinkVideoComs.StopWatch.Elapsed;
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
  if FLinkVideoComs = nil then
    Try
      FLinkVideoComs := TVideoComsChannel.StartAccess(FHost, FPort);
      FLinkVideoComs.OnInComingGraphic := RxGraphic;
      FLinkVideoComs.OnAnsiStringAction := RxAnsiString;
      FLinkVideoComs.OnSimpleDuplexRemoteAction := RxAnsiString;
      FLinkVideoComs.SynchronizeResults := true;
      FLinkVideoComs.OnDestroy := LnkChnlClosing;
      If not FLinkVideoComs.ServerSetLinkConnection(FLinkRef) then
        FreeAndNil(FLinkVideoComs)
      else
        FLinkVideoComs.OpenChannel;
    Except
      On E: Exception do
      Begin
        ISIndyUtilsException(Self, E, 'VideoComs');
        FreeAndNil(FLinkVideoComs);
      End;
    End;
  Result := FLinkVideoComs;
end;

function TVideoChnlLinkVCL.VideoIsActive(AInLastNoMins: Integer): Boolean;
Var
  Recent: Boolean;
begin
  try
    Result := False;
    if FLinkVideoComs = nil then
      Exit;

    if AInLastNoMins < 1 then
      AInLastNoMins := 3;

    if FActiveChnl then
      Result := FLinkVideoComs.StopWatch.Elapsed < FLastRxGraphicTime.Add
        (TTimeSpan.FromMinutes(AInLastNoMins));
  Except
    On E: Exception do
    begin
      FLinkVideoComs := nil;
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
