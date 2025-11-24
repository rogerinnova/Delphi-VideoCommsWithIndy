unit IsMediaCommsObjs;

interface

{$IFDEF FPC}
{$DEFINE UseVCLBITMAP}
{$MODE Delphi}
// {$I InnovaLibDefsLaz.inc}
{$H+}
{$ELSE}
{$IFNDEF FMXApplication}
{$DEFINE UseVCLBITMAP}
{$ENDIF}
{$ENDIF}
{$IFDEF DoNotUseVCLBITMAP}
{$UNDEF UseVCLBITMAP}
{$ENDIF}

uses
{$IFDEF UseVCLBITMAP}
{$IFDEF FPC}
  Graphics,
{$ELSE}
  Vcl.Graphics,
  Vcl.Imaging.jpeg,
{$ENDIF}
  ISImageHelpers,
{$ELSE}
  Fmx.Graphics,
{$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
  Classes, SysUtils, UITypes, IsGblLogCheck, // IsStrUtl,
  ISRemoteConnectionIndyTCPObjs;

Type

{$IFDEF UseVCLBITMAP}
  TInGraphicProc = Procedure(AGraphic: TGraphic) of Object;
{$ELSE}
  TInGraphicProc = Procedure(AGraphic: TBitMap) of Object;
{$ENDIF}

  TVideoComsChannel = Class(TISIndyTCPFullDuplexClient)
  Private
    FLastRxOrAcknowledgeGraphic, FLastTx: TDateTime;
    FManager: TObject;
    FOutGoingGraphicsRequested, FOpenGraphicChannelToActiveRx: Boolean;
    FOnInComingGraphic: TInGraphicProc;
    FLastPayload: AnsiString;
{$IFDEF Debug}
    FVideoInRptCount: integer;
{$ENDIF}
{$IFDEF UseVCLBITMAP}
    Class Function RecoverGraphic(AData: AnsiString): TGraphic;
{$ELSE}
    Class Function RecoverGraphic(AData: AnsiString): TBitMap;
{$ENDIF}
    Class procedure StringAsStrm(AData: AnsiString; AStm: TStream);
    Class function StreamAsString(AStrm: TStream): AnsiString; // From IsStrUtl
  Protected
    function DoFullDuplexIncomingAction(AData: AnsiString): Boolean; override;
    procedure SyncedIncomingGraph;
    procedure SyncedCheckCloseGraphicWithNil;
    // will send a nil graphic to the on incoming graphic routine
    procedure WasClosedForcfullyOrGracefully; Override;
    function Write(AData: RawByteString): integer; override;
  Public
    Destructor Destroy; override;
    Function SetManager(AManager: TObject): Boolean;
    Procedure DropManager(AManager: TObject);
    Procedure CheckChannelGraphicStillOpen;
    Class Function PackGraphic(AGraphic: Pointer): AnsiString;
{$IFDEF UseVCLBITMAP}
    Class Function TestGraphic(AGraph: TGraphic): TGraphic;
{$ELSE}
    Class Function TestGraphic(AGraph: TBitMap): TBitMap;
{$ENDIF}
    Function OpenChannel: Boolean;
    Function CloseChannel: Boolean;
    Function ChannelActiveWithGraphic(Atst: TDateTime = 30 / 24 / 60 /
      60): Boolean;
    Function CloseRemoteCircuit: Boolean;
    Property OnInComingGraphic: TInGraphicProc Read FOnInComingGraphic
      write FOnInComingGraphic;
    Property InComingGraphicsActive: Boolean read FOpenGraphicChannelToActiveRx;
    Property OutGoingGraphicsRequested: Boolean read FOutGoingGraphicsRequested;
  end;

  TMediaCommands = (OpenTraffic, CloseTraffic, AcceptFMXBitmap, CloseTxCircuit,
    NullMediaCmd);

Function DecodeMediaCommand(Out AData: AnsiString; ACommand: AnsiString)
  : TMediaCommands;

{$IFDEF NextGen}

Var
  MediaCommandArray: Array [OpenTraffic .. NullMediaCmd] of AnsiString;

Const
{$ELSE}
Const
  MediaCommandArray: Array [OpenTraffic .. NullMediaCmd] of AnsiString =
    ('#OpenTraffic!', '#CloseTraffic!', '#AcceptFMXBitmap!', '#CloseCircuit!',
    '#Null!');
{$ENDIF}
  ObjStmNullFlag = 55;
  ObjStmRegBitMapObj = 68;
  ObjStmMetaFileObj = 77;
  ObjStmIconObj = 96;
  ObjStmJPEGObj = 22;
  ObjStmGraphEnd = 11;

implementation

uses
{$IFNDEF FPC}
  IsMobileCaptureDevices,
{$ENDIF}
  IsIndyUtils;

Function DecodeMediaCommand(Out AData: AnsiString; ACommand: AnsiString)
  : TMediaCommands;
Var
  i: TMediaCommands;
Begin
  Result := NullMediaCmd;
  if ACommand <> '' then
  Begin
    i := OpenTraffic;
    while (i < NullMediaCmd) and (Result = NullMediaCmd) do
      if Pos(MediaCommandArray[i], ACommand) = 1 then
        Result := i
      else
        inc(i);
  End;

  if Result = NullMediaCmd then
    AData := ACommand
  else
    AData := Copy(ACommand, Length(MediaCommandArray[Result]) + 1,
      Length(ACommand));
End;

{ TVideoComsChannel }

function TVideoComsChannel.ChannelActiveWithGraphic(Atst: TDateTime): Boolean;
begin
  Result := (Now - FLastRxOrAcknowledgeGraphic) < Atst;
end;

procedure TVideoComsChannel.CheckChannelGraphicStillOpen;
begin
  if FOpenGraphicChannelToActiveRx then
  Begin
    If not ChannelActiveWithGraphic(1 / 24 / 12) then
    begin
      FOpenGraphicChannelToActiveRx := false;
      if GblLogAllChlOpenClose then
        if Assigned(OnLogMsg) then
          LogAMessage('Closing Graphic Channel ' + TextID)
        else
          ISIndyUtilsException(Self, 'Closing Graphic Channel ' + TextID);
    end
    else if ChannelActiveWithGraphic(1 / 24 / 12) then
    begin
      FOpenGraphicChannelToActiveRx := true;
      if GblLogAllChlOpenClose then
        if Assigned(OnLogMsg) then
          LogAMessage('Open Graphic Channel ' + TextID)
        else
          ISIndyUtilsException(Self, 'Open Graphic Channel ' + TextID);

    end;
  End;
end;

function TVideoComsChannel.CloseChannel: Boolean;
Var
  TimeStmp: TTimeRec;
begin
  FOutGoingGraphicsRequested := false;
  TimeStmp.SetValue(Now);
  Result := FullDuplexDispatch(MediaCommandArray[CloseTraffic] +
    TimeStmp.TransString, '');
end;

function TVideoComsChannel.CloseRemoteCircuit: Boolean;
Var
  TimeStmp: TTimeRec;
begin
  TimeStmp.SetValue(Now);
  Result := FullDuplexDispatch(MediaCommandArray[CloseTxCircuit] +
    TimeStmp.TransString, '');
end;

destructor TVideoComsChannel.Destroy;
begin
  try
    if Assigned(FOnInComingGraphic) then
      Try
        FOnInComingGraphic(Nil);
      Except
        on E: Exception do
          ISIndyUtilsException(Self, E,
            'Destroy - Assigned(FOnInComingGraphic)');
      End;
{$IFNDEF FPC}
    if FManager is TIsMediaCapture then
      TIsMediaCapture(FManager).DropVideoCommsChannel(Self);
{$ENDIF}
    inherited;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'Destroy');
  End;
end;

function TVideoComsChannel.DoFullDuplexIncomingAction
  (AData: AnsiString): Boolean;
Var
  TstTmStmp: TTimeRec; // Temp until all senders suport TTimeRec;
{$IFDEF UseVCLBITMAP}
  BitMap: TGraphic;
  // Class Function RecoverGraphic(AData: AnsiString): TGraphic;
{$ELSE}
  BitMap: TBitMap;
  // Class Function RecoverGraphic(AData: AnsiString): TBitMap;
{$ENDIF}
begin
  Result := false;
  FLastDuplexTime := Now;
{$IFDEF Debug}
  if Length(AData) > 4 then
    if FVideoInRptCount > 0 then
      Dec(FVideoInRptCount)
    Else
      FVideoInRptCount := 50;
{$ENDIF}
  Try
    Result := true;
    case DecodeMediaCommand(FLastPayload, AData) of
      OpenTraffic:
        Begin
          FOutGoingGraphicsRequested := true;
          FLastRxOrAcknowledgeGraphic := FLastDuplexTime;
          If not TestTimeStamp(AData) then
            LogTimeStampFail(AData, 'Fail Open Traffic Timer');
          // {$IFDEF Debug}
          // if FVideoInRptCount = 49 then
          // ISIndyUtilsException(Self, 'TVCmms DupIn>>OpenTraffic>>' + AData);
          // {$ENDIF}
        End;
      CloseTraffic:
        Begin
          FOutGoingGraphicsRequested := false;
          // FOpenGraphicChannelToActiveRx := false;
          If not TestTimeStamp(AData) then
            LogTimeStampFail(AData, 'Fail Close Traffic Timer');
        End;
      AcceptFMXBitmap:
        begin
          FLastRxOrAcknowledgeGraphic := FLastDuplexTime;
          If Assigned(FOnInComingGraphic) then
            if SynchronizeResults then
              SyncReturn(SyncedIncomingGraph)
            Else
            Begin
              BitMap := RecoverGraphic(FLastPayload);
              try
                FOnInComingGraphic(BitMap);
              finally
                FreeAndNil(BitMap);
              end;
            End;
          If TstTmStmp.FromTransString(AData) then
            // Temp until all senders suport TTimeRec;
            If not TstTmStmp.DelayOfLessThan(10000) then
              LogTimeStampFail(AData, 'Fail Bitmap Timer::');
          FOpenGraphicChannelToActiveRx := true;
          If FOutGoingGraphicsRequested then
           If not OpenChannel then // respond with open traffic
            ISIndyUtilsException(Self,'Open Channell Fail on'+textId);
        end;
      CloseTxCircuit:
        Begin
          If not TestTimeStamp(AData) then
            LogTimeStampFail(AData, 'Fail Close Traffic Timer CloseTxCircuit');
          Free;
        End;
      NullMediaCmd:
        if (AData = '') and FOutGoingGraphicsRequested then // Poll
          OpenChannel
        else
          Result := Inherited DoFullDuplexIncomingAction(AData);
      else
       ISIndyUtilsException(self,'No Decode DoFullDuplexIncomingAction::'+FLastPayload);
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'DoFullDuplexIncomingAction>>' + E.Message);
  End;
end;

procedure TVideoComsChannel.DropManager(AManager: TObject);
begin
  if FManager = AManager then
  Begin
    FManager := nil;
    PermHold := false;
  End;
end;

function TVideoComsChannel.OpenChannel: Boolean;
Var
  TimeStmp: TTimeRec;
begin
  FOutGoingGraphicsRequested := true;
  FOpenGraphicChannelToActiveRx := true;
  TimeStmp.SetValue(Now);
  Result := FullDuplexDispatch(MediaCommandArray[OpenTraffic] +
    TimeStmp.TransString, '');
end;

class function TVideoComsChannel.PackGraphic(AGraphic: Pointer): AnsiString;
Var
  m, MStrm: TMemoryStream;
  GType: Word;
  GObject: TObject;
  Sz: LongInt;
  TimeStmp: TTimeRec;
{$IFDEF UseVCLBITMAP}
  GraphicOut: TGraphic;
{$ELSE}
  GraphicOut: TBitMap;
{$ENDIF}
begin
  TimeStmp.SetValue(Now);
  GObject := AGraphic;
  GraphicOut := AGraphic;
  m := nil;
  MStrm := TMemoryStream.create;
  Try
    Begin
      if GObject = nil then
        GType := ObjStmNullFlag
      else
{$IFNDEF UseVclBitmap}
        if GObject is TBitMap then
          GType := ObjStmRegBitMapObj
{$ELSE}
      if GraphicOut is TBitMap then
        GType := ObjStmRegBitMapObj
      else if GraphicOut is TMetaFile then
        GType := ObjStmMetaFileObj
      else if GraphicOut is TIcon then
        GType := ObjStmIconObj
      else if GraphicOut is TJPEGImage then
        GType := ObjStmJPEGObj
{$ENDIF}
      else
        raise EExceptionIsComsNotExpected.create('Invalid Graphic to File');

      MStrm.Write(GType, SizeOf(GType));
      if GType <> ObjStmNullFlag then
        try
          m := TMemoryStream.create;
          if GraphicOut <> nil then
          begin
            GraphicOut.SaveToStream(m);
            Sz := m.Size;
            MStrm.Write(Sz, SizeOf(Sz));
            if Sz > 0 then
              MStrm.CopyFrom(m, 0);
          end;
        finally
          m.Free;
        end { try }
      Else
      Begin
        Sz := 0;
        MStrm.Write(Sz, SizeOf(Sz));
      End;
      MStrm.Write(Sz, SizeOf(Sz));
      GType := ObjStmGraphEnd;
      MStrm.Write(GType, SizeOf(GType));
      Result := StreamAsString(MStrm);
    End;
  Finally
    MStrm.Free;
  End;
  Result := MediaCommandArray[AcceptFMXBitmap] + Result + MediaCommandArray
    [NullMediaCmd] + TimeStmp.TransString;
end;

{$IFDEF UseVCLBITMAP}

Class function TVideoComsChannel.RecoverGraphic(AData: AnsiString): TGraphic;
{$ELSE}

Class function TVideoComsChannel.RecoverGraphic(AData: AnsiString): TBitMap;
{$ENDIF}
Var
  Stm, m: TMemoryStream;
  GType: Word;
  Sz, Sz2: LongInt;
  Tst: AnsiString;

begin
  try
    Result := nil;
    Stm := TMemoryStream.create;
    Try
      StringAsStrm(AData, Stm);
      Stm.seek(0, TSeekOrigin.soBeginning);
      Stm.read(GType, SizeOf(GType));
      Stm.read(Sz, SizeOf(Sz));
      if Sz > 0 then
      begin
        m := TMemoryStream.create;
        try
          m.CopyFrom(Stm, Sz);
          Tst := StreamAsString(m);
          m.seek(0, TSeekOrigin.soBeginning);
          case GType of
            ObjStmNullFlag:
              Exit;
{$IFDEF UseVCLBITMAP}
            ObjStmRegBitMapObj:
              Result := TVclImageTypeDecode.GetVclGraphicObjFromStream(m);
            ObjStmMetaFileObj:
              ;
            ObjStmIconObj:
              Result := TIcon.create;
            ObjStmJPEGObj:
              Result := TJPEGImage.create;
            ObjStmGraphEnd:
              Exit;
{$ELSE}
            ObjStmRegBitMapObj:
              Result := TBitMap.create;
{$ENDIF}
          Else
            Exit;
          end;
          // m.Seek(0, TSeekOrigin.soBeginning);
          // m.Position:=0;
          // Tst:=StreamAsString(m);
          m.Position := 0;
          If Result <> nil then
            Result.LoadFromStream(m);
        finally
          m.Free;
        end;
      end
      else
        FreeAndNil(Result);

      Stm.read(Sz2, SizeOf(Sz2));
      Stm.read(GType, SizeOf(GType));
      if GType <> ObjStmGraphEnd then
        FreeAndNil(Result);
    Finally
      Stm.Free;
    End;
  Except
    FreeAndNil(Result);
    Result := nil;
  end;
end;

function TVideoComsChannel.SetManager(AManager: TObject): Boolean;
begin
  Result := false;
  Try
    FPermHold := true; // TISIndyTCPFullDuplexClient.PermHold
    FPoleInterval := 1 / 24 / 60;
    Result := FManager = AManager;
    if Result then
      Exit;

{$IFNDEF FPC}
    if (FManager <> nil) and (FManager <> AManager) then
      if FManager is TIsMediaCapture then
        TIsMediaCapture(FManager).DropVideoCommsChannel(Self);
{$ENDIF}
    FManager := AManager;
{$IFNDEF FPC}
    if (FManager <> nil) then
      if FManager is TIsMediaCapture then
        TIsMediaCapture(FManager).AddVideoCommsChannel(Self);
{$ENDIF}
    Result := FManager = AManager;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

class function TVideoComsChannel.StreamAsString(AStrm: TStream): AnsiString;
// From IsStrUtl
var
  Sz: int64;
  st: LongInt;
  Rptr: PAnsiChar;
begin
  Sz := AStrm.Size;
  if Sz > 20000000 then
    raise Exception.create('StreamAsString 20 Meg Limit');
  Try
    AStrm.seek(0, TSeekOrigin.soBeginning);
{$IFDEF NextGen}
    Result.ReadBytesFrmStrm(AStrm, Sz);
{$ELSE}
    SetLength(Result, Sz);
    Rptr := PAnsiChar(Result);
    st := Sz;
    st := AStrm.read(Rptr[0], st);
    if st < Sz then
      SetLength(Result, st);
{$ENDIF}
  Except
    On E: Exception do
      raise Exception.create('StreamAsString Error::' + E.Message);
  End;
end;

Class procedure TVideoComsChannel.StringAsStrm(AData: AnsiString;
  AStm: TStream);
// From IsStrUtl
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
  AStm.Write(B[0], Length(AData));
{$ENDIF}
end;

procedure TVideoComsChannel.SyncedCheckCloseGraphicWithNil;
Var
{$IFDEF UseVCLBITMAP}
  BitMap: TGraphic;
  // Class Function RecoverGraphic(AData: AnsiString): TGraphic;
{$ELSE}
  BitMap: TBitMap;
  // Class Function RecoverGraphic(AData: AnsiString): TBitMap;
{$ENDIF}
begin
  If Assigned(FOnInComingGraphic) then
  Begin
    BitMap := nil;
    try
      FOnInComingGraphic(BitMap);
    finally
      FreeAndNil(BitMap);
    end;
  end;
end;

procedure TVideoComsChannel.SyncedIncomingGraph;
Var
{$IFDEF UseVCLBITMAP}
  BitMap: TGraphic;
  // Class Function RecoverGraphic(AData: AnsiString): TGraphic;
{$ELSE}
  BitMap: TBitMap;
  // Class Function RecoverGraphic(AData: AnsiString): TBitMap;
{$ENDIF}
begin
  If Assigned(FOnInComingGraphic) then
  Begin
    BitMap := RecoverGraphic(FLastPayload);
    try
      FOnInComingGraphic(BitMap);
    finally
      FreeAndNil(BitMap);
    end;
  end;
end;

{$IFDEF UseVCLBITMAP}

Class Function TVideoComsChannel.TestGraphic(AGraph: TGraphic): TGraphic;
{$ELSE}

Class Function TVideoComsChannel.TestGraphic(AGraph: TBitMap): TBitMap;
{$ENDIF}
Var
  Data, Payload: AnsiString;
  // Tst: TMediaCommands;
begin
  Data := PackGraphic(AGraph);
  // Tst := DecodeMediaCommand(Payload, Data);
  Result := RecoverGraphic(Payload);
end;

procedure TVideoComsChannel.WasClosedForcfullyOrGracefully;
Var
  Date: TDateTime;
begin
  Date := Now;
  inherited;
end;

function TVideoComsChannel.Write(AData: RawByteString): integer;
begin
  Try
    FLastTx := Now;
    Result := Inherited;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

{$IFDEF NextGen}

Initialization

MediaCommandArray[OpenTraffic] := '#OpenTraffic!';
MediaCommandArray[CloseTraffic] := '#CloseTraffic!';
MediaCommandArray[AcceptFMXBitmap] := '#AcceptFMXBitmap!';
MediaCommandArray[CloseTxCircuit] := '#CloseCircuit!';
MediaCommandArray[NullMediaCmd] := '#Null!';
{$ENDIF}

end.
