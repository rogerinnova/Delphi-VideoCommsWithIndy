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
{$IFDEF FPC} Copy Test SysUtils, Classes, SyncObjs,
{$ELSE}
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
{$ENDIF}
  IdContext, inifiles, IdTCPConnection, IdGlobal, IdYarn,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, ISStrUtl,
  IsArrayLib,
{$IFDEF Nextgen}
  IsNextGenPickup,
{$ENDIF}
  ISRemoteConnectionIndyTCPObjs;

type
  TComandActionString = Function(AData: String; ATcpSession: TISIndyTCPBase)
    : String of Object;
  // TActionPassThru = Procedure(ADate: AnsiString;
  // ATcpSession: TISIndyTCPBase)of Object;

  TBusyCheckCalls = class(TObject)
  private
    FLastCall, FAllowTo80: TDateTime;
    FCountTo80, FTotalCalls: Integer;
    FIpStr: string;
  Public
    constructor Create(Const AAllowence: TDateTime; Const AIpStr: string);
    Function NotTooBusy(const AAllowance: TDateTime): Boolean;
    Function TextData: String;
  end;

  TIsIndyTCPServerContext = class;

  TISIndyTCPSvrSession = class(TISIndyTCPBase)
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
    FTimeOutAt, FPermittedIdleTime: TDateTime;
    FServerObject: TIdTcpServer;
    FServerConnext: TIsIndyTCPServerContext;
    FRegisteredAs: AnsiString;
    FOnSimpleRemoteAction: TComandActionAnsi;
    FOnStringAction: TComandActionString;
    FLockSession: TCriticalSection;
    function ShowServerDetails: AnsiString;
    function ShowServerConnections(ARegData: AnsiString): AnsiString;
    function SetServerConnections(AConnectData: AnsiString): AnsiString;
    // Link to Advertised - cServerLink
    // Start new followon  - cNewIPLink
    Procedure SetFullDuplex(Val: Boolean); override;
    Procedure ClearReferences;
    Function ResetServer(AConnectData: AnsiString): AnsiString;
    function DropCoupledSession: AnsiString;
  protected
    FCountTo80: Integer;
    FNext80TransactionAllowance: TDateTime;
    FOnLogMsg: TISIndyLogEvent;
    // function ProcessSimpleRemoteActionTxn(ACommand: AnsiString):AnsiString;
    Function CheckWriteBusy: Boolean; override;
    Function CheckReadBusy: Boolean; override;
    function DoSimpleRemoteAction(ACommand: AnsiString): AnsiString;
    Procedure DoFileTransferBlockDnLd(ACommand: AnsiString);
    Procedure DoFileTransferBlockUpLd(ADataIn: AnsiString);
    procedure WasClosedForcfullyOrGracefully; Override;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Function AcceptStart: Boolean;
    Function ProcessNextTransaction: Boolean;
    // function PackAServerFile(const AFileName: AnsiString): AnsiString;
    function IsTimedOut(ACloseIfTrue: Boolean = false): Boolean;
    function PackAServerFileSize(const AFileName: AnsiString): AnsiString;
    // function PackAPutServerFileResponse(const AFileData: AnsiString)
    // : AnsiString;
    function ConnectionStatusText: AnsiString;
    function LinkedTo(APort, BPort: Integer): Integer;
    function TextID: String; override;
    Procedure DropSrvrReferences;
    Procedure LogAMessage(AMessage: String); override;
    Property OnSimpleRemoteAction: TComandActionAnsi Read FOnSimpleRemoteAction
      Write FOnSimpleRemoteAction;
    Property OnStringAction: TComandActionString Read FOnStringAction
      Write FOnStringAction;
    // Property OnFullDuplexIncomingAction:TActionPassThru Read FOnFullDuplexIncomingAction write FOnFullDuplexIncomingAction;
    Property OnLogMsg: TISIndyLogEvent Read FOnLogMsg write FOnLogMsg;
  end;

  { TIsIndyTCPServerContext }

  TIsIndyTCPServerContext = class(TIdServerContext)
  Private
    FTcpRef: TISIndyTCPSvrSession;
    FDestroying: Boolean;
    Function RawTcpRef: TISIndyTCPSvrSession;
  Protected
    function Run: Boolean; override;
  Public
    constructor Create(AConnection: TIdTCPConnection; AYarn: TIdYarn;
      AList: TIdContextThreadList = nil); override;
    Destructor Destroy; override;
    Function TcpRef: TISIndyTCPSvrSession;
    Function CtxTextId: string;
    Procedure ReleaseOldRef;
  end;

  { TIsIndyApplicationServer }

  TIsIndyApplicationServer = class(TIdTcpServer)
  Private
    FServerClosing: Boolean;
    FLogsMissed: Integer;
    fCurrentAddresses, FLogList: TStringList;
    fCurrentSessionObjects: TList;
    FBusyLock: TCriticalSection;
    FListLock: TCriticalSection;
    FOnSessionSimpleRemoteAction: TComandActionAnsi;
    FOnSessionAnsiStringAction: TComandActionAnsi;
    FOnSessionStringAction: TComandActionString;
    FServerTcpSessions: Integer;
    FListOfRegConnections: TStringList;
    FTimeLimitFor80Calls, FTimeLimitFor80Transactions: TDateTime;
    fIdleTimePermitted: TDateTime;
    FResetStartTime: TDateTime; // if > now then reset/reject calls;
    function GetMaxCallsPerMinute: Integer;
    function GetSessionByCallingPort(APeerPortNo: Integer)
      : TISIndyTCPSvrSession;
    // Find ASession on the server given the calling port
    Function ListOfRegConnections: TStringList;
    Function LocalContext(AContext: TIdContext): TIsIndyTCPServerContext;
    Function ResetSvr(AData: AnsiString): AnsiString;
    // procedure IsIdTCPSrvrContextCreated(AContext: TIdContext);
    procedure IsIdTCPSrvrConnect(AContext: TIdContext);
    procedure IsIdTCPSvrSessionExecute(AContext: TIdContext);
    procedure CheckBusyOnConnect(AContext: TIsIndyTCPServerContext);
    // Connections on Ip Address
    procedure CheckBusyOnPacket(ASession: TISIndyTCPSvrSession);
    // packets on channel
    procedure SetMaxCallsperminute(AValue: Integer);
    procedure LoadServerIniData;
    Procedure CloseInactiveSessions;
    Procedure AddSession(ASession: TISIndyTCPSvrSession);
    Procedure DropSession(ASession: TISIndyTCPSvrSession);
    Procedure DropAllCurrentSessions; // On Closing server
  Protected
    procedure Shutdown; override;
    procedure AddLogMessage(ATextID, AMsg: String);
  Public
    Constructor Create(AOwner: TComponent);
    Destructor Destroy; override;
    Function ServerDetailsAsText: AnsiString;
    Function AllConnectionsAsText: AnsiString;
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
    Property IdleTimePermitted: TDateTime Read fIdleTimePermitted
      Write fIdleTimePermitted;
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

{$IFDEF NextGen}
Function cRemoteResetServer: AnsiString;
Function cRemoteServerDetails: AnsiString;
// Function cRemoteDbLog: AnsiString;
Function cRecoverRemoteFile: AnsiString;
Function cRemoteFileSize: AnsiString;
Function cRemoteForceClose: AnsiString;
// Function cRemoteServerConnections: AnsiString;
// Function cRemoteSetServerRelay: AnsiString;
// Function cServerLink: AnsiString;
// Function cNewIPLink: AnsiString;

{$ELSE}

Const
  cRemoteResetServer: AnsiString = 'RemoteResetServer#';
  cRemoteServerDetails: AnsiString = 'RemoteServerDetails#';
  // cRemoteDbLog: AnsiString = 'RemoteDbLog';
  cRecoverRemoteFile: AnsiString = 'RecoverRemoteFile';
  cRemoteFileSize: AnsiString = 'RemoteFileSize';
  cPutRemoteFile: AnsiString = 'PutRemoteFile';
  cRemoteForceClose: AnsiString = 'RemoteForceClose';
{$ENDIF}

implementation

uses {MonitorTestObjs,} ISIndyUtils, IsGeneralLib,
  IsGblLogCheck;

{$IFDEF NextGen}

Function cRemoteForceClose: AnsiString;
Begin
  Result := 'RemoteForceClose';
end;

Function cRemoteResetServer: AnsiString;
Begin
  Result := 'RemoteResetServer#';
End;

Function cRemoteServerDetails: AnsiString;
begin
  Result := 'RemoteServerDetails#';
end;

// Function cRemoteDbLog: AnsiString;
// begin
// Result := 'RemoteDbLog';
// end;

Function cRecoverRemoteFile: AnsiString;
begin
  Result := 'RecoverRemoteFile';
end;

Function cRemoteFileSize: AnsiString;
begin
  Result := 'RemoteFileSize';
end;

{$ENDIF}

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
Const
  cStart80TransactionAllowence = 1 / 24 / 60 / 60 / 200; // 5msec

procedure TIsIndyApplicationServer.AddLogMessage(ATextID, AMsg: String);

begin
  // Exit;//Temp Test

  Try
    if CLogAll then
      ISIndyUtilsException(ATextID, AMsg);

    If FLogsMissed > 0 then
      ISIndyUtilsException(Self, '# Missed Msg<' + IntToStr(FLogsMissed) +
        '> AddLogMessage>>' + AMsg);
    If FListLock.TryEnter then
      try
        If FLogList = nil then
          FLogList := TStringList.Create;
        if FLogList.Count < 100 then
          FLogList.Add(FormatDateTime('nn:ss.zzz ', now) + ATextID + ':' +
            ' : ' + AMsg)
      finally
        FListLock.Release
      end
    Else
      Inc(FLogsMissed);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '#' + ' AddLogMessage');
  end;
end;

procedure TIsIndyApplicationServer.AddSession(ASession: TISIndyTCPSvrSession);
Var
  Idx: Integer;
begin
  if fCurrentSessionObjects = nil then
    fCurrentSessionObjects := TList.Create;
  FListLock.Acquire;
  Try
    Idx := fCurrentSessionObjects.IndexOf(ASession);
    if Idx < 0 then
      fCurrentSessionObjects.Add(ASession);
  Finally
    FListLock.Release;
  end;
end;

function TIsIndyApplicationServer.AllConnectionsAsText: AnsiString;
Var
  i: Integer;
  Obj: TISIndyTCPSvrSession;
begin
  Try
    if fCurrentSessionObjects = nil then
      Result := 'No Current Sessions' + #10#13
    Else
    begin
      Result := IntToStr(fCurrentSessionObjects.Count) +
        ' Current Sessions' + #10#13;
      for i := 0 to fCurrentSessionObjects.Count - 1 do
      Begin
        if TObject(fCurrentSessionObjects[i]) is TISIndyTCPSvrSession then
          Obj := TISIndyTCPSvrSession(fCurrentSessionObjects[i])
        else
          Obj := nil;
        if Obj <> nil then
          if Obj.FCoupledSession <> nil then
            Result := Result + Obj.TextID + ' is linked' + #10#13
          else
            Result := Result + Obj.TextID + #10#13;
      end;
    end;
    if FListOfRegConnections = nil then
      Result := Result + 'No Advertised Sessions' + #10#13
    Else
    begin
      Result := Result + IntToStr(FListOfRegConnections.Count) +
        ' Advertised Sessions' + #10#13;
      for i := 0 to FListOfRegConnections.Count - 1 do
      Begin
        if FListOfRegConnections.Objects[i] is TISIndyTCPSvrSession then
          Obj := TISIndyTCPSvrSession(FListOfRegConnections.Objects[i])
        else
          Obj := nil;
        if Obj = nil then
          Result := Result + FListOfRegConnections[i] + ' == ' +
            Obj.TextID + #10#13
        else if Obj.FCoupledSession <> nil then
          Result := Result + FListOfRegConnections[i] + ' == ' + Obj.TextID +
            ' is linked' + #10#13
        else
          Result := Result + FListOfRegConnections[i] + ' == ' +
            Obj.TextID + #10#13;
      end;
    end;
  Except
    On E: Exception do
      Result := Result + #10#13 + 'Exception::' + E.Message;
  End;
end;

function TIsIndyApplicationServer.AllRegisteredConnections
  (AConnection: TISIndyTCPSvrSession): AnsiString;
Var
  Index, i: Integer;
begin
  ListOfRegConnections;
  if AConnection <> nil then
    if AConnection.FRegisteredAs <> '' then
      if AConnection.CheckConnection then
      Begin
        Index := FListOfRegConnections.IndexOf(AConnection.FRegisteredAs);
        if GblRptRegConnectiononSrvr then
          If Index < 0 then
            AddLogMessage('Server', 'Add Registered Connection::' +
              AConnection.FRegisteredAs)
          Else
            AddLogMessage('Server', 'Existing Registered Connection::' +
              AConnection.FRegisteredAs);

        If Index < 0 then
          FListOfRegConnections.AddObject(AConnection.FRegisteredAs,
            AConnection)
        Else
          FListOfRegConnections.Objects[index] := AConnection;
      end;

  if FListOfRegConnections.Count < 1 then
    Result := 'No Connections'
  else
    Result := '';
  Try
    For i := FListOfRegConnections.Count - 1 downto 0 do
      if FListOfRegConnections.Objects[i] is TISIndyTCPSvrSession then
      Begin
        if TISIndyTCPSvrSession(FListOfRegConnections.Objects[i]).CheckConnection
        then
          Result := Result + TISIndyTCPSvrSession
            (FListOfRegConnections.Objects[i]).ConnectionStatusText + #13#10
        Else
        Begin
          FListOfRegConnections.Objects[i] := nil;
          FListOfRegConnections.Delete(i);
          Result := Result + 'Closed Object at ' + IntToStr(i) + #13#10;
        End;
      End
      else if FListOfRegConnections.Objects[i] = nil then
        Result := Result + 'Nil Object at ' + IntToStr(i) + #13#10
      else
        Try
          FListOfRegConnections.Objects[i] := nil;
          FListOfRegConnections.Delete(i);
          Result := Result + 'Unknown Object at ' + IntToStr(i) + #13#10;
        Except
          On E: Exception do
            Result := Result + 'Exception::' + E.Message + ' at ' +
              IntToStr(i) + #13#10;
        end;
  Except
    On E: Exception do
      Result := Result + 'Exception::' + E.Message;
  end;
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
  Try
    IpStr := AContext.TcpRef.Address;
    FBusyLock.Enter;
    try
      if CurrentAddresses.Find(IpStr, IpIdx) then
      Begin
        IObj := TBusyCheckCalls(fCurrentAddresses.Objects[IpIdx]);
      end
      else
      begin
        IObj := TBusyCheckCalls.Create(FTimeLimitFor80Calls, IpStr);
        fCurrentAddresses.AddObject(IpStr, IObj);
      end;
      if IObj <> nil then
        if not IObj.NotTooBusy(FTimeLimitFor80Calls) then
          AddLogMessage(IpStr, 'Too Busy');
    finally
      FBusyLock.Release;
    end;
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
  LocalAllocationTime, TM: TDateTime;

  // packets on channel
  s: string;
begin
  if FServerClosing then
    Exit;
  if ASession = nil then
    Exit;
  Try
    Inc(ASession.FCountTo80);
    if ASession.FCountTo80 > 80 then
    begin
      TM := now;
      ASession.FCountTo80 := 0;
      // ISIndyUtilsException(Self, ASession.TextId+' #FcountTo80 At ' +
      // FormatDateTime('nn:ss.z', Tm));
      LocalAllocationTime := ASession.FNext80TransactionAllowance;
      if TM > LocalAllocationTime then
      begin
        // s := 'Time is ' + FormatDateTime('nn:ss.z', Tm) + crlf +
        // '     80 Transactions in ' + FormatDateTime('nn:ss.z',
        // Tm - LocalAllocationTime) + crlf +
        // '     Min Time for 80 Transactions is ' + FormatDateTime('ss.zzz',
        // FTimeLimitFor80Transactions) + ' seconds';
        s := ASession.TextID + crlf + s;
        // ISIndyUtilsException(Self, s);
        ASession.FCountTo80 := 0;
      end
      else
      Begin
        ISIndyUtilsException(Self, ASession.TextID +
          '# Svr Busy FcountTo80 too early by ' + FormatDateTime('nn.ss.z',
          LocalAllocationTime - TM));
        AddLogMessage(ASession.TextID, 'Too Busy');
        ISIndyUtilsException(Self, '#Svr Busy will Release at ' +
          FormatDateTime('nn:ss.zzz ', LocalAllocationTime));
        while TM < LocalAllocationTime do
        begin
          ISIndyUtilsException(Self,
            'Waiting' + FormatDateTime('nn:ss.zzz ', TM));
          // must be local as other threads will do check busy
          Sleep(2000); // hold thread for two seconds
          TM := now;
        end;
      end;
      ASession.FNext80TransactionAllowance := TM + FTimeLimitFor80Transactions;

      // ISIndyUtilsException(Self,ASession.TextId+'# Next Allocation ' +
      // FormatDateTime('hh:nn:ss.zzz', ASession.FNext80TransactionAllowance));
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
  LocalList: TList;
  Idx: Integer;
begin
  Try
    if fCurrentSessionObjects = nil then
      Exit;
    LocalList := TList.Create;
    try
      // Not Locking the list but not changin it??
      for Idx := 0 to fCurrentSessionObjects.Count - 1 do
        if fCurrentSessionObjects[Idx] <> nil then
          if TObject(fCurrentSessionObjects[Idx]) is TISIndyTCPSvrSession then
          Begin
            ThisSession := TISIndyTCPSvrSession(fCurrentSessionObjects[Idx]);
            If ThisSession.IsTimedOut then
              LocalList.Add(ThisSession);
          end;

      for Idx := 0 to LocalList.Count - 1 do
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
    End;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'CloseInactiveSessions');
  End;
end;

constructor TIsIndyApplicationServer.Create(AOwner: TComponent);
Var
  LogStart: String;
begin
  FServerClosing := false;
  // Four Seconds;
  FTimeLimitFor80Transactions := cStart80TransactionAllowence;
  FListLock := TCriticalSection.Create;
  FBusyLock := TCriticalSection.Create;
  Inherited;
  ContextClass := TIsIndyTCPServerContext;
  OnConnect := IsIdTCPSrvrConnect;
  OnExecute := IsIdTCPSvrSessionExecute;
  // OnContextCreated := IsIdTCPSrvrContextCreated;
  MaxCallsPerMinute := 800;
  ISIndyUtilsException(Self,
    '#' + 'New IsIndyApplicationServer Max Calls Per Min ' +
    IntToStr(MaxCallsPerMinute));
  LoadServerIniData;
  LogStart := 'After Ini' + crlf + 'IsIndyApplicationServer Max Calls Per Min '
    + IntToStr(MaxCallsPerMinute) + crlf + 'Session Idle Timeout =' +
    FormatDateTime('hh:mm:ss', fIdleTimePermitted);
  ISIndyUtilsException(Self, LogStart);
end;

function TIsIndyApplicationServer.CurrentAddressDetails: String;
var
  BObj: TBusyCheckCalls;
  i: Integer;
begin
  Result := '';
  if fCurrentAddresses = nil then
    Exit;
  if fCurrentAddresses.Count < 1 then
    Exit;

  for i := 0 to fCurrentAddresses.Count - 1 do
  begin
    if fCurrentAddresses.Objects[i] is TBusyCheckCalls then
    begin
      BObj := TBusyCheckCalls(fCurrentAddresses.Objects[i]);
      Result := Result + BObj.TextData + crlf;
    End
    Else
      Result := Result + fCurrentAddresses[i] + crlf;
  end;
end;

function TIsIndyApplicationServer.CurrentAddresses: TStringList;
begin
  if fCurrentAddresses = nil then
  begin
    fCurrentAddresses := TStringList.Create;
    fCurrentAddresses.Sorted := True;
    fCurrentAddresses.OwnsObjects := True;
    // TBusyCheckCalls
  end;
  Result := fCurrentAddresses;
end;

destructor TIsIndyApplicationServer.Destroy;
begin
  Try
    DropAllCurrentSessions;
    fCurrentSessionObjects.Free;
    FListOfRegConnections.Free;
    FLogList.Free;
    FListLock.Free;
    FBusyLock.Free;
    fCurrentAddresses.Free; // Owns Objects;
    // FreeSListWObjects(fCurrentAddresses);
    // fCurrentAddresses:=nil;
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TIsIndyApplicationServer.Destroy');
  end;
  inherited;
end;

procedure TIsIndyApplicationServer.DropAllCurrentSessions;
Var
  Idx: Integer;
  ThisObj: TISIndyTCPSvrSession;
begin
  if fCurrentSessionObjects <> nil then
    While fCurrentSessionObjects.Count > 0 do
    Begin
      FListLock.Acquire;
      Try
        if TObject(fCurrentSessionObjects[0]) is TISIndyTCPSvrSession then
          ThisObj := TISIndyTCPSvrSession(fCurrentSessionObjects[0])
        else
          ThisObj := nil;
      finally
        FListLock.Release;
      end;
      if ThisObj <> nil then
        ThisObj.CloseConnection;
      Sleep(100);
    end;
  FreeAndNil(fCurrentSessionObjects);
end;

procedure TIsIndyApplicationServer.DropRegConnection
  (AConnection: TISIndyTCPSvrSession);
Var
  Index: Integer;
begin
  if AConnection = nil then
    Exit;
  if GblRptMakeConnectionOnSrvr then
    AddLogMessage('Server', 'TIsIndyApplicationServer.DropRegConnection');
  If FListOfRegConnections = nil Then
    Exit;
  FListLock.Acquire;
  Try
    Index := FListOfRegConnections.IndexOfObject(AConnection);
    if Index >= 0 then
      FListOfRegConnections.Delete(Index);
  Finally
    FListLock.Release;
  end;
end;

procedure TIsIndyApplicationServer.DropSession(ASession: TISIndyTCPSvrSession);
Var
  Idx: Integer;
begin
  Try
    if ASession.FServerObject = Self then
      ASession.FServerObject := nil;

    FListLock.Acquire;
    Try
      DropRegConnection(ASession);
      Dec(FServerTcpSessions);
      if fCurrentSessionObjects = nil then
        Exit;
      if fCurrentSessionObjects = nil then
        Idx := -1
      Else
        Idx := fCurrentSessionObjects.IndexOf(ASession);
      if Idx < 0 then
        ISIndyUtilsException(Self, 'Session not found')
      else
      begin
        fCurrentSessionObjects[Idx] := nil;
        fCurrentSessionObjects.Delete(Idx);
      end;
      if FListOfRegConnections = nil then
        Idx := -1
      Else
        Idx := FListOfRegConnections.IndexOfObject(ASession);
      if Idx < 0 then
      else
      begin
        FListOfRegConnections.Objects[Idx] := nil;
        FListOfRegConnections.Delete(Idx);
      end;
    Finally
      FListLock.Release;
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, ' Drop Session');
  end;
end;

function TIsIndyApplicationServer.GetMaxCallsPerMinute: Integer;
begin
  Result := Round(80 / (FTimeLimitFor80Calls * 24 * 60));
end;

function TIsIndyApplicationServer.GetRegConnectionFor(ARegString: AnsiString)
  : TISIndyTCPBase;
Var
  Inx: Integer;
begin
  Result := nil;
  Try
    If ListOfRegConnections.Find(ARegString, Inx) then
      Result := FListOfRegConnections.Objects[Inx] as TISIndyTCPBase;
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
begin
  Result := nil;
  if APeerPortNo < 1 then
    Exit;
  if fCurrentSessionObjects = nil then
    Exit;
  i := 0;
  if FListLock.TryEnter then
    try
      while (i < fCurrentSessionObjects.Count) and (Result = nil) do
      begin
        Obj := fCurrentSessionObjects[i];
        if Obj is TISIndyTCPSvrSession then
        Begin
          ThisObj := TISIndyTCPSvrSession(Obj);
          if ThisObj.Port = APeerPortNo then
            Result := ThisObj;
        end;
        Inc(i);
      end;
    finally
      FListLock.Leave;
    end;
end;

procedure TIsIndyApplicationServer.IsIdTCPSvrSessionExecute
  (AContext: TIdContext);
Var
  LContext: TIsIndyTCPServerContext;
  LConnection: TIdTCPConnection;
  TcpCtx: TISIndyTCPSvrSession;
begin
  if AContext = nil then
    Exit;
  TcpCtx := nil;
  LContext := LocalContext(AContext);
  Try
    if LContext = nil then
      ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Nil Local Context')
    else
      TcpCtx := LContext.RawTcpRef;

    if TcpCtx = nil then
    begin
      ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Nil TcpCtx');
      Exit;
    end;

    LConnection := LContext.Connection;
    if TcpCtx.FConnection <> LConnection then
    begin
      if LConnection = nil then
        ISIndyUtilsException(Self,
          '#IsIdTCPSvrSessionExecute Context Nil Coonection')
      else
        ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Wrong TcpCtx ::' +
          TcpCtx.TextID);
      Exit;
    end;

    if LConnection <> nil then
      // while LConnection.Connected do
      if LConnection.Connected then
      begin
        if FResetStartTime > 0.01 then
          if FResetStartTime < now then
            FResetStartTime := 0.0
          else
          begin
            ISIndyUtilsException(Self, '# Closing ResetStartTime=' +
              FormatDateTime('dd hh:nn:ss.zzz', FResetStartTime));
            LConnection.Disconnect;
            Sleep(1000);
            Exit;
          end;
        if TcpCtx <> nil then
          If not TcpCtx.ProcessNextTransaction Then
          Begin
            if GblLogAllChlOpenClose then
            begin
              AddLogMessage(TcpCtx.TextID, 'End Context Run Channel');
              ISIndyUtilsException(Self, TcpCtx.TextID + '# End Session');
            end;
            TcpCtx.CloseGracefully;
            Sleep(1000);
          end;
      end;
  Except
    On E: Exception do
    Begin
      Try
        AddLogMessage('Server IsIdTCPSvrSessionExecute Ex:', E.Message);
        if TcpCtx <> nil then
          TcpCtx.LogAMessage('Execute Error:' + E.Message);
        if LConnection <> nil then
        begin
          If LConnection.IOHandler <> nil then
            LConnection.IOHandler.CloseGracefully;
        end
        else if LContext.Connection <> nil then
          if LContext.Connection.IOHandler <> nil then
            LContext.Connection.IOHandler.CloseGracefully;
      Except
        On ee: Exception do
        Begin
          Try
            AddLogMessage('Double Exeption:', ee.Message);
          Except
          end;
        end;
      end;
    End;
  End;
end;

procedure TIsIndyApplicationServer.IsIdTCPSrvrConnect(AContext: TIdContext);
Var
  LContext: TIsIndyTCPServerContext;
  ThisSession: TISIndyTCPSvrSession;
begin
  Try
    LContext := LocalContext(AContext);

    LContext.ReleaseOldRef;
    ThisSession := LContext.TcpRef;
    CheckBusyOnConnect(LContext);

    ThisSession.FServerObject := Self;
    Inc(FServerTcpSessions);
    ThisSession.OnLogMsg := AddLogMessage;
    ThisSession.OnAnsiStringAction := OnSessionAnsiStringAction;
    ThisSession.OnStringAction := OnSessionStringAction;
    ThisSession.OnSimpleRemoteAction := OnSessionSimpleRemoteAction;
    if GblRptMakeConnectionOnSrvr then
    Begin
      ISIndyUtilsException(Self, 'On Connect::' + IntToStr(FServerTcpSessions));
      AddLogMessage('Server', 'On Connect::' + IntToStr(FServerTcpSessions));
    End;
    if FResetStartTime > 0.01 then
      if FResetStartTime > now then
        FResetStartTime := 0.0
      else
        LContext.FTcpRef.CloseGracefully;
    // accept no calls in reset period;

    if FResetStartTime < 0.001 then
      If ThisSession.AcceptStart then
      Begin
        if GblLogAllChlOpenClose then
        begin
          ISIndyUtilsException(Self, LContext.FTcpRef.TextID + '# Run Channel');
          AddLogMessage(LContext.CtxTextId, 'Run Channel');
        end;
      end
      else
        LContext.FTcpRef.CloseGracefully;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'IsIdTCPSrvrConnect');
      AddLogMessage('Server', 'OnConnect Error:' + E.Message);
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
  Linked, AllOk, BothCoupled, Together: Boolean;
  ThisPort, ThatPort: Integer;
  RegObj, ThisPortObj, ThatPortObj: TISIndyTCPSvrSession;
  LinkToReg: AnsiString;
  Ary: TArrayOfAnsiStrings;
  LenAry, i, ThisSessionIdx, ThisRegIdx: Integer;
begin
  Try
    Result := cIsLinkedOnServer + 'CE#'; // CoupleError

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
                Result := cIsLinkedOnServer + 'CK#';
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

      ThisSessionIdx := -1;
      if ASession <> nil then
        if fCurrentSessionObjects = nil then
          ISIndyUtilsException(Self, 'Session Connected =' + ASession.TextID +
            ' but no fCurrentSessionObjects')
        Else
          ThisSessionIdx := fCurrentSessionObjects.IndexOf(ASession);

      ThisRegIdx := -1;
      if FListOfRegConnections <> nil then
        if LinkToReg <> '' then
          ThisRegIdx := FListOfRegConnections.IndexOf(LinkToReg);

      RegObj := nil;
      if ThisRegIdx < 0 then
      else if FListOfRegConnections.Objects[ThisRegIdx] is TISIndyTCPSvrSession
      then
        RegObj := TISIndyTCPSvrSession(FListOfRegConnections.Objects
          [ThisRegIdx]);

      ThisPortObj := GetSessionByCallingPort(ThisPort);
      ThatPortObj := GetSessionByCallingPort(ThatPort);
      // (CoupleError,NullCouple,ThisPortExists,ThatPortExists,ThisPortCoupled,ThatPortCoupled,BothCoupled,CoupledTogether,CoupleLinkOK);
      Result := cIsLinkedOnServer + 'CE#';
      if RegObj = nil then
      begin
        if CoupledTogether(ThisPortObj, ThatPortObj) then
          Result := cIsLinkedOnServer + 'CT#'
        else
        begin
          if ThisPortObj <> nil then
          Begin
            Result := cIsLinkedOnServer + 'NI#'; // ThisPortExists
            if ThisPortObj.FCoupledSession <> nil then
              Result := cIsLinkedOnServer + 'CI#'; // ThisPortCoupled
            if ThatPortObj = nil then
              Exit;
            if ThatPortObj.FCoupledSession <> nil then
              if ThatPortObj = ThisPortObj then
                Exit
              else if ThisPortObj.FCoupledSession <> nil then
                Result := cIsLinkedOnServer + 'CB#' // BothCoupled
              Else
                Result := cIsLinkedOnServer + 'CA#'; // ThatPortCoupled
          end
          else if ThatPortObj <> nil then
            if ThatPortObj.FCoupledSession <> nil then
              Result := cIsLinkedOnServer + 'CA#' // ThatPortCoupled
            Else
              Result := cIsLinkedOnServer + 'NA#'; // ThatPortExists
        end
      end
      else
      Begin
        // (CoupleError,RegButNoLinks,NullCouple,ThisPortExists,ThatPortExists,ThisPortCoupled,ThatPortCoupled,BothCoupled,CoupledTogether,CoupleLinkOK);
        Case RegObj.LinkedTo(ThisPort, ThatPort) of
          0:
            Result := cIsLinkedOnServer + 'RO#'; // RegButNoLinks
          5, 6:
            Result := cIsLinkedOnServer + 'CO#'; // CoupleLinkOK
          1, 2:
            Result := cIsLinkedOnServer + 'RO#'; // RegButNoLinks
          3:
            Result := cIsLinkedOnServer + 'CI#'; // ThisPortCoupled
          4:
            Result := cIsLinkedOnServer + 'CA#'; // ThatPortCoupled
        end;
      end
    end;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'LinkStatusAsResponse');
      Result := cIsLinkedOnServer + 'CE#'; // CoupledError
    end;
  end;
end;

function TIsIndyApplicationServer.ListOfRegConnections: TStringList;
begin
  if FListOfRegConnections = nil then
  Begin
    FListOfRegConnections := TStringList.Create;
    FListOfRegConnections.Sorted := True;
    FListOfRegConnections.Duplicates := dupError;
  end;
  Result := FListOfRegConnections;
end;

procedure TIsIndyApplicationServer.LoadServerIniData;
Var
  IdleSeconds: Integer;
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
        fIdleTimePermitted := IdleSeconds / (24 * 60 * 60);
      finally
        IniFile.Free;
      end;
    end;
end;

function TIsIndyApplicationServer.LocalContext(AContext: TIdContext)
  : TIsIndyTCPServerContext;
begin
  if AContext is TIsIndyTCPServerContext then
    Result := TIsIndyTCPServerContext(AContext)
  Else
    raise Exception.Create('Error AContext is Not TIsIndyTCPServerContext');
end;

function TIsIndyApplicationServer.ReadLogMessage: String;
begin
  if FLogList = nil then
    Result := ''
  Else
    Try
      While Not FListLock.TryEnter do
        Sleep(1000);
      Result := FLogList.Text;

      if FLogsMissed > 0 then
        Result := Result + #13#10 + 'Missed msgs=' + IntToStr(FLogsMissed);
      FLogList.Clear;
      FLogsMissed := 0;
    Finally
      FListLock.Release;
    End;
  CloseInactiveSessions;
end;

function TIsIndyApplicationServer.RemotePortRegAsString(ARegNo,
  AConnectNo: Integer): AnsiString;
Var
  RegOb, ConnectObj: TISIndyTCPSvrSession;
  No1, No2: Integer;
  RegNam: AnsiString;
begin
  RegOb := nil;
  ConnectObj := nil;
  Result := '##';
  No1 := 0;
  No2 := 0;
  try
    if fCurrentSessionObjects = nil then
      Exit; // No Connections

    If (FListOfRegConnections <> nil) and (ARegNo > -1) and
      (ARegNo < FListOfRegConnections.Count) then
      if FListOfRegConnections.Objects[ARegNo] is TISIndyTCPSvrSession then
        RegOb := TISIndyTCPSvrSession(FListOfRegConnections.Objects[ARegNo]);

    if AConnectNo >= fCurrentSessionObjects.Count then
      AConnectNo := fCurrentSessionObjects.Count - 1;
    if (AConnectNo > -1) then
      if TObject(fCurrentSessionObjects[AConnectNo]) is TISIndyTCPSvrSession
      then
        ConnectObj := fCurrentSessionObjects[AConnectNo];

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
begin
  ISIndyUtilsException(Self, '#ResetSvr');
  RestartSrvAtTime := now + 3 / 24 / 60; // hold reject reset for one minute;
  if FListOfRegConnections <> nil then
    for i := 0 to FListOfRegConnections.Count - 1 do
    Begin
      if FListOfRegConnections.Objects[i] is TISIndyTCPSvrSession then
      Begin
        Chnl := FListOfRegConnections.Objects[i] as TISIndyTCPSvrSession;
        if Chnl.FCoupledSession <> nil then
          Chnl.FCoupledSession.CloseGracefully;
        Chnl.CloseGracefully;
      end;
    end;

  Result := 'Suspending Server until ' + FormatDateTime('dd hh:mm:ss',
    RestartSrvAtTime);
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
  if Bindings <> nil then
    for i := 0 to Bindings.Count - 1 do
      Result := Result + 'Listening on Port ' + IntToStr(Bindings[i].Port) + ' '
        + IPVersionStr(Bindings[i].IPVersion) + #13#10;
  Result := Result + 'Maximum Calls Per Minute is ' +
    IntToStr(MaxCallsPerMinute) + #13#10;
  if fCurrentAddresses <> nil then
    Result := Result + CurrentAddressDetails + #13#10;

  if Contexts <> nil then
    Result := Result + 'Current Sessions =' + IntToStr(Contexts.Count) + #13#10;
  Result := Result + 'Current Server Context Objects =' +
    IntToStr(GlobalContextCount) + #13#10;
  Result := Result + 'Current Server TCP Objects =' +
    IntToStr(FServerTcpSessions) + #13#10;
  Result := Result + #13#10 + 'Connection Details' + #13#10 +
    AllConnectionsAsText;
end;

procedure TIsIndyApplicationServer.SetMaxCallsperminute(AValue: Integer);
begin
  FTimeLimitFor80Calls := 80 / AValue / 24 / 60;
end;

procedure TIsIndyApplicationServer.Shutdown;
Var
  Start: TDateTime;
begin
  Start := now;
  FServerClosing := True;
  inherited;
  ISIndyUtilsException(Self, '# Time To Shutdown =' +
    FormatDateTime('nn:ss.zzz', now - Start));
end;

{ TIsIndyTCPServerContext }

constructor TIsIndyTCPServerContext.Create(AConnection: TIdTCPConnection;
  AYarn: TIdYarn; AList: TIdContextThreadList);
begin
  inherited; // added to server contexts on beforerun
  Inc(GlobalContextCount);
end;

function TIsIndyTCPServerContext.CtxTextId: string;
begin
  if FTcpRef = nil then
    Result := 'No TcpRef'
  else
    Result := FTcpRef.TextID;
end;

destructor TIsIndyTCPServerContext.Destroy;
Var
  s: String;
begin
  FDestroying := True;
  try
    Dec(GlobalContextCount);
    if GblLogAllChlOpenClose then
    begin
      s := CtxTextId;
      ISIndyUtilsException(Self, '# Closing Context::' + s);
    end;
    if FTcpRef <> nil then
      FTcpRef.DropSrvrReferences;
    FreeAndNil(FTcpRef);
  finally
    inherited;
  end;
end;

function TIsIndyTCPServerContext.TcpRef: TISIndyTCPSvrSession;
begin
  Try
    Result := nil;
    if FDestroying then
      Exit;

    if FTcpRef = nil then
    begin
      FTcpRef := TISIndyTCPSvrSession.Create;
      FTcpRef.SetConnection(Connection);
      FTcpRef.FServerConnext := Self;
      If FServer is TIdTcpServer then
        FTcpRef.FServerObject := TIdTcpServer(FServer);
      If FServer is TIsIndyApplicationServer then
        TIsIndyApplicationServer(FServer).AddSession(FTcpRef);
      if GblLogAllChlOpenClose then
        FTcpRef.LogAMessage('Session Open');
      if (FTcpRef.IOHandler <> Connection.IOHandler) then
        raise Exception.Create('Error FTcpRef.IOHandler<>Connection.IOHandler');
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
  if FDestroying then
    Exit;
  if FTcpRef = nil then
    Exit;
  Result := FTcpRef;

  If FTcpRef.TcpConnection = nil then
    If FTcpRef.FServerConnext = Self then
    Begin
      FTcpRef.SetConnection(Connection);
      If FServer is TIdTcpServer then
        FTcpRef.FServerObject := TIdTcpServer(FServer);
      if GblLogAllChlOpenClose then
        FTcpRef.LogAMessage('Session Open ');
      if (FTcpRef.IOHandler <> Connection.IOHandler) then
        raise Exception.Create('Error FTcpRef.FServerConnext <> Self');
    end
    Else If FTcpRef.FServerConnext <> nil then
      raise Exception.Create('Error FTcpRef.IOHandler<>Connection.IOHandler');
end;

procedure TIsIndyTCPServerContext.ReleaseOldRef;
begin
  Try
    // This is a new connection
    If FTcpRef <> nil then
    begin
      FreeAndNil(FTcpRef);
      ISIndyUtilsException(Self, '#ReleaseOldRef<>nil');
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '#ReleaseOldRef');
  End;
end;

function TIsIndyTCPServerContext.Run: Boolean;
begin
  Result := inherited Run;
  if FDestroying then
    Result := false;
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
    CurrentKey := ATestRecord;
    LocalTest := cApplicationHandshakeCode;
{$IFDEF NEXTGEN}
    Encrypt(SizeOf(CurrentKey), @CurrentKey, Length(LocalTest),
      Pointer(LocalTest));
{$ELSE}
    Encrypt(SizeOf(CurrentKey), @CurrentKey, Length(LocalTest), @LocalTest[1]);
{$ENDIF}
    if CurrentKey.Key1 = CurrentKey.Key2 then
      Result := CurrentKey.Key1
    else
      Result := 1.676669;
  end;

Var
  LocalKey: LocalKeyRecord;
  SessionKey: TDateTime;
  TrnctType: TTCPTransactionTypes;
  SessionRandomKey, Key, ResponseData, DataToSend: AnsiString;
  IndexState: AnsiChar;
  Trans: AnsiString;

begin
  // Result := false;
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
    SessionKey := TestConnectionData(LocalKey, cNoPersonality);
  SessionRandomKey := RandomKey;
  if SessionKey < 2.0 then
    // SendError
    ResponseData := 'UA' + SessionRandomKey
  Else
  begin
    IndexState := 'F';

    if false then
      ResponseData := 'E' + IndexState + SessionRandomKey
    else
      ResponseData := 'D' + IndexState + SessionRandomKey;
  end;

{$IFDEF NEXTGEN}
  Encrypt(ResponseData.Length, Pointer(ResponseData), SizeOf(SessionKey),
    @SessionKey);
{$ELSE}
  Encrypt(Length(ResponseData), @ResponseData[1], SizeOf(SessionKey),
    @SessionKey);
{$ENDIF}
  ResponseData := cStartConnection + ResponseData;
  DataToSend := PackTransaction(ResponseData, '');
  Write(DataToSend);
  FRandomKey := SessionRandomKey;
  // LogAMessage('Made Connection Key='+SessionRandomKey);

  Result := True;
  if Result then
    FileAccessBase := GlobalDefaultFileAccessBase;
end;

function TISIndyTCPSvrSession.CheckReadBusy: Boolean;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).CheckBusyOnPacket(Self);
  Result := Inherited; // FDecReadCount := CVLrgeBusy;
  if FDecReadCount > 1000 then
    FDecReadCount := 1000;
end;

function TISIndyTCPSvrSession.CheckWriteBusy: Boolean;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).CheckBusyOnPacket(Self);
  Result := Inherited;
  if FDecWriteCount > 1000 then
    FDecWriteCount := 1000;
end;

procedure TISIndyTCPSvrSession.ClearReferences;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).DropSession(Self);
  if FServerObject <> nil then
    ISIndyUtilsException(Self, 'Server not deleted in drop session');

  try
    if FServerConnext <> nil then
      if FServerConnext.FTcpRef = Self then
      begin
        FServerConnext.FDestroying := True;
        // FServerConnext.FTcpRef := nil;
      end;

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
      ISIndyUtilsException(Self, E, 'TISIndyTCPSvrSession.Destroy');
  end;
end;

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

constructor TISIndyTCPSvrSession.Create;
begin
  Inherited Create;
  ReadDataWaitDiv5 := 5000; // ms
  FCountTo80 := 0;
  FNext80TransactionAllowance := now + cStart80TransactionAllowence;
end;

destructor TISIndyTCPSvrSession.Destroy;
begin
  try
    ClearReferences;
    FreeAndNil(FLockSession);
  finally
    inherited;
  end;
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

    CMDFileName := Copy(ACommand, 14, Length(ACommand));
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
      FileSz := ServerFile.Size; // ServerFile.Seek(0,soFromEnd);
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
        FRandomKey);
      If write(DataSend) <> Length(DataSend) then
        LogAMessage('DoFileTransferBlock : DataSend)<>Length(DataSend');
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
      CMDFileName := Copy(ADataIn, 14, ChrDataSt - ChrDataIn);
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
          FRandomKey)
      else
        raise Exception.Create('File Block Bad Write::' + TrfFileName);
      If write(DataSend) <> Length(DataSend) then
        LogAMessage('DoFileTransferBlock : DataSend)<>Length(DataSend');
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
  if Pos(cRemoteServerDetails, ACommand) = 1 then
    Result := ShowServerDetails
  else if Pos(cRemoteServerConnections, ACommand) = 1 then
    Result := ShowServerConnections(ACommand)
  else if Pos(cRemoteServerDropCoupledSession, ACommand) = 1 then
    Result := DropCoupledSession
  else if Pos(cIsLinkedOnServer, ACommand) = 1 then
  begin
    if FServerObject is TIsIndyApplicationServer then
      Result := TIsIndyApplicationServer(FServerObject)
        .LinkStatusAsResponse(ACommand, Self)
    else
      Result := '-33333';
  End
  else if Pos(cIdleSecsOnServer, ACommand) = 1 then
  begin
    if FServerObject is TIsIndyApplicationServer then
      Result := IntToStr(Round(TIsIndyApplicationServer(FServerObject)
        .fIdleTimePermitted * 24 * 60 * 60))
    else
      Result := '-5555';
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
  else if Pos(cRemoteSetServerRelay, ACommand) = 1 then
    Result := SetServerConnections(ACommand)
  else if Pos(cRemoteResetServer, ACommand) = 1 then
    Result := ResetServer(ACommand)
    // Function removed
    // else if Pos(cRemoteDbLog + '^>>', ACommand) = 1 then
    // LogAMessage(ACommand)
  else if Pos(cRemoteFileSize + '^', ACommand) = 1 then
    Result := PackAServerFileSize(DecodeSafeFileTransferPath(ACommand))
  else if Pos(CRemoteChangeLogging + '^', ACommand) = 1 then
    Result := RemoteChangeLogging(ACommand)
  else if Pos(cRemoteForceClose, ACommand) = 1 then
  begin
    Result := 'Boo';
    CloseGracefully; // test
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

procedure TISIndyTCPSvrSession.DropSrvrReferences;
begin
  if FServerObject is TIsIndyApplicationServer then
    TIsIndyApplicationServer(FServerObject).DropSession(Self);
  FServerObject := nil;
  FServerConnext := nil;
end;

function TISIndyTCPSvrSession.IsTimedOut(ACloseIfTrue: Boolean): Boolean;
begin
  Result := false;
  if FPermittedIdleTime < 0.000000001 then
    if FServerObject is TIsIndyApplicationServer then
    Begin
      FPermittedIdleTime := TIsIndyApplicationServer(FServerObject)
        .IdleTimePermitted;
      FTimeOutAt := now + FPermittedIdleTime;
    End;
  if FPermittedIdleTime < 0.000000001 then
    Exit;
  Result := FTimeOutAt < now;
  if Result and ACloseIfTrue then
  begin
    if GblRptTimeoutClear then
      ISIndyUtilsException(Self, '# Idle Close ' + TextID);
    CloseGracefully;
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
          Result := 4; // BPort is couple
        1:
          Result := 5; // reverse match
        2:
          ISIndyUtilsException(Self, 'Session Link Error B Both =' +
            IntToStr(BPort));
      end;
  end;
end;

procedure TISIndyTCPSvrSession.LogAMessage(AMessage: String);
begin
  try
    if FServerObject is TIsIndyApplicationServer then
      TIsIndyApplicationServer(FServerObject).AddLogMessage(TextID, AMessage);
    if GlobalTCPLogAllData Or (FServerObject = nil) then
      ISIndyUtilsException(Self, '#' + 'LogAMessage>' + AMessage);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '#' + 'LogAMessage');
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

function TISIndyTCPSvrSession.ProcessNextTransaction: Boolean;
Var
  Trans, Key, Echo, Rtn, RawRtn: AnsiString;
  TimeRec: TTimeRec;
  StrRtn: String;
  TrnctType: TTCPTransactionTypes;
begin
  Result := false;
  Rtn := '';
  Key := '';
  try
    if FPermittedIdleTime > 0.000000001 then
      FTimeOutAt := now + FPermittedIdleTime;
    Trans := ReadATransactionRecord(TrnctType, Key);
    if (Assigned(FCoupledSession)) and (TrnctType <> SmpAct) then
    Begin
      Try
        if Not Assigned(FCoupledSession.FCoupledSession) then
          ISIndyUtilsException(Self,
            'Full Duplex Coupled session Dispatch no return session ' + TextID);
        Result := FCoupledSession.FullDuplexDispatch(Trans, Key);
        if Not Result then
        begin
          ISIndyUtilsException(Self,
            'Full Duplex Coupled session Dispatch Fail ' + TextID);
          if FOwnsCoupledSession then
            FreeAndNil(FCoupledSession)
          else
          begin
            if FCoupledSession <> nil then
              if FCoupledSession.FCoupledSession = Self then
                FCoupledSession.FCoupledSession := nil;
            FCoupledSession := nil;
          end;
        end;
        Result := True; // But Leave incoming for now
      Except
        on E: Exception do
        begin
          FCoupledSession := nil;
          Rtn := 'Coupled Session Failure ::' + E.Message;
          LogAMessage(Rtn);
          Result := false;
          ISIndyUtilsException(Self, E, '#Coupled Session Dispatch Failure');
        end;
      end;
    End
    else
      case TrnctType of
        EchoTrans:
          Begin
            if TimeRec.FromTransString(Trans) then
              Trans := Trans + ' Echo MilliSecs:' +
                IntToStr(TimeRec.DeltaMilliSecs);
            Echo := PackTransaction(Key + Trans, FRandomKey);
            // Echo := PackTransaction(Key + '[' + Trans + ']', FRandomKey);
            Write(Echo);
            if GblRptMakeConnectionOnSrvr then
              LogAMessage('Echo' + Trans + ' Key:' + Key);
            Result := True;
          End;
        SmpAct:
          Begin
            Try
              if FCoupledSession <> nil then
              Begin // Lock returns
                Result := True;
                if FLockSession = nil then
                  FLockSession := TCriticalSection.Create;
                FLockSession.Enter;
              End;

              Rtn := DoSimpleRemoteAction(Trans);
              if Rtn <> '' then
              Begin
                RawRtn := PackTransaction(Key + Rtn, FRandomKey);
                Write(RawRtn);
                if CLogAll then
                begin
                  if Length(Rtn) > 40 then
{$IFDEF NEXTGEN}
                    Rtn.Length := 40;
{$ELSE}
                    SetLength(Rtn, 40);
{$ENDIF}
                  LogAMessage(Trans + '::' + Rtn);
                end;
                Result := True;
              End
              Else
              Begin
                ISIndyUtilsException(Self,
                  '#ProcessNextTransaction - No Response frm Trans<' +
                  Trans + '>');
                if Not Result then
                Begin
                  CloseConnection;
                  Result := false;
                End;
              End;
            Finally
              if FLockSession <> nil then
                FLockSession.Release;
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
              RawRtn := PackString(StrRtn, FRandomKey);
            End
            Else
            Begin
              Key := cReturnError;
              Rtn := 'No OnStringAction Function';
              RawRtn := PackTransaction(Key + Rtn, FRandomKey);
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
              RawRtn := PackTransaction(Key + Rtn, FRandomKey);
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
              RawRtn := PackTransaction(Key + Rtn, FRandomKey);
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
              RawRtn := PackTransaction(Key, FRandomKey);
              Write(RawRtn);
            end;
            Result := True;
          End;
        NewCon:
          Begin
            ISIndyUtilsException(Self,
              ' #ProcessNextTransaction NewConnection Data<' + Trans + '>');
            Result := false;
          end;
        LogServerData:
          Begin
            // ISIndyUtilsException(Self,
            // ' #ProcessNextTransaction LogServerData Data<' + Trans + '>');
            LogAMessage(Trans);
            Rtn := 'Logged ' + IntToStr(Length(Trans)) + ' Chars';
            RawRtn := PackTransaction(Key + Rtn, FRandomKey);
            Write(RawRtn);
            Result := True;
          end;
      Else
        Begin
          If Trans <> '' then
            ISIndyUtilsException(Self, ' #ProcessNextTransaction Unknown Data<'
              + Trans + '>');
          // Key := cReturnError;
          Result := false;
        End;
      end;

    if Not Result then
    Begin
      If Key = '' then
        Key := cReturnError;
      If Rtn <> '' then
      Begin
        RawRtn := PackTransaction(Key + 'ProcessNextTransaction Rtn False ' +
          Rtn, FRandomKey);
        Write(RawRtn);
        ISIndyUtilsException(Self, '#Not Result Key=' + Key +
          ' Closing:ProcessNextTransaction Rtn False');
      end;
      Result := false; // will CloseGracefully
    end;
  Except
    On ee: Exception do
    begin
      Result := false;
      RawRtn := Key + 'Exception::' + ee.Message;

      // RawRtn := PackTransaction(Key + 'Exception::'+ee.Message,
      // FRandomKey);
      // Write(RawRtn);
      ISIndyUtilsException(Self, ee, 'Trans =' + Trans + ':: Key=' + Key);
    end;
  end;

end;

function TISIndyTCPSvrSession.ResetServer(AConnectData: AnsiString): AnsiString;
begin
  Result := '';
  ISIndyUtilsException(Self, TextID + '#ResetServer');
  LogAMessage('Reset Server Command');
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
  if FCoupledSession = nil then
    ISIndyUtilsException(Self, 'FullDup  FCoupledSession=nil Id=' + TextID);

  if fFullDuplex <> Val then
    if Val then
    Begin
      if FCoupledSession <> nil then
        Try
          if FLockSession = nil then
            FLockSession := TCriticalSection.Create;
          FLockSession.Enter;
          fFullDuplex := FCoupledSession <> nil;
        Finally
          FLockSession.Release;
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
  NewCon: TISIndyTCPBase;
  Address, PortStr: AnsiString;
  WillOwn: Boolean;

begin
  if FServerObject is TIsIndyApplicationServer then
    Svr := FServerObject as TIsIndyApplicationServer
  else
    Exit;

  ISIndyUtilsException(Self, 'Set Svr Con ' + AConnectData);
  LogAMessage('Set Svr Con ' + AConnectData);

  if FCoupledSession <> nil then
    DropCoupledSession;
  Tst := Length(cRemoteSetServerRelay) + 1;
  Result := '';
  if Pos(cRemoteSetServerRelay, AConnectData) <> 1 then
    Exit;
  WillOwn := false;
  NewCon := nil;
  Inx := Pos(cServerLink, AConnectData);
  if Inx = Tst then
  Begin
    // RemoteServerRelay#SV#Reference From RemoteServerDetails#
    Address := Copy(AConnectData, Tst + 3, 255);
    NewCon := Svr.GetRegConnectionFor(Address);
    if NewCon <> nil then
      ISIndyUtilsException(Self, 'Set Svr Con ' + AConnectData +
        ' Connected to ' + NewCon.Address + ':' + IntToStr(NewCon.Port));

    // LogAMessage('Set Svr Con ' + AConnectData + ' Connected to ' +
    // NewCon.Address + ':' + IntToStr(NewCon.Port));
  End
  Else
  Begin
    Inx := Pos(cNewIPLink, AConnectData);
    if Inx = Tst then
      try
        // RemoteServerRelay#IP#Host Address or IP:Port
        Address := Copy(AConnectData, Tst + 3, 255);
        Inx := Pos(AnsiString(':'), Address);
        if Inx > 6 then
        Begin
          PortStr := Copy(Address, Inx + 1, 255);
{$IFDEF NextGen}
          Address.Length := Inx - 1;
{$ELSE}
          SetLength(Address, Inx - 1);
{$ENDIF}
          ConPort := StrToIntDef(PortStr, 0);
          if (ConPort > 0) and (Address <> '') then
            NewCon := TISIndyTCPFullDuplexClient.StartAccess(Address, ConPort)
          else
            NewCon := nil;
          if (NewCon <> nil) and (Svr <> nil) then
          begin
            Inc(Svr.FServerTcpSessions);
            TISIndyTCPFullDuplexClient(NewCon).OnLogMsg := Svr.AddLogMessage;
          end;
          WillOwn := True;
        End;
      except
        On E: Exception do
        begin
          FreeAndNil(NewCon);
          ISIndyUtilsException(Self, E.Message);
        end;
      end;
  End;

  if NewCon <> nil then
  Begin
    // FCloseOnTimeOut:=False;
    ReadDataWaitDiv5 := 30000;
    if FOwnsCoupledSession then
      FreeAndNil(FCoupledSession);
    FCoupledSession := NewCon;
    if NewCon.FOwnsCoupledSession then
      FreeAndNil(NewCon.FCoupledSession);
    NewCon.FCoupledSession := Self;
    FOwnsCoupledSession := WillOwn;
  End;

  if FCoupledSession <> nil then
    Result := FCoupledSession.TextID + ' >< ' + TextID
  else
    Result := 'Fail::' + AConnectData;
end;

function TISIndyTCPSvrSession.ShowServerConnections(ARegData: AnsiString)
  : AnsiString;
Var
  NewReg: AnsiString;
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

    NewReg := Copy(ARegData, Length(cRemoteServerConnections) + 1, 255);
    if IsEmptyString(NewReg) then
    Else if NewReg <> FRegisteredAs then
    Begin
      if Not IsEmptyString(FRegisteredAs) then
        Svr.DropRegConnection(Self);
      FRegisteredAs := NewReg;
    End;
    Result := Svr.AllRegisteredConnections(Self);
  Except
    On E: Exception do
      Result := 'Connection Exception ' + E.Message;
  end;
end;

function TISIndyTCPSvrSession.ShowServerDetails: AnsiString;
Var
  no: AnsiString;
begin
  if not(FServerObject is TIsIndyApplicationServer) then
    Result := ''
  Else
  Begin
    Result := TIsIndyApplicationServer(FServerObject).ServerDetailsAsText;
  End;
  Result := Result + 'Session is' + TextID + #13#10;
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
begin
  Try
    inherited;
    // Port := 0;
    ClearReferences; // Session is closed must remove references
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '# WasClosedForcfullyOrGracefully');
  End;
end;

{ TBusyCheckCalls }

constructor TBusyCheckCalls.Create(Const AAllowence: TDateTime;
  Const AIpStr: string);
begin
  FIpStr := AIpStr;
  FLastCall := now;
  FAllowTo80 := now + AAllowence;
  // FCountTo80 := 0;
  if GblLogAllChlOpenClose then
    ISIndyUtilsException(Self, 'NewBusyObject ' + TextData);
end;

function TBusyCheckCalls.NotTooBusy(const AAllowance: TDateTime): Boolean;
var
  s: string;
  LocalAllocationTime, TM: TDateTime;
begin
  Result := True;
  TM := 0.0;
  Inc(FCountTo80);
  Inc(FTotalCalls);
  TM := now;
  if FCountTo80 > 80 then
  begin
    FCountTo80 := 0;
    s := 'Total Calls=' + IntToStr(FTotalCalls) + ' Time is ' +
      FormatDateTime('nn:ss.z', TM) + crlf + '     80 calls in ' +
      FormatDateTime('nn:ss.z', TM - FAllowTo80) + crlf +
      '     Min Time for 80 calls is ' + FormatDateTime('ss.zzz', AAllowance) +
      ' seconds';
    s := FIpStr + crlf + s;
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, 'FcountTo80 At ' + FormatDateTime('nn:ss.z',
        TM) + crlf + s);
    if TM > FAllowTo80 then
    begin
      s := FormatDateTime('hh:nn:ss.zzz', TM) + '= Tm > FAllowTo80 =' +
        FormatDateTime('hh:nn:ss.zzz', FAllowTo80);
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, s);
    end
    else
    begin
      s := FormatDateTime('hh:nn:ss.zzz', TM) + '= Tm < FAllowTo80 =' +
        FormatDateTime('hh:nn:ss.zzz', FAllowTo80);
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, s);
      Result := false;
      LocalAllocationTime := FAllowTo80;
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, FIpStr + ':# Svr Busy FcountTo80 gap ' +
          FormatDateTime('nn.ss.z', now - LocalAllocationTime));
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, FIpStr + ':# Svr Busy will Release at ' +
          FormatDateTime('nn:ss.zzz ', LocalAllocationTime));
      while now < LocalAllocationTime do
      begin
        // must be local as other threads will do check busy
        Sleep(2000); // hold thread for two seconds
        if now < LocalAllocationTime then
          ISIndyUtilsException(Self, FIpStr + ':# Waiting till' +
            FormatDateTime('nn:ss.zzz ', LocalAllocationTime));
      end;
    end;
    FAllowTo80 := now + AAllowance;
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, '# Next Allocation ' +
        FormatDateTime('hh:nn:ss.zzz', FAllowTo80) + ' = ' +
        FormatDateTime('hh:nn:ss.zzz', now) + ' Plus ' +
        FormatDateTime('hh:nn:ss.zzz', AAllowance));
  end;
  FLastCall := TM;
end;

function TBusyCheckCalls.TextData: String;
begin
  Result := FIpStr + ' Total Calls =' + IntToStr(FTotalCalls) + crlf +
    '(80) Count Now =' + IntToStr(FCountTo80) + crlf + 'Last Call =' +
    FormatDateTime('hh:nn:ss.zzz', FLastCall) + crlf + '80 not Before =' +
    FormatDateTime('hh:nn:ss.zzz', FAllowTo80) + crlf;
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
begin
  While not Terminated do
    Try
      Try
        FTst := TISIndyTCPClient.StartAccess(FIpAddress, FPort);
        if FTst.Active then
        Begin
          FLastStatus := now;
          Rslt := FTst.ServerDetails;
          if Pos('Port ' + IntToStr(FPort), Rslt) < 7 then
            raise Exception.Create('Bad Details Returned');
          if FLogged then
            ISIndyUtilsException(Self, '# Return Success Ip=' + FIpAddress + ':'
              + IntToStr(FPort));
          FLogged := false;
        End
        Else If not FLogged then
        begin
          ISIndyUtilsException(Self, '# Failed Test Ip=' + FIpAddress + ':' +
            IntToStr(FPort));
          FLogged := True;
        end;
        Sleep(60000);
      Finally
        FreeAndNil(FTst);
      End;
    Except
      On E: Exception do
      Begin
        FTst := nil;
        if Not FLogged then
          ISIndyUtilsException(Self, E, 'Execute');
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
  FTestThread := TTstThrd.Create(AIpAddress, APort);
  ISIndyUtilsException(Self, '#Testing TCP Server on ' + AIpAddress + ':' +
    IntToStr(APort));
end;

destructor TIsMonitorTCPAppServer.Destroy;
begin
  Try
    FTestThread.Terminate;
    inherited;
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

end.
