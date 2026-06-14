unit SrvcFormBasicTCPServer;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.IniFiles,
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr,
  Vcl.Dialogs,
  IsIndyTCPApplicationServer, IsRemoteConnectionIndyTCPObjs;

type
  TDemoTCPBasicServer = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
  private
    { Private declarations }
    FCommsServer: TIsIndyApplicationServer;
    Function CommsServer: TIsIndyApplicationServer;
    Function OnAnsiStringRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Function OnSimpleActionRx(ACommand: ansistring; ATcpSession: TISIndyTCPBase)
      : ansistring;
    Function OnStringActionRX(AData: String;
      ATcpSession: TISIndyTCPBase): String;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  DemoTCPBasicServer: TDemoTCPBasicServer;

implementation

Uses isGeneralLib, IsGblLogCheck, ISIndyUtils, CommsDemoCommonValues;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  DemoTCPBasicServer.Controller(CtrlCode);
end;

function TDemoTCPBasicServer.CommsServer: TIsIndyApplicationServer;
begin
  If FCommsServer = nil then
  begin
    FCommsServer := TIsIndyApplicationServer.Create(nil);
    FCommsServer.OnSessionAnsiStringAction := OnAnsiStringRx;
    FCommsServer.OnSessionStringAction := OnStringActionRX;
    FCommsServer.OnSessionSimpleRemoteAction := OnSimpleActionRx;
  end;
  Result := FCommsServer;
end;

function TDemoTCPBasicServer.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function TDemoTCPBasicServer.OnAnsiStringRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
begin
  { If you need TCP sessions to DO stuff in your application
    If this app does not need to interact with VCL Components
    the only restriction on this process is that it is thread safe }
  // ISIndyUtilsException(self,FormatDateTime('hh:nn:ss ', Now) + ATcpSession.TextID +
  // ' OnAnsiStringRx::' + ACommand);
  Result := '';
end;

function TDemoTCPBasicServer.OnSimpleActionRx(ACommand: ansistring;
  ATcpSession: TISIndyTCPBase): ansistring;
begin
  { If you need TCP sessions to DO stuff in your application
    If this app does not need to interact with VCL Components
    the only restrict on this process is that it is thread safe }
  ISIndyUtilsException(self, FormatDateTime('hh:nn:ss ', Now) +
    ATcpSession.TextID + ' OnSimpleActionRx::' + ACommand);
end;

function TDemoTCPBasicServer.OnStringActionRX(AData: String;
  ATcpSession: TISIndyTCPBase): String;
begin
  { If you need TCP sessions to DO stuff in your application
    If this app does not need to interact with VCL Components
    the only restrict on this process is that it is thread safe }
  ISIndyUtilsException(self, FormatDateTime('hh:nn:ss ', Now) +
    ATcpSession.TextID + ' OnStringActionRX::' + AData);
end;

procedure TDemoTCPBasicServer.ServiceCreate(Sender: TObject);
Var
  IniFile: TIniFile;
  BaseDir: String;
begin
  // For demo Also class function TAppObj.AppObj: TAppObj;
  OpenAppLogging(true, '');
  // GblRptSendImages := false;
  GblRptMakeConnectionOnSrvr := true;
  GblLogAllChlOpenClose := true;
  GblRptTimeoutClear := true;
  GLogISIndyUtilsException := true;
  GblRptRegConnectiononSrvr := true;
  // For demo Also class function TAppObj.AppObj: TAppObj;

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
      Begin
        ISIndyUtilsException(self, E, 'ServiceCreate ini File');
        raise Exception.Create('Failed to find/create inifile ' +
          IniFileNameFromExe + ' Error=' + E.Message);
      End;
    End;
  Try
    CommsServer;
    if FCommsServer.DefaultPort < 1 then
      FCommsServer.DefaultPort := CServiceListeningPort;
    FCommsServer.Active := true;
    ISIndyUtilsException(self, '#Server default port =' +
      IntToStr(FCommsServer.DefaultPort));
    ISIndyUtilsException('', FCommsServer.ServerDetailsAsText);
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(self, E, 'ServiceCreate Start Server');
      raise Exception.Create('Failed to Start Commsserver:: Error=' +
        E.Message);
    End;
  End;
end;

procedure TDemoTCPBasicServer.ServiceDestroy(Sender: TObject);
begin
  Try
    FCommsServer.free;
  Except
    On E: Exception do
      ISIndyUtilsException(self, E, 'ServiceDestroy');
  End;
end;

end.
