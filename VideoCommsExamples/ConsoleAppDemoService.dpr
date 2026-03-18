program ConsoleAppDemoService;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  {$IFDEF TestFastMM}
  FastMM5 in 'Z:\ThirdPartyGitRepo\FastMM\FastMM5-master\FastMM5.pas',
  ISFastMMInit in '..\IsLibrayExtracts\ISFastMMInit.pas',
  {$EndIf }
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
    FCommsServer: TIsIndyApplicationServer;
    Function OnAnsiStringRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Function OnStringActionRx(AData: String;
      ATcpSession: TISIndyTCPBase): String;
    Function OnSimpleActionRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    function CommsServer: TIsIndyApplicationServer;
    Class Function AppObj: TAppObj;
    Destructor Destroy; override;
  End;

  { TAppObj }
Var
  ThisApp: TAppObj = nil;

class function TAppObj.AppObj: TAppObj;
begin
  if ThisApp = nil then
    ThisApp := TAppObj.Create;
  Result := ThisApp;
end;

function TAppObj.CommsServer: TIsIndyApplicationServer;
begin
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
  FreeAndNil(FCommsServer);
  inherited;
  GblIndyComsObjectFinalize;
end;

function TAppObj.OnAnsiStringRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
begin
  Writeln(ACommand);
  Result := '';
end;

function TAppObj.OnSimpleActionRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
begin
  Writeln(ACommand);
  Result := '';
end;

function TAppObj.OnStringActionRx(AData: String;
  ATcpSession: TISIndyTCPBase): String;
begin
  Writeln(AData);
  Result := '';
end;

Var
  IniFile: TIniFile;
  BaseDir: String;
  LogPurge: TLogFile;
  TimeSpan:TTimeSpan;
  Kill:integer;
//  BObj:Tobject;
begin
  {$IFDEF TestFastMM}
  LoadFastMMfromISLib;
  {$Else}
   ReportMemoryLeaksOnShutdown := true;
  {$EndIf}

  Kill:=500;
//  BObj:=Tobject.Create;
  try
    LogPurge := nil;
    Try
      Try
        LogPurge := AppendLogFileObject(ExceptionLogName);
        LogPurge.PurgeLogFilesOlderThan := (now - 0.001);
      Finally
        LogPurge.free;
      End;
    Except
    End;

    OpenAppLogging(True, '', True, True, false, false, false);
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
{$IFDEF Debug}
      GLogISIndyUtilsException := True;
{$ENDIF}
      if TAppObj.AppObj.FCommsServer.DefaultPort < 1 then
        TAppObj.AppObj.FCommsServer.DefaultPort := CServiceListeningPort;
      TAppObj.AppObj.FCommsServer.Active := True;
      ISIndyUtilsException(TAppObj.AppObj,'#Server default port ='+IntToStr(TAppObj.AppObj.FCommsServer.DefaultPort));
      ISIndyUtilsException(TAppObj.AppObj,TAppObj.AppObj.FCommsServer.ServerDetailsAsText);
      Except
      On E: Exception do
      Begin
        ISIndyUtilsException('Console', E, 'Failed Commserver Start');
        raise Exception.Create('Failed to Start Commsserver:: Error=' +
          E.Message);
      End;
    End;
    while (Kill>0)and TAppObj.AppObj.FCommsServer.Active do
    Begin
      Writeln(TAppObj.AppObj.FCommsServer.ServerDetailsAsText);
      Writeln(TAppObj.AppObj.FCommsServer.ReadLogMessage);
      Writeln(' ');
      Writeln(TAppObj.AppObj.FCommsServer.AllConnectionsAsText);
      Writeln(' ');
      Writeln(TAppObj.AppObj.FCommsServer.LinkStatusAsResponse(cIsLinkedOnServer
        + TAppObj.AppObj.FCommsServer.RemotePortRegAsString(0, 3), nil));
      TimeSpan:=TTimeSpan.FromMilliseconds(20000*Kill);
      Writeln('Will Close in '+TimeSpan.ToString);
      sleep(20000);
      Dec(Kill);
      TimeSpan:=TTimeSpan.FromMilliseconds(20000*Kill);
      Writeln('Will Close in '+TimeSpan.ToString);
    End;
    FreeAndNil(ThisApp);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
