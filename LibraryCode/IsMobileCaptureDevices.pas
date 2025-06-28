unit IsMobileCaptureDevices;
{$I InnovaMultiPlatLibDefs.inc}
// https://sourceforge.net/p/radstudiodemos/code/HEAD/tree/branches/RADStudio_Tokyo/Object%20Pascal/Mobile%20Snippets/

interface

uses FMX.Media, Sysutils, Classes, System.IOUtils, System.Math,
  System.Generics.Collections, System.Types, System.UITypes,
  System.SyncObjs,
  // {$IFDEF UseVCLBITMAP}
  // VCL.Graphics,
  // {$ELSE}
  FMX.Graphics,
  IsFmxGraphics,
  // {$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
{$IFDEF Android}
{$IFDEF ISD103R_DELPHI}
  IsPermissions,
{$ENDIF}
{$ENDIF}
  IsMediaCommsObjs;

Const
{$IF DEFINED(ANDROID) OR DEFINED(IOS)}
  AUDIO_FILENAME = 'test.caf';
{$ELSE}
  AUDIO_FILENAME = 'test.wav';
{$ENDIF}

Type
  TErrorProc = Procedure(AMsg: String) of Object;

  TIsCaptureDevicePxy = class(TCaptureDevice)
  Public
    Property MediaType: TMediaType Read GetMediaType;
  end;

  TIsCaptureDeviceVideoTst = Class;

  TIsCaptureTstThread = class(TThread)
  private
    FDevice: TCaptureDevice;
  protected
    procedure Execute; override;
  public
    constructor Create(ADevice: TCaptureDevice); overload;
    destructor Destroy; override;
  end;

  TIsCaptureDeviceVideoTst = Class(TVideoCaptureDevice)
  private
    FBitmap: TBitmap;
    fRunThread: TIsCaptureTstThread;
  protected
    function GetDeviceState: TCaptureDeviceState; override;
    procedure DoThreadRun;
    procedure DoStopCapture; override;
    procedure DoStartCapture; override;
    function GetCaptureSetting: TVideoCaptureSetting; override;
    function DoSetCaptureSetting(const ASetting: TVideoCaptureSetting)
      : Boolean; override;
    function DoGetAvailableCaptureSettings
      : TArray<TVideoCaptureSetting>; override;
    function GetMediaType: TMediaType; override;
    procedure DoSampleBufferToBitmap(const ABitmap: TBitmap;
      const ASetSize: Boolean); override;
  public
    constructor Create(const AManager: TCaptureDeviceManager;
      const ADefault: Boolean); override;
    Destructor Destroy; override;
  end;

  TIsCaptureDeviceAudioTst = Class(TAudioCaptureDevice)
  private
    fRunThread: TIsCaptureTstThread;
  protected
    function GetDeviceState: TCaptureDeviceState; override;
    procedure DoThreadRun;
    procedure DoStopCapture; override;
    procedure DoStartCapture; override;
    function GetMediaType: TMediaType; override;
  public
    constructor Create(const AManager: TCaptureDeviceManager;
      const ADefault: Boolean); override;
    Destructor Destroy; override;
  end;

  TIsCaptureProc = Procedure(ADevice: TCaptureDevice; ATime: TDateTime)
    of object;

  TIsMediaCapture = class;

  TThreadTxComImage = class(TThread)
  private
    FThreadLock: TCriticalSection;
    FOwner: TIsMediaCapture;
    FLCopyVideoComsChls: TList<TVideoComsChannel>;
    FDataToSend: AnsiString;
    procedure ErrorMessage(AMsg: String);
  Protected
    procedure Execute; override;
  Public
    Constructor Create(AOwner: TIsMediaCapture);
    Destructor Destroy; override;
    function AddBitMapString(ABitmapString: AnsiString): Boolean;
  end;

TIsMediaCapture = class(TObject)
  private
    FInDestroy: Boolean;
    FLockObj: TCriticalSection;
    // lock media device only one thread in SampleVideoBufferReady at a time
    FLastBitmap: TBitmap;
    // FCaptureManager: TCaptureDeviceManager;
    TempErrorCount: integer;
    FFrontCameraCapture, FBackCameraCapture, FDefaultCamera,
      FDefaultAudioCapture: integer;
    FCurSynceBitmapBusy: Boolean;
    FCurSynceBitmap: TBitmap;
    FSamplesPerSecond: Single;
    FSyncTime, FLockObjectDwell, FLastVideoComms, FVideoTxDwell: TDateTime;
    FSyncDev: TObject;
    FSyncIndex: integer;
    FComsBitMap: TBitmap;
    FImagesSent: integer;
    FVideoDevices: Array of TVideoCaptureDevice;
    // Owned by  TCaptureDeviceManager
    FAudioDevices: Array of TAudioCaptureDevice;
    FRetVideoFuncts: Array of TIsCaptureProc;
    FRetAudioFuncts: Array of TIsCaptureProc;
    FBitMaps: Array of TBitmap;
    // Direct Camera to bitmap (owned by Image Component)
    FSentMaps: Array of TBitmap; // past comms bitmaps Owned by this object
    FNxtPos, FLostCount: integer;
    fOnError: TErrorProc;
    FComsBitmapWidth, FComsBitmapHeight: integer;
    FVideoComsChannels: TList<TVideoComsChannel>; // Drop All Channels
    FSyncReturns, FSyncBitmap: Boolean;
    FSendImageThread: TThreadTxComImage;
    // returns or bitmap update must be in mainthread
    procedure AddSentBitMapCopy(ABitmap: TBitmap);
    Function ComsBitMap: TBitmap;
    Function IndexOfDevice(AObj: TObject): integer;
    procedure AlignAspectRatioOfComsBitmpTo(AData: TBitmap);
    procedure SampleVideoBufferReady(Sender: TObject; const ATime: TMediaTime);
    // procedure SampleAudioBufferReady(Sender: TObject; const ATime: TMediaTime);
    // Not Reqired for Audio??
    // maybe change files
    procedure ErrorMessage(AMsg: String);
    Procedure GetDevices(AForceTestDummies: Boolean);
    Procedure CaptureSync;
    Procedure BitMapSync;
    Procedure DropAllChannels;
    function GetVideoDevice(var AChoose: integer): TVideoCaptureDevice;
    procedure SetComsBitmapHeight(const Value: integer);
    procedure SetComsBitmapWidth(const Value: integer);
  protected
    // function GetMediaType: TMediaType; virtual;
    // function GetDeviceProperty(const Prop: TCaptureDevice.TProperty): string; virtual;
    // function GetDeviceState: TCaptureDeviceState; virtual;
    // procedure DoStartCapture; virtual;
    // procedure DoStopCapture; virtual;
    procedure SendToVideoCommsChannels(AData: TBitmap);Virtual;
    //For Video Demo Code
  public
    Constructor Create(AComsBmpW, AComsBmpH: integer;
      ASyncReturns, ASyncBitMaps, AForceTestDummies: Boolean);
    Destructor Destroy; override;
    Function VideoCommsReport: String;
    Function SzPastComsBitMapBuffer: integer;
    Function GetOldCommsBitMap(AIndex: integer): TBitmap;
    Procedure AddVideoCommsChannel(AObj: TVideoComsChannel);
    Procedure DropVideoCommsChannel(AObj: TVideoComsChannel);
    Procedure SetBitmap(ABitmap: TBitmap; AChoose: integer);
    Procedure SetVideoReturn(AReturn: TIsCaptureProc; AChoose: integer);
    Procedure SetAudioReturn(AReturn: TIsCaptureProc; AChoose: integer);
    procedure TestVideoCommsChannels(AData: TBitmap);
    Procedure ActivateDeactivateVideo(AChoose: integer = -1;
      ASetOff: Boolean = False);
    Procedure ActivateDeactivateAudio(AChoose: integer = -1;
      ASetOff: Boolean = False);
    Procedure SaveANumberOfCommsBitmaps(ANumberToSave: integer);
    Procedure ForceTestVideoDevice;
    Procedure ForceTestAudioDevice;
    Property OnError: TErrorProc read fOnError write fOnError;
    Property FrontCameraSelect: integer Read FFrontCameraCapture;
    Property RearCameraSelect: integer Read FFrontCameraCapture;
    Property DefaultCameraSelect: integer Read FDefaultCamera;
    Property DefaultAudioSelect: integer Read FDefaultAudioCapture;
    Property ComsBitmapWidth: integer read FComsBitmapWidth
      write SetComsBitmapWidth;
    Property ComsBitmapHeight: integer read FComsBitmapHeight
      write SetComsBitmapHeight;
    Property ImagesSentLastRound: integer read FImagesSent;
    Property LastLockObjectDwell: TDateTime read FLockObjectDwell;
    Property LastVideoTxDwell: TDateTime read FVideoTxDwell;
    Property LastVideoComms: TDateTime read FLastVideoComms;
  end;

Function MediaCaptureDevices(AComsBmpW, AComsBmpH: integer;
  ASyncReturns, ASyncBitMaps, AForceTestDummies: Boolean): TIsMediaCapture;

Function CurrentMediaCapture: TIsMediaCapture;

Procedure GblMobileMediaCaptureFinalize;

Const
  cMinTimeBetweenPicTx = 1 / 24 / 60 / 60 / 2; // two per second

Var
  LastMediaError: String = '';
  GblRptSendImages: Boolean = False;

implementation

uses ISIndyUtils, IsArrayLib, ISRemoteConnectionIndyTCPObjs;

Var
  LocalMediaCaptureDevices: TIsMediaCapture = nil;
  GblTstDevices: integer = 0;

Procedure LogMediaError(AError: String);
Var
  Previous: String;
Begin
  Previous := LastMediaError;
  LastMediaError := AError;
  // If Length(LastMediaError)>20 then
  // Begin
  // LastMediaError[18]:=#13;
  // LastMediaError[19]:=#10;
  // End;
  // If Length(LastMediaError)>40 then
  // Begin
  // LastMediaError[38]:=#13;
  // LastMediaError[39]:=#10;
  // End;
  If Length(Previous) > 120 then
    SetLength(Previous, 100);

  LastMediaError := LastMediaError + #13#10 + Previous;

  ISIndyUtilsException('LogMErr', AError);
End;

Function CurrentMediaCapture: TIsMediaCapture;
Begin
  Result := LocalMediaCaptureDevices;
  if Result = nil then
    ISIndyUtilsException('CurrentMediaCapture', 'Not Initialized');
End;

Function MediaCaptureDevices(AComsBmpW, AComsBmpH: integer;
  ASyncReturns, ASyncBitMaps, AForceTestDummies: Boolean): TIsMediaCapture;
Begin
  Result := nil;
  try
    if LocalMediaCaptureDevices = nil then
      LocalMediaCaptureDevices := TIsMediaCapture.Create(AComsBmpW, AComsBmpH,
        ASyncReturns, ASyncBitMaps, AForceTestDummies);
    Result := LocalMediaCaptureDevices;
  Except
    On E: Exception do
      ISIndyUtilsException('IsMobileCaptureDevices', E, 'MediaCaptureDevices');
  End;
End;

{ GetAudioFileName resolves the audio file path for either platform. }
function GetAudioFileName(const AFileName: string): string;
begin
{$IFDEF ANDROID}
  Result := TPath.GetTempPath + '/' + AFileName;
{$ELSE}
{$IFDEF IOS}
  Result := TPath.GetHomePath + '/Documents/' + AFileName;
{$ELSE}
  Result := TPath.Combine(TPath.GetTempPath, AFileName);
{$ENDIF}
{$ENDIF}
end;

{ TThreadTxComImage }

function TThreadTxComImage.AddBitMapString(ABitmapString: AnsiString): Boolean;
begin
  Result := False;
  if FThreadLock.TryEnter then
    Try
{$IFDEF Nextgen}
      // if FDataToSend <> nil then
      if FDataToSend.Length > 0 then
        Exit;
{$ELSE}
      if Length(FDataToSend) > 0 then
        Exit;
{$ENDIF}
      if Terminated then
        Exit;

      FDataToSend := ABitmapString;
      Result := true;
    Finally
      FThreadLock.Release;
    End;
end;

constructor TThreadTxComImage.Create(AOwner: TIsMediaCapture);
begin
  Inherited Create(true);
  FThreadLock := TCriticalSection.Create;
  FOwner := AOwner;
  FLCopyVideoComsChls := FOwner.FVideoComsChannels;
  ISIndyUtilsException(Self, '#TxComThreadOpen ');
  FreeOnTerminate := true;
end;

destructor TThreadTxComImage.Destroy;
begin
  Try
    Dec(GlobalThreadCount);
    FLCopyVideoComsChls := nil;
    if FOwner <> nil then
      FOwner.FSendImageThread := nil;
    inherited;
    FThreadLock.Free;
    ISIndyUtilsException(Self, 'TxComThreadClose ');
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E);
  End;
end;

procedure TThreadTxComImage.ErrorMessage(AMsg: String);
begin
  try
    if FOwner <> nil then
      FOwner.ErrorMessage(AMsg)
    else
      ISIndyUtilsException(Self, AMsg);
  Except
  end;
end;

procedure TThreadTxComImage.Execute;
Var
  I, TxLen, ImagesSent, ProgressMsgCount: integer;
  StartTime: TDateTime;
begin
  Try
    while not Terminated do
      try
        ImagesSent := 0;
        FThreadLock.Acquire;
        try
{$IFDEF NextGen}
          TxLen := FDataToSend.Length;
{$ELSE}
          TxLen := Length(FDataToSend);
{$ENDIF}
        finally
          FThreadLock.Release;
        end;
        if TxLen < 1 then
        Begin
          Sleep(300);
        End
        else if TxLen > CMaxDuplexPacket then
        Begin
          ErrorMessage('LargeGraphicFile::' + IntToStr(TxLen));
          FDataToSend := '';
          Sleep(100);
        End
        else
        Begin
          StartTime := now;
          for I := 0 to FLCopyVideoComsChls.count - 1 do
            Try
              if FLCopyVideoComsChls[I] <> nil then
                if FLCopyVideoComsChls[I].OpenGraphicsChannel then
                Begin
{$IFDEF Debug}
                  if ProgressMsgCount = 1 then
                    FLCopyVideoComsChls[I].LogAMessage
                      ('Img Sent ' + FormatDateTime('nn:ss.zz', now));
{$ENDIF}
{$IFDEF Android}
                  FLCopyVideoComsChls[I].FullDuplexDispatch(FDataToSend, '');
                  // no wait less of a problem as this is an excusive TX Thread
{$ELSE}
                  FLCopyVideoComsChls[I].FullDuplexDispatch(FDataToSend, '');
                  // why waste another thread
                  // FLCopyVideoComsChls[I].FullDuplexDispatchNoWait
                  // (FDataToSend, 3);
{$ENDIF}
                  inc(ImagesSent);
                  FLCopyVideoComsChls[I].CheckChannelGraphicStillOpen;
                End;
            Except
              on E: Exception do
                ISIndyUtilsException(Self, E, '# Execute I=' + IntToStr(I));
            End;

          if ProgressMsgCount > 0 then
            Dec(ProgressMsgCount)
          Else
          Begin
            ProgressMsgCount := 50;
            if GblRptSendImages then
              ISIndyUtilsException(Self,
                '#SendToVideoCommsChannels(50)::Images sent=' +
                IntToStr(ImagesSent));
          End;

          FThreadLock.Acquire;
          try
            FDataToSend := '';
          finally
            FThreadLock.Release;
          end;
          if Not Terminated then
          Begin
            Sleep(100);
          End;
        End;
      Finally
        if FOwner <> nil then
          if ImagesSent > 0 then
          begin
            FOwner.FVideoTxDwell := now - StartTime;
            FOwner.FImagesSent := ImagesSent;
          end;
      End;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, '# Execute');
  End;
End;

{ TIsMediaCapture }

procedure TIsMediaCapture.ActivateDeactivateAudio(AChoose: integer;
  ASetOff: Boolean);
begin
  if AChoose < 0 then
    AChoose := FDefaultAudioCapture;
  if (AChoose < 0) or (AChoose > High(FAudioDevices)) then
    ErrorMessage('Audio Index ' + IntToStr(AChoose) + ' out of range 0 to ' +
      IntToStr(High(FAudioDevices)))
  else If FAudioDevices[AChoose] = nil then
    ErrorMessage('Audio Index ' + IntToStr(AChoose) + ' nil')
  else
  Begin
    try
      if ASetOff then
      Begin
        FAudioDevices[AChoose].StopCapture;
        if Assigned(FRetAudioFuncts[AChoose]) then
          FRetAudioFuncts[AChoose](FAudioDevices[AChoose], now);
      End
      else
      begin
        FAudioDevices[AChoose].FileName := GetAudioFileName(AUDIO_FILENAME);
        FAudioDevices[AChoose].StartCapture;
        // FAudioDevices[AChoose].OnSampleBufferReady := SampleAudioBufferReady;
      end;
    except
      On E: Exception do
        ErrorMessage('StartCapture: Operation not supported by this device ::' +
          E.Message);
    end;
  End;

end;

Function TIsMediaCapture.GetVideoDevice(var AChoose: integer)
  : TVideoCaptureDevice;
begin
  Result := nil;
  if FInDestroy then
    Exit;

  if AChoose < 0 then
    AChoose := FDefaultCamera;
  if AChoose > High(FVideoDevices) then
    AChoose := FDefaultCamera;
  if AChoose < 0 then
    Result := nil
  else
    Result := FVideoDevices[AChoose];
end;

procedure TIsMediaCapture.ActivateDeactivateVideo(AChoose: integer;
  ASetOff: Boolean);
Var
  Dev: TVideoCaptureDevice;
begin
  Dev := GetVideoDevice(AChoose);
  if Dev = nil then
    Exit;
  if ASetOff then
  Begin
    Dev.StopCapture;
    Dev.OnSampleBufferReady := nil;
  End
  else
  Begin
    Dev.OnSampleBufferReady := SampleVideoBufferReady;
    Dev.StartCapture;
  End;
end;

procedure TIsMediaCapture.AddSentBitMapCopy(ABitmap: TBitmap);
begin
  if FInDestroy then
    Exit;

  if FNxtPos < Length(FSentMaps) then
    try
      if FLockObj.TryEnter then
        try
          // LogMediaError('TMC.AddSentBitMapCopy::' +
          // IntToStr(Round(ABitmap.Width)));
          FSentMaps[FNxtPos].Assign(ABitmap);
          inc(FNxtPos);
          if FNxtPos > High(FSentMaps) then
            FNxtPos := 0;
        finally
          FLockObj.Leave;
        end
      else
        LogMediaError('Cannot enter Bitmap copy');
    except
      On E: Exception do
        ISIndyUtilsException(Self, E.Message);
    end;
end;

procedure TIsMediaCapture.AddVideoCommsChannel(AObj: TVideoComsChannel);
Var
  I: integer; // Takes ownership of AObject
begin
  Try
    if FVideoComsChannels = nil then
      FVideoComsChannels := TList<TVideoComsChannel>.Create;
    if AObj=nil then
        Exit;
    AObj.SetManager(Self);
    if FVideoComsChannels.count < 1 then
      I := -1
    else
      I := FVideoComsChannels.IndexOf(AObj);
    if I < 0 then
      FVideoComsChannels.Add(AObj);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsMediaCapture.AlignAspectRatioOfComsBitmpTo(AData: TBitmap);
Var
  AspectRatio, SzRef, SzRefRslt: Double;
begin
  if SameValue(AData.Height, FComsBitmapHeight, 0.001) and
    SameValue(AData.Width, FComsBitmapWidth, 0.001) then
    Exit;

  if SameValue(AData.Height / AData.Width, FComsBitmapHeight / FComsBitmapWidth,
    0.0001) then
    Exit;

  FreeAndNil(FComsBitMap);
  AspectRatio := AData.Height / AData.Width;
  SzRef := AData.Height * AData.Width; // Area pixels
  SzRefRslt := FComsBitmapHeight * FComsBitmapWidth;
  SzRefRslt := SqRt(SzRefRslt / SzRef);
  FComsBitmapHeight := Round(AData.Height * SzRefRslt);
  FComsBitmapWidth := Round(AData.Width * SzRefRslt);
  ComsBitMap;
end;

procedure TIsMediaCapture.BitMapSync;
begin
  try
    if FInDestroy then
      Exit;

    if FSyncIndex < 0 then
      Exit;

    if FSyncDev is TVideoCaptureDevice then
      if FBitMaps[FSyncIndex] <> nil then
      begin
        TVideoCaptureDevice(FSyncDev).SampleBufferToBitmap
          (FBitMaps[FSyncIndex], true);

        FCurSynceBitmap := nil;
        if FVideoComsChannels <> nil then
          FCurSynceBitmap := ComsBitMap;
        if FCurSynceBitmap <> nil then
        Begin
          if FBitMaps[FSyncIndex] <> ComsBitMap then
            if (FBitMaps[FSyncIndex].Height = FComsBitmapHeight) and
              (FBitMaps[FSyncIndex].Width = FComsBitmapWidth) then
              FComsBitMap.CopyFromBitmap(FBitMaps[FSyncIndex])
            Else
            Begin
              AlignAspectRatioOfComsBitmpTo(FBitMaps[FSyncIndex]);
              FreeAndNil(FLastBitmap);
              Try
                FLastBitmap := FBitMaps[FSyncIndex].CreateThumbnail
                  (FComsBitmapWidth, FComsBitmapHeight);
                FComsBitMap.CopyFromBitmap(FLastBitmap);
                FCurSynceBitmap := FComsBitMap;
              Except
                On E: Exception do
                  ISIndyUtilsException(Self, E.Message);
              End;
            End;
        end;
      end;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsMediaCapture.CaptureSync;
begin
  if FInDestroy then
    Exit;

  if FSyncIndex < 0 then
    Exit;

  if FSyncDev is TVideoCaptureDevice then
  Begin
    if Assigned(FRetVideoFuncts[FSyncIndex]) then
      FRetVideoFuncts[FSyncIndex](TCaptureDevice(FSyncDev), FSyncTime);
  End
  Else if FSyncDev is TAudioCaptureDevice then
  Begin
    if Assigned(FRetAudioFuncts[FSyncIndex]) then
      FRetAudioFuncts[FSyncIndex](TCaptureDevice(FSyncDev), FSyncTime);
  End;
end;

function TIsMediaCapture.ComsBitMap: TBitmap;
begin
  if FInDestroy then
    Result := nil
  Else
  Begin
    if FComsBitMap <> nil then
      if (FComsBitMap.Height <> FComsBitmapHeight) or
        (FComsBitMap.Width <> FComsBitmapWidth) then
        FreeAndNil(FComsBitMap);
    if FComsBitMap = nil then
      if FVideoComsChannels <> nil then
        FComsBitMap := TBitmap.Create(FComsBitmapWidth, FComsBitmapHeight);
    Result := FComsBitMap;
  End;
end;

constructor TIsMediaCapture.Create(AComsBmpW, AComsBmpH: integer;
  ASyncReturns, ASyncBitMaps, AForceTestDummies: Boolean);
begin
  if LocalMediaCaptureDevices <> nil then
    raise Exception.Create('Only one copy of TIsMediaCapture');

  FInDestroy := False;
  FSyncReturns := ASyncReturns;
  FSyncBitmap := ASyncBitMaps;
  FLockObj := TCriticalSection.Create;
  FComsBitmapWidth := AComsBmpW;
  FComsBitmapHeight := AComsBmpH;
{$IFDEF Android}
{$IFDEF ISD103R_DELPHI}
  PermissionsGranted([Camera, DataAcc], False, true, nil);
{$ENDIF}
{$ENDIF}
  GetDevices(AForceTestDummies);
  LocalMediaCaptureDevices := Self;
end;

destructor TIsMediaCapture.Destroy;
Var
  I: integer;
begin
  try
    if FInDestroy then
      Exit;
    FInDestroy := true;

    I := 700;
    while (FSendImageThread <> nil) do
    begin
      FSendImageThread.Terminate;
      Sleep(100);
      Dec(I);
      if I < 0 then
      begin
        FSendImageThread := nil; // wait no longer
        LogMediaError('TMC.Destroy FSendImageThread <> nil');
      end;
    end;

    I := Length(FVideoDevices) - 1;
    While I > -1 do
    Begin
      if FVideoDevices[I] is TIsCaptureDeviceVideoTst then
        FVideoDevices[I].Free; // Only Test Devices others owne by
      Dec(I);
    End;
    I := Length(FAudioDevices) - 1;

    While I > -1 do
    Begin
      if FAudioDevices[I] is TIsCaptureDeviceAudioTst then
        FAudioDevices[I].Free;
      Dec(I);
    End;

    try
      SaveANumberOfCommsBitmaps(0);
      FLockObj.Free;
      DropAllChannels;
      FreeAndNil(FComsBitMap);
      FreeAndNil(FLastBitmap);
      If FVideoComsChannels <> nil then
        Raise Exception.Create('FVideoComsChannels <> nil');
    Except
      on E: Exception do
        ISIndyUtilsException(Self, E.Message);
    End;
    if LocalMediaCaptureDevices = Self then
      LocalMediaCaptureDevices := nil;
    inherited;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsMediaCapture.DropAllChannels;
Var
  I: integer;
  NxtObj: TVideoComsChannel;
begin
  try
    if FVideoComsChannels = nil then
      Exit;
    for I := 0 to FVideoComsChannels.count - 1 do
      Try
        NxtObj := FVideoComsChannels[I];
        if NxtObj <> nil then
          NxtObj.DropManager(Self);
        FVideoComsChannels[I] := nil;
        NxtObj.OffThreadDestroy(False);
      Except
        on E: Exception do
          ISIndyUtilsException(Self, E, 'DropAllChannels');
      End;
    FreeAndNil(FVideoComsChannels);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'DropAllChannels');
  End;
end;

procedure TIsMediaCapture.DropVideoCommsChannel(AObj: TVideoComsChannel);
Var
  I: integer;
begin
  Try
    AObj.DropManager(Self);
    if FVideoComsChannels = nil then
      Exit;

    I := FVideoComsChannels.IndexOf(AObj);
    if I > -1 then
    Begin
      FVideoComsChannels.Delete(I);
      ISIndyUtilsException(Self, '#DropVideoCommsChannel >>' + AObj.TextID);
    End
    Else
      ISIndyUtilsException(Self, '#DropVideoCommsChannel Not Found :: ' +
        AObj.TextID);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, '#DropVideoCommsChannel');
  End;
end;

procedure TIsMediaCapture.ErrorMessage(AMsg: String);
begin
  if Assigned(fOnError) then
    fOnError(AMsg)
  Else
    LogMediaError(AMsg);
end;

procedure TIsMediaCapture.ForceTestAudioDevice;
begin
  raise Exception.Create('No ForceTestAudioDevice Code');
end;

procedure TIsMediaCapture.ForceTestVideoDevice;
Var
  I: integer;
begin
  try
    I := Length(FVideoDevices) - 1;
    While I > -1 do
    Begin
      if FVideoDevices[I] is TIsCaptureDeviceVideoTst then
        FVideoDevices[I].Free;
      Dec(I);
    End;

    SetLength(FVideoDevices, 1);
    FVideoDevices[0] := TIsCaptureDeviceVideoTst.Create(nil, true);
    FDefaultCamera := 0;
    FFrontCameraCapture := 0;
  Except
    On E: Exception do
    begin
      LogMediaError('TMC.ForceTestVideoDevice' + E.Message);
    end;
  End;
end;

procedure TIsMediaCapture.GetDevices(AForceTestDummies: Boolean);
var
  I, NxtAudioArray, NxtVideoArray: integer;
  D: TCaptureDevice;
  Dpxy: TIsCaptureDevicePxy;
begin
  Try
    if FInDestroy then
      Exit;

    FFrontCameraCapture := -1;
    FBackCameraCapture := -1;
    FDefaultCamera := -1;
    FDefaultAudioCapture := -1;
    NxtAudioArray := -1;
    NxtVideoArray := -1;
    if (TCaptureDeviceManager.Current <> nil) then
    begin
      for I := 0 to TCaptureDeviceManager.Current.count - 1 do
      begin
        D := TCaptureDeviceManager.Current.Devices[I];
        Dpxy := TIsCaptureDevicePxy(D);
{$IFDEF SupressWinCamera}
{$IFDEF MSWindows}
        if AForceTestDummies then
          if (D is TVideoCaptureDevice) then
            D := nil;
        { I have not yet had success with the Camera on Windows 11
          This will enable the test dummy to repplace it }
{$ENDIF}
{$ENDIF}
        if (D is TVideoCaptureDevice) then
        Begin
          inc(NxtVideoArray);
          SetLength(FVideoDevices, NxtVideoArray + 1);
          FVideoDevices[NxtVideoArray] := TVideoCaptureDevice(D);
          if (Dpxy.MediaType = TMediaType.Video) then
          begin
            if (FVideoDevices[NxtVideoArray].Position = TDevicePosition.Front)
            then
              FFrontCameraCapture := NxtVideoArray
            else if (FVideoDevices[NxtVideoArray]
              .Position = TDevicePosition.Back) then
              FBackCameraCapture := NxtVideoArray
            else
              ErrorMessage('FVideoDevices[' + IntToStr(NxtVideoArray) +
                '] Not Front or back');
          end
          else
            ErrorMessage('FVideoDevices[' + IntToStr(NxtVideoArray) +
              '] Not Video Media');

          if D.IsDefault then
            FDefaultCamera := NxtVideoArray;
        End
        else if (D is TAudioCaptureDevice) then
        begin
          inc(NxtAudioArray);
          SetLength(FAudioDevices, NxtAudioArray + 1);
          FAudioDevices[NxtAudioArray] := TAudioCaptureDevice(D);
          if not(Dpxy.MediaType = TMediaType.Audio) then
            ErrorMessage('FAudioDevices[' + IntToStr(NxtAudioArray) +
              '] Not Audio Media');
          if D.IsDefault then
            FDefaultAudioCapture := NxtAudioArray;
        end;
      end;
    end;
    if AForceTestDummies then
    Begin
      if Length(FVideoDevices) < 1 then
        ForceTestVideoDevice;
      if Length(FAudioDevices) < 1 then
        ForceTestAudioDevice;
    End;
    SetLength(FRetVideoFuncts, Length(FVideoDevices));
    SetLength(FBitMaps, Length(FVideoDevices));
    SetLength(FRetAudioFuncts, Length(FAudioDevices));
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

function TIsMediaCapture.GetOldCommsBitMap(AIndex: integer): TBitmap;
Var
  ActualIndex, SzBuffer: integer;
begin
  Result := nil;
  if AIndex < 1 then
    Exit;

  if FLockObj.TryEnter then
    Try
      SzBuffer := Length(FSentMaps);
      if AIndex > SzBuffer then
        Exit;
      ActualIndex := AIndex - FNxtPos - 1;
      if ActualIndex < 0 then
        ActualIndex := ActualIndex + SzBuffer;

      Result := FSentMaps[ActualIndex];
    Finally
      FLockObj.Leave;
    End;
end;

function TIsMediaCapture.IndexOfDevice(AObj: TObject): integer;
begin
  Result := -1;
  if FInDestroy then
    Exit;

  if AObj is TVideoCaptureDevice then
    Result := IndexInArray(TArrayOfObjects(FVideoDevices), AObj)
  else if AObj is TAudioCaptureDevice then
    Result := IndexInArray(TArrayOfObjects(FAudioDevices), AObj);
end;

procedure TIsMediaCapture.SampleVideoBufferReady(Sender: TObject;
  const ATime: TMediaTime);
var
  idx: integer;
  ThisTime, LastSync: TDateTime;
begin
  try
    if FInDestroy then
      Exit;

    if FCurSynceBitmapBusy then
    begin
      ErrorMessage('if FCurSynceBitmapBusy then');
      Exit;
    end;

    ThisTime := ATime.ToDateTime;
    If ThisTime < 100 then
      ThisTime := now;

    // ISIndyUtilsException('Dbg', 'SmpBufrRdy This Time ' +
    // FormatDateTime('mm dd hh:nn', ThisTime));
    // ISIndyUtilsException('Dbg', 'SmpBufrRdy This Time ' +
    // FormatDateTime('mm dd hh:nn', Now));

    LastSync := FSyncTime;
    if LastSync > 100 then
    begin
      FSamplesPerSecond := 1 / ((ThisTime - LastSync) * 24 * 60 * 60);
      // if TempErrorCount=2 then
      if (now - ThisTime) > 1 / 24 / 60 / 60 then
      Begin
        ErrorMessage('SmpBufrRdy Process Time = ' +
          FormatDateTime('yy/mm/dd hh:nn:ss.zzz', now - ThisTime));
        // ISIndyUtilsException(Self, 'SmpBufrRdy Process Time = ' +
        // FormatDateTime('hh:nn:ss.zzz', now - ThisTime));
      End;
    end;

    idx := IndexOfDevice(Sender);
    if idx < 0 then
      ISIndyUtilsException(Self, 'SmpBufrRdy call no device at ' +
        FormatDateTime('mm dd hh:nn', ThisTime))
    else
    begin
      FLockObj.Acquire;
      Try
        FCurSynceBitmapBusy := true;
        Try
          Try
            FSyncDev := Sender;
            FSyncTime := ThisTime;
            FSyncIndex := idx;
            if (FBitMaps[idx] <> nil) then
            begin
              if FSyncBitmap and IsNotMainThread then
              Begin
                TThread.Synchronize(TThread.CurrentThread, BitMapSync);
                FCurSynceBitmap := FBitMaps[idx];
                // FBitMaps[idx] updated in BitMapSync
                // LogMediaError
                // ('TMC.SampleVideoBufferReady:: 5555555555');
              End
              Else
                BitMapSync
            End
            Else
            Begin
              ISIndyUtilsException(Self, '(FBitMaps[idx]=nil)');
              FCurSynceBitmap := nil;
              if FVideoComsChannels <> nil then
                FCurSynceBitmap := ComsBitMap;
              if FCurSynceBitmap <> nil then
                FVideoDevices[idx].SampleBufferToBitmap(FCurSynceBitmap, true);
            end;

            if FCurSynceBitmap <> nil then
              SendToVideoCommsChannels(FCurSynceBitmap)
              // else
              // ISIndyUtilsException(Self, 'FCurSynceBitmap = nil')
                ;

            if Assigned(FRetVideoFuncts[idx]) then
              if FSyncReturns then
                TThread.Synchronize(TThread.CurrentThread, CaptureSync)
              else
                FRetVideoFuncts[idx](TCaptureDevice(Sender), ThisTime);
          Except
            On E: Exception do
            Begin
              LogMediaError('TMC.SmplRdy::' + E.Message);
              ISIndyUtilsException(Self, E.Message);
            End;
          End;
          FLockObjectDwell := (now - ThisTime);
          if FLockObjectDwell > 1 / 24 / 60 / 60 / 2 then
            If TempErrorCount < 4 then
            Begin
              ErrorMessage('SmpBufrRdy Time to Process = ' +
                FormatDateTime('hh:nn:ss.zzz', FLockObjectDwell));
              ErrorMessage('SmpBufrRdy Process At  ' +
                FormatDateTime('yy/mm/dd hh:nn:ss.zzz', now) +
                ' Time of Sample =' + FormatDateTime('yy/mm/dd hh:nn:ss.zzz',
                ThisTime) + crlf + ' Last Synced at ' +
                FormatDateTime('yy/mm/dd hh:nn:ss.zzz', LastSync) +
                'Raw Media Time =' + IntToStr(ATime));
              inc(TempErrorCount);
            End;
        Finally
          FCurSynceBitmapBusy := False;
        End;
      Finally
        FLockObj.Release;
      End;
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsMediaCapture.SaveANumberOfCommsBitmaps(ANumberToSave: integer);
Var
  CurSz, Nxt: integer;
begin
  Try
    CurSz := Length(FSentMaps);
    if ANumberToSave = CurSz then
      Exit
    else if FLockObj.TryEnter then
      Try
        FNxtPos := 0;
        if ANumberToSave < CurSz then
        Begin
          for Nxt := ANumberToSave to High(FSentMaps) do
            FSentMaps[Nxt].Free;
          SetLength(FSentMaps, ANumberToSave);
        End
        else
        Begin
          SetLength(FSentMaps, ANumberToSave);
          for Nxt := CurSz to High(FSentMaps) do
            FSentMaps[Nxt] := TBitmap.Create;
        End;
      Finally
        FLockObj.Leave;
      End;
  Except
    on E: Exception do
    begin
      ISIndyUtilsException(Self, E.Message);
      if FInDestroy then
        Exit;
    End;
  End;
end;

procedure TIsMediaCapture.SendToVideoCommsChannels(AData: TBitmap);
Var
  TxStr: AnsiString;
begin
  Try
    if (now - FLastVideoComms) < cMinTimeBetweenPicTx then
      Exit;

    if FInDestroy then
      Exit;

    if FVideoComsChannels = nil then
      Exit;
    if FVideoComsChannels.count < 1 then
      Exit;
    if AData = nil then
      Exit;

    if FSendImageThread = nil then
      if not FInDestroy then
      Begin
        FSendImageThread := TThreadTxComImage.Create(Self);
        FSendImageThread.Resume;
      end;

    if (FSendImageThread <> nil) then
      if FLockObj.TryEnter then
        Try
          if AData <> ComsBitMap then
            if (AData.Height = FComsBitmapHeight) and
              (AData.Width = FComsBitmapWidth) then
              FComsBitMap.CopyFromBitmap(AData)
            Else
            Begin
              AlignAspectRatioOfComsBitmpTo(AData);
              FreeAndNil(FLastBitmap);
              Try
                FLastBitmap := AData.CreateThumbnail(FComsBitmapWidth,
                  FComsBitmapHeight);
                FComsBitMap.CopyFromBitmap(FLastBitmap);
              Finally
                // FreeAndNil(FLastBitmap);
              End;
            End;
          TxStr := TVideoComsChannel.PackGraphic(FComsBitMap);
          if not FSendImageThread.AddBitMapString(TxStr) then
          Begin
            inc(FLostCount);
            LogMediaError('Tx full - Loss Count=' + IntToStr(FLostCount));
          End
          Else
            AddSentBitMapCopy(FComsBitMap);
          FLastVideoComms := now;
        Finally
          // FImagesSent := ImagesSent;
          FLockObj.Leave;
        End
      Else if GblRptSendImages then
        LogMediaError('SendToVideoCommsChannels Busy');
  Except
    On E: Exception do
      LogMediaError('SendToVideoCommsChannels>' + E.Message)
  End;
End;

procedure TIsMediaCapture.SetAudioReturn(AReturn: TIsCaptureProc;
  AChoose: integer);
begin
  if (AChoose < 0) or (AChoose > High(FRetAudioFuncts)) then
    Exit;

  FRetAudioFuncts[AChoose] := AReturn;
end;

procedure TIsMediaCapture.SetBitmap(ABitmap: TBitmap; AChoose: integer);
begin
  if FInDestroy then
    Exit;

  if (AChoose < 0) or (AChoose > High(FBitMaps)) then
    Exit;

  FBitMaps[AChoose] := ABitmap;
end;

procedure TIsMediaCapture.SetComsBitmapHeight(const Value: integer);
begin
  if FInDestroy then
    Exit;

  FreeAndNil(FComsBitMap);
  FComsBitmapHeight := Value;
end;

procedure TIsMediaCapture.SetComsBitmapWidth(const Value: integer);
begin
  if FInDestroy then
    Exit;

  FreeAndNil(FComsBitMap);
  FComsBitmapWidth := Value;
end;

procedure TIsMediaCapture.SetVideoReturn(AReturn: TIsCaptureProc;
  AChoose: integer);
begin
  if FInDestroy then
    Exit;
  if (AChoose < 0) or (AChoose > High(FRetVideoFuncts)) then
    Exit;

  FRetVideoFuncts[AChoose] := AReturn;
end;

function TIsMediaCapture.SzPastComsBitMapBuffer: integer;
begin
  Result := Length(FSentMaps);
end;

procedure TIsMediaCapture.TestVideoCommsChannels(AData: TBitmap);
begin
  SendToVideoCommsChannels(AData);
end;

function TIsMediaCapture.VideoCommsReport: String;
begin
  Result := 'Send Images ' + IntToStr(FImagesSent) + crlf + 'Lock Dwell ' +
    FormatFloat('0.000', FLockObjectDwell * 24 * 60 * 60) + ' seconds' + crlf +
    'Video Dwell ' + FormatFloat('0.000', FVideoTxDwell * 24 * 60 * 60) +
    ' seconds' + crlf + 'Lock Dwell ' + FormatFloat('0.000',
    FLockObjectDwell * 24 * 60 * 60) + ' seconds' + crlf + 'Time Sent ' +
    FormatDateTime('ddd hh:nn:ss.z', FLastVideoComms) + crlf + 'Time Sync ' +
    FormatDateTime('ddd hh:nn:ss.z', FSyncTime);
end;

{ TIsCaptureTstThread }

constructor TIsCaptureTstThread.Create(ADevice: TCaptureDevice);
begin
  try
    FDevice := ADevice;
    inc(GlobalThreadCount);
    Inherited Create;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

destructor TIsCaptureTstThread.Destroy;
Var
  ss: string;
begin
  Try
    Dec(GlobalThreadCount);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
  inherited;
end;

procedure TIsCaptureTstThread.Execute;
begin
  Try
    if FDevice is TIsCaptureDeviceVideoTst then
      TIsCaptureDeviceVideoTst(FDevice).DoThreadRun
    else if FDevice is TIsCaptureDeviceAudioTst then
      TIsCaptureDeviceAudioTst(FDevice).DoThreadRun;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

{ TIsCaptureDeviceBaseTst }

constructor TIsCaptureDeviceVideoTst.Create(const AManager
  : TCaptureDeviceManager; const ADefault: Boolean);
begin
  Try
    inc(GblTstDevices);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
  inherited;
end;

destructor TIsCaptureDeviceVideoTst.Destroy;
begin
  Try
    FreeAndNil(FBitmap);
    FreeAndNil(fRunThread);
    Dec(GblTstDevices);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
  inherited;
end;

function TIsCaptureDeviceVideoTst.DoGetAvailableCaptureSettings
  : TArray<TVideoCaptureSetting>;
begin
  SetLength(Result, 0);
  // To stop Absact Warning
end;

procedure TIsCaptureDeviceVideoTst.DoSampleBufferToBitmap
  (const ABitmap: TBitmap; const ASetSize: Boolean);
begin
  // inherited;
  ABitmap.Size := FBitmap.Size;
  ABitmap.CopyFromBitmap(FBitmap);
end;

function TIsCaptureDeviceVideoTst.DoSetCaptureSetting(const ASetting
  : TVideoCaptureSetting): Boolean;
begin
  Result := False;
end;

procedure TIsCaptureDeviceVideoTst.DoStartCapture;
begin
  fRunThread := TIsCaptureTstThread.Create(Self);
end;

procedure TIsCaptureDeviceVideoTst.DoStopCapture;
begin
  FreeAndNil(fRunThread);
end;

Procedure TIsCaptureDeviceVideoTst.DoThreadRun;
Var
  Rect: TRectf;
  Canvas: TCanvas;
  IntTime: Int64;
begin
  FBitmap := TBitmap.Create(2000, 4000);
  while (fRunThread <> nil) and Not fRunThread.Terminated do
    Try
      FBitmap.Clear(TAlphaColorRec.Palegreen);
      Rect.Create(200, 200, 1800, 1800);
      While (fRunThread <> nil) and Not fRunThread.Terminated and
        (Rect.Width > 20) do
      begin
        Canvas := FBitmap.Canvas;
        TIsGraphics.DrawElipse(Rect, Canvas, TAlphaColorRec.red, 10,
          0.9, False);
        // Sleep(1000); one per second
        Sleep(50); // ten per second ??
        IntTime := Round(now * MediaTimeScale * SecsPerDay);
        SampleBufferReady(IntTime);
        // Now := MediaTime / MediaTimeScale / SecsPerDay;
        Rect.Inflate(-20, -20);
        // LogMediaError('TIsCaptureDeviceVideoTst.DoThreadRun::'+IntToStr(Round(Rect.Width))
        // +IntToStr(Round(Rect.Width))+IntToStr(Round(Rect.Width))+IntToStr(Round(Rect.Width)));
      end;
    Except
      On E: Exception do
      Begin
        ISIndyUtilsException(self,E,'TIsCaptureDeviceVideoTst.DoThreadRun');
        fRunThread.Terminate;
      End;
    End;
  ISIndyUtilsException(self,'TIsCaptureDeviceVideoTst.DoThreadRun:: 66666');
  FreeAndNil(FBitmap);
end;

function TIsCaptureDeviceVideoTst.GetCaptureSetting: TVideoCaptureSetting;
begin

end;

function TIsCaptureDeviceVideoTst.GetDeviceState: TCaptureDeviceState;
begin
  if fRunThread = nil then
    Result := TCaptureDeviceState.Stopped
  else
    Result := TCaptureDeviceState.Capturing;
end;

function TIsCaptureDeviceVideoTst.GetMediaType: TMediaType;
begin
  Result := TMediaType.Video;
end;

{ TIsCaptureDeviceAudioTst }

constructor TIsCaptureDeviceAudioTst.Create(const AManager
  : TCaptureDeviceManager; const ADefault: Boolean);
begin
  Try
    inherited;
    inc(GblTstDevices);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

destructor TIsCaptureDeviceAudioTst.Destroy;
begin
  Try
    FreeAndNil(fRunThread);
    Dec(GblTstDevices);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
  inherited;
end;

procedure TIsCaptureDeviceAudioTst.DoStartCapture;
begin
  try
    fRunThread := TIsCaptureTstThread.Create(Self);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsCaptureDeviceAudioTst.DoStopCapture;
begin
  Try
    FreeAndNil(fRunThread);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

procedure TIsCaptureDeviceAudioTst.DoThreadRun;
begin

end;

function TIsCaptureDeviceAudioTst.GetDeviceState: TCaptureDeviceState;
begin
  if fRunThread = nil then
    Result := TCaptureDeviceState.Stopped
  else
    Result := TCaptureDeviceState.Capturing;
end;

function TIsCaptureDeviceAudioTst.GetMediaType: TMediaType;
begin
  Result := TMediaType.Audio;
end;

Procedure GblMobileMediaCaptureFinalize;
Var
  s: string;
Begin
  Try
    LocalMediaCaptureDevices.Free;
    if GblTstDevices > 0 then
      GblTstDevices := 0;
  Except
    on E: Exception do
      ISIndyUtilsException('GblMobileMediaCaptureFinalize', E.Message);
  End;
End;

Initialization

finalization

GblMobileMediaCaptureFinalize;

end.
