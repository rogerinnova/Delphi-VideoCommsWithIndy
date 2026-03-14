{$I InnovaLibDefs.inc}
{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}
unit IsIndyLib;
// See Also unit  ISBase64AndEncryption

{ Usage
  rslt := InternetHttpGrabWithSSL('https://accounts.google.com/ServiceLogin');
  InternetAccess := ValidPort(ISSiteDBHost, DbPort);
  LocalHost := ThisHostIpAddress;
  TstServer := FindServerOnSubnet(DbPort, 2, 254);
  IAm:=ThisHostName;
}

interface

uses SysUtils,
{$IFDEF fpc}
{$ELSE}IOUtils, IsProcCl, IsLogging,
{$ENDIF}
  IdStack, IdHTTP, IdIOHandler, Classes,
  IdSSLOpenSSLHeaders, IdGlobal, IdIntercept,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL
{$IFDEF NextGen}
    , IsNextGenPickup
{$ENDIF}
    ;

Type
  TISIndyHttpGrab = Class(TIdHttp)
  Private
    FSavedIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    FConnectionIntercept: TIdConnectionIntercept;
{$IFDEF fpc}
{$ELSE}
    FLogger: TLogFile;
{$ENDIF}
    FSession: String;
    Function SetUpIoHandler: TIdIOHandler; // TIdSSLIOHandlerSocketOpenSSL;
    Function SetUpLogger: TIdConnectionIntercept;
    Procedure SetDefaults;
    procedure LogIntercept1Receive(ASender: TIdConnectionIntercept;
      var ABuffer: TIdBytes);
    procedure LogIntercept1Send(ASender: TIdConnectionIntercept;
      var ABuffer: TIdBytes);
  Protected
    FAllowNoHTTPS: Boolean;
  Public
    //
    OpenSSLDir: String;
    Constructor Create(AOwner: TComponent);
    Destructor Destroy; override;
    Procedure LogException(AEx: Exception);
    Procedure ReleaseLogFile;
  End;

  TISIndyGrabNoHttps = Class(TISIndyHttpGrab)
  Public
    Constructor Create(AOwner: TComponent);
    function AllowsSSL: Boolean;
  End;

{$IFNDEF NextGen}

function Base64Decode(const s: AnsiString): AnsiString; overload;
{$ENDIF}
{$IFDEF UNICODE}
function Base64Decode(const s: String): String; overload;
{$ENDIF}
Function ThisHostName: String;
Function ThisHostIpAddress: String;
Function ValidPort(Const AIpAddress: String; APort: Integer): Boolean;
Function FindServerOnSubnet(APort: Integer; AStartIP: Integer = 1;
  ATopIP: Integer = 254): String;

Function InternetHttpGrabWithSSL(AUrl: String;
  APostData: TStream = nil): String;
Function InternetHttpGrab(AUrl: String; APostData: TStream = nil): String;
Function SetupSSLDLLs(Var ANonSSLAcceptable: Boolean)
  : TIdSSLIOHandlerSocketOpenSSL;
Procedure ReleaseGrabLogs;

Var
  SSLDLLLibDir, // Directory containing SSL DLLs
  SSLLoggerFileName: String;
  // FulPathName of Data log File if Required For  InternetHttpGrabWithSSL
  NonSSLLoggerFileName: String;
  // FulPathName of Data log File if Required For  InternetHttpGrabWithSSL

implementation

uses IdCoderMIME, IdCoder3To4, IdBaseComponent, IdComponent, IdAntiFreezeBase,
  IdTCPConnection, IdTCPClient
{$IFDEF UNICODE}
    , ISUnicodeStrUtl;

function Base64Decode(const s: String): String;
begin
  Result := TIdDecoderMIME.DecodeString(s);
end;
{$ELSE}
    ;
{$ENDIF}
{$IFNDEF NEXTGEN}

function Base64Decode(const s: AnsiString): AnsiString;
// var
// Coder: TIdDecoderMIME;//TIdBase64Decoder;

// Res: string;
begin
{$IFDEF UNICODE}
  Result := CompressedUnicode(TIdDecoderMIME.DecodeString(s));
{$ELSE}
  Result := TIdDecoderMIME.DecodeString(s);
{$ENDIF}
  { Coder := TIdDecoderMIME.Create(nil);//TIdBase64Decoder.Create(nil);
    try
    //Coder.AddCRLF := False;
    //Coder.UseEvent := False;
    Coder.Reset;
    Coder.CodeString(s);
    Res := Coder.CompletedInput;
    Result := Copy(Res, 3, Length(Res));
    finally
    FreeAndNil(Coder);
    end; }
end;
{$ENDIF}

Function ThisHostName: String;
begin
  Result := '';
  Try
    TIdStack.IncUsage;
    Result := GStack.HostName;
  Finally
    TIdStack.DecUsage;
  End;

end;

Function ThisHostIpAddress: String;
begin
  Try
    TIdStack.IncUsage;
    Result := GStack.LocalAddress;
  Finally
    TIdStack.DecUsage;
  End;
end;

Function ValidPort(Const AIpAddress: String; APort: Integer): Boolean;
Var
  TstClient: TIdTCPClient;
begin
  TstClient := nil;
  Result := false;
  Try
    TstClient := TIdTCPClient.Create(nil);
    TstClient.Host := AIpAddress;
    TstClient.Port := APort;
    Try
      TstClient.Connect;
      Result := TstClient.Connected;
    Except
    End;
    Try
      if Result then
        TstClient.Disconnect;
    Except
    End;
  Finally
    TstClient.Free;;
  End;
end;

Function FindServerOnSubnet(APort: Integer; AStartIP: Integer = 1;
  ATopIP: Integer = 254): String;
Var
  LocalSubNet, TstIP: String;
  Len, Tst: Integer;
  TstClient: TIdTCPClient;
begin
  TstClient := nil;
  Result := '';
  LocalSubNet := ThisHostIpAddress;
  Len := Length(LocalSubNet);
{$IFDEF NEXTGEN}
  while (Len > 3) and (LocalSubNet[Len - 1] <> '.') do
{$ELSE}
  while (Len > 3) and (LocalSubNet[Len] <> '.') do
{$ENDIF}
  begin
    SetLength(LocalSubNet, Len - 1);
    Len := Length(LocalSubNet);
  end;

  if Len > 3 then
    Try
      TstClient := TIdTCPClient.Create(nil);
      TstClient.ConnectTimeout := 20;
      TstClient.Port := APort;
      Tst := AStartIP;
      while (Result = '') and (Tst <= ATopIP) do
      begin
        TstIP := LocalSubNet + IntToStr(Tst);
        TstClient.Host := TstIP;
        Try
          TstClient.Connect;
          if TstClient.Connected then
          begin
            Result := TstIP;
            TstClient.Disconnect;
          end
          Else
            inc(Tst);
        Except
          inc(Tst);
        End;
      end;
    Finally
      TstClient.Free;
    end;
end;

{ TISIndyHttpGrab }

constructor TISIndyHttpGrab.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetDefaults;
  IOHandler := SetUpIoHandler;
  if SSLLoggerFileName <> '' then
    Intercept := SetUpLogger;
end;

destructor TISIndyHttpGrab.Destroy;
begin
  freeandnil(FSavedIOHandler);
  freeandnil(FConnectionIntercept);
{$IFNDEF fpc}
  freeandnil(FLogger);
{$ENDIF}
  inherited;
end;

procedure TISIndyHttpGrab.LogException(AEx: Exception);
begin
  Try
{$IFNDEF fpc}
    if FLogger = nil then
      Exit;

    FLogger.LogALine(FSession + ' Exception::' + AEx.message);
{$ENDIF}
  Except
  End;
end;

procedure TISIndyHttpGrab.LogIntercept1Receive(ASender: TIdConnectionIntercept;
  var ABuffer: TIdBytes);
Var
  s: PAnsiChar;
begin
  s := @ABuffer[0];

{$IFNDEF fpc}
  if FLogger = nil then
    Exit;

  FLogger.LogALine(FSession + '::Rx');
  FLogger.LogALine(s);
{$ENDIF}
end;

procedure TISIndyHttpGrab.LogIntercept1Send(ASender: TIdConnectionIntercept;
  var ABuffer: TIdBytes);
Var
  s: PAnsiChar;
begin
  s := @ABuffer[0];
{$IFNDEF fpc}
  if FLogger = nil then
    Exit;

  FLogger.LogALine(FSession + '::Tx');
  FLogger.LogALine(s);
{$ENDIF}
end;

procedure TISIndyHttpGrab.ReleaseLogFile;
begin
{$IFNDEF fpc}
  if FLogger <> nil then
    FLogger.ReleaseFileStream;
{$ENDIF}
end;

procedure TISIndyHttpGrab.SetDefaults;
begin
  AllowCookies := True;
  ProxyParams.BasicAuthentication := false;
  ProxyParams.ProxyPort := 0;
  Request.ContentLength := -1;
  Request.ContentRangeEnd := -1;
  Request.ContentRangeStart := -1;
  Request.ContentRangeInstanceLength := -1;
  Request.Accept :=
    'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
  Request.BasicAuthentication := false;
  Request.UserAgent := 'Mozilla/3.0 (compatible; Indy Library)';
  Request.Ranges.Units := 'bytes';
  // Request.Ranges := <>
  HTTPOptions := [hoForceEncodeParams];
end;

function TISIndyHttpGrab.SetUpIoHandler: TIdIOHandler;
// TIdSSLIOHandlerSocketOpenSSL;
begin
  if FSavedIOHandler = nil then
    FSavedIOHandler := SetupSSLDLLs(FAllowNoHTTPS);
  Result := FSavedIOHandler;
end;

function TISIndyHttpGrab.SetUpLogger: TIdConnectionIntercept;
Var
  LogDir: String;
begin
  Result := nil;
  if (SSLLoggerFileName = '') then
    Exit;

  if Not FileExists(SSLLoggerFileName) then
  Begin
    LogDir := ExtractFileDir(SSLLoggerFileName);
    if (LogDir <> '') and Not DirectoryExists(LogDir) then
      If not ForceDirectories(LogDir) then
        Exit;
  End;

  FConnectionIntercept := TIdConnectionIntercept.Create(nil);
  FConnectionIntercept.OnReceive := LogIntercept1Receive;
  FConnectionIntercept.OnSend := LogIntercept1Send;
{$IFNDEF fpc}
  FLogger := TLogFile.Create(SSLLoggerFileName, True, 100000, false, True);
  FLogger.PurgeLogFilesOlderThan := Now - 6; // Can only have one file in 3 Days
  FSession := FormatDateTime('yymmdd:zzz', Now);
  FLogger.LogALine('Session Start ID:' + FSession);
{$ENDIF}
  Result := FConnectionIntercept;
end;

Var
  SingletonHttp: TISIndyHttpGrab;
  SingletonNonHttps: TISIndyHttpGrab;

Procedure ReleaseGrabLogs;
begin
  if SingletonHttp <> nil then
    SingletonHttp.ReleaseLogFile;
  if SingletonNonHttps <> nil then
    if SingletonNonHttps <> SingletonHttp then
      SingletonNonHttps.ReleaseLogFile;
end;

Function InternetHttpGrabWithSSL(AUrl: String;
  APostData: TStream = nil): String;
begin
  if SingletonHttp = nil then
    SingletonHttp := TISIndyHttpGrab.Create(nil);
  Try
    if APostData = nil then
      Result := SingletonHttp.Get(AUrl)
    else
      Result := SingletonHttp.Post(AUrl, APostData);
  Except
    On E: Exception do
    Begin
      if SingletonHttp <> nil then
      begin
        SingletonHttp.LogException(E);
        If SSLDLLLibDir = '' then
          SSLDLLLibDir := SingletonHttp.OpenSSLDir;
        if SingletonNonHttps = SingletonHttp then
          SingletonNonHttps := nil;
        freeandnil(SingletonNonHttps);
        freeandnil(SingletonHttp);

        freeandnil(SingletonHttp);
      end;
      raise Exception.Create('InternetHttpGrabWithSSL::' + E.message + #10#13 +
        '<br> SSLDLLLibDir=' + SSLDLLLibDir);
    End;
  End;
end;

Function InternetHttpGrab(AUrl: String; APostData: TStream = nil): String;
begin
  if SingletonNonHttps = nil then
    if SingletonHttp <> nil then
      SingletonNonHttps := SingletonHttp
    else
    Begin
      SingletonNonHttps := TISIndyGrabNoHttps.Create(nil);
      if TISIndyGrabNoHttps(SingletonNonHttps).AllowsSSL then
        SingletonHttp := SingletonNonHttps;
    End;
  Try
    if APostData = nil then
      Result := SingletonNonHttps.Get(AUrl)
    else
      Result := SingletonNonHttps.Post(AUrl, APostData);
  Except
    On E: Exception do
    Begin
      if SingletonNonHttps <> nil then
      begin
        SingletonNonHttps.LogException(E);
        If SSLDLLLibDir = '' then
          SSLDLLLibDir := SingletonNonHttps.OpenSSLDir;
        if SingletonNonHttps = SingletonHttp then
          SingletonHttp := nil;
        freeandnil(SingletonNonHttps);
        freeandnil(SingletonHttp);
      end;
      raise Exception.Create('InternetHttpGrabWithSSL::' + E.message + #10#13 +
        '<br> SSLDLLLibDir=' + SSLDLLLibDir);
    End;
  End;
end;

Function SetupSSLDLLs(Var ANonSSLAcceptable: Boolean)
  : TIdSSLIOHandlerSocketOpenSSL;
// IdOpenSSLSetLibPath;
// SafeLoadLibrary(GIdOpenSSLPath + SSLCLIB_DLL_name);
// Refer IdCompilerDefines.inc
// RLebeau: For iOS devices, OpenSSL cannot be used as an external library,
// it must be statically linked into the app.  For the iOS simulator, this
// is not true.  Users who want to use OpenSSL in iOS device apps will need
// to add the static OpenSSL library to the project and then include the
// IdSSLOpenSSLHeaders_static unit in their uses clause. It hooks up the
// statically linked functions for the IdSSLOpenSSLHeaders unit to use...

// OpenSSL From http://indy.fulgan.com/SSL/
// https://access.redhat.com/documentation/en-US/Fuse_ESB/4.4.1/html/Web_Services_Security_Guide/files/OpenSSL.html
// put OpenSSl in Program Files\Innova Solutions\OpenSSL

// Load Setup From
// http://docs.innovasolutions.com.au/Docs/OpenSSL/OpenSSLforInternetHttpGrabWithSSL.exe
// Refer F:\TrillianShare\HgRepository\InnovaSolutionsDelphi\Delphi Projects\Delphi 3rd Party Stuff\OpenSSL
Var
  OpenSSLDir: string;

Begin
  if (SSLDLLLibDir <> '') and (DirectoryExists(SSLDLLLibDir)) then
    IdOpenSSLSetLibPath(SSLDLLLibDir)
  Else if FileExists('libeay32.dll' { SSLCLIB_DLL_name } ) And
    FileExists('ssleay32.dll' { SSL_DLL_name } ) then
    ANonSSLAcceptable := false
  else
  Begin
{$IFDEF fpc}
    // OpenSSLDir := TPath.GetHomePath { GetMyAppsDataFolder } +
    // TPath.PathSeparator + 'Innova Solutions' + TPath.PathSeparator +
    // 'OpenSSL';
{$ELSE}
{$IFDEF MSWINDOWS}
    OpenSSLDir := GetProgramFilesFolder + '\Innova Solutions\OpenSSL\';
{$ELSE}
    OpenSSLDir := TPath.GetHomePath { GetMyAppsDataFolder } +
      TPath.PathSeparator + 'Innova Solutions' + TPath.PathSeparator +
      'OpenSSL';
{$ENDIF}
{$ENDIF}
    if DirectoryExists(OpenSSLDir) then
    begin
      IdOpenSSLSetLibPath(OpenSSLDir);
      ANonSSLAcceptable := FileExists(OpenSSLDir + 'libeay32.dll') and
        FileExists(OpenSSLDir + 'ssleay32.dll')
    end
    Else if not ANonSSLAcceptable then
      Raise Exception.Create('You Need SSL DLLs they can be obtained from ' +
        ' http://docs.innovasolutions.com.au/Docs/OpenSSL/OpenSSLforInternetHttpGrabWithSSL.exe');
  End;
  If ANonSSLAcceptable Then
  Begin
    Result := nil; // Let the implicit manager handle it
  End
  Else
  Begin
    Result := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    Result.MaxLineAction := maException;
    // Port = 0
    // DefaultPort = 0
    Result.SSLOptions.Mode := sslmUnassigned;
    // Result.SSLOptions.VerifyMode := [];
    // Result.SSLOptions.VerifyDepth := 0;
  End;
End;

{ TISIndyGrabNoHttps }

function TISIndyGrabNoHttps.AllowsSSL: Boolean;
begin
  Result := not FAllowNoHTTPS;
end;

constructor TISIndyGrabNoHttps.Create(AOwner: TComponent);
begin
  FAllowNoHTTPS := True;
  Inherited Create(AOwner);
end;

initialization

finalization

if SingletonHttp <> SingletonNonHttps then
  freeandnil(SingletonNonHttps);
freeandnil(SingletonHttp);

end.
