unit FmVCLApplicationSrver;
{$IFDEF FPC}
{$MODE Delphi}
// {$I InnovaLibDefsLaz.inc}
{$H+}
{$ELSE}
// {$I InnovaLibDefs.inc}
{$ENDIF}

// Compile Windows 32 Optimisation False
interface

uses
{$IFDEF FPC}
  {Windows,} Messages,
  DateUtils, SyncObjs,
  IniFiles, IsLazTimeSpan,
  SysUtils, {IOUtils,}
  Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  IsLazarusPickup,
{$ELSE}
  Winapi.Windows, Winapi.Messages,
  System.DateUtils, System.SyncObjs,
  System.IniFiles, TimeSpan,
  System.SysUtils, System.IOUtils,
  System.Variants, System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Mask,
{$ENDIF}
  ISProcCl,
  IsIndyTCPApplicationServer, IsRemoteConnectionIndyTCPObjs,
  IsMediaCommsObjs, IsImageManagerVCL;

type

  { TServerForm }

  TServerForm = class(TForm)
    PnlTop: TPanel;
    PnlBottom: TPanel;
    TimerStatus: TTimer;
    BtnSendGetFile: TButton;
    BtnEchoRequest: TButton;
    BtnStartStopMonitor: TButton;
    BtnFollowOn: TButton;
    BtnOffThreadFree: TButton;
    BtnShowLog: TButton;
    BtnTestAutoCloseAndHold: TButton;
    BtnTestConnectAndRespond: TButton;
    BtnStartVideoComms: TButton;
    BtnChkLinkState: TButton;
    BtnSendBackState: TButton;
    BtnSrvResponseTimes: TButton;
    BtnSrvDetails: TButton;
    PnlAllData: TPanel;
    PnlImages: TPanel;
    PnlRxImage: TPanel;
    PnlRxData: TPanel;
    MmoRexData: TMemo;
    PnlCheckBoxes: TPanel;
    ImgSend: TImage;
    ChkBxLogMC: TCheckBox;
    ChkBxLogCO: TCheckBox;
    ChkBxLogPA: TCheckBox;
    ChkBxLogCl: TCheckBox;
    ChkBxLogAll: TCheckBox;
    ChkBxLogTD: TCheckBox;
    ChkBxLogRc: TCheckBox;
    ChkBxLogAC: TCheckBox;
    ChkBxLogCA: TCheckBox;
    ChkBxLogAllEx: TCheckBox;
    PnlInfo: TPanel;
    MmoInfo: TMemo;
    MmoRegistrations: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    LblEdtMeteredSleep: TLabeledEdit;
    PnlBusy: TPanel;
    BtnExternalServer: TButton;
    CmbxExtnalServerSel: TComboBox;
    TimerCleanup: TTimer;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TimerStatusTimer(Sender: TObject);
    procedure TimerCleanupTimer(Sender: TObject);
    procedure BtnSendGetFileClick(Sender: TObject);
    procedure BtnEchoRequestClick(Sender: TObject);
    procedure BtnStartStopMonitorClick(Sender: TObject);
    procedure BtnFollowOnClick(Sender: TObject);
    procedure BtnOffThreadFreeClick(Sender: TObject);
    procedure BtnTestConnectAndRespondClick(Sender: TObject);
    procedure BtnShowLogClick(Sender: TObject);
    procedure BtnTestAutoCloseAndHoldClick(Sender: TObject);
    procedure ChkBxLoggingClick(Sender: TObject);
    procedure BtnStartVideoCommsClick(Sender: TObject);
    procedure BtnChkLinkStateClick(Sender: TObject);
    procedure BtnSendBackStateClick(Sender: TObject);
    procedure BtnSrvDetailsClick(Sender: TObject);
    procedure BtnSrvResponseTimesClick(Sender: TObject);
    procedure LblEdtMeteredSleepChange(Sender: TObject);
    procedure BtnExternalServerClick(Sender: TObject);
    procedure CmbxExtnalServerSelExitEnter(Sender: TObject);
  private
    { Private declarations }
    FFormInDestroy: Boolean;
    // FImageSetUp: boolean;
    FImageManager: TImageMngrVCL;
    FRxText: string;
    FWaitSync: TCriticalSection;
    FCommsServer, FSecondaryComsServer: TIsIndyApplicationServer;
    // FCameraVideoChnl,
    FTestServer: TIsMonitorTCPAppServer;
    // FSimpleClient: TISIndyTCPClient;
    // FDuplexClientAdvertised, FDuplexClientLinked,
    FRxVideoChnl, FSendVideoChnl: TVideoComsChannel;
    FNoWaitCntrlChl: TNoWaitReturnThread;
    FSendMessageback: TISIndyTCPFullDuplexClient;
    FFwdTst: TISIndyTCPFullDuplexClient;
    FSaveAllOldSessions { , FListOfCurrentVideoRx } : TStringList;
    fKnownServers: TStringList;
    FCurSrvAddress: AnsiString;
    FCurSrvListeningPort: integer;
    FCurSrvConnectionString: string;
    FUseExternalServer: Boolean;
    FNextStatusTimer, FNextCleanupTimer: TDateTime;
    Procedure BusyStart;
    Procedure BusyEnd;
    Procedure LoadIniDetails;
    Procedure SaveIniDetails;
    procedure AlignCurServerToComboBox;
    Function CommsServer: TIsIndyApplicationServer;
    Function ImageManager: TImageMngrVCL;
    Function WaitSync: TCriticalSection;
    Function OnAnsiStringRxPrimaryServer(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnAnsiStringRxSendMsgBackClient(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnSimpleDuplexRxSendMsgBackClient(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnAnsiStringClientRx(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnAnsiStringSecondaryRx(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnSimpleActionRxOnServer(ACommand: AnsiString;
      ATcpSession: TISIndyTCPBase): AnsiString;
    Function OnStringActionRX(AData: String;
      ATcpSession: TISIndyTCPBase): String;
    Procedure FreeAllResourcesBeforeClose;
    Procedure OnFwrdTstRtn(ATcpSession: TISIndyTCPClient);
    Procedure LinkAnyDefaultCamerasLaunch;
    Procedure OnLinkAnyDefaultCameras(ATcp: TISIndyTCPClient);
    Procedure SetupVideoPathAndAdvertise(AConnectObj: TObject);
    Procedure SetupVideoRxForStaticImage(AConnectObj: TObject);
    Procedure SendMockCameraImage(AConnectObj: TObject);
    Procedure HandleInComingGraphicOnVideoRx(AGraphic: TGraphic);
    Procedure ClosingFormObject(Sender: TObject);
    Procedure NoWaitClosing(Sender: TObject);
    Procedure NoWaitTCPReturn(ARtn: TISIndyTCPClient);
    Procedure ClientConnectedReturn(Sender: TObject);
    Procedure ShowLogFile; // Puts Logfile in Memo
    Procedure MmoStartTest(AMsg: string);
    Procedure ClearOldSessions;
    Procedure CheckExistingConnections;
  public
    { Public declarations }
  end;

var
  ServerForm: TServerForm;

implementation

Uses
{$IFDEF Debug}
{$IFDEF TestFastMM}
  ISFastMMInit,
{$ENDIF}
{$ENDIF}
  isGeneralLib, IsGblLogCheck, CommsDemoCommonValues,
  IsIndyUtils, IsIndyLib, IsObjectTimeSpanRecording, IsLogging;
{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TServerForm }
Const
  cVideoChlId = 'LocalVideoLink';

procedure TServerForm.AlignCurServerToComboBox;
Var
  Srv: string;
  Port, Idx: integer;
  Clt: TISIndyTCPClient;
begin
  Clt:=nil;
  try
    if fKnownServers = nil then
      LoadIniDetails;

    if (FCurSrvConnectionString = '') then
      FCurSrvConnectionString := 'LocalHost:' + IntToStr(CListeningPort);

    if not FUseExternalServer then
    begin
      FCurSrvConnectionString := 'LocalHost:' + IntToStr(CListeningPort);
      FCurSrvAddress := 'LocalHost';
      FCurSrvListeningPort := CListeningPort;
      BtnExternalServer.Caption := 'Connect to External server';
      Exit;
    end;

    if TISIndyTCPBase.ExpandSrvRefCode(CmbxExtnalServerSel.Text, Srv, Port) then
      FCurSrvConnectionString := CmbxExtnalServerSel.Text
    else if Not TISIndyTCPBase.ExpandSrvRefCode(FCurSrvConnectionString, Srv,
      Port) then
    begin
      Srv := FCurSrvAddress;
      Port := FCurSrvListeningPort;
      FCurSrvConnectionString := Srv + ':' + IntToStr(FCurSrvListeningPort);
    end;

    Idx := CmbxExtnalServerSel.Items.IndexOf(FCurSrvConnectionString);

    If Idx < 0 then
      If TISIndyTCPBase.ExpandSrvRefCode(FCurSrvConnectionString, Srv, Port)
      then
        Try
          Clt := nil;
          Try
            Clt := TISIndyTCPClient.StartAccess(Srv, Port, nil);
            if Clt.Activate then
            Begin
              fKnownServers.Add(FCurSrvConnectionString);
              CmbxExtnalServerSel.Clear;
              CmbxExtnalServerSel.Items.AddStrings(fKnownServers);
              Idx := CmbxExtnalServerSel.Items.IndexOf(FCurSrvConnectionString);
              SaveIniDetails;
            End;
          Except
            On E: exception do
              ISIndyUtilsException(self, E, 'ConnectionToServer Clt Exception');
          End;
        Finally
          Clt.Free;
        end;
    CmbxExtnalServerSel.ItemIndex := Idx;

    FCurSrvAddress := Srv;
    FCurSrvListeningPort := Port;
    FCurSrvConnectionString := Srv + ':' + IntToStr(FCurSrvListeningPort);
    BtnExternalServer.Caption := 'Will Call ' + FCurSrvConnectionString;
    CheckExistingConnections;
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'ConnectionToServer');
  End;
end;

procedure TServerForm.BtnChkLinkStateClick(Sender: TObject);
Var
  LocalClient: TISIndyTCPClient;
  LocalDuplex, LocalDuplex2: TISIndyTCPFullDuplexClient;
  Response: AnsiString;
begin
  try
    BusyStart;
    MmoStartTest('Check Lnk State Test');
    LocalDuplex := nil;
//    LocalDuplex2 := nil;
    LocalClient := TISIndyTCPClient.StartAccess(FCurSrvAddress,
      FCurSrvListeningPort, ClientConnectedReturn);
    try
      Application.ProcessMessages;
      Case LocalClient.GetLinkStatus(LocalClient.LocalPort, 0, '', Response) of
        CoupleError:
          MmoRexData.Lines.Add('Error:' + Response);
        ThisPortExists:
          MmoRexData.Lines.Add('Call Noted on Port One:' + Response);
        RegButNoLinks, NullCouple, ThatPortExists, ThisPortCoupled,
          ThatPortCoupled, BothCoupled, CoupledTogether, CoupleLinkOK:
          MmoRexData.Lines.Add('Error:' + Response);
      End;
      Application.ProcessMessages;
      LocalDuplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort, ClientConnectedReturn);
      LocalDuplex.ServerSetFollowonConnection(FCurSrvAddress,
        CListeningPort + 10);
      Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort, 0, '', Response) of
        CoupleError:
          MmoRexData.Lines.Add('Error:' + Response);
        ThisPortCoupled:
          MmoRexData.Lines.Add('Dplx Call Coupled Follow on:' + Response);
        RegButNoLinks, NullCouple, ThisPortExists, ThatPortExists,
          ThatPortCoupled, BothCoupled, CoupledTogether, CoupleLinkOK:
          MmoRexData.Lines.Add('Error:' + Response);
      End;
      Application.ProcessMessages;
      FreeAndNilDuplexChannel(Pointer(LocalDuplex));
      LocalDuplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort, ClientConnectedReturn);
      LocalDuplex.ServerConnections(nil, 'TestRegLink');
      Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort, 0, 'TestRegLink',
        Response) of
        CoupleError:
          MmoRexData.Lines.Add('Error:' + Response);
        RegButNoLinks:
          MmoRexData.Lines.Add('Dplx Call Registered:' + Response);
        ThisPortCoupled, NullCouple, ThisPortExists, ThatPortExists,
          ThatPortCoupled, BothCoupled, CoupledTogether, CoupleLinkOK:
          MmoRexData.Lines.Add('Error:' + Response);
      End;
      Application.ProcessMessages;
      LocalDuplex2 := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort, ClientConnectedReturn);
      If Not LocalDuplex2.ServerSetLinkConnection('TestRegLink') then
        MmoRexData.Lines.Add('Error: failed connection to TestRegLink' +
          Response);

      Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort, 0, 'TestRegLink',
        Response) of
        CoupleError:
          MmoRexData.Lines.Add('Error:' + Response);
        CoupleLinkOK:
          MmoRexData.Lines.Add('Coupled to TestRegLink ::' + Response);
        RegButNoLinks:
          MmoRexData.Lines.Add('Registered:' + Response); // Reg Only
        ThisPortCoupled:
          MmoRexData.Lines.Add('This Port Coupled :' + Response);
        NullCouple, ThisPortExists, ThatPortExists, ThatPortCoupled,
          BothCoupled, CoupledTogether:
          MmoRexData.Lines.Add('Error:' + Response);
      End;

      Application.ProcessMessages;
      Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort,
        LocalDuplex2.LocalPort, 'TestRegLink', Response) of
        CoupleError:
          MmoRexData.Lines.Add('Error:' + Response);
        CoupleLinkOK:
          MmoRexData.Lines.Add('Coupled to TestRegLink ::' + Response); // OK
        RegButNoLinks:
          MmoRexData.Lines.Add('Registered:' + Response);
        ThisPortCoupled:
          MmoRexData.Lines.Add('This Port Coupled :' + Response);
        NullCouple, ThisPortExists, ThatPortExists, ThatPortCoupled,
          BothCoupled, CoupledTogether:
          MmoRexData.Lines.Add('Error:' + Response);
      End;
      FreeAndNilDuplexChannel(Pointer(LocalDuplex));
      FreeAndNilDuplexChannel(Pointer(LocalDuplex2));
      LocalDuplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort, ClientConnectedReturn);
      if FSendVideoChnl <> nil then
      begin
        FSendVideoChnl.ServerConnections(nil, cVideoChlId);
        LocalDuplex.ServerSetLinkConnection(cVideoChlId);
        Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort,
          FSendVideoChnl.LocalPort, cVideoChlId, Response) of
          CoupleError:
            MmoRexData.Lines.Add('Error:' + Response);
          CoupleLinkOK:
            MmoRexData.Lines.Add('Coupled to VideoChannel ::' + Response);
          RegButNoLinks:
            MmoRexData.Lines.Add('Registered:' + Response);
          ThisPortCoupled, NullCouple, ThisPortExists, ThatPortExists,
            ThatPortCoupled, BothCoupled, CoupledTogether:
            MmoRexData.Lines.Add('Error:' + Response);
        End;
        Application.ProcessMessages;
        Case LocalClient.GetLinkStatus(LocalDuplex.LocalPort,
          FSendVideoChnl.LocalPort, 'NotVideoChannel', Response) of
          CoupleError:
            MmoRexData.Lines.Add('Error:' + Response);
          CoupleLinkOK:
            MmoRexData.Lines.Add('Coupled to VideoChannel ::' + Response);
          CoupledTogether:
            MmoRexData.Lines.Add('Coupled Together ::' + Response);
          RegButNoLinks:
            MmoRexData.Lines.Add('Dplx Error Coupled Registered:' + Response);
          ThisPortCoupled, NullCouple, ThisPortExists, ThatPortExists,
            ThatPortCoupled, BothCoupled:
            MmoRexData.Lines.Add('Error:' + Response);
        End;
        Application.ProcessMessages;
        FreeAndNil(FRxVideoChnl); // it was forced to unlinked
        FreeAndNilDuplexChannel(Pointer(LocalDuplex2));
        FreeAndNilDuplexChannel(Pointer(LocalDuplex));
      end;
    finally
      FreeAndNilDuplexChannel(Pointer(LocalDuplex));
      LocalClient.Free;
    end;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnEchoRequestClick(Sender: TObject);
Var
  Client: TISIndyTCPClient;
  S: AnsiString;
{$IFNDEF  SuppressIPMetering}
  MeterBit: AnsiString;
{$ENDIF}
begin
  Client:=nil;
  try
    BusyStart;
    MmoStartTest('Echo Test');
    Try
      Try
        S := 'Some Ansi Text to echo from server';
{$IFNDEF  SuppressIPMetering}
        AddSetMeteredTimeRecAsString(S, 'Echo');
{$ENDIF}
        Client := TISIndyTCPClient.StartAccess(FCurSrvAddress,
          FCurSrvListeningPort, ClientConnectedReturn);
        S := Client.EchoFromServer(S);
        if not Client.Active then
        begin
          MmoInfo.Lines.Add('Failed to connect to ' + FCurSrvAddress + ':' +
            IntToStr(CListeningPort) + ' Id=' + Client.TextID);
          S := Client.EchoFromServer
            ('Some Ansi Text to echo from server Second Try'
{$IFNDEF  SuppressIPMetering}
            + AddMeteredTimeRecAsString('Echo2')
{$ENDIF}
            );
        end;
{$IFNDEF  SuppressIPMetering}
        if SplitMeteredData(S, MeterBit) then
        Begin
          MeterBit := MeterBit + AddMeteredTimeRecAsString('EchoRTN');
          MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
          if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
            ISIndyUtilsException(self, 'Time Metered Fail Echo')
        End;
{$ENDIF}
        MmoInfo.Lines.Add(S);
        MmoInfo.Lines.Add('');
      Finally
        Client.Free;
      End;
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'BtnEchoRequestClick');
    End;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnExternalServerClick(Sender: TObject);
begin
  if fKnownServers = nil then
    LoadIniDetails;

  FUseExternalServer := not FUseExternalServer;

  if not FUseExternalServer then
  Begin
    BtnExternalServer.Caption := 'Connect to External server';
    CmbxExtnalServerSel.Visible := False;
    FCurSrvConnectionString := 'LocalHost:' + IntToStr(CListeningPort);
    FCurSrvAddress := 'LocalHost';
    FCurSrvListeningPort := CListeningPort;
    BtnFollowOn.Enabled := true;
    BtnOffThreadFree.Enabled := true;
    BtnChkLinkState.Enabled := true;
  End
  Else
  Begin
    CmbxExtnalServerSel.Clear;
    CmbxExtnalServerSel.Items.AddStrings(fKnownServers);
    AlignCurServerToComboBox;
    CmbxExtnalServerSel.Visible := true;
    BtnFollowOn.Enabled := False;
    BtnOffThreadFree.Enabled := False;
    BtnChkLinkState.Enabled := False;
  End;
end;

procedure TServerForm.BtnStartStopMonitorClick(Sender: TObject);
begin
  If FTestServer = nil then
    FTestServer := TIsMonitorTCPAppServer.Create(FCurSrvAddress, CListeningPort)
  Else
    FreeAndNil(FTestServer);
  If FTestServer = nil then
    BtnStartStopMonitor.Caption := 'Start Mon'
  Else
    BtnStartStopMonitor.Caption := 'Stop Mon';
end;

procedure TServerForm.BtnStartVideoCommsClick(Sender: TObject);
begin
  try
    BusyStart;
    if FSendVideoChnl = nil then
      SetupVideoPathAndAdvertise(nil)
    Else If FRxVideoChnl = nil then
      SetupVideoRxForStaticImage(nil)
    Else
    Begin
      BtnStartVideoComms.Caption := '';
      SendMockCameraImage(FSendVideoChnl);
    End;

    if FSendVideoChnl <> nil then
      if Not FSendVideoChnl.Active then
        FreeAndNil(FSendVideoChnl);

    if FRxVideoChnl <> nil then
      if Not FRxVideoChnl.Active then
        FreeAndNil(FRxVideoChnl);

    if FRxVideoChnl <> nil then // but is active
      if not FRxVideoChnl.ChannelActiveWithGraphic(30) then
        If not FRxVideoChnl.IsLinked then
          FreeAndNil(FRxVideoChnl);

    If FRxVideoChnl <> nil then
      BtnStartVideoComms.Caption := 'Rx Channel ' + FRxVideoChnl.TextID +
        FormatDateTime(' nn:ss', now)
    else if FSendVideoChnl <> nil then
      BtnStartVideoComms.Caption := 'Send Channel ' + FSendVideoChnl.TextID +
        FormatDateTime(' nn:ss', now)
    Else
      BtnStartVideoComms.Caption := 'Retry Set Video' +
        FormatDateTime(' nn:ss', now);
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnFollowOnClick(Sender: TObject);
Var
  Client: TISIndyTCPFullDuplexClient;
  S: AnsiString;
{$IFNDEF  SuppressIPMetering}
  MeterBit: AnsiString;
{$ENDIF}
begin
  try
    BusyStart;
    MmoStartTest('Follow On Test');
    If FSecondaryComsServer = nil then
    begin
      FSecondaryComsServer := TIsIndyApplicationServer.Create(nil);
      FSecondaryComsServer.OnSessionAnsiStringAction := OnAnsiStringSecondaryRx;
      FSecondaryComsServer.OnSessionStringAction := OnStringActionRX;
      FSecondaryComsServer.OnSessionSimpleRemoteAction :=
        OnSimpleActionRxOnServer;
      FSecondaryComsServer.DefaultPort := CListeningPort + 10;
      FSecondaryComsServer.Active := true;
    end;

    Client := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
      CListeningPort);
    // set up call to server
    try
      Client.ServerSetFollowonConnection(FCurSrvAddress, CListeningPort + 10);
      S := 'Some Ansi Text to Send to server ' + FormatDateTime('ss.zzz', now);
{$IFNDEF  SuppressIPMetering}
      AddSetMeteredTimeRecAsString(S, 'Follow');
{$ENDIF}
      S := Client.AnsiTransaction(S);
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);

{$IFNDEF  SuppressIPMetering}
      Client.TimeStampMetering := true;
{$ENDIF}
      S := #13#10#13#10 + Client.ServerDetails;
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Server Details get via ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);
      Client.ServerSetFollowonConnection(FCurSrvAddress, CListeningPort);
      S := #13#10'Text to Send to Server Back to original server ' +
        FormatDateTime('ss.zzz', now);
{$IFNDEF  SuppressIPMetering}
      AddSetMeteredTimeRecAsString(S, 'Follow2');
{$ENDIF}
      S := #13#10#13#10 + Client.AnsiTransaction(S);
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);
      S := #13#10#13#10 + Client.ServerDetails;
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);
      Client.ServerSetFollowonConnection(FCurSrvAddress, CListeningPort + 10);
      S := #13#10'Loop back to second ' + FormatDateTime('ss.zzz', now);
{$IFNDEF  SuppressIPMetering}
      AddSetMeteredTimeRecAsString(S, 'Follow3');
{$ENDIF}
      S := #13#10#13#10 + Client.AnsiTransaction(S);
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);
      S := #13#10#13#10 + Client.ServerDetails;
{$IFNDEF  SuppressIPMetering}
      if SplitMeteredData(S, MeterBit) then
      Begin
        MeterBit := MeterBit + AddMeteredTimeRecAsString('FlOnRTN');
        MmoRexData.Lines.Add(#13#10'Metering for ' + Client.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeterBit) then
          ISIndyUtilsException(self, 'Time Metered Fail Follow On')
      End;
{$ENDIF}
      MmoRexData.Lines.Add(S);
      Application.ProcessMessages;
      sleep(5000);
    finally
      Client.Free;
    end;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnOffThreadFreeClick(Sender: TObject);
{ Start up a number of Clients the call offline free
  Offline free returns immediatly
  Reports on the serverside connections
  It takes some time before all are closed
  All resources are freed via offline free but you do not need to wait
  a normal free can take seconds as the circuit is closed }

Var
  OffLineFreeServerClient, ClientForOfflineFree: TISIndyTCPFullDuplexClient;
  RstList: TStringList;
  S: string;
  Loopcount: integer;
begin
  try
    ClientForOfflineFree:=nil;
    BusyStart;
    MmoStartTest('Test Off Thread Free');
    RstList := TStringList.Create;
    try
      OffLineFreeServerClient := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      S := RstList.Text;
      ClientForOfflineFree := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      ClientForOfflineFree.ServerConnections(RstList,
        'RegThat' + FormatDateTime('nnsszzz', now));
      MmoInfo.Lines.Add(crlf + RstList.Text);
      OffLineFreeServerClient.OffThreadDestroy(False);
      OffLineFreeServerClient := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      OffLineFreeServerClient.ServerConnections(RstList,
        'Reg' + FormatDateTime('nnsszzz', now));
      MmoInfo.Lines.Add(crlf + RstList.Text);
      OffLineFreeServerClient.OffThreadDestroy(False);
      OffLineFreeServerClient := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      OffLineFreeServerClient.ServerConnections(RstList,
        'Reg' + FormatDateTime('nnsszzz', now));
      MmoInfo.Lines.Add(crlf + RstList.Text);
      OffLineFreeServerClient.OffThreadDestroy(False);
      OffLineFreeServerClient := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      OffLineFreeServerClient.ServerConnections(RstList,
        'Reg' + FormatDateTime('nnsszzz', now));
      MmoInfo.Lines.Add(crlf + RstList.Text);
      OffLineFreeServerClient.OffThreadDestroy(False);
      OffLineFreeServerClient := TISIndyTCPFullDuplexClient.StartAccess
        (FCurSrvAddress, CListeningPort);
      OffLineFreeServerClient.ServerConnections(RstList,
        'Reg' + FormatDateTime('nnsszzz', now));
      MmoInfo.Lines.Add(crlf + RstList.Text);
      OffLineFreeServerClient.OffThreadDestroy(False);
      Application.ProcessMessages;
      sleep(500);
      ClientForOfflineFree.ServerConnections(RstList, '');
      MmoInfo.Lines.Add(crlf + RstList.Text);
      Application.ProcessMessages;
      // switching form while loop to for loop
      // Loopcount := 20;
      // while Loopcount > 1 do
      // Begin
      // Dec(Loopcount);
      For Loopcount := 1 to 20 do
      begin
        sleep(500);
        ClientForOfflineFree.ServerConnections(RstList, '');
        MmoInfo.Lines.Add(crlf + RstList.Text);
        Application.ProcessMessages;
      End;
    finally
      FreeAndNilDuplexChannel(Pointer(ClientForOfflineFree));
      FreeAndNil(RstList);
    end;
    Application.ProcessMessages;
    sleep(2000);
    MmoInfo.Lines.Add('Comms Objects');
    MmoInfo.Lines.Add(TGblRptComs.ReportObjectTypes);
    MmoInfo.Lines.Add('End Test'#13#10);
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnSendBackStateClick(Sender: TObject);
Var
  // FwdRsp: ansistring;
  i: integer;
  RegData: AnsiString;
begin
  try
    BusyStart;
    if FSaveAllOldSessions = nil then
      Exit;
    If FSendMessageback = nil then
      Exit;

    FFwdTst := nil;
    if FSaveAllOldSessions.Objects[4] is TISIndyTCPFullDuplexClient then
      FFwdTst := TISIndyTCPFullDuplexClient(FSaveAllOldSessions.Objects[4]);

    if FFwdTst = nil then
      Exit;

    if not Assigned(FFwdTst.OnAnsiStringAction) then
    Begin
      MmoRexData.Lines.Add('not Assigned(FFwdTst.OnAnsiStringAction)');
      Exit;
    End;

    MmoStartTest('Send 20 Msgs Forward for loopback');

    Case FFwdTst.GetLinkStatus(FFwdTst.LocalPort, FSendMessageback.LocalPort,
      FSaveAllOldSessions[4], RegData) of
      CoupleError, RegButNoLinks, NullCouple, ThisPortExists, ThatPortExists,
        ThisPortCoupled, ThatPortCoupled, BothCoupled, CoupledTogether:
        Begin
          MmoRexData.Lines.Add('');
          MmoRexData.Lines.Add('Fwd Not Linked to SendBack ::' + RegData);
          Exit;
        End;
      CoupleLinkOK:
        MmoRexData.Lines.Add('Fwd is Linked to SendBack as ' + RegData);
    End;

{$IFNDEF  SuppressIPMetering}
    FFwdTst.TimeStampMetering := true;
{$ENDIF}
    MmoRexData.Lines.Add('');
    MmoRexData.Lines.Add('State of Wait Messages');
    MmoRexData.Lines.Add('');
    for i := 1 to 20 do
    Begin
      FFwdTst.AnsiTransactionNoWait('Forward Test ' + IntToStr(i), nil,
        OnFwrdTstRtn);
      // FSendMessageback.AnsiTransactionNoWait('BackTest '+IntToStr(i));
    End;
    MmoRexData.Lines.Add('Fwd ' + FFwdTst.MessageWaitState);
    MmoRexData.Lines.Add('Bck ' + FSendMessageback.MessageWaitState);
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnSendGetFileClick(Sender: TObject);
Var
  ThisServerClient: TISIndyTCPClient;
  ThatServerClient: TISIndyTCPFullDuplexClient;
  TestFile: TFileStream;
  FileRecovered: TMemoryStream;
begin
  try
    BusyStart;
    MmoStartTest('Simple Client File Transfer');
    TestFile := nil;
    Try
      TestFile := TFileStream.Create(TestFileName, fmOpenRead);
      try
        // File to server in this application
        ThisServerClient := TISIndyTCPClient.StartAccess(FCurSrvAddress,
          FCurSrvListeningPort);
        ThisServerClient.PutLargeStreamToServer(TestFile,
          'Temp\NewTestUpload.txt');
        // putting in Temp directory enables overwrite if file exists
        if GlobalDefaultFileAccessBase <> '' then
          if FileExists(TPath.Combine(GlobalDefaultFileAccessBase,
            'Temp\NewTestUpload.txt')) then
            MmoInfo.Lines.Add('File Uploaded');
        Application.ProcessMessages;
        FileRecovered := TMemoryStream.Create;
        try
          ThisServerClient.CopyLargeServerFileToStream(FileRecovered,
            'Temp\NewTestUpload.txt');
          if FileRecovered.Size > 500 then
            if FileRecovered.Size = TestFile.Size then
              MmoInfo.Lines.Add('File Downloaded');
        finally
          FileRecovered.Free;
          FreeAndNil(ThisServerClient);
        end;
        Application.ProcessMessages;
        MmoInfo.Lines.Add(#13#10 + 'Duplex Client File Transfer');
        Try
          ThatServerClient := TISIndyTCPFullDuplexClient.StartAccess
            (FCurSrvAddress, FCurSrvListeningPort);
        Except
          ThatServerClient := nil;
        end;
        if ThatServerClient = nil then
          MmoInfo.Lines.Add('Service Application not running')
        else
        Begin
          TestFile.Seek(0, soFromBeginning); // reset test file
          ThatServerClient.PutLargeStreamToServer(TestFile,
            'Temp\NewTestUpload.txt');
          MmoInfo.Lines.Add('File Uploaded');
          Application.ProcessMessages;
          FileRecovered := TMemoryStream.Create;
          try
            ThatServerClient.CopyLargeServerFileToStream(FileRecovered,
              'Temp\NewTestUpload.txt');
            if FileRecovered.Size > 500 then
              if FileRecovered.Size = TestFile.Size then
                MmoInfo.Lines.Add('File Downloaded' + #13#10);
          finally
            FileRecovered.Free;
            FreeAndNil(ThatServerClient);
          end;
        End;
      Except
        On E: exception do
        begin
          MmoInfo.Lines.Add(E.Message);
          FreeAndNil(ThatServerClient);
          FreeAndNil(ThisServerClient);
        end;
      End;
    Finally
      TestFile.Free;
    End;
  finally
    BusyEnd;
  end;

end;

procedure TServerForm.BtnShowLogClick(Sender: TObject);
begin
  try
    BusyStart;
    ShowLogFile;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnSrvDetailsClick(Sender: TObject);
Var
  ConnectList: TStringList;
  WillWait: TISIndyTCPClient;
begin
  try
    BusyStart;
    MmoStartTest('Getting Details From Server with Wait');
    WillWait := nil;
    ConnectList := TStringList.Create;
    try
      WillWait := TISIndyTCPClient.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort);
      WillWait.ServerConnections(ConnectList, '');
      MmoRexData.Lines.Add('');
      if FCommsServer = nil then
      Begin
        MmoRexData.Lines.Add('');
        MmoRexData.Lines.Add(#13#10'Server is external'#13#10 +
          'This App Object Data is');
        MmoRexData.Lines.Add('Wait Object Data');
        MmoRexData.Lines.Add(TWaitData.ReportWaitTimes);
        MmoRexData.Lines.Add('');
        MmoRexData.Lines.Add('Object LifeSpan Data');
        MmoRexData.Lines.Add
          (TSingletonObjTimeSpanRecording.SingletonLifeTimeStats);
      End;
      MmoRexData.Lines.Add('');
      MmoRexData.Lines.Add('');
      MmoRexData.Lines.Add('From Server');
      MmoRexData.Lines.Add(WillWait.ServerDetails);
      MmoRexData.Lines.Add('End Current Connections>>'#13#10);
      MmoRexData.Lines.Add(WillWait.LogTextOnServer('Put Text in Server Log'));
      MmoRexData.Lines.Add(#13#10'Connections Advertised');
      MmoRexData.Lines.AddStrings(ConnectList);
      MmoRexData.Lines.Add('End Current Connections>>'#13#10);
      MmoRexData.CaretPos := Point(0, MmoRexData.Lines.Count-1);
      //MmoRexData.selstart := MaxInt;
    finally
      WillWait.Free;
      ConnectList.Free;
    End;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnSrvResponseTimesClick(Sender: TObject);
begin
  try
    BusyStart;
    MmoStartTest('Server Response time info');
    if FCommsServer = nil then
      Exit;

    MmoRexData.Lines.Add(FCommsServer.AllConnectionResponseTimesAsText);
    MmoInfo.Lines.Add(FCommsServer.AllConnectionsAsText);
    MmoRexData.Lines.Add('');
    MmoRexData.Lines.Add('Wait Object Data');
    MmoRexData.Lines.Add(TWaitData.ReportWaitTimes);
    MmoRexData.Lines.Add('');
    MmoRexData.Lines.Add('Object LifeSpan Data');
    MmoRexData.Lines.Add(TSingletonObjTimeSpanRecording.SingletonLifeTimeStats);
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnTestAutoCloseAndHoldClick(Sender: TObject);
{ sub } procedure AddASeries;
  Var
    RegStrg, NoWaitRegStrg: string;
    Client: TISIndyTCPClient;
    Duplex: TISIndyTCPFullDuplexClient;
    NoWaitRtnThread: TNoWaitReturnThread;
  begin
    Try
      NoWaitRtnThread := TNoWaitReturnThread.Create(FCurSrvAddress,
        FCurSrvListeningPort, NoWaitClosing);
      NoWaitRegStrg := 'NoWaitRtnThread' + FormatDateTime('nnsszzz', now);
      if FSaveAllOldSessions.count > 1 then
      Begin
        NoWaitRegStrg := 'NoWaitRtnThread Hold ' +
          FormatDateTime('nnsszzz', now);
        NoWaitRtnThread.PermHold := true;
        FSaveAllOldSessions.AddObject(NoWaitRegStrg, NoWaitRtnThread); // no 0
      End
      else
        FSaveAllOldSessions.AddObject(NoWaitRegStrg, NoWaitRtnThread);
      NoWaitRtnThread.ServerDetailsNoWait(NoWaitTCPReturn);
      Client := TISIndyTCPClient.StartAccess(FCurSrvAddress, CListeningPort);
      Client.OnDestroy := ClosingFormObject;
      RegStrg := 'Client' + FormatDateTime('nnsszzz', now);
      FSaveAllOldSessions.AddObject(RegStrg, Client); // no 1
      Client.ServerConnections(nil, RegStrg);
      Duplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        CListeningPort);
      Duplex.OnAnsiStringAction := OnAnsiStringClientRx;
      Duplex.OnDestroy := ClosingFormObject;
      Duplex.SynchronizeResults := true;
      RegStrg := 'Duplex No Hold' + FormatDateTime('nnsszzz', now);
      FSaveAllOldSessions.AddObject(RegStrg, Duplex); // no 2
      Duplex.ServerConnections(nil, RegStrg);
      Client := TISIndyTCPClient.StartAccess(FCurSrvAddress, CListeningPort);
      Client.OnDestroy := ClosingFormObject;
      RegStrg := 'Client' + FormatDateTime('nnsszzz', now);
      FSaveAllOldSessions.AddObject(RegStrg, Client); // no 3
      Client.ServerConnections(nil, RegStrg);
      Duplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        CListeningPort);
      Duplex.PermHold := true;
      Duplex.OnAnsiStringAction := OnAnsiStringClientRx;
      Duplex.OnDestroy := ClosingFormObject;
      Duplex.SynchronizeResults := true;
      RegStrg := 'Duplex Hold' + FormatDateTime('nnsszzz', now);
      FSaveAllOldSessions.AddObject(RegStrg, Duplex); // no 4
      Duplex.ServerConnections(nil, RegStrg);
{$IFNDEF  SuppressIPMetering}
      NoWaitRtnThread.ThreadTimeStampMetering := true;
{$ENDIF}
      NoWaitRtnThread.ServerConnectionsNoWait(nil, NoWaitRegStrg,
        NoWaitTCPReturn); // return always synchronised
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'AddASeries');
    End;
  end;
{ sub } procedure AddOneDuplex;
  Var
    RegStrg: string;
    Duplex: TISIndyTCPFullDuplexClient;
  begin
    try
      Duplex := TISIndyTCPFullDuplexClient.StartAccess(FCurSrvAddress,
        CListeningPort);
      Duplex.OnAnsiStringAction := OnAnsiStringClientRx;
      Duplex.OnDestroy := ClosingFormObject;
      Duplex.SynchronizeResults := true;
      RegStrg := 'Duplex No Hold' + FormatDateTime('nnsszzz', now);
      FSaveAllOldSessions.AddObject(RegStrg, Duplex);
      Duplex.ServerSetRefConnection(RegStrg);
      Duplex.ServerConnectionsNoWait(nil, '', NoWaitTCPReturn);
      // return always synchronised
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'AddOneDuplex');
    End;
  end;
{$IFNDEF  SuppressIPMetering}
{ sub } procedure AddAMeteringChannel;
  Var
    NoWaitRegStrg: string;
    NoWaiMeteredThread: TNoWaitReturnThread;
  begin
    Try
      NoWaiMeteredThread := TNoWaitReturnThread.Create(FCurSrvAddress,
        FCurSrvListeningPort, NoWaitClosing);
      NoWaitRegStrg := 'Metering' + FormatDateTime('nnsszzz', now);
      NoWaiMeteredThread.PermHold := true;
      FSaveAllOldSessions.AddObject(NoWaitRegStrg, NoWaiMeteredThread);
      NoWaiMeteredThread.ThreadTimeStampMetering := true;
      NoWaiMeteredThread.ServerConnectionsNoWait(nil, NoWaitRegStrg,
        NoWaitTCPReturn); // return always synchronised
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'AddASeries');
    End;
  end;
{$ENDIF}

begin
  try
    BusyStart;
    MmoStartTest('Test SetUp, Hold, Advertise and AutoClose');
    if FSaveAllOldSessions = nil then
      FSaveAllOldSessions := TStringList.Create;
    FSaveAllOldSessions.OwnsObjects := False;
    // Cannot own objects as some are NoWaitThreads
    // Not Sorted
{$IFNDEF  SuppressIPMetering}
    // AddAMeteringChannel;
{$ENDIF}
    AddASeries;
    // AddOneDuplex;
    BtnTestConnectAndRespond.Enabled := true;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BtnTestConnectAndRespondClick(Sender: TObject);
Var
  Clt: TISIndyTCPClient;
  Thrd: TNoWaitReturnThread;
  Msg, FwdRsp: AnsiString;
begin
  try
    BusyStart;
    MmoStartTest('Test Connect to Advertised and Confirm Data Connection');
    if FSaveAllOldSessions = nil then
      Exit;
    if FSaveAllOldSessions.count < 5 then
      Exit;

    Try
      if (FSaveAllOldSessions.Objects[4] is TISIndyTCPFullDuplexClient) and
        (Pos('Duplex Hold', FSaveAllOldSessions[4]) > 0) then
        FFwdTst := FSaveAllOldSessions.Objects[4] as TISIndyTCPFullDuplexClient
      else
        FFwdTst := nil;

      If FSendMessageback <> nil then
      begin
        MmoRexData.Lines.Add('Message Sent From FSendMessageback');
        MmoRexData.Lines.Add('');
        Application.ProcessMessages;
        Msg := #13#10'Direct NoWait Msg Bck from ' + FSendMessageback.TextID +
          FormatDateTime(' ddd hh:nn:ss.zzz)', now);
{$IFNDEF  SuppressIPMetering}
        AddSetMeteredTimeRecAsString(Msg, 'MsgBck');
{$ENDIF}
        FSendMessageback.FullDuplexDispatchNoWait(Msg, 5);

        if FFwdTst <> nil then
        begin
          FwdRsp := 'Message Sent From FFwdTst (' + FFwdTst.TextID +
            ' and Looped on Linked Chnl FSendMessageback' +
            FormatDateTime(' ddd hh:nn:ss.zzz', now);
{$IFNDEF  SuppressIPMetering}
          FFwdTst.TimeStampMetering := true;
          AddSetMeteredTimeRecAsString(FwdRsp, 'MsgFwd');
          // FFwdTst.TimeStampMetering := True Would Add Metering but with First record = MC ;
{$ENDIF}
          FFwdTst.FullDuplexDispatchNoWait(FwdRsp, 5);
        end;
      end
      else if FFwdTst <> nil then
      Begin
        MmoRexData.Lines.Add('Set Up Test Send Message Back');
        MmoRexData.Lines.Add('');
        FSendMessageback := TISIndyTCPFullDuplexClient.StartAccess
          (FCurSrvAddress, FCurSrvListeningPort, ClientConnectedReturn);
        FSendMessageback.OnDestroy := ClosingFormObject;
        FSendMessageback.OnAnsiStringAction := OnAnsiStringRxSendMsgBackClient;
        FSendMessageback.OnSimpleDuplexRemoteAction :=
          OnSimpleDuplexRxSendMsgBackClient;

        If FSendMessageback.ServerSetLinkConnection(FSaveAllOldSessions[4]) then
        begin
          Msg := 'Link to ' + FSaveAllOldSessions[4] + ' Connected From ' +
            FSendMessageback.TextID + FormatDateTime('  ddd hh:nn:ss)', now);
{$IFNDEF  SuppressIPMetering}
          AddSetMeteredTimeRecAsString(Msg, 'Linked');
{$ENDIF}
          FSendMessageback.FullDuplexDispatchNoWait(Msg, 5);

          // if FFwdTst <> nil then
          // FFwdTst.FullDuplexDispatchNoWait
          // ('Data From Session[4] to FSendMessageback' +
          // FormatDateTime('ddd hh:nn:ss.zz', now), 5);
        End
        else
          FreeAndNilDuplexChannel(Pointer(FSendMessageback));
      end;
    except
      On E: exception do
        ISIndyUtilsException(self, E, 'BtnTestConnectAndRespondClick One');
    End;
    Try
      MmoRexData.Lines.Add('');
      MmoRexData.Lines.Add('Test Client Reactivate');
      MmoRexData.Lines.Add('');
      Clt := nil;
      If FSaveAllOldSessions.count > 3 then
        if Pos('Client', FSaveAllOldSessions[1]) > 0 then
          if FSaveAllOldSessions.Objects[1] is TISIndyTCPClient then
          begin // test client still valid but disconnected
            Clt := TISIndyTCPClient(FSaveAllOldSessions.Objects[1]);
            if Clt.Active then
              FwdRsp := 'Active Connection ' + Clt.TextID
            else
            Begin
              FwdRsp := 'Non Active Connection was ' + Clt.TextID;
              Clt.Activate;
              sleep(500);
              FwdRsp := FwdRsp + ' Now ' + Clt.TextID;
            End;
            MmoRexData.Lines.Add(Clt.EchoFromServer(FwdRsp));
          end;
      MmoRexData.Lines.Add('');
      MmoRexData.Lines.Add('Test Thread Object Zero');
      MmoRexData.Lines.Add('');
      if FSaveAllOldSessions.Objects[0] is TNoWaitReturnThread then
      begin
        Thrd := TNoWaitReturnThread(FSaveAllOldSessions.Objects[0]);
        Thrd.ServerConnectionsNoWait(nil, '', NoWaitTCPReturn);
        FwdRsp := 'About to Delete Object Zero';
        Thrd.Terminate;
      end
      else
        FwdRsp := 'Object Zero is nil';
      if Clt <> nil then
        MmoRexData.Lines.Add(Clt.EchoFromServer(FwdRsp));
    except
      On E: exception do
        ISIndyUtilsException(self, E, 'BtnTestConnectAndRespondClick Two');
    End;

    BtnSendBackState.Enabled := FSendMessageback <> Nil;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.BusyEnd;
begin
  PnlBusy.Visible := False;
end;

procedure TServerForm.BusyStart;
begin
  PnlBusy.Visible := true;
  Application.ProcessMessages;
end;

procedure TServerForm.CheckExistingConnections;
{ Sub } Function ClearClient(AClt: TISIndyTCPFullDuplexClient): Boolean;
  Begin
    Result := true;
    if AClt = nil then
      Exit;
    if (AClt.Port <> FCurSrvListeningPort) or (AClt.Address <> FCurSrvAddress)
    then
      FreeAndNilDuplexChannel(AClt)
    else
      Result := False;
  end;
{ Sub } Procedure ResetThread(Var ATrd: TNoWaitReturnThread);
  Begin
    if ATrd = nil then
      Exit;
    ATrd.SetData(FCurSrvAddress, FCurSrvListeningPort);
  End;

begin
  if ClearClient(FRxVideoChnl) then
    FRxVideoChnl := Nil;
  if ClearClient(FSendVideoChnl) then
    FSendVideoChnl := Nil;
  if ClearClient(FSendMessageback) then
    FSendMessageback := Nil;
  ResetThread(FNoWaitCntrlChl);
end;

procedure TServerForm.ChkBxLoggingClick(Sender: TObject);
// Direct Set Logging Constants from CheckBoxes
begin
  cLogAll := ChkBxLogAll.Checked;
  GLogISIndyUtilsException := ChkBxLogAllEx.Checked;
  GblLogAllChlOpenClose := ChkBxLogCO.Checked;
  GlobalTCPLogAllData := ChkBxLogTD.Checked;
  GblLogPollActions := ChkBxLogPA.Checked;
  GblRptIsCommsConnectionAttempts := ChkBxLogCA.Checked;
  GblRptIsCommsCheckAutoChannels := ChkBxLogAC.Checked;
  GblRptRegConnectiononSrvr := ChkBxLogRc.Checked;
  GblRptMakeConnectionOnSrvr := ChkBxLogMC.Checked;
  GblRptTimeoutClear := ChkBxLogCl.Checked;
  if GLogISIndyUtilsException then
    // if ExceptLog<>nil then
    ISIndyUtilsException(self, '# CbxCng' + crlf + ReportLoggingStatus);
end;

procedure TServerForm.ClearOldSessions;
Var
  i: integer;
begin
  if IsNotMainThread then
    ISIndyUtilsException(self, 'ClearOldSessions must be Mainthread')
  Else
    Try
      Try
        FreeAndNil(FSendVideoChnl);
        FreeAndNil(FRxVideoChnl);
        // FreeAndNil(FCameraVideoChnl);
        FreeAndNil(FSendMessageback);
      Except
        On E: exception do
          ISIndyUtilsException(self, E, 'ClearOldSessions Part 1');
      End;
      if FSaveAllOldSessions <> nil then
        for i := 0 to FSaveAllOldSessions.count - 1 do
          Try
            // Cannot own objects as some are TNoWaitReturnThreads
            if FSaveAllOldSessions.Objects[i] <> nil then
              if FSaveAllOldSessions.Objects[i] is TNoWaitReturnThread then
                TNoWaitReturnThread(FSaveAllOldSessions.Objects[i]).Terminate
              else
                FSaveAllOldSessions.Objects[i].Free;
          except
            On E: exception do
              ISIndyUtilsException(self, E, 'ClearOldSessions Index=' +
                IntToStr(i));
          end;
      FreeAndNil(FSaveAllOldSessions);
    except
      On E: exception do
        ISIndyUtilsException(self, E, 'ClearOldSessions');
    end;
end;

procedure TServerForm.ClientConnectedReturn(Sender: TObject);
begin
  if FFormInDestroy then
    Exit;
  if Sender is TISIndyTCPClient then
    MmoInfo.Lines.Add('Connection Made ' + TISIndyTCPClient(Sender).TextID)
  Else
    MmoInfo.Lines.Add('UnExpected Call to ClientConnectedReturn');
end;

procedure TServerForm.ClosingFormObject(Sender: TObject);
Var
  i: integer;
begin
  Try
    if FSaveAllOldSessions <> nil then
    begin
      i := FSaveAllOldSessions.IndexOfObject(Sender);
      if i >= 0 then
        FSaveAllOldSessions.Objects[i] := nil;
    end;
    if Sender = FSendVideoChnl then
      FSendVideoChnl := nil;
    if Sender = FRxVideoChnl then
      FRxVideoChnl := nil;
    // if Sender = FCameraVideoChnl then
    // FCameraVideoChnl := nil;
    if Sender = FNoWaitCntrlChl then
      FNoWaitCntrlChl := nil;
    // if Sender = FSimpleClient then
    // FSimpleClient := nil;
    // if Sender = FDuplexClientAdvertised then
    // FDuplexClientAdvertised := nil;
    // if Sender = FDuplexClientLinked then
    // FDuplexClientLinked := nil;
    if Sender = FSendMessageback then
      FSendMessageback := nil

  except
    on E: exception do
      ISIndyUtilsException(self, E, 'ClosingFormObject');
  end;
end;

procedure TServerForm.CmbxExtnalServerSelExitEnter(Sender: TObject);
begin
  if Not FUseExternalServer then
    Exit;

  if Sender = CmbxExtnalServerSel then
    Try
      AlignCurServerToComboBox;
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'CmbxExtnalServerSelExitEnter');
    End;
end;

function TServerForm.CommsServer: TIsIndyApplicationServer;
begin
  Result := nil;
  if FFormInDestroy then
    Exit;
  If FCommsServer = nil then
  begin
    FCommsServer := TIsIndyApplicationServer.Create(nil);
    FCommsServer.OnSessionAnsiStringAction := OnAnsiStringRxPrimaryServer;
    FCommsServer.OnSessionStringAction := OnStringActionRX;
    FCommsServer.OnSessionSimpleRemoteAction := OnSimpleActionRxOnServer;
    Caption := 'Server On ' + GetThisHostIPAddressViaIndy;
  end;
  Result := FCommsServer;
end;

procedure TServerForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var
  Stats: String;
begin
  try
    BusyStart;
    Stats := TSingletonObjTimeSpanRecording.SingletonLifeTimeStats;

    ISIndyUtilsException(self, #13#10'FormCloseQuery#'#13#10);
    ISIndyUtilsException(self, Stats);
    ISIndyUtilsException(self, 'FormCloseQuery#'#13#10);
    sleep(1000);
    FreeAllResourcesBeforeClose;
{$IFDEF TestFastMM}
    TObject.Create;
{$ENDIF}
    CanClose := true;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.FormCreate(Sender: TObject);
Var
  IniFile: TIniFile;
  BaseDir: String;
  LogPurge: TLogFile;
begin
  FCurSrvAddress := 'LocalHost';
  FCurSrvListeningPort := CListeningPort;
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

{$IFNDEF  SuppressIPMetering}
  LblEdtMeteredSleep.Text := IntToStr(gblMeterSleep);
{$ELSE}
  LblEdtMeteredSleep.Text := 'No gblMeterSleep';
{$ENDIF}
  OpenAppLogging(true, '', GblLogAllChlOpenClose, GlobalTCPLogAllData,
    GblLogPollActions, GblRptRegConnectiononSrvr,
    GblRptIsCommsConnectionAttempts);
  { Procedure OpenAppLogging(AStartNewLogFile:Boolean; ALogFileName: String = '';
    ARptTcpOpenClose: Boolean = false;
    ARptTcpData: Boolean = false;
    ARptCommsPoll: Boolean = false;
    ARptAutoChannels: Boolean = false;
    ARptCommsConAttempts: Boolean = false);
    cLogAll := ChkBxLogAll.Checked;
    GLogISIndyUtilsException := ChkBxLogAllEx.Checked;
    GblLogAllChlOpenClose := ChkBxLogCO.Checked;
    GlobalTCPLogAllData := ChkBxLogTD.Checked;
    GblLogPollActions := ChkBxLogPA.Checked;
    GblRptIsCommsConnectionAttempts := ChkBxLogCA.Checked;
    GblRptIsCommsCheckAutoChannels := ChkBxLogAC.Checked;
    GblRptRegConnectiononSrvr := ChkBxLogRc.Checked;
    GblRptMakeConnectionOnSrvr := ChkBxLogMC.Checked;
    GblRptSrvrTimeoutClear := ChkBxLogCl.Checked;
  }
  ChkBxLoggingClick(nil); // Direct Set Logging
  // GblLogAllChlOpenClose := True;
  TGblRptComs.ReportObjectTypes; // Start Counting

  MmoInfo.Clear;
  if Not FileExists(IniFileNameFromExe) then
    Try
      BaseDir := ExtractFileDir(IniFileNameFromExe) + '\Data';
      IniFile := TIniFile.Create(IniFileNameFromExe);
      try // Create Ini File For Server Code
        IniFile.WriteString('Files', 'FileAccessBase', BaseDir);
        IniFile.WriteInteger('TCP', 'PORT', CListeningPort);
      finally
        IniFile.Free;
      end;
    Except
      On E: exception do
        raise exception.Create('Failed to find/create inifile ' +
          IniFileNameFromExe + ' Error=' + E.Message);
    End;
  Try
    if FCommsServer = nil then
    begin
      if ValidPort('LocalHost', CListeningPort) then
        Caption := 'External Server On Localhost:' + IntToStr(CListeningPort)
        // Code will excerise External Server Commserver not required
      Else
        CommsServer;
    end;
    if FCommsServer <> nil then
    begin
      if FCommsServer.DefaultPort < 1 then
        FCommsServer.DefaultPort := CListeningPort;
      FCommsServer.Active := true;
    end;
    if Not FileExists(TestFileName) then
      CreateTestFile;
    ISIndyUtilsException(self, ' # ' + crlf + ReportLoggingStatus);
  Except
    On E: exception do
      raise exception.Create('Failed to Start Commsserver:: Error=' +
        E.Message);
  End;
end;

procedure TServerForm.FormDestroy(Sender: TObject);
begin
  Try
    if not FFormInDestroy then
      FreeAllResourcesBeforeClose;
    // Should already happened in close query so
    // Form exists until resources are cleared
  finally
    TSingletonObjTimeSpanRecording.ReleaseSingletonTimeStats;
  End;
end;

procedure TServerForm.FreeAllResourcesBeforeClose;
var
  LogAfterFinalize: TLogFile;
begin
  Try
    Try
      FFormInDestroy := true;
      FreeAndNil(FSendMessageback);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(FSendMessageback)');
      FreeAndNil(fKnownServers);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(fKnownServers)');
      ClearOldSessions;
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # ClearOldSessions');
      if FNoWaitCntrlChl <> nil then
        FNoWaitCntrlChl.Terminate;
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose #  FNoWaitCntrlChl.Terminate');
      FreeAndNil(FImageManager); // Release calls before server
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # Nil(FImageManager)');
      sleep(1000); // allow time to process no wait rtn terminate
      ISIndyUtilsException(self, 'sleep(1000);');
      // Application.ProcessMessages; // before closing server
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(FWaitSync)');
      FreeAndNil(FWaitSync);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(FWaitSync)');
      FreeAndNil(FTestServer);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose #  FreeAndNil(FTestServer)');
      FreeAndNil(FCommsServer);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(FCommsServer)');
      FreeAndNil(FSecondaryComsServer);
      ISIndyUtilsException(self,
        'FreeAllResourcesBeforeClose # FreeAndNil(FSecondaryComsServer)');
      GblIndyComsObjectFinalize; // Bring Forward Fo Fast MM
    Except
      On E: exception do
        ISIndyUtilsException(self, E, '#FreeAllResourcesBeforeClose Frees')
    End;
    LogAfterFinalize := TLogFile.Create(ExceptionLogName, true, 5000000,
      true, False);
    try
      LogAfterFinalize.LogALine
        (#13#10#13#10'#VCL Form FreeAllResourcesBeforeClose#'#13#10 +
        TSingletonObjTimeSpanRecording.SingletonLifeTimeStats);
      LogAfterFinalize.LogALine('#VCL Form FreeAllResourcesBeforeClose End#');
    finally
      FreeAndNil(LogAfterFinalize);
    end;
  except
    On E: exception do
      try
        if LogAfterFinalize = nil then
          LogAfterFinalize := TLogFile.Create(ExceptionLogName, true, 5000000,
            true, False);
        if LogAfterFinalize <> nil then
        Begin
          LogAfterFinalize := TLogFile.Create(ExceptionLogName, true, 5000000,
            true, False);
          LogAfterFinalize.LogALine
            (#13#10#13#10'VCL Form Destroy Exception#'#13#10 + E.Message);
        End;
        TSingletonObjTimeSpanRecording.ReleaseSingletonTimeStats;
      finally
        LogAfterFinalize.Free;
      end;
  end;
end;

procedure TServerForm.HandleInComingGraphicOnVideoRx(AGraphic: TGraphic);
Var
  ImgRx: TImageControl;
begin
  if ImageManager = nil then
    ISIndyUtilsException(self,
      'HandleInComingGraphicOnVideoRx#>>No Image manager Created');
  if FImageManager = nil then
    Exit;
  ImgRx := FImageManager.ImageControl(0); // Fixed Images = 1
  // ImgRx.Stretch := True;
  // ImgRx.Proportional := True;
  // FImageSetUp := True;
  if AGraphic <> nil then
    ImgRx.Picture.Graphic := AGraphic;
end;

function TServerForm.ImageManager: TImageMngrVCL;
begin
  if FFormInDestroy then
  begin
    Result := nil;
    Exit;
  end;
  If FImageManager = nil then
  begin
    FImageManager := TImageMngrVCL.Create(PnlRxImage, 1);
  end;
  Result := FImageManager;
end;

procedure TServerForm.LblEdtMeteredSleepChange(Sender: TObject);
begin
{$IFNDEF  SuppressIPMetering}
  gblMeterSleep := StrToIntDef(LblEdtMeteredSleep.Text, -1);
  if gblMeterSleep < 0 then
    gblMeterSleep := 1
  Else
    LblEdtMeteredSleep.Text := IntToStr(gblMeterSleep);
{$ELSE}
  LblEdtMeteredSleep.Text := 'SuppressIPMetering is active';
{$ENDIF}
end;

procedure TServerForm.LinkAnyDefaultCamerasLaunch;
begin
  try
    if FNoWaitCntrlChl = nil then
    Begin
      FNoWaitCntrlChl := TNoWaitReturnThread.Create(FCurSrvAddress,
        FCurSrvListeningPort, nil);
      FNoWaitCntrlChl.OnTerminate := ClosingFormObject;
      // FNoWaitCntrlChl always Sync Results;
    end;
    FNoWaitCntrlChl.ServerConnectionsNoWait(MmoRegistrations.Lines, '',
      OnLinkAnyDefaultCameras);
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'LinkAnyDefaultCamerasLaunch');
  End;

end;

procedure TServerForm.LoadIniDetails;
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
    fKnownServers.OwnsObjects := true;
    fKnownServers.CaseSensitive := False;
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
    fKnownServers.Add('scripts.innovasolutions.com.au:1559'); // PORT=1559
    fKnownServers.Add('192.168.1.92:1559');
    fKnownServers.Add('192.168.1.95:1559');
    fKnownServers.Add('192.168.1.94:1559');
    SaveIniDetails;
  end;
end;

procedure TServerForm.MmoStartTest(AMsg: string);
begin
  if FFormInDestroy then
    Exit;
  MmoInfo.Clear;
  MmoRexData.Clear;
  MmoInfo.Lines.Add(AMsg);
  MmoRexData.Lines.Add(AMsg);
  MmoInfo.Lines.Add('');
  MmoRexData.Lines.Add('');
  Application.ProcessMessages;
end;

procedure TServerForm.NoWaitClosing(Sender: TObject);
begin
  ClosingFormObject(Sender);
  MmoInfo.Lines.Add('NoWaitClosing ');
end;

procedure TServerForm.NoWaitTCPReturn(ARtn: TISIndyTCPClient);
Var
  Data, MeteringData: AnsiString;
begin // return always synchronised
  if ARtn = nil then
    Exit;

  Data := ARtn.LastNwRtnData;
{$IFNDEF  SuppressIPMetering}
  If SplitMeteredData(Data, MeteringData) then
  Begin
    MeteringData := MeteringData + AddMeteredTimeRecAsString('NWRTN');
    MmoRexData.Lines.Add(#13#10'Metering for ' + ARtn.TextID);
    if not StringsFrmMeteredData(MmoRexData.Lines, MeteringData) then
      ISIndyUtilsException(self, 'Time Metered Fail NoWaitTCPReturn')
  End;
{$ENDIF}
  if Pos('Listening on Port', ARtn.LastNwRtnData) > 0 then
  Begin
    MmoRexData.Lines.Add('');
    MmoRexData.Lines.Add(ARtn.LastNwRtnData);
  End;

end;

function TServerForm.OnAnsiStringClientRx(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
{$IFNDEF  SuppressIPMetering}
Var
  MeteringData: AnsiString;
{$ENDIF}
begin
{$IFNDEF  SuppressIPMetering}
  If SplitMeteredData(ACommand, MeteringData) then
  Begin
    MeteringData := MeteringData + AddMeteredTimeRecAsString('NWRTN');
    MmoRexData.Lines.Add(#13#10'Metering for ' + ATcpSession.TextID);
    if not StringsFrmMeteredData(MmoRexData.Lines, MeteringData) then
      ISIndyUtilsException(self, 'Time Metered Fail OnAnsiStringClientRx')
  End;
{$ENDIF}
  MmoRexData.Lines.Add(ACommand);
  Result := '';
end;

function TServerForm.OnAnsiStringSecondaryRx(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
// Server side on Secondary Server used for Follow On
{$IFNDEF  SuppressIPMetering}
Var
  MeteringData: AnsiString;
{$ENDIF}
begin
  if FFormInDestroy then
    Exit;
{$IFNDEF  SuppressIPMetering}
  If SplitMeteredData(ACommand, MeteringData) then
  Begin
    MeteringData := MeteringData + AddMeteredTimeRecAsString('SecRx');
    ACommand := ACommand + MeteringData;
  End;
{$ENDIF}
  Result := 'Returned From Secondary Follow on Server ' + ATcpSession.TextID +
    crlf + ACommand;
end;

procedure TServerForm.OnFwrdTstRtn(ATcpSession: TISIndyTCPClient);
// Comes From No Wait Ansi String so Synchronised
Var
  Data: AnsiString;
{$IFNDEF  SuppressIPMetering}
  MeteringData: AnsiString;
{$ENDIF}
begin
  try
    BusyStart;
    if ATcpSession = nil then
      Exit;

    If FFwdTst <> ATcpSession then
      ISIndyUtilsException(self, 'FFwdTst <> ATcpSession')
    else if FFwdTst.LastNwRtnData <> '' then
    begin
      MmoRexData.Lines.Add('OnFwrdTstRtn');
      Data := FFwdTst.LastNwRtnData;
{$IFNDEF  SuppressIPMetering}
      If SplitMeteredData(Data, MeteringData) then
      Begin
        MmoRexData.Lines.Add(Data);
        MmoRexData.Lines.Add(#13#10'Metering for ' + FFwdTst.TextID);
        if not StringsFrmMeteredData(MmoRexData.Lines, MeteringData) then
          ISIndyUtilsException(self, 'Time Metered Fail OnFwrdTstRtn')
      End
      else
        MmoRexData.Lines.Add(Data);
{$ELSE}
      MmoRexData.Lines.Add(Data);
{$ENDIF}
    end;
  finally
    BusyEnd;
  end;
end;

procedure TServerForm.OnLinkAnyDefaultCameras(ATcp: TISIndyTCPClient);
Var
  // LinkObj: TVideoChnlLinkVCL;
  S: string;
  Idx: integer;
  i: integer;
begin
  try
    if IsNotMainThread then
      ISIndyUtilsException(self, 'OnLinkAnyDefaultCameras not synced')
    else
      for Idx := 0 to MmoRegistrations.Lines.count - 1 do
      begin
        S := MmoRegistrations.Lines[Idx];
        i := Pos('|Free', S);
        if i > 4 then
        begin
          SetLength(S, i - 1);
          i := Pos(CCameraLink, S);
          if i > 0 then
            // LinkObj :=
            ImageManager.ConnectChannel(S, FCurSrvAddress,
              FCurSrvListeningPort);
        end;
      end;
  Except
    On E: exception do
      ISIndyUtilsException(self, E, 'OnLinkAnyDefaultCameras');
  end;
end;

function TServerForm.OnAnsiStringRxPrimaryServer(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
begin
  if FFormInDestroy then
    Exit;
  Result := ACommand;
  if Length(ACommand) > cMaxDataChunk then
    Exit;

  if ACommand = '' then
    Exit;
  { Incoming data from TCP sessions act in their own thread unless"SynchronizeResults is set.
    Without"SynchronizeResults thread safety requires interactions to be managed. }

  WaitSync.Acquire;
  Try
    FRxText := FRxText + FormatDateTime('hh:nn:ss ', now) + ATcpSession.TextID +
      ' OnAnsiStringRx::' + ACommand + crlf;
  Finally
    FWaitSync.Release;
  End;
  Result := ATcpSession.TextID;
end;

function TServerForm.OnAnsiStringRxSendMsgBackClient(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
Var
  RtnMessage: AnsiString;
{$IFNDEF  SuppressIPMetering}
  MeteringData: AnsiString;
{$ENDIF}
begin
  if FFormInDestroy then
    Exit;
  Result := ''; // This code does response
  if ACommand = '' then
    Exit; // was a poll

{$IFNDEF  SuppressIPMetering}
  If SplitMeteredData(ACommand, MeteringData) then
  Begin
    MeteringData := MeteringData + AddMeteredTimeRecAsString('RxSdBk');
    if ACommand = '' then
      Exit; // was a poll
    ACommand := ACommand + MeteringData;
  End;
{$ENDIF}
  if ATcpSession = nil then
    ISIndyUtilsException(self,
      'No Session in OnAnsiStringRxSendMsgBackClient :: ' + ACommand)
  Else if ATcpSession = FSendMessageback then
  begin
    if FSendMessageback.SynchronizeResults then
      ISIndyUtilsException(self,
        'FSendMessageback.SynchronizeResults not required');
    // The following is threadsafe????
    RtnMessage := 'FSendMessageback::' + FormatDateTime('ddd hh:nn:ss.zzz ',
      now) + ATcpSession.TextID + '::' + #13#10 + ACommand;
    FSendMessageback.AnsiTransaction(RtnMessage);
  end
  else
    Result := ACommand;
end;

function TServerForm.OnSimpleActionRxOnServer(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
begin
  if FFormInDestroy then
    Exit;

  { Incoming data from TCP sessions act in their own thread unless"SynchronizeResults is set.
    Without"SynchronizeResults thread safety requires interactions to be managed. }

  WaitSync.Acquire;
  Try
    FRxText := FRxText + FormatDateTime('hh:nn:ss ', now) + ATcpSession.TextID +
      ' OnSimpleActionRx::' + ACommand + crlf;
  Finally
    FWaitSync.Release;
  End;
  Result := FRxText;
end;

function TServerForm.OnSimpleDuplexRxSendMsgBackClient(ACommand: AnsiString;
  ATcpSession: TISIndyTCPBase): AnsiString;
Var
  RtnMessage: AnsiString;
{$IFNDEF  SuppressIPMetering}
  MeteringData: AnsiString;
{$ENDIF}
begin
  Result := ''; // This code does response
  if ACommand = '' then
    Exit; // was a poll

{$IFNDEF  SuppressIPMetering}
  If SplitMeteredData(ACommand, MeteringData) then
  Begin
    if ACommand = '' then
      Exit; // is Poll
    ACommand := ACommand + MeteringData + AddMeteredTimeRecAsString('LoopBk');
  End;
{$ELSE}
  MmoRexData.Lines.Add(ACommand);
{$ENDIF}
  if ATcpSession = nil then
    ISIndyUtilsException(self,
      'No Session in OnAnsiStringRxSendMsgBackClient :: ' + ACommand)
  Else if ATcpSession = FSendMessageback then
  begin
    if FSendMessageback.SynchronizeResults then
      ISIndyUtilsException(self,
        'FSendMessageback.SynchronizeResults not required');
    // The following is threadsafe????
    RtnMessage := #13#10'Looped at FSendMessageback::' + ATcpSession.TextID +
      '::' + FormatDateTime('ddd hh:nn:ss.zzz ', now) + #13#10'Rxed Cmd='
      + ACommand;
    if ACommand <> '' then
      FSendMessageback.FullDuplexDispatchNoWait(RtnMessage, 5);
  end
  else
    Result := ACommand;
end;

function TServerForm.OnStringActionRX(AData: String;
  ATcpSession: TISIndyTCPBase): String;
begin
  if FFormInDestroy then
    Exit;

  { Incoming data from TCP sessions act in their own thread unless"SynchronizeResults is set.
    Without"SynchronizeResults thread safety requires interactions to be managed. }

  WaitSync.Acquire;
  Try
    FRxText := FRxText + FormatDateTime('hh:nn:ss ', now) + ATcpSession.TextID +
      ' OnStringActionRX::' + AData + crlf;
  Finally
    FWaitSync.Release;
  End;
  Result := FRxText;
end;

procedure TServerForm.SaveIniDetails;
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

procedure TServerForm.SendMockCameraImage(AConnectObj: TObject);
Var
  LocalCopy: TVideoComsChannel;
  PkData: AnsiString;
begin
  LocalCopy := nil;
  if AConnectObj is TVideoComsChannel then // Session is connected
    LocalCopy := TVideoComsChannel(AConnectObj)
  Else if AConnectObj <> nil then
    Raise exception.Create('AConnectObj not nil in SendMockCameraImage');

  if LocalCopy <> nil then
  begin
    if FSendVideoChnl <> nil then
      if FSendVideoChnl <> LocalCopy then
        raise exception.Create
          ('AConnectObj not same as FSendVideoChnl in SetUpMockCameraLink');
    if not Assigned(LocalCopy.OnDestroy) then
    Begin
      LocalCopy.OnInComingGraphic := HandleInComingGraphicOnVideoRx;
      LocalCopy.SynchronizeResults := true;
      LocalCopy.OnDestroy := ClosingFormObject;
    End;

    if FSendVideoChnl <> nil then
    begin
      PkData := TVideoComsChannel.PackGraphic(ImgSend.Picture.Graphic);
      FSendVideoChnl.FullDuplexDispatch(PkData, '');
    end;
  end;
end;

procedure TServerForm.SetupVideoPathAndAdvertise(AConnectObj: TObject);
// Call with nil create session
// On Connection call should have session Channel as AConnectObj
// but FSendVideoChnl := TVideoComsChannel.StartAccess will not have returned
Var
  LocalCopy: TVideoComsChannel;
  Rslt: TStringList;
begin
  LocalCopy := nil;
  if AConnectObj is TVideoComsChannel then // Session is connected
    LocalCopy := TVideoComsChannel(AConnectObj)
  Else if AConnectObj <> nil then
    Raise exception.Create('AConnectObj not nil in SetupVideoPathAndAdvertise')
  else
  Begin
    if FSendVideoChnl = nil then
      FSendVideoChnl := TVideoComsChannel.StartAccess(FCurSrvAddress,
        FCurSrvListeningPort, SetupVideoPathAndAdvertise);

    Rslt := TStringList.Create;
    try
      FSendVideoChnl.ServerConnections(Rslt, '');
      if Pos(cVideoChlId, Rslt.Text) < 1 then
        Raise exception.Create('VideoChannel not Registered');
    finally
      Rslt.Free;
    end;
  End;
  if LocalCopy = nil then
    Exit;

  if (FSendVideoChnl <> nil) Then
    if (FSendVideoChnl <> LocalCopy) then
      Raise exception.Create('Invalid Connection SetupVideoPathAndAdvertise');

  if (FSendVideoChnl <> nil) Then
    if Not Assigned(FSendVideoChnl.OnAnsiStringAction) then
    begin
      FSendVideoChnl.OnAnsiStringAction := OnAnsiStringClientRx;
      ISIndyUtilsException(self, 'Assigning FSendVideoChnl.OnAnsiStringAction')
    end;

  LocalCopy.PermHold := true;
  LocalCopy.OnDestroy := ClosingFormObject;
  If not LocalCopy.ServerSetRefConnection(cVideoChlId) then
    Raise exception.Create(cVideoChlId + ' not Registered');
end;

procedure TServerForm.SetupVideoRxForStaticImage(AConnectObj: TObject);
Var
  LocalCopy: TVideoComsChannel;
begin
  LocalCopy := nil;
  if AConnectObj is TVideoComsChannel then // Session is connected
    LocalCopy := TVideoComsChannel(AConnectObj)
  Else if AConnectObj <> nil then
    Raise exception.Create('AConnectObj not nil in SetupVideoRxForStaticImage');

  if LocalCopy = nil then
    FRxVideoChnl := TVideoComsChannel.StartAccess(FCurSrvAddress,
      FCurSrvListeningPort, SetupVideoRxForStaticImage);
  // FRxVideoChnl will remain nil until StartAccess returns after 2nd entry to SetupVideoRxForStaticImage

  if LocalCopy <> nil then
  begin
    if FRxVideoChnl <> nil then
      if FRxVideoChnl <> LocalCopy then
        raise exception.Create
          ('AConnectObj not same as FRxVideoChnl in SetupVideoRxForStaticImage');
    if Not Assigned(LocalCopy.OnDestroy) then
    begin
      LocalCopy.OnInComingGraphic := HandleInComingGraphicOnVideoRx;
      LocalCopy.SynchronizeResults := true;
      LocalCopy.OnDestroy := ClosingFormObject;
      LocalCopy.OnAnsiStringAction := OnAnsiStringClientRx;
    end;
    LocalCopy.ServerSetLinkConnection(cVideoChlId);
  end
end;

procedure TServerForm.ShowLogFile;
// Procedure ShowLogFile; // Puts Logfile in Memo
Var
  Log: TFileStream;
  S: AnsiString;
  Sz: Int64;
begin
  if FFormInDestroy then
    Exit;
  MmoRexData.Clear;
  Application.ProcessMessages;
  if FileExists(ExceptionLogName) then
    try
      Log := TFileStream.Create(ExceptionLogName, fmOpenRead, fmShareDenyNone);
      try
        Sz := Log.Size;
        SetLength(S, Sz);
        Log.Read(S[1], Sz);
        MmoRexData.Text := 'Log File Data' + crlf + S;
      finally
        Log.Free;
      end;
    Except
      On E: exception do
        ISIndyUtilsException(self, E, 'Log File Read Fail');
    end;
  if ExceptLog <> nil then
    ExceptLog.RollAndFlagNewApplication(true);
end;

procedure TServerForm.TimerCleanupTimer(Sender: TObject);
begin
  TimerCleanup.Enabled := False;
  Try
    Try
      if FFormInDestroy then
        Exit;

      LinkAnyDefaultCamerasLaunch;
      if FSendVideoChnl <> nil then
        SendMockCameraImage(FSendVideoChnl);

      if FImageManager <> nil then
      begin
        FImageManager.BlankInactiveImageChannels(1);
        FImageManager.DisConnectInactiveImageChannels(2);
      end;

      if GblLogPollActions then
        If FNextCleanupTimer < now then
        Begin
          FNextCleanupTimer := now + 1 / 24 / 12;
          ISIndyUtilsException(self, '#TimerCleanupTimer');
        End;

      if FRxText <> '' then
      Begin
        MmoInfo.Lines.Add('');
        MmoInfo.Lines.Add('Server Side RX Data');

        { Incoming data from TCP sessions act in their own thread unless"SynchronizeResults is set.
          Without"SynchronizeResults thread safety requires interactions to be managed. }

        WaitSync.Acquire;
        Try
          MmoInfo.Lines.Add(FRxText);
          FRxText := '';
        Finally
          FWaitSync.Release;
        End;
        MmoInfo.Lines.Add('End Server Side RX Data');
      End;
    Except
{$IFDEF MSWindows}
      On E: exception do
        OutputDebugString(PChar('LogFile Exception::' + E.Message));
{$ENDIF}
    End;
  Finally
    TimerCleanup.Enabled := true;
  End;
end;

procedure TServerForm.TimerStatusTimer(Sender: TObject);
begin
  TimerStatus.Enabled := False;
  Try
    Try
      if FFormInDestroy then
        Exit;
      MmoInfo.Lines.Add('');
      MmoInfo.Lines.Add('');
      MmoInfo.Lines.Add('');
      MmoInfo.Lines.Add('Report at ' + FormatDateTime('hh:nn', now));
      if FTestServer <> nil then
        MmoInfo.Lines.Add(crlf + 'Test Last Status=' +
          FormatDateTime('ddd hh.nn', FTestServer.LastStatus) + crlf + crlf);

      if FCommsServer <> nil then
      begin
        MmoInfo.Lines.Add(crlf + 'Direct From Server Side');
        MmoInfo.Lines.Add(FCommsServer.ServerDetailsAsText);
        MmoInfo.Lines.Add(crlf + 'Log Messages>>');
        MmoInfo.Lines.Add(FCommsServer.ReadLogMessage);
        MmoInfo.Lines.Add('End Log Messages>>');
      end;

      MmoInfo.Lines.Add('');
      MmoInfo.Lines.Add('Comms Objects');
      MmoInfo.Lines.Add(TGblRptComs.ReportObjectTypes);

      If FNextStatusTimer < now then
      Begin
        FNextStatusTimer := now + 1 / 24 / 4;
        ISIndyUtilsException(self, 'TimerStatusTimer # ::' +
          FormatDateTime('dd mmmm hh:nn:ss.zzz', now));
      End;
      if FRxText <> '' then
      Begin
        MmoInfo.Lines.Add('');
        MmoInfo.Lines.Add('Server Side RX Data');

        { Incoming data from TCP sessions act in their own thread unless"SynchronizeResults is set.
          Without"SynchronizeResults thread safety requires interactions to be managed. }

        WaitSync.Acquire;
        Try
          MmoInfo.Lines.Add(FRxText);
          FRxText := '';
        Finally
          FWaitSync.Release;
        End;
        MmoInfo.Lines.Add('End Server Side RX Data');
      End;
    Except
{$IFDEF MSWindows}
      On E: exception do
        OutputDebugString(PChar('LogFile Exception::' + E.Message));
{$ENDIF}
    End;
  Finally
    TimerStatus.Enabled := true;
  End;
end;

function TServerForm.WaitSync: TCriticalSection;
begin
  Result := Nil;
  if FFormInDestroy then
    Exit;
  if FWaitSync = nil then
    FWaitSync := TCriticalSection.Create;
  Result := FWaitSync;
end;

end.
