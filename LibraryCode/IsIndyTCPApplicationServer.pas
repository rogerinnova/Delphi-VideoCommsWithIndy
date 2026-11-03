{$IFDEF FPC}
{$MODE Delphi}
{$I InnovaLibDefsLaz.inc}
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}
unit IsIndyTCPApplicationServer;
// Indy

interface

uses
{$IFDEF FPC}
  SysUtils,
  Classes,
  SyncObjs,
  IsLazarusPickup,
  {#$IFNDEF  SuppressIPMetering}
  IsLazTimeSpan,
  {#$ENDIF}
{$ELSE}
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.SyncObjs,
  {#$IFNDEF  SuppressIPMetering}
  System.TimeSpan, System.Diagnostics,
  {#$ENDIF}
{$ENDIF}
  IdContext, inifiles, IdTCPConnection, IdGlobal, IdYarn,
  IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdTCPServer, IdThreadSafe,
  ISStrUtl, IsArrayLib,
{$IFDEF Nextgen}
  IsNextGenPickup,
{$ENDIF}
  IsObjectTimeSpanRecording, ISRemoteConnectionIndyTCPObjs;

type
  TComandActionString = Function(AData: String; ATcpSession: TISIndyTCPBase)
    : String of Object;
  // TActionPassThru = Procedure(ADate: AnsiString;
  // ATcpSession: TISIndyTCPBase)of Object;

  TBusyCheckCalls = class(TObject)
  private
    FLastCall, FAllowTo80: TTimeSpan;
    FCountTo80, FTotalCalls: Integer;
    FIpStr: string;
    FBusyWatch: TStopwatch;
  Public
    constructor Create(Const AAllowence: TTimeSpan; Const AIpStr: string);
    Destructor Destroy; Override;
    Function NotTooBusy(const AAllowance: TTimeSpan): Boolean;
    Function TextData: String;
  end;

  TIsIndyTCPServerContext = class;

  TISIndyTCPSvrSession = class(TISIndyTCPBase)
    { New thinking September 2026
      Session is Owned by Context }
    // Session Freed on Context Destroy WasClosedForcfullyOrGracefully;
    // Override;
    // And CloseConnection;
    // Override;
    // Flag Context Closed ClearReferences Nulls FConnection and FIOHandler

    { Call Stack Close Remote Session
      TIdIOHandlerSocket.Close;
      TIdTCPConnection.Destroy;
      TIdContext.Destroy;
      TIsIndyTCPServerContext.Destroy;
      TIdThreadWithTask.Destroy

      Server Incoming Data
      TISIndyTCPSvrSession.ProcessNextTransaction
      TIsIndyApplicationServer.IsIdTCPSvrSessionExecute
      TIdCustomTCPServer.DoExecute(AContext:
      TIdContext.Run:
      TIdThreadWithTask.Run;
      TIdThread.Execute;
      TIdThreadWithTask.Run;

    }
  private
    FInSessionDestroy, FIsMeteredTransaction: Boolean;
    FTimeOutAt, FPermittedIdleTime, FReportIdleTime: TTimeSpan;
    FServerObject: TIdTcpServer;
    FServerContext: TIsIndyTCPServerContext;
    FRegisteredAs: AnsiString;
    FOnSimpleRemoteAction: TComandActionAnsi;
    FOnStringAction: TComandActionString;
    // FLockSession: TCriticalSection;
{$IFNDEF  SuppressIPMetering}
    FCurrentTxMetering: AnsiString;
    FAveProcTm, FmaxProcTm, FminProcTm: Double;
    FAveProcSumSqs: Double;
    FProcTmSamples: Integer;
    FAveDispatchTm, FMaxDispatchTm, FMinDispatchTm, FmaxSrvReadTm,
      FminSrvReadTm: Double;
    FAveSrvReadTm, FAveSrvReadSumSqs, FAveDisPatchSumSqs: Double;
    FDisPatchSamples, FSrvReadTmSamples: Integer;
{$ENDIF}
    function ShowServerDetails: AnsiString;
    function ShowServerConnections(ARegData: AnsiString): AnsiString;
    function SetServerConnections(AConnectData: AnsiString): AnsiString;
    // Link to Advertised - cServerLink
    // Start new followon  - cNewIPLink
    Procedure ClearReferences;
    // Procedure BeforeContextRun(AContext:TIdContext);
{$IFNDEF  SuppressIPMetering}
    Procedure CalAveSrvReadTime(ASample: TTimeSpan);
    Procedure CalAveTransProcTime(ASample: TTimeSpan);
    Procedure CalAveDispatchTime(ASample: TTimeSpan);
{$ENDIF}
    Function ResetServer(AConnectData: AnsiString): AnsiString;
    function DropCoupledSession: AnsiString;
  protected
    FCountTo80: Integer;
    FNext80TransactionAllowance: TTimeSpan;
    // function ProcessSimpleRemoteActionTxn(ACommand: AnsiString):AnsiString;
    Procedure SetFullDuplex(Val: Boolean); override;
    Function CheckWriteBusy: Boolean; override;
    Function CheckReadBusy: Boolean; override;
    function DoSimpleRemoteAction(ACommand: AnsiString): AnsiString;
    Procedure DoFileTransferBlockDnLd(ACommand: AnsiString);
    Procedure DoFileTransferBlockUpLd(ADataIn: AnsiString);
    procedure WasClosedForcfullyOrGracefully; Override;
    procedure CloseConnection; Override;
  Public
    Constructor Create(AContext: TIsIndyTCPServerContext;
      AServer: TIdCustomTCPServer);
    Destructor Destroy; Override;
    Function FullDuplexDispatch(AData: AnsiString; AKey: AnsiString
{$IFNDEF NextGen}
      = '' // Not Next Gen
{$ENDIF} ): Boolean; override;
    // On A server session object FConnection maybe unsafe
    Function AcceptStart: Boolean;
    Function ProcessNextSrvrTransaction: Boolean;
    // function PackAServerFile(const AFileName: AnsiString): AnsiString;
    function IsTimedOut(ACloseIfTrue: Boolean = false): Boolean;
    function PackAServerFileSize(const AFileName: AnsiString): AnsiString;
    function PackAServerAvailableFiles(const AFileName: AnsiString): AnsiString;
    // function PackAPutServerFileResponse(const AFileData: AnsiString)
    // : AnsiString;
    function ConnectionStatusText: AnsiString;
{$IFNDEF  SuppressIPMetering}
    function ConnectionResponseTimesText: AnsiString;
{$ENDIF}
    function LinkedTo(APort, BPort: Integer): Integer;
    function TextID: String; override;
    function PortId: String; override;
    // Procedure DropSrvrReferences;
    Property OnSimpleRemoteAction: TComandActionAnsi Read FOnSimpleRemoteAction
      Write FOnSimpleRemoteAction;
    Property OnStringAction: TComandActionString Read FOnStringAction
      Write FOnStringAction;
    // Property OnFullDuplexIncomingAction:TActionPassThru Read FOnFullDuplexIncomingAction write FOnFullDuplexIncomingAction;
{$IFNDEF  SuppressIPMetering}
    Property AveProcTm: Double Read FAveProcTm;
    Property AveDispatchTm: Double Read FAveDispatchTm;
{$ENDIF}
  end;

  { TIsIndyTCPServerContext }

  TIsIndyTCPServerContext = class(TIdServerContext)
  Private
    FContextID: string;
    FTcpRef: TISIndyTCPSvrSession;
    FSessionClosing: Boolean;
    FContextStopWatch: TStopwatch;
{$IFNDEF  SuppressIPMetering}
    FLastProcessComplete: TTimeSpan;
    FAverageProcTm, FmaxProcTm, FminProcTm, FAverageDnTm, FmaxDnTm,
      FminDnTm: Double;
    FAverageProcSumSqs, FAverageDnSumSqs: Double; // msecs
    FNoProcTmSamples: Integer;
    Procedure CalAverageProcessTime(AProcessTime, ADownTime: TTimeSpan);
{$ENDIF}
  Protected
    function Run: Boolean; override;
  Public
    constructor Create(AConnection: TIdTCPConnection; AYarn: TIdYarn;
      AList: TIdContextThreadList = nil); override;
    Destructor Destroy; override;
    Function TcpRef: TISIndyTCPSvrSession;
    Function RawTcpRef: TISIndyTCPSvrSession;
    Function CtxTextId: string;
    Procedure ReleaseOldRef;
{$IFNDEF  SuppressIPMetering}
    function ContextResponseTimesText: AnsiString;
    Property AverageProcessTime: Double read FAverageProcTm; // msecs
    Property AverageDownTime: Double read FAverageDnTm; // msecs
{$ENDIF}
    Property ContextStopWatch: TStopwatch Read FContextStopWatch;
  end;

  { TServerCleanup }
  TServerCleanup = Class(TThread)
  Private
    FOwner: TIdTcpServer;
  Protected
    Procedure Execute; Override;
  public
    Constructor Create(AOwner: TIdTcpServer);
    Destructor Destroy; override;
  End;

  { TIsIndyApplicationServer }
  TIsIndyApplicationServer = class(TIdTcpServer)
  Strict Private
    FApSrvrListLock: TCriticalSection;
    FBusyLock: TCriticalSection;
  Private
    FServerClosing: Boolean;
    FLogsMissed: Integer;
    FCurrentAddresses, FLogList: TStringList;
    // TIdThreadSafeStringList;
    FListOfRegConnections: TIdThreadSafeStringList;
    FCurrentSessionObjects: TThreadList;
    FDoNextCloseEvent: TDateTime;
    FCleanupThread: TServerCleanup;
    FOnSessionSimpleRemoteAction: TComandActionAnsi;
    FOnSessionAnsiStringAction: TComandActionAnsi;
    FOnSessionStringAction: TComandActionString;
    FServerTcpSessions: Integer;
    FTimeLimitFor80Calls, FTimeLimitFor80Transactions: TTimeSpan;
    FIdleTimePermitted: TTimeSpan;
    FResetStartTime: TDateTime;
    FAllowNoPersonality: Boolean; // if > now then reset/reject calls;
    function GetSessionByCallingPort(APeerPortNo: Integer)
      : TISIndyTCPSvrSession;
    // Find ASession on the server given the calling port
    Function ListOfRegConnections: TIdThreadSafeStringList;
    Function LocalContext(AContext: TIdContext): TIsIndyTCPServerContext;
    Function ResetSvr(AData: AnsiString): AnsiString;
    // procedure IsIdTCPSrvrContextCreated(AContext: TIdContext);
    Function ApSrvrListLockTryEnter(ALable: String;
      ATryHalfSecs: Integer = 0): Boolean;
    Function BusyLockTryEnter: Boolean;
    Procedure BusyLockRelease;
    // procedure ApSrvrListLockEnter(ALable: String);
    procedure ApSrvrListLockRelease(ALable: String);
    procedure IsIdTCPSrvrConnect(AContext: TIdContext);
    // Server.IOHandler.Accept(Binding, Self, LYarn);
    // Create and init context
    // LContext := Server.FContextClass.Create(LPeer, LYarn, Server.Contexts)
    // LYarn.Run Holds Thread LContext.Run
    // TIdThread.Execute; with loop???
    // LContext.OnRun := Server.DoExecute := IsIdTCPSvrSessionExecute
    procedure ISIdSrvThrdException(AContext: TIdContext; AException: Exception);
    procedure IsIdTCPSvrSessionExecute(AContext: TIdContext);
    procedure CheckBusyOnConnect(AContext: TIsIndyTCPServerContext);
    // Connections on Ip Address
    procedure CheckBusyOnPacket(ASession: TISIndyTCPSvrSession);
    // packets on channel
    function GetMaxCallsPerMinute: Integer;
    procedure SetMaxCallsperminute(AValue: Integer);
    procedure LoadServerIniData;
    Procedure CloseInactiveSessions;
    procedure ConfirmRegisteredConnections;
    // Decouples registered session when follow on is not rx data
    Procedure AddSession(ASession: TISIndyTCPSvrSession);
    Procedure DropSession(ASession: TISIndyTCPSvrSession);
    Procedure DropAllCurrentSessions; // On Closing server
  Protected
    FSrvrStopWatch: TStopwatch;
    procedure Shutdown; override;
  Public
    Constructor Create(AOwner: TComponent);
    Destructor Destroy; override;
    Function CurrentlyReset: Boolean;
    Function ServerDetailsAsText: AnsiString;
    Function AllConnectionsAsText: AnsiString;
    Function AllConnectionResponseTimesAsText: AnsiString;
    Function AllRegisteredConnections(AConnection: TISIndyTCPSvrSession)
      : AnsiString;
    Function RemotePortRegAsString(ARegNo: Integer; AConnectNo: Integer = -1)
      : AnsiString;
    Function LinkStatusAsResponse(ACommand: AnsiString;
      ASession: TISIndyTCPSvrSession): AnsiString;
    Function GetRegConnectionFor(ARegString: AnsiString): TISIndyTCPBase;
    function ReadLogMessage: String;
    Function CurrentAddresses: TStringList;
    Function CurrentAddressDetails: String;
    Procedure DropRegConnection(AConnection: TISIndyTCPSvrSession);
    Property OnSessionSimpleRemoteAction: TComandActionAnsi
      Read FOnSessionSimpleRemoteAction Write FOnSessionSimpleRemoteAction;
    Property OnSessionStringAction: TComandActionString
      Read FOnSessionStringAction Write FOnSessionStringAction;
    Property OnSessionAnsiStringAction: TComandActionAnsi
      Read FOnSessionAnsiStringAction Write FOnSessionAnsiStringAction;
    Property MaxCallsPerMinute: Integer Read GetMaxCallsPerMinute
      write SetMaxCallsperminute;
    Property IdleTimePermitted: TTimeSpan Read FIdleTimePermitted
      Write FIdleTimePermitted;
    Property AllowNoPersonality: Boolean Read FAllowNoPersonality
      Write FAllowNoPersonality;
  end;

  TIsMonitorTCPAppServer = Class(TObject)
  Private
    function GetLastStatus: TDateTime;

  Type
    TTstThrd = Class(TThread)
      FIpAddress: String;
      FPort: Integer;
      FLastStatus: TDateTime;
      FLogged: Boolean;
      Constructor Create(AIpAddress: String; APort: Integer);
      Procedure Execute; Override;
    End;

  Var
    FTestThread: TTstThrd;
  Public
    Constructor Create(AIpAddress: String; APort: Integer);
    Destructor Destroy; Override;
    Property LastStatus: TDateTime read GetLastStatus;
  End;

Var
  GlobalDefaultFileAccessBase: String = '';
{$IFDEF Debug}
  GlobalDbugRegisteredAs: AnsiString; // Match FRegisteredAs
{$ENDIF}

implementation

uses {MonitorTestObjs,} IsNavUtils, ISIndyUtils, IsGeneralLib,
  IsGblLogCheck;

function RandomKey: AnsiString;
begin
  // {$ifdef debug}
  // result:='abcde1234567890';
  // exit;
  // {$endif}
  Randomize;
  Result := AnsiChar(Random(254) + 1) + AnsiChar(Random(254) + 1) +
    AnsiChar(Random(254) + 1) + AnsiChar(Random(254) + 1) +
    AnsiChar(Random(254) + 1) + AnsiChar(Random(254) + 1) +
    AnsiChar(Random(254) + 1) + AnsiChar(Random(254) + 1) +
    AnsiChar(Random(254) + 1);
end;

{ TIsIndyApplicationServer }

procedure TIsIndyApplicationServer.AddSession(ASession: TISIndyTCPSvrSession);
Var
  Idx: Integer;
  LSessions: TList;
begin
  if FCurrentSessionObjects = nil then
    FCurrentSessionObjects := TThreadList.Create;
  If not ApSrvrListLockTryEnter('AddSession ' + ASession.FRegisteredAs, 30) then
    raise EExceptionIsComsNotExpected.Create('Cannot Lock Session');
  Try
    LSessions := FCurrentSessionObjects.LockList;
    Try
      Idx := LSessions.IndexOf(ASession);
      if Idx < 0 then
        FCurrentSessionObjects.Add(ASession);
    Finally
      FCurrentSessionObjects.UnlockList;
    end;
  Finally
    ApSrvrListLockRelease('AddSession ');
  end;

  ConfirmRegisteredConnections;

  If FDoNextCloseEvent < now then
    CloseInactiveSessions;
end;

function TIsIndyApplicationServer.AllConnectionResponseTimesAsText: AnsiString;
Var
  i: Integer;
  Obj: TISIndyTCPSvrSession;
  LSessions: TList;
begin
  Try
    if FCurrentSessionObjects = nil then
      Result := 'No Current Sessions' + #13#10
    Else if ApSrvrListLockTryEnter('AllConnectionResponseTimesAsText', 4) then
      Try
        LSessions := FCurrentSessionObjects.LockList;
        Try
          Result := IntToStr(LSessions.Count) + ' Current Sessions' + #13#10;
          for i := 0 to LSessions.Count - 1 do
          Begin
            if TObject(LSessions[i]) is TISIndyTCPSvrSession then
              Obj := TISIndyTCPSvrSession(LSessions[i])
            else
              Obj := nil;

{$IFNDEF  SuppressIPMetering}
            if Obj <> nil then
            Begin
              Result := Result + #13#10#13#10 + Obj.ConnectionResponseTimesText
                + #13#10#13#10 + Obj.TickStatsAsString;
            End;
{$ENDIF}
          end;
        Finally
          FCurrentSessionObjects.UnlockList;
        end;
      Finally
        ApSrvrListLockRelease('AllConnectionResponseTimesAsText');
      end;
  Except
    On E: Exception do
      Result := Result + #13#10 + 'Exception::' + E.Message;
  End;
End;

function TIsIndyApplicationServer.AllConnectionsAsText: AnsiString;
Var
  i: Integer;
  Obj: TISIndyTCPSvrSession;
  LSessions: TList;
  LRegCon: TStringList;

begin
  Try
    if FCurrentSessionObjects = nil then
      Result := 'No Current Sessions' + #13#10
    Else if ApSrvrListLockTryEnter('AllConnectionsAsText', 4) then
      Try
        LSessions := FCurrentSessionObjects.LockList;
        Try
          Result := IntToStr(LSessions.Count) + ' Current Sessions' + #13#10;
          for i := 0 to LSessions.Count - 1 do
            Try
              if TObject(LSessions[i]) is TISIndyTCPSvrSession then
                Obj := TISIndyTCPSvrSession(LSessions[i])
              else
                Obj := nil;
              if Obj <> nil then
                if Obj.FCoupledSession <> nil then
                  Result := Result + Obj.PortId + ' is linked to ' +
                    Obj.FCoupledSession.PortId + '>>' +
                    Obj.FRegisteredAs + #13#10
                else
                  Result := Result + Obj.PortId + '>>' +
                    Obj.FRegisteredAs + #13#10;
            Except
              On E: Exception Do
              Begin
                Result := Result + 'Exception <' + E.Message + '>i=' +
                  IntToStr(i) + #13#10;
                ApplicationFlagThreadMsg('AllConnectionsAsText Exception <' +
                  E.Message + '>i=' + IntToStr(i))
              End;
            End;
        Finally
          FCurrentSessionObjects.UnlockList;
        end;
      Finally
        ApSrvrListLockRelease('AllConnectionsAsText');
      end;
    if FListOfRegConnections = nil then
      Result := Result + #13#10'No Advertised Sessions'#13#10
    Else if ApSrvrListLockTryEnter('AllConnectionsAsText Adv', 4) then
      Try
        LRegCon := FListOfRegConnections.Lock;
        Try
          Result := Result + #13#10 + IntToStr(LRegCon.Count) +
            ' Advertised Sessions' + #13#10;

          for i := 0 to LRegCon.Count - 1 do
            Try
              if LRegCon.Objects[i] is TISIndyTCPSvrSession then
                Obj := TISIndyTCPSvrSession(LRegCon.Objects[i])
              else
                Obj := nil;
              if Obj = nil then
                Result := Result + LRegCon[i] + ' == ' + #13#10
              else if Obj.FCoupledSession <> nil then
                Result := Result + LRegCon[i] + ' == ' + Obj.PortId +
                  ' is linked' + #13#10
              else
                Result := Result + LRegCon[i] + ' == ' + Obj.PortId + #13#10;
            Except
              On E: Exception Do
              Begin
                Result := Result + 'Exception <' + E.Message + '>i=' +
                  IntToStr(i) + #13#10;
                ApplicationFlagThreadMsg('Advertised Sessions Exception <' +
                  E.Message + '>i=' + IntToStr(i))
              End;
            end;
        Finally
          FListOfRegConnections.Unlock;
        end;
      Finally
        ApSrvrListLockRelease('AllConnectionsAsText Adv');
      end;
  Except
    On E: Exception do
      Result := Result + #13#10 + 'AllConnectionsAsText Exception::' +
        E.Message;
  End;
end;

function TIsIndyApplicationServer.AllRegisteredConnections
  (AConnection: TISIndyTCPSvrSession): AnsiString;
Var
  Index, i: Integer;
  s: string;
  LRegCon: TStringList;
  ThisObj: TISIndyTCPSvrSession;
  Obj: TObject;
begin
  Try
    If Not ApSrvrListLockTryEnter('AllRegisteredConnections ' +
      AConnection.PortId, 10) then
      raise EExceptionIsComsNotExpected.Create
        ('AllRegisteredConnections no Lock:: ' + AConnection.PortId);
    Try
      LRegCon := ListOfRegConnections.Lock;
      Try
        if AConnection <> nil then
          if AConnection.FRegisteredAs <> '' then
            if AConnection.CheckConnection then
            Begin
              Index := LRegCon.IndexOf(AConnection.FRegisteredAs);
              if GblRptRegConnectiononSrvr then
              Begin
                s := AConnection.PortId;
                If Index < 0 then
                  s := s + '  #Add Registered Connection::' +
                    AConnection.FRegisteredAs
                Else
                  s := s + '  #Existing Registered Connection::' +
                    AConnection.FRegisteredAs;
                ISIndyUtilsException(Self, s);
              End;
              If Index < 0 then
                LRegCon.AddObject(AConnection.FRegisteredAs, AConnection)
              Else
                LRegCon.Objects[index] := AConnection;
            end;

        if LRegCon.Count < 1 then
          Result := 'No Connections'
        else
          Result := '';

        For i := LRegCon.Count - 1 downto 0 do
          Try
            Obj := LRegCon.Objects[i];
            if Obj is TISIndyTCPSvrSession then
            begin
              ThisObj := TISIndyTCPSvrSession(Obj);
              if ThisObj.CheckConnection then
                Result := Result + ThisObj.ConnectionStatusText + #13#10
              Else
              begin
                LRegCon.Objects[i] := nil;
                LRegCon.Delete(i);
                Result := Result + 'Closed Object at ' + IntToStr(i) + #13#10;
              end;
            end
            else if Obj = nil then
              Result := Result + 'Nil Object at ' + IntToStr(i) + #13#10
            else
            Begin
              LRegCon.Objects[i] := nil;
              LRegCon.Delete(i);
              Result := Result + 'Unknown Object at ' + IntToStr(i) + #13#10;
            end;
          Except
          end;
      Finally
        FListOfRegConnections.Unlock;
      end;
    Finally
      ApSrvrListLockRelease('AllRegisteredConnections');
    End;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'AllRegisteredConnections');
      Result := Result + 'Exception::' + E.Message;
      ApplicationFlagThreadMsg(Result);
    end
  end;
end;

// procedure TIsIndyApplicationServer.ApSrvrListLockEnter(ALable: String);
// Var
// s: string;
// begin
// Try
// s := ALable + '# FApSrvrList Attempt Locked by ' +
// IntToStr(TThread.CurrentThread.ThreadID);
// WritelnIfPossible(s);
// ISIndyUtilsException(Self, s);
// FApSrvrListLock.Enter;
// s := ALable + '# FApSrvrList Locked by ' +
// IntToStr(TThread.CurrentThread.ThreadID);
// WritelnIfPossible(s);
// ISIndyUtilsException(Self, s);
// Except
// On E: Exception do
// ISIndyUtilsException(Self, E, s);
// end;
// end;

procedure TIsIndyApplicationServer.ApSrvrListLockRelease(ALable: String);
Var
  s: string;
begin
  Try
    FApSrvrListLock.Release;
{$IFDEF Release}
    Exit;
{$ENDIF}
    s := ALable + ' FApSrvrList Released by ' +
      IntToStr(TThread.CurrentThread.ThreadID);
    WritelnIfPossible(s);
    ISIndyUtilsException(Self, '#' + s);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, s);
  end;
end;

function TIsIndyApplicationServer.ApSrvrListLockTryEnter(ALable: String;
  ATryHalfSecs: Integer): Boolean;
Var
  s: string;
begin
  Result := false;
  Try
    Result := FApSrvrListLock.TryEnter;
    if Result then
      s := ALable + ':: FApSrvrList is Locked by ' +
        IntToStr(TThread.CurrentThread.ThreadID)
    else
      while Not Result and (ATryHalfSecs > 0) do
      Begin
        Sleep(500);
        s := IntToStr(ATryHalfSecs) + ': ' + ALable;
        Result := ApSrvrListLockTryEnter(s, 0);
        Dec(ATryHalfSecs);
      End;

    if Not Result then
      s := ALable + ':: FApSrvrList Lock Failed by ' +
        IntToStr(TThread.CurrentThread.ThreadID);
{$IFDEF Release}
    Exit;
{$ENDIF}
    WritelnIfPossible(s);
    ISIndyUtilsException(Self, '#' + s);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, s);
  end;
end;

procedure TIsIndyApplicationServer.BusyLockRelease;
begin
  FBusyLock.Release;
end;

function TIsIndyApplicationServer.BusyLockTryEnter: Boolean;
begin
  Result := FBusyLock.TryEnter;
  if Not Result then
    ApplicationFlagThreadMsg('Failed BusyLock');
end;

procedure TIsIndyApplicationServer.CheckBusyOnConnect
  (AContext: TIsIndyTCPServerContext);
// Var
// TcpSession: TISIndyTCPSvrSession;
// See Also \MonitorServers\MonitorTestObjs >> TSrverUsageAndBlockObj
Var
  // Connections on Ip Address
  IpIdx: Integer;
  IObj: TBusyCheckCalls;
  IpStr: string;
begin
  if FServerClosing then
    Exit;
  if AContext = nil then
    Exit;
  if AContext.Connection = nil then
    Exit;
  // While Testing
  ApplicationFlagThreadMsg('CheckBusyOnConnect ' + AContext.CtxTextId);
  Try
    IpStr := AContext.TcpRef.Address;
    IF BusyLockTryEnter then
      try
        if CurrentAddresses.Find(IpStr, IpIdx) then
        Begin
          if FCurrentAddresses.Objects[IpIdx] is TBusyCheckCalls then
            IObj := TBusyCheckCalls(FCurrentAddresses.Objects[IpIdx])
          else
            IObj := nil;
        end
        else
        begin
          IObj := TBusyCheckCalls.Create(FTimeLimitFor80Calls, IpStr);
          FCurrentAddresses.AddObject(IpStr, IObj);
        end;
      finally
        BusyLockRelease;
      end;

    if IObj <> nil then
      if not IObj.NotTooBusy(FTimeLimitFor80Calls) then
        ISIndyUtilsException(Self, IpStr + ' Too Busy');
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'CheckBusyOnConnect');
  End;
end;

procedure TIsIndyApplicationServer.CheckBusyOnPacket
  (ASession: TISIndyTCPSvrSession);
// Var
// TcpSession: TISIndyTCPSvrSession;
// See Also \MonitorServers\MonitorTestObjs >> TSrverUsageAndBlockObj
Var
  LocalAllocationTime, TM: TTimeSpan;

  // packets on channel
  // s: string;
begin
  if FServerClosing then
    Exit;
  if ASession = nil then
    Exit;
  Try
    Inc(ASession.FCountTo80);
    if ASession.FCountTo80 > 80 then
    begin
      TM := ASession.StopWatch.Elapsed;
      ASession.FCountTo80 := 0;
      // ISIndyUtilsException(Self, ASession.TextId+' #FcountTo80 At ' +
      // FormatDateTime('nn:ss.z', Tm));
      LocalAllocationTime := ASession.FNext80TransactionAllowance;
      if TM > LocalAllocationTime then
      begin
        ASession.FCountTo80 := 0;
      end
      else
      Begin
        ISIndyUtilsException(Self, ASession.TextID +
          '# Svr Busy FcountTo80 too early by ' + LocalAllocationTime.Subtract
          (TM).ToString);
        ISIndyUtilsException(Self, '#Svr Busy will Release in ' +
          LocalAllocationTime.Subtract(TM).ToString);
        while TM < LocalAllocationTime do
        begin
          ISIndyUtilsException(Self,
            'Waiting' + FormatDateTime('nn:ss.zzz ', now));
          // must be local as other threads will do check busy
          Sleep(2000); // hold thread for two seconds
          TM := ASession.StopWatch.Elapsed;
        end;
      end;
      ASession.FNext80TransactionAllowance := ASession.StopWatch.Elapsed.Add
        (FTimeLimitFor80Transactions);
    end;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'Check Busy');
      ASession.FCountTo80 := 0;
    end;
  End;
end;

procedure TIsIndyApplicationServer.CloseInactiveSessions;
Var
  ThisSession: TISIndyTCPSvrSession;
  Msg: string;
  LocalList: TList;
  LCurSessionObjList: TList;
  LRegList: TStringList;
  Idx, LblIdx: Integer;
begin
  Try
    if FServerClosing then
      Exit;

    ApplicationFlagThreadMsg('CloseInactiveSessions');
    FDoNextCloseEvent := now + 1 / 24;
    if FCurrentSessionObjects = nil then
      Exit;
    LocalList := TList.Create;
    try
      if not ApSrvrListLockTryEnter('CloseInactiveSessions', 2) then
        Exit;
      try
        LCurSessionObjList := FCurrentSessionObjects.LockList;
        try
          LRegList := ListOfRegConnections.Lock;
          try
            for Idx := 0 to LCurSessionObjList.Count - 1 do
              if LCurSessionObjList[Idx] <> nil then
                if TObject(LCurSessionObjList[Idx]) is TISIndyTCPSvrSession then
                Begin
                  ThisSession := TISIndyTCPSvrSession(LCurSessionObjList[Idx]);
                  if (ThisSession.FCoupledSession is TISIndyTCPSvrSession) then
                  begin
                    if ThisSession.IsTimedOut then
                    Begin
                      if LRegList.IndexOfObject(ThisSession) < 0 then
                        LocalList.Add(ThisSession);
                    end
                    else
                    begin
                      LblIdx := LRegList.IndexOfObject(ThisSession);
                      if LblIdx > -1 then
                      Begin
                        Msg := '#Label ' + LRegList[LblIdx] +
                          ' Connection Timed Out ' + ThisSession.PortId;
                        if GblRptTimeoutClear then
                          ISIndyUtilsException(Self, Msg);
                      End;
                      LocalList.Add(ThisSession);
                    end;
                  end
                  else If ThisSession.IsTimedOut then
                    LocalList.Add(ThisSession);
                end;
          finally
            FListOfRegConnections.Unlock;
          end;
        finally
          FCurrentSessionObjects.UnlockList;
        end;
      finally
        ApSrvrListLockRelease('CloseInactiveSessions');
      end;

      ApplicationFlagThreadMsg('CloseInactiveSessions Local List');

      for Idx := LocalList.Count - 1 downto 0 do
        // Go backwards as sessions may be delaeted
        if LocalList[Idx] <> nil then
          if TObject(LocalList[Idx]) is TISIndyTCPSvrSession then
            Try
              ThisSession := TISIndyTCPSvrSession(LocalList[Idx]);
              If ThisSession.IsTimedOut(True) then
                if GblRptTimeoutClear then
                  ISIndyUtilsException(Self, '# Svr Session TimeOut ' +
                    ThisSession.TextID);
            Except
              On E: Exception do
                ISIndyUtilsException(Self, E, 'ThisSession.IsTimedOut');
            End;
    Finally
      LocalList.Free;
      ApplicationFlagThreadMsg('CloseInactiveSessions Free Local List');
    End;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'CloseInactiveSessions');
  End;
end;

procedure TIsIndyApplicationServer.ConfirmRegisteredConnections;
// Decouples registered session when follow on is not rx data
// This allows Polls from source to be returned stopping the source being declared inactive
Var
  i: Integer;
  ConObj, CplObj: TISIndyTCPSvrSession;
  FollowOn: TISIndyTCPBase;
  ListToDo: TStringList;
  // LCurSessionObj: TList;
  LRegList: TStringList;

begin
  Try
    ListToDo := TStringList.Create;
    Try
      ListToDo.OwnsObjects := false;
      if FListOfRegConnections = nil then
        Exit;
      If Not ApSrvrListLockTryEnter('ConfirmRegisteredConnections', 2) Then
      Begin
        Inc(FLogsMissed);
        Exit;
      end;
      // else
      // LCurSessionObj: TList;
      Try
        LRegList := FListOfRegConnections.Lock;
        Try
          for i := 0 to LRegList.Count - 1 do
            Try
              if LRegList.Objects[i] is TISIndyTCPSvrSession then
                Try
                  ListToDo.AddObject(LRegList[i], LRegList.Objects[i]);
                Except
                  On E: Exception do
                  begin
                    ISIndyUtilsException(Self, E,
                      'Confirm#RegisteredConnections Add I=' + IntToStr(i));
                    WritelnIfPossible
                      (' ConfirmRegisteredConnections Exception :' + E.Message +
                      ' Add I=' + IntToStr(i));
                  end
                End;
            Except
              On E: Exception do
              begin
                ISIndyUtilsException(Self, E, 'Confirm#RegisteredConnections I='
                  + IntToStr(i));
                WritelnIfPossible(' ConfirmRegisteredConnections Exception :' +
                  E.Message + ' I=' + IntToStr(i));
              end
            End;
        finally
          FListOfRegConnections.Unlock;
        End;
      finally
        ApSrvrListLockRelease('ConfirmRegisteredConnections');
      end;

      for i := 0 to ListToDo.Count - 1 do
        try
          if ListToDo.Objects[i] is TISIndyTCPSvrSession then
          begin
            ConObj := ListToDo.Objects[i] as TISIndyTCPSvrSession;
            if (ConObj.FCoupledSession <> nil) then
            Begin
              // while testing
              // ApplicationFlagThreadMsg(Self, 'ConObj.FCoupledSession <> nil ' +
              // ConObj.TextID);
              if (ConObj.FCoupledSession is TISIndyTCPSvrSession) then
              Begin
                CplObj := ConObj.FCoupledSession as TISIndyTCPSvrSession;
                if CplObj <> nil then
                  if CplObj.IsTimedOut(false) then
                  Begin
                    if GblRptTimeoutClear then
                      ApplicationFlagThreadMsg(Self, 'CplObj.IsTimedOut');
                    // while testing
                    ApplicationFlagThreadMsg(Self, 'CplObj.IsTimedOut');

                    ConObj.FCoupledSession := nil;
                    CplObj.FCoupledSession := nil;
                  end
                  else If CplObj.FCoupledSession <> ConObj then
                    ConObj.FCoupledSession := nil;
              end
              Else if (ConObj.FCoupledSession is TISIndyTCPBase) then
              begin
                FollowOn := ConObj.FCoupledSession;
                if FollowOn <> nil then
                  if FollowOn.FCoupledSession <> ConObj Then
                  Begin
                    ConObj.FCoupledSession := nil;
                    FollowOn.FCoupledSession := nil;
                    ApplicationFlagThreadMsg(Self,
                      'FollowOn.FCoupledSession <> ConObj');
                  End;
              End
              else
                ISIndyUtilsException(Self,
                  'ConfirmRegisteredConnections Must not Be so');
            End;
          End;
        Except
          On E: Exception do
          begin
            ISIndyUtilsException(Self, E, 'Confirm#RegisteredConnections');
            WritelnIfPossible(' ConfirmRegisteredConnections Exception :' +
              E.Message);
          end
        end;
      ApplicationFlagThreadMsg
        ('Completed ConfirmRegisteredConnections no exception');
    finally
      FreeAndNil(ListToDo);
    end;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'Confirm#RegisteredConnections Outer');
      WritelnIfPossible(' ConfirmRegisteredConnections Outer Loop Exception :' +
        E.Message);
      ApplicationFlagThreadMsg
        ('ConfirmRegisteredConnections Outer Loop Exception')
    End;
  End;
end;

constructor TIsIndyApplicationServer.Create(AOwner: TComponent);
Var
  LogStart: String;
begin
  ApplicationFlagThreadMsg('Server Create');
  FSrvrStopWatch := TStopwatch.StartNew;
  FServerClosing := false;
  // Four Seconds;
  FTimeLimitFor80Transactions := cStart80TransactionAllowence;
  FApSrvrListLock := TCriticalSection.Create;
  If ApSrvrListLockTryEnter('Create Thread', 2) then
    ApSrvrListLockRelease('Create');
  FBusyLock := TCriticalSection.Create;
  Inherited;
  ContextClass := TIsIndyTCPServerContext;
  OnConnect := IsIdTCPSrvrConnect;
  OnExecute := IsIdTCPSvrSessionExecute;
  OnException := ISIdSrvThrdException;

  // OnContextCreated := IsIdTCPSrvrContextCreated;
  MaxCallsPerMinute := 800;
  ISIndyUtilsException(Self,
    '#' + 'New IsIndyApplicationServer Max Calls Per Min ' +
    IntToStr(MaxCallsPerMinute));
  LoadServerIniData;
  FCleanupThread := TServerCleanup.Create(Self);
  LogStart := '#After Ini' + crlf + 'IsIndyApplicationServer Max Calls Per Min '
    + IntToStr(MaxCallsPerMinute) + crlf + 'Session Idle Timeout =' +
    FIdleTimePermitted.ToString;
  ISIndyUtilsException(Self, LogStart);
  LogStart := 'Global Log Settings' + crlf + ReportLoggingStatus;
  ISIndyUtilsException(Self, LogStart);

  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, True);

  Sleep(1000); // before cleanup starts
  If FCleanupThread <> nil then
    FCleanupThread.Resume;
{$IFDEF Debug}
  AllowNoPersonality := True;
  // Allows connections using cNoPersonality without
  // knowledge of cApplicationHandshakeCodeString
{$ENDIF}
  TSingletonObjTimeSpanRecording.RecordObjectOnCreate(Self);
end;

function TIsIndyApplicationServer.CurrentAddressDetails: String;
var
  BObj: TBusyCheckCalls;
  i: Integer;
begin
  try
    Result := '';
    if FCurrentAddresses = nil then
      Exit;
    if FCurrentAddresses.Count < 1 then
      Exit;

    for i := 0 to FCurrentAddresses.Count - 1 do
    begin
      if FCurrentAddresses.Objects[i] is TBusyCheckCalls then
      begin
        BObj := TBusyCheckCalls(FCurrentAddresses.Objects[i]);
        Result := Result + BObj.TextData + crlf;
      End
      Else
        Result := Result + FCurrentAddresses[i] + crlf;
    end;
  Except
    On E: Exception do
    Begin
      WritelnIfPossible('CurrentAddressDetails Exception ' + E.Message);
      ISIndyUtilsException(Self, E, '#CurrentAddressDetails')
    End;
  end;
end;

function TIsIndyApplicationServer.CurrentAddresses: TStringList;
begin
  if FCurrentAddresses = nil then
  begin
    FCurrentAddresses := TStringList.Create;
    FCurrentAddresses.Sorted := True;
    FCurrentAddresses.OwnsObjects := True;
    // TBusyCheckCalls
  end;
  Result := FCurrentAddresses;
end;

function TIsIndyApplicationServer.CurrentlyReset: Boolean;
begin
  Result := FResetStartTime > now;
end;

destructor TIsIndyApplicationServer.Destroy;
begin
  Try
    Try
      ApplicationFlagThreadMsg('Destroying Server');

      if FCleanupThread <> nil then
        Try
          FCleanupThread.FOwner := nil;
          FCleanupThread.Terminate;
        Except
          On E: Exception do
            ISIndyUtilsException(Self, E, 'Destroy 2');
        End;

      if Active then
        Active := false; // shutdown
      if Assigned(GlobalCountOfComsObjectTypes) then
        GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);
      ISIndyUtilsException(Self, 'Start Destroy Server: ');
      ISIndyUtilsException('', ServerDetailsAsText);
    Except
      On E: Exception do
        ISIndyUtilsException(Self, E, 'Destroy 1');
    End;

    try
      inherited; // will drop contexts and they own sessions
    except
      On E: Exception do
        ISIndyUtilsException(Self, E, 'Destroy.Inherited');
    end;
    // inherited;    //will drop contexts and they own sessions
    // DropAllCurrentSessions;

    FCurrentSessionObjects.Free;
    ISIndyUtilsException(Self, 'fCurrentSessionObjects.Free;');
    FListOfRegConnections.Free;
    ISIndyUtilsException(Self, 'FListOfRegConnections.Free;');
    FCurrentAddresses.Free; // Owns Objects;
    ISIndyUtilsException(Self, 'fCurrentAddresses.Free;');
    FLogList.Free;
    FApSrvrListLock.Free;
    FBusyLock.Free;
    ISIndyUtilsException(Self, 'FBusyLock.Free;');

  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TIsIndyApplicationServer.Destroy');
  end;

  if FCleanupThread <> nil then
    Sleep(1000);
  TSingletonObjTimeSpanRecording.RecordObjectLifeTimeOnDestroy(Self,
    FSrvrStopWatch.Elapsed);
end;

procedure TIsIndyApplicationServer.DropAllCurrentSessions;
Var
  ThisObj: TISIndyTCPSvrSession;
  LCurSessionObjs: TList;
  LoopChk: Integer;
begin
  if FCurrentSessionObjects <> nil then
    If Not ApSrvrListLockTryEnter('DropAllCurrentSessions', 2) Then
      Exit;

  // else
  Try
    LoopChk := 1000;
    LCurSessionObjs := FCurrentSessionObjects.LockList;
    Try
      While (LCurSessionObjs.Count > 0) and (LoopChk > 0) do
        Try
          Dec(LoopChk);
          if TObject(LCurSessionObjs[0]) is TISIndyTCPSvrSession then
            ThisObj := TISIndyTCPSvrSession(LCurSessionObjs[0])
          else
            ThisObj := nil;
          Try
            if ThisObj <> nil then
              ApplicationFlagThreadMsg('DropAllCurrentSessions Object=' +
                ThisObj.TextID)
            else
              ApplicationFlagThreadMsg('DropAllCurrentSessions nil Object');
          Except
            On E: Exception do
              ISIndyUtilsException(Self, E, 'DropAllCurrentSessions');
          End;

          LCurSessionObjs[0] := nil;
          LCurSessionObjs.Delete(0);

          if ThisObj <> nil then
          begin
            // while testing
            // if GblRptRegConnectiononSrvr then
            ApplicationFlagThreadMsg('Dropping session ' + ThisObj.PortId);
            ThisObj.CloseConnection;
            ThisObj := nil;
            FreeAndNil(ThisObj); // Freed in CloseConnection
          end;
          Sleep(100);
        Except
          On E: Exception do
            ISIndyUtilsException(Self, E, 'DropAllCurrentSessions');
        End;
    Finally
      FCurrentSessionObjects.UnlockList;
    end;
  finally
    ApSrvrListLockRelease('DropAllCurrentSessions');
  end;
  FreeAndNil(FCurrentSessionObjects);
end;

procedure TIsIndyApplicationServer.DropRegConnection
  (AConnection: TISIndyTCPSvrSession);
Var
  Index: Integer;
  Id: AnsiString;
  RegObjs: TStringList;

begin
  if AConnection = nil then
    Exit;
  Id := AConnection.PortId + ' :: ' + AConnection.FRegisteredAs;
  // while testing
  // if GblRptRegConnectiononSrvr then
  ApplicationFlagThreadMsg('DropRegConnection:: ' + Id);

  If FListOfRegConnections = nil Then
    Exit;

  If ApSrvrListLockTryEnter('DropRegConnection', 2) then
    Try
      RegObjs := FListOfRegConnections.Lock;
      Try
        Index := RegObjs.IndexOfObject(AConnection);
        if Index >= 0 then
        begin
          // while testing
          // if GblRptRegConnectiononSrvr then
          ApplicationFlagThreadMsg('DropRegConnection Index=' + IntToStr(Index)
            + ' :: ' + Id);
          RegObjs.Delete(Index);
        end;
      finally
        FListOfRegConnections.Unlock;
      end;
    Finally
      ApSrvrListLockRelease('DropRegConnection');
    end;
end;

procedure TIsIndyApplicationServer.DropSession(ASession: TISIndyTCPSvrSession);
Var
  Idx: Integer;
  SessionContext: TIsIndyTCPServerContext;
  LCurSessionObjs: TList;
  LRegObjs: TStringList;
begin
  // While Testing
  if ASession = nil then
    ApplicationFlagThreadMsg(Self, 'DropSession ASession=nil');

  if ASession = nil then
    Exit;

  Try
    if ASession.FServerObject = Self then
      ASession.FServerObject := nil
    Else
      ApplicationFlagThreadMsg('Wrong Server in Drop Session:');

    If ApSrvrListLockTryEnter('DropSession', 2) then
      Try
        SessionContext := ASession.FServerContext;
        if SessionContext <> nil then
        Begin
          SessionContext.FSessionClosing := True;
          If SessionContext.FTcpRef <> ASession then
            ApplicationFlagThreadMsg('Wrong Context in Drop Session:');
          // Else
          // SessionContext.FTcpRef := nil;
        End
        Else
          ApplicationFlagThreadMsg('No Context in Drop Session:');

        ASession.FServerContext := nil;

        DropRegConnection(ASession);
        Dec(FServerTcpSessions);

        if FCurrentSessionObjects = nil then
          Exit;

        LCurSessionObjs := FCurrentSessionObjects.LockList;
        try
          if FListOfRegConnections <> nil then
            LRegObjs := FListOfRegConnections.Lock
          else
            LRegObjs := nil;
          try
            if LCurSessionObjs = nil then
              Idx := -1
            Else
              Idx := LCurSessionObjs.IndexOf(ASession);
            if Idx < 0 then
              ISIndyUtilsException(Self, 'Session not found')
            else
            begin
              LCurSessionObjs[Idx] := nil;
              LCurSessionObjs.Delete(Idx);
            end;

            if LRegObjs = nil then
              Idx := -1
            Else
              Idx := LRegObjs.IndexOfObject(ASession);
            // While Testing

            if Idx < 0 then
              // While Testing
              ApplicationFlagThreadMsg
                ('DropSession FListOfRegConnections Index < 0')
            else if Idx >= LRegObjs.Count then
              // While Testing
              ApplicationFlagThreadMsg
                ('DropSession FListOfRegConnections Index ' + IntToStr(Idx) +
                ' Exceeds ' + IntToStr(LRegObjs.Count))
            else
            begin
              LRegObjs.Objects[Idx] := nil;
              LRegObjs.Delete(Idx);
            end;
          Finally
            if FListOfRegConnections <> nil then
              FListOfRegConnections.Unlock
          end;
        Finally
          FCurrentSessionObjects.UnlockList;
        end;
      Finally
        ApSrvrListLockRelease('DropSession');
      end;
  Except
    On E: Exception do
    begin
      WritelnIfPossible('Exception in Drop Session:' + E.Message);
      ISIndyUtilsException(Self, E, ' Drop Session');
    end;
  end;
end;

function TIsIndyApplicationServer.GetMaxCallsPerMinute: Integer;
begin
  if FTimeLimitFor80Calls.Ticks < FTimeLimitFor80Calls.TicksPerMillisecond then
    FTimeLimitFor80Calls := TTimeSpan.FromMilliseconds(2);
  Result := Round(80 / FTimeLimitFor80Calls.TotalMinutes);
end;

function TIsIndyApplicationServer.GetRegConnectionFor(ARegString: AnsiString)
  : TISIndyTCPBase;
Var
  Inx: Integer;
  LRegList: TStringList;
begin
  ApplicationFlagThreadMsg('GetRegConnectionFor ' + ARegString);
  Result := nil;
  Try
    LRegList := ListOfRegConnections.Lock;
    try
      If LRegList.Find(ARegString, Inx) then
        Result := LRegList.Objects[Inx] as TISIndyTCPBase;
    finally
      FListOfRegConnections.Unlock;
    end;
  Except
    Result := nil;
  end;
end;

function TIsIndyApplicationServer.GetSessionByCallingPort(APeerPortNo: Integer)
  : TISIndyTCPSvrSession;
Var
  i: Integer;
  Obj: TObject;
  ThisObj: TISIndyTCPSvrSession;
  LCurList: TList;
begin
  Result := nil;
  if APeerPortNo < 1 then
    Exit;
  if FCurrentSessionObjects = nil then
    Exit;
  i := 0;
  if ApSrvrListLockTryEnter('GetSessionByCallingPort', 2) then
    try
      LCurList := FCurrentSessionObjects.LockList;
      try
        while (i < LCurList.Count) and (Result = nil) do
        begin
          Obj := LCurList[i];
          if Obj is TISIndyTCPSvrSession then
          Begin
            ThisObj := TISIndyTCPSvrSession(Obj);
            if ThisObj.Port = APeerPortNo then
              Result := ThisObj;
          end;
          Inc(i);
        end;
      Finally
        FCurrentSessionObjects.UnlockList;
      end
    finally
      ApSrvrListLockRelease('GetSessionByCallingPort');
    end
  Else
  begin
    WritelnIfPossible('GetSessionByCallingPort no Lock:Port=' +
      IntToStr(APeerPortNo));
    ISIndyUtilsException(Self, 'GetSessionBy#CallingPort no Lock:Port=' +
      IntToStr(APeerPortNo));
  end
end;

procedure TIsIndyApplicationServer.IsIdTCPSvrSessionExecute
  (AContext: TIdContext);
Var
  LContext: TIsIndyTCPServerContext;
  LConnection: TIdTCPConnection;
  TcpCtxSession: TISIndyTCPSvrSession;
begin
  Try
    if AContext = nil then
      Exit;
    TcpCtxSession := nil;
    LConnection := nil;
    LContext := LocalContext(AContext);
    Try
      if LContext = nil then
      begin
        ApplicationFlagThreadMsg
          ('IsIdTCPSvrSessionExecute Nil Local Context ACtxt Type=');
        ISIndyUtilsException(Self,
          '#IsIdTCPSvrSessionExecute Nil Local Context');
        Exit;
      end
      else
        TcpCtxSession := LContext.RawTcpRef;

      if TcpCtxSession = nil then
      begin
        LContext.FSessionClosing := True;
        ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Nil TcpCtx');
        Exit;
      end;

      LConnection := LContext.Connection;
      if TcpCtxSession.FConnection <> LConnection then
      begin
        // 14:46:02 TIsIndyApplicationServer::IsIdTCPSvrSessionExecute Wrong TcpCtx ::Svr:1559 Disconnected <192.168.20.6>:50664        LContext.FSessionClosing := True;
        ApplicationFlagThreadMsg('IsIdTCPSvrSessionExecute');
        if LConnection = nil then
          ISIndyUtilsException(Self,
            '#IsIdTCPSvrSessionExecute Context Nil Connection')
        else if TcpCtxSession = nil then
          ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Wrong TcpCtx ::'
            + ' No TcpCtxSession.TextID')
        else
          ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Wrong TcpCtx ::'
            + TcpCtxSession.TextID);
      end;

      if (LConnection = nil) or (TcpCtxSession = nil) then
      Begin
        LContext.FSessionClosing := True;
        Exit;
      end;

      if LConnection <> nil then
        if LConnection.Connected then
        begin
          if FResetStartTime > 0 then
            if FResetStartTime < now then
              FResetStartTime := 0.0
            else
            begin
              ISIndyUtilsException(Self, '# Closing ResetStartTime=' +
                FormatDateTime('dd hh:nn:ss.zzz', FResetStartTime));
              LContext.FSessionClosing := True;
              Exit;
            end;

          if TcpCtxSession <> nil then
            If not TcpCtxSession.ProcessNextSrvrTransaction Then
            Begin
              if GblLogAllChlOpenClose then
                ApplicationFlagThreadMsg(Self, TcpCtxSession.PortId +
                  '# End Session');
              LContext.FSessionClosing := True;
              // TcpCtxSession.CloseIsObjGracefully;
            end;
        end;
    Except
      On E: Exception do
      Begin
        Try
          ISIndyUtilsException(Self, E, 'Is#IdTCPSvrSessionExecute');
          ApplicationFlagThreadMsg('IsIdTCPSvrSessionExecute Exception ::' +
            E.Message);
          if LContext <> nil then
            LContext.FSessionClosing := True;
        Except
          On ee: Exception do
            try
              ISIndyUtilsException(Self, ee,
                'IsIdTCPSvrSessionExecute #Double Exception');
            Except
            end;
        end;
      end;
    End;
  Except
    On eo: Exception do
      try
        ISIndyUtilsException(Self, eo,
          'IsIdTCPSvrSessionExecute #Outer Loop Exception');
        ApplicationFlagThreadMsg
          ('IsIdTCPSvrSessionExecute #Outer Loop Exception::' + eo.Message);
      Except
      end;
  End;
End;

procedure TIsIndyApplicationServer.ISIdSrvThrdException(AContext: TIdContext;
  AException: Exception);
Var
  s: string;
begin
  if AContext is TIsIndyTCPServerContext then
    s := TIsIndyTCPServerContext(AContext).CtxTextId + ':: Exception =' +
      AException.Message
  Else
    s := 'ISIdSrvThrdException =' + AException.Message;
  ApplicationFlagThreadMsg(s);
  raise EExceptionIsComsNotExpected.Create(s);
end;

procedure TIsIndyApplicationServer.IsIdTCPSrvrConnect(AContext: TIdContext);
Var
  LContext: TIsIndyTCPServerContext;
  ThisSession: TISIndyTCPSvrSession;
begin
  // Runs in TIdListenerThread (One per ListenerPort IP4,IP6)
  // Must exit before further connections can open
  Try
    ApplicationFlagThreadMsg('Connect to server');
    LContext := LocalContext(AContext);

    LContext.ReleaseOldRef;
    ThisSession := LContext.TcpRef;
    CheckBusyOnConnect(LContext);

    ThisSession.FServerObject := Self;
    Inc(FServerTcpSessions);
    ThisSession.OnAnsiStringAction := OnSessionAnsiStringAction;
    ThisSession.OnStringAction := OnSessionStringAction;
    ThisSession.OnSimpleRemoteAction := OnSessionSimpleRemoteAction;
    // while testing
    // if GblRptRegConnectiononSrvr then
    ApplicationFlagThreadMsg(ThisSession.PortId + ' On Connect: : ');
    // while testing
    ApplicationFlagThreadMsg(ThisSession.PortId + ' Confirm Scheduler Thread');

    if FResetStartTime > 0.01 then
      if FResetStartTime > now then
        FResetStartTime := 0.0
      else
      Begin
        ISIndyUtilsException(Self, LContext.FTcpRef.TextID +
          '# Failed Connect due ResetStartTime');
        LContext.FSessionClosing := True;
        // accept no calls in reset period;
        Exit;
      End;

    if FResetStartTime < 0.001 then
      If ThisSession.AcceptStart then
      Begin
        if GblLogAllChlOpenClose then
          ApplicationFlagThreadMsg(LContext.FTcpRef.TextID + ' Run Channel');
      end
      else
      Begin
        ApplicationFlagThreadMsg(LContext.FTcpRef.TextID + ' Failed Connect');
        LContext.FSessionClosing := True;
      end;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'IsIdTCPSrvrConnect');
      ApplicationFlagThreadMsg('Connect to server exception');
    end;
  end;
end;

function TIsIndyApplicationServer.LinkStatusAsResponse(ACommand: AnsiString;
  ASession: TISIndyTCPSvrSession): AnsiString;
{ sub } Function CoupledTogether(AThis, AThat: TISIndyTCPSvrSession): Boolean;
  begin
    Result := false;
    if AThis = AThat then
      Exit;
    if AThis = nil then
      Exit;
    if AThat = nil then
      Exit;
    if AThis.FCoupledSession = nil then
      If AThat.FCoupledSession = AThis then
        ISIndyUtilsException(Self, 'AThis Not Coupled ' + AThis.TextID + '<>' +
          AThat.TextID)
      else
        Exit;

    if AThat.FCoupledSession = nil then
      If AThis.FCoupledSession = AThis then
        ISIndyUtilsException(Self, 'AThat Not Coupled ' + AThis.TextID + '<>' +
          AThat.TextID)
      else
        Exit;

    if AThis.FCoupledSession = AThat then
      if AThat.FCoupledSession = AThis then
        Result := True
      else
        ISIndyUtilsException(Self, 'Not CoupledTogether ' + AThis.TextID + '<>'
          + AThat.TextID);
  end;

Var
  // Linked, AllOk, BothCoupled, Together: Boolean;
  ThisPort, ThatPort: Integer;
  RegObj, ThisPortObj, ThatPortObj: TISIndyTCPSvrSession;
  LinkToReg, ThisReg, ThatReg: AnsiString;
  Ary: TArrayOfAnsiStrings;
  LenAry, i, ThisRegIdx: Integer;
  LRegConLst: TStringList;

begin
  Try
    Result := cIsLinkedOnServer + 'CE#'; // CoupleError
    if ASession = nil then
      ApplicationFlagThreadMsg('LinkStatusAsResponse Nil ASession')
    Else
      ApplicationFlagThreadMsg('LinkStatusAsResponse ' + ASession.PortId);

    ThisReg := '<>';
    ThatReg := '<>';
    ThisPort := 0;
    ThatPort := 0;
    if Pos(cIsLinkedOnServer, ACommand) <> 1 then
      Exit
    Else
    Begin
      Ary := GetAnsiArrayFromString(ACommand, '#', false, false, false);
      // cIsLinkedOnServer(0),ThisPort(1),ThatPort(2),Ref(3) after # in Refr
      LenAry := Length(Ary);
      Case LenAry of
        0:
          Exit;
        1:
          Begin
            if ASession <> nil then
              if ASession.FCoupledSession = nil then
                Result := cIsLinkedOnServer + 'CN#' // NullCouple,
              else if ASession.FCoupledSession.FCoupledSession = nil then
              begin
                Result := cIsLinkedOnServer + 'CE#'; // CoupleError
                ISIndyUtilsException(Self, 'Single Couple error::' +
                  ASession.TextID + '::Reg=' + ASession.FRegisteredAs);
              end
              Else if ASession.FCoupledSession.FCoupledSession = ASession then
                Result := cIsLinkedOnServer + 'CK#' + ASession.FRegisteredAs;
            Exit;
          End;
        2, 3:
          Begin
            ThisPort := StrToIntDef(Ary[1], 0);
            if LenAry < 3 then
              ThatPort := 0
            else
              ThatPort := StrToIntDef(Ary[2], 0);
            LinkToReg := '';
          end;
        4, 5, 6, 7, 8, 9: // allows for '#' in link reg
          Begin
            ThisPort := StrToIntDef(Ary[1], 0);
            ThatPort := StrToIntDef(Ary[2], 0);
            LinkToReg := Ary[3];
            i := 4;
            while i < LenAry do
            begin
              LinkToReg := LinkToReg + '#' + Ary[i];
              Inc(i);
            end;
          end;
      end;

      if ASession <> nil then
        if FCurrentSessionObjects = nil then
          ISIndyUtilsException(Self, 'Session Connected =' + ASession.TextID +
            ' but no fCurrentSessionObjects')
        Else
          // ThisSessionIdx := fCurrentSessionObjects.IndexOf(ASession);
            ;
      ThisRegIdx := -1;
      LRegConLst := ListOfRegConnections.Lock;
      try
        if LinkToReg <> '' then
          ThisRegIdx := LRegConLst.IndexOf(LinkToReg);
        LinkToReg := '<' + LinkToReg + '>';
        RegObj := nil;
        if ThisRegIdx < 0 then
          // do nothing
        else if LRegConLst.Objects[ThisRegIdx] is TISIndyTCPSvrSession then
          RegObj := TISIndyTCPSvrSession(LRegConLst.Objects[ThisRegIdx]);
      Finally
        FListOfRegConnections.Unlock
      end;

      ThisPortObj := GetSessionByCallingPort(ThisPort);
      if ThisPortObj <> nil then
        ThisReg := '<' + ThisPortObj.FRegisteredAs + '>';
      ThatPortObj := GetSessionByCallingPort(ThatPort);
      if ThatPortObj <> nil then
        ThatReg := '<' + ThatPortObj.FRegisteredAs + '>';
      // (CoupleError,NullCouple,ThisPortExists,ThatPortExists,ThisPortCoupled,ThatPortCoupled,BothCoupled,CoupledTogether,CoupleLinkOK);
      Result := cIsLinkedOnServer + 'CE#';
      if RegObj = nil then
      begin
        if CoupledTogether(ThisPortObj, ThatPortObj) then
          Result := cIsLinkedOnServer + 'CT#' + ThisReg + ThatReg
        else
        begin
          if ThisPortObj <> nil then
          Begin
            Result := cIsLinkedOnServer + 'NI#' + ThisReg; // ThisPortExists
            if ThisPortObj.FCoupledSession <> nil then
              Result := cIsLinkedOnServer + 'CI#' + ThisReg;
            // ThisPortCoupled
            if ThatPortObj = nil then
              Exit;
            if ThatPortObj.FCoupledSession <> nil then
              if ThatPortObj = ThisPortObj then
                Exit
              else if ThisPortObj.FCoupledSession <> nil then
                Result := cIsLinkedOnServer + 'CB#' + ThisReg + ThatReg
                // BothCoupled
              Else
                Result := cIsLinkedOnServer + 'CA#' + ThatReg;
            // ThatPortCoupled
          end
          else if ThatPortObj <> nil then
            if ThatPortObj.FCoupledSession <> nil then
              Result := cIsLinkedOnServer + 'CA#' + ThatReg // ThatPortCoupled
            Else
              Result := cIsLinkedOnServer + 'NA#' + ThatReg; // ThatPortExists
        end
      end
      else
      Begin
        // (CoupleError,RegButNoLinks,NullCouple,ThisPortExists,ThatPortExists,ThisPortCoupled,ThatPortCoupled,BothCoupled,CoupledTogether,CoupleLinkOK);
        Case RegObj.LinkedTo(ThisPort, ThatPort) of
          0:
            Result := cIsLinkedOnServer + 'RO#' + LinkToReg; // RegButNoLinks
          5, 6:
            Result := cIsLinkedOnServer + 'CO#' + LinkToReg; // CoupleLinkOK
          1, 2:
            Result := cIsLinkedOnServer + 'RO#' + LinkToReg; // RegButNoLinks
          3:
            Result := cIsLinkedOnServer + 'CI#' + LinkToReg + ThisReg;
          // ThisPortCoupled
          4:
            Result := cIsLinkedOnServer + 'CA#' + LinkToReg + ThatReg;
          // ThatPortCoupled
        end;
      end
    end;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'Link#StatusAsResponse Result=' + Result);
      ApplicationFlagThreadMsg('LinkStatusAsResponse');
      Result := cIsLinkedOnServer + 'CE#' + E.Message;
    end;
  end;
end;

function TIsIndyApplicationServer.ListOfRegConnections: TIdThreadSafeStringList;
Var
  LSList: TStringList;
begin
  if FListOfRegConnections = nil then
  Begin
    FListOfRegConnections := TIdThreadSafeStringList.Create;
    LSList := FListOfRegConnections.Lock;
    try
      LSList.Sorted := True;
      LSList.Duplicates := dupError;
    finally
      FListOfRegConnections.Unlock;
    end
  end;
  Result := FListOfRegConnections;
end;

procedure TIsIndyApplicationServer.LoadServerIniData;
Var
  IdleSeconds, MxCallsPmin: Integer;
  IniFile: TIniFile;
  IniFileName: String;
begin
  IniFileName := IniFileNameFromExe;
  if GlobalDefaultFileAccessBase = '' then
    if FileExists(IniFileName) then
    Begin
      IniFile := TIniFile.Create(IniFileName);
      try
        GlobalDefaultFileAccessBase := IniFile.ReadString('Files',
          'FileAccessBase', '');
        if GlobalDefaultFileAccessBase = '' then
          IniFile.WriteString('Files', 'FileAccessBase', '');
        if DefaultPort < 1 then
          DefaultPort := IniFile.ReadInteger('TCP', 'PORT', 0);
        IdleSeconds := IniFile.ReadInteger('TCP', 'IdleTimeInSeconds', -1);
        if IdleSeconds < 0 then
        Begin
          IdleSeconds := 60 * 5;
          IniFile.WriteInteger('TCP', 'IdleTimeInSeconds', IdleSeconds);
        end;
        FIdleTimePermitted := TTimeSpan.FromSeconds(IdleSeconds);
        MxCallsPmin := IniFile.ReadInteger('TCP', 'MaxCallsPerMin', -1);
        if MxCallsPmin > 0 then
          MaxCallsPerMinute := MxCallsPmin
        else if MxCallsPmin < 0 then
          IniFile.WriteInteger('TCP', 'MaxCallsPerMin', 0);
      finally
        IniFile.Free;
      end;
    end;
end;

function TIsIndyApplicationServer.LocalContext(AContext: TIdContext)
  : TIsIndyTCPServerContext;
begin
  if AContext = nil then
    Result := nil
  else if AContext is TIsIndyTCPServerContext then
    Result := TIsIndyTCPServerContext(AContext)
  Else
    raise Exception.Create('Error AContext is Not TIsIndyTCPServerContext');
end;

function TIsIndyApplicationServer.ReadLogMessage: String;
begin
  if FLogList = nil then
    Result := ''
  Else
  Begin
    If Not ApSrvrListLockTryEnter('ReadLogMessage', 2) Then
    Begin
      Inc(FLogsMissed);
      Exit;
    end;

    Try
      Result := FLogList.Text;
      if FLogsMissed > 0 then
        Result := Result + #13#10 + 'Missed msgs=' + IntToStr(FLogsMissed);
      FLogList.Clear;
      FLogsMissed := 0;
    Finally
      ApSrvrListLockRelease('ReadLogMessage');
    End;
  end;

  ConfirmRegisteredConnections;
  If FDoNextCloseEvent < now then
    CloseInactiveSessions;
end;

function TIsIndyApplicationServer.RemotePortRegAsString(ARegNo,
  AConnectNo: Integer): AnsiString;
Var
  RegOb, ConnectObj: TISIndyTCPSvrSession;
  No1, No2: Integer;
  RegNam: AnsiString;
  LRegConList: TStringList;
  LConObjLst: TList;
begin
  RegOb := nil;
  ConnectObj := nil;
  Result := '##';
  No1 := 0;
  No2 := 0;
  try
    if FCurrentSessionObjects = nil then
      Exit;
    // No Connections
    If (FListOfRegConnections <> nil) then
    Begin
      LRegConList := FListOfRegConnections.Lock;
      Try
        If (ARegNo > -1) and (ARegNo < LRegConList.Count) then
          if LRegConList.Objects[ARegNo] is TISIndyTCPSvrSession then
            RegOb := TISIndyTCPSvrSession(LRegConList.Objects[ARegNo]);
      Finally
        FListOfRegConnections.Unlock
      End;
    End;
    LConObjLst := FCurrentSessionObjects.LockList;
    try
      if AConnectNo >= LConObjLst.Count then
        AConnectNo := LConObjLst.Count - 1;
      if (AConnectNo > -1) then
        if TObject(LConObjLst[AConnectNo]) is TISIndyTCPSvrSession then
          ConnectObj := LConObjLst[AConnectNo];
    finally
      FCurrentSessionObjects.UnlockList;
    end;
    if (ConnectObj = nil) and (RegOb <> nil) then
      ConnectObj := RegOb.FCoupledSession as TISIndyTCPSvrSession;

    if (ConnectObj <> nil) then
      No2 := ConnectObj.Port;
    if (RegOb <> nil) then
    Begin
      No1 := RegOb.Port;
      RegNam := RegOb.FRegisteredAs;
    end;
    if No1 = No2 then
      Inc(No2);
    Result := IntToStr(No1) + '#' + IntToStr(No2) + '#' + RegNam;
  except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'RemotePortAsString');
  end;
end;

function TIsIndyApplicationServer.ResetSvr(AData: AnsiString): AnsiString;
Var
  RestartSrvAtTime: TDateTime;
  i: Integer;
  Chnl: TISIndyTCPSvrSession;
  LListOfReg: TStringList;
begin
  ISIndyUtilsException(Self, ' #ResetSvr');
  RestartSrvAtTime := now + 3 / 24 / 60; // hold reject reset for one minute;
  if FListOfRegConnections <> nil then
    if ApSrvrListLockTryEnter('ResetSvr', 5) then
      Try
        LListOfReg := FListOfRegConnections.Lock;
        Try
          for i := LListOfReg.Count - 1 Downto 0 do
            Try
              if LListOfReg.Objects[i] is TISIndyTCPSvrSession then
              Begin
                Chnl := LListOfReg.Objects[i] as TISIndyTCPSvrSession;
                if Chnl.FCoupledSession <> nil then
                  Chnl.FCoupledSession.CloseIsObjGracefully;
                Chnl.CloseIsObjGracefully;
              end;
            Except
              On E: Exception do
                ApplicationFlagThreadMsg('ResetSvr Exception:' + E.Message);
            end;
        Finally
          FListOfRegConnections.Unlock;
        end;
      Finally
        ApSrvrListLockRelease('ResetSvr');
      end;
  Result := 'Suspending Server until ' + FormatDateTime('dd hh:mm:ss',
    RestartSrvAtTime);
  ISIndyUtilsException(Self, '#' + Result);
  ApplicationFlagThreadMsg(Result);
  FResetStartTime := RestartSrvAtTime;
end;

function TIsIndyApplicationServer.ServerDetailsAsText: AnsiString;
{ Sub } Function IPVersionStr(AVersionType: TIdIPVersion): String;
  Begin
    Result := '';
    case AVersionType of
      Id_IPv4:
        Result := 'IPv4';
      Id_IPv6:
        Result := 'IPv6';
    end;
  end;

Var
  i: Integer;
begin
  Result := '';
  Try
    if Bindings <> nil then
      for i := 0 to Bindings.Count - 1 do
        Result := Result + 'Listening on Port ' + GetThisHostIPAddressViaIndy +
          ':' + IntToStr(Bindings[i].Port) + ' ' +
          IPVersionStr(Bindings[i].IPVersion) + #13#10;
    Result := Result + 'Idle Time Permitted =' +
      FIdleTimePermitted.ToString + #13#10;
    Result := Result + 'Maximum Calls Per Minute is ' +
      IntToStr(MaxCallsPerMinute) + #13#10;
    if FCurrentAddresses <> nil then
      Result := Result + CurrentAddressDetails + #13#10;

    if Contexts <> nil then
      Result := Result + 'Current Sessions =' +
        IntToStr(Contexts.Count) + #13#10;
    Result := Result + 'Current Server Context Objects =' +
      IntToStr(GlobalContextCount) + #13#10;
    Result := Result + 'Current Server TCP Objects =' +
      IntToStr(FServerTcpSessions) + #13#10;
    Result := Result + #13#10 + 'Connection Details' + #13#10 +
      AllConnectionsAsText;
  Except
    On E: Exception do
    Begin
      WritelnIfPossible('ServerDetailsAsText Exception ' + E.Message);
      ISIndyUtilsException(Self, E, '#ServerDetailsAsText')
    End;
  end;
end;

procedure TIsIndyApplicationServer.SetMaxCallsperminute(AValue: Integer);
begin
  FTimeLimitFor80Calls := TTimeSpan.FromMinutes(80 / AValue);
end;

procedure TIsIndyApplicationServer.Shutdown;
Var
  ClosingTimer: TStopwatch;
begin
  try
    ClosingTimer := TStopwatch.StartNew;
    FServerClosing := True;
    inherited;
    ISIndyUtilsException(Self, '# Time To Shutdown =' +
      ClosingTimer.Elapsed.ToString);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'On ShutDown');
  End;
end;

{ TIsIndyTCPServerContext }

{$IFNDEF  SuppressIPMetering}

procedure TIsIndyTCPServerContext.CalAverageProcessTime(AProcessTime,
  ADownTime: TTimeSpan);
Var
  AThisProcessTime, AThisDownTime: Double;
begin
  AThisProcessTime := AProcessTime.Ticks / 10000;
  AThisDownTime := ADownTime.Ticks / 10000;
  Inc(FNoProcTmSamples);
  if AThisProcessTime > FmaxProcTm then
    FmaxProcTm := AThisProcessTime;
  CalNewDoubleAverageAndSumOfSquares(AThisProcessTime, FAverageProcTm,
    FAverageProcSumSqs, FNoProcTmSamples);
  CalNewDoubleAverageAndSumOfSquares(AThisProcessTime, FAverageProcTm,
    FAverageProcSumSqs, FNoProcTmSamples);
  if AThisDownTime > FmaxDnTm then
    FmaxDnTm := AThisDownTime;
  CalNewDoubleAverageAndSumOfSquares(AThisDownTime, FAverageDnTm,
    FAverageDnSumSqs, FNoProcTmSamples);
end;

function TIsIndyTCPServerContext.ContextResponseTimesText: AnsiString;
Var
  SD: Double;
  RsltD: string;

begin
  SD := CalDoubleStdDevFromSumOfSquares(FAverageProcSumSqs, FNoProcTmSamples);

  if SD > 0.00000001 then
    Result := ' Context ' + FormatFloat('###0.000 mSecs', FAverageProcTm) +
      ' Max ' + FormatFloat('(0.000)', FmaxProcTm) + ' Min ' +
      FormatFloat('(0.00000)', FminProcTm) + ' SD ' +
      FormatFloat('(0.00000)', SD)
  else
    Result := ' Context ' + FormatFloat('###0.000 mSecs', FAverageProcTm) +
      ' Max ' + FormatFloat('(0.000)', FmaxProcTm) + ' Min ' +
      FormatFloat('(0.00000)', FminProcTm);
  Result := Result + ' Samples (' + IntToStr(FNoProcTmSamples) + ')';

  if FmaxDnTm < 0.0001 then
    Exit;

  SD := CalDoubleStdDevFromSumOfSquares(FAverageProcSumSqs, FNoProcTmSamples);

  if SD > 0.00000001 then
    RsltD := ' Cxt Dwn ' + FormatFloat('###0.000 mSecs', FAverageDnTm) + ' Max '
      + FormatFloat('(0.000)', FmaxDnTm) + ' Min ' +
      FormatFloat('(0.0000000000)', FminDnTm) + ' SD ' +
      FormatFloat('(0.0000000000)', SD)
  else
    RsltD := ' Cxt Dwn ' + FormatFloat('###0.000 mSecs', FAverageDnTm) + ' Max '
      + FormatFloat('(0.000)', FmaxDnTm) + ' Min ' +
      FormatFloat('(0.0000000000)', FminDnTm);
  Result := Result + #13#10 + RsltD;

end;
{$ENDIF}

constructor TIsIndyTCPServerContext.Create(AConnection: TIdTCPConnection;
  AYarn: TIdYarn; AList: TIdContextThreadList);
begin
  FContextStopWatch := TStopwatch.StartNew;
  if FContextStopWatch.IsHighResolution then
    // FContextStopWatch.Start
  else
    ISIndyUtilsException(Self, 'Not FContextStopWatch.IsHighResolution');
{$IFNDEF  SuppressIPMetering}
  FLastProcessComplete := FContextStopWatch.Elapsed;
{$ENDIF}
  inherited; // added to server contexts on beforerun
  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, True);
  // While Testing
  ApplicationFlagThreadMsg('Context Create ' + '(' +
    IntToStr(LongWord(Pointer(Self))) + ') Count=' +
    IntToStr(GlobalContextCount));
  Inc(GlobalContextCount);
  TSingletonObjTimeSpanRecording.RecordObjectOnCreate(Self);
end;

function TIsIndyTCPServerContext.CtxTextId: string;
begin
  if FTcpRef <> nil then
    Result := FTcpRef.PortId
  else if Connection <> nil then
    Result := 'No TcpRef '
  else
    Result := 'No Connection';

  Result := FContextID + '>>' + Result;
end;

destructor TIsIndyTCPServerContext.Destroy;
Var
  s: String;
begin
  { New thinking September 2026
    Session is Owned by Context }
  // While Testing
  ApplicationFlagThreadMsg('Context Closing ' + CtxTextId + ' Count = ' +
    IntToStr(GlobalContextCount));
  Dec(GlobalContextCount);

  if Not FSessionClosing then
    ApplicationFlagThreadMsg('TIsIndyTCPServerContext.Destroy not closing ');

  FSessionClosing := True;
  try
    try
      TSingletonObjTimeSpanRecording.RecordObjectLifeTimeOnDestroy(Self,
        FContextStopWatch.Elapsed);
      s := ' (' + IntToStr(LongInt(Pointer(Self))) + ') ' + CtxTextId;
      // while testing
      // if GblRptRegConnectiononSrvr then
      ApplicationFlagThreadMsg('Closing Context:: ' + s);
      if FTcpRef <> nil then
        if FTcpRef.FServerContext <> nil then
          if FTcpRef.FServerContext = Self then
            FreeAndNil(FTcpRef)
          else if FTcpRef.FServerContext <> nil then
            ApplicationFlagThreadMsg
              (s + ' TIsIndyTCPServerContext.Destroy Ref not owned');

      Try
        FreeAndNil(FTcpRef);
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, s + '# FreeAndNil(FTcpRef)::' +
            CtxTextId);
      end;

      if FTcpRef <> nil then
        ApplicationFlagThreadMsg(s + ' Closing Context::FTcpRef <> nil ' + s);

      if FOwnsConnection then
        ApplicationFlagThreadMsg('Closing Context::Owned Connection=nil ' + s)
      Else
        ApplicationFlagThreadMsg('Closing Context::FConnection=nil ' + s);
    finally
      Try
        inherited;
        if FConnection <> nil then
          ApplicationFlagThreadMsg('inherited Destroy Exit FConnection <> nil')
        else
          ApplicationFlagThreadMsg('inherited Destroy End Connection');

        if FTcpRef <> nil then
          ApplicationFlagThreadMsg
            ('inherited TIsIndyTCPServerContext Destroy Exit FTcpRef <> nil')
        else
          ApplicationFlagThreadMsg
            ('inherited TIsIndyTCPServerContext Destroy Exit');

      Except
        On E: Exception do
        begin
          ApplicationFlagThreadMsg('inherited Destroy Exception ' + E.Message);
          ISIndyUtilsException(Self, E, 'inherited Destroy ::' + CtxTextId);
        end;
      end;
    end;
    if Assigned(GlobalCountOfComsObjectTypes) then
      GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Destroy ::' + CtxTextId);
  end;
end;

function TIsIndyTCPServerContext.TcpRef: TISIndyTCPSvrSession;
begin
  Try
    Result := nil;
    if FSessionClosing then
      Exit;

    if FTcpRef = nil then
    begin
      FTcpRef := TISIndyTCPSvrSession.Create(Self, FServer);
      // OnBeforeRun:=FTcpRef.BeforeContextRun;
      // While testing
      ApplicationFlagThreadMsg('Server Session Open ' + FTcpRef.TextID);
      if GblLogAllChlOpenClose then
      Begin
        ISIndyUtilsException(Self, '#Session Open ' + FTcpRef.TextID);
        // FTcpRef.LogAMessage('Session Open');
      End;
      if (FTcpRef.FConnection <> Connection) then
        raise Exception.Create('Error FTcpRef.FConnection<>Connection');
    end;
    Result := FTcpRef;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'TcpRef');
      Result := nil
    end;
  End;
end;

function TIsIndyTCPServerContext.RawTcpRef: TISIndyTCPSvrSession;
begin
  Result := nil;
  if FSessionClosing then
    Exit;
  if FTcpRef = nil then
    Exit;
  Result := FTcpRef;

  if FTcpRef <> nil then
    If FTcpRef.TcpConnection = nil then
      If FTcpRef.FServerContext = Self then
      Begin
        FTcpRef.SetConnection(Connection);
        If FServer is TIdTcpServer then
          FTcpRef.FServerObject := TIdTcpServer(FServer);
        if GblLogAllChlOpenClose then
          ISIndyUtilsException(FTcpRef, 'Session Open ');
        if (FTcpRef.FConnection <> Connection) then
          raise Exception.Create('Error FTcpRef.FServerConnext <> Self');
      end
      Else If FTcpRef.FServerContext <> nil then
        raise Exception.Create('Error FTcpRef.IOHandler<>Connection.IOHandler');
end;

procedure TIsIndyTCPServerContext.ReleaseOldRef;
begin
  Try
    // This is a new connection
    If FTcpRef <> nil then
    begin
      FreeAndNil(FTcpRef);
      ApplicationFlagThreadMsg('#ReleaseOldRef<>nil');
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '#ReleaseOldRef');
  End;
end;

function TIsIndyTCPServerContext.Run: Boolean;
// Context.OnRun := Server.DoExecute := IsIdTCPSvrSessionExecute
{$IFNDEF  SuppressIPMetering}
Var
  StartTime: TTimeSpan;
  ElapsedTimeDownTime, ElapsedProcessTime: TTimeSpan;

begin
  if FContextID = '' then
  Begin
    FContextID := '(' + IntToStr(LongWord(Pointer(Self))) + ')';
    FContextID := '[' + FContextID +
      IntToStr(TThread.CurrentThread.ThreadID) + ']';
    ApplicationFlagThreadMsg('New Context:' + CtxTextId)
  End;
  StartTime := FContextStopWatch.Elapsed;
  ElapsedTimeDownTime := StartTime.Subtract(FLastProcessComplete);
{$ELSE}
begin
{$ENDIF}
  Result := inherited Run;
  if FSessionClosing then
  Begin
    Result := false;
    ApplicationFlagThreadMsg('Context Closing >> Destroy >> ' + CtxTextId);
  End
  Else
  Begin
{$IFNDEF  SuppressIPMetering}
    ElapsedProcessTime := FContextStopWatch.Elapsed.Subtract(StartTime);
    if ElapsedProcessTime.Seconds > 50 then
      ISIndyUtilsException(Self, 'Processing Time =' + FormatFloat('###0.000',
        ElapsedProcessTime.Seconds) + ' Seconds ' + CtxTextId);

    if ElapsedTimeDownTime.Seconds > 50 then
      ISIndyUtilsException(Self, 'Process Down Time =' + FormatFloat('###0.000',
        ElapsedTimeDownTime.Seconds) + ' Seconds ' + CtxTextId);
    CalAverageProcessTime(ElapsedProcessTime, ElapsedTimeDownTime);
    FLastProcessComplete := FContextStopWatch.Elapsed;
{$ENDIF}
  end;
end;

{ TISIndyTCPSvr }
type
  LocalKeyRecord = record
    Key1, Key2: TDateTime;
  end;

function TISIndyTCPSvrSession.AcceptStart: Boolean;
  function TestConnectionData(ATestRecord: LocalKeyRecord;
    const ATestData: AnsiString): TDateTime;
  var
    CurrentKey: LocalKeyRecord;
    LocalTest: AnsiString;
  begin
    Result := 1.676669;
    Try
      CurrentKey := ATestRecord;
      LocalTest := cApplicationHandshakeCode;
{$IFDEF NEXTGEN}
      Encrypt(SizeOf(CurrentKey), @CurrentKey, Length(LocalTest),
        Pointer(LocalTest));
{$ELSE}
      Encrypt(SizeOf(CurrentKey), @CurrentKey, Length(LocalTest),
        @LocalTest[1]);
{$ENDIF}
      if CurrentKey.Key1 = CurrentKey.Key2 then
        Result := CurrentKey.Key1
      else
        Result := 1.676669;
    Except
      On E: Exception do
        ISIndyUtilsException(Self, E,
          'Accept#Start TestConnectionData ' + TextID)
    End;
  end;

Var
  LocalKey: LocalKeyRecord;
  SessionKey: TDateTime;
  TrnctType: TTCPTransactionTypes;
  SessionRandomKey, Key, ResponseData, DataToSend: AnsiString;
  // IndexState: AnsiChar;
  Trans: AnsiString;

begin
  Result := false;
  Try
    Trans := ReadATransactionRecord(TrnctType, Key);

    if Length(Trans) > SizeOf(LocalKey) then
{$IFDEF NEXTGEN}
      Trans.CopyBytesToMemory(@LocalKey, SizeOf(LocalKey));
{$ELSE}
      CopyMemory(@LocalKey, @Trans[1], SizeOf(LocalKey));
{$ENDIF}
    // two iterations of original key
    SessionKey := TestConnectionData(LocalKey, cApplicationHandshakeCode);
    if SessionKey < 2.0 then
    Begin
      if FServerObject = nil then
        ISIndyUtilsException(Self, 'Accept#Start No Server for ' + TextID)
      else if TIsIndyApplicationServer(FServerObject).AllowNoPersonality then
      Begin
        SessionKey := TestConnectionData(LocalKey, cNoPersonality);
        if SessionKey > 2.0 then
          ISIndyUtilsException(Self, 'Accept#Start from No Personality '
            + TextID);
      end;
    End;
    SessionRandomKey := RandomKey;
    if SessionKey < 2.0 then
    Begin
      ISIndyUtilsException(Self, 'Accept#Start UA ' + PortId);
      // SendError
      ResponseData := 'UA' + 'Failed Connection Decode using 1.676669';
      // no SessionRandomKey sent
    End
    Else
      ResponseData := 'DF' + SessionRandomKey;

{$IFDEF NEXTGEN}
    Encrypt(ResponseData.Length, Pointer(ResponseData), SizeOf(SessionKey),
      @SessionKey);
{$ELSE}
    Encrypt(Length(ResponseData), @ResponseData[1], SizeOf(SessionKey),
      @SessionKey);
{$ENDIF}
    ResponseData := cStartConnection + ResponseData;
    DataToSend := PackTransaction(ResponseData, ''{$IFNDEF  SuppressIPMetering}
      , false{$ENDIF});
    Write(DataToSend);
    FRandomKey := SessionRandomKey;

    Result := True;
    if Result then
      FileAccessBase := GlobalDefaultFileAccessBase;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Accept#Start ' + TextID)
  End;
end;

{ procedure TISIndyTCPSvrSession.BeforeContextRun(AContext: TIdContext);
  Var
  LServer:TIsIndyApplicationServer;
  begin
  if AContext=nil then Exit;
  if AContext <> FServerContext then
  raise EExceptionIsComsNotExpected.Create('AContext <> FServerContext');
  if FServerObject is TIsIndyApplicationServer then
  LServer:= TIsIndyApplicationServer(FServerObject)
  else
  raise EExceptionIsComsNotExpected.Create('FServerObject not TIsIndyApplicationServer');

  LServer.CheckBusyOnConnect(FServerContext);

  if LServer.FResetStartTime < 0.001 then
  If AcceptStart then
  Begin
  if GblLogAllChlOpenClose then
  ApplicationFlagThreadMsg(TextID + ' Channel Open');
  end
  else
  Begin
  ApplicationFlagThreadMsg(TextID + ' Failed Connect');
  FServerContext.FSessionClosing := True;
  end;
  end; }

{$IFNDEF  SuppressIPMetering}

procedure TISIndyTCPSvrSession.CalAveDispatchTime(ASample: TTimeSpan);
Var
  ASampleMilliSeconds: Double;
begin
  ASampleMilliSeconds := ASample.Ticks / 10000;
  Inc(FDisPatchSamples);
  if ASampleMilliSeconds > FMaxDispatchTm then
    FMaxDispatchTm := ASampleMilliSeconds;
  if (ASampleMilliSeconds < FMinDispatchTm) or (FMinDispatchTm < 0.000000001)
  then
    FMinDispatchTm := ASampleMilliSeconds;
  CalNewDoubleAverageAndSumOfSquares(ASampleMilliSeconds, FAveDispatchTm,
    FAveDisPatchSumSqs, FDisPatchSamples)
end;

procedure TISIndyTCPSvrSession.CalAveSrvReadTime(ASample: TTimeSpan);
Var
  ASampleMilliSeconds: Double;
begin
  ASampleMilliSeconds := ASample.Ticks / 10000;
  Inc(FSrvReadTmSamples);
  if ASampleMilliSeconds > FmaxSrvReadTm then
    FmaxSrvReadTm := ASampleMilliSeconds;
  if (ASampleMilliSeconds < FminSrvReadTm) or (FminSrvReadTm < 0.000000001) then
    FminSrvReadTm := ASampleMilliSeconds;
  CalNewDoubleAverageAndSumOfSquares(ASampleMilliSeconds, FAveSrvReadTm,
    FAveSrvReadSumSqs, FSrvReadTmSamples)
end;

procedure TISIndyTCPSvrSession.CalAveTransProcTime(ASample: TTimeSpan);
Var
  ASampleMilliSeconds: Double;
begin
  ASampleMilliSeconds := ASample.Ticks / 10000;
  Inc(FProcTmSamples);
  if (ASampleMilliSeconds < FminProcTm) or (FminProcTm < 0.000000001) then
    FminProcTm := ASampleMilliSeconds;
  if ASampleMilliSeconds > FmaxProcTm then
    FmaxProcTm := ASampleMilliSeconds;
  CalNewDoubleAverageAndSumOfSquares(ASampleMilliSeconds, FAveProcTm,
    FAveProcSumSqs, FProcTmSamples)
end;
{$ENDIF}

function TISIndyTCPSvrSession.CheckReadBusy: Boolean;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).CheckBusyOnPacket(Self);
  Result := Inherited; // FDecReadCount := CVLrgeBusy;
  if FDecReadCount > CVListenerBusy then
    FDecReadCount := CVListenerBusy;
end;

function TISIndyTCPSvrSession.CheckWriteBusy: Boolean;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).CheckBusyOnPacket(Self);
  Result := Inherited;
  if FDecWriteCount > CVListenerBusy then
    FDecWriteCount := CVListenerBusy;
end;

procedure TISIndyTCPSvrSession.ClearReferences;
{ New thinking September 2026
  Session is Owned by Context }
Var
  s: string;
begin
  try
    s := 'ClearReferences Thread =' + IntToStr(TThread.CurrentThread.ThreadID);
    If (FServerContext = nil) and (FConnection = nil) then
      s := s + ' All Nil >> ';

    if FServerObject is TIsIndyApplicationServer then
      TIsIndyApplicationServer(FServerObject).DropSession(Self);

    if FServerObject <> nil then
      ApplicationFlagThreadMsg('Server not deleted in drop session ' + PortId);

    if FServerContext <> nil then
    Begin
      ApplicationFlagThreadMsg('FServerContext not deleted in drop session '
        + PortId);
      FServerContext.FSessionClosing := True;
    End;

    if FServerContext <> nil then
      if FServerContext.FTcpRef = Self then
      begin
        FServerContext.FSessionClosing := True;
        if FInSessionDestroy then
          FServerContext.FTcpRef := nil;
      end;

    HandleCoupleSessionDropReferences;

    FServerContext := nil;
    FConnection := nil;
    SetConnection(FConnection);

    // while testing
    ApplicationFlagThreadMsg('ClearReferences ' + PortId);
    // if GblRptRegConnectiononSrvr then
    ISIndyUtilsException(Self, s + ' #ClearReferences');
  except
    On E: Exception do
    Begin
      WritelnIfPossible(s + ' ClearReferences Exception ' + E.Message);
      ISIndyUtilsException(Self, E, s + ' #ClearReferences');
      Exit;
    End;
  End;

  try
    if FCoupledSession <> nil then
    Begin
      if FOwnsCoupledSession then
        FreeAndNil(FCoupledSession)
      else
        FCoupledSession.FCoupledSession := nil;
    End;
    FCoupledSession := nil;
  except
    On E: Exception do
    Begin // s has thread
      WritelnIfPossible(s + ' ClearReferences 2 Exception ' + E.Message);
      ISIndyUtilsException(Self, E, s + ' #ClearReferences 2');
      Exit;
    End;
  end;
end;

procedure TISIndyTCPSvrSession.CloseConnection;
{ New thinking September 2026
  Session is Owned by Context }
begin
  FClosingTcpSocket := True;
  ApplicationFlagThreadMsg('TISIndyTCPSvrSession.CloseConnection ' + TextID);
  if FConnection <> nil then
  Begin
    ApplicationFlagThreadMsg
      ('TISIndyTCPSvrSession.CloseConnection FConnection<>nil ' + TextID);
    if FConnection.Connected then
      FConnection.Disconnect;
  End;

  if FServerContext <> nil then
  Begin
    ApplicationFlagThreadMsg
      ('TISIndyTCPSvrSession.CloseConnection FServerContext<>nil ' + TextID);
    If not FServerContext.FSessionClosing then
      ApplicationFlagThreadMsg
        ('TISIndyTCPSvrSession.CloseConnection FServerContext not closing '
        + TextID);
  End;

  WasClosedForcfullyOrGracefully;
  // Will Free as connection run by context
end;

{$IFNDEF  SuppressIPMetering}

function TISIndyTCPSvrSession.ConnectionResponseTimesText: AnsiString;
Var
  SD: Double;
begin

  Result := TextID + '  (' + IntToStr(FDisPatchSamples) + ' Dispatched )(' +
    IntToStr(FSrvReadTmSamples) + ' Read )' + IntToStr(FProcTmSamples) +
    ' Processed )';

  if FMaxDispatchTm > 0.0000000000001 then
  Begin

    SD := (CalDoubleStdDevFromSumOfSquares(FAveDisPatchSumSqs,
      FDisPatchSamples));

    if SD > 0.0000000001 then
      Result := Result + #13#10' Dispatch ' + FormatFloat('###0.000 mSecs',
        FAveDispatchTm) + ' Max' + FormatFloat('(0.000)', FMaxDispatchTm) +
        ' Min' + FormatFloat('(0.0000000000)', FMinDispatchTm) + ' SD' +
        FormatFloat('(0.0000000000)', SD)
    Else
      Result := Result + #13#10' Dispatch ' + FormatFloat('###0.000 mSecs',
        FAveDispatchTm) + ' Max' + FormatFloat('(0.000)', FMaxDispatchTm) +
        ' Min' + FormatFloat('(0.0000000000)', FMinDispatchTm);
  End;

  if FmaxSrvReadTm > 0.0000000000001 then
  Begin

    SD := (CalDoubleStdDevFromSumOfSquares(FAveSrvReadSumSqs,
      FSrvReadTmSamples));

    if SD > 0.0000000001 then
      Result := Result + #13#10' Read ' + FormatFloat('###0.000 mSecs',
        FAveSrvReadTm) + ' Max' + FormatFloat('(0.000)', FmaxSrvReadTm) + ' Min'
        + FormatFloat('(0.0000000000)', FminSrvReadTm) + ' SD' +
        FormatFloat('(0.0000000000)', SD)
    Else
      Result := Result + #13#10' Read ' + FormatFloat('###0.000 mSecs',
        FAveSrvReadTm) + ' Max' + FormatFloat('(0.0000000000)', FmaxSrvReadTm) +
        ' Min' + FormatFloat('(0.0000000000)', FminSrvReadTm);
  End;

  if FmaxProcTm < 0.0000000000001 then
    Exit;

  SD := (CalDoubleStdDevFromSumOfSquares(FAveProcTm, FProcTmSamples)) * 24
    * 60 * 60;

  if SD > 0.0000000001 then
    Result := Result + #13#10' Process ' + FormatFloat('###0.000 mSecs',
      FAveProcTm) + ' Max' + FormatFloat('(0.000)', FmaxProcTm) + ' Min' +
      FormatFloat('(0.000)', FminProcTm) + ' SD' + FormatFloat('(0.000)', SD)
  Else
    Result := Result + #13#10' Process ' + FormatFloat('###0.000 mSecs',
      FAveProcTm) + ' Max' + FormatFloat('(0.000)', FmaxProcTm) + ' Min' +
      FormatFloat('(0.000)', FminProcTm);
  if FServerContext <> nil then
    Result := Result + #13#10 + FServerContext.ContextResponseTimesText;
end;
{$ENDIF}

function TISIndyTCPSvrSession.ConnectionStatusText: AnsiString;
begin
  Result := 'No Register Name';
  if FRegisteredAs <> '' then
    if Not CheckConnection then
      Result := FRegisteredAs + CLinkClosed
    else if FCoupledSession = nil then
      Result := FRegisteredAs + CLinkFree
    else
      Result := FRegisteredAs + CLinkLinked;
end;

constructor TISIndyTCPSvrSession.Create(AContext: TIsIndyTCPServerContext;
  AServer: TIdCustomTCPServer);
begin
  if (AContext = nil) or (AServer = nil) then
    raise EExceptionIsComsNotExpected.Create('(AContext=nil) or (AServer=nil)');
  if (AContext.Connection = nil) then
    raise EExceptionIsComsNotExpected.Create('AContext.Connection=nil');

  Inherited Create;
  ReadDataWaitDiv5 := 5000; // ms
  FCountTo80 := 0;
  FNext80TransactionAllowance := StopWatch.Elapsed.Add
    (cStart80TransactionAllowence);
  FServerContext := AContext;
  If AServer is TIdTcpServer then
    FServerObject := TIdTcpServer(AServer);
  SetConnection(AContext.Connection);
  If FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).AddSession(Self);
  IsTimedOut(false);
  if FPermittedIdleTime.Ticks < 1 then
    FTimeOutAt := StopWatch.Elapsed.Add(TTimeSpan.FromHours(0.5))
  else
    FTimeOutAt := StopWatch.Elapsed.Add(FPermittedIdleTime);
end;

destructor TISIndyTCPSvrSession.Destroy;
begin
  FClosingTcpSocket := True;
  Try
    FInSessionDestroy := True;
    FConnection := nil; // Connection Managed by context
    try
      if FServerContext <> nil then
        if FServerContext.FTcpRef = Self then
        Begin
          FServerContext.FTcpRef := nil;
          if FServerContext.FSessionClosing then
            ApplicationFlagThreadMsg('Context Closing:' + PortId)
          else
            ApplicationFlagThreadMsg('Closing Open Context:' + PortId);
          FServerContext.FSessionClosing := True;
        End;
      ClearReferences;
    finally
      try
        inherited;
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, 'Session Destroy Inherited');
      End;
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Session Destroy');
  End;
end;

Procedure TISIndyTCPSvrSession.DoFileTransferBlockDnLd(ACommand: AnsiString);
var
  BlkStartPtr: ^Int64;
  BlkSzPtr: ^Int32;
  BlkStart: Int64;
  FileSz: Int64;
  BlckSz: Int32;
  TrfFileName: String;
  DataReturn, DataSend, CMDFileName: AnsiString;
  ServerFile: TFileStream;

begin // BlckSz:Int+BlkStart:int64+^FileName
  try
    if Length(ACommand) < (4 + 8 + 1 + 4) then // FileName 4Letters Min
      raise Exception.Create('Not enough data');
    if Byte(ACommand[13]) <> Byte(Ord('^')) then
      raise Exception.Create('Corrupted data');

    CMDFileName := copy(ACommand, 14, Length(ACommand));
    TrfFileName := DecodeSafeFileTransferPath(CMDFileName);

    if not FileExists(TrfFileName) then
      raise Exception.Create('No File::' + TrfFileName);

{$IFDEF NEXTGEN}
    BlkSzPtr := Pointer(ACommand);
    BlkStartPtr := Pointer(Int64(BlkSzPtr) + 4);
{$ELSE}
    BlkSzPtr := @ACommand[1];
    BlkStartPtr := @ACommand[5];
{$ENDIF}
    BlckSz := BlkSzPtr^;
    BlkStart := BlkStartPtr^;
    ServerFile := TFileStream.Create(TrfFileName, fmOpenRead or
      fmShareDenyNone);
    try
      FileSz := ServerFile.Size;
      // ServerFile.Seek(0,soFromEnd);
      if BlkStart + BlckSz > FileSz then
        BlckSz := FileSz - BlkStart;
      ServerFile.Seek(BlkStart, soFromBeginning);
{$IFDEF NEXTGEN}
      DataReturn.ReadBytesFrmStrm(ServerFile, BlckSz);
{$ELSE}
      SetLength(DataReturn, BlckSz);
      ServerFile.Read(DataReturn[1], BlckSz);
{$ENDIF}
      DataSend := PackTransaction(cReadFileTransferBlock + DataReturn,
        FRandomKey{$IFNDEF  SuppressIPMetering}
        , false{$ENDIF});
      If write(DataSend) <> Length(DataSend) then
        ISIndyUtilsException(Self,
          'DoFileTransferBlock : DataSend)<>Length(DataSend');
    finally
      ServerFile.Free;
    end;
  except
    on E: Exception do
      try
        ISIndyUtilsException(Self, 'DoFileTransferBlockDnLd : ' + E.Message);
      except
      end;
  end;
end;

procedure TISIndyTCPSvrSession.DoFileTransferBlockUpLd(ADataIn: AnsiString);
var
  BlkStartPtr: ^Int64;
  BlkSzPtr: ^Int32;
  BlkStart: Int64;
  FileSz: Int64;
  BlckSz, DataSz: Int32;
  TrfFileName: String;
{$IFDEF NEXTGEN}
  TstStr,
{$ENDIF}
  DataSend, CMDFileName: AnsiString;
  ServerFile: TFileStream;
  ChrDataIn, ChrDataSt, Tst: PAnsiChar;
  Saved: Integer;
begin
  // BlckSz:Int+BlkStart:int64+^FileName
  try
    if Length(ADataIn) < (4 + 8 + 1 + 4) then // FileName 4Letters Min
      raise Exception.Create('Not enough data');
    if Byte(ADataIn[13]) <> Byte(Ord('^')) then
      raise Exception.Create('Corrupted data');
{$IFDEF NEXTGEN}
    ChrDataIn := Pointer(ADataIn);
    Inc(ChrDataIn, 14);
    TstStr := '^';
    Tst := Pointer(TstStr);
{$ELSE}
    ChrDataIn := @ADataIn[13];
    Inc(ChrDataIn);
    Tst := '^';
{$ENDIF}
{$IFDEF FPC}
    ChrDataSt := AnsiStrPos(ChrDataIn, Tst);
{$ELSE}
    ChrDataSt := StrPos(ChrDataIn, Tst);
{$ENDIF}
    if (ChrDataSt <> nil) and (ChrDataSt[1] <> AnsiChar(0)) then
    begin
      CMDFileName := copy(ADataIn, 14, ChrDataSt - ChrDataIn);
      Inc(ChrDataSt);
    end;

    DataSz := Length(ChrDataSt);

    TrfFileName := DecodeSafeFileTransferPath(CMDFileName);

{$IFDEF NEXTGEN}
    BlkSzPtr := Pointer(ADataIn);
    BlkStartPtr := Pointer(Int64(BlkSzPtr) + 4);
{$ELSE}
    BlkSzPtr := @ADataIn[1];
    BlkStartPtr := @ADataIn[5];
{$ENDIF}
    BlckSz := BlkSzPtr^;
    BlkStart := BlkStartPtr^;

    if DataSz <> BlckSz then
      raise Exception.Create('DataSz{' + IntToStr(DataSz) + '} <> BlckSz{' +
        IntToStr(BlckSz) + '}');

    ServerFile := nil;
    Try
      if BlkStart = 0 then
      Begin
        if FileExists(TrfFileName) then
          if IsUploadAcceptTempFile(TrfFileName) then
          Begin
            DeleteFile(TrfFileName);
            Sleep(200);
          End;
        if FileExists(TrfFileName) then
          raise Exception.Create('File Exists::' + TrfFileName);

        if not DirectoryExists(ExtractFileDir(TrfFileName)) then
          try
            ForceDirectories(ExtractFileDir(TrfFileName));
          Except
            On E: Exception do
            begin
              ISIndyUtilsException(Self, E, 'ExtractFileDir(' +
                TrfFileName + ')');
              Exit;
            end;
          end;
        ServerFile := TFileStream.Create(TrfFileName, fmCreate);
        FileSz := 0;
        // ServerFile.Seek(0,soFromBeginning);
      End
      Else if FileExists(TrfFileName) then
      Begin
        ServerFile := TFileStream.Create(TrfFileName, fmOpenWrite or
          fmShareExclusive);
        FileSz := ServerFile.Seek(0, soFromEnd);
      End
      else
        raise Exception.Create('File Not Created::' + TrfFileName);

      if BlkStart <> FileSz then
        raise Exception.Create('File Block Out of Sequence::' + TrfFileName);

      // if BlkStart + BlckSz > FileSz then
      // BlckSz := FileSz - BlkStart;

{$IFDEF NEXTGEN}
      Tst := Pointer(ChrDataSt);
      Saved := ServerFile.Write(Tst, BlckSz);
{$ELSE}
      Saved := ServerFile.Write(ChrDataSt[0], BlckSz);
{$ENDIF}
      // Saved := ServerFile.Write(ChrDataSt[0], BlckSz);
      if Saved = BlckSz then
        DataSend := PackTransaction(cPutFileTransferBlock + IntToStr(Saved),
          FRandomKey{$IFNDEF  SuppressIPMetering}
          , false{$ENDIF})
      else
        raise Exception.Create('File Block Bad Write::' + TrfFileName);
      If write(DataSend) <> Length(DataSend) then
        ISIndyUtilsException(Self,
          'DoFileTransferBlock : DataSend)<>Length(DataSend');
    finally
      ServerFile.Free;
    end;
  except
    on E: Exception do
      ISIndyUtilsException(Self, 'DoFileTransferBlockUpLd : ' + E.Message);
  end;
end;

function TISIndyTCPSvrSession.DoSimpleRemoteAction(ACommand: AnsiString)
  : AnsiString;
begin
  Result := '';
  if (Self = nil) then
  Begin
    ApplicationFlagThreadMsg('DoSimpleRemoteAction on Cleared Object');
    Exit;
  End;
  if Pos(cRemoteServerDropCoupledSession, ACommand) = 1 then
    Result := DropCoupledSession
  else if Pos(cIsLinkedOnServer, ACommand) = 1 then
  begin
    if FServerObject is TIsIndyApplicationServer then
      Result := TIsIndyApplicationServer(FServerObject)
        .LinkStatusAsResponse(ACommand, Self)
    else
      Result := '-33333';
  End
  { Any command that acts on this server must go before
    Assigned(FCoupledSession)
  }
  else if Assigned(FCoupledSession) then
  Begin
    if FCoupledSession.FCoupledSession = nil then
      ISIndyUtilsException(Self, 'Id=' + TextID + 'Reg=' + FRegisteredAs +
        '   FCoupledSession.FCoupledSession=nil Id:=' + FCoupledSession.TextID +
        ' Reg=' + TISIndyTCPSvrSession(FCoupledSession).FRegisteredAs)
    else
      ISIndyUtilsException(Self, 'Id=' + TextID + 'Reg=' + FRegisteredAs +
        '  FCoupledSession has FCoupledSession ID=' + FCoupledSession.TextID +
        ' Reg=' + FRegisteredAs);

    FCoupledSession.FullDuplexDispatch(ACommand, cSimpleRemoteAction);
    // else if Pos(cRemoteServerDetails, ACommand) = 1 then
    // Result := ShowServerDetails
  end
  else if Pos(cRemoteServerDetails, ACommand) = 1 then
    Result := ShowServerDetails
  else if Pos(cRemoteServerConnections, ACommand) = 1 then
    Result := ShowServerConnections(ACommand)
  else if Pos(cRemoteSetServerRelay, ACommand) = 1 then
    Result := SetServerConnections(ACommand)
  else if Pos(cRemoteResetServer, ACommand) = 1 then
    Result := ResetServer(ACommand)
  else if Pos(cIdleSecsOnServer, ACommand) = 1 then
  begin
    if FServerObject is TIsIndyApplicationServer then
      Result := IntToStr(Round(TIsIndyApplicationServer(FServerObject)
        .FIdleTimePermitted.TotalSeconds))
    else
      Result := '-5555';
  End
  // Function removed
  // else if Pos(cRemoteDbLog + '^>>', ACommand) = 1 then
  // LogAMessage(ACommand)
  else if Pos(cRemoteFileSize + '^', ACommand) = 1 then
    Result := PackAServerFileSize(DecodeSafeFileTransferPath(ACommand))
  else if Pos(CRemoteChangeLogging + '^', ACommand) = 1 then
    Result := RemoteChangeLogging(ACommand)
  else if Pos(cRemoteListAvailableFiles + '^', ACommand) = 1 then
    Result := PackAServerAvailableFiles(DecodeSafeFileTransferPath(ACommand))
  else if Pos(cRemoteForceClose, ACommand) = 1 then
  begin
    Result := 'Boo';
    CloseIsObjGracefully; // test
  End
  else if Assigned(FOnSimpleRemoteAction) then
    Result := FOnSimpleRemoteAction(ACommand, Self)
  else
  Begin
    ISIndyUtilsException(Self, 'Simple Rmt: No Code For Action :' + ACommand);
    Result := 'No Code For Action::' + ACommand;
  End;
end;

function TISIndyTCPSvrSession.DropCoupledSession: AnsiString;
begin
  Try
    if FCoupledSession <> nil then
    Begin
      ISIndyUtilsException('DropCoupledSession',
        TextID + '<>' + FCoupledSession.TextID);
      if FCoupledSession is TISIndyTCPFullDuplexClient Then
        TISIndyTCPFullDuplexClient(FCoupledSession).DropAllRemoteSessions;
      if FCoupledSession.FCoupledSession = Self then
        if FOwnsCoupledSession then
          FCoupledSession.Free
        Else
          FCoupledSession.FCoupledSession := nil;
      Result := 'DropCoupledSession';
      fFullDuplex := false;
    End
    Else
    Begin
      Result := 'No Session to Drop in DropCoupledSession';
      ISIndyUtilsException('DropCoupledSession', TextID + ' ' + Result);
    End;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, 'Error DropCoupledSession:' + E.Message);
  End;
  FCoupledSession := nil;
end;

function TISIndyTCPSvrSession.FullDuplexDispatch(AData,
  AKey: AnsiString): Boolean;
// On A server session object FConnection maybe unsafe
Var
  SvrContext: TIsIndyTCPServerContext;
  LConnection: TIdTCPConnection;
begin
  Result := false;

  if FClosingTcpSocket then
    Exit;

  if Not LockConnectionCon(LConnection) then
    Exit;

  if FServerContext = nil then
    Exit;
  if FServerContext.FTcpRef <> Self then
    Exit;
  if FServerContext.FSessionClosing then
    Exit;

  if FServerContext.Connection <> LConnection then
    Exit;
  Try
    if FServerContext.Connection.Connected then
      // While Testing
      // ApplicationFlagThreadMsg('FullDuplexDispatch Connected ' + TextID)
    else
      Exit;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, '#FullDuplexDispatch Not Connected');
      ApplicationFlagThreadMsg('FullDuplexDispatch Not Connected');
      Exit;
    End;
  End;
  Try
    Result := Inherited FullDuplexDispatch(AData, AKey);
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'Inherited #FullDuplexDispatch');
      ApplicationFlagThreadMsg('Inherited FullDuplexDispatch');
      Exit;
    End;
  end;
end;

// procedure TISIndyTCPSvrSession.DropSrvrReferences;
// begin
// try
// if FServerObject is TIsIndyApplicationServer then
// TIsIndyApplicationServer(FServerObject).DropSession(Self);
// FServerObject := nil;
// FServerContext := nil;
// Except
// On E: Exception do
// begin
// WritelnIfPossible('Exception in DropSrvrReferences:' + E.Message);
// ISIndyUtilsException(Self, E, 'DropSrvrReferences');
// end;
// end;
// end;

function TISIndyTCPSvrSession.IsTimedOut(ACloseIfTrue: Boolean): Boolean;
begin
  Result := false;
  if FPermittedIdleTime.Ticks < 1 then
    if FServerObject is TIsIndyApplicationServer then
    Begin
      FPermittedIdleTime := TIsIndyApplicationServer(FServerObject)
        .IdleTimePermitted;
      FReportIdleTime := FPermittedIdleTime - TTimeSpan.FromSeconds(30);
      FTimeOutAt := FChnlStopWatch.Elapsed.Add(FPermittedIdleTime);
    End;
  if FPermittedIdleTime.Ticks < 1 then
    Exit;
  Result := FTimeOutAt < FChnlStopWatch.Elapsed;
  if Result and ACloseIfTrue then
  begin
    if GblRptTimeoutClear then
      ApplicationFlagThreadMsg(Self, '# Idle Close ' + PortId + ' Idle Limit ='
        + FPermittedIdleTime.ToString);
    CloseIsObjGracefully;
  end;
end;

function TISIndyTCPSvrSession.LinkedTo(APort, BPort: Integer): Integer;
begin
  Result := 0;
  if Port <> 0 then
    if (APort = Port) then
      Result := 1
    else if (BPort = Port) then
      Result := 2;

  if FCoupledSession <> nil then
  begin
    if FCoupledSession.Port = APort then
      case Result of
        0:
          Result := 3; // APort is couple
        1:
          ISIndyUtilsException(Self, 'Session Link Error A Both =' +
            IntToStr(APort));
        2:
          Result := 6; // full match
      end
    else if FCoupledSession.Port = BPort then
      case Result of
        0:
          Result := 4;
        // BPort is couple
        1:
          Result := 5; // reverse match
        2:
          ISIndyUtilsException(Self, 'Session Link Error B Both =' +
            IntToStr(BPort));
      end;
  end;
end;

{ function TISIndyTCPSvrSession.PackAPutServerFileResponse(const AFileData
  : AnsiString): AnsiString;
  Var
  FileName: AnsiString;
  FileSt, FileEd: PAnsiChar;
  OffSet: Integer;
  Sz: Int64;
  Directory: String;
  OutputFile: TFileStream;
  ???
  begin
  try
  Result := 'error';
  if Pos(cPutRemoteFile + '^', AFileData) <> 1 then
  Exit;
  FileSt := @AFileData[1];
  OffSet := Length(cPutRemoteFile + '^');
  FileSt := FileSt + OffSet;
  FileEd := AnsiStrPos(FileSt,'^');
  FileName := Copy(AFileData, 3, FileEd - FileSt);
  FileName := DecodeSafeFileTransferPath(FileName);
  if FileName = '' then
  Exit;
  if (FileEd[0] = '^') and (FileEd[9] = '^') then
  Sz := Ord(FileEd[1]) + Ord(FileEd[2]) * 256 + Ord(FileEd[3]) * 256 * 256 +
  Ord(FileEd[4]) * 256 * 256 * 256 + Ord(FileEd[5]) * 256 * 256 * 256 *
  256 + Ord(FileEd[6]) * 256 * 256 * 256 * 256 * 256 + Ord(FileEd[7]) *
  256 * 256 * 256 * 256 * 256 * 256 + Ord(FileEd[8]) * 256 * 256 * 256 *
  256 * 256 * 256 * 256
  else
  Exit;
  if (Sz < 2) or (Sz > 30000000) then
  Exit;

  Directory := ExtractFileDir(FileName);
  if not DirectoryExists(Directory) then
  ForceDirectories(Directory);
  if not DirectoryExists(Directory) then
  Exit;

  If FileExists(FileName) then
  Exit; // filename must be unique

  OutputFile := TFileStream.Create(FileName, fmCreate);

  OutputFile.Write(FileEd, Sz);

  Result := 'Pack sz';
  except
  on E: Exception do
  ISIndyUtilsException('Application File Upload:', E.Message);
  end;

  end;
}

{ function TISIndyTCPSvrSession.PackAServerFile(const AFileName: AnsiString)
  : AnsiString;
  var
  ServerFile: TFileStream;
  begin
  ServerFile := nil;
  Result := '';
  if AFileName = '' then
  Exit;

  if not FileExists(AFileName) then
  raise Exception.Create(AFileName + cNoExistMessage);

  try
  ServerFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  Result := StreamAsString(ServerFile);
  finally
  ServerFile.Free;
  end;
  end;
}

function TISIndyTCPSvrSession.PackAServerAvailableFiles(const AFileName
  : AnsiString): AnsiString;
Var
  LBase, LDir, Mask: AnsiString;
  ThisRec: TSearchRec;
begin
  Result := 'No Data';
  LBase := DecodeSafeFileTransferPath('');
  if Pos(LBase, AFileName) <> 1 then
    Exit;
  if DirectoryExists(AFileName) then
    LDir := AFileName
  else
    LDir := ExtractFileDir(AFileName);
  if Not DirectoryExists(LDir) then
    Exit;

  Result := '';
  Mask := LDir + TPath.DirectorySeparatorChar + '*.*';
  if (FindFirst(Mask, faDirectory, ThisRec) = 0) then
  Begin
    Result := ThisRec.Name;
    while FindNext(ThisRec) = 0 do
      Result := Result + #13#10 + ThisRec.Name;
  End;
end;

function TISIndyTCPSvrSession.PackAServerFileSize(const AFileName: AnsiString)
  : AnsiString;
var
  ServerFile: TFileStream;
  Sz: Int64;
begin
  ServerFile := nil;
  Result := '';
  if AFileName = '' then
    Exit;

  if not FileExists(AFileName) then
    raise Exception.Create(AFileName + cNoExistMessage);

  try
    ServerFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    Sz := ServerFile.Size;
    Result := IntToStr(Sz);
  finally
    ServerFile.Free;
  end;
end;

function TISIndyTCPSvrSession.PortId: String;
begin
  try
    if (Self = nil) then
    Begin
      Result := ' Disconnected Self = nil';
      ApplicationFlagThreadMsg('PortID on Cleared Object');
    End
    Else if (Length(Address) < 1) Or (Address[1] = '<') then
      Result := ' Disconnected Was to ' + Address + ':' + IntToStr(Port)
    else
      Result := Address + ':' + IntToStr(Port);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Port Id');
  end;
end;

function TISIndyTCPSvrSession.ProcessNextSrvrTransaction: Boolean;
Var
  Trans, Key, Echo, Rtn, RawRtn: AnsiString;
  StartTime: TTimeSpan;
  ElapsedTime: TTimeSpan;
  TimeRec: TTimeRec;
  StrRtn, ss: String;
  TrnctType: TTCPTransactionTypes;
{$IFDEF Debug}
begin
  FIsDebugChnl := Self = GlobalSelectDebugChn;
  if not FIsDebugChnl and (FRegisteredAs <> '') then
    FIsDebugChnl := FRegisteredAs = GlobalDbugRegisteredAs;
{$ELSE}
begin
{$ENDIF}
  Trans := '';
  Rtn := '';
  Try
    if (Self = nil) then
    Begin
      ApplicationFlagThreadMsg('ProcessNextSrvrTransaction on Cleared Object');
      Exit;
    End;

    StartTime := FChnlStopWatch.Elapsed;
    Result := false;
    Try
      Rtn := '';
      Key := '';
      try
        if FPermittedIdleTime.Ticks < 1 then
          IsTimedOut(false);
        // Get  FPermittedIdleTime

        Trans := ReadATransactionRecord(TrnctType, Key);
        ElapsedTime := FChnlStopWatch.Elapsed;
        ElapsedTime := ElapsedTime.Subtract(StartTime);

        if ElapsedTime > FReportIdleTime then
          ISIndyUtilsException(Self, '#Excessive Trans Read Time ' + PortId +
            #13#10'Elapsed Time =' + ElapsedTime.ToString +
            #13#10'Key =' + Key);

        if (Trans = '') and (Key = '') then
        Begin
          Result := Not IsTimedOut(false);
          { while Testing }
          // if Not Result then
          // ApplicationFlagThreadMsg('Read Trans = "" ' + PortId +
          // #13#10'Elapsed Time =' + ElapsedTime.ToString +
          // #13#10'Key =' + Key);

          if GblRptTimeoutClear and Not Result then
          Begin
            ISIndyUtilsException(Self, '#Read Trans = "" ' + PortId +
              #13#10'Elapsed Time =' + ElapsedTime.ToString +
              #13#10'Key =' + Key);
            ISIndyUtilsException(Self, '#Read Timeout ' + PortId);
          End;
          Exit;
          // Is Not Timed out keep reading     ???? means????
        End;

        if FPermittedIdleTime.Ticks > 1 then // Rx Data
          FTimeOutAt := StartTime.Add(FPermittedIdleTime);

        CalAveSrvReadTime(ElapsedTime);
{$IFNDEF  SuppressIPMetering}
        FIsMeteredTransaction := SplitMeteredData(Trans, FCurrentTxMetering);
        if FIsMeteredTransaction then
          FCurrentTxMetering := FCurrentTxMetering +
            AddMeteredTimeRecAsString('PT');

{$ENDIF}
        if (Assigned(FCoupledSession)) and (TrnctType <> SmpAct) then
        Begin
          Try
{$IFNDEF  SuppressIPMetering}
            Trans := Trans + FCurrentTxMetering;
{$ENDIF}
            if Not Assigned(FCoupledSession.FCoupledSession) then
              ISIndyUtilsException(Self,
                'Full Duplex Coupled session Dispatch no return session '
                + TextID);
            Result := FCoupledSession.FullDuplexDispatch(Trans, Key);
{$IFNDEF  SuppressIPMetering}
            ElapsedTime := FChnlStopWatch.Elapsed.Subtract(StartTime);
            CalAveDispatchTime(ElapsedTime);
{$ENDIF}
            if Not Result then
            begin
              Result := True;
              // But Leave incoming for now because problem was on despatch
              ss := TextID;
              if FOwnsCoupledSession then
                ApplicationFlagThreadMsg
                  ('Server Session Full Duplex Owned Coupled session Dispatch Fail '
                  + TextID)
              else
                ApplicationFlagThreadMsg
                  ('Server Session Full Duplex Non Owned Coupled session Dispatch Fail '
                  + TextID);

              Try
                if FCoupledSession <> nil then
                Begin
                  ss := ss + ' FCoupledSession <> nil but wrong ';
                  ss := FCoupledSession.TextID + ':Coupled to:' + TextID;
                end;
              Except
                On E: Exception do
                Begin
                  ISIndyUtilsException(E, '#Dropping Coupled Session ' + ss);
                  ApplicationFlagThreadMsg
                    ('Exception Dropping Coupled Session' + ss);
                End;
              end;

              if FOwnsCoupledSession then
                FreeAndNil(FCoupledSession)
              else
              begin
                Try
                  if FCoupledSession <> nil then
                    if FCoupledSession.FCoupledSession = Self then
                      FCoupledSession.FCoupledSession := nil;
                  FCoupledSession := nil;
                Except
                  On E: Exception do
                  Begin
                    ISIndyUtilsException(E, '#Dropping Coupled Session ' + ss);
                    ApplicationFlagThreadMsg
                      ('Exception Dropping Coupled Session' + ss);
                  End;
                End;
              end;
              FCoupledSession := nil;
            end;
          Except
            on E: Exception do
            begin
              FCoupledSession := nil;
              Rtn := 'Coupled Session Failure ::' + E.Message;
              Result := false;
              ISIndyUtilsException(Self, E,
                '#Coupled Session Dispatch Failure');
            end;
          end;
        End
        else
          case TrnctType of
            EchoTrans:
              Begin
                if TimeRec.FromTransString(Trans) then
                  Trans := Trans + ' Echo MilliSecs:' +
                    FormatFloat('0.00', TimeRec.DeltaMilliSecs);
{$IFNDEF  SuppressIPMetering}
                if FIsMeteredTransaction then
                  Trans := Trans + FCurrentTxMetering;
{$ENDIF}
                Echo := PackTransaction(Key + Trans,
                  FRandomKey{$IFNDEF  SuppressIPMetering}
                  , false{$ENDIF});
                // Echo := PackTransaction(Key + '[' + Trans + ']', FRandomKey);
                Write(Echo);
                if GblRptMakeConnectionOnSrvr then
                  ISIndyUtilsException(Self, 'Echo Key =' + Key +
                    BytesToLogText(Trans));
                Result := True;
              End;
            SmpAct:
              Begin
                Try
                  { if FCoupledSession <> nil then
                    Begin // Lock returns
                    Result := True;
                    // if FLockSession = nil then
                    // FLockSession := TCriticalSection.Create;
                    // FLockSession.Enter;
                    End;
                  }
                  Rtn := DoSimpleRemoteAction(Trans);
                  if Rtn <> '' then
                  Begin
{$IFNDEF  SuppressIPMetering}
                    if FIsMeteredTransaction then
                      Rtn := Rtn + FCurrentTxMetering;
{$ENDIF}
                    RawRtn := PackTransaction(Key + Rtn,
                      FRandomKey{$IFNDEF  SuppressIPMetering}
                      , false{$ENDIF});
                    Write(RawRtn);
                    if GblLogMsgToGeneralLogl then
                      ISIndyUtilsException(Self, 'DoSimpleRemoteAction' +
                        BytesToLogText(Trans) + #13#10'Rtn' +
                        BytesToLogText(Rtn));
                    Result := True;
                  End
                  Else
                  Begin
                    ISIndyUtilsException(Self,
                      '#ProcessNextSrvrTransaction - No Response frm Trans' +
                      BytesToLogText(Trans));
                    Result := True;
                  End;

                Except
                  On E: Exception do
                    ISIndyUtilsException(Self, E,
                      'SmpAct Transaction #ProcessNextSrvrTransaction' +
                      BytesToLogText(Trans));
                  // Finally
                  // if FLockSession <> nil then
                  // FLockSession.Release;
                End;
              End;
            RdFileTrfBlk:
              Begin
                DoFileTransferBlockDnLd(Trans);
                Result := True;
              End;
            PtFileTrfBlk:
              Begin
                DoFileTransferBlockUpLd(Trans);
                Result := True;
              End;
            MvString:
              Begin
                if Assigned(FOnStringAction) then
                Begin
                  StrRtn := FOnStringAction(RecoverTrnsString(Trans), Self);
{$IFNDEF  SuppressIPMetering}
                  if FIsMeteredTransaction then
                    StrRtn := StrRtn + FCurrentTxMetering;
{$ENDIF}
                  RawRtn := PackString(StrRtn,
                    FRandomKey{$IFNDEF  SuppressIPMetering}
                    , false{$ENDIF});
                End
                Else
                Begin
                  Key := cReturnError;
                  Rtn := 'No OnStringAction Function';
{$IFNDEF  SuppressIPMetering}
                  if FIsMeteredTransaction then
                    StrRtn := StrRtn + FCurrentTxMetering;
{$ENDIF}
                  RawRtn := PackTransaction(Key + Rtn,
                    FRandomKey{$IFNDEF  SuppressIPMetering}
                    , false{$ENDIF});
                End;
                Write(RawRtn);
                Result := True;
              End;
            MvRawStrm:
              Begin
                if Assigned(FOnAnsiStringAction) then
                  Rtn := FOnAnsiStringAction(Trans, Self)
                Else
                Begin
                  Key := cReturnError;
                  Rtn := 'No OnAnsiStringAction Function';
                End;
                if Rtn <> '' then
                Begin
{$IFNDEF  SuppressIPMetering}
                  if FIsMeteredTransaction then
                    Rtn := Rtn + FCurrentTxMetering;
{$ENDIF}
                  RawRtn := PackTransaction(Key + Rtn,
                    FRandomKey{$IFNDEF  SuppressIPMetering}
                    , false{$ENDIF});
                  Write(RawRtn);
                End;
                Result := True;
              End;
            FullDuplexMode:
              Begin
                Result := DoFullDuplexIncomingAction(Trans);
                If Not Result then
                Begin
                  Key := cReturnError;
                  Rtn := 'No OnFullDuplexIncomingAction Function';
{$IFNDEF  SuppressIPMetering}
                  if FIsMeteredTransaction then
                    Rtn := Rtn + FCurrentTxMetering;
{$ENDIF}
                  RawRtn := PackTransaction(Key + Rtn,
                    FRandomKey{$IFNDEF  SuppressIPMetering}
                    , false{$ENDIF});
                  Write(RawRtn);
                  Result := True;
                End;
              End;
            FlgNull:
              Begin
                if Assigned(FCoupledSession) then
                  FCoupledSession.FullDuplexDispatch('', Key) // Forward Null
                Else
                begin
                  RawRtn := PackTransaction(Key,
                    FRandomKey{$IFNDEF  SuppressIPMetering}
                    , false{$ENDIF});
                  Write(RawRtn);
                end;
                Result := True;
              End;
            NewCon:
              Begin
                ISIndyUtilsException(Self,
                  ' #ProcessNextSrvrTransaction NewConnection Data' +
                  BytesToLogText(Trans));
                Result := false;
              end;
            LogServerData:
              Begin
                ISIndyUtilsException(Self, Trans);
                Rtn := 'Logged ' + IntToStr(Length(Trans)) + ' Chars';
{$IFNDEF  SuppressIPMetering}
                if FIsMeteredTransaction then
                  Rtn := Rtn + FCurrentTxMetering;
{$ENDIF}
                RawRtn := PackTransaction(Key + Rtn,
                  FRandomKey{$IFNDEF  SuppressIPMetering}
                  , false{$ENDIF});
                Write(RawRtn);
                Result := True;
              end;
            FlgError:
              Begin
                ISIndyUtilsException(Self,
                  PortId + ' # ProcessNextSrvrTransaction Flag Error' +
                  BytesToLogText(Trans));
                Result := True;
              End;
            FlgEmpty:
              Begin
                ISIndyUtilsException(Self,
                  PortId + ' # ProcessNextSrvrTransaction Flag Empty' +
                  BytesToLogText(Trans));
                Result := True;
              End
          Else
            Begin
              If Trans <> '' then
                ISIndyUtilsException(Self,
                  PortId + ' # ProcessNextSrvrTransaction Unknown Data' +
                  BytesToLogText(Trans));
              // Key := cReturnError;
              Result := false;
            End;
          end;

        if Not Result then
        Begin
          ISIndyUtilsException(Self, '# ProcessNextSrvrTransaction Not Result '
            + PortId + #13#10'Trans =' + BytesToLogText(Trans) + #13#10'Key=' +
            Key + ' Rtn =' + BytesToLogText(Rtn));
          If Key = '' then
            Key := cReturnError;
          If Rtn <> '' then
          Begin
            RawRtn := PackTransaction
              (Key + 'ProcessNextSrvrTransaction Rtn False ' + Rtn,
              FRandomKey{$IFNDEF  SuppressIPMetering}
              , false{$ENDIF});
            Write(RawRtn);
            ISIndyUtilsException(Self, '#Not Result Key=' + Key +
              ' Closing:ProcessNextSrvrTransaction Rtn False');
          end;
          Result := false;
          // will CloseGracefully
        end;
{$IFNDEF  SuppressIPMetering}
        ElapsedTime := FChnlStopWatch.Elapsed.Subtract(StartTime);
        CalAveTransProcTime(ElapsedTime);
{$ENDIF}
      Except
        On ee: Exception do
        begin
          Result := false;
          RawRtn := Key + 'Exception::' + ee.Message;
          ISIndyUtilsException(Self, ee, 'Key=' + Key + ' :: Trans =' +
            BytesToLogText(Trans));
        end;
      end;
    Finally
      if Not Result then
        // While Testing
        // if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, 'ProcessNextSrvrTransaction #False Result ' +
          PortId + #13#10 + 'Key =' + Key + ':: Trans =' +
          BytesToLogText(Trans));
    End;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'ProcessNextSrvrTransaction outerloop');
      ApplicationFlagThreadMsg('ProcessNextSrvrTransaction Exception');
      Result := false;
    end;
  End;
end;

function TISIndyTCPSvrSession.ResetServer(AConnectData: AnsiString): AnsiString;
begin
  Result := '';
  ISIndyUtilsException(Self, TextID + ' #ResetServer');
  if FServerObject is TIsIndyApplicationServer then
    Result := TIsIndyApplicationServer(FServerObject).ResetSvr(AConnectData)
  else
  Begin
    CloseConnection;
    Result := 'Closing Single Connection';
    Exit;
  End;
end;

procedure TISIndyTCPSvrSession.SetFullDuplex(Val: Boolean);
begin
  if FCoupledSession <> nil then
    if FCoupledSession.FCoupledSession = nil then
      ISIndyUtilsException(Self,
        'FullDup  FCoupledSession.FCoupledSession=nil Id=' + TextID);

  if fFullDuplex <> Val then
    if Val then
    Begin
      if FCoupledSession <> nil then
        Try
          // if FLockSession = nil then
          // FLockSession := TCriticalSection.Create;
          // FLockSession.Enter;
          fFullDuplex := FCoupledSession <> nil;
        Finally
          // FLockSession.Release;
        End;
    End
    else
      fFullDuplex := Val;
end;

function TISIndyTCPSvrSession.SetServerConnections(AConnectData: AnsiString)
  : AnsiString;
Var
  Svr: TIsIndyApplicationServer;
  Inx, Tst, ConPort: Integer;
  ConToLinkTo: TISIndyTCPBase;
  Address, PortStr: AnsiString;
  WillOwn: Boolean;

begin
  if FServerObject is TIsIndyApplicationServer then
    Svr := FServerObject as TIsIndyApplicationServer
  else
    Exit;
  // While Testing
  ApplicationFlagThreadMsg(PortId + ' Set Svr Con ' + AConnectData);
  // if GblRptSrvrRelayConnectionAttempts then
  ISIndyUtilsException(Self, PortId + ' #Set Svr Con ' + AConnectData);

  if FCoupledSession <> nil then
    DropCoupledSession;
  Tst := Length(cRemoteSetServerRelay) + 1;

  Result := '';
  if Pos(cRemoteSetServerRelay, AConnectData) <> 1 then
    Exit;
  WillOwn := false;
  ConToLinkTo := nil;
  Inx := Pos(cServerLink, AConnectData);
  if Inx = Tst then
  Begin
    // RemoteServerRelay#SV#Reference From RemoteServerDetails#
    Address := copy(AConnectData, Tst + 3, 255);
    ConToLinkTo := Svr.GetRegConnectionFor(Address);
    // While Testing
    // if GblRptSrvrRelayConnectionAttempts then
    if ConToLinkTo = nil then
      ISIndyUtilsException(Self, PortId + 'Failed Svr Con ' + AConnectData)
    Else
      ISIndyUtilsException(Self, 'Set Svr Con ' + AConnectData + #13#10 + TextID
        + ' Connected to ' + ConToLinkTo.PortId);
  End
  Else
  Begin
    Inx := Pos(cNewIPLink, AConnectData);
    if Inx = Tst then
      try
        // RemoteServerRelay#IP#Host Address or IP:Port
        Address := copy(AConnectData, Tst + 3, 255);
        Inx := Pos(AnsiString(':'), Address);
        if Inx > 6 then
        Begin
          PortStr := copy(Address, Inx + 1, 255);
{$IFDEF NextGen}
          Address.Length := Inx - 1;
{$ELSE}
          SetLength(Address, Inx - 1);
{$ENDIF}
          ConPort := StrToIntDef(PortStr, 0);
          if (ConPort > 0) and (Address <> '') then
            ConToLinkTo := TISIndyTCPFullDuplexClient.StartAccess
              (Address, ConPort)
          else
            ConToLinkTo := nil;

          if GblRptSrvrRelayConnectionAttempts then
            if ConToLinkTo = nil then
              ISIndyUtilsException(Self, TextID + 'Failed Svr Con ' +
                AConnectData)
            Else
              ISIndyUtilsException(Self, 'Set Svr Relay ' + AConnectData +
                #13#10 + PortId + ' Connected to ' + ConToLinkTo.PortId);

          if (ConToLinkTo <> nil) and (Svr <> nil) then
            Inc(Svr.FServerTcpSessions);
          WillOwn := True;
        End;
      except
        On E: Exception do
        begin
          FreeAndNil(ConToLinkTo);
          ISIndyUtilsException(Self, E, 'SetServerConnections>>AConnectData = '
            + AConnectData);
        end;
      end;
  End;

  if ConToLinkTo <> nil then
  Begin
    // FCloseOnTimeOut:=False;
    ReadDataWaitDiv5 := 30000;
    if FOwnsCoupledSession then
      FreeAndNil(FCoupledSession);
    FCoupledSession := ConToLinkTo;
    if ConToLinkTo.FOwnsCoupledSession then
      FreeAndNil(ConToLinkTo.FCoupledSession);
    ConToLinkTo.FCoupledSession := Self;
    FOwnsCoupledSession := WillOwn;
  End;

  if FCoupledSession <> nil then
    Result := FCoupledSession.PortId + ' >< ' + PortId
  else
    Result := 'Fail::' + AConnectData;
end;

function TISIndyTCPSvrSession.ShowServerConnections(ARegData: AnsiString)
  : AnsiString;
Var
  NewReg, CurMeteredData: AnsiString;
  Svr: TIsIndyApplicationServer;
begin
  Result := '';
  Try
    if Pos(cRemoteServerConnections, ARegData) <> 1 then
      Exit;
    if FServerObject is TIsIndyApplicationServer then
      Svr := FServerObject as TIsIndyApplicationServer
    else
      Exit;
    NewReg := copy(ARegData, Length(cRemoteServerConnections) + 1, 255);
    if IsEmptyString(NewReg) then
      // do nothing
    Else if NewReg <> FRegisteredAs then
    Begin
      if Not IsEmptyString(FRegisteredAs) then
      begin
        // while testing
        ApplicationFlagThreadMsg('NewReg ' + NewReg + '<> FRegisteredAs ' +
          FRegisteredAs);
        ISIndyUtilsException(Self, '#NewReg ' + NewReg + '<> FRegisteredAs ' +
          FRegisteredAs);
        //
        if Not IsEmptyString(FRegisteredAs) then
          Svr.DropRegConnection(Self);
      end
      Else
      begin
        // while testing
        ApplicationFlagThreadMsg('NewReg ' + NewReg);
        ISIndyUtilsException(Self, '#NewReg ' + NewReg);
        //
      end;
      FRegisteredAs := NewReg;
    End;
    Result := Svr.AllRegisteredConnections(Self);
{$IFNDEF  SuppressIPMetering}
    Result := Result + CurMeteredData;
{$ENDIF}
  Except
    On E: Exception do
      Result := 'Connection Exception ' + E.Message;
  end;
end;

function TISIndyTCPSvrSession.ShowServerDetails: AnsiString;
Var
  no: AnsiString;
begin
  Try
    if not(FServerObject is TIsIndyApplicationServer) then
      Result := ''
    Else
    Begin
      Result := TIsIndyApplicationServer(FServerObject).ServerDetailsAsText;
    End;
    Result := Result + #13#10'This Session is ' + PortId + #13#10;
    if Assigned(FOnSimpleRemoteAction) then
      no := ''
    Else
      no := 'No ';
    Result := Result + no + 'On Simple RemoteAction Assigned' + #13#10;
    if Assigned(FOnStringAction) then
      no := ''
    Else
      no := 'No ';
    Result := Result + no + 'On String Action Assigned' + #13#10;
    if Assigned(FOnAnsiStringAction) then
      no := ''
    Else
      no := 'No ';
    Result := Result + no + 'On Ansi String Action Assigned' + #13#10;

    Result := Result + #13#10 + 'State of Connections' +
      TGblRptComs.ReportObjectTypes;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TGblRptComs.ReportObjectTypes');
  End;
end;

function TISIndyTCPSvrSession.TextID: String;
begin
  if (Length(Address) < 1) Or (Address[1] = '<') then
    Result := 'Svr:' + IntToStr(LocalPort) + ' Disconnected ' + Address + ':' +
      IntToStr(Port)
  else
    Result := 'Svr:' + IntToStr(LocalPort) + ' Frm ' + Address + ':' +
      IntToStr(Port);
end;

procedure TISIndyTCPSvrSession.WasClosedForcfullyOrGracefully;
{ New thinking September 2026
  Session is Owned by Context }
begin
  Try
    if GblLogAllChlOpenClose then
      ApplicationFlagThreadMsg(Self,
        'TISIndyTCPSvrSession.WasClosedForcfullyOrGracefully ' + TextID);
    ClearReferences; // Session is closed must remove references
    if not FInSessionDestroy then
      inherited;
  Except
    On E: Exception do
    begin
      ApplicationFlagThreadMsg
        ('TISIndyTCPSvrSession.WasClosedForcfullyOrGracefully Exception ' +
        E.Message);
      ISIndyUtilsException(Self, E, '# WasClosedForcfullyOrGracefully');
    end;
  End;
end;

{ TBusyCheckCalls }

constructor TBusyCheckCalls.Create(Const AAllowence: TTimeSpan;
  Const AIpStr: string);
begin
  Try
    if Assigned(GlobalCountOfComsObjectTypes) then
      GlobalCountOfComsObjectTypes.CountComsTypes(Self, True);
    FBusyWatch := TStopwatch.StartNew;
    if FBusyWatch.IsHighResolution then
      FBusyWatch.Start
    else
      ISIndyUtilsException(Self, 'Not FBusyWatch.IsHighResolution');
    FIpStr := AIpStr;
    FLastCall := FBusyWatch.Elapsed;
    FAllowTo80 := FLastCall.Add(AAllowence);
    // FCountTo80 := 0;
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, 'NewBusyObject ' + TextData);
    TSingletonObjTimeSpanRecording.RecordObjectOnCreate(Self);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'NewBusyObject ' + TextData);
  End;
end;

destructor TBusyCheckCalls.Destroy;
begin
  TSingletonObjTimeSpanRecording.RecordObjectLifeTimeOnDestroy(Self,
    FBusyWatch.Elapsed);
  inherited;
  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);
end;

function TBusyCheckCalls.NotTooBusy(const AAllowance: TTimeSpan): Boolean;
var
  s: string;
  LocalAllocationTime, TM: TTimeSpan;
begin
  Result := True;
  Inc(FCountTo80);
  Inc(FTotalCalls);
  TM := FBusyWatch.Elapsed;
  if FCountTo80 > 80 then
  begin
    FCountTo80 := 0;
    s := 'Total Calls=' + IntToStr(FTotalCalls) + ' Time Elapsed is ' +
      TM.ToString + crlf + '     80 calls in ' + TM.Subtract(FAllowTo80)
      .ToString + crlf + '     Min Time for 80 calls is ' + AAllowance.ToString;
    s := FIpStr + crlf + s;
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, 'FCountTo80 At ' + FormatDateTime('nn:ss.z',
        now) + crlf + s);
    if TM > FAllowTo80 then
    begin
      s := TM.ToString + '= Tm > FAllowTo80 =' + FAllowTo80.ToString;
      s := s + ' #Is not too busy';
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, s);
    end
    else
    begin
      s := TM.ToString + '= Tm < FAllowTo80 =' + FAllowTo80.ToString;
      s := s + ' #Is too busy';
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, s);
      Result := false;
      LocalAllocationTime := FAllowTo80;
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, FIpStr + ':# Svr Busy FcountTo80 gap ' +
          TM.Subtract(LocalAllocationTime).ToString);

      while TM < LocalAllocationTime do
      begin
        if GblLogAllChlOpenClose then
          ISIndyUtilsException(Self, FIpStr + ':# Svr Busy Released in ' +
            TM.Subtract(LocalAllocationTime).ToString);
        // must be local as other threads will do check busy
        Sleep(2000); // hold thread for two seconds
        TM := FBusyWatch.Elapsed;
        if TM < LocalAllocationTime then
          ISIndyUtilsException(Self, FIpStr + ':# Waiting');
      end;
    end;
    TM := FBusyWatch.Elapsed;
    FAllowTo80 := TM.Add(AAllowance);
  end;
  FLastCall := TM;
end;

function TBusyCheckCalls.TextData: String;
Var
  TM: TTimeSpan;
begin
  TM := FBusyWatch.Elapsed;
  Result := FIpStr + ' Total Calls =' + IntToStr(FTotalCalls) + crlf +
    '(80) Count Now =' + IntToStr(FCountTo80) + crlf + 'Last Call =' +
    FLastCall.Subtract(TM).ToString + crlf + '80 not Before =' +
    FAllowTo80.Subtract(TM).ToString + crlf;
end;

{ TIsMonitorTCPAppServer.TTstThrd }

constructor TIsMonitorTCPAppServer.TTstThrd.Create(AIpAddress: String;
  APort: Integer);
begin
  FIpAddress := AIpAddress;
  FPort := APort;
  FreeOnTerminate := True;
  Inherited Create(false);
end;

procedure TIsMonitorTCPAppServer.TTstThrd.Execute;
Var
  FTst: TISIndyTCPClient;
  Rslt: String;
  Minutes: Integer;
begin
  Minutes := 0;
  FTst := nil;
  While not Terminated do
    Try
      Try
        FreeAndNil(FTst);
        FTst := TISIndyTCPClient.StartAccess(FIpAddress, FPort);
        if FTst <> nil then
          if FTst.Active then
          Begin
            FLastStatus := now;
            Rslt := FTst.ServerDetails;
            if Pos(':' + IntToStr(FPort), Rslt) < 7 then
              raise Exception.Create('Bad Details Returned');
            if FLogged then
              ApplicationFlagThreadMsg(Self, ' Return Success Ip=' + FIpAddress
                + ':' + IntToStr(FPort));
            FLogged := false;
          End
          Else If not FLogged then
          begin
            ApplicationFlagThreadMsg(Self, ' Failed Test Ip=' + FIpAddress + ':'
              + IntToStr(FPort));
            FLogged := True;
          end;
        if (Minutes mod 15) = 0 then
        Begin
          ISIndyUtilsException(Self, ' Test Period = ' + IntToStr(Minutes) +
            ' Minutes Time Now ' + FormatDateTime('dd mmm hh:nn:ss', now));
        End;
        Inc(Minutes);
        Sleep(60000);
      Finally
        FreeAndNil(FTst);
      End;
    Except
      On E: Exception do
      Begin
        FTst := nil;
        if Not FLogged then
          ISIndyUtilsException(Self, E, '#Execute');
        FLogged := True;
      End;
    End;
  Try
    FreeAndNil(FTst);
  Except

  End;
end;

{ TIsMonitorTCPAppServer }

constructor TIsMonitorTCPAppServer.Create(AIpAddress: String; APort: Integer);
begin
  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, True);
  FTestThread := TTstThrd.Create(AIpAddress, APort);
  ISIndyUtilsException(Self, '#Testing TCP Server on ' + AIpAddress + ':' +
    IntToStr(APort));
  Sleep(100);
  FTestThread.Resume;
end;

destructor TIsMonitorTCPAppServer.Destroy;
begin
  Try
    FTestThread.Terminate;
    inherited;
    if Assigned(GlobalCountOfComsObjectTypes) then
      GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TIsMonitorTCPAppServer.Destroy');
  end;
end;

function TIsMonitorTCPAppServer.GetLastStatus: TDateTime;
begin
  if FTestThread <> nil then
    Result := FTestThread.FLastStatus
  else
    Result := 0.0;
end;

{ TServerCleanup }

constructor TServerCleanup.Create(AOwner: TIdTcpServer);
begin
  FOwner := AOwner;
  inherited Create(True);
  FreeOnTerminate := True;
  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, True);
end;

destructor TServerCleanup.Destroy;
begin
  ApplicationFlagThreadMsg('Destroy Cleanup Object');
  if FOwner is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FOwner).FCleanupThread := nil;
  FOwner := nil;

  if Assigned(GlobalCountOfComsObjectTypes) then
    GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);
  ApplicationFlagThreadMsg('Destroy Cleanup Before inherited Object');
  inherited;
  ApplicationFlagThreadMsg('Destroy Cleanup After inherited Object');
end;

procedure TServerCleanup.Execute;
Var
  Srv: TIsIndyApplicationServer;
  SecondCount, LogCount: Integer;
begin
  if FOwner is TIsIndyApplicationServer then
    Srv := TIsIndyApplicationServer(FOwner)
  Else
    Exit;

  SecondCount := 0;
  LogCount := 0;

  while Not Terminated do
    Try
      Dec(SecondCount);

      if FOwner = nil then
        Terminate
      else if SecondCount < 1 then
      Begin
        ApplicationFlagThreadMsg('Start Cleanup');

        if FOwner = Srv then
{$IFDEF FPC}
          // Srv.ConfirmRegisteredConnections
          ApplicationFlagThreadMsg(Self, 'Cleanup Disabled')
{$ELSE}
{$IFDEF DoApplicationObjectCleanup}
          Srv.ConfirmRegisteredConnections
{$ELSE}
          ApplicationFlagThreadMsg(Self, 'Cleanup Disabled')
{$ENDIF}
{$ENDIF}
        Else
          Terminate;

        ApplicationFlagThreadMsg('Cleanup Done ConfirmRegisteredConnections');
        if FOwner = nil then
          Terminate;

        if Terminated then
        Begin
          ApplicationFlagThreadMsg('Cleanup Terminated 1');
          Exit;
        End;

        If (FOwner = Srv) and (Srv.FDoNextCloseEvent < now) then
        Begin
{$IFDEF DoApplicationObjectCleanup}
          Srv.CloseInactiveSessions;
{$ELSE}
          ApplicationFlagThreadMsg(Self, 'Cleanup Disabled');
{$ENDIF}
          ApplicationFlagThreadMsg('Cleanup Done CloseInactiveSessions');
        end;
        SecondCount := 30; // 30 seconds
        Dec(LogCount);
        if LogCount < 1 then
        Begin
          ISIndyUtilsException('', '');
          ISIndyUtilsException(Self, '#TimeStamp'#13#10 +
            FormatDateTime(' dd mmm hh:nn:ss', now) + crlf);
          LogCount := 60;
          // every half hour
        End;
        ApplicationFlagThreadMsg('End Cleanup');
      End;
      if not Terminated then
        Sleep(1000)
      else
        ApplicationFlagThreadMsg('Cleanup Terminated Final');
    Except
      On E: Exception do
      begin
        WritelnIfPossible('Cleanup Execute Exception>>' + E.Message);
        ISIndyUtilsException(Self, E, '#Execute');
        Terminate;
      end;
    End;
  ApplicationFlagThreadMsg('Cleanup Terminated OuterLoop');
end;

end.
