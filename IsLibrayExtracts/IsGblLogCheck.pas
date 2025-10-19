unit IsGblLogCheck;

interface

uses
{$IFDEF FPC}
{$DEFINE InnovaComms}
  sysutils
{$ELSE}
    System.sysutils
{$ENDIF}
{$IFDEF NextGen}
    , IsNextGenPickup
{$ENDIF}
{$IFDEF InnovaComms}
    , IsIndyUtils, ISProcCl,
  InnovaCommsDbObjects,
  isremoteconnectionindytcpobjs
{$ENDIF}
    ;

Procedure OpenAppLogging(AStartNewLogFile: Boolean; ALogFileName: String = '';
  ARptTcpOpenClose: Boolean = false; ARptTcpData: Boolean = false;
  ARptCommsPoll: Boolean = false; ARptAutoChannels: Boolean = false;
  ARptCommsConAttempts: Boolean = false);
Function ReportLoggingStatus: string;
Function RemoteChangeLogging(ACommandData: AnsiString): AnsiString;
Function RemoteChangeLoggingEncode(ARptTcpOpenClose: Boolean = false;
  ARptTcpData: Boolean = false; ARptRegConnection: Boolean = false;
  ARptMakeConnection: Boolean = false; ARptRegTimeoutClear: Boolean = false;
  ARptPollActions: Boolean = false; ARptAll: Boolean = false): AnsiString;

{$IFDEF NextGen}
Function CRemoteChangeLogging: AnsiString;
{$ELSE}

Const
  CRemoteChangeLogging: AnsiString = 'RemoteChangeLogging';
{$ENDIF}

Var
  cLogAll: Boolean = false;
  // LogAll: TCheckBox;
  GLogISIndyUtilsException: Boolean = false;
  GblLogAllChlOpenClose: Boolean = false;
  // LogCO: TCheckBox;
  GlobalTCPLogAllData: Boolean = false;
  // LogTD: TCheckBox;
  GblLogPollActions: Boolean = false;
  // LogPA: TCheckBox;
  GblRptIsCommsConnectionAttempts: Boolean = false;
  GblRptIsCommsCheckAutoChannels: Boolean = false;
  GblRptRegConnectiononSrvr: Boolean = false;
  // LogRc: TCheckBox;
  GblRptMakeConnectionOnSrvr: Boolean = false;
  // LogMC: TCheckBox;
  GblRptTimeoutClear: Boolean = false;
  // LogCl: TCheckBox;

implementation

uses IsLogging, IsIndyUtils;

Procedure OpenAppLogging(AStartNewLogFile: Boolean; ALogFileName: String = '';
  ARptTcpOpenClose: Boolean = false; ARptTcpData: Boolean = false;
  ARptCommsPoll: Boolean = false; ARptAutoChannels: Boolean = false;
  ARptCommsConAttempts: Boolean = false);
Var
  AppName: String;
begin
  AppName := ExtractFileName
    (ChangeFileExt(AllPlatformExeFileNameFrmISProcCl, ''));
  GLogISIndyUtilsException := True;
  If ALogFileName <> '' then
    SetExceptionLog(ALogFileName, AStartNewLogFile)
  Else
    SetExceptionLog(ExceptionLogName, AStartNewLogFile);
  ISIndyUtilsException(AppName, FormatDateTime('dddd dd mmm  hh.nn:ss.zzz ',
    Now) + #13#10);
  GblLogAllChlOpenClose := ARptTcpOpenClose;
  GlobalTCPLogAllData := ARptTcpData;
  GblLogPollActions := ARptCommsPoll;
{$IFDEF InnovaComms}
  GblRptIsCommsCheckAutoChannels := ARptAutoChannels;
  GblRptIsCommsConnectionAttempts := ARptCommsConAttempts;
{$ELSE}
  If ARptAutoChannels Or ARptCommsConAttempts then
    ISIndyUtilsException('Log Start' + #13#10,
      // 'GblRptCheckAutoChannels and  GblReportConnectionAttempts Not Supported');
      'GblRptIsCommsCheckAutoChannels and  GblRptIsCommsConnectionAttempts Not Supported');
{$ENDIF}
end;

Function ReportLoggingStatus: string;
begin
  Result := '';
  If cLogAll then
    Result := Result + ' Log All ??' + #13#10
  else
    Result := Result + ' not log all' + #13#10;

  if GLogISIndyUtilsException then
    Result := Result + ' Log Indy Utils Exceptions' + #13#10
  else
    Result := Result + ' Indy Utils Exceptions not logged' + #13#10;

  if GblLogAllChlOpenClose then
    Result := Result + ' Log Channels Open and Close' + #13#10
  else
    Result := Result + ' Channels Open and Close not logged' + #13#10;
  if GlobalTCPLogAllData then
    Result := Result + ' Log TCP Data' + #13#10
  else
    Result := Result + ' TCP Data not logged' + #13#10;
  if GblLogPollActions then
    Result := Result + ' Log Poll Actions' + #13#10
  else
    Result := Result + ' Poll Actions not logged' + #13#10;

  if GblRptRegConnectiononSrvr then
    Result := Result + ' Log Reg Srv Connections' + #13#10
  else
    Result := Result + ' Reg Srv Connections not logged' + #13#10;
  if GblRptMakeConnectionOnSrvr then
    Result := Result + ' Log Srv Connections' + #13#10
  else
    Result := Result + ' Srv Connections not logged' + #13#10;
  if GblRptTimeoutClear then
    Result := Result + ' Log TimeOuts' + #13#10
  else
    Result := Result + ' TimeOuts not logged' + #13#10;

{$IFDEF InnovaComms}
  if GblRptIsCommsCheckAutoChannels then
    Result := Result + ' Log InnovaComms Check Auto Channels' + #13#10
  else
    Result := Result + ' Check InnovaComms Auto Channels not logged' + #13#10;
  if GblRptIsCommsConnectionAttempts then
    Result := Result + ' Log InnovaComms Connection Attempts' + #13#10
  else
    Result := Result + ' InnovaComms Connection Attempts not logged' + #13#10;
{$ENDIF}
end;

Function RemoteChangeLogging(ACommandData: AnsiString): AnsiString;
  Function TakeTwo(Var ATxt: PAnsiChar): AnsiString;
  Begin
    if (ATxt = nil) or (Length(ATxt) < 2) then
      TakeTwo := ''
    Else
    Begin
      TakeTwo := ATxt[0] + ATxt[1];
      inc(ATxt, 2);
    End;
  End;

Var
  NxtChr, StChr: PAnsiChar;
  Key: AnsiString;
Begin
  StChr := PAnsiChar(ACommandData);
  NxtChr := strpos(StChr, PAnsiChar('^')) + 1;
  if (NxtChr - StChr - 1) <> Length(CRemoteChangeLogging) then
    Exit;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'TO' then
    GblLogAllChlOpenClose := True
  Else if Key = 'to' then
    GblLogAllChlOpenClose := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'TD' then
    GlobalTCPLogAllData := True
  Else if Key = 'td' then
    GlobalTCPLogAllData := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'RC' then
    GblRptRegConnectiononSrvr := True
  Else if Key = 'rc' then
    GblRptRegConnectiononSrvr := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'MC' then
    GblRptMakeConnectionOnSrvr := True
  Else if Key = 'mc' then
    GblRptMakeConnectionOnSrvr := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'CT' then
    GblRptTimeoutClear := True
  Else if Key = 'ct' then
    GblRptTimeoutClear := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'PA' then
    GblLogPollActions := True
  Else if Key = 'pa' then
    GblLogPollActions := false;

  Key := TakeTwo(NxtChr);
  if Key = '' then
    Exit
  Else if Key = 'LA' then
    cLogAll := True
  Else if Key = 'la' then
    cLogAll := false;
  Result := ReportLoggingStatus;
End;

Function RemoteChangeLoggingEncode(ARptTcpOpenClose, ARptTcpData,
  ARptRegConnection, ARptMakeConnection, ARptRegTimeoutClear, ARptPollActions,
  ARptAll: Boolean): AnsiString;
Var
  s: AnsiString;
begin
  s := '';
  if ARptTcpOpenClose then
    s := s + 'TO'
  else
    s := s + 'to';
  if ARptTcpData then
    s := s + 'TD'
  else
    s := s + 'td';
  if ARptRegConnection then
    s := s + 'RC'
  else
    s := s + 'rc';
  if ARptMakeConnection then
    s := s + 'MC'
  else
    s := s + 'mc';
  if ARptRegTimeoutClear then
    s := s + 'CT'
  else
    s := s + 'ct';
  if ARptPollActions then
    s := s + 'PA'
  else
    s := s + 'pa';
  if ARptAll then
    s := s + 'LA'
  else
    s := s + 'la';

  Result := CRemoteChangeLogging + '^' + s;
end;

{$IFDEF NextGen}

Function CRemoteChangeLogging: AnsiString;
Begin
  Result := 'RemoteChangeLogging';
end;
{$ENDIF}

end.
