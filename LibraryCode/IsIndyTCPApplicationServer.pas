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
  SysUtils, Classes, SyncObjs,
{$ELSE}
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
{$ENDIF}
  IdContext, inifiles, IdTCPConnection,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, ISStrUtl,
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
    FServerObject: TIdTcpServer;
    FServerConnext: TIsIndyTCPServerContext;
    FRegisteredAs: AnsiString;
    FOnSimpleRemoteAction: TComandActionAnsi;
    FOnStringAction: TComandActionString;
    function ShowServerDetails: AnsiString;
    function ShowServerConnections(ARegData: AnsiString): AnsiString;
    function SetServerConnections(AConnectData: AnsiString): AnsiString;
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
    function PackAServerFileSize(const AFileName: AnsiString): AnsiString;
    // function PackAPutServerFileResponse(const AFileData: AnsiString)
    // : AnsiString;
    function ConnectionStatusText: AnsiString;
    function TextID: String; override;
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
  Public
    Destructor Destroy; override;
    Function TcpRef: TISIndyTCPSvrSession;
    Procedure ReleaseOldRef;
  end;

  { TIsIndyApplicationServer }

  TIsIndyApplicationServer = class(TIdTcpServer)
  Private
    FLogsMissed: Integer;
    fCurrentAddresses, FLogList: TStringList;
    FBusyLock: TCriticalSection;
    FListLock: TCriticalSection;
    FOnSessionSimpleRemoteAction: TComandActionAnsi;
    FOnSessionAnsiStringAction: TComandActionAnsi;
    FOnSessionStringAction: TComandActionString;
    FServerTcpSessions: Integer;
    FListOfRegConnections: TStringList;
    FTimeLimitFor80Calls, FTimeLimitFor80Transactions: TDateTime;
    FResetStartTime: TDateTime; // if > now then reset/reject calls;
    function GetMaxCallsPerMinute: Integer;
    Function ListOfRegConnections: TStringList;
    Function LocalContext(AContext: TIdContext): TIsIndyTCPServerContext;
    Function ResetSvr(AData: AnsiString): AnsiString;
    procedure IsIdTCPSrvrContextCreated(AContext: TIdContext);
    procedure IsIdTCPSrvrConnect(AContext: TIdContext);
    procedure IsIdTCPSvrSessionExecute(AContext: TIdContext);
    procedure CheckBusyOnConnect(AContext: TIsIndyTCPServerContext);
    // Connections on Ip Address
    procedure CheckBusyOnPacket(ASession: TISIndyTCPSvrSession);
    // packets on channel
    procedure SetMaxCallsperminute(AValue: Integer);
    procedure LoadServerIniData;
  Protected
    procedure AddLogMessage(ATextID, AMsg: String);
  Public
    Constructor Create(AOwner: TComponent);
    Destructor Destroy; override;
    Function ServerDetailsAsText: AnsiString;
    Function AllRegisteredConnections(AConnection: TISIndyTCPSvrSession)
      : AnsiString;
    Function GetRegConnectionFor(ARegString: AnsiString): TISIndyTCPBase;
    function ReadLogMessage: String;
    Function CurrentAddresses: TStringList;
    Function CurrentAddressDetails: String;
    Procedure DropRegConnection(AConnection: TISIndyTCPSvrSession);
    // Property OnLogServerEvent: TISIndyLogEvent Read FOnLogServerEvent
    // write FOnLogServerEvent;
    // Property OnLogConectionEvent: TISIndyLogEvent Read FOnLogConectionEvent
    // Write FOnLogConectionEvent;
    Property OnSessionSimpleRemoteAction: TComandActionAnsi
      Read FOnSessionSimpleRemoteAction Write FOnSessionSimpleRemoteAction;
    Property OnSessionStringAction: TComandActionString
      Read FOnSessionStringAction Write FOnSessionStringAction;
    Property OnSessionAnsiStringAction: TComandActionAnsi
      Read FOnSessionAnsiStringAction Write FOnSessionAnsiStringAction;
    Property MaxCallsPerMinute: Integer Read GetMaxCallsPerMinute
      write SetMaxCallsperminute;
    // OnSessionSimpleRemoteAction,OnSessionAnsiStringAction: TComandActionAnsi
    // OnSessionStringAction: TComandActionString
    // TComandActionAnsi = Function(ACommand: ansistring;
    // ATcpSession: TISIndyTCPBase): ansistring of Object;
    // TComandActionString = Function(AData: String; ATcpSession: TISIndyTCPBase)
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
  GlobalContext: Integer = 0;

{$IFDEF NextGen}
Function cRemoteResetServer: AnsiString;
Function cRemoteServerDetails: AnsiString;
//Function cRemoteDbLog: AnsiString;
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
//  cRemoteDbLog: AnsiString = 'RemoteDbLog';
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

//Function cRemoteDbLog: AnsiString;
//begin
//  Result := 'RemoteDbLog';
//end;

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

procedure TIsIndyApplicationServer.AddLogMessage(ATextID, AMsg: String);

begin
  Try
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
        if cLogAll then
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
  s: string;
  IpIdx: Integer;
  IObj: TBusyCheckCalls;
  IpStr: string;
begin
  if AContext = nil then
    exit;
  if AContext.Connection = nil then
    exit;

  Try
    IpStr := AContext.TcpRef.Address;
    IObj := nil;
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
    finally
      FBusyLock.Release;
    end;
    if IObj <> nil then
      if not IObj.NotTooBusy(FTimeLimitFor80Calls) then
        AddLogMessage(IpStr, 'Too Busy');
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
  if ASession = nil then
    exit;
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

Const
  cStart80TransactionAllowence = 1 / 24 / 60 / 60 / 200; // 5msec

constructor TIsIndyApplicationServer.Create(AOwner: TComponent);
begin
  // Four Seconds;
  FTimeLimitFor80Transactions := cStart80TransactionAllowence;
  FListLock := TCriticalSection.Create;
  FBusyLock := TCriticalSection.Create;
  Inherited;
  ContextClass := TIsIndyTCPServerContext;
  OnConnect := IsIdTCPSrvrConnect;
  OnExecute := IsIdTCPSvrSessionExecute;
  OnContextCreated := IsIdTCPSrvrContextCreated;
  MaxCallsPerMinute := 800;
  ISIndyUtilsException(Self,
    '#' + 'New IsIndyApplicationServer Max Calls Per Min ' +
    IntToStr(MaxCallsPerMinute));
  LoadServerIniData;
  ISIndyUtilsException(Self,
    '#' + 'After Ini IsIndyApplicationServer Max Calls Per Min ' +
    IntToStr(MaxCallsPerMinute));
end;

function TIsIndyApplicationServer.CurrentAddressDetails: String;
var
  BObj: TBusyCheckCalls;
  i: Integer;
begin
  Result := '';
  if fCurrentAddresses = nil then
    exit;
  if fCurrentAddresses.Count < 1 then
    exit;

  for i := 0 to fCurrentAddresses.Count - 1 do
  begin
    Result := Result + fCurrentAddresses[i] + crlf;
    if fCurrentAddresses.Objects[i] is TBusyCheckCalls then
    begin
      BObj := TBusyCheckCalls(fCurrentAddresses.Objects[i]);
      Result := Result + BObj.TextData + crlf;
    End;
  end;
end;

function TIsIndyApplicationServer.CurrentAddresses: TStringList;
begin
  if fCurrentAddresses = nil then
  begin
    fCurrentAddresses := TStringList.Create;
    fCurrentAddresses.Sorted := true;
  end;
  Result := fCurrentAddresses;
end;

destructor TIsIndyApplicationServer.Destroy;
begin
  Try
    FListOfRegConnections.Free;
    FLogList.Free;
    FListLock.Free;
    FBusyLock.Free;
  Except
  end;
  inherited;
end;

procedure TIsIndyApplicationServer.DropRegConnection
  (AConnection: TISIndyTCPSvrSession);
Var
  Index: Integer;
begin
  if AConnection = nil then
    exit;
  if cLogAll then
    AddLogMessage('Server', 'TIsIndyApplicationServer.DropRegConnection');
  If FListOfRegConnections = nil Then
    exit;
  if AConnection = nil then
    exit;

  Index := FListOfRegConnections.IndexOfObject(AConnection);
  if Index >= 0 then
    FListOfRegConnections.Delete(Index);
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

procedure TIsIndyApplicationServer.IsIdTCPSvrSessionExecute
  (AContext: TIdContext);
Var
  LContext: TIsIndyTCPServerContext;
  LConnection: TIdTCPConnection;
  TcpCtx: TISIndyTCPSvrSession;
  s: String;
begin
  if AContext = nil then
    exit;
  Try
    LContext := LocalContext(AContext);
    TcpCtx := nil;
    if LContext = nil then
      ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Nil Local Context')
    else
      TcpCtx := LContext.RawTcpRef;

    if TcpCtx = nil then
    begin
      ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Nil TcpCtx');
      exit;
    end;

    LConnection := LContext.Connection;
    if TcpCtx.FConnection <> LConnection then
    begin
      if LConnection = nil then
        ISIndyUtilsException(Self,
          '#IsIdTCPSvrSessionExecute Comtext Nil Coonection')
      else
        ISIndyUtilsException(Self, '#IsIdTCPSvrSessionExecute Wrong TcpCtx ::' +
          TcpCtx.TextID);
      exit;
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
            exit;
          end;
        if TcpCtx <> nil then
          If not TcpCtx.ProcessNextTransaction Then
          Begin
            if GblLogAllChlOpenClose then
            begin
              AddLogMessage(TcpCtx.TextID, 'End Run Channel');
              ISIndyUtilsException(Self, '#Failed ProcessNextTransaction');
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
        if LContext.Connection <> nil then
          if LContext.Connection.Connected then
            AContext.Connection.Disconnect;
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
    if cLogAll then
      AddLogMessage('Server', 'On Connect::' + IntToStr(FServerTcpSessions));

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
          AddLogMessage(LContext.FTcpRef.TextID, 'Run Channel');
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

procedure TIsIndyApplicationServer.IsIdTCPSrvrContextCreated
  (AContext: TIdContext);
begin
  Inc(GlobalContext);
end;

function TIsIndyApplicationServer.ListOfRegConnections: TStringList;
begin
  if FListOfRegConnections = nil then
  Begin
    FListOfRegConnections := TStringList.Create;
    FListOfRegConnections.Sorted := true;
    FListOfRegConnections.Duplicates := dupError;
  end;
  Result := FListOfRegConnections;
end;

procedure TIsIndyApplicationServer.LoadServerIniData;
Var
  IniFile: TIniFile;
  IniFileName:String;
begin
  IniFileName:=IniFileNameFromExe;
  if GlobalDefaultFileAccessBase = '' then
    if FileExists(IniFileName) then
    Begin
      IniFile := TIniFile.Create(IniFileName);
      GlobalDefaultFileAccessBase := IniFile.ReadString('Files',
        'FileAccessBase', '');
      if GlobalDefaultFileAccessBase = '' then
        IniFile.WriteString('Files', 'FileAccessBase', '');
      if DefaultPort < 1 then
         DefaultPort := IniFile.ReadInteger('TCP', 'PORT', 0);
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
Var
  i: Integer;
begin
  Result := '';
  if Bindings <> nil then
    for i := 0 to Bindings.Count - 1 do
      Result := Result + 'Listening on Port ' +
        IntToStr(Bindings[i].Port) + #13#10;
  Result := Result + 'Maximum Calls Per Minute is ' +
    IntToStr(MaxCallsPerMinute) + #13#10;
  if fCurrentAddresses <> nil then
    Result := Result + CurrentAddressDetails + #13#10;

  if Contexts <> nil then
    Result := Result + 'Current Sessions =' + IntToStr(Contexts.Count) + #13#10;
  Result := Result + 'Current Server Context Objects =' +
    IntToStr(GlobalContext) + #13#10;
  Result := Result + 'Current Server TCP Objects =' +
    IntToStr(FServerTcpSessions) + #13#10;
end;

procedure TIsIndyApplicationServer.SetMaxCallsperminute(AValue: Integer);
begin
  FTimeLimitFor80Calls := 80 / AValue / 24 / 60;
end;

{ TIsIndyTCPServerContext }

destructor TIsIndyTCPServerContext.Destroy;
begin
  try
    Dec(GlobalContext);
    FDestroying := true;
    // if Assigned(FTcpRef) then
    // FTcpRef.LogAMessage('CLOSING');
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
      exit;

    if FTcpRef = nil then
    begin
      FTcpRef := TISIndyTCPSvrSession.Create;
      FTcpRef.SetConnection(Connection);
      FTcpRef.FServerConnext := Self;
      If FServer is TIdTcpServer then
        FTcpRef.FServerObject := TIdTcpServer(FServer);
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
  Result := FTcpRef;
  if FDestroying then
    exit;
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
    Else
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

  Result := true;
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
Var
  Srv: TIsIndyApplicationServer;
begin
  try
    Try
      if FServerObject is TIsIndyApplicationServer then
      Begin
        if GblLogAllChlOpenClose then
          LogAMessage('Svr Session Destroy');
        Srv := TIsIndyApplicationServer(FServerObject);
        Dec(Srv.FServerTcpSessions);
        Srv.DropRegConnection(Self);
      End
      else
        Srv := nil;

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
      begin
        ISIndyUtilsException(Self, E, 'TISIndyTCPSvrSession.Destroy');
        if Srv <> nil then
          Srv.AddLogMessage('SnEnd', E.Message);
      end;
    end;
  finally
    inherited;
    // if Srv <> nil then
    // Dec(Srv.FServerTcpSessions)   See above
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
  DataReturn, DataSend, CMDFileName: AnsiString;
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
              exit;
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
var
{$IFDEF NextGen}
  SnapName: string;
{$ELSE}
  SnapName: AnsiString;
{$ENDIF}
begin
  Result := '';
  SnapName := '';

  if Pos(cRemoteServerDetails, ACommand) = 1 then
    Result := ShowServerDetails
  else if Pos(cRemoteServerConnections, ACommand) = 1 then
    Result := ShowServerConnections(ACommand)
  else if Pos(cRemoteServerDropCoupledSession, ACommand) = 1 then
    Result := DropCoupledSession
  else if Assigned(FCoupledSession) then
    FCoupledSession.FullDuplexDispatch(ACommand, cSimpleRemoteAction)
    // else if Pos(cRemoteServerDetails, ACommand) = 1 then
    // Result := ShowServerDetails
  else if Pos(cRemoteSetServerRelay, ACommand) = 1 then
    Result := SetServerConnections(ACommand)
  else if Pos(cRemoteResetServer, ACommand) = 1 then
    Result := ResetServer(ACommand)
//  Function removed
//  else if Pos(cRemoteDbLog + '^>>', ACommand) = 1 then
//    LogAMessage(ACommand)
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
    ISIndyUtilsException(Self, 'Sim Rmt: No Code For Action :' + ACommand);
    raise Exception.Create('No Code For Action::' + ACommand);
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
    exit;

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
    Trans := ReadATransactionRecord(TrnctType, Key);
    if (Assigned(FCoupledSession)) and (TrnctType <> SmpAct) then
    Begin
      Try
        Result := FCoupledSession.FullDuplexDispatch(Trans, Key);
        if Not Result then
          if FOwnsCoupledSession then
            FreeAndNil(FCoupledSession)
          else
            FCoupledSession := nil;
        Result := true; // But Leave incoming for now
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
            if cLogAll then
              LogAMessage('Echo' + Trans + ' Key:' + Key);
            Result := true;
          End;
        SmpAct:
          Begin
            if FCoupledSession <> nil then
              Result := true;
            Rtn := DoSimpleRemoteAction(Trans);
            if Rtn <> '' then
            Begin
              RawRtn := PackTransaction(Key + Rtn, FRandomKey);
              Write(RawRtn);
              if cLogAll then
              begin
                if Length(Rtn) > 40 then
{$IFDEF NEXTGEN}
                  Rtn.Length := 40;
{$ELSE}
                  SetLength(Rtn, 40);
{$ENDIF}
                LogAMessage(Trans + '::' + Rtn);
              end;
              Result := true;
            End
            Else
            Begin
              ISIndyUtilsException(Self,
                '#ProcessNextTransaction - No Response frm Trans<' +
                Trans + '>');
              CloseConnection;
              Result := false;
            End;
          End;
        RdFileTrfBlk:
          Begin
            DoFileTransferBlockDnLd(Trans);
            Result := true;
          End;
        PtFileTrfBlk:
          Begin
            DoFileTransferBlockUpLd(Trans);
            Result := true;
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
            Result := true;
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
            Result := true;
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
              Result := true;
            End;
          End;
        FlgNull:
          Begin
            if Assigned(FCoupledSession) then
              FCoupledSession.FullDuplexDispatch('', Key); // Forward Null
            Result := true;
          End;
        NewCon:
          Begin
            ISIndyUtilsException(Self,
              ' #ProcessNextTransaction NewConnection Data<' + Trans + '>');
            Result := false;
          end;
        PartTrnData:
          Begin
            ISIndyUtilsException(Self,
              ' #ProcessNextTransaction PartTrnData Data<' + Trans + '>');
            Result := false;
          end;
        { FlgError, FlgNull, MvString, MvRawStrm, SmpAct,
          EchoTrans, FullDuplexMode, RdFileTrfBlk, PtFileTrfBlk, }
        LogServerData:
          Begin
            ISIndyUtilsException(Self,
              ' #ProcessNextTransaction LogServerData Data<' + Trans + '>');
            Result := false;
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
    exit;
  End;
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
    exit;

  LogAMessage('Set Svr Con ' + AConnectData);

  if FCoupledSession <> nil then
    DropCoupledSession;
  Tst := Length(cRemoteSetServerRelay) + 1;
  Result := '';
  if Pos(cRemoteSetServerRelay, AConnectData) <> 1 then
    exit;
  WillOwn := false;
  NewCon := nil;
  Inx := Pos(cServerLink, AConnectData);
  if Inx = Tst then
  Begin
    // RemoteServerRelay#SV#Reference From RemoteServerDetails#
    Address := Copy(AConnectData, Tst + 3, 255);
    NewCon := Svr.GetRegConnectionFor(Address);
    if NewCon <> nil then
      LogAMessage('Set Svr Con ' + AConnectData + ' Connected to ' +
        NewCon.Address + ':' + IntToStr(NewCon.Port));
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
          WillOwn := true;
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
    Result := FCoupledSession.TextID
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
      exit;
    if FServerObject is TIsIndyApplicationServer then
      Svr := FServerObject as TIsIndyApplicationServer
    else
      exit;

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
  No: AnsiString;
begin
  if not(FServerObject is TIsIndyApplicationServer) then
    Result := ''
  Else
  Begin
    Result := TIsIndyApplicationServer(FServerObject).ServerDetailsAsText;
  End;
  Result := Result + 'Session is' + TextID + #13#10;
  if Assigned(FOnSimpleRemoteAction) then
    No := ''
  Else
    No := 'No ';
  Result := Result + No + 'On Simple RemoteAction Assigned' + #13#10;
  if Assigned(FOnStringAction) then
    No := ''
  Else
    No := 'No ';
  Result := Result + No + 'On String Action Assigned' + #13#10;
  if Assigned(FOnAnsiStringAction) then
    No := ''
  Else
    No := 'No ';
  Result := Result + No + 'On Ansi String Action Assigned' + #13#10;

  Result := Result + #13#10 + 'State of Connections' +
    TGblRptComs.ReportObjectTypes;

end;

(*
  Function TISIndyTCPSvrSession.ProcessSimpleRemoteActionTxn
  (ACommand: AnsiString):AnsiString;
  var
  Rtn: AnsiString;
  {$IFDEF NextGen}
  SnapName: string;
  {$ELSE}
  SnapName: AnsiString;
  {$ENDIF}
  begin
  Rtn := '';
  // SnapName := '';
  // if Pos('MakeSnapShotOfDb', ACommand) = 1 then
  // begin
  // MakeSnapShotOfDb(DecodeSafeFileTransferPath(ACommand), SnapName);
  // Result := SnapName;
  // end
  // else if Pos('DeleteSnapShotFiles', ACommand) = 1 then
  // Result := DeleteSnapShotFiles(DecodeSafeFileTransferPath(ACommand))
  // else if Pos('SetEncrypted', ACommand) = 1 then
  // SetEncrypted(Pos('^Y', ACommand) > 10)
  // else if Pos('ForceIndexRebuild', ACommand) = 1 then
  // begin
  // ForceIndexRebuild;
  // try
  // RecoverIndexs // only from fully qualified app;
  // except
  // end;
  // end
  // else if Pos('EmailProcessStillActive', ACommand) = 1 then
  // begin
  // {$IFNDEF AUTOREFCOUNT}
  // if EmailProcessStillActive then
  // Result := 'Y'
  // else
  // {$ENDIF}
  // Result := 'N';
  // end
  // else if Pos('RemoteDbLog' + '^>>', ACommand) = 1 then
  // LogAMessage(ACommand)
  // else
  if Pos('RecoverRemoteFile' + '^', ACommand) = 1 then
  Rtn := PackAServerFile(DecodeSafeFileTransferPath(ACommand))
  else if Pos('RemoteFileSize' + '^', ACommand) = 1 then
  Rtn := PackAServerFileSize(DecodeSafeFileTransferPath(ACommand))
  // else if Pos('RemoteFileSnapShot' + '^', ACommand) = 1 then
  // Result := PackFileSnapShotName(DecodeSafeFileTransferPath(ACommand))
  // else if Pos('DeleteFileSnapShot' + '^', ACommand) = 1 then
  // Result := PackDeleteSnapShot(DecodeSafeFileTransferPath(ACommand))
  else
  raise Exception.Create('No Code For Action::' + ACommand);
  end;
*)

function TISIndyTCPSvrSession.TextID: String;
begin
  Result := 'Svr:' + IntToStr(LocalPort) + ' Frm ' + Address + ':' +
    IntToStr(Port);
end;

procedure TISIndyTCPSvrSession.WasClosedForcfullyOrGracefully;
begin
  Try
    inherited;

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
  Result := true;
  Inc(FCountTo80);
  Inc(FTotalCalls);
  if FCountTo80 > 80 then
  begin
    FCountTo80 := 0;
    TM := now;
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
    '80 Count =' + IntToStr(FCountTo80) + crlf + 'Last Time =' +
    FormatDateTime('hh:nn:ss.zzz', FLastCall) + crlf + 'Next Time =' +
    FormatDateTime('hh:nn:ss.zzz', FAllowTo80) + crlf;
end;

{ TIsMonitorTCPAppServer.TTstThrd }

constructor TIsMonitorTCPAppServer.TTstThrd.Create(AIpAddress: String;
  APort: Integer);
begin
  FIpAddress := AIpAddress;
  FPort := APort;
  FreeOnTerminate := true;
  Inherited Create(false);
end;

procedure TIsMonitorTCPAppServer.TTstThrd.Execute;
Var
  FTst: TISIndyTCPClient;
begin
  While not Terminated do
    Try
      Try
        FTst := TISIndyTCPClient.StartAccess(FIpAddress, FPort);
        if FTst.Active then
        Begin
          FLastStatus := now;
          FLogged := false;
        End
        Else If not FLogged then
          ISIndyUtilsException(Self, '# Failed Test Ip=' + FIpAddress + ':' +
            IntToStr(FPort));
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
        FLogged := true;
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
  FTestThread.Terminate;
  inherited;
end;

function TIsMonitorTCPAppServer.GetLastStatus: TDateTime;
begin
  if FTestThread <> nil then
    Result := FTestThread.FLastStatus
  else
    Result := 0.0;
end;

end.
