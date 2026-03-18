unit FmDummyCammeraImages;
// An FMXApplication which will connect to FmVCLApplicationSrver and send
// if on a Mobile real cammera images (Requires configuration and access to server)
// if on Windows Dummy camamera immages uses localhost

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, IniFiles, IsProcCl,
{$IFDEF NEXTGEN}
  IsNextGenPickup,
{$ENDIF}
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  IsMediaCommsObjs, CommsDemoCommonValues, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Media, ISRemoteConnectionIndyTCPObjs,
  IsMobileCaptureDevices, FMX.ListBox, FMX.Edit, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

type
  TFmDummyCamerraForTestingSrvr = class(TForm)
    BtnRestartLink: TButton;
    ImgLocalCamera: TImageControl;
    Timer1: TTimer;
    ImgSent: TImageControl;
    LblImagesSent: TLabel;
    BtnReset: TButton;
    LblCamera: TLabel;
    CmbxServerSel: TComboBox;
    EdtServerUrl: TEdit;
    BtnLinkStatus: TButton;
    BtnLoadLog: TButton;
    MMoLogData: TMemo;
    BtnCloseLog: TButton;
    BtnEcho: TButton;
    BtnStopVideo: TButton;
    procedure BtnRestartLinkClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
    procedure BtnLinkStatusClick(Sender: TObject);
    procedure BtnCloseLogClick(Sender: TObject);
    procedure BtnLoadLogClick(Sender: TObject);
    procedure BtnEchoClick(Sender: TObject);
    procedure BtnStopVideoClick(Sender: TObject);
  private
    { Private declarations }

    FVideoDisable, FFormInDestroy: boolean;
    FDelayFormCreateActions: boolean;
    fKnownServers: TStringList;
    FCurSrvConnectionString: string;

    FImagesActuallySent,FCameraImages,FStep: integer;
    FConnectionToServer: TVideoComsChannel;
    // FConnectionToExtServer, FConnectionFrmExtServer, FConnectionToExtServer2,
    // FConnectionFrmExtServer2: TVideoComsChannel;
    FMediaDevices: TIsMediaCapture;
    Function ConnectionToServer: TVideoComsChannel;
    // Function ConnectionToExtServer(AStep: integer): TVideoComsChannel;
    Procedure ShowLogFile; // Puts Logfile in Memo
    Function MediaDevices: TIsMediaCapture;
    Procedure LoadIniDetails;
    Procedure SaveIniDetails;
    Procedure DelayedSetup; // Delay some create concepts to allow for Android
    Procedure UpdateConnections;
    Procedure SetLinkStatusOnOneAction(AFrom, ATo: TVideoComsChannel;
      ALink: AnsiString);
    Procedure CommsDestroy(ASender: TObject);

    procedure Test8;
    Procedure ClientConnectedReturn(Sender: TObject);

    Procedure SentBitMapEvent(ABitMap: TBitMap; ASentImages: integer);
    Procedure OnCameraData(ADevice: TCaptureDevice; ATime: TDateTime);
  public
    { Public declarations }
  end;

var
  FmDummyCamerraForTestingSrvr: TFmDummyCamerraForTestingSrvr;

implementation

{$R *.fmx}
{ TFmDummyCamerraForTestingSrvr }

uses IsObjectTimeSpanRecording, IsIndyUtils, IsLogging, IsGblLogCheck;

procedure TFmDummyCamerraForTestingSrvr.BtnCloseLogClick(Sender: TObject);
begin
  MMoLogData.Visible := false;
end;

procedure TFmDummyCamerraForTestingSrvr.BtnEchoClick(Sender: TObject);
Var
  S,Msr: AnsiString;
  TstClient: TISIndyTCPClient;
begin
  if FConnectionToServer = nil then
    Exit;
  TstClient := nil;
  try
    gblMeterSleep:=0;
    TstClient := TISIndyTCPClient.StartAccess(FConnectionToServer.Address,
      FConnectionToServer.Port);
    s:='Echo Test';
{$IFNDEF  SuppressIPMetering}
  AddSetMeteredTimeRecAsString(S, 'Echo');
{$ENDIF}
    s:=TstClient.EchoFromServer(s);
{$IFNDEF  SuppressIPMetering}
    if SplitMeteredData(s,Msr) then
      begin
        MMoLogData.Lines.Clear;
        MMoLogData.Lines.Add('Echo Response');
        MMoLogData.Lines.Add(s);
        MMoLogData.Lines.Add(#13#10'Metering for ' + TstClient.TextID);
        if not StringsFrmMeteredData(MMoLogData.Lines, Msr) then
            ISIndyUtilsException(self, 'Time Metered Fail Echo');
        MMoLogData.Visible:=true;
      end;
{$ENDIF}
  finally
    TstClient.Free;
  end;
end;

procedure TFmDummyCamerraForTestingSrvr.BtnLinkStatusClick(Sender: TObject);
begin
  SetLinkStatusOnOneAction(FConnectionToServer, nil, '')
end;

procedure TFmDummyCamerraForTestingSrvr.BtnLoadLogClick(Sender: TObject);
begin
  // MMoLogData.Visible:=true;
  ShowLogFile;
end;

procedure TFmDummyCamerraForTestingSrvr.BtnResetClick(Sender: TObject);
begin
  Try
    FreeAndNilDuplexChannel(FConnectionToServer);
    // FreeAndNilDuplexChannel(FConnectionToExtServer);
    // FreeAndNilDuplexChannel(FConnectionFrmExtServer);
    // FreeAndNilDuplexChannel(FConnectionToExtServer2);
    // FreeAndNilDuplexChannel(FConnectionFrmExtServer2);
    FreeAndNil(FMediaDevices);
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'BtnResetClick');
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.BtnRestartLinkClick(Sender: TObject);
begin
  if ConnectionToServer = nil then
  begin
    FreeAndNil(FMediaDevices);
    BtnRestartLink.Text := 'Retry ' + FormatDateTime('nn:ss', now);
  end
  else
  Begin
    if MediaDevices <> nil then
    Begin
      BtnRestartLink.Text := 'Connected ' + ConnectionToServer.TextID +
        FormatDateTime('   hh:nn:ss', now);
    End
    else
      BtnRestartLink.Text := 'No Camera ' + FormatDateTime('nn:ss', now);
  End;
  EdtServerUrl.Visible := ConnectionToServer = nil;
end;

procedure TFmDummyCamerraForTestingSrvr.BtnStopVideoClick(Sender: TObject);
begin
   FVideoDisable:=  not FVideoDisable;
   If FMediaDevices<>nil then
      FMediaDevices.ActivateDeactivateVideo(-1, FVideoDisable);
   if FVideoDisable then
     BtnStopVideo.Text:='Start Video'
    else
     BtnStopVideo.Text:='Stop Video';
end;

procedure TFmDummyCamerraForTestingSrvr.ClientConnectedReturn(Sender: TObject);
begin
  if FFormInDestroy then
    Exit;
  if Sender is TISIndyTCPClient then
    ISIndyUtilsException(self, 'Connection Made ' +
      TISIndyTCPClient(Sender).TextID)
  Else
    ISIndyUtilsException(self, 'UnExpected Call to ClientConnectedReturn');
end;

procedure TFmDummyCamerraForTestingSrvr.CommsDestroy(ASender: TObject);
begin
  if ASender = FConnectionToServer then
    FConnectionToServer := nil;
  // if ASender = FConnectionToExtServer then
  // FConnectionToExtServer := nil;
  // if ASender = FConnectionFrmExtServer then
  // FConnectionFrmExtServer := nil;
  // if ASender = FConnectionFrmExtServer2 then
  // FConnectionFrmExtServer2 := nil;
  // if ASender = FConnectionFrmExtServer2 then
  // FConnectionFrmExtServer2 := nil;
end;

function TFmDummyCamerraForTestingSrvr.ConnectionToServer: TVideoComsChannel;
Var
  Srv: string;
  Port: integer;
begin
  if (EdtServerUrl.Visible) and TISIndyTCPBase.ExpandSrvRefCode
    (EdtServerUrl.Text, Srv, Port) then
    FCurSrvConnectionString := EdtServerUrl.Text
  else if CmbxServerSel.ItemIndex > -1 then
    FCurSrvConnectionString := CmbxServerSel.Items[CmbxServerSel.ItemIndex]
  Else
    FCurSrvConnectionString := '';

  If FCurSrvConnectionString <> '' then
    If TISIndyTCPBase.ExpandSrvRefCode(FCurSrvConnectionString, Srv, Port) then
    Begin
      if FConnectionToServer <> nil then
        if not(SameText(FConnectionToServer.Address, Srv) and
          (FConnectionToServer.Port = Port)) then
          FreeAndNilDuplexChannel(FConnectionToServer);
    End;

  Result := FConnectionToServer;
  Try
    if FConnectionToServer = nil then
      Try
        if Srv = '' then
        begin
          Srv := 'localhost';
          Port := CListeningPort;
        end;
        FConnectionToServer := TVideoComsChannel.StartAccess(Srv, Port);
        FConnectionToServer.PermHold := True;
        FConnectionToServer.OnDestroy := CommsDestroy;
        // Would also be set by adding to manager
        Result := FConnectionToServer;
        if FConnectionToServer <> nil then
          SaveIniDetails;
      Except
        On E: exception do
        Begin
          ISIndyUtilsException(self, E, 'Failed to connect to ' + Srv +
            ' on port ' + IntToStr(Port));
          FreeAndNil(FConnectionToServer);
        End;
      end;
    Result := FConnectionToServer;
    if FConnectionToServer = nil then
      Exit;

    if FConnectionToServer.ServerSetRefConnection
      (CDummyCameraLink + IntToStr(Random(9900) + 100)) then
    // 1 chance in 9900 of Rx channels sharing registration
    Begin
      If EdtServerUrl.Visible then
        UpdateConnections;
      EdtServerUrl.Visible := false;
    End
    else
    begin
      ISIndyUtilsException(self,
        '# FConnectionToServer Fail ServerSetRefConnection');
      Result := nil;
      FreeAndNil(FConnectionToServer);
      Exit;
    end;
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'ConnectionToServer');
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.DelayedSetup;
// Delay some create concepts to allow for Android
Var
  IniFile: TIniFile;
  BaseDir: String;
  LogPurge: TLogFile;
begin
  Try
    LoadIniDetails;
    if fKnownServers = nil then
      Exit;
    LogPurge := nil;
    Try
      Try
        LogPurge := AppendLogFileObject(ExceptionLogName);
        LogPurge.PurgeLogFilesOlderThan := (now - 0.1);
      Finally
        LogPurge.Free;
      End;
    Except
    End;
    // moved to LoadLog
    // OpenAppLogging(True, '', False{GblLogAllChlOpenClose},False{GlobalTCPLogAllData},
    // False{GblLogPollActions},False{GblRptRegConnectiononSrvr},
    // False{GblRptIsCommsConnectionAttempts});
    TGblRptComs.ReportObjectTypes; // Start Counting
    UpdateConnections;
    FDelayFormCreateActions := True;
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'Delay Setup');
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.FormCreate(Sender: TObject);
var
  LogPurge: TLogFile;
begin
  GblRptSendImages := True;
  LogPurge := nil;
  Try
    Try
      LogPurge := AppendLogFileObject(ExceptionLogName);
      LogPurge.PurgeLogFilesOlderThan := (now - 0.001);
    Finally
      LogPurge.Free;
    End;
  Except
  End;
  // OpenAppLogging(True, '', GblLogAllChlOpenClose, GlobalTCPLogAllData,
  // GblLogPollActions, GblRptRegConnectiononSrvr,
  // GblRptIsCommsConnectionAttempts);
end;

procedure TFmDummyCamerraForTestingSrvr.FormDestroy(Sender: TObject);
begin
  FFormInDestroy := True;
  BtnResetClick(nil);
  FreeAndNil(fKnownServers);
  GblIndyComsObjectFinalize;
  TSingletonObjTimeSpanRecording.ReleaseSingletonTimeStats;
end;

procedure TFmDummyCamerraForTestingSrvr.LoadIniDetails;
Var
  IniFile: TIniFile;
  i: integer;
  Val: string;
Const
  NullEntry = 'No Val';
begin
  if fKnownServers = nil then
  begin
    fKnownServers := TStringList.Create;
    fKnownServers.OwnsObjects := True;
    fKnownServers.CaseSensitive := false;
  end
  else
    fKnownServers.Clear;
  IniFile := OpenIniFileIS;
  Try
    for i := 0 to 10 do
    Begin
      Val := IniFile.ReadString('Servers', 'Svr' + IntToStr(i + 1), NullEntry);
      if Val <> NullEntry then
        fKnownServers.Add(Val);
    End;
    Val := IniFile.ReadString('Servers', 'CurrentSvr', NullEntry);
    if Val <> NullEntry then
      FCurSrvConnectionString := Val;
  Finally
    IniFile.Free;
  End;
  if fKnownServers.count < 1 then
  begin
    fKnownServers.Add('localhost:1559');
    fKnownServers.Add('scripts.innovasolutions.com.au:1559'); // PORT=1559
    fKnownServers.Add('192.168.1.92:1559');
    fKnownServers.Add('192.168.1.95:1559');
    fKnownServers.Add('192.168.1.94:1559');
    SaveIniDetails;
  end;
end;

function TFmDummyCamerraForTestingSrvr.MediaDevices: TIsMediaCapture;
begin
  if FMediaDevices = nil then
  Begin
    FMediaDevices := TIsMediaCapture.Create(1000, 1000, True{false},True{false}, True);
    // 1000x1000 bitmap.nosync,nolocalbitmapsync,makedummy);
    FMediaDevices.SetBitmap(ImgLocalCamera.Bitmap,
      FMediaDevices.DefaultCameraSelect);
    FMediaDevices.OnSendBitMap := SentBitMapEvent;
    FMediaDevices.SetVideoReturn(OnCameraData,FMediaDevices.DefaultCameraSelect);
    FVideoDisable:= Not False;
    BtnStopVideoClick(nil);   // FMediaDevices.ActivateDeactivateVideo(-1, FVideoDisable);
    FVideoDisable:=False;
  End;
  // FMediaDevices.AddVideoCommsChannel(FConnectionToExtServer);
  FMediaDevices.AddVideoCommsChannel(FConnectionToServer);
  Result := FMediaDevices;
end;

procedure TFmDummyCamerraForTestingSrvr.OnCameraData(ADevice: TCaptureDevice;
  ATime: TDateTime);
begin
 Inc(FCameraImages);
 //Returns are synced at create
 LblCamera.Text:='Camera Images = '+IntToStr(FCameraImages)+' as at '+Formatdatetime('nn:ss.zzz',now);
end;

procedure TFmDummyCamerraForTestingSrvr.SaveIniDetails;
Var
  IniFile: TIniFile;
  i: integer;
  Idx: integer;
begin
  if fKnownServers = nil then
    Exit;

  IniFile := OpenIniFileIS;
  Try
    if FCurSrvConnectionString <> '' then
    Begin
      IniFile.WriteString('Servers', 'CurrentSvr', FCurSrvConnectionString);
      Idx := fKnownServers.IndexOf(FCurSrvConnectionString);
      If Idx < 0 then
        fKnownServers.Insert(0, FCurSrvConnectionString)
      else if Idx > 0 then
      begin
        fKnownServers.Delete(Idx);
        fKnownServers.Insert(0, FCurSrvConnectionString);
      end;
    End;
    if fKnownServers <> nil then
      for i := 0 to fKnownServers.count - 1 do
        IniFile.WriteString('Servers', 'Svr' + IntToStr(i + 1),
          fKnownServers[i]);
  Finally
    IniFile.Free;
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.SentBitMapEvent(ABitMap: TBitMap;
  ASentImages: integer);
begin
  if ASentImages>0 then
     Inc(FImagesActuallySent);
  LblImagesSent.Text := IntToStr(FImagesActuallySent)+' Images Sent to ' + IntToStr(ASentImages) + ' Channels at '+
    FormatDateTime('nn:ss.zzz',now) ;
  if ABitMap <> nil then
  Begin
    ImgSent.Visible := True;
    ImgSent.Bitmap.Assign(ABitMap);
  End
  else
    ImgSent.Bitmap.Assign(nil);
end;

procedure TFmDummyCamerraForTestingSrvr.SetLinkStatusOnOneAction(AFrom,
  ATo: TVideoComsChannel; ALink: AnsiString);
Var
  APort, BPort: integer;
  RsltObj: TVideoComsChannel;
  S: AnsiString;
begin
  BtnLinkStatus.Text := 'No Connection';
  RsltObj := ATo;
  if AFrom = nil then
    APort := 0
  else
  Begin
    RsltObj := AFrom;
    APort := AFrom.LocalPort;
  End;
  if ATo = nil then
    BPort := 0
  else
    BPort := ATo.LocalPort;
  if RsltObj = nil then
    Exit; //

  Case RsltObj.GetLinkStatus(APort, BPort, ALink, S) of
    CoupleError:
      Begin
        BtnLinkStatus.Text := 'CoupleError';
        dec(FStep);
      End;
    NullCouple:
      BtnLinkStatus.Text := 'NullCouple';
    ThisPortExists:
      BtnLinkStatus.Text := 'ThisPortExists';
    ThatPortExists:
      BtnLinkStatus.Text := 'ThatPortExists';
    ThatPortCoupled:
      BtnLinkStatus.Text := 'ThatPortCoupled';
    ThisPortCoupled:
      BtnLinkStatus.Text := 'ThisPortCoupled';
    BothCoupled:
      BtnLinkStatus.Text := 'BothCoupled';
    CoupledTogether:
      BtnLinkStatus.Text := 'CoupledTogether';
    CoupleLinkOK:
      BtnLinkStatus.Text := 'CoupleLinkOK';
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.ShowLogFile;
Var
  Log: TFileStream;
  S: AnsiString;
  Sz: Int64;
begin
  if FFormInDestroy then
    Exit;
  MMoLogData.Visible := True;
  MMoLogData.Lines.Clear;
  Application.ProcessMessages;
  if FileExists(ExceptionLogName) then
    try
      Log := TFileStream.Create(ExceptionLogName, fmOpenRead, fmShareDenyNone);
      try
        Sz := Log.Size;
{$IFDEF NextGen}
        s.Length:=Sz;
        Log.Read(S, Sz);
{$ELSE}
        SetLength(S, Sz);
        Log.Read(S[1], Sz);
{$ENDIF}
        MMoLogData.Text := 'Log File Data' + crlf + S;
      finally
        Log.Free;
      end;
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'Log File Read Fail');
    end;
  if ExceptLog = nil then
    OpenAppLogging(True, '', false { GblLogAllChlOpenClose } ,
      false { GlobalTCPLogAllData } , false { GblLogPollActions } ,
      false { GblRptRegConnectiononSrvr } ,
      false { GblRptIsCommsConnectionAttempts } );

  if ExceptLog <> nil then
    ExceptLog.RollAndFlagNewApplication(True);
end;

procedure TFmDummyCamerraForTestingSrvr.Test8;
Var
  Client: TISIndyTCPClient;
  S: String;
  ConnectResults: TStringList;
begin
  ConnectResults := nil;
  Try
    Try
      Try
        Client := TISIndyTCPClient.StartAccess('Localhost',
          CServiceListeningPort, ClientConnectedReturn);
        S := Client.EchoFromServer('Some Ansi Text to echo from server');
        // if not Client.Activate then
        if not Client.Active then
          ISIndyUtilsException(self, 'Failed to connect to localhost:1777 Id=' +
            Client.TextID)
        else
        begin
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
          S := Client.EchoFromServer('Some Ansi Text to echo from server');
        end;
        Application.ProcessMessages;

        // Client.Port := CServiceListeningPort;
        S := Client.EchoFromServer('Some Ansi Text to echo from server');
        ISIndyUtilsException(self, S);
        Application.ProcessMessages;
        if Client.Active then
        begin
          ISIndyUtilsException(self, 'Connect to localhost Id=' +
            Client.TextID);
          S := Client.AnsiTransaction('Some Ansi Text to Send to server ' +
            FormatDateTime('ss.zzz', now));
          ISIndyUtilsException(self, S);
          S := Client.SimpleActionExtTransaction
            ('You do not need to Flag a simple action ' +
            FormatDateTime('ss.zzz', now));
          ISIndyUtilsException(self, S);
          S := Client.ServerDetails;
          // MmoInfo.Lines.Add('');
          // MmoInfo.Lines.Add(S);
          ConnectResults := TStringList.Create;
          If Client.ServerConnections(ConnectResults, 'Link a') Then
            ISIndyUtilsException(self, ConnectResults.Text);
          Client.ServerConnections(ConnectResults,
            'Link ' + FormatDateTime('zzz', now));
          ISIndyUtilsException(self, '');
          ISIndyUtilsException(self, S);
        end;
        ISIndyUtilsException(self, '');
        ISIndyUtilsException(self, '');

      Finally
        Client.Free;
      End;
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'BtnEchoRequestClick');
    End;
    if ConnectResults <> nil then
    Begin
      ISIndyUtilsException(self, ConnectResults.Text);
      ISIndyUtilsException(self, '');
    End;
  Finally
    ConnectResults.Free;
  End;
end;

procedure TFmDummyCamerraForTestingSrvr.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  try
    if not FDelayFormCreateActions then
      DelayedSetup;
    if FConnectionToServer <> nil then
      if not FConnectionToServer.Active then
      Begin
        // FConnectionToServer.CloseGracefully;
        FreeAndNilDuplexChannel(FConnectionToServer);
      end;
    if FConnectionToServer = nil then
      BtnRestartLink.Text := 'Retry ' + FormatDateTime('nn:ss', now);
  finally
    Timer1.Interval := 5000;
    Timer1.Enabled := True;
  end;
end;

procedure TFmDummyCamerraForTestingSrvr.UpdateConnections;
Var
  Idx: integer;
  Url: string;
  Port: integer;
begin
  if FCurSrvConnectionString = '' then
    if (FConnectionToServer <> nil) and (FConnectionToServer.Active) then
      FCurSrvConnectionString := FConnectionToServer.EnCodeSrvRefCode
        (FConnectionToServer.Address, FConnectionToServer.Port);

  if FCurSrvConnectionString = '' then
    ISIndyUtilsException(self, 'UpdateConnections FCurrentServer=<>')
  else
  Begin
    If fKnownServers.IndexOf(FCurSrvConnectionString) < 0 then
    begin
      if (FConnectionToServer <> nil) and (FConnectionToServer.Active) then
      Begin
        if FConnectionToServer.ExpandSrvRefCode(FCurSrvConnectionString, Url,
          Port) then
          if SameText(FConnectionToServer.Address, Url) and
            (FConnectionToServer.Port = Port) then
          Begin
            fKnownServers.Insert(0, FCurSrvConnectionString);
            SaveIniDetails;
          End;
      End;
    end;
  End;
  CmbxServerSel.Clear;
  CmbxServerSel.Items.AddStrings(fKnownServers);
  Idx := CmbxServerSel.Items.IndexOf(FCurSrvConnectionString);
  if Idx >= 0 then
  Begin
    CmbxServerSel.ItemIndex := Idx;
    EdtServerUrl.Text := FCurSrvConnectionString;
  End;

  EdtServerUrl.Visible := FConnectionToServer = nil;
end;

end.
