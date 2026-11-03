program ConsoleAppDemoService;

{$APPTYPE CONSOLE}
{$R *.res}

uses
{$IFDEF TestFastMM}
  FastMM5 in 'Z:\ThirdPartyGitRepo\FastMM\FastMM5-master\FastMM5.pas',
  ISFastMMInit in '..\IsLibrayExtracts\ISFastMMInit.pas',
{$ENDIF }
  System.SysUtils,
  IniFiles,
  isGeneralLib,
  IsGblLogCheck,
  ISIndyUtils,
  CommsDemoCommonValues,
  IsLogging,
  TimeSpan,
  IsIndyTCPApplicationServer,
  IsRemoteConnectionIndyTCPObjs;

Type
  TAppObj = Class(Tobject)
    FReportRx: Integer;
    FTimeInLog: TIsFifteenMinuteLogger;
    FCommsServer: TIsIndyApplicationServer;
    FTestServer: TIsMonitorTCPAppServer;
    Function IsClosing: Boolean;
    Function OnAnsiStringRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Function OnStringActionRx(AData: String;
      ATcpSession: TISIndyTCPBase): String;
    Function OnSimpleActionRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    function CommsServer: TIsIndyApplicationServer;
    function TestServer: TIsMonitorTCPAppServer;
    Class Function AppObj: TAppObj;
    Destructor Destroy; override;
  End;

  { TAppObj }
Var
  ThisApp: TAppObj = nil;

class function TAppObj.AppObj: TAppObj;
begin
  TGblRptComs.ReportObjectTypes;
  if ThisApp = nil then
    ThisApp := TAppObj.Create;
  Result := ThisApp;
end;

function TAppObj.CommsServer: TIsIndyApplicationServer;
begin
  if FTimeInLog = nil then
    FTimeInLog := TIsFifteenMinuteLogger.Create;

  If FCommsServer = nil then
  begin
    FCommsServer := TIsIndyApplicationServer.Create(nil);
    FCommsServer.OnSessionAnsiStringAction := OnAnsiStringRx;
    FCommsServer.OnSessionStringAction := OnStringActionRx;
    FCommsServer.OnSessionSimpleRemoteAction := OnSimpleActionRx;
  end;
  Result := FCommsServer;
end;

destructor TAppObj.Destroy;
begin
  if FTimeInLog <> nil then
    FTimeInLog.Terminate;
  ApplicationFlagThreadMsg('TAppObj.Destroy');
  Try
    if FCommsServer <> nil then
      FCommsServer.Active := false;
    FreeAndNil(FCommsServer);
  Except
    On E: Exception do
      ISIndyUtilsException(self, E, 'Destroy');
  End;
  inherited;

  GblIndyComsObjectFinalize;
end;

function TAppObj.IsClosing: Boolean;
begin
  Result := True;
  if FCommsServer = nil then
    Exit;
  Result := FCommsServer.CurrentlyReset;
end;

function TAppObj.OnAnsiStringRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
Var
  S: String;
begin
  Result := '';
  Dec(FReportRx);
  if FReportRx > 0 then
    Exit;
  FReportRx := 100;
  S := 'TAppObj.OnAnsiStringRx    :: ' + Copy(ACommand, 1, 20);
  if ATcpSession <> nil then
    S := S + '::' + ATcpSession.PortId;
  ApplicationFlagThreadMsg(S);
  Result := 'Ping';
end;

function TAppObj.OnSimpleActionRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
Var
  S: String;
begin
  Result := '';
  Dec(FReportRx);
  if FReportRx > 0 then
    Exit;
  FReportRx := 100;
  S := 'TAppObj.OnSimpleActionRx    :: ' + Copy(ACommand, 1, 20);
  if ATcpSession <> nil then
    S := S + '::' + ATcpSession.PortId;
  ApplicationFlagThreadMsg(S);
  Result := 'Ping';
end;

function TAppObj.OnStringActionRx(AData: String;
  ATcpSession: TISIndyTCPBase): String;
Var
  S: String;
begin
  Result := '';
  Dec(FReportRx);
  if FReportRx > 0 then
    Exit;
  FReportRx := 100;
  S := 'TAppObj.OnStringActionRx    :: ' + Copy(AData, 1, 20);
  if ATcpSession <> nil then
    S := S + '::' + ATcpSession.PortId;
  ApplicationFlagThreadMsg(S);
  Result := 'Ping';
end;

function TAppObj.TestServer: TIsMonitorTCPAppServer;
Var
  Address: String;
  Port: Integer;
begin
  If FTestServer = nil then
  Begin
    Address := 'localhost';
    Port := CommsServer.DefaultPort;
    FTestServer := TIsMonitorTCPAppServer.Create(Address, Port);
  End;
  Result := FTestServer;
end;

Var
  IniFile: TIniFile;
  BaseDir: String;
  LogPurge: TLogFile;
  TimeSpan: TTimeSpan;
  Kill: Integer;

  // BObj:Tobject;
begin
  try
{$IFDEF TestFastMM}
    LoadFastMMfromISLib(True, True, false);
{$ELSE}
    ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
    // GblRptSendImages := false;
    GblLogAllChlOpenClose := True;
    GblRptTimeoutClear := True;
    GLogISIndyUtilsException := True;
    // OpenAppLogging in Delay if FMX

    Kill := 500;
    // BObj:=Tobject.Create;
    try
      LogPurge := nil;
      Try
        Try
          LogPurge := AppendLogFileObject(ExceptionLogName);
          LogPurge.PurgeLogFilesOlderThan := (now - 5);
        Finally
          LogPurge.free;
        End;
      Except
      End;

      OpenAppLogging(True, True, '');
      GblRptTimeoutClear := True;
      GblRptTimeoutClear := True;
      GLogISIndyUtilsException := True;
      // OpenAppLogging in Delay if FMX

      if Not FileExists(IniFileNameFromExe) then
        Try
          BaseDir := ExtractFileDir(IniFileNameFromExe) + '\Data';
          IniFile := TIniFile.Create(IniFileNameFromExe);
          try
            IniFile.WriteString('Files', 'FileAccessBase', BaseDir);
            IniFile.WriteInteger('TCP', 'PORT', CServiceListeningPort);
          finally
            IniFile.free;
          end;
        Except
          On E: Exception do
            raise Exception.Create('Failed to find/create inifile ' +
              IniFileNameFromExe + ' Error=' + E.Message);
        End;
      Try
        GLogISIndyUtilsException := True;
        TAppObj.AppObj.CommsServer;
        TAppObj.AppObj.TestServer;
{$IFDEF Debug}
        GLogISIndyUtilsException := True;
{$ENDIF}
        if TAppObj.AppObj.FCommsServer.DefaultPort < 1 then
          TAppObj.AppObj.FCommsServer.DefaultPort := CServiceListeningPort;
        TAppObj.AppObj.FCommsServer.Active := True;
        ISIndyUtilsException(TAppObj.AppObj, '#Server default port =' +
          IntToStr(TAppObj.AppObj.FCommsServer.DefaultPort));
        ISIndyUtilsException(TAppObj.AppObj,
          TAppObj.AppObj.FCommsServer.ServerDetailsAsText);
      Except
        On E: Exception do
        Begin
          ISIndyUtilsException('Console', E, 'Failed Commserver Start');
          raise Exception.Create('Failed to Start Commsserver:: Error=' +
            E.Message);
        End;
      End;
      while (Kill > 0) and TAppObj.AppObj.CommsServer.Active do
      Begin
        if Kill < 3 then
          Kill := 500;
        // Keep going
        // Every 20 seconds
        if (Kill Mod 20) = 0 then // 400 seconds
        Begin
          Writeln(TAppObj.AppObj.FCommsServer.ServerDetailsAsText);
          Writeln(TAppObj.AppObj.FCommsServer.ReadLogMessage);
          Writeln(' ');
          Writeln(TAppObj.AppObj.FCommsServer.AllConnectionsAsText);
          Writeln(' ');
          Writeln(TAppObj.AppObj.FCommsServer.LinkStatusAsResponse
            (cIsLinkedOnServer + TAppObj.AppObj.FCommsServer.
            RemotePortRegAsString(0, 3), nil));
        End;
        TimeSpan := TTimeSpan.FromMilliseconds(20000 * Kill);
        Writeln('Will Close in ' + TimeSpan.ToString);
        if TAppObj.AppObj.IsClosing then
          Kill := -1
        Else
          sleep(20000);
        Dec(Kill);
        TimeSpan := TTimeSpan.FromMilliseconds(20000 * Kill);
        Writeln('Will Close in ' + TimeSpan.ToString);
        ApplicationFlagThreadMsg('Time Now ' +
          FormatdateTime('mmm dd hh:nn:ss', now));
        ISIndyUtilsException(TAppObj.AppObj, 'Will #Close in ' +
          TimeSpan.ToString);
      End;
      ISIndyUtilsException('Closing', 'FreeAndNil(ThisApp);');
      Try
        FreeAndNil(ThisApp);
      Except
        on E: Exception do
          ApplicationFlagThreadMsg(E.ClassName + ': ' + E.Message +
            ':FreeAndNil(ThisApp);');
      end;
    except
      on E: Exception do
        ApplicationFlagThreadMsg(E.ClassName + ': ' + E.Message);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
{$IFDEF TestFastMM}
  Tobject.Create;
{$ENDIF}

end.
