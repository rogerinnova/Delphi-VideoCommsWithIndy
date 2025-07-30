unit IsGblLogCheck;

interface

uses
{$IFDEF FPC}
{$Define InnovaComms}
  sysutils,
{$ELSE}
  System.sysutils,
{$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}

  IsIndyUtils, ISProcCl,
{$IFDEF InnovaComms}
InnovaCommsDbObjects,
{$ENDIF}
  isremoteconnectionindytcpobjs;

Procedure OpenAppLogging(AStartNewLogFile:Boolean; ALogFileName: String = '';
  ARptTcpOpenClose: Boolean = false; ARptTcpData: Boolean = false;
  ARptCommsPoll: Boolean = false; ARptAutoChannels: Boolean = false;
  ARptCommsConAttempts: Boolean = false);
Function ReportLoggingStatus: string;
Function RemoteChangeLogging(ACommandData: AnsiString): AnsiString;
Function RemoteChangeLoggingEncode(ARptTcpOpenClose: Boolean = false;
  ARptTcpData: Boolean = false; ARptRegConnection: Boolean = false;
  ARptMakeConnection: Boolean = false; ARptRegTimeoutClear: Boolean = false;
  ARptPollActions: Boolean = false; ARptAll: Boolean = false)
  : AnsiString;

{$IFDEF NextGen}
Function CRemoteChangeLogging: AnsiString;
{$ELSE}

Const
  CRemoteChangeLogging: AnsiString = 'RemoteChangeLogging';
{$ENDIF}

Var
  cLogAll: Boolean = false;
//    LogAll: TCheckBox;
  GLogISIndyUtilsException: Boolean = false;
  GblLogAllChlOpenClose: Boolean = false;
//    LogCO: TCheckBox;
  GlobalTCPLogAllData: Boolean = false;
//   LogTD: TCheckBox;
  GblLogPollActions: Boolean = false;
//    LogPA: TCheckBox;
  GblRptIsCommsConnectionAttempts: Boolean = false;
  GblRptIsCommsCheckAutoChannels: Boolean = false;
  GblRptRegConnectiononSrvr: Boolean = false;
//    LogRc: TCheckBox;
  GblRptMakeConnectionOnSrvr: Boolean = false;
//    LogMC: TCheckBox;
  GblRptSrvrTimeoutClear: Boolean = false;
//    LogCl: TCheckBox;


implementation

Procedure OpenAppLogging(AStartNewLogFile:Boolean; ALogFileName: String = '';
  ARptTcpOpenClose: Boolean = false; ARptTcpData: Boolean = false;
  ARptCommsPoll: Boolean = false; ARptAutoChannels: Boolean = false;
  ARptCommsConAttempts: Boolean = false);
Var
  AppName: String;
begin
  AppName := ExtractFileName(ChangeFileExt(ExeFileNameAllPlatforms, ''));
  GLogISIndyUtilsException := True;
  If ALogFileName <> '' then
    SetExceptionLog(ALogFileName,AStartNewLogFile)
   Else
    SetExceptionLog(ExceptionLogName,AStartNewLogFile);
  ISIndyUtilsException(CRLF, CRLF + CRLF + 'New Executeable Instance');
  ISIndyUtilsException(AppName, FormatDateTime('dddd dd mmm  hh.nn:ss.zzz ',
    Now) + CRLF + CRLF);
  GblLogAllChlOpenClose := ARptTcpOpenClose;
  GlobalTCPLogAllData := ARptTcpData;
  GblLogPollActions := ARptCommsPoll;
{$IFDEF InnovaComms}
  GblRptIsCommsCheckAutoChannels := ARptAutoChannels;
  GblRptIsCommsConnectionAttempts := ARptCommsConAttempts;
{$ELSE}
  If ARptAutoChannels Or ARptCommsConAttempts then
    ISIndyUtilsException('Log Start'+crlf,
//      'GblRptCheckAutoChannels and  GblReportConnectionAttempts Not Supported');
      'GblRptIsCommsCheckAutoChannels and  GblRptIsCommsConnectionAttempts Not Supported');
{$ENDIF}
  ISIndyUtilsException('Log Start'+crlf,ReportLoggingStatus);
end;

Function ReportLoggingStatus: string;
begin
  Result := '';
  If cLogAll then
    Result := Result + ' Log All ??' + CRLF
  else
    Result := Result + ' not log all ??' + CRLF;

  if GLogISIndyUtilsException then
    Result := Result + ' Log All Indy Utils Exceptions' + CRLF
  else
    Result := Result + ' Indy Utils Exceptions not logged' + CRLF;

  if GblLogAllChlOpenClose then
    Result := Result + ' Log All Channels Open and Close' + CRLF
  else
    Result := Result + ' Channels Open and Close not logged' + CRLF;
  if GlobalTCPLogAllData then
    Result := Result + ' Log All TCP Data' + CRLF
  else
    Result := Result + ' TCP Data not logged' + CRLF;
  if GblLogPollActions then
    Result := Result + ' Log All Channels Poll Actions' + CRLF
  else
    Result := Result + ' Poll Actions not logged' + CRLF;

{$IFDEF InnovaComms}
  if GblRptIsCommsCheckAutoChannels then
    Result := Result + ' Log InnovaComms Check Auto Channels' + CRLF
  else
    Result := Result + ' Check InnovaComms Auto Channels not logged' + CRLF;
  if GblRptIsCommsConnectionAttempts then
    Result := Result + ' Log InnovaComms Connection Attempts' + CRLF
  else
    Result := Result + ' InnovaComms Connection Attempts not logged' + CRLF;
{$ENDIF}
end;

Function RemoteChangeLogging(ACommandData: AnsiString): AnsiString;
  Function TakeTwo(Var ATxt:PAnsiChar):AnsiString;
  Begin
    if (ATxt=nil) or (Length(ATxt)<2) then
         TakeTwo:=''
     Else
       Begin
        TakeTwo:=ATxt[0]+ATxt[1];
        inc(ATxt,2);
       End;
  End;
Var
  NxtChr,StChr:PAnsiChar;
  Key:AnsiString;
Begin
  StChr:=PAnsiChar(ACommandData);
  NxtChr:=strpos(StChr,PAnsiChar('^'))+1;
  if (NxtChr-StChr-1)<>length(CRemoteChangeLogging) then Exit;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='TO' then
     GblLogAllChlOpenClose:= True
    Else
    if Key='to' then
     GblLogAllChlOpenClose:= false     ;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='TD' then
       GlobalTCPLogAllData:= True
    Else
    if Key='td' then
     GlobalTCPLogAllData:= false;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='RC' then
       GblRptRegConnectiononSrvr:= True
    Else
    if Key='rc' then
     GblRptRegConnectiononSrvr:= false;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='MC' then
       GblRptMakeConnectionOnSrvr:= True
    Else
    if Key='mc' then
     GblRptMakeConnectionOnSrvr:= false;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='CT' then
       GblRptSrvrTimeoutClear:= True
    Else
    if Key='ct' then
     GblRptSrvrTimeoutClear:= false;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='PA' then
       GblLogPollActions:= True
    Else
    if Key='pa' then
     GblLogPollActions:= false;

   Key:=TakeTwo(NxtChr);
   if Key='' then
    Exit
    Else
    if Key='LA' then
       cLogAll:= True
    Else
    if Key='la' then
     cLogAll:= false;
  Result:=ReportLoggingStatus;
End;

Function RemoteChangeLoggingEncode(ARptTcpOpenClose,
  ARptTcpData, ARptRegConnection, ARptMakeConnection,
  ARptRegTimeoutClear,ARptPollActions,ARptAll: Boolean)
  : AnsiString;
Var
  s:AnsiString;
begin
  s:='';
  if ARptTcpOpenClose then s:=s+'TO'
    else s:=s+'to';
  if ARptTcpData then s:=s+'TD'
    else s:=s+'td';
  if ARptRegConnection then s:=s+'RC'
    else s:=s+'rc';
  if ARptMakeConnection then s:=s+'MC'
    else s:=s+'mc';
  if ARptRegTimeoutClear then s:=s+'CT'
    else s:=s+'ct';
  if ARptPollActions then s:=s+'PA'
    else s:=s+'pa';
  if ARptAll then s:=s+'LA'
    else s:=s+'la';

  Result:=CRemoteChangeLogging+'^'+s;
end;


{$IFDEF NextGen}

Function CRemoteChangeLogging: AnsiString;
Begin
  Result := 'RemoteChangeLogging';
end;
{$ENDIF}

end.
