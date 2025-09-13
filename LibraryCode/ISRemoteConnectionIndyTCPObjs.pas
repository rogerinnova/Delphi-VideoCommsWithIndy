{$IFDEF FPC}
{$MODE Delphi}
{$I InnovaLibDefsLaz.inc}
{$H+}
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}
unit ISRemoteConnectionIndyTCPObjs;

{ About Indy
  http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=index.html

  IDGlobals Useful Functions

  TIdInitializerComponent
  TIdBaseComponent   property                         property                  TCollectionItem on TIdSocketHandles
  TIdComponent
  TIdTCPConnection  IOHandler   TIdIOHandler        FInputBuffer  TIdBuffer;          \/
  Socket    TIdIOHandlerSocket      Binding                   TIdSocketHandle
  TIdIOHandlerStack
  TIdTCPClientCustom
  TIdTCPClient


  Connection  TIdIOHandler   TIdBuffer
  FIdTCPCon.IOHandler.
  Socket  is
  TIdIOHandlerSocket
  TIdIOHandlerStack is a TIdIOHandlerSocket descendant that
  implements the Indy IOHandler framework using a socket handle
  to access TCP/IP protocol stack.
  Binding is
  TIdSocketHandle Ip Address and ports  in a collection TIdSocketHandles


  TIdSocketHandle.Receive (Public)  calls  GStack.Receive(Handle, VBuffer);
  GStack Implements  platform stack

  initialization
  TIdIOHandlerStack.SetDefaultClass; will RegisterIOHandler


  procedure TIdTCPConnection.CreateIOHandler(ABaseType:TIdIOHandlerClass=nil);
  begin
  if Connected then begin
  EIdException.Toss(RSIOHandlerCannotChange);
  end;
  if Assigned(ABaseType) then begin
  IOHandler := TIdIOHandler.MakeIOHandler(ABaseType, Self);
  end else begin
  IOHandler := TIdIOHandler.MakeDefaultIOHandler(Self);
  end;
  ManagedIOHandler := True;
  end;


}

interface

uses
  // ISStrUtl,
{$IFDEF MSWINDOWS}
  WinApi.Windows,
{$ENDIF}
{$IFDEF FPC}
  SysUtils, {IOUtils,} Classes,
  // UITypes,
  SyncObjs, IdGlobal, IDStack,
  IsLazarusPickup,
{$ELSE}
  System.SysUtils, System.IOUtils, System.Classes, System.UITypes,
  System.SyncObjs,
  IdGlobal, IDStack,
{$ENDIF}
  IDIOHandlerSocket, IdException,
  IdSocketHandle, IdIntercept, IdIOHandler,
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
  ISIndyUtils, IdBaseComponent, IdComponent, IdAntiFreezeBase,
  IdTCPConnection, IdTCPClient;

Var
  GlobalThreadCount: integer;

Type
  TArrayOfByte = array of Byte;
  TISIndyTCPBase = class;

  TTCPTransactionTypes = ( { GetInxFl, PutInxFl, GetClsIdx, GetLkFl, GetRegObj,
      GetTotalObj, LkUkInxRc, PopObj, PutObj, RegObj, RfshSupInx, DelObj, }
    NewCon, { PartTrnData, } FlgError, FlgNull, MvString, MvRawStrm, SmpAct,
    EchoTrans, FullDuplexMode, RdFileTrfBlk, PtFileTrfBlk, LogServerData);

  TTxnSzRecord = record
{$IFDEF FPC}
{$ELSE}
    Function AsString: ansistring;
    Procedure FrmChar(aa, ab, ac, ad: AnsiChar);
    Procedure FrmString(aString: ansistring; AOffset: integer = 0);
    // Offset 1 starts on second Char
{$ENDIF}
    case integer of
      0:
        (Sz: UInt32;);
      1:
        (a, b, c, d: Byte;);
      2:
        (low, high: Word;);
  end;

  TISIndyTCPEvent = Procedure(ASender: TObject) of Object;
  TISIndyLogEvent = Procedure(AId, AMsg: string) of Object;
  TComandActionAnsi = Function(ACommand: ansistring;
    ATcpSession: TISIndyTCPBase): ansistring of Object;

  TIsTrackIdTCPClientConnection = Class(TIdTCPClient)
  Public
    FOwnerTCPBase: TISIndyTCPBase;
    Constructor Create;
    Destructor Destroy; override;
    Class Function CurrentConnections: integer;
  End;

  TIsMsgBuffer = class(TObject)
    { Use buffer between messages from communication objects and writing to
      Form objects such as Memos
      Form.OnIdle;
      If MsgBuf.MsgToRead(Txt) then
      MmoLogs.Add(Txt }
  Private
    FListLock: TCriticalSection;
    FData: TStringlist;
  public
    Constructor Create;
    Destructor Destroy; override;
    Procedure AddBuffMsgStr(AMsg: String);
    Procedure AddBuffMsgAnsi(AMsg: ansistring);
    Procedure AddBuffLogMsg(AId, AMsg: String);
    Function MsgToRead(out AMsg: String; AReadLines: integer = 0): boolean;
  end;

  TISIndyTCPBase = Class(TObject)
  Private
    FIOHandler: TIdIOHandler;
    fPeerPort, FPort: TIdPort;
    fPeerIP, FIP: String;
    fMaxTcpBuffRead: integer;
    FClosedForcfullyOrGracefully: boolean;
    FFileAccessBasePath: String;
    FFullDupLogList, FLogList: TStringlist;
    FLoggingListLock: TCriticalSection; // For async Log messages
    FLogsMissed: integer;
    FLastData: ansistring;
    FConnectionCounted: boolean;
    procedure SyncDuplxAction;
    Procedure RefreshBindingDetails;
    procedure SetAddress(const Value: String); Virtual;
    procedure SetPort(const Value: TIdPort); Virtual;
    procedure SetFileAccessBasePath(const Value: String);
    function GetLocalPort: TIdPort;
  Protected
    FLastWriteBusyDate, FLastReadBusyDate: TDateTime;
    FDecWriteCount, FDecReadCount: integer;
    FConnection: TIdTCPConnection;
    FNextTransactionData: ansistring;
    FReadDataWaitDiv5: integer;
    FLastLoggedTimeStampError, FLastDuplexTime, FLastIncoming: TDateTime;
    FCloseOnTimeOut, fFullDuplex: boolean;
    // False except for TISIndyTCPFullDuplexClient
    FRandomKey: ansistring;
    FOnAnsiStringAction: TComandActionAnsi;
    FClosingTcpSocket, // Disable Synchronize
    FSynchronizeResults: boolean;
    FOnDestroy: TISIndyTCPEvent;
    Procedure SyncReturn(AMeathod: TThreadMethod);
    function GetIPRemote: String; Virtual;
    function GetPort: TIdPort; Virtual;
    function FillBufferWithLeftOver(Var ABuffer: TIdBytes): integer;
    function ReadATransactionRecord(var ATrnctType: TTCPTransactionTypes;
      var AKey: ansistring): ansistring; Virtual;
    function DoFullDuplexIncomingAction(AData: ansistring): boolean; Virtual;
    function RecoverTrnsString(AData: ansistring): String;
    Procedure SetConnection(AConnection: TIdTCPConnection);
    procedure WasClosedForcfullyOrGracefully; Virtual;
    function CheckConnection: boolean; Virtual;
    procedure SendTransaction(AData: ansistring;
      out ATrnctType: TTCPTransactionTypes;
      out AKey, ANewData: ansistring); virtual;
    // Blocking transaction On full Duplex Session will Wait until readThread Releases
    function Write(AData: RawByteString): integer; Virtual;
    function ReadOneTransaction(var ABuffer: TIdBytes;
      AClientWaitDiv5: integer): integer;
    function WaitForData(AWaitTime: integer): boolean;
    function GetBlockFromServerFileTransaction(const AFileName: ansistring;
      ABlockStart: Int64; ABlockSz: Int32): ansistring;
    function PutBlockToServerFileTransaction(const AFileName,
      ADataBlock: ansistring; ABlockStart: Int64): ansistring;
    Class function StreamAsString(AStrm: Tstream): ansistring;
    // function PackAllBackupFiles: TStrings;
    // function PackFileSnapShotName(const AFileName: ansistring): ansistring;
    // function PackDeleteSnapShot(const AFileName: ansistring): ansistring;
    function DecodeSafeFileTransferPath(ACmdPlusPath: string): ansistring;
    function IsUploadAcceptTempFile(AFileName: string): boolean;
    function SimpleRemoteAction(const AFunction: ansistring): ansistring;
    Function CheckWriteBusy: boolean; Virtual;
    Function CheckReadBusy: boolean; Virtual;
    // function DecodeSafeFileTransferPath(ACmdPlusPath: string): ansistring;
    Procedure ApplicationProcessMessages;
    Procedure SetFullDuplex(Val: boolean); Virtual;
    procedure AddFullDuplexLogMessage(TextID, AMsg: String);
    procedure AddLogMessage(TextID, AMsg: String);
    procedure CloseConnection; virtual;
    // TWorkBeginEvent Id Component Do Begin Work
    procedure WorkBeginEvent(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure WorkEndEvent(ASender: TObject; AWorkMode: TWorkMode);
    procedure WorkEvent(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure LogTimeStampFail(AData: ansistring; AMessage: string);
  Public
    FCoupledSession: TISIndyTCPBase;
    FOwnsCoupledSession: boolean;
    Constructor Create;
    Destructor Destroy; override;
    Function FullDuplexDispatch(AData: ansistring; AKey: ansistring
{$IFNDEF NextGen}
      = '' // Not Next Gen
{$ENDIF} ): boolean; Virtual;
    // Non Blocking transaction On full Duplex Session Starts readThread
    Function RemoteAddress: ansistring;
    Function LocalAddress: ansistring;
    function BindingIsLocal(ABind: TIdSocketHandle): boolean;
    function CallOnLocalSubNet: boolean;
    function TextID: String; Virtual;
    function ReadFullDuplexLogMessage: String;
    function ReadLogMessage: String;
    function CloseGracefully: boolean;
    Function RecentData(AGap: TDateTime): boolean;
    Class function RawToByteArray(AData: RawByteString): TIdBytes;
    Procedure LogAMessage(AMsg: String); virtual;
    Procedure WorkEnableBeginActionEndBreakpoints;
    // Activates Work Action Functions where you can set breakpoints for this specific object
    // procedure AfterConstruction; override;
    Property Address: String read GetIPRemote write SetAddress;
    Property Port: TIdPort read GetPort write SetPort;
    Property LocalPort: TIdPort read GetLocalPort;
    Property MaxTcpBuffRead: integer read fMaxTcpBuffRead write fMaxTcpBuffRead;
    Property IOHandler: TIdIOHandler read FIOHandler;
    Property TcpConnection: TIdTCPConnection read FConnection;
    Property FileAccessBase: String read FFileAccessBasePath
      write SetFileAccessBasePath;
    Property ReadDataWaitDiv5: integer read FReadDataWaitDiv5
      write FReadDataWaitDiv5;
    // Time Waiting for a single ReadOneTransaction - FReadDataWaitDiv5
    // Will Cycle 5 times if no data recived  * 5
    // Cycle occures when Timeout raises Exception  and
    // ApplicationProcessMessages is run on each cycle if main thread used
    // ReadOneTransaction is called * cReadDataWaitCycles
    // from ReadATransactionRecord
    //
    Property OnAnsiStringAction: TComandActionAnsi Read FOnAnsiStringAction
      Write FOnAnsiStringAction;
    Property OnDestroy: TISIndyTCPEvent read FOnDestroy write FOnDestroy;
  End;

  TISIndyTCPClient = Class;
  TNoWaitTCPReturn = procedure(ARtn: TISIndyTCPClient) of object;

  TISIndyTCPClient = class(TISIndyTCPBase)
  Private
    fIdTCPClientCon: TIdTCPClient;
    fDoAfterConnection { , fOnDisconnect } : TISIndyTCPEvent;
    fServerAddress: String;
    fServerPort: integer;
    fInReconnect, fCreatedViaStartAccess: boolean;
    FDoNotTryAgainUntil: TDateTime;
    { For testing
      procedure WhenConnected(ASender: TIdConnectionIntercept);
      procedure WhenDisConnected(ASender: TIdConnectionIntercept);
      procedure WhenReceive(ASender: TIdConnectionIntercept;
      var ABuffer: TIdBytes);
      procedure WhenSend(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
    }
    procedure SetAddress(const Value: String); Override;
    procedure SetPort(const Value: TIdPort); Override;
    function GetActive: boolean;
    function IdTCPClientCon(AHost: String; APort: integer): TIdTCPClient;
    procedure SetActive(const Value: boolean);
    procedure FreeOldSocket(Sender: TObject);
  Protected
    FRtnList: TStrings;
    FRtnData: ansistring;
    FRtnTrnctType: TTCPTransactionTypes;
    FRtnKey: ansistring;
    FErrorStr: String;
    FEncrypted, FNotAuthorized, FSecAuthStatus: boolean;
    procedure SendTransaction(AData: ansistring;
      out ATrnctType: TTCPTransactionTypes;
      out AKey, ANewData: ansistring); Override;
    procedure WasClosedForcfullyOrGracefully; Override;
    function CheckConnection: boolean; Override;
    function MakeConnection: boolean;
    procedure CloseConnection; Override;
    function Reconnect(const ACurrentTransanction: ansistring)
      : boolean; Virtual;
  Public
    Constructor Create;
    Constructor StartAccess(const AServerName: String; APort: integer;
      ADoAfterConnection: TISIndyTCPEvent = nil); virtual;
    Destructor Destroy; override;
    Function EchoFromServer(AData: ansistring): ansistring;
    Function SimpleActionExtTransaction(ACommand: ansistring): ansistring;
    Function AnsiTransaction(AData: ansistring): ansistring;
    Function ServerDetails: ansistring;
    Function ServerDetailTestClose: ansistring;
    Function RestartCommsServer: String;
    Function ServerConnections(AResults: TStrings;
      ARegThisValue: ansistring): boolean;
    Function StringTransaction(aString: String): String;
    Function Close: boolean;
    Function LastError: String;
    Function Activate: boolean;
    Function CopyLargeServerFileToStream(AStream: Tstream;
      const AServerFileName: ansistring): boolean;
    Function PutLargeStreamToServer(AStream: Tstream;
      const AServerFileName: ansistring): boolean;
    function TextID: String; override;
    // Property OnDisconnect: TISIndyTCPEvent Read fOnDisconnect
    // Write fOnDisconnect;
    Property Active: boolean read GetActive write SetActive;
    Property DoAfterConnection: TISIndyTCPEvent Read fDoAfterConnection
      Write fDoAfterConnection;
    Property LastNwRtnData: ansistring read FRtnData;
    Property LastNwTransType: TTCPTransactionTypes read FRtnTrnctType;
  end;

  EExceptionIsExpected = class(Exception)
  end;

  EExceptionIsComsNotExpected = class(Exception)
  end;

  TReadThread = class;
  TWriteThread = class;

  TWaitData = class(TObject)
    FData: ansistring;
    FNext: TWaitData;
    Constructor Create(AData: ansistring);
    Destructor Destroy; override;
    Function Push(AData: ansistring): integer; virtual;
    Function Pop(Var AListHead: TWaitData): TWaitData;
  end;

  TNoWaitRtnThrdData = class(TWaitData)
    fNoWaitRtnFunctn: TNoWaitTCPReturn;
    fNoWaitRtnLst: TStrings;
    // ACommand: ansistring;
    Constructor Create(ACommand: ansistring; ARtn: TNoWaitTCPReturn;
      ANoWaitRtnLst: TStrings);
    Function Push(AData: ansistring): integer; override;
    Function PushNoWait(ACommand: TNoWaitRtnThrdData): integer;
  end;

  TNoWaitReturnThread = Class(TThread)
  private
    FLock: TCriticalSection;
    FSrver: String;
    FPort: integer;
    FIdleCount: integer;
    FRtnFunction: TNoWaitTCPReturn;
    FTrdTCPClient: TISIndyTCPClient;
    FThreadActive: boolean;
    FCommands: TWaitData;
    FCurrentQueueOfNWReqLength: integer;
    Function TrdTCPClient: TISIndyTCPClient;
    Function AddNoWaitCommand(ACommand: TNoWaitRtnThrdData): integer;
    procedure ChnlTerminating(AObj: TObject);
    procedure SyncReturnNW;
    procedure ProcessAndFreeCommand(Var ACommand: TNoWaitRtnThrdData);
  Protected
    procedure TerminatedSet ; Override;
    procedure Execute; override;
  Public
    // Create a thread with a unique socket for no wait responses

    // Usage x:=TNoWaitReturnThread.Create(Host,port,AOnTerminate);
    // x.ServerConnectionsNoWait(ResultList,ResultValue6816);
    // ARtnFunction: TNoWaitTCPReturn):
    Constructor Create(ASrver: String; APort: integer;
      AOnTerminate: TNotifyEvent);
    Destructor Destroy; Override;
    Function ServerDetailsNoWait(ARtn: TNoWaitTCPReturn): boolean;
    Function ServerConnectionsNoWait(AResults: TStrings;
      ARegThisValue: ansistring; ARtn: TNoWaitTCPReturn): boolean;
    // Run a single command in this unique socket and sychronize
    // returned data with main thread
    Function SimpleActionNoWaitTransaction(ACommand: ansistring;
      ANoWaitRtnLst: TStrings; ARtn: TNoWaitTCPReturn): boolean;
    Function ChnlConnectionDetails: String;
    Function TextID: String;
    Procedure SetData(ASrver: String; APort: integer);
  End;

  TISIndyTCPFullDuplexClient = Class(TISIndyTCPClient)
  private
    FWaiting: TWaitData;
    FNoWaitRtnThrdData: TWaitData; // Actually TNoWaitRtnThrdData;
    FCurNwCommand: TNoWaitRtnThrdData;
    fReadThread: TReadThread;
    fWriteThread: TWriteThread;
    fDplxReadCriticalSectionLock, fDplxWriteNoWaitCriticalSectionLock
      : TCriticalSection;
    FCurrentQueueOfRequests, FCurrentQueueOfNWRequests, FLockCount: integer;
    fReleaseThreads, FOffThreadDestroy: boolean;
    FNextPoll, FPoleInterval: TDateTime;
    FOnLogMsg: TISIndyLogEvent;
    FOnSimpleDuplexRemoteAction: TComandActionAnsi;
    FPermHold: boolean;
    // The Read thread loops thru read loop until terminated or read loop returns false
    Function ReadLoop: boolean;
    Function WriteLoop: boolean;
    function DoSimpleDuplexRemoteAction(ACommand: ansistring): ansistring;
    Function SetOngoingConnections(AConnectData: ansistring): ansistring;
    Function DropCoupledSession: ansistring;
    Function TrySetFullDuplex: boolean;
    Function DplxWriteNoWaitCriticalSectionLock: TCriticalSection;
    Function AddNoWaitSyncCommand(ACommand: TNoWaitRtnThrdData): integer;
    procedure SetSynchronizeResults(const Value: boolean);
    procedure SyncReturnDuplxCltNW;
    procedure ProcessAndFreeNwCommand(Var ACommand: TWaitData);
  Protected
    { procedure SendTransaction(AData: ansistring;
      out ATrnctType: TTCPTransactionTypes;
      out AKey, ANewData: ansistring); Override;
      Base level Returns Full Duplex State }
    function ProcessNonDuplexIncomingTransaction(Trans, Key: ansistring;
      TrnctType: TTCPTransactionTypes): boolean; // virtual;
    function ReadATransactionRecord(var ATrnctType: TTCPTransactionTypes;
      var AKey: ansistring): ansistring; override;
    Procedure SetFullDuplex(Val: boolean); override;
    function Write(AData: RawByteString): integer; override;
    Function TestTimeStamp(APayload: ansistring; Atest: integer = 5000)
      : boolean;
    Function MakeTimeStamp: ansistring;
  Public
{$IFDEF Debug}
    FIsDebugchnl: boolean;
{$ENDIF}
    Constructor StartAccess(const AServerName: String; APort: integer;
      ADoAfterConnection: TISIndyTCPEvent = nil); override;
    Destructor Destroy; override;
    Function OffThreadDestroy(DoOnDestroyProcess: boolean): boolean;
    // Destroy takes some time as threads need to terminate
    // Use OffThreadDestroy to take this process outside main thread
    // Happens in Rx or TX threads Destroy
    Procedure LogAMessage(AMsg: String); override;
    Function FullDuplexDispatchNoWait(AData: ansistring;
      AMaxQueue: integer): integer;
    Function DropAllRemoteSessions: boolean;
    Function ServerSetLinkConnection(ALinkThisValue: ansistring): boolean;
    Function ServerSetRefConnection(AReferenceValue: ansistring): boolean;
    Function ServerSetFollowonConnection(const AServerName: String;
      APort: integer): boolean;
    Function ServerLinkFromConnectionText(AConnectionText: string): boolean;

    Function ServerConnectionsNoWait(AResults: TStrings;
      ARegThisValue: ansistring; ARtn: TNoWaitTCPReturn): boolean;

    Class Function RefValueFromConnectionListValue(AListValue: String;
      out IsFree: boolean): ansistring;
    procedure DropThread(AThread: TThread);
    Property OnLogMsg: TISIndyLogEvent Read FOnLogMsg write FOnLogMsg;
    // must not sync with main thread
    Property OnSimpleDuplexRemoteAction: TComandActionAnsi
      read FOnSimpleDuplexRemoteAction write FOnSimpleDuplexRemoteAction;
    Property SynchronizeResults: boolean read FSynchronizeResults
      write SetSynchronizeResults;
    Property PermHold: boolean read FPermHold write FPermHold;
  End;

  TISIndyTCPFullDuplexClientClass = Class of TISIndyTCPFullDuplexClient;

  TReadThread = class(TThread)
  protected
    FTCPConnection: TISIndyTCPFullDuplexClient;
    procedure Execute; override;
  Public
    constructor Create;
    Destructor Destroy; Override;
  end;

  TWriteThread = class(TReadThread)
  protected
    procedure Execute; override;
  end;

  TTimeRec = Record
    Procedure SetValue(Val: TDateTime);
    Function AsString: string;
    Function TransString: ansistring;
    Function FromTransString(AData: ansistring): boolean;
    Function DelayOfLessThan(ATestMilliSecs: integer): boolean;
    Function DeltaMilliSecs: integer; // mSeconds since set time
    case ws: boolean of
      true:
        (FDateTime: Double);
      false:
        (FData: Array [1 .. 8] of Byte);
  end;

procedure Encrypt(ABufferSize: Longword; ABufferPointer: pointer;
  AKeySize: Word; AKeyPointer: pointer);
Procedure CopyMemory(ADestination, ASource: pointer; AMemLen: Longword);
// : LongWord;
function DecodeIpAddress(WebAddress: PAnsiChar): ansistring;
function IsIPAddress(var IpAdd: Longword; WebAddress: PAnsiChar): boolean;
function BytesToTextString(const ByteData: ansistring): ansistring; overload;
function BytesToTextString(const ByteData: array of Byte): ansistring; overload;
function PackTransaction(const AData, AEncryptKey: ansistring): ansistring;
function PackRawString(AData: ansistring; AEncryptKey: ansistring): ansistring;
Function PackString(AData: String; AEncryptKey: ansistring): ansistring;

{$IFDEF NEXTGEN}
{$IFDEF Debug}
Function OpenDebugBreakPointsInAndroid: boolean;
{$ENDIF}
{$ENDIF}
{$IFDEF NextGen}
// Remote Transaction Keys 3 Chars as functions
Function cBuildIndexTransaction: ansistring; // = 'Bit';
Function cBuildNewLockFileTransaction: ansistring; // = 'Blt';
Function cClassIndexTransaction: ansistring; // = 'Cit';
Function cDeleteIndexObjTransaction: ansistring; // = 'Dot';
Function cGetTotalObjectsTransaction: ansistring; // = 'Got';
Function cLoadRegisterObjectTransaction: ansistring; // = 'Lrt';
Function cLockUnlockIndexTransaction: ansistring; // = 'Lut';
Function cPopStmTransaction: ansistring; // = 'Pot';
Function cPutStmTransaction: ansistring; // = 'Put';
Function cRegisterObjectTransaction: ansistring; // = 'Rot';
Function cRefreshSupIndexList: ansistring; // = 'Rst';
Function cSaveIndexfileTransaction: ansistring; // = 'Sit';

Function cStartConnection: ansistring; // = 'Sct';
Function cPartTransactionData: ansistring; // = 'Ptd';
Function cSimpleRemoteAction: ansistring; // = 'Smp';
Function cReadFileTransferBlock: ansistring; // = 'FtB';
Function cPutFileTransferBlock: ansistring; // = 'PtB';
Function cReturnError: ansistring; // = 'Err';
Function cMvRawStrm: ansistring;
Function cFullDuplexMode: ansistring; // =
Function cMvStr: ansistring;
Function cLogServerDetails: ansistring; // = 'Lsd';
Function cReturnEcho: ansistring; // = 'Eco';
Function cNoExistMessage: ansistring; // = ' Does Not Exist'

Function CLinkClosed: ansistring; // ='|' + 'Closed';
Function CLinkFree: ansistring; // = '|' + 'Free';
Function CLinkLinked: ansistring; // ='|' + 'Linked';

Function CRLF: ansistring; // = AnsiChar(#13) + AnsiChar(#10);
Function Lf: ansistring; // = AnsiChar(#10);

{$ELSE}

const
  // Remote Transaction Keys 3 Chars
  cBuildIndexTransaction: ansistring = 'Bit';
  cBuildNewLockFileTransaction: ansistring = 'Blt';
  cClassIndexTransaction: ansistring = 'Cit';
  cDeleteIndexObjTransaction: ansistring = 'Dot';
  cGetTotalObjectsTransaction: ansistring = 'Got';
  cLoadRegisterObjectTransaction: ansistring = 'Lrt';
  cLockUnlockIndexTransaction: ansistring = 'Lut';
  cPopStmTransaction: ansistring = 'Pot';
  cPutStmTransaction: ansistring = 'Put';
  cRegisterObjectTransaction: ansistring = 'Rot';
  cRefreshSupIndexList: ansistring = 'Rst';
  cStartConnection: ansistring = 'Sct';
  // cPartTransactionData: ansistring = 'Ptd';
  cSaveIndexfileTransaction: ansistring = 'Sit';
  cSimpleRemoteAction: ansistring = 'Smp';
  cReadFileTransferBlock: ansistring = 'FtB';
  cPutFileTransferBlock: ansistring = 'PtB';
  cReturnError: ansistring = 'Err';
  cMvStr: ansistring = 'Mvs';
  cMvRawStrm: ansistring = 'MvR';
  cLogServerDetails: ansistring = 'Lsd';
  cReturnEcho: ansistring = 'Eco';
  cFullDuplexMode: ansistring = 'FDM';
  // cReturnError: ansistring = 'Err';
  // cReturnError: ansistring = 'Err';
  // cReturnError: ansistring = 'Err';
  cNoExistMessage = ' Does Not Exist';

  CRLF = AnsiChar(#13) + AnsiChar(#10);
  Lf = AnsiChar(#10);

  CLinkClosed = '|' + 'Closed';
  CLinkFree = '|' + 'Free';
  CLinkLinked = '|' + 'Linked';


  // cRemoteLockIndicator:UInt32 = $AAAAAAAA;
{$ENDIF}
{$IFDEF NextGen}
Function cRemoteResetServer: ansistring;
Function cRemoteServerDetails: ansistring;
Function cRemoteServerConnections: ansistring;
Function cRemoteServerDropCoupledSession: ansistring;
Function cRemoteSetServerRelay: ansistring;
Function cServerLink: ansistring;
Function cNewIPLink: ansistring;
Function cStartTimeStamp: ansistring;
Function cEndTimeStamp: ansistring;

const
{$ELSE}
const
  cRemoteServerConnections: ansistring = 'RemoteServerConnections#';
  cRemoteServerDropCoupledSession
    : ansistring = 'RemoteServerDropCoupledSession#';
  cRemoteSetServerRelay: ansistring = 'RemoteServerRelay#';
  cRemoteResetServer: ansistring = 'RemoteResetServer#';
  cServerLink: ansistring = 'SV#';
  // Link to server in RemoteServerConnections by name
  cNewIPLink: ansistring = 'IP#';
  // Generate a full duplex call to IP:Port from server
  cStartTimeStamp: ansistring = 'TStamp#';
  cEndTimeStamp: ansistring = 'ETStamp#';
{$ENDIF}
  CMaxDuplexPacket = 700000000;
  cFnameMarker = 'fn^~}';
  cPersonalityMarker = 'Pr^~}';
  cNoPersonality = 'NO PERSONALITY';
  cEndMarker = 'e~}^';
  cClosing = 'closesocket}~^';
  cDuplexInactiveTime: TDateTime = 5 / 24 / 60; // 5 minutes
  c30SecondsDateTime: TDateTime = 0.5 / 24 / 60; // 40 Seconds
  MaxTcpBuffer = 256;
  CVLrgeBusy = 10000000; // Default Busy reporting per hour

Var
  // Handshake string
  // Changing This String Value will Restrict Access to
  // Applications with the same setting
  // GCountOfConnections: integer; // Base Connections
  // GlobalCountOfComsObjectTypes: TStringlist;
  GlobalApplicationProcessMessages: Procedure of Object;
{$IFDEF Debug}
  // GlobalTCPLogAllData: boolean = true;
{$ELSE}
  // GlobalTCPLogAllData: boolean = false;
{$ENDIF}
  GlobalSelectDebugChn: TISIndyTCPFullDuplexClient = nil;
{$IFDEF NEXTGEN}
  cApplicationHandshakeCodeString
    : String = 'Change This String Value to Restrict Access';
Function cApplicationHandshakeCode: ansistring; inline;
// ='Change This String Value to Restrict Access';
function CTransactionStart: AnsiChar; inline; // = '<';
function CTransactionEnd: AnsiChar; inline; // = '>';
{$ELSE}
  cApplicationHandshakeCode
    : ansistring = 'Change This String Value to Restrict Access';
  CTransactionStart: AnsiChar = '<';
  CTransactionEnd: AnsiChar = '>';
{$ENDIF}

Const
  cTCPClientReadTimeOut = 100;
  MinTransactionSz = 8;
  cMaxDataChunk = 100000; // 100 KBytes  <> One Megabyte
  DebugStartKey: TDateTime = 4000.0000;

  SocketAbortTimeout = 5000; // msec
  StreamTimeout = 5000; // msec
  cReadDataWaitCycles = 10;
{$IFDEF FPC}
Function SzRecAsString(ASzRec: TTxnSzRecord): ansistring;
function SzRecFrmChar(aa, ab, ac, ad: AnsiChar): TTxnSzRecord;
function SzRecFrmString(aString: ansistring; AOffset: integer = 0)
  : TTxnSzRecord;
Procedure FreeAndNilDuplexChannel(Var AChnl: pointer);
{$ELSE}
Procedure FreeAndNilDuplexChannel(const [ref] AChnl
  : TISIndyTCPFullDuplexClient);
{$ENDIF}
Procedure GblIndyComsObjectFinalize;

Var
  GblIndyComsInFinalize: boolean = false;

implementation

uses IsGblLogCheck, IdExceptionCore; // , IsRemoteDbLib;

Var
  CountNoWaitReturnThread: integer = 0;
  CountWaitData: integer = 0;

type

  StrCodeInfoRec = record
    CodePage: Word; // 2
    ElementLength: Word; // 2
    RefCount: integer; // 4
    Length: integer; // 4
  end;

  PStrCodeInfoRec = ^StrCodeInfoRec;

const
  NullStrCodeInfo: StrCodeInfoRec = (CodePage: 0; ElementLength: 0; RefCount: 0;
    Length: 0);

{$IFDEF NextGen}

Function cRemoteResetServer: ansistring;
Begin
  Result := 'RemoteResetServer#';
end;

Function cRemoteServerDetails: ansistring;
Begin
  Result := 'RemoteServerDetails#';
end;

Function cRemoteServerDropCoupledSession: ansistring;
begin
  Result := 'RemoteServerDropCoupledSession#'
end;

Function cRemoteServerConnections: ansistring;
begin
  Result := 'RemoteServerConnections#';
end;

Function cRemoteSetServerRelay: ansistring;
begin
  Result := 'RemoteServerRelay#';
end;

Function cServerLink: ansistring;
begin
  Result := 'SV#';
end;

Function cNewIPLink: ansistring;
begin
  Result := 'IP#';
end;

Function cStartTimeStamp: ansistring;
begin
  Result := 'TStamp#';
end;

Function cEndTimeStamp: ansistring;
begin
  Result := 'ETStamp#';
end;

{$ENDIF}

Procedure CopyMemory(ADestination, ASource: pointer; AMemLen: Longword);
// : LongWord;
Const
  BufMax = 2000000000;
Type
  Bfr = Array [0 .. BufMax] of Byte;
  BfrPtr = ^Bfr;
Var
  Src, Dest: BfrPtr;
  i: integer;
begin
  if AMemLen > BufMax then
    raise EExceptionIsComsNotExpected.Create('CopyMemory Length exceeded (' +
      IntToStr(BufMax) + ') Value=' + IntToStr(AMemLen));
  Src := ASource;
  Dest := ADestination;
  for i := 0 to AMemLen - 1 do
    Dest[i] := Src[i];
  // Result:=LongWord(@Dest[i]);
end;

{$IFDEF DEBUG}

Function BufferAsAnsi(AWriteBuffer: TIdBytes): ansistring;
{$IFDEF NEXTGEN}
begin
  Result.CopyBytesFromMemory(@AWriteBuffer[0], Length(AWriteBuffer));
{$ELSE}
Var
  i: integer;
begin
  SetLength(Result, Length(AWriteBuffer));
  For i := 1 to Length(AWriteBuffer) do
    Result[i] := AnsiChar(AWriteBuffer[i - 1]);
{$ENDIF}
end;
{$ENDIF}

{ Mod Nov 2015 function StringFromBuffer(Const ABuffer: From (ABuffer }
function StringFromBuffer(Const ABuffer: array of Byte; AStart, ACount: integer)
  : ansistring;
var
  ActCount: integer;
begin
  ActCount := Length(ABuffer) - AStart;
  if ActCount > ACount then
    ActCount := ACount;
  if ActCount > 0 then
  begin
{$IFDEF NextGen}
    Result.CopyBytesFromMemory(@ABuffer[AStart], ActCount);
{$ELSE}
    SetLength(Result, ActCount);
    CopyMemory(@Result[1], @ABuffer[AStart], ActCount);
{$ENDIF}
  end
  else
    Result := '';
end;

function BytesToTextString(const ByteData: array of Byte): ansistring; overload;
begin
  Result := BytesToTextString(StringFromBuffer(ByteData, 0, Length(ByteData)));
end;

function BytesToTextString(const ByteData: ansistring): ansistring; overload;
const
  a: set of ' ' .. '}' = [' ' .. '~'];
  Ctrl: set of #0 .. #255 = [#1 .. #31];
var
  i: integer;
  Sub: LongInt;
  rr: ansistring;
  x: AnsiChar;
  GreaterThan127: boolean;
  DataLength: integer;

begin
  try
{$IFDEF NextGen}
    Result := ByteData.AsStringValues;
{$ELSE}
    Result := '';
    if ByteData = '' then
      Exit;

    i := 1;
    rr := '';
    DataLength := Length(ByteData);
    if DataLength > 1000 then
      DataLength := 1000;
    // raise EExceptionIsComsNotExpected.Create('BytesToTextString is limitted to 6000');
    // modified for ISMultiUserPermObjFileStm
    while i <= DataLength do
    begin
      Sub := Ord(ByteData[i]);
      GreaterThan127 := Sub > 127;
      if GreaterThan127 then
      begin
        Sub := Sub - 128;
        rr := rr + '<';
      end;
      x := AnsiChar(Sub);
      if (x in a) then
        rr := rr + x
      else
      begin
        if GreaterThan127 then
          rr := rr + '[' + IntToHex(Sub + 128, 2) + ']'
        else
          rr := rr + '[' + IntToHex(Sub, 2) + ']';
        if (x in Ctrl) then
          rr := rr + '(' + '^' + AnsiChar(Sub + 64) + ')';
      end;
      if GreaterThan127 then
        rr := rr + '>';
      i := i + 1;
    end;
    Result := rr;
{$ENDIF}
  except
    on E: Exception do
      Result := 'BytesToTextString Error::' + E.Message;
  end;
end;
{$IFDEF FPC}

Procedure FreeAndNilDuplexChannel(Var AChnl: pointer);
Begin
  Try
    if AChnl <> nil then
      TISIndyTCPFullDuplexClient(AChnl).OffThreadDestroy(true);
  Except
  End;
  AChnl := nil;
End;

// procedure FreeAndNil(var obj);
// var
// temp: tobject;
// begin
// temp:=tobject(obj);
// pointer(obj):=nil;
// temp.free;
// end;

{$ELSE}

Procedure FreeAndNilDuplexChannel(const [ref] AChnl
  : TISIndyTCPFullDuplexClient);
Begin
  Try
    if AChnl <> nil then
      AChnl.OffThreadDestroy(false);
  Except
  End;
  TObject(pointer(@AChnl)^) := nil;
End;
{$ENDIF}

function DecodeIpAddress(WebAddress: PAnsiChar): ansistring;
// IpAdd from  inet_addr >> If no error occurs, inet_addr returns an unsigned long containing a suitable binary representation of the Internet address given. If the passed-in AnsiString does not contain a legitimate Internet address, for example if a portion of an "a.b.c.d" address exceeds 255, inet_addr returns the value INADDR_NONE.
var
  s: ansistring;

begin
  s := WebAddress;
  Try
    TIdStack.IncUsage;
    Result := GStack.ResolveHost(s);
  Finally
    TIdStack.DecUsage;
  End;
end;

function IsIPAddress(var IpAdd: Longword; WebAddress: PAnsiChar): boolean;
// IpAdd from  inet_addr >> If no error occurs, inet_addr returns an unsigned long containing a suitable binary representation of the Internet address given. If the passed-in AnsiString does not contain a legitimate Internet address, for example if a portion of an "a.b.c.d" address exceeds 255, inet_addr returns the value INADDR_NONE.
var
  s: String;

begin
  Result := false;
  s := WebAddress;
  if Trim(s) = '' then
    Exit;
  if Pos('.', s) < 2 then
    Exit;

  Try
    TIdStack.IncUsage;
    Result := GStack.IsIP(s);
  Finally
    TIdStack.DecUsage;
  End;
end;

{$IFDEF NEXTGEN}

function CTransactionStart: AnsiChar; inline; // = '<';
begin
  Result := '<';
end;

function CTransactionEnd: AnsiChar; inline; // = '>';
begin
  Result := '>';
end;

Function cApplicationHandshakeCode: ansistring; inline;
// ='Change This String Value to Restrict Access';
begin
  Result := cApplicationHandshakeCodeString;
end;
{$ENDIF}
{$IFDEF NEXTGEN}
{$IFDEF Debug}

Function OpenDebugBreakPointsInAndroid: boolean;
begin
  Result := true;
end;
{$ENDIF}
{$ENDIF}

Function DebugNonRandomKey: ansistring;
begin
  Result := 'AOAOAOAOA';
end;

function StrCodeInfo(const s: RawByteString): StrCodeInfoRec; overload; inline;
var
  AtS: NativeInt;
begin
  AtS := NativeInt(s);
  if AtS = 0 then
    Result := NullStrCodeInfo
  else
    Result := PStrCodeInfoRec(AtS - 12)^
end;

function StrCodeInfo(const s: UnicodeString): StrCodeInfoRec; overload; inline;
var
  AtS: NativeInt;
begin
  AtS := NativeInt(s);
  if AtS = 0 then
    Result := NullStrCodeInfo
  else
    Result := PStrCodeInfoRec(AtS - 12)^
end;

function CompressedUnicode(const AUCode: UnicodeString): ansistring;
// Contains Ascii version of Unicode but '' if 2 byte characters found
// Reverse of DeCompressUnicode
// Byte Contents Drops nulls in uncode
var
  Ri, Ui: integer;
  Nxt, Dest: PAnsiChar;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result.CompressedUnicode(AUCode);
{$ELSE}
  R := StrCodeInfo(AUCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    if R.CodePage <> DefaultUnicodeCodePage then
      raise EExceptionIsComsNotExpected.Create('Non Unicode Unicode');
    SetLength(Result, R.Length);
    // AllDone:=r.Length-1;
    Nxt := @AUCode[1];
    Dest := @Result[1];
    Ri := 0;
    Ui := 0;
    while (Nxt[Ui + 1] = AnsiChar(0)) and (Ri < R.Length) do
    begin
      Dest[Ri] := Nxt[Ui];
      Inc(Ui, 2);
      Inc(Ri);
    end;
    if Ri < R.Length then
      Result := '';
  end;
{$ENDIF}
end;

function DeCompressUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reverse of CompressedUnicode
// Byte Contents inserted nulls
var
  Ri, Ai: integer;
  Nxt, Dest: PAnsiChar;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AAnsiCode;
{$ELSE}
  R := StrCodeInfo(AAnsiCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    if R.CodePage = DefaultUnicodeCodePage then
      raise EExceptionIsComsNotExpected.Create('Unicoded non Unicode');
    SetLength(Result, R.Length);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    Ri := 0;
    Ai := 0;
    while (Ai < R.Length) do
    begin
      Dest[Ri + 1] := AnsiChar(0);
      Dest[Ri] := Nxt[Ai];
      Inc(Ai);
      Inc(Ri, 2);
    end;
  end;
{$ENDIF}
end;

function UnicodeAsAnsi(const AUCode: UnicodeString): ansistring;
// Bypasses Conversion Routines Byte for Byte conversion Unicode Length 10 = Ansi len 20
// For std Unicode with actual AnsiChars every second byte in new string will be a null
// Byte Contents unchanged

var
  MemLen: integer;
  Nxt, Dest: pointer;
  R: StrCodeInfoRec;
  // RstAnsiCode:RawByteString;
begin
  // RstAnsiCode:= AAnsiCode;
  // SetCodepage(RstAnsiCode,DefaultUnicodeCodePage,false);
  // Result:=RstAnsiCode;
  R := StrCodeInfo(AUCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    // if R.CodePage<>DefaultUnicodeCodePage then
    // raise EExceptionIsComsNotExpected.Create('Error Message');
    // ULen:=Length(AUCode);

    // if R.CodePage<>DefaultUnicodeCodePage then
    // raise EExceptionIsComsNotExpected.Create('Error Message');

{$IFDEF NextGen}
    Result.UnicodeAsAnsi(AUCode);
{$ELSE}
    MemLen := R.ElementLength * R.Length;
    SetLength(Result, MemLen);
    Nxt := @AUCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
{$ENDIF}
  end;
end;

function AnsiAsUnicode(const AAnsiCode: RawByteString): UnicodeString;
// Reinstates String following UnicodeAsAnsi
// Bypasses Conversion Routines
// Byte Contents unchanged
var
  MemLen, ULen: integer;
  Nxt, Dest: pointer;
  R: StrCodeInfoRec;
begin
{$IFDEF NextGen}
  Result := AAnsiCode.RecoverFullUnicode;
{$ELSE}
  R := StrCodeInfo(AAnsiCode);
  if R.Length < 1 then
    Result := ''
  else
  begin
    // if R.CodePage=DefaultUnicodeCodePage then
    // raise EExceptionIsComsNotExpected.Create('Error Message');

    MemLen := R.ElementLength * R.Length;
    if (MemLen mod 2) > 0 then
      Inc(MemLen); // now points to null terminator

    ULen := MemLen div 2;
    SetLength(Result, ULen);
    Nxt := @AAnsiCode[1];
    Dest := @Result[1];
    CopyMemory(Dest, Nxt, MemLen);
  end;
{$ENDIF}
end;

function BufferFromString(aString: ansistring; AStart, ACount: integer)
  : TArrayOfByte;
var
  ActCount: integer;
begin
  ActCount := Length(aString) - AStart + 1;
  if ActCount > ACount then
    ActCount := ACount;
  if ActCount > 0 then
  begin
    SetLength(Result, ActCount);
{$IFDEF NEXTGEN}
    CopyMemory(@Result[0], pointer(aString), ActCount);
{$ELSE}
    CopyMemory(@Result[0], @aString[AStart], ActCount);
{$ENDIF}
  end
  else
    SetLength(Result, 0);
end;

function DecodeTransactionTCPType(const AKey: ansistring): TTCPTransactionTypes;
var
  s: string;
begin
  if Length(AKey) <> 3 then
    raise EExceptionIsComsNotExpected.Create('DecodeTransactionTCPType');

  { if AKey = cBuildIndexTransaction then
    Result := GetInxFl
    else if AKey = cBuildNewLockFileTransaction then
    Result := GetLkFl
    else if AKey = cClassIndexTransaction then
    Result := GetClsIdx
    else if AKey = cLoadRegisterObjectTransaction then
    Result := GetRegObj
    else if AKey = cGetTotalObjectsTransaction then
    Result := GetTotalObj
    else if AKey = cLockUnlockIndexTransaction then
    Result := LkUkInxRc
    else if AKey = cPopStmTransaction then
    Result := PopObj
    else if AKey = cPutStmTransaction then
    Result := PutObj
    else if AKey = cRegisterObjectTransaction then
    Result := RegObj
    else if AKey = cRefreshSupIndexList then
    Result := RfshSupInx
    else }
  if AKey = cStartConnection then
    Result := NewCon
    // else if AKey = cPartTransactionData then
    // Result := PartTrnData
  else if AKey = cSimpleRemoteAction then
    Result := SmpAct
  else { if AKey = cSaveIndexfileTransaction then
      Result := PutInxFl
      else if AKey = cDeleteIndexObjTransaction then
      Result := DelObj
      else }
    if AKey = cReturnEcho then
      Result := EchoTrans
    else if AKey = cReturnError then
      Result := FlgError
    else if AKey = cMvStr then
      Result := MvString
    else if AKey = cMvRawStrm then
      Result := MvRawStrm
    else if AKey = cReadFileTransferBlock then
      Result := RdFileTrfBlk
    else if AKey = cPutFileTransferBlock then
      Result := PtFileTrfBlk
    else if AKey = cLogServerDetails then
      Result := LogServerData
    else if AKey = cFullDuplexMode then
      Result := FullDuplexMode
    else
    Begin
      s := AKey;
      raise EExceptionIsExpected.Create('DecodeTransactionTCPType::<' +
        s + '>');
    End;
end;

function PackTransaction(const AData, AEncryptKey: ansistring): ansistring;
var
  Txn: TTxnSzRecord;
  s: ansistring;
{$IFDEF NEXTGEN}
  PtrSData: pointer;
{$ENDIF}
  i: LongInt;
  TxnType: TTCPTransactionTypes;

begin
  TxnType := SmpAct;
  try
{$IFDEF NextGen}
    i := AData.Length - 3;
{$ELSE}
    i := Length(AData) - 3;
{$ENDIF}
    try
      if i < 0 then
      begin
        s := cSimpleRemoteAction + AData;
        i := i + 3;
      end
      else
        s := AData;
{$IFDEF FPC}
      uniquestring(s);
{$ENDIF}
{$IFDEF NextGen}
      TxnType := DecodeTransactionTCPType(s[0] + s[1] + s[2]);
{$ELSE}
      TxnType := DecodeTransactionTCPType(s[1] + s[2] + s[3]);
{$ENDIF}
      Txn.Sz := i;
    except
      s := cSimpleRemoteAction + AData;
{$IFDEF NextGen}
      Txn.Sz := s.Length - 3;
{$ELSE}
      Txn.Sz := Length(s) - 3;
{$ENDIF}
    end;
{$IFDEF fpc}
    uniquestring(s);
{$ENDIF}
    { encrypt }
{$IFDEF NEXTGEN}
    PtrSData := pointer(Int64(pointer(s)) + 3);
{$ENDIF}
    if (AEncryptKey <> '') and (Length(s) > 3) and
      not(TxnType in [FlgError, NewCon]) then
{$IFDEF NEXTGEN}
      Encrypt(s.Length - 3, PtrSData, AEncryptKey.Length, pointer(AEncryptKey));
{$ELSE}
      Encrypt(Length(s) - 3, @s[4], Length(AEncryptKey), @AEncryptKey[1]);
{$ENDIF}
    { /encrypt }
{$IFDEF FPC}
    Result := CTransactionStart + SzRecAsString(Txn) + s + CTransactionEnd;
{$ELSE}
    Result := CTransactionStart + Txn.AsString + s + CTransactionEnd;
{$ENDIF}
  except
    on E: Exception do
      raise EExceptionIsComsNotExpected.Create('PackTransaction::<' + AData +
        '>key=' + BytesToTextString(AEncryptKey) + ' Message::' + E.Message);
  end;
end;

function PackRawString(AData: ansistring; AEncryptKey: ansistring): ansistring;
Begin
  Result := PackTransaction(cMvRawStrm + AData, AEncryptKey);
End;

Function PackString(AData: String; AEncryptKey: ansistring): ansistring;
var
  DSend: ansistring;

begin
  DSend := CompressedUnicode(AData);
  if DSend <> '' then
    DSend := cMvStr + 'AA' + DSend
  else
    DSend := cMvStr + 'UU' + UnicodeAsAnsi(AData);

  Result := PackTransaction(DSend, AEncryptKey);
End;

procedure DecodeIndyTCPBaseTransStart(Const ABuffer: array of Byte;
  ACharsRead: integer; out ATransactionSize: Longword;
  out AKey, ANewData: ansistring);
// procedure DecodeIndyTCPBaseTransactionStart(Const ABuffer: array of Byte;
// ACharsRead: integer; out ATransactionSize: Longword;
// out ATrnctType: TTCPTransactionTypes; out AKey, ANewData: ansistring);
var
  i: integer;
  ss: String;
  // Transaction Format
  // size
  // Key
  // S       Data>>>>>>>>>>>>>>>>>>>>>>>>>Transaction Sz>>>>>>>>>>>>>>>>>T
  // <1234KEYADATAADATAADATAADATAADATAADATAADATAADATAADATAADATAADATAADATA>
begin
  if (ACharsRead < MinTransactionSz) or (ABuffer[0] <> Ord(CTransactionStart))
  then
  begin
    ss := 'Invalid Transaction Sz=' + IntToStr(ACharsRead) + ' Start=' +
      AnsiChar(ABuffer[0]) + '  Type::' + AnsiChar(ABuffer[5]) +
      AnsiChar(ABuffer[6]) + AnsiChar(ABuffer[7]);
    raise EExceptionIsComsNotExpected.Create(ss);
  end;
  try
    ATransactionSize := ABuffer[1] + ABuffer[2] * 256 + ABuffer[3] * 256 * 256 +
      ABuffer[4] * 256 * 256 * 256;

    if ATransactionSize > CMaxDuplexPacket then
    Begin
      Raise Exception.Create('CMaxDuplexPacket Exceeded::' +
        IntToStr(ATransactionSize) + '>' + IntToStr(CMaxDuplexPacket));
    End;

    i := ACharsRead - 8;

    // Short transactions (Got) have no data
    // So Transaction size is 0
    // Old code returns a > because AChars read=9 but new code Chars read = 8
    if i > ATransactionSize + 1 then
      i := ATransactionSize + 1;
    AKey := AnsiChar(ABuffer[5]) + AnsiChar(ABuffer[6]) + AnsiChar(ABuffer[7]);
    // ATrnctType := DecodeTransactionType(AKey);
{$IFDEF NEXTGEN}
    ANewData.CopyBytesFromMemory(@ABuffer[8], i);
{$ELSE}
    SetLength(ANewData, i);
    if i > 0 then
      CopyMemory(@ANewData[1], @ABuffer[8], i);
{$ENDIF}
  except
    on E: Exception do
      raise EExceptionIsComsNotExpected.Create
        ('DecodeIndyTCPBaseTransactionStart::' + E.Message);
  end;
end;

(* function BuildFullTransaction(const ACurrentData, ANewData: ansistring;
  var ANextChunkNo: Word; out ATrnctType: TTCPTransactionTypes;
  out AKey: ansistring): ansistring;
  var
  DataToAdd, ChnkNo: TTxnSzRecord;
  DatLen: Longword;
  LastChunk: boolean;

  begin
  AKey := '';
  DatLen := Length(ANewData);
  if DatLen < 8 then
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction:Too Little Data::' + ANewData);
  {$IFDEF FPC}
  ChnkNo := SzRecFrmString(ANewData);
  DataToAdd := SzRecFrmString(ANewData, 4);
  {$ELSE}
  ChnkNo.FrmString(ANewData);
  DataToAdd.FrmString(ANewData, 4);
  {$ENDIF}
  if DatLen <> 8 + DataToAdd.Sz then
  raise EExceptionIsComsNotExpected.Create('BuildFullTransaction:Bad DataSz');

  if (ChnkNo.Sz < 1) and (ACurrentData <> '') then
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction:First chunk not first');

  LastChunk := ChnkNo.Sz > $FFFFFFF;

  if LastChunk then
  begin
  ChnkNo.Sz := ChnkNo.Sz - +$F0000000;
  if ANewData[DatLen] = '>' then
  Dec(DataToAdd.Sz)
  else
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction:Last chunk not Terminated');
  end;

  if ChnkNo.Sz = ANextChunkNo then
  Inc(ANextChunkNo)
  else
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction:Chunk out of order');

  Result := ACurrentData + Copy(ANewData, 9, DataToAdd.Sz);

  if LastChunk then
  try
  // DecodeIndyTCPBaseTransactionStart(buffer, DataCount, TransactionSize, ATrnctType, AKey, NewData);
  DatLen := Length(Result);
  if Byte(Result[1]) <> Byte(CTransactionStart) then
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction:No Start Char');
  {$IFDEF FPC}
  DataToAdd := SzRecFrmString(Result, 1);
  {$ELSE}
  DataToAdd.FrmString(Result, 1);
  {$ENDIF}
  DatLen := DatLen - 8;
  if DatLen > DataToAdd.Sz + 1 then
  DatLen := DataToAdd.Sz + 1;
  {$IFDEF NEXTGEN}
  AKey := Result[5] + Result[6] + Result[7];
  {$ELSE}
  AKey := Result[6] + Result[7] + Result[8];
  {$ENDIF}
  ATrnctType := DecodeTransactionTCPType(AKey);

  if DatLen > 0 then
  {$IFDEF NEXTGEN}
  Result := Copy(Result, 8, DatLen);
  {$ELSE}
  Result := Copy(Result, 9, DatLen);
  {$ENDIF}
  except
  on E: Exception do
  raise EExceptionIsComsNotExpected.Create
  ('BuildFullTransaction::DecodeIndyTCPBaseTransactionStart::' +
  E.Message);
  end
  else
  ATrnctType := PartTrnData;
  end;

  function GenerateTransactionChunkData(var AData: ansistring;
  var AChunkCount: Word): ansistring;
  var
  DataFlgToGo, ChnkNo, Txn: TTxnSzRecord;
  DatLen, DataToGo: Longword;
  TxnKey: ansistring;
  begin
  DatLen := Length(AData);
  if AChunkCount = 0 then
  begin
  if DatLen < cMaxDataChunk then
  raise EExceptionIsComsNotExpected.Create('Chunk<MaxDataChunk on 0');
  try
  {$IFDEF NEXTGEN}
  TxnKey := AData[0] + AData[1] + AData[2];
  {$ELSE}
  TxnKey := AData[1] + AData[2] + AData[3];
  {$ENDIF}
  DecodeTransactionTCPType(TxnKey);
  Txn.Sz := Length(AData) - 3;
  except
  raise EExceptionIsComsNotExpected.Create
  ('GenerateTransactionChunkData:No Valid Transaction::' + TxnKey);
  end;
  end;

  ChnkNo.Sz := AChunkCount;
  if DatLen > cMaxDataChunk then
  DataFlgToGo.Sz := cMaxDataChunk
  else
  begin
  DataFlgToGo.Sz := DatLen;
  ChnkNo.Sz := AChunkCount + $F0000000;
  end;

  DataToGo := DataFlgToGo.Sz;
  if AChunkCount = 0 then
  begin
  Inc(DataFlgToGo.Sz, 5);
  {$IFDEF FPC}
  Result := cPartTransactionData + SzRecAsString(ChnkNo) +
  SzRecAsString(DataFlgToGo) + CTransactionStart + SzRecAsString(Txn);
  {$ELSE}
  Result := cPartTransactionData + ChnkNo.AsString + DataFlgToGo.AsString +
  CTransactionStart + Txn.AsString;
  {$ENDIF}
  end
  else
  begin
  if ChnkNo.Sz > $FFFFFFF then
  Inc(DataFlgToGo.Sz);
  {$IFDEF FPC}
  Result := cPartTransactionData + SzRecAsString(ChnkNo) +
  SzRecAsString(DataFlgToGo);
  {$ELSE}
  Result := cPartTransactionData + ChnkNo.AsString + DataFlgToGo.AsString;
  {$ENDIF}
  end;
  Result := Result + Copy(AData, 1, DataToGo);

  if ChnkNo.Sz > $FFFFFFF then
  begin
  AData := '';
  Result := Result + CTransactionEnd;
  end
  else
  AData := Copy(AData, DataToGo + 1, DatLen);

  Inc(AChunkCount);
  end;
*)

{ TISIndyTCPClient }

function TISIndyTCPClient.Activate: boolean;
begin
  Try
    Result := Active;
    if not Result then
      if (fServerAddress <> '') and (fServerPort > 0) then
        if fInReconnect or not fCreatedViaStartAccess then
        Begin
          WasClosedForcfullyOrGracefully;
          If IdTCPClientCon(fServerAddress, fServerPort) <> nil then
            // use create
            if fIdTCPClientCon.Connected then
            Begin
              Result := true;
              SetConnection(fIdTCPClientCon);
            End;
        end;
  except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, 'Activate Exception:: ID=' + TextID);
      LogAMessage('Activate Exception::' + E.Message);
      Result := false;
    end;
  end;
end;

function TISIndyTCPClient.AnsiTransaction(AData: ansistring): ansistring;
Var
  TrnsType: TTCPTransactionTypes;
  Key: ansistring;
begin
  SendTransaction(PackRawString(AData, FRandomKey), TrnsType, Key, Result);
end;

Function TISIndyTCPClient.CheckConnection: boolean;
begin
  if Not Active then
    If FDoNotTryAgainUntil < now Then
      Reconnect('');
  Result := Active;
end;

function TISIndyTCPClient.Close: boolean;
begin
  if fIdTCPClientCon <> nil then
    fIdTCPClientCon.Disconnect;
  WasClosedForcfullyOrGracefully;
  Result := Not Active;
end;

procedure TISIndyTCPClient.CloseConnection;
begin
  Close;
end;

function TISIndyTCPClient.CopyLargeServerFileToStream(AStream: Tstream;
  const AServerFileName: ansistring): boolean;
var
  Rtn, Key, Trans: ansistring;
  Sz, NxtBlock: Int64;
  BlockSz, DataSize: Int32;
  TrnsType: TTCPTransactionTypes;

begin
  Result := false;
  if AServerFileName = '' then
    Exit;
  if AStream = nil then
    Exit;
  CheckConnection;

  Trans := PackTransaction(SimpleRemoteAction('RemoteFileSize' + '^' +
    AServerFileName), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  Sz := StrToIntDef(Rtn, 0);
  if Sz = 0 then
    raise EExceptionIsExpected.Create('No Remote File :: ' + AServerFileName);

  BlockSz := cMaxDataChunk;
  DataSize := BlockSz;
  NxtBlock := 0;

  while (NxtBlock < Sz - 1) and (DataSize = BlockSz) do
  begin
    Trans := PackTransaction(GetBlockFromServerFileTransaction(AServerFileName,
      NxtBlock, BlockSz), FRandomKey);
    SendTransaction(Trans, TrnsType, Key, Rtn);
    DataSize := Length(Rtn);
{$IFDEF NextGen}
    Rtn.WriteBytesToStrm(AStream, DataSize);
{$ELSE}
    AStream.Write(Rtn[1], DataSize);
{$ENDIF}
    NxtBlock := NxtBlock + DataSize;
  end;
  Result := NxtBlock = Sz;
end;

constructor TISIndyTCPClient.Create;
begin
  MaxTcpBuffRead := -1; // Read Everything
  // IdTCPCon;
  Inherited;
  ReadDataWaitDiv5 := 200; // ms
  FCloseOnTimeOut := true;
end;

destructor TISIndyTCPClient.Destroy;
begin
  Try
    try
      FConnection := nil;
      FreeAndNil(fIdTCPClientCon); // Client owns socket connection
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self, '#' + 'Closing/Destroy :' + TextID);
    finally
      inherited;
    end;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TISIndyTCPClient.Destroy');
  End;
end;

function TISIndyTCPClient.EchoFromServer(AData: ansistring): ansistring;
Var
  SendData: ansistring;
  Rtn: TTCPTransactionTypes;
  KeyTxt: ansistring;

begin
  if not CheckConnection then
    Exit;
  Result := 'BooHoo';
  SendData := PackTransaction(cReturnEcho + AData, FRandomKey);
  SendTransaction(SendData, Rtn, KeyTxt, Result);
  if KeyTxt <> cReturnEcho then
    raise EExceptionIsComsNotExpected.Create('KeyTxt:' + KeyTxt + '<>' +
      cReturnEcho);
  if GlobalTCPLogAllData then
    ISIndyUtilsException(Self, '#' + ' Echo Data= ' + Result);
end;

procedure TISIndyTCPClient.FreeOldSocket(Sender: TObject);
Var
  SType: string;
begin
  Try
    if Sender Is TObject then
      SType := Sender.ClassName
    Else
      SType := 'Null Object';

    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, '#' + 'FreeOldSocket ' + SType + '>>'
        + TextID);

    if Sender <> nil then
      if (Sender = FConnection) Or (Sender = FIOHandler) Or
        (Sender = fIdTCPClientCon) then
      Begin
        ISIndyUtilsException(Self, 'FreeOldSocket closing Existing');
        if FConnection is TIsTrackIdTCPClientConnection then
          TIsTrackIdTCPClientConnection(FConnection).FOwnerTCPBase := nil;
        FConnection := nil;
        FIOHandler := nil;
        if fIdTCPClientCon <> nil then
        begin
          fIdTCPClientCon.OnDisconnected := nil;
          fIdTCPClientCon := nil;
        end;
        Free;
        Exit;
      End;

    if (Sender is TIdIOHandler) or (Sender is TIdTCPConnection) then
      Try
        Sender.Free
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, 'FreeOldSocket Sender.Free' + SType);
      End
    else
      ISIndyUtilsException(Self, 'FreeOldSocket Bad Type:=' + SType);
  Except
    On E: Exception Do
      ISIndyUtilsException(Self, E, 'FreeOldSocket ' + SType);
  End;
end;

function TISIndyTCPClient.GetActive: boolean;
begin
  Try
    Result := false;
    if (fIdTCPClientCon <> nil) and (fIdTCPClientCon.IOHandler <> nil) then
      Result := fIdTCPClientCon.Connected;
  Except
    On E: Exception do
    Begin
      fIdTCPClientCon := nil;
      FConnection := nil;
      Result := false;
      ISIndyUtilsException(Self, E, 'GetActive')
    End;
  End;
end;

function TISIndyTCPClient.IdTCPClientCon(AHost: String; APort: integer)
  : TIdTCPClient;
begin
  if fIdTCPClientCon = nil then
    try
      fIdTCPClientCon := TIsTrackIdTCPClientConnection.Create;
      // TIsTrackIdTCPClientConnection(fIdTCPClientCon).FLogMessage := AddLogMessage;
      fIdTCPClientCon.ReadTimeOut := cTCPClientReadTimeOut;
      fIdTCPClientCon.ConnectTimeout := 1000;
      fIdTCPClientCon.Connect(AHost, APort);
      if fIdTCPClientCon.Connected then
      Begin
        fIdTCPClientCon.ReadTimeOut := cTCPClientReadTimeOut;
        fIdTCPClientCon.ConnectTimeout := 1000 * 30;
        fIdTCPClientCon.OnDisconnected := FreeOldSocket;
      End
      Else
        FreeAndNil(fIdTCPClientCon);
      { Test
        FConnection.Intercept := TIdConnectionIntercept.Create(FConnection);
        FConnection.Intercept.OnSend := WhenSend;
        FConnection.Intercept.OnConnect := WhenConnected;
        FConnection.Intercept.OnReceive := WhenReceive;
        FConnection.Intercept.OnDisconnect := WhenDisConnected;
      }
    Except
      On E: Exception do
      Begin
        ISIndyUtilsException(Self, E, '#IdTCPClientCon Host=' + AHost);
        FreeAndNil(fIdTCPClientCon)
      End;
    end;
  FConnection := fIdTCPClientCon;

  if GlobalTCPLogAllData then
    ISIndyUtilsException(Self, '#' + 'New IdTCPClientCon >> Sessions=' +
      IntToStr(TIsTrackIdTCPClientConnection.CurrentConnections));

  Result := FConnection as TIdTCPClient;
end;

function TISIndyTCPClient.LastError: String;
begin
  Result := FErrorStr;
end;

function TISIndyTCPClient.MakeConnection: boolean;
var
  SPt, ss, s, Key: ansistring;
  Rst: TTCPTransactionTypes;
  StartKeyCode { ,NewKey } : TDateTime;
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
  WS1, WS2: string;
{$ENDIF}
{$ENDIF}
begin
  Try
    FRandomKey := '';
    // ss := TRemoteDb.PersonalityAsTransactionData(Personality) +
    // TRemoteDb.FileNameAsTransactionData(FdbFileName);
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
    // WS2:=ss.Asstring;
{$ENDIF}
{$ENDIF}
{$IFDEF DEBUG}
    StartKeyCode := DebugStartKey;
{$ELSE}
    StartKeyCode := now + 1.56577;
{$ENDIF}
    // TRemoteDb.RecoverStartupKey(ss, FPersonality, NewKey,s);
    ss := cApplicationHandshakeCode;
{$IFDEF FPC}
    uniquestring(ss);
{$ENDIF}
{$IFDEF NEXTGEN}
    Encrypt(ss.Length, pointer(ss), SizeOf(StartKeyCode), @StartKeyCode);
{$ELSE}
    Encrypt(Length(ss), @ss[1], SizeOf(StartKeyCode), @StartKeyCode);
{$ENDIF}
    SPt := cStartConnection + ss;
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
    WS2 := ss.AsString;
    WS1 := SPt.AsString;
{$ENDIF}
{$ENDIF}
    SPt := PackTransaction(SPt, '');
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
    WS2 := SPt.AsString;
{$ENDIF}
{$ENDIF}
    SendTransaction(SPt, Rst, Key, s);

    Result := Key = cStartConnection;
    if s = '' then
      raise EExceptionIsComsNotExpected.Create('No Response From ' + fPeerIP);
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
    WS2 := s.AsString;
{$ENDIF}
{$ENDIF}
    if Rst = NewCon then
    Begin
{$IFDEF NEXTGEN}
      Encrypt(s.Length, pointer(s), SizeOf(StartKeyCode), @StartKeyCode);
{$ELSE}
      Encrypt(Length(s), @s[1], SizeOf(StartKeyCode), @StartKeyCode);
{$ENDIF}
{$IFDEF DEBUG}
{$IFDEF NEXTGEN}
      WS2 := s.AsString;
{$ENDIF}
{$ENDIF}
    End;
    if Rst <> NewCon then
      raise EExceptionIsComsNotExpected.Create(s);

    FNotAuthorized := false;

{$IFDEF NEXTGEN}
    case Char(s[0]) of
{$ELSE}
    case s[1] of
{$ENDIF}
      'E':
        FEncrypted := true;
      'U':
        FNotAuthorized := true;
      'D':
        FEncrypted := false;
    else
      Begin
        s := s + '   Enc:' + FormatDateTime('dd mm yy', StartKeyCode);
        uniquestring(s);
        Raise Exception.Create(s);
      End;
    end; // case

    // LogAMessage('Rx S='+s);

    if not FNotAuthorized then
{$IFDEF NEXTGEN}
      case Char(s[1]) of
{$ELSE}
      case s[2] of
{$ENDIF}
        'F':
          FSecAuthStatus := true;
        'S':
          FSecAuthStatus := false;
      else
        raise EExceptionIsComsNotExpected.Create('Bad Index Response::' + s)
      end; // case
{$IFDEF NEXTGEN}
    if s.Length > 2 then
      FRandomKey := Copy(s, 3, s.Length);
    { First letter =1 }
{$ELSE}
    if Length(s) > 2 then
      FRandomKey := Copy(s, 3, Length(s));
{$ENDIF}
    // LogAMessage('Rx Random Key='+FRandomKey);
    if Result And Assigned(fDoAfterConnection) then
      fDoAfterConnection(Self);
  Except
    On E: Exception do
    Begin
      raise EExceptionIsComsNotExpected.Create('Make Connection::' + E.Message);
    End;
  end;
end;

function TISIndyTCPClient.PutLargeStreamToServer(AStream: Tstream;
  const AServerFileName: ansistring): boolean;
var
  Rtn, Key, Trans: ansistring;
  Sz, NxtBlock: Int64;
  BlockSz, DataSize: Int32;
  DataSent: integer;
  TrnsType: TTCPTransactionTypes;
  NxtData: ansistring;
  // Buffer:PAnsiChar;
begin
  NxtBlock := 0;
  Result := false;
  try
    if AServerFileName = '' then
      Exit;
    if AStream = nil then
      Exit;
    CheckConnection;
    Sz := AStream.Seek(0, soEnd);
    AStream.Seek(0, soFromBeginning);

    BlockSz := cMaxDataChunk;
    DataSize := BlockSz;
    NxtBlock := 0;

{$IFDEF NEXTGEN}
    NxtData.Length := BlockSz;
{$ELSE}
    SetLength(NxtData, BlockSz);
{$ENDIF}
    while NxtBlock < Sz do
    begin
      if DataSize > Sz - NxtBlock then
      Begin
        DataSize := Sz - NxtBlock;
{$IFDEF NEXTGEN}
        NxtData.Length := DataSize;
{$ELSE}
        SetLength(NxtData, DataSize);
{$ENDIF}
      End;
{$IFDEF NEXTGEN}
      NxtData.ReadBytesFrmStrm(AStream, DataSize);
{$ELSE}
      SetLength(NxtData, DataSize);
      AStream.Read(NxtData[1], DataSize);
{$ENDIF}
      Trans := PackTransaction(PutBlockToServerFileTransaction(AServerFileName,
        NxtData, NxtBlock), FRandomKey);
      SendTransaction(Trans, TrnsType, Key, Rtn);
      // DataSize := Length(Rtn);
      DataSent := StrToIntDef(Rtn, 0);
      if DataSent <> DataSize then
        raise Exception.Create('DataSent{' + IntToStr(DataSent) +
          '} <> DataSize{' + IntToStr(DataSize) + '}');
      NxtBlock := NxtBlock + DataSent;
    end;
    Result := true;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'PutLargeStreamToServer >>' +
        AServerFileName + ' Next Block ::' + IntToStr(NxtBlock));
  end;
end;

function TISIndyTCPClient.Reconnect(const ACurrentTransanction
  : ansistring): boolean;
var
  ActiveDataSz, ActiveDataStart: integer;
begin
  Result := false;
  if GblIndyComsInFinalize then
    Exit;

  if fInReconnect then
  Begin
    ISIndyUtilsException(Self, 'Rentering Reconnect ::' + TextID);
    Exit;
  End;
  If FDoNotTryAgainUntil > now Then
    Exit;
  try
    fInReconnect := true;
    FDoNotTryAgainUntil := 0.0;
    if Active then
      Close;
    try
      { Encrypt(Length(s) - 3, @s[4], Length(AEncryptKey), @AEncryptKey[1]);
        Result := CTransactionStart + Txn.a + Txn.b + Txn.c + Txn.d + s + CTransactionEnd; }
      try
{$IFDEF NEXTGEN}
        ActiveDataSz := ACurrentTransanction.Length;
        ActiveDataSz := ActiveDataSz - 3 - 4 - 1 - 1;
        // ActiveDataSz := Length(ACurrentTransanction) - 3 -
        // Length(CTransactionStart) - 4 - Length(CTransactionEnd);
        ActiveDataStart := 4 + 1 + 4;
        // ActiveDataStart := 4 + Length(CTransactionStart) + 4;
        if (ActiveDataSz > 0) and (FRandomKey <> '') then
          Encrypt(ActiveDataSz, pointer(Int64(pointer(ACurrentTransanction)) +
            ActiveDataStart - 1), Length(FRandomKey), pointer(FRandomKey));
{$ELSE}
        ActiveDataSz := Length(ACurrentTransanction) - 3 -
          Length(CTransactionStart) - 4 - Length(CTransactionEnd);
        ActiveDataStart := 4 + Length(CTransactionStart) + 4;
        if (ActiveDataSz > 0) and (FRandomKey <> '') then
          Encrypt(ActiveDataSz, @ACurrentTransanction[ActiveDataStart],
            Length(FRandomKey), @FRandomKey[1]);
{$ENDIF}
      Except
        On E: Exception do
        Begin
          FDoNotTryAgainUntil := now + c30SecondsDateTime;
          ISIndyUtilsException(Self, E, ' Getting new Key:' + TextID);
          Exit;
        End;
      end;
      try
        if not Active then
          Result := Activate
        else
          Result := true;
      Except
        On E: Exception do
        Begin
          FDoNotTryAgainUntil := now + c30SecondsDateTime;
          ISIndyUtilsException(Self, E, ' Activate new Key:' + TextID);
          Exit;
        End;
      end;

      if Not Result then
        FDoNotTryAgainUntil := now + c30SecondsDateTime
      else
        Try
          MakeConnection;
          if (ActiveDataSz > 0) and (FRandomKey <> '') then
{$IFDEF NEXTGEN}
            Encrypt(ActiveDataSz, pointer(Int64(pointer(ACurrentTransanction)) +
              ActiveDataStart - 1), FRandomKey.Length, pointer(FRandomKey));
{$ELSE}
            Encrypt(ActiveDataSz, @ACurrentTransanction[ActiveDataStart],
              Length(FRandomKey), @FRandomKey[1]);
{$ENDIF}
        Except
          On E: Exception do
          begin
            FDoNotTryAgainUntil := now + c30SecondsDateTime;
            ISIndyUtilsException(Self, E, '# Decoding Key::');
            Exit;
          end;
        end;
    finally
      fInReconnect := false;
    end;
  except
    on E: Exception do
    Begin
      FDoNotTryAgainUntil := now + c30SecondsDateTime;
      ISIndyUtilsException(Self, E, '#FDoNotTryAgainUntil ' +
        FormatDateTime('nn:ss.zzz', FDoNotTryAgainUntil));
      WasClosedForcfullyOrGracefully;
      // raise EExceptionIsComsNotExpected.Create('Reconnect Error::' + E.Message);
    End;
  end;
end;

function TISIndyTCPClient.RestartCommsServer: String;
var
  Rtn, Key, Trans: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  If not CheckConnection then
  Begin
    Result := 'Status: No Server Connection' + CRLF + 'To Address:' +
      fServerAddress + ' Port:' + IntToStr(fServerPort);;
    Exit;
  End;

  Trans := PackTransaction(SimpleRemoteAction(cRemoteResetServer), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  Result := Rtn;
end;

{ function TISIndyTCPClient.Read( // ABuffer: Array of Byte;
  var ABuffer: TIdBytes; AClientWait: Integer): Integer;
  Var
  WaitCount: Integer;
  begin
  // Result := FIdTCPCon.Socket.Binding.Receive(ABuffer);
  Result := 0;
  SetLength(ABuffer, 0);
  WaitCount := AClientWait div FIdTCPCon.ReadTimeOut;
  while (Result = 0) and (WaitCount > -1) do
  Try
  Dec(WaitCount);
  { While FIdTCPCon.Socket.InputBuffer.Size < 256 do
  FIdTCPCon.Socket.ReadFromSource(False)

  {
  procedure TIdIOHandler.ReadBytes(var VBuffer: TIdBytes; AByteCount: Integer; AAppend: Boolean = True);
  begin
  Assert(FInputBuffer<>nil);
  if AByteCount > 0 then begin
  // Read from stack until we have enough data
  while FInputBuffer.Size < AByteCount do
  begin
  if ReadFromSource(False) > 0 then
  begin
  if FInputBuffer.Size >= AByteCount then begin
  Break; // we have enough data now
  end;
  end;
  CheckForDisconnect(True, True);
  end;
  FInputBuffer.ExtractToBytes(VBuffer, AByteCount, AAppend);
  end else if AByteCount < 0 then begin
  ReadFromSource(False, ReadTimeout, False);
  CheckForDisconnect(True, True);
  FInputBuffer.ExtractToBytes(VBuffer, -1, AAppend);
  end;
  end;


}{
  FIdTCPCon.Socket.ReadBytes(ABuffer, fMaxTcpBuffRead, true);
  Result := Length(ABuffer);
  Except
  On D:EIdReadTimeout do
  ;
  End;
  end; { }

procedure TISIndyTCPClient.SendTransaction(AData: ansistring;
  out ATrnctType: TTCPTransactionTypes; out AKey, ANewData: ansistring);
begin
  try
    if not Active then
      if not fInReconnect then
        if not Reconnect(AData) then
          Exit;
    inherited;
    // On full Duplex Session Wait until readThread Releases
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E,
        'SendTransaction - Send Remote Transaction');
      if fInReconnect then
        raise EExceptionIsComsNotExpected.Create
          ('SendTransaction - ReEntry in Reconnect::' + E.Message);
    End;
  end;
end;

function TISIndyTCPClient.ServerConnections(AResults: TStrings;
  ARegThisValue: ansistring): boolean;
var
  Rtn, Key, Trans: ansistring;
  Rtns: String;
  TrnsType: TTCPTransactionTypes;
begin
  Result := false;
  If AResults = nil then
    Exit;
  If not CheckConnection then
    Exit;

  Trans := PackTransaction(SimpleRemoteAction('RemoteServerConnections#' +
    ARegThisValue), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  Rtns := Rtn;
  // make it string
  if Rtns <> '' then
    if Pos('|', Rtns) > 1 then
      try
        AResults.Text := Rtns;
        if AResults.Count > 0 then
          Result := true;
      Except
        Result := false;
      end
    Else
      Result := false;
  if not Result then
    AResults.Text := Rtns;
end;

function TISIndyTCPClient.ServerDetails: ansistring;
var
  Rtn, Key, Trans: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  If not CheckConnection then
  Begin
    Result := 'Status: No Server Connection' + CRLF + 'To Address:' +
      fServerAddress + ' Port:' + IntToStr(fServerPort);;
    Exit;
  End;

  Trans := PackTransaction(SimpleRemoteAction('RemoteServerDetails#'),
    FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  Result := Rtn;
end;

function TISIndyTCPClient.ServerDetailTestClose: ansistring;
var
  Rtn, Key, Trans: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  If not CheckConnection then
  Begin
    Result := 'Status: No Server Connection' + CRLF + 'To Address:' +
      fServerAddress + ' Port:' + IntToStr(fServerPort);;
    Exit;
  End;

  Trans := PackTransaction(SimpleRemoteAction('RemoteForceClose#'), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  Result := Rtn;
end;

procedure TISIndyTCPClient.SetActive(const Value: boolean);
begin
  if Value then
  Begin
    Activate;
  End
  Else
    Close;
end;

procedure TISIndyTCPClient.SetAddress(const Value: String);
begin
  if Active then
    Close;
  fServerAddress := Value;
  fPeerIP := Value;
  fCreatedViaStartAccess := false;
  FDoNotTryAgainUntil := 0.0;
end;

procedure TISIndyTCPClient.SetPort(const Value: TIdPort);
begin
  if Active then
    Close;
  fServerPort := Value;
  fPeerPort := Value;
  fCreatedViaStartAccess := false;
  FDoNotTryAgainUntil := 0.0;
end;

function TISIndyTCPClient.SimpleActionExtTransaction(ACommand: ansistring)
  : ansistring;
Var
  SendData: ansistring;
  Rtn: TTCPTransactionTypes;
  KeyTxt: ansistring;

begin
  if not CheckConnection then
  Begin
    Result := '';
    Exit;
  End;

  Result := 'BooHoo';
  SendData := PackTransaction(ACommand, FRandomKey);
  SendTransaction(SendData, Rtn, KeyTxt, Result);
  if KeyTxt <> cSimpleRemoteAction then
  Begin
    LogAMessage('Error ' + KeyTxt + '<>' + cSimpleRemoteAction);
    Result := 'Error ' + KeyTxt + '<>' + cSimpleRemoteAction + ' Data='
      + Result;
  End;
end;

constructor TISIndyTCPClient.StartAccess(const AServerName: String;
  APort: integer; ADoAfterConnection: TISIndyTCPEvent = nil);
begin
  Try
    fCreatedViaStartAccess := true;
    Create;
    fServerAddress := AServerName;
    fServerPort := APort;
    fDoAfterConnection := ADoAfterConnection;

    If (fIdTCPClientCon <> nil) then
    Begin
      ISIndyUtilsException(Self,
        'Startaccess Existing socket<>nil should not happen ' + AServerName +
        ':' + IntToStr(APort));
      If fIdTCPClientCon.Connected then
        fIdTCPClientCon.OnDisconnected := FreeOldSocket
      Else
        WasClosedForcfullyOrGracefully;
    End;

    fIdTCPClientCon := nil;
    MaxTcpBuffRead := MaxTcpBuffer;
    If Reconnect('') Then
    Begin
      If (fIdTCPClientCon <> nil) then
        fIdTCPClientCon.OnDisconnected := FreeOldSocket;
      FErrorStr := '';
    End
    else
    Begin
      FErrorStr := 'Failed to connect to ' + AServerName + ':' +
        IntToStr(APort);
      LogAMessage(FErrorStr);
    End;
    // if Assigned(AOnLogMessage) then
    // OnLogMsg := AOnLogMessage;

    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, '#' + 'Set Access ' + TextID);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'TISIndyTCPClient.StartAccess :: ' + TextID)
  End;
end;

function TISIndyTCPClient.StringTransaction(aString: String): String;
Var
  TrnsType: TTCPTransactionTypes;
  Key, Rtn: ansistring;
begin
  SendTransaction(PackString(aString, FRandomKey), TrnsType, Key, Rtn);
  Case TrnsType of
    MvString:
      Result := RecoverTrnsString(Rtn);
    FlgError:
      Result := 'Error::' + Rtn;
  Else
    Result := 'Error Key=' + Key + ' Message::' + Rtn;
  End;
end;

function TISIndyTCPClient.TextID: String;
begin
  Try
    Result := 'Clt Prt:' + IntToStr(LocalPort) + ' To ' + Address + ':' +
      IntToStr(Port);
  Except
    On E: Exception do
    begin
      Result := 'TextID Exception';
      ISIndyUtilsException(Self, E, 'TISIndyTCPClient.TextID  ' + Result);
    end;
  End;
end;

procedure TISIndyTCPClient.WasClosedForcfullyOrGracefully;
begin
  Try
    Try
      FIOHandler := nil;
      if fIdTCPClientCon <> nil then
        FreeAndNil(fIdTCPClientCon);
    Except
      On E: Exception do
      begin
        ISIndyUtilsException(Self, E,
          'TISIndyTCPClient.WasClosedForcfullyOrGracefully::' + TextID);
        fIdTCPClientCon := nil;
      end;
    End;
    FConnection := fIdTCPClientCon;
  Finally
    inherited;
  End;
end;

{ Test
  procedure TISIndyTCPClient.WhenConnected(ASender: TIdConnectionIntercept);
  Var
  s: PAnsiChar;
  begin
  s := 'ggggg';
  end;

  procedure TISIndyTCPClient.WhenDisConnected(ASender: TIdConnectionIntercept);
  Var
  s: PAnsiChar;
  begin
  s := 'ggggg';
  end;

  procedure TISIndyTCPClient.WhenReceive(ASender: TIdConnectionIntercept;
  var ABuffer: TIdBytes);
  Var
  s: AnsiString;
  begin
  s := BytesToAnsiStringIS(ABuffer);
  end;

  procedure TISIndyTCPClient.WhenSend(ASender: TIdConnectionIntercept;
  var ABuffer: TIdBytes);
  Var
  s: AnsiString;
  begin
  s := BytesToAnsiStringIS(ABuffer);
  end;
  { }

{ FISIndyTCPBase }

procedure TISIndyTCPBase.AddFullDuplexLogMessage(TextID, AMsg: String);
begin
  try
    if fFullDuplex then
    Begin
      If FLoggingListLock.TryEnter then
        Try
          If FFullDupLogList = nil then
            FFullDupLogList := TStringlist.Create;
          If FFullDupLogList.Count < 100 then
            FFullDupLogList.Add(TextID + FormatDateTime(' : ddd hh:nn:ss : ',
              now) + AMsg)
        Finally
          FLoggingListLock.Release;
        End
      Else
        Inc(FLogsMissed);
    end;
  Except
  end;
end;

procedure TISIndyTCPBase.AddLogMessage(TextID, AMsg: String);
begin
  Try
    If FLoggingListLock.TryEnter then
      try
        If FLogList = nil then
          FLogList := TStringlist.Create;
        If FLogList.Count < 100 then
          FLogList.Add(TextID + FormatDateTime(' : ddd hh:nn:ss : ',
            now) + AMsg)
      finally
        FLoggingListLock.Release;
      end
    else
      Inc(FLogsMissed);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, '# AddLogMessage')
  end;
end;

procedure TISIndyTCPBase.ApplicationProcessMessages;
begin
  if (TThread.CurrentThread.ThreadID = MainThreadID) then
    if Assigned(GlobalApplicationProcessMessages) then
      GlobalApplicationProcessMessages;
end;

function TISIndyTCPBase.BindingIsLocal(ABind: TIdSocketHandle): boolean;
Var
  Ip1, IP2, ss: String;
  EndCh, StartCh: PChar;
Const
  Dot: Char = '.';
begin
  Result := false;
  if ABind = nil then
    Exit;
  if ABind.PeerIP = '127.0.0.1' then
    Result := true
  else
  begin
    Ip1 := ABind.IP;
    IP2 := ABind.PeerIP;
    if (Ip1 <> '') and (IP2 <> '') then
    begin
      StartCh := PChar(Ip1);
      EndCh := StrRScan(StartCh, Dot);
      if EndCh <> nil then
      begin
        ss := Copy(Ip1, 1, (EndCh - StartCh));
        Result := Pos(ss, IP2) = 1;
      end;
    end;
  end;
end;

function TISIndyTCPBase.CallOnLocalSubNet: boolean;
begin
  Result := false;
  if FConnection <> nil then
    if FConnection.Socket <> nil then
      Result := BindingIsLocal(FConnection.Socket.Binding)
end;

function TISIndyTCPBase.CheckConnection: boolean;
begin
  if IOHandler <> nil then
    Result := IOHandler.Connected
  Else
    Result := false;
end;

function TISIndyTCPBase.CheckReadBusy: boolean;
begin
  Result := false;
  Dec(FDecReadCount);
  if FDecReadCount < 0 then
  begin
    FDecReadCount := CVLrgeBusy;
    if (FLastReadBusyDate + 1 / 24) < now then
      Result := true;
    FLastReadBusyDate := now;
  end;
end;

function TISIndyTCPBase.CheckWriteBusy: boolean;
begin
  Result := false;
  Dec(FDecWriteCount);
  if FDecWriteCount < 0 then
  begin
    FDecWriteCount := CVLrgeBusy;
    if (FLastWriteBusyDate + 1 / 24) < now then
      Result := true;
    FLastWriteBusyDate := now;
  end;
end;

procedure TISIndyTCPBase.CloseConnection;
begin
  If Assigned(FIOHandler) then
    if FIOHandler.Connected then
      FIOHandler.Close; // Gracefully;
end;

function TISIndyTCPBase.CloseGracefully: boolean;
begin
  Result := false;
  Try
    If FConnection <> nil then
    Begin
      if FIOHandler = FConnection.IOHandler then
        FIOHandler := nil;
      If FConnection.Connected then
      begin
        FConnection.Disconnect(true);
        if GblLogAllChlOpenClose then
          ISIndyUtilsException(Self,
            '#TISIndyTCPBase.CloseGracefully with Connection');
        sleep(1000);
      end;
      FConnection := nil;
    End
    Else if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self,
        '#TISIndyTCPBase.CloseGracefully with nil Connection');
    Result := (IOHandler = nil);

    if IOHandler <> nil then
    begin
      FIOHandler.CloseGracefully;
      FIOHandler := nil;
      Result := true;
    end;

    SetConnection(nil);
    WasClosedForcfullyOrGracefully;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '#TISIndyTCPBase.CloseGracefully');
  End;
End;

constructor TISIndyTCPBase.Create;
begin
  Try
    FClosingTcpSocket := false;
    if Not FConnectionCounted then
    Begin
      Inc(GCountOfConnections);
      Inc(GCountOfHistoricalCons);
      FConnectionCounted := true;
      if Assigned(GlobalCountOfComsObjectTypes) then
        GlobalCountOfComsObjectTypes.CountComsTypes(Self, true);
      FLoggingListLock := TCriticalSection.Create;
    End;
    FDecWriteCount := CVLrgeBusy;
    FDecReadCount := CVLrgeBusy;
    Inherited;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TISIndyTCPBase Create');
  End;
end;

function TISIndyTCPBase.DecodeSafeFileTransferPath(ACmdPlusPath: string)
  : ansistring;
var
  i: integer;
  UnixPath: boolean;

begin
  Result := '';
  if FFileAccessBasePath = '' then
    Exit;

  Result := ACmdPlusPath;

  i := Pos('^', ACmdPlusPath);
  if i > 0 then
    Result := Copy(ACmdPlusPath, i + 1, Length(ACmdPlusPath));

  if Result = '' then
    Exit;

  UnixPath := TPath.PathSeparator = '/';

  if UnixPath then
    Result := StringReplace(Result, '\', '/', [rfReplaceAll])
  else
    Result := StringReplace(Result, '/', '\', [rfReplaceAll]);

  if Pos(ansistring(Lowercase(FFileAccessBasePath)), Lowercase(Result)) = 1 then
    Exit // c:full file name
  else if UnixPath then
  begin
    if (Pos('/mnt/', ACmdPlusPath) > 0) or (Pos('/MNT/', ACmdPlusPath) > 0) or
      (Pos('..', ACmdPlusPath) > 0) or (Pos('./', ACmdPlusPath) > 0)
    { or ?????? (Pos('/', ACmdPlusPath) > 0) }
    then
      raise EExceptionIsComsNotExpected.Create('Illegal Command File Name ::' +
        ACmdPlusPath);
  end
  else if (Pos(':', ACmdPlusPath) > 0) or (Pos('\\', ACmdPlusPath) > 0) or
    (Pos('..', ACmdPlusPath) > 0) or (Pos('>\', ACmdPlusPath) > 0)
  { or ?????? (Pos('/', ACmdPlusPath) > 0) }
  then
    raise EExceptionIsComsNotExpected.Create('Illegal Command File Name ::' +
      ACmdPlusPath);

  if Result <> '' then
    Result := TPath.Combine(FFileAccessBasePath, Result); { }
end;

destructor TISIndyTCPBase.Destroy;
Var
  LOnDestroy: TISIndyTCPEvent;
begin
{$IFDEF Debug}
  if GblLogAllChlOpenClose then
    ISIndyUtilsException(Self, '#' + 'Enter TISIndyTCPBase Destroy >>'
      + TextID);
{$ENDIF}
  try
    try
      LOnDestroy := FOnDestroy;
      FOnDestroy := nil;
      If Assigned(LOnDestroy) then
        LOnDestroy(Self);

      While not FLoggingListLock.TryEnter do
      Begin
        sleep(1000);
        ISIndyUtilsException(Self, '#' + 'FLoggingListLock.TryEnter')
      End;
      Dec(GCountOfConnections);

      if Assigned(GlobalCountOfComsObjectTypes) then
        GlobalCountOfComsObjectTypes.CountComsTypes(Self, false);

      if Assigned(FConnection) then
        FConnection := nil;
      if FOwnsCoupledSession then
        Try
          if FCoupledSession is TISIndyTCPFullDuplexClient then
            FreeAndNilDuplexChannel(pointer(FCoupledSession))
          else
            FreeAndNil(FCoupledSession);
        Except
          On E: Exception do
          begin
            ISIndyUtilsException(Self, E, '#' + 'Destroy FOwnsCoupledSession');
          End;
        End;
{$IFDEF fpc}
{$ELSE}
      // try
      // If Assigned(FIOHandler) then
      // if FIOHandler.InputBuffer <> nil then
      // if FIOHandler.Connected then
      // FIOHandler.Close;
      // Except
      // end;
{$ENDIF}
      FIOHandler := nil;
      FreeAndNil(FFullDupLogList);
      FreeAndNil(FLogList);
      FreeAndNil(FLoggingListLock);
    Except
      On E: Exception do
      begin
        ISIndyUtilsException(Self, E, '#' + 'TISIndyTCPBase.Destroy');
        FIOHandler := nil;
      end;
    end;
  finally
    inherited;
  end;
  // NOTHING OWNED HERE???
end;

function TISIndyTCPBase.DoFullDuplexIncomingAction(AData: ansistring): boolean;
Var
  Rtn, ErrorMsg: ansistring;

begin
  ErrorMsg := '';

  if AData <> '' then
    FLastDuplexTime := FLastIncoming + cDuplexInactiveTime;
  Try
    if Assigned(FCoupledSession) then
      FCoupledSession.FullDuplexDispatch(AData, '')
    else if Assigned(FOnAnsiStringAction) then
    begin
      FLastData := AData;
      if FSynchronizeResults then
        SyncReturn(SyncDuplxAction)
      Else
      Begin
        Rtn := FOnAnsiStringAction(FLastData, Self);
        if Rtn <> '' then
          if FullDuplexDispatch(Rtn, '') then
          begin
            if GlobalTCPLogAllData then
              ISIndyUtilsException(Self,
                '# DoFullDuplexIncomingAction Replied with>>' + Rtn);
          end
          Else
          Begin
            ErrorMsg := 'Error in response>>' + Rtn;
            ISIndyUtilsException(Self, '#' + ErrorMsg);
          End;
      End;
    end
    Else
      ErrorMsg := 'No Support for DoFullDuplexIncomingAction';
  Except
    On E: Exception do
    Begin
      ErrorMsg := 'Exception DoFullDuplexIncomingAction::' + E.Message;
      ISIndyUtilsException(Self, '#DoFullDuplexIncomingAction:' + ErrorMsg);
    End;
  End;
  Result := ErrorMsg = '';
  if Not Result then
    ISIndyUtilsException(Self, '#DoFullDuplexIncomingAction:' + ErrorMsg);
end;

function TISIndyTCPBase.FillBufferWithLeftOver(var ABuffer: TIdBytes): integer;

Var
  LenSv, i, DataCount: integer;
  buffer: TIdBytes;
begin
{$IFDEF NextGen}
  LenSv := FNextTransactionData.Length;
{$ELSE}
  LenSv := Length(FNextTransactionData);
{$ENDIF}
  DataCount := 0;
  buffer := nil;
  Try
    SetLength(ABuffer, (LenSv + DataCount));

    for i := 1 to LenSv do
      ABuffer[i - 1] := Ord(FNextTransactionData[i]);

    FNextTransactionData := '';

    For i := 0 to DataCount - 1 do
      ABuffer[i + LenSv] := buffer[i];
    Result := LenSv + DataCount;
  Except
    On E: Exception do
      raise EExceptionIsComsNotExpected.Create('Error FillBufferWithLeftOver::'
        + E.Message);
  End;
  { Test
    SaveFill(ABuffer, Result);
    { }
end;

function TISIndyTCPBase.FullDuplexDispatch(AData: ansistring; AKey: ansistring
{$IFNDEF NextGen}
  = '' // Not Next Gen
{$ENDIF} ): boolean;
var
  ToSend, Sent: LongInt;
  DataToGo: ansistring;
  DebugString: String;
begin
  Result := false;
  if Not fFullDuplex then
    SetFullDuplex(true);
  // Non Blocking transaction On full Duplex Session Starts readThread
  if AData <> '' then
    FLastDuplexTime := now + cDuplexInactiveTime;
  // Can send '' as ping
  If FClosedForcfullyOrGracefully then
    Exit;
  try
    if AKey = '' then
      DataToGo := PackTransaction(cFullDuplexMode + AData, FRandomKey)
{$IFDEF NEXTGEN}
    Else if Pos(AKey, AData) = 0 then
{$ELSE}
    Else if Pos(AKey, AData) = 1 then
{$ENDIF}
      DataToGo := PackTransaction(AData, FRandomKey)
    Else
      DataToGo := PackTransaction(AKey + AData, FRandomKey);
{$IFDEF NEXTGEN}
    ToSend := DataToGo.Length;
    DebugString := DataToGo;
{$ELSE}
    ToSend := Length(DataToGo);
{$ENDIF}
    if ToSend = 0 then
      Exit;
    if ToSend > CMaxDuplexPacket then
    Begin
      LogAMessage('Excess Duplex Data');
      raise EExceptionIsComsNotExpected.Create('Exceeds Duplex Data');
    End;

    If FConnection <> nil Then
      if FConnection.Connected then
      Begin
        Sent := Write(DataToGo);
        Result := Sent = ToSend;
        if Not Result then
          raise EExceptionIsExpected.Create('Write=' + IntToStr(Sent) +
            ' <> To Send=' + IntToStr(ToSend));
      End
      Else
      Begin
        ISIndyUtilsException(Self, '#FullDuplexDispatch No Connection');
        FClosedForcfullyOrGracefully := true;
      end;
  Except
    On E: Exception do
    Begin
      ISIndyUtilsException(Self, E, '#FullDuplexDispatch');
      Result := false;
    End;
  end;
end;

function TISIndyTCPBase.GetBlockFromServerFileTransaction(const AFileName
  : ansistring; ABlockStart: Int64; ABlockSz: Int32): ansistring;
var
  BlkStartPtr: ^Int64;
  BlkSzPtr: ^Int32;
  Data: ansistring;
begin
{$IFDEF NEXTGEN}
  Data.Length := 8 { Size(Int64) } + 4 { Size(LongInt) };
  BlkSzPtr := pointer(Data);
  BlkStartPtr := pointer(Int64(pointer(Data)) + 4);
{$ELSE}
  SetLength(Data, 8 { Size(Int64) } + 4 { Size(LongInt) } );
  BlkSzPtr := @Data[1];
  BlkStartPtr := @Data[5];
{$ENDIF}
  BlkStartPtr^ := ABlockStart;
  BlkSzPtr^ := ABlockSz;

  Result := cReadFileTransferBlock + Data + '^' + AFileName;
end;

function TISIndyTCPBase.GetIPRemote: String;
begin
  if fPeerIP = '' then
    RefreshBindingDetails;
  Result := fPeerIP;
end;

function TISIndyTCPBase.GetLocalPort: TIdPort;
begin
  if FPort = 0 then
    RefreshBindingDetails;
  Result := FPort;
end;

function TISIndyTCPBase.GetPort: TIdPort;
begin
  if fPeerPort = 0 then
    RefreshBindingDetails;
  Result := fPeerPort;
end;

function TISIndyTCPBase.IsUploadAcceptTempFile(AFileName: string): boolean;
Var
  Tst: String;
begin
  // Result := false;
  Tst := TPath.Combine(Lowercase(FFileAccessBasePath), 'temp');
  Result := Pos(Tst, Lowercase(AFileName)) = 1;
end;

function TISIndyTCPBase.LocalAddress: ansistring;
begin
  Result := '';
  if FConnection <> nil then
    if FConnection.Socket <> nil then
      Result := FConnection.Socket.Binding.IP;
end;

procedure TISIndyTCPBase.LogAMessage(AMsg: String);
begin
  Try
    if fFullDuplex then
      AddFullDuplexLogMessage(TextID, AMsg)
    else
      AddLogMessage(TextID, AMsg);
    // Log messages may be syncronised causing lock up
    // Else if Assigned(FOnLogMsg) then
    // FOnLogMsg(TextID, AMsg);
    if GlobalTCPLogAllData then
      ISIndyUtilsException(Self, '#' + 'LogAMessage ' + TextID +
        ' Msg:' + AMsg);

  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'LogAMessage ');
  end;
end;

procedure TISIndyTCPBase.LogTimeStampFail(AData: ansistring; AMessage: string);
var
  TmStmp: TTimeRec;
  Delay: TDateTime;
begin
  Delay := now - FLastLoggedTimeStampError;
  if Delay > 24 / 15 then
  // Four Minutes
  Begin
    FLastLoggedTimeStampError := now;
    ISIndyUtilsException(Self, '#LogTimeStampFail >>' + AMessage + '  At' +
      FormatDateTime(' dd/mm/yy hh:nn:ss', now));
    if TmStmp.FromTransString(AData) then
      ISIndyUtilsException(Self, '#LogTimeStampFail >>' + 'Time Data Stamp =' +
        TmStmp.AsString)
    Else
      ISIndyUtilsException(Self, '#LogTimeStampFail >>' +
        'Bad time data >>' + AData);
  end;
end;

function TISIndyTCPBase.PutBlockToServerFileTransaction(const AFileName,
  ADataBlock: ansistring; ABlockStart: Int64): ansistring;
var
  BlkStartPtr: ^Int64;
  BlkSzPtr: ^Int32;
  Data: ansistring;
  BlockSz: Int32;

begin
{$IFDEF NEXTGEN}
  BlockSz := ADataBlock.Length;
  Data.Length := 8 { Size(Int64) } + 4 { Size(LongInt) };
  BlkSzPtr := pointer(Data);
  BlkStartPtr := pointer(Int64(pointer(Data)) + 4);
{$ELSE}
  BlockSz := Length(ADataBlock);
  SetLength(Data, 8 { Size(Int64) } + 4 { Size(LongInt) } );
  BlkSzPtr := @Data[1];
  BlkStartPtr := @Data[5];
{$ENDIF}
  BlkStartPtr^ := ABlockStart;
  BlkSzPtr^ := BlockSz;

  Result := cPutFileTransferBlock + Data + '^' + AFileName + '^' + ADataBlock;
end;

class function TISIndyTCPBase.RawToByteArray(AData: RawByteString): TIdBytes;

Var
  Len, Dif, i: integer;
begin
{$IFDEF NEXTGEN}
  Len := AData.Length;
{$ELSE}
  Len := Length(AData);
{$ENDIF}
  SetLength(Result, Len);
  if Len > 0 then
  Begin
{$IFDEF NEXTGEN}
{$ELSE}
    if Low(AData) > 0 then
      Dif := 1
    else
{$ENDIF}
      Dif := 0;
    for i := 0 to High(Result) do
      Result[i] := Byte(AData[i + Dif]);
  End;
end;

function TISIndyTCPBase.ReadATransactionRecord(var ATrnctType
  : TTCPTransactionTypes; var AKey: ansistring): ansistring;
var
  LengthNewData, NewTransactionStart, WaitForNextResponse, DataCount: integer;
  buffer: TIdBytes;
  TransactionSize: Longword;
  NewData: ansistring;
  ShouldClose: boolean;

begin
  Result := '';
  NewData := '';
  ATrnctType := FlgError;
  { test
    Status := 0;
    OldTransactionData := FNextTransactionData;
    UniqueString(OldTransactionData);
    if OldTransactionData <> '' then
    Status := 4; { /test }
  TransactionSize := 8;
  if fFullDuplex then
    WaitForNextResponse := 1
  else
    WaitForNextResponse := cReadDataWaitCycles;
  // x FReadDataWait
  while (FConnection <> nil) and (FConnection.Connected) and (AKey = '') and
    (WaitForNextResponse > 0) do
    try
      if FNextTransactionData <> '' then
        DataCount := FillBufferWithLeftOver(buffer)
      else
      Begin
        buffer := nil;
        if FConnection = nil then
          raise EExceptionIsComsNotExpected.Create
            ('FConnection.Read FConnection=nil');
        DataCount := ReadOneTransaction(buffer, FReadDataWaitDiv5);
        // FTCPClient knows how much data to expect and will return once read
        // o delay can increase to 25 seconds
        { Test
          if DataCount > 0 then
          SaveBuffers(buffer, DataCount)
          Else
          { test
          Status := -1; { }
      end;
      if DataCount = 0 then
        Dec(WaitForNextResponse)
      else
        try
          if AnsiChar(buffer[0]) <> '<' then
            raise EExceptionIsComsNotExpected.Create
              (' ReadATransactionRecord:: buffer[0]<> < ::Status=');
          // +  inttoStr(Status) + '::' + OldTransactionData);
          // DecodeIndyTCPBaseTransactionStart(buffer, DataCount, TransactionSize, ATrnctType,
          // AKey, NewData);
          DecodeIndyTCPBaseTransStart(buffer, DataCount, TransactionSize,
            AKey, NewData);
          if (AKey = '') then
            AKey := 'Err';
          ATrnctType := DecodeTransactionTCPType(AKey);
          if CheckReadBusy then
            // if GlobalTCPLogAllData then
            ISIndyUtilsException(Self, 'CheckReadBusy Key=' + AKey);

        except
          on E: Exception do
          begin
            NewData := StringFromBuffer(buffer, 0, DataCount);
            AKey := 'Err';
            raise EExceptionIsComsNotExpected.Create
              (E.Message + ' ReadATransactionRecord:: NewData=' + NewData);
          end;
        end;
    except
      on E: Exception do
        Try
          ShouldClose := true;
          if E is EIdReadTimeout then
          Begin
            Dec(WaitForNextResponse);
            ShouldClose := FCloseOnTimeOut and (WaitForNextResponse < 1);
            If ShouldClose then
              if GblRptSrvrTimeoutClear then
              Begin
                LogAMessage('Closing On Timeout:: ' + E.Message);
                ISIndyUtilsException(Self, E, 'Closing On Timeout::' +
                  E.Message);
              end;
          End;
          if ShouldClose then
          Begin
            WaitForNextResponse := 0;
            if GblLogAllChlOpenClose then
            begin
              ISIndyUtilsException(Self, E, '#ReadATransactionRecord');
              LogAMessage('Closing:: ' + E.Message);
            end;
            CloseGracefully;
            if FConnection <> nil then
            Begin
              FConnection.Disconnect;
              FConnection := nil;
            End;
            // AKey := 'Err';
            // ANewData := 'Transaction Fail::' + e.Message;
          end;
        Except
          WaitForNextResponse := 0;
          FConnection := nil;
          ISIndyUtilsException(Self,
            '#ReadATransactionRecord Error In Exception::' + E.Message);
        end;
    end; // While No Transaction

  WaitForNextResponse := 3; // x 5000 ms
{$IFDEF NEXTGEN}
  LengthNewData := NewData.Length;
  NewTransactionStart := TransactionSize + 1;
  if (WaitForNextResponse = 0) or (LengthNewData < TransactionSize + 1) or
    (NewData[TransactionSize] <> CTransactionEnd) then
{$ELSE}
  LengthNewData := Length(NewData);
  NewTransactionStart := TransactionSize + 2;

  if (WaitForNextResponse = 0) or (LengthNewData < TransactionSize + 1) or
    (NewData[TransactionSize + 1] <> CTransactionEnd) then
{$ENDIF}
  begin
    AKey := '';
    NewData := '';
  end
  else
  begin
    If (LengthNewData > TransactionSize + 1) then
      If (NewData[NewTransactionStart] = CTransactionStart) then
        FNextTransactionData := Copy(NewData, NewTransactionStart,
          Length(buffer))
      Else
        FNextTransactionData := Copy(NewData, NewTransactionStart,
          Length(buffer));
{$IFDEF NEXTGEN}
    NewData.Length := TransactionSize;
    { encrypt }
    if (FRandomKey <> '') and (ATrnctType <> FlgError) and (NewData <> '') then
      Encrypt(TransactionSize, pointer(NewData), FRandomKey.Length,
        pointer(FRandomKey));
    { encrypt }
{$ELSE}
    SetLength(NewData, TransactionSize);
    { encrypt }
    if (FRandomKey <> '') and (ATrnctType <> FlgError) and (NewData <> '') then
      Encrypt(TransactionSize, @NewData[1], Length(FRandomKey), @FRandomKey[1]);
    { encrypt }
{$ENDIF}
  end;
  Result := NewData;
end;

function TISIndyTCPBase.ReadFullDuplexLogMessage: String;
begin
  if FFullDupLogList = nil then
    Result := ''
  Else
    Try
      While Not FLoggingListLock.TryEnter do
        sleep(1000);
      Result := FFullDupLogList.Text;
      FFullDupLogList.Clear;
    Finally
      FLoggingListLock.Release;
    End;
end;

function TISIndyTCPBase.ReadLogMessage: String;
begin
  Try
    if FLogList = nil then
      Result := ''
    Else
      Try
        While Not FLoggingListLock.TryEnter do
          sleep(1000);
        Result := FLogList.Text;
        if FLogsMissed > 0 then
          Result := Result + #13#10 + 'Missed msgs=' + IntToStr(FLogsMissed);
        FLogList.Clear;
        FLogsMissed := 0;
      Finally
        FLoggingListLock.Release;
      End;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'ReadLogMessage');

  End;
end;

function TISIndyTCPBase.ReadOneTransaction(var ABuffer: TIdBytes;
  AClientWaitDiv5: integer): integer;
// Wait till data comes in
// Read Transaction Start to get Transaction size
// Read rest of transaction
// If times out without data cycle five times <WaitCount>
// running application process messages on each cycle if main thread

Var
  FullTransactionDataSz: Longword;
  Key, Data: ansistring;
  WaitCount: integer;
  // {$IFDEF DEBUG}
  ss: string;
  // {$ENDIF}
begin
  WaitCount := 5;
  Result := 0;
  while (FConnection <> nil) and (Result = 0) and (WaitCount > 0) do
    Try

{$IFDEF DEBUG}
      ss := BufferAsAnsi(ABuffer);
{$ENDIF}
      // SetLength(ABuffer,0); done by Apend=false in readbytes
      FConnection.Socket.ReadTimeOut := AClientWaitDiv5;
      FConnection.Socket.ReadBytes(ABuffer, MinTransactionSz + 1, false);
      // +1 to get >
      // Exception on Timeout - Try again (5 Times)
      Result := Length(ABuffer);
      if Result < MinTransactionSz + 1 then
        raise EIdReadTimeout.Create('Read Less Than MinTransactionSz::' +
          IntToStr(Result));

{$IFDEF DEBUG}
      ss := BufferAsAnsi(ABuffer);
{$ENDIF}
      DecodeIndyTCPBaseTransStart(ABuffer, Result, FullTransactionDataSz,
        Key, Data);
      if FullTransactionDataSz > 0 then
        FConnection.Socket.ReadBytes(ABuffer, FullTransactionDataSz, true);
{$IFDEF DEBUG}
      ss := BufferAsAnsi(ABuffer);
{$ENDIF}
      Result := Length(ABuffer);
      // FIdTCPCon.Socket.ReadTimeout:=FIdTCPCon.ReadTimeout;
    Except
      On E: Exception do
      begin
        Dec(WaitCount);
        If (TThread.CurrentThread.ThreadID = MainThreadID) then
          ApplicationProcessMessages;
{$IFDEF DEBUG}
        ss := E.Message;
{$ENDIF}
        if E is EIdConnClosedGracefully then
        Begin
          WaitCount := 0;
          WasClosedForcfullyOrGracefully;
        End
        Else if E is EIdReadTimeout then
        Begin
          ss := E.ClassName + '::' + E.Message;
          if (WaitCount < 1) then
            raise; // Else try again
        end
        else if E is EExceptionIsComsNotExpected then
        Begin
          ss := E.ClassName + '::' + E.Message;
          WaitCount := 0;
          WasClosedForcfullyOrGracefully;
        End
        else
        Begin
          ISIndyUtilsException(Self, E, 'ReadOneTransaction::');
          WaitCount := 0;
          WasClosedForcfullyOrGracefully;
        End;
      End;
    end;
  if FConnection = nil then
    WasClosedForcfullyOrGracefully;
end;

function TISIndyTCPBase.RecentData(AGap: TDateTime): boolean;
Var
  Tst: TDateTime;
begin
  Tst := (now - AGap);
  Result := Tst < FLastIncoming;
end;

function TISIndyTCPBase.RecoverTrnsString(AData: ansistring): String;
Var
{$IFDEF NextGen}
  Tst: Char;
{$ELSE}
  Tst: AnsiChar;
{$ENDIF}
  AStr: ansistring;
begin
  Result := '';
  if Length(AData) > 2 then
  Begin
{$IFDEF NextGen}
    Tst := AData[0];
    AStr := Copy(AData, 2, Length(AData));
{$ELSE}
    Tst := AData[1];
    AStr := Copy(AData, 3, Length(AData));
{$ENDIF}
    case Tst of
      'A':
        Result := DeCompressUnicode(AStr);
      'U':
        Result := AnsiAsUnicode(AStr);
    end;
  End;
end;

procedure TISIndyTCPBase.RefreshBindingDetails;
begin
  if FConnection = nil then
    Exit;

  if FConnection.Socket <> nil then
    if FConnection.Socket.Binding <> nil then
    begin
      fPeerIP := FConnection.Socket.Binding.PeerIP;
      FIP := FConnection.Socket.Binding.IP;
      fPeerPort := FConnection.Socket.Binding.PeerPort;
      FPort := FConnection.Socket.Binding.Port;
    end;
end;

function TISIndyTCPBase.RemoteAddress: ansistring;
begin
  Try
    if (FConnection = nil) or (FConnection.IOHandler = nil) then
      Result := 'No Connection'
    else if FConnection.Socket <> nil then
      Result := FConnection.Socket.Binding.PeerIP
    else
      Result := DecodeIpAddress(PAnsiChar(FConnection.IOHandler.Host));

  Except
    On E: Exception do
      Result := 'Exception in RemoteAddress:' + E.Message;
  end;
end;

procedure TISIndyTCPBase.SendTransaction(AData: ansistring;
  out ATrnctType: TTCPTransactionTypes; out AKey, ANewData: ansistring);
// Blocking transaction On full Duplex Session
// SetFullDuplex will
// Will Wait until readThread Releases
var
  ToSend: LongInt;
  ErrorCount: integer;
  SaveDuplex: boolean;
begin
  SaveDuplex := fFullDuplex;
  try
    Try
      if SaveDuplex then
        SetFullDuplex(false);
      // On full Duplex Client Session
      // SetFullDuplex will
      // Wait until readThread Releases
      FClosedForcfullyOrGracefully := false;
{$IFDEF NEXTGEN}
      ToSend := AData.Length;
{$ELSE}
      ToSend := Length(AData);
{$ENDIF}
      ANewData := '';
      AKey := '';
      if ToSend = 0 then
        Exit;
      // ReadLoopCount: Integer;
      ErrorCount := 5;
      while (ANewData = '') and (AKey = '') and (ErrorCount > 0) and
        (FConnection <> nil) do
        try
          if FConnection = nil then
            ErrorCount := 0
          else if Not FConnection.Connected then
            ErrorCount := 0
          Else If (Write(AData) <> ToSend) then
            Dec(ErrorCount)
          Else
          begin
            ANewData := ReadATransactionRecord(ATrnctType, AKey);
            if ATrnctType <> FlgError then
              FLastIncoming := now;
            If ANewData = '' then
              if FClosedForcfullyOrGracefully then
                Exit
              Else
                Dec(ErrorCount);
          end;
        except
          on E: Exception do
          begin
            ISIndyUtilsException(Self, E,
              'Error SendTransaction - Send Remote Transaction::');
            Dec(ErrorCount);
            if (ErrorCount < 1) then
              raise EExceptionIsComsNotExpected.Create
                ('SendTransaction - Send Remote Transaction::' + E.Message);

          end;
        end;
    except
      on E: Exception do
        raise EExceptionIsComsNotExpected.Create('Send Remote Transaction::' +
          E.Message);
    end;
  finally
    if SaveDuplex then
      SetFullDuplex(true);
  end;
  if ATrnctType = FlgError then
    LogAMessage('Error Return:' + AData);
end;

procedure TISIndyTCPBase.SetAddress(const Value: String);
begin
  fPeerIP := Value;
end;

procedure TISIndyTCPBase.SetConnection(AConnection: TIdTCPConnection);
begin
  if FConnection <> AConnection then
  Begin
    If (AConnection is TIsTrackIdTCPClientConnection) or
      (FConnection is TIsTrackIdTCPClientConnection) then
      FreeAndNil(FConnection)
    else
      FConnection := nil;
    // Probably owned by a server
    FIOHandler := nil;
  End;

  FConnection := AConnection;
  if FConnection = nil then
    Exit;

  FIOHandler := FConnection.IOHandler;
  RefreshBindingDetails;
end;

procedure TISIndyTCPBase.SetFileAccessBasePath(const Value: String);
Var
  s: String;
begin
  if Value = '' then
    FFileAccessBasePath := ''
  else
  Begin
    s := TPath.GetFullPath(Value);
    FFileAccessBasePath := s;
  end;
end;

procedure TISIndyTCPBase.SetFullDuplex(Val: boolean);
begin
  // No Action
end;

procedure TISIndyTCPBase.SetPort(const Value: TIdPort);
begin
  fPeerPort := Value;
end;

function TISIndyTCPBase.SimpleRemoteAction(const AFunction: ansistring)
  : ansistring;
begin
  Result := cSimpleRemoteAction + AFunction;
end;

Class function TISIndyTCPBase.StreamAsString(AStrm: Tstream): ansistring;
var
  Sz: Int64;
  st: LongInt;
  Rptr: PAnsiChar;
begin
  Result := '';
  if AStrm = nil then
    Exit;

  AStrm.Seek(LongInt(0), soFromBeginning);
  Sz := AStrm.Size;
  // if Sz > 2000000000 then
  // raise EExceptionIsComsNotExpected.Create('StreamAsString');
  // if Sz > 20000000 then
  // raise EExceptionIsComsNotExpected.Create('StreamAsString 20 Meg Limit');
  if Sz > 30000050 then // CurrentMax Block Size
    raise EExceptionIsComsNotExpected.Create('StreamAsString 30 Meg Limit');
{$IFDEF NextGen}
  Result.ReadBytesFrmStrm(AStrm, Sz);
{$ELSE}
  SetLength(Result, Sz);
  Rptr := PAnsiChar(Result);
  st := Sz;
  st := AStrm.Read(Rptr[0], st);
  if st < Sz then
    SetLength(Result, st);
{$ENDIF}
end;

procedure TISIndyTCPBase.SyncDuplxAction;
Var
  Rtn: ansistring;
begin
  if Assigned(FOnAnsiStringAction) then
    Rtn := FOnAnsiStringAction(FLastData, Self)
  else
    Exit;
  if Rtn <> '' then
    if FullDuplexDispatch(Rtn, '') then
    begin
      if GlobalTCPLogAllData then
        ISIndyUtilsException(Self,
          '#' + 'SyncDuplxAction Replied with>>' + Rtn);
    end
    else
    begin
      ISIndyUtilsException(Self,
        '#' + 'SyncDuplxAction Dispatch Fail ::' + Rtn);
      LogAMessage('SyncDuplxAction Dispatch Fail ::' + Rtn);
    end;
end;

procedure TISIndyTCPBase.SyncReturn(AMeathod: TThreadMethod);
Var
  ThisThread: TThread;
begin
  if FClosingTcpSocket then
  Begin
    ISIndyUtilsException(Self, 'SyncReturn FClosingTcpSocket');
    Exit;
  End;
  if IsNotMainThread then
  begin
    // Warning: Do not call Synchronize from
    // within the main thread. This can cause an infinite loop.
    ThisThread := TThread.CurrentThread;
    ThisThread.Synchronize(ThisThread, AMeathod);
  end
  else
    AMeathod;
end;

function TISIndyTCPBase.TextID: String;
begin
  Result := 'Base';
  // Do not like abstract
end;

function TISIndyTCPBase.WaitForData(AWaitTime: integer): boolean;
Var
  LCount, LocalWait: integer;
begin
  Result := false;
  if FConnection = nil then
    Exit;
  if not FConnection.Connected then
    Exit;

  LocalWait := 1;
  if AWaitTime < 1 then
    LCount := 1
  else
  begin
    if AWaitTime < 20 then
      LocalWait := 1
    Else
      LocalWait := 10;
    if LocalWait < 1 then
      LocalWait := 1;
    LCount := AWaitTime div LocalWait;
  end;
  while not Result and (LCount > 0) do
  begin
    Result := not FConnection.IOHandler.InputBufferIsEmpty;
    if not Result then
    begin
      sleep(LocalWait);
      TIdAntiFreezeBase.DoProcess;
    end;
    Dec(LCount);
  end;
end;

procedure TISIndyTCPBase.WasClosedForcfullyOrGracefully;
begin
  Try
    If FConnection <> nil then
    Begin
      if FIOHandler = FConnection.IOHandler then
        FIOHandler := nil;
      If FConnection.Connected then
        FConnection.Disconnect(false);
      FConnection := nil;
      sleep(1000);
    End
    else
    Begin
      if GblLogAllChlOpenClose then
        ISIndyUtilsException(Self,
          TextID + '#FConnection = nil in Close Gracfully');
    end;

    // if FIOHandler <> nil then
    // begin
    // FIOHandler.CloseGracefully;
    // FIOHandler := nil;
    // end;
    SetConnection(FConnection);
    FClosedForcfullyOrGracefully := true;
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self,
        TextID + ' # TISIndyTCPBase.WasClosedForcfullyOrGracefully');
  Except
    on E: Exception do
    begin
      ISIndyUtilsException(Self, E,
        '#TISIndyTCPBase.WasClosedForcfullyOrGracefully');
      FIOHandler := nil;
      FConnection := nil;
    end;
  end;
end;

procedure TISIndyTCPBase.WorkBeginEvent(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  if ASender = FConnection then // set breakpoints
    case AWorkMode of
      wmRead:
        ;
      wmWrite:
        ;
    end;
end;

// Activates Work Action Functions where you can set breakpoints for this specific object
procedure TISIndyTCPBase.WorkEnableBeginActionEndBreakpoints;
begin
  if FConnection = nil then
    Exit;
  Try
    FConnection.OnWorkBegin := WorkBeginEvent;
    FConnection.OnWork := WorkEvent;
    FConnection.OnWorkEnd := WorkEndEvent;
  Except
  End;
end;

procedure TISIndyTCPBase.WorkEndEvent(ASender: TObject; AWorkMode: TWorkMode);
begin
  if ASender = FConnection then
    // set breakpoints
    case AWorkMode of
      wmRead:
        ;
      wmWrite:
        ;
    end;
end;

procedure TISIndyTCPBase.WorkEvent(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if ASender = FConnection then // set breakpoints
    case AWorkMode of
      wmRead:
        ;
      wmWrite:
        ;
    end;
end;

function TISIndyTCPBase.Write(AData: RawByteString): integer;
Var
  LBuffer: TIdBytes;
  LLen: integer;
begin
  Result := 0;
  LBuffer := RawToByteArray(AData);
  LLen := Length(LBuffer);
  if LLen > 0 then
    Try
      if IOHandler <> nil then
      Begin
        If IOHandler.Connected then
          IOHandler.WriteDirect(LBuffer, LLen, 0)
        else
          LLen := 0;
      end
      else if FConnection <> nil then
        If (FConnection.IOHandler <> nil) and FConnection.IOHandler.Connected
        then
          FConnection.IOHandler.WriteDirect(LBuffer, LLen, 0)
        else
          LLen := 0;
      Result := LLen;
      If CheckWriteBusy Then
        if GlobalTCPLogAllData then
          ISIndyUtilsException(Self, '#Write more than ' + IntToStr(CVLrgeBusy)
            + ' per hour ' + TextID + ' Data =' + AData)
        else
          ISIndyUtilsException(Self, '#Write more than ' + IntToStr(CVLrgeBusy)
            + ' per hour ' + TextID);
    Except
      On E: Exception do
      Begin
        if E is EIdConnClosedGracefully then
          WasClosedForcfullyOrGracefully
        Else
          ISIndyUtilsException(Self, E, '#TISIndyTCPBase.Write');
        Result := 0;
      End;
    End;
end;

{$IFDEF NextGen}

// Remote Transaction Keys 3 Chars as functions
Function cBuildIndexTransaction: ansistring;
Begin
  Result := 'Bit';
end;

Function cBuildNewLockFileTransaction: ansistring;
Begin
  Result := 'Blt';
end;

Function cClassIndexTransaction: ansistring;
Begin
  Result := 'Cit';
end;

Function cDeleteIndexObjTransaction: ansistring;
Begin
  Result := 'Dot';
end;

Function cGetTotalObjectsTransaction: ansistring;
Begin
  Result := 'Got';
end;

Function cLoadRegisterObjectTransaction: ansistring;
Begin
  Result := 'Lrt';
end;

Function cLockUnlockIndexTransaction: ansistring;
Begin
  Result := 'Lut';
end;

Function cPopStmTransaction: ansistring;
Begin
  Result := 'Pot';
end;

Function cPutStmTransaction: ansistring;
Begin
  Result := 'Put';
end;

Function cRegisterObjectTransaction: ansistring;
Begin
  Result := 'Rot';
end;

Function cRefreshSupIndexList: ansistring;
Begin
  Result := 'Rst';
end;

Function cStartConnection: ansistring;
Begin
  Result := 'Sct';
end;

Function cPartTransactionData: ansistring;
Begin
  Result := 'Ptd';
end;
// = ;

Function cSaveIndexfileTransaction: ansistring;
Begin
  Result := 'Sit';
end;
// = ;

Function cSimpleRemoteAction: ansistring;
Begin
  Result := 'Smp';
end;
// = ;

Function cReadFileTransferBlock: ansistring;
Begin
  Result := 'FtB';
end;
// = ;

Function cPutFileTransferBlock: ansistring;
Begin
  Result := 'PtB';
end;
// = ;

Function cReturnError: ansistring;
Begin
  Result := 'Err';
end; // = ;

Function cFullDuplexMode: ansistring;
Begin
  Result := 'FDM';
end;
// = ;

Function cMvRawStrm: ansistring;

Begin
  Result := 'MvR';
end; // = ;

Function cMvStr: ansistring;
Begin
  Result := 'Mvs';
end; // = ;

Function cReturnEcho: ansistring;
Begin
  Result := 'Eco';
end; // = ;

Function cLogServerDetails: ansistring;
Begin
  Result := 'Lsd';
end;

Function cNoExistMessage: ansistring; // = ' Does Not Exist'
Begin
  Result := ' Does Not Exist';
end;

Function CLinkClosed: ansistring; // ='|' + 'Closed';
Begin
  Result := '|' + 'Closed'
end;

Function CLinkFree: ansistring; // = '|' + 'Free';
Begin
  Result := '|' + 'Free';
end;

Function CLinkLinked: ansistring; // ='|' + 'Linked';
Begin
  Result := '|' + 'Linked';
end;

Function CRLF: ansistring;
Begin
  Result := #13 + #10;
end;

Function Lf: ansistring;
Begin
  Result := #10;
end;
{$ENDIF}
{$IFDEF FPC}

function SzRecAsString(ASzRec: TTxnSzRecord): ansistring;
begin
  Result := AnsiChar(ASzRec.a) + AnsiChar(ASzRec.b) + AnsiChar(ASzRec.c) +
    AnsiChar(ASzRec.d);
end;

function SzRecFrmChar(aa, ab, ac, ad: AnsiChar): TTxnSzRecord;
begin
  Result.a := Byte(aa);
  Result.b := Byte(ab);
  Result.c := Byte(ac);
  Result.d := Byte(ad);
end;

Function SzRecFrmString(aString: ansistring; AOffset: integer): TTxnSzRecord;
var
  Offset: integer;
begin
  Result.Sz := 0;
{$IFDEF NextGen}
  Offset := AOffset;
  if aString.Length < (4 + Offset) then
    Exit;
{$ELSE}
  Offset := AOffset + 1;
  if Length(aString) < (4 + Offset) then
    Exit;
{$ENDIF}
  Result.a := Byte(aString[Offset]);
  Result.b := Byte(aString[Offset + 1]);
  Result.c := Byte(aString[Offset + 2]);
  Result.d := Byte(aString[Offset + 3]);
end;

{$ELSE}
{ TTxnSzRecord }

function TTxnSzRecord.AsString: ansistring;
begin
  Result := AnsiChar(a) + AnsiChar(b) + AnsiChar(c) + AnsiChar(d);
end;

procedure TTxnSzRecord.FrmChar(aa, ab, ac, ad: AnsiChar);
begin
  a := Byte(aa);
  b := Byte(ab);
  c := Byte(ac);
  d := Byte(ad);
end;

procedure TTxnSzRecord.FrmString(aString: ansistring; AOffset: integer);
var
  Offset: integer;
begin
  Sz := 0;
{$IFDEF NextGen}
  Offset := AOffset;
  if aString.Length < (4 + Offset) then
    Exit;
{$ELSE}
  Offset := AOffset + 1;
  if Length(aString) < (4 + Offset) then
    Exit;
{$ENDIF}
  a := Byte(aString[Offset]);
  b := Byte(aString[Offset + 1]);
  c := Byte(aString[Offset + 2]);
  d := Byte(aString[Offset + 3]);
end;
{$ENDIF}
// { TSmallSzRecord }

// function TSmallSzRecord.AsString: ansistring;
// begin
// Result := AnsiChar(a) + AnsiChar(b);
// end;

procedure Encrypt(ABufferSize: Longword; ABufferPointer: pointer;
  AKeySize: Word; AKeyPointer: pointer);

const
  MaxEnSz = MaxInt;

type
  byte_buffer = record
    one_byte: array [1 .. MaxEnSz] of Byte;
  end;

  buffer_ptr = ^byte_buffer;
var
  i, j: Longword;
{$IFDEF Debug}
  Enc, Dta: array [1 .. 16] of Byte;
{$ENDIF}
begin
  Try
{$IFDEF Debug}
    for i := 1 to 16 do
    Begin
      Dta[i] := buffer_ptr(ABufferPointer)^.one_byte[i];
      Enc[i] := buffer_ptr(AKeyPointer)^.one_byte[i];
    end;
{$ENDIF}
    i := 1;
    j := 1;
    while i <= (ABufferSize) do
    begin
      buffer_ptr(ABufferPointer)^.one_byte[i] :=
        (buffer_ptr(ABufferPointer)^.one_byte[i] xor buffer_ptr(AKeyPointer)
        ^.one_byte[j]);
      // {$EndIf}
      j := j + 1;
      if j > (AKeySize) then
        j := 1;
      i := i + 1;
    end;
{$IFDEF Debug}
    for i := 1 to 16 do
    Begin
      Dta[i] := buffer_ptr(ABufferPointer)^.one_byte[i];
      Enc[i] := buffer_ptr(AKeyPointer)^.one_byte[i];
    end;
{$ENDIF}
  Except
    On E: Exception do
      Raise EExceptionIsComsNotExpected.Create('Encrypt::' + E.Message);
  end;
end;

{ TIsTrackIdTCPConnection }
Var
  GlobalCountOfIDTCPConnections: integer;

constructor TIsTrackIdTCPClientConnection.Create;
begin
  Inc(GlobalCountOfIDTCPConnections);
  Inherited Create;
end;

class function TIsTrackIdTCPClientConnection.CurrentConnections: integer;
begin
  Result := GlobalCountOfIDTCPConnections;
end;

destructor TIsTrackIdTCPClientConnection.Destroy;
Var
  Sd: String;
begin
  Try
    Dec(GlobalCountOfIDTCPConnections);
    if GblLogAllChlOpenClose then
    begin
      if FOwnerTCPBase <> nil then
        Sd := FOwnerTCPBase.TextID
      else If (Socket <> nil) and (Socket.Binding <> nil) then
        Sd := 'Clt Prt:' + IntToStr(Socket.Binding.Port) + ' To ' +
          Socket.Binding.PeerIP + ':' + IntToStr(Socket.Binding.PeerPort)
      else
        Sd := 'No Connection';
      ISIndyUtilsException(Self, '#' + 'Closing<' + Sd + '> Sessions=' +
        IntToStr(GlobalCountOfIDTCPConnections));
    end;
    if FOwnerTCPBase <> nil then
      if FOwnerTCPBase.FConnection = Self then
        FOwnerTCPBase.FConnection := nil;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'Tracked Destroy')
    end;
  End;
  inherited;
end;

// procedure TIsTrackIdTCPClientConnection.LogAMessage(AMsg: ansistring);
// begin
// if Assigned(FLogMessage) then
// FLogMessage('Track Indy Client Log (' + IntToStr(CurrentConnections) +
// ')', AMsg)
// else
// ISIndyUtilsException(Self, 'Track Indy Client Log (' +
// IntToStr(CurrentConnections) + ')   :: ' + AMsg);
// end;

{ TReadThread }

constructor TReadThread.Create;
begin
  Try
    Inc(GlobalThreadCount);
    inherited Create(true);
    FreeOnTerminate := false;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E.Message);
  End;
end;

destructor TReadThread.Destroy;
begin
  Try
    Try
      Dec(GlobalThreadCount);
      if FTCPConnection <> nil then
        FTCPConnection.DropThread(Self);
    Except
      on E: Exception do
        ISIndyUtilsException(Self, E, 'TReadThread.Destroy DropThread');
    End;
    inherited;
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'TReadThread.Destroy');
  End;
end;

procedure TReadThread.Execute;
begin
  try
    while not Terminated do
    begin
      if FTCPConnection = nil then
        Terminate
      Else If not FTCPConnection.ReadLoop then
        Terminate;
      if GblIndyComsInFinalize then
        Terminate;
    end;

    if FTCPConnection <> nil then
      FTCPConnection.DropThread(Self);
    FTCPConnection := nil;
  Except
    on E: Exception do
    begin
      ISIndyUtilsException(Self, E.Message);
      Terminate;
    end;
  End;
end;

{ TISIndyTCPFullDuplexClient }

function TISIndyTCPFullDuplexClient.AddNoWaitSyncCommand
  (ACommand: TNoWaitRtnThrdData): integer;
begin
  Result := FCurrentQueueOfNWRequests;
  if fReleaseThreads then
    Exit;

  // SetFullDuplex(false); not requires
  // On full Duplex Client Session
  // TISIndyTCPBase.SendTransaction Will SetFullDuplex(false)
  // SetFullDuplex will
  // Wait until readThread Releases
  DplxWriteNoWaitCriticalSectionLock.Acquire;
  Try
    if FNoWaitRtnThrdData = nil then
    begin
      FNoWaitRtnThrdData := ACommand;
      FCurrentQueueOfNWRequests := 1;
    end
    else if FNoWaitRtnThrdData is TNoWaitRtnThrdData then
      FCurrentQueueOfNWRequests := TNoWaitRtnThrdData(FNoWaitRtnThrdData)
        .PushNoWait(ACommand)
    else
      ISIndyUtilsException(Self, 'FNoWaitRtnThrdData is NOT TNoWaitRtnThrdData')
  finally
    fDplxWriteNoWaitCriticalSectionLock.Release;
  end;
  Result := FCurrentQueueOfNWRequests;
end;

destructor TISIndyTCPFullDuplexClient.Destroy;
Var
  Count: integer;
begin
  Try
    Try
      fReleaseThreads := true;
      FClosingTcpSocket := true;
      if fDplxWriteNoWaitCriticalSectionLock <> nil then
      begin
        fDplxWriteNoWaitCriticalSectionLock.Acquire;
        Try
          FreeAndNil(FWaiting);
        Finally
          fDplxWriteNoWaitCriticalSectionLock.Release;
        End;
      end;
      Count := 30;
      while (fReadThread <> nil) or (fWriteThread <> nil) do
      Begin
        if fReadThread <> nil then
          if fReadThread.Suspended then
            fReadThread.Resume;
        if fWriteThread <> nil then
          if fWriteThread.Suspended then
            fWriteThread.Resume;

        Dec(Count);
        if Count < 0 then
        Begin
          ISIndyUtilsException(Self, 'Threads not cleared');
          // FreeAndNil(fReadThread);
          // FreeAndNil(fWriteThread);
          fReadThread := nil;
          fWriteThread := nil;
        End
        else
        Begin
          ApplicationProcessMessages;
          sleep(1000);
        End;
      End;
    Finally
      inherited;
    End;
    // fReadThread.Free;
    // fWriteThread.Free;
    FreeAndNil(fDplxReadCriticalSectionLock);
    FreeAndNil(fDplxWriteNoWaitCriticalSectionLock);
  Except
    on E: Exception do
      ISIndyUtilsException(Self, E, 'TISIndyTCPFullDuplexClient.Destroy');
  End;
end;

function TISIndyTCPFullDuplexClient.DoSimpleDuplexRemoteAction
  (ACommand: ansistring): ansistring;
var
{$IFDEF NextGen}
  SnapName: string;
{$ELSE}
  SnapName: ansistring;
{$ENDIF}
begin
  Result := '';
  SnapName := '';
  if Pos(cRemoteServerDropCoupledSession, ACommand) = 1 then
    Result := DropCoupledSession
  else if Assigned(FCoupledSession) then
    FCoupledSession.FullDuplexDispatch(ACommand, cSimpleRemoteAction)
    // else if Pos(cRemoteServerDetails, ACommand) = 1 then
    // Result := ShowServerDetails
  else if Pos(cRemoteSetServerRelay, ACommand) = 1 then
    Result := SetOngoingConnections(ACommand)
  else if Assigned(FOnSimpleDuplexRemoteAction) then
    Result := FOnSimpleDuplexRemoteAction(ACommand, Self)
  else
  begin
    Result := 'No Code For Action::' + ACommand;
    ISIndyUtilsException(Self, 'Sim Rmt: No Code For Action :' + ACommand);
    LogAMessage(Result);
  end;
end;

function TISIndyTCPFullDuplexClient.DplxWriteNoWaitCriticalSectionLock
  : TCriticalSection;
begin
  If fDplxWriteNoWaitCriticalSectionLock = nil then
    fDplxWriteNoWaitCriticalSectionLock := TCriticalSection.Create;
  Result := fDplxWriteNoWaitCriticalSectionLock;
end;

function TISIndyTCPFullDuplexClient.DropAllRemoteSessions: boolean;
var
  Rtn, Key, Trans: ansistring;
  Command: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  Result := false;
  If not CheckConnection then
    Exit;
  Command := cRemoteServerDropCoupledSession;
  Trans := PackTransaction(SimpleRemoteAction(Command), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  if Rtn <> '' then
    Result := not(Pos(ansistring('Fail:'), Trans) = 1);
end;

function TISIndyTCPFullDuplexClient.DropCoupledSession: ansistring;
begin
  Try
    if FCoupledSession <> nil then
    Begin
      if FCoupledSession is TISIndyTCPFullDuplexClient Then
        TISIndyTCPFullDuplexClient(FCoupledSession).DropAllRemoteSessions;

      if FCoupledSession.FCoupledSession = Self then
        if FOwnsCoupledSession then
          FCoupledSession.Free
        Else
          FCoupledSession.FCoupledSession := nil;
    End;
  Except
    On E: Exception do
      LogAMessage('DropCoupledSession::' + E.Message);
  End;
  FCoupledSession := nil;
end;

procedure TISIndyTCPFullDuplexClient.DropThread(AThread: TThread);
begin
  fReleaseThreads := true;
  if AThread = fReadThread then
    fReadThread := nil;
  if AThread = fWriteThread then
    fWriteThread := nil;
  if fReadThread = fWriteThread then // both nil
    try
      if FOffThreadDestroy then
        Destroy;
    Except
      fReleaseThreads := true;
    end;
end;

function TISIndyTCPFullDuplexClient.FullDuplexDispatchNoWait(AData: ansistring;
  AMaxQueue: integer): integer;
begin
  Result := AMaxQueue;
  if fReleaseThreads then
    Exit;

  If TrySetFullDuplex Then
  Begin
    DplxWriteNoWaitCriticalSectionLock.Acquire;
    Try
      if FWaiting <> nil then
        if AMaxQueue > 0 then
          if FCurrentQueueOfRequests > AMaxQueue then
          begin
            FWaiting.Pop(FWaiting).Free;
          end;
      if FWaiting = nil then
      begin
        FWaiting := TWaitData.Create(AData);
        FCurrentQueueOfRequests := 1;
      end
      else
        FCurrentQueueOfRequests := FWaiting.Push(AData);
    Finally
      fDplxWriteNoWaitCriticalSectionLock.Release;
    end;
  End;
  Result := FCurrentQueueOfRequests;
end;

procedure TISIndyTCPFullDuplexClient.LogAMessage(AMsg: String);
begin
  Try
    inherited;
    if Assigned(FOnLogMsg) then
      // For Follow On Sessions
      FOnLogMsg(TextID, AMsg) // must not sync with main thread
    else
      ISIndyUtilsException(Self, TextID + ' >> ' + AMsg);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, AMsg);
  End;
end;

function TISIndyTCPFullDuplexClient.MakeTimeStamp: ansistring;
Var
  TimeRec: TTimeRec;
begin
  TimeRec.SetValue(now);
  Result := TimeRec.TransString;
end;

function TISIndyTCPFullDuplexClient.OffThreadDestroy(DoOnDestroyProcess
  : boolean): boolean;
// Destroy takes some time as threads need to terminate
// Use OffThreadDestroy to take this process outside main thread
// Happens in Rx or TX threads Destroy
var
  LOnDestroy: TISIndyTCPEvent;
  // OnDisconnect
begin
  Result := false;
  try
    if not DoOnDestroyProcess then
    Begin
      // fOnDisconnect := nil;
      FOnDestroy := nil;
    End;

    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, '#' + 'OffThreadDestroy Enter :' + TextID);

    LOnDestroy := FOnDestroy;
    FOnDestroy := nil;

    if Self = nil then
      Exit;

    if not fReleaseThreads and (fReadThread <> nil) then
      Result := true;
    if Result then
      FOffThreadDestroy := true
    else if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, '#' + 'OffThreadDestroy False');

    if Assigned(LOnDestroy) then
      LOnDestroy(Self);
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'OffThreadDestroy');
  end;
end;

procedure TISIndyTCPFullDuplexClient.ProcessAndFreeNwCommand
  (var ACommand: TWaitData);
Var
  RtnNwData, RtnNwKey: ansistring;
  RtnNwTrans: TTCPTransactionTypes;

begin
  Try
    Try
      if ACommand = nil then
        Exit;
      if not Activate then
      begin
        ISIndyUtilsException(Self, 'No Connection ProcessAndFreeNwCommand');
        FreeAndNil(ACommand);
        Exit;
      end;
      if ACommand is TNoWaitRtnThrdData then
        FCurNwCommand := ACommand as TNoWaitRtnThrdData
      else
      Begin
        ISIndyUtilsException(Self, 'Bad Command ProcessAndFreeNwCommand');
        FreeAndNil(ACommand);
        Exit;
      end;
      if FCurNwCommand <> nil then
        if FCurNwCommand.FData <> '' then
          try
            RtnNwKey := ''; // od csimpleaction
            SendTransaction(ACommand.FData, RtnNwTrans, RtnNwKey, RtnNwData);
            FRtnData := RtnNwData;
            FRtnTrnctType := RtnNwTrans;
            FRtnKey := RtnNwKey;
            if Assigned(FCurNwCommand.fNoWaitRtnLst) or
              Assigned(FCurNwCommand.fNoWaitRtnFunctn) then
              If IsNotMainThread Then
                TThread.Synchronize(nil, SyncReturnDuplxCltNW)
              else
                SyncReturnDuplxCltNW;
            FreeAndNil(ACommand);
          except
            On E: Exception do
              ISIndyUtilsException(Self, E, 'ProcessAndFreeNwCommand');
          end;
      FRtnData := '';
      FRtnList := nil;
    Finally
      FCurNwCommand := nil;
      FreeAndNil(ACommand);
    End;
  except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'ProcessAndFreeNwCommand');
  End;
end;

function TISIndyTCPFullDuplexClient.ProcessNonDuplexIncomingTransaction(Trans,
  Key: ansistring; TrnctType: TTCPTransactionTypes): boolean;
Var
  Echo, Rtn, RawRtn: ansistring;
begin
  Result := false;
  if (Assigned(FCoupledSession)) and (TrnctType <> SmpAct) then
  Begin
    Result := FCoupledSession.FullDuplexDispatch(Trans, Key);
  End
  else
    case TrnctType of
      EchoTrans:
        Begin
          FLastIncoming := now;
          Echo := Trans;
          Result := FullDuplexDispatch(Echo, Key);
          if cLogAll then
            LogAMessage('Echo' + Trans + ' Key:' + Key);
        End;
      SmpAct:
        Begin
          FLastIncoming := now;
          if FCoupledSession <> nil then
            Result := true;
          Rtn := DoSimpleDuplexRemoteAction(Trans);
          if Rtn <> '' then
          Begin
            Result := FullDuplexDispatch(Rtn, Key);
            if cLogAll then
              LogAMessage(Trans + '::' + Rtn);
          End
        End;
      RdFileTrfBlk, MvString:
        Begin
          FLastIncoming := now;
          Rtn := 'Full Duplex Rx Does not support Key ' + Key;
          Key := cReturnError;
          Result := FullDuplexDispatch(Rtn, Key);
        End;
      MvRawStrm:
        Begin
          FLastIncoming := now;
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
            Result := true;
          End;
        End;
      FullDuplexMode:
        Begin
          FLastIncoming := now;
          Result := DoFullDuplexIncomingAction(Trans);
          If Not Result then
          Begin
            Key := cReturnError;
            Rtn := 'No OnFullDuplexIncomingAction Function';
            RawRtn := PackTransaction(Key + Rtn, FRandomKey);
            Write(RawRtn);
          End;
        End;
      FlgNull:
        Begin
          FLastIncoming := now;
          if Assigned(FCoupledSession) then
            FCoupledSession.FullDuplexDispatch('', Key); // Forward Null
          Result := true;
        End;
    Else
      Key := cReturnError;
    end;

  if Not Result then
  Begin
    Rtn := 'ProcessNonDuplexIncomingTransaction Rtn False Key = ' + Key;
    Key := cReturnError;
    Result := FullDuplexDispatch(Rtn, Key);
    LogAMessage(Trans + ':ProcessNonDuplexIncomingTransaction Rtn False');
  end;

end;

function TISIndyTCPFullDuplexClient.ReadATransactionRecord(var ATrnctType
  : TTCPTransactionTypes; var AKey: ansistring): ansistring;
begin
  Inc(FLockCount);
  fDplxReadCriticalSectionLock.Acquire;
  Try
    // Done := false;
    Result := Inherited;
    // while ATrnctType = FullDuplexMode do
    // begin
    // DoFullDuplexIncomingAction(Result); // then
    // Result := Inherited;
    // End;
    { while not Done do
      Case ATrnctType of
      FullDuplexMode:
      Begin
      DoFullDuplexIncomingAction(Result);
      Result := Inherited;
      End;
      FlgNull:
      Result := Inherited;
      Else
      Done := true;
      End; }
  Finally
    fDplxReadCriticalSectionLock.Release;
    Dec(FLockCount);
  End;
end;

function TISIndyTCPFullDuplexClient.ReadLoop: boolean;
Var
  TrnctType: TTCPTransactionTypes;
  Key: ansistring;
  Data: ansistring;
  ErrorStr: String;
{$IFDEF Debug}
begin
  FIsDebugchnl := Self = GlobalSelectDebugChn;
{$ELSE}
begin
{$ENDIF}
  Try
    if FOffThreadDestroy then
      fReleaseThreads := true;

    Result := false;
    if not fReleaseThreads then
    begin
      if fFullDuplex then
      // need to send to turn on
      Begin
        Try
          Data := ReadATransactionRecord(TrnctType, Key);
{$IFDEF Debug}
{$IFDEF NextGen}
          ErrorStr := Data;
{$ENDIF}
{$ENDIF}
        Except
          On E: Exception do
          begin
            TrnctType := FlgError;
            ErrorStr := E.Message;
            LogAMessage('Read Data Fail::' + ErrorStr);
            ISIndyUtilsException(Self, E.Message);
            Data := ErrorStr;
          end;
        End;
        Case TrnctType of
          FlgNull:
            Begin
              if GblLogPollActions then
                ISIndyUtilsException(Self, '#FlgNull on ' + TextID);
              FLastIncoming := now;
              If FCoupledSession <> nil then
                FCoupledSession.FullDuplexDispatch('', '');
              sleep(1000);
            End;
          FlgError:
            Begin
              if Data <> '' then
              // No Data OK
              Begin
                ISIndyUtilsException(Self, 'Flag Error::{' + Data + '}');
                ISIndyUtilsException(Self, '#OffThreadDestroy :: Error');
                OffThreadDestroy(true);
                // FreeAndNilDuplexChannel(self);
              End
              else If not RecentData(FPoleInterval * 4) then
                if FPermHold then
                Begin
                  FLastIncoming := now;
                  if GblLogAllChlOpenClose then
                    ISIndyUtilsException(Self, 'No OffThreadDestroy FPermHold');
                End
                else
                begin
                  if GblLogAllChlOpenClose then
                    ISIndyUtilsException(Self,
                      'OffThreadDestroy ::If not RecentData(FPoleInterval * 4)');
                  OffThreadDestroy(true);
                end;
              sleep(1000);
            End;
          FullDuplexMode:
            begin
              FLastIncoming := now;
              Result := DoFullDuplexIncomingAction(Data);
              Exit;
            end;
        Else
          Begin
            FLastIncoming := now; // is not an error
            ProcessNonDuplexIncomingTransaction(Data, Key, TrnctType);
          End;
        End;
      End
      Else
        sleep(1000);
      Result := true;
    end;
  Except
    on E: Exception do
    begin
      ISIndyUtilsException(Self, 'Exception in ReadLoop::' + E.Message);
      Result := false;
      LogAMessage('Exception in ReadLoop::' + E.Message);
    end;
  End;
End;

class function TISIndyTCPFullDuplexClient.RefValueFromConnectionListValue
  (AListValue: String; out IsFree: boolean): ansistring;
Var
  Marker: integer;
begin
  // From AllRegisteredConnections and ConnectionStatusText  in IsIndyTCPApplicationServer
  // FRegisteredAs + '|' + 'Closed'
  Marker := Pos(CLinkFree, ansistring(AListValue));
  if Marker > 1 then
    IsFree := true
  Else
  Begin
    IsFree := false;
    Marker := Pos('|', AListValue);
  End;
  if Marker > 1 then
    Result := Copy(AListValue, 0, Marker - 1)
  Else
    Result := AListValue;
end;

function TISIndyTCPFullDuplexClient.ServerConnectionsNoWait(AResults: TStrings;
  ARegThisValue: ansistring; ARtn: TNoWaitTCPReturn): boolean;
var
  // ThisCmd:TNoWaitRtnThrdData;
  Trans: ansistring;
begin
  Result := false;
  Try
    If AResults = nil then
      Exit;
    If not CheckConnection then
      Exit;

    Trans := PackTransaction(SimpleRemoteAction('RemoteServerConnections#' +
      ARegThisValue), FRandomKey);

    Result := AddNoWaitSyncCommand(TNoWaitRtnThrdData.Create(Trans, ARtn,
      AResults)) > 0;
  Except

  end;
end;

function TISIndyTCPFullDuplexClient.ServerLinkFromConnectionText(AConnectionText
  : string): boolean;
Var
  ref: ansistring;
  IsFree: boolean;
begin
  ref := RefValueFromConnectionListValue(AConnectionText, IsFree);
  if IsFree then
    Result := ServerSetLinkConnection(ref)
  else
    Result := false;
end;

function TISIndyTCPFullDuplexClient.ServerSetFollowonConnection
  (const AServerName: String; APort: integer): boolean;
var
  Rtn, Key, Trans: ansistring;
  Command: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  Result := false;
  If not CheckConnection then
    Exit;
  if AServerName = '' then
    Exit;
  if APort < 1 then
    Exit;

  Command := cRemoteSetServerRelay + cNewIPLink + AServerName + ':' +
    IntToStr(APort);
  Trans := PackTransaction(SimpleRemoteAction(Command), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  if Rtn <> '' then
    Result := not(Pos(ansistring('Fail:'), Trans) = 1);
  if Result then
    SetFullDuplex(true);
end;

function TISIndyTCPFullDuplexClient.ServerSetLinkConnection(ALinkThisValue
  : ansistring): boolean;
var
  Rtn, Key, Trans: ansistring;
  Command: ansistring;
  TrnsType: TTCPTransactionTypes;
begin
  Result := false;
  If not CheckConnection then
  begin
    ISIndyUtilsException(Self, '#' + 'Exit If not CheckConnection then');
    Exit;
  end;
  if ALinkThisValue = '' then
    Exit;

  Command := cRemoteSetServerRelay + cServerLink + ALinkThisValue;

  Trans := PackTransaction(SimpleRemoteAction(Command), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  if Rtn <> '' then
    Result := not(Pos(ansistring('Fail:'), Rtn) = 1);
  // test
  // if Rtn <> '' then
  ISIndyUtilsException(Self, '#' + 'cRemoteSetServerRelay Trn::' + Rtn);

  if Result then
    SetFullDuplex(true)
  else
    ISIndyUtilsException(Self,
      '#' + '!!Failed!! cRemoteSetServerRelay Trn::' + Rtn);;
end;

function TISIndyTCPFullDuplexClient.ServerSetRefConnection(AReferenceValue
  : ansistring): boolean;
var
  Rtn, Key, Trans: ansistring;
  Command: ansistring;
  TrnsType: TTCPTransactionTypes;
  Rslt: integer;
begin
  Result := false;
  If not CheckConnection then
    Exit;
  if AReferenceValue = '' then
    Exit;

  Command := cRemoteServerConnections + AReferenceValue;

  Trans := PackTransaction(SimpleRemoteAction(Command), FRandomKey);
  SendTransaction(Trans, TrnsType, Key, Rtn);
  if Rtn <> '' then
    Rslt := Pos(AReferenceValue, Rtn)
  else
    Rslt := -1;
  Result := Rslt > 0;
  if Result then
    SetFullDuplex(true);
end;

procedure TISIndyTCPFullDuplexClient.SetFullDuplex(Val: boolean);
begin
  if fFullDuplex <> Val then
    if fDplxReadCriticalSectionLock <> nil then
    Begin
      Inc(FLockCount);
      fDplxReadCriticalSectionLock.Acquire;
      // Non Full Duplex thread forced to wait till ReadThread Releases it
      try
        if Val then
          if FNoWaitRtnThrdData <> nil then
            Exit;
        fFullDuplex := Val;
      finally
        fDplxReadCriticalSectionLock.Release;
        Dec(FLockCount);
      end;
    End;
end;

function TISIndyTCPFullDuplexClient.SetOngoingConnections
  (AConnectData: ansistring): ansistring;
Var
  Inx, Tst, ConPort: integer;
  NewCon: TISIndyTCPBase;
  Address, PortStr: ansistring;
  WillOwn: boolean;

begin
  if FCoupledSession <> nil then
    DropCoupledSession;
  Tst := Length(cRemoteSetServerRelay) + 1;
  Result := '';
  if Pos(cRemoteSetServerRelay, AConnectData) <> 1 then
    Exit;
  WillOwn := true;
  NewCon := nil;
  // Inx := Pos(cServerLink, AConnectData);
  // if Inx = Tst then
  // Begin // RemoteServerRelay#SV#Reference From RemoteServerDetails#
  // Address := Copy(AConnectData, Tst + 3, 255);
  // NewCon := Svr.GetRegConnectionFor(Address);
  // End
  // Else
  // Begin
  Inx := Pos(cNewIPLink, AConnectData);
  if Inx = Tst then
    try
      // RemoteServerRelay#IP#Host Address or IP:Port
      Address := Copy(AConnectData, Tst + 3, 255);
      if Address = '' then
        Inx := -1
      else
        Inx := Pos(ansistring(':'), Address);
      if Inx < 6 then
        DropCoupledSession
      else
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
        if (NewCon <> nil) then
          TISIndyTCPFullDuplexClient(NewCon).OnLogMsg := AddLogMessage;
        WillOwn := true;
      End;
    except
      FreeAndNil(NewCon);
    end;
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

procedure TISIndyTCPFullDuplexClient.SetSynchronizeResults
  (const Value: boolean);
begin
  FSynchronizeResults := Value;
end;

constructor TISIndyTCPFullDuplexClient.StartAccess(const AServerName: String;
  APort: integer; ADoAfterConnection: TISIndyTCPEvent = nil);
begin
  fReleaseThreads := false;
  FPoleInterval := 1 / 24 / 60;
  // one minute
  FNextPoll := now + FPoleInterval;
  fDplxReadCriticalSectionLock := TCriticalSection.Create;
  inherited StartAccess(AServerName, APort, ADoAfterConnection);
  fReadThread := TReadThread.Create; // Suspended(true);
  fReadThread.FTCPConnection := Self;
  fReadThread.FreeOnTerminate := true;
  fWriteThread := TWriteThread.Create; // Suspended(true);
  fWriteThread.FTCPConnection := Self;
  fWriteThread.FreeOnTerminate := true;
  FCloseOnTimeOut := false;
  ReadDataWaitDiv5 := 200;
  // ms between read actions Makes 5 attempts before Exiting Read Transaction
  // SetFullDuplex(true);
  FLastIncoming := now;
  SetFullDuplex(true);
  fReadThread.Start;
  fWriteThread.Start;
end;

procedure TISIndyTCPFullDuplexClient.SyncReturnDuplxCltNW;
// Specifically for no wait threads - Always Synced in GUI Applications.
begin
  Try
    if FCurNwCommand = nil then
    Begin
      ISIndyUtilsException(Self, '#' + 'No Command in NW Sync Rtn');
      Exit;
    End;
    if IsNotMainThread then
    Begin
      ISIndyUtilsException(Self,
        '#' + 'IsNotMainThread in SyncReturnDuplxCltNW');
      Exit;
    End;

    if Assigned(FCurNwCommand.fNoWaitRtnLst) then
      FCurNwCommand.fNoWaitRtnLst.Text := FRtnData;
    if Assigned(FCurNwCommand.fNoWaitRtnFunctn) then
      FCurNwCommand.fNoWaitRtnFunctn(Self);
    if GlobalTCPLogAllData then
      ISIndyUtilsException(Self,
        '#' + 'Completed SyncReturnDuplxCltNW NoWait Rtn');
    { }
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'SyncReturnDuplxCltNW');
  End;
end;

function TISIndyTCPFullDuplexClient.TestTimeStamp(APayload: ansistring;
  Atest: integer): boolean;
Var
  TstTmStmp: TTimeRec;
begin
  If TstTmStmp.FromTransString(APayload) then
    Result := TstTmStmp.DelayOfLessThan(Atest)
  else
    Result := false;
end;

function TISIndyTCPFullDuplexClient.TrySetFullDuplex: boolean;
begin
  Result := fFullDuplex;
  if not Result then
    if fDplxReadCriticalSectionLock <> nil then
      if fDplxReadCriticalSectionLock.TryEnter then
        Try
          if FNoWaitRtnThrdData = nil then
            fFullDuplex := true;
        Finally
          fDplxReadCriticalSectionLock.Release;
        end;
  Result := fFullDuplex;
end;

function TISIndyTCPFullDuplexClient.Write(AData: RawByteString): integer;
begin
  Try
    FNextPoll := now + FPoleInterval;
    Result := inherited;
    // if fFullDuplex then
  Except
    On E: Exception do
    begin
      FNextPoll := now + FPoleInterval;
      Result := 0;
      ISIndyUtilsException(ClassName + ' Write', E.Message);
    end;
  End;
end;

function TISIndyTCPFullDuplexClient.WriteLoop: boolean;
Var
  // TrnctType: TTCPTransactionTypes;
  // Key: ansistring;
  // Data: ansistring;
  DoPoll: boolean;
  NxtSend: TWaitData; // TNoWaitRtnThrdData;
  // NxtSimplexSend: TNoWaitRtnThrdData;
{$IFDEF Debug}
  PollLast: TDateTime;
  WS1: string;
{$ENDIF}
begin
  Result := false;
  DoPoll := false;
  if FOffThreadDestroy then
    // Or do we wait till RxLoop Sets fReleaseThreads
    fReleaseThreads := true;

  NxtSend := nil;
{$IFDEF Debug}
  PollLast := FNextPoll;
{$ENDIF}
  Try
    if fReleaseThreads then
      Result := false
    Else
      Try
        Result := true;
        if FNoWaitRtnThrdData <> nil then
        begin
          // SetFullDuplex(false); not requires
          // On full Duplex Client Session
          // TISIndyTCPBase.SendTransaction Will SetFullDuplex(false)
          // SetFullDuplex will
          // Wait until readThread Releases
          Try
            DplxWriteNoWaitCriticalSectionLock.Acquire;
            try
              NxtSend := FNoWaitRtnThrdData.Pop(FNoWaitRtnThrdData)
                as TNoWaitRtnThrdData;
              Dec(FCurrentQueueOfNWRequests);
            finally
              fDplxWriteNoWaitCriticalSectionLock.Release;
            end;

            if NxtSend = nil then
              ISIndyUtilsException(Self, 'NxtSimplexSend=nil in WriteLoop')
{$IFDEF Debug}
            else
              WS1 := NxtSend.FData
{$ENDIF};
            ProcessAndFreeNwCommand(NxtSend);
            DoPoll := false;
          Finally
            SetFullDuplex(true);
          End;
        end
        else if (FWaiting <> nil) then
        begin
          DplxWriteNoWaitCriticalSectionLock.Acquire;
          try
            NxtSend := FWaiting.Pop(FWaiting);
            Dec(FCurrentQueueOfRequests);
          finally
            fDplxWriteNoWaitCriticalSectionLock.Release;
          end;
{$IFDEF Debug}
          WS1 := NxtSend.FData;
{$ENDIF}
          Result := FullDuplexDispatch(NxtSend.FData, cFullDuplexMode);
          FreeAndNil(NxtSend);
          DoPoll := false;
        end
        else

{$IFDEF Debug}
        begin
          DoPoll := now > FNextPoll;
          PollLast := 0.0;
        end;
        If GblLogPollActions Then
          if DoPoll then
          Begin
            WS1 := '      DoPoll on ' + TextID;
            ISIndyUtilsException(Self, '# WriteLoop ' + WS1)
          end;
{$ELSE}
        DoPoll := now > FNextPoll;
{$ENDIF}
        if DoPoll then
          if TrySetFullDuplex then
            Result := FullDuplexDispatch('', '');

        if Result then
        Begin
          if fDplxWriteNoWaitCriticalSectionLock = nil then
          Begin
            sleep(100);
            // ISIndyUtilsException(Self,TextId+'# fDplxWriteNoWaitCriticalSectionLock = nil in loop');
          End
          else
            sleep(5);
        End;
      Except
        On E: Exception Do
        Begin
          if Not Result then
            ISIndyUtilsException(Self, E, '# No Result Write Loop')
          else if DoPoll then
            ISIndyUtilsException(Self, E, '# DoPoll:')
          else
            ISIndyUtilsException(Self, E, '# NoDoPoll');
        End;
      End;
{$IFDEF Debug}
    WS1 := 'PollLast=' + FormatDateTime('hh:nn:ss.zzz', PollLast) +
      'still equal to FNextPoll = ' + FormatDateTime('hh:nn:ss.zzz', FNextPoll);
    if PollLast = FNextPoll then
      ISIndyUtilsException(Self, '# WriteLoop ' + WS1);
{$ENDIF}
  Except
    On E: Exception Do
    Begin
      ISIndyUtilsException(Self, 'Write Loop:' + E.Message);
      Result := false;
    End;
  End;
end;

{ TWriteThread }

procedure TWriteThread.Execute;
begin
  Try
    while not Terminated do
    begin
      if FTCPConnection = nil then
        Terminate
      Else If not FTCPConnection.WriteLoop then
        Terminate;
      if GblIndyComsInFinalize then
        Terminate;
    end;

    if FTCPConnection <> nil then
      FTCPConnection.DropThread(Self);
    FTCPConnection := nil;
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, 'Execute:' + E.Message);
      Terminate;
    end;
  End;
end;

{ TIsMsgBuffer }

procedure TIsMsgBuffer.AddBuffLogMsg(AId, AMsg: String);
begin
  AddBuffMsgStr(AId + ' : ' + AMsg);
end;

procedure TIsMsgBuffer.AddBuffMsgAnsi(AMsg: ansistring);
begin
  AddBuffMsgStr(AMsg);
end;

procedure TIsMsgBuffer.AddBuffMsgStr(AMsg: String);
begin
  FListLock.Acquire;
  try
    FData.Add(AMsg);
  finally
    FListLock.Release;
  end;
end;

constructor TIsMsgBuffer.Create;
begin
  FData := TStringlist.Create;
  FListLock := TCriticalSection.Create;
end;

destructor TIsMsgBuffer.Destroy;
begin
  FData.Free;
  FListLock.Free;
  inherited;
end;

function TIsMsgBuffer.MsgToRead(out AMsg: String; AReadLines: integer): boolean;
begin
  Result := false;
  if (FData = nil) or (FData.Count < 1) then
    Exit;

  Result := true;
  FListLock.Acquire;
  Try
    if AReadLines < 1 then
    Begin
      AMsg := FData.Text;
      FData.Clear;
    End
    else if AReadLines < FData.Count then
      MsgToRead(AMsg, 0)
    else
    Begin
      AMsg := '';
      While AReadLines > 0 do
      begin
        AMsg := AMsg + FData[0];
        FData.Delete(0);
        Dec(AReadLines);
        If AReadLines > 0 then
          AMsg := AMsg + CRLF;
      end;
    end
  Finally
    FListLock.Release;
  End;

end;

{ TWaitData }

constructor TWaitData.Create(AData: ansistring);
begin
  FData := AData;
  Inc(CountWaitData);
  if CountWaitData > 500 then
    raise Exception.Create('CountWaitData>500');
end;

destructor TWaitData.Destroy;
begin
  Dec(CountWaitData);
  FNext.Free;
  inherited;
end;

function TWaitData.Pop(var AListHead: TWaitData): TWaitData;
begin
  Result := Self;
  AListHead := FNext;
  FNext := nil;
end;

function TWaitData.Push(AData: ansistring): integer;
begin
  if FNext = nil then
  begin
    FNext := TWaitData.Create(AData);
    Result := 2;
  end
  else
    Result := FNext.Push(AData) + 1;
end;

{ TNoWaitReturnThread }

function TNoWaitReturnThread.AddNoWaitCommand
  (ACommand: TNoWaitRtnThrdData): integer;
begin
  Result := FCurrentQueueOfNWReqLength;
  Try
    if Terminated then
      Exit;

    FLock.Acquire;
    Try
      if FCommands = nil then
      begin
        FCommands := ACommand;
        FCurrentQueueOfNWReqLength := 1;
      end
      else if FCommands is TNoWaitRtnThrdData then
        FCurrentQueueOfNWReqLength := TNoWaitRtnThrdData(FCommands)
          .PushNoWait(ACommand)
      else
        ISIndyUtilsException(Self,
          'AddNoWaitCommand is NOT TNoWaitRtnThrdData');
      FIdleCount := 0;
    finally
      FLock.Release;
    end;
    Result := FCurrentQueueOfNWReqLength;
    Suspended := false;
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, '# AddNoWaitCommand');
  end;
end;

function TNoWaitReturnThread.ChnlConnectionDetails: String;
begin
  if FTrdTCPClient = nil then
    Result := 'No Connection'
  else
    Result := FTrdTCPClient.TextID;
end;

procedure TNoWaitReturnThread.ChnlTerminating(AObj: TObject);
begin
  if AObj = FTrdTCPClient then
  Begin
    if GblLogAllChlOpenClose then
      ISIndyUtilsException(Self, TextID + '#Client Thread Closing');
    FTrdTCPClient := nil;
  End;
end;

constructor TNoWaitReturnThread.Create(ASrver: String; APort: integer;
  AOnTerminate: TNotifyEvent);
begin
  Inc(CountNoWaitReturnThread);
  if CountNoWaitReturnThread > 500 then
    raise Exception.Create('CountNoWaitReturnThread count Exceeded');

  FLock := TCriticalSection.Create;
  inherited Create(true);
  FSrver := ASrver;
  FPort := APort;
  FTrdTCPClient := nil;
  OnTerminate := AOnTerminate;
  FreeOnTerminate := true;
end;

destructor TNoWaitReturnThread.Destroy;
begin
  try
    if Not Terminated then
      raise EExceptionIsComsNotExpected.Create
        ('TNoWaitReturnThread Expects to be Terminated not Freed');
    if FTrdTCPClient <> nil then
      FTrdTCPClient.OnDestroy := nil;
    FreeAndNil(FTrdTCPClient);
    FreeAndNil(FLock);
    Dec(CountNoWaitReturnThread);
  Except
    On E: Exception do
    begin
      ISIndyUtilsException(Self, E, 'Destroy');
    end;
  end;
  inherited;
end;

procedure TNoWaitReturnThread.Execute;
Var
  LocalCurrentCommand: TNoWaitRtnThrdData;
begin
  while Not Terminated do
    try
      if TrdTCPClient = nil then
      begin
        ISIndyUtilsException(Self, '# Srv=<' + FSrver + ':' + IntToStr(FPort) +
          '> Failed to open');
        Terminate;
      end
      else
      begin
        if FCommands = nil then
        begin
          if Not Terminated then
          FIdleCount := 500;
          LocalCurrentCommand := nil;
        end
        else
        begin
          FLock.Acquire;
          try
            LocalCurrentCommand := FCommands.Pop(FCommands)
              as TNoWaitRtnThrdData;
            FIdleCount := 0;;
          finally
            FLock.Release;
          end;
          If LocalCurrentCommand <> nil then
            ProcessAndFreeCommand(LocalCurrentCommand)
        end;
        if LocalCurrentCommand <> nil then
        Begin
          FreeAndNil(LocalCurrentCommand);
          ISIndyUtilsException(Self, 'Execute Failed to action command');
        End;
      end;
      if GblIndyComsInFinalize then
        Terminate;
      While Not Terminated and (FIdleCount > 0) and (FCommands = nil) do
      begin
        Dec(FIdleCount);
        sleep(500);
        if GblIndyComsInFinalize then
          Terminate;
      end;
      if GblIndyComsInFinalize then
        Terminate;
    Except
      On E: Exception do
      begin
        ISIndyUtilsException(Self, E, 'Execute');
        if GblIndyComsInFinalize then
          Terminate;
      end;
    End;
end;

procedure TNoWaitReturnThread.ProcessAndFreeCommand(var ACommand
  : TNoWaitRtnThrdData);

var
  Resp: ansistring;
  Trn: TTCPTransactionTypes;
  Key { , NewData } : ansistring;

begin
  if ACommand = nil then
    Exit;

  FThreadActive := true;
  Try
    Try
      FLock.Acquire;
      try
        if not TrdTCPClient.Activate then
        Begin
          ISIndyUtilsException(Self, '#Failed to Connect ' + FSrver + ':' +
            IntToStr(FPort));
          FreeAndNil(FTrdTCPClient);
          FreeAndNil(ACommand);
          Exit;
        End;

        if not FTrdTCPClient.Active then
        begin
          FreeAndNil(FTrdTCPClient);
        end;
      finally
        FLock.Release;
      end;

      if FTrdTCPClient <> nil then
      begin
        if ACommand <> nil then
          if ACommand.FData <> '' then
            try
              FRtnFunction := ACommand.fNoWaitRtnFunctn;
              FTrdTCPClient.FRtnList := ACommand.fNoWaitRtnLst;
              Key := '';
              // od csimpleaction
              FTrdTCPClient.SendTransaction(ACommand.FData, Trn, Key, Resp);
              FTrdTCPClient.FRtnData := Resp;
              FTrdTCPClient.FRtnTrnctType := Trn;
              FTrdTCPClient.FRtnKey := Key;
              if Assigned(FTrdTCPClient.FRtnList) or Assigned(FRtnFunction) then
                If IsNotMainThread Then
                  TThread.Synchronize(nil, SyncReturnNW)
                else
                  SyncReturnNW;
              FreeAndNil(ACommand);
            except
              On E: Exception do
                ISIndyUtilsException(Self, E, 'ProcessAndFreeCommand');
            end;
        if FTrdTCPClient <> nil then
        Begin
          FTrdTCPClient.FRtnData := '';
          FTrdTCPClient.FRtnList := nil;
        End;
        if ACommand <> nil then
        begin
          ISIndyUtilsException(Self,
            'ProcessAndFreeCommand did not free command');
          ACommand := nil;
        end;
      end;
    except
      On E: Exception do
        ISIndyUtilsException(Self, E, 'ProcessAndFreeCommand');
    End;
  Finally
    FThreadActive := false;
  End;
end;

function TNoWaitReturnThread.ServerConnectionsNoWait(AResults: TStrings;
  ARegThisValue: ansistring; ARtn: TNoWaitTCPReturn): boolean;
Var
  Trans: ansistring;
  NewCommand: TNoWaitRtnThrdData;
begin
  Result := false;
  FLock.Acquire;
  try
    if TrdTCPClient = nil then
      Exit;
    if FTrdTCPClient.Activate then
      try
        Trans := PackTransaction(FTrdTCPClient.SimpleRemoteAction
          ('RemoteServerConnections#' + ARegThisValue),
          FTrdTCPClient.FRandomKey);

        NewCommand := TNoWaitRtnThrdData.Create(Trans, ARtn, nil);
        NewCommand.fNoWaitRtnFunctn := ARtn;
        NewCommand.fNoWaitRtnLst := AResults;
        Result := AddNoWaitCommand(NewCommand) > 0;
      Except
        On E: Exception do
          ISIndyUtilsException(Self, E, '# ServerDetailsNoWait');
      end;
  finally
    FLock.Release;
  end;
end;

function TNoWaitReturnThread.ServerDetailsNoWait
  (ARtn: TNoWaitTCPReturn): boolean;
Var
  Trans: ansistring;
  NewCommand: TNoWaitRtnThrdData;
begin
  Result := false;
  if TrdTCPClient = nil then
    Exit;
  if FTrdTCPClient.Activate then
    try
      Trans := PackTransaction(FTrdTCPClient.SimpleRemoteAction
        ('RemoteServerDetails#'), FTrdTCPClient.FRandomKey);
      NewCommand := TNoWaitRtnThrdData.Create(Trans, ARtn, nil);
      NewCommand.fNoWaitRtnFunctn := ARtn;
      // NewCommand.fNoWaitRtnLst:=AResults;
      Result := AddNoWaitCommand(NewCommand) > 0;
    Except
      On E: Exception do
        ISIndyUtilsException(Self, E, '# ServerDetailsNoWait');
    end;
end;

procedure TNoWaitReturnThread.SetData(ASrver: String; APort: integer);
begin
  if (ASrver = FSrver) and (APort = FPort) then
    Exit;
  FLock.Acquire;
  Try
    FreeAndNil(FCommands);
    FreeAndNil(FTrdTCPClient);
    FSrver := ASrver;
    FPort := APort;
    TrdTCPClient;
  Finally
    FLock.Release;
  End;
end;


function TNoWaitReturnThread.SimpleActionNoWaitTransaction(ACommand: ansistring;
  ANoWaitRtnLst: TStrings; ARtn: TNoWaitTCPReturn): boolean;
Var
  Trans: ansistring;
  NewCommand: TNoWaitRtnThrdData;
begin
  Result := false;
  if TrdTCPClient = nil then
    Exit;
  if FTrdTCPClient.Activate then
    try
      Trans := PackTransaction(FTrdTCPClient.SimpleRemoteAction(ACommand),
        FTrdTCPClient.FRandomKey);
      NewCommand := TNoWaitRtnThrdData.Create(Trans, ARtn, nil);
      NewCommand.fNoWaitRtnFunctn := ARtn;
      NewCommand.fNoWaitRtnLst := ANoWaitRtnLst;
      Result := AddNoWaitCommand(NewCommand) > 0;
    Except
      On E: Exception do
        ISIndyUtilsException(Self, E, 'SimpleActionNoWaitTransaction');
    end;
end;

procedure TNoWaitReturnThread.SyncReturnNW;
// Specifically for no wait threads - Always Synced in GUI Applications.
begin
  Try
    if FTrdTCPClient = nil then
    Begin
      ISIndyUtilsException(Self, '#' + 'No Clientl Sync Rtn');
      Exit;
    End;

    if IsNotMainThread then
    Begin
      ISIndyUtilsException(Self,
        '#' + 'IsNotMainThread in TISIndyTCPClient.TNoWaitReturnThread.SyncReturnNW');
      Exit;
    End;

    if Assigned(FTrdTCPClient.FRtnList) then
      FTrdTCPClient.FRtnList.Text := FTrdTCPClient.FRtnData;
    if Assigned(FRtnFunction) then
      FRtnFunction(FTrdTCPClient);
    if GlobalTCPLogAllData then
      ISIndyUtilsException(Self, '#' + 'Completed Synced NoWait Rtn');
    { }
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'Sync Rtn');
  End;
end;

procedure TNoWaitReturnThread.TerminatedSet;
begin
  FIdleCount:=0;
  inherited;
end;

function TNoWaitReturnThread.TextID: String;
begin
  Try
    if FTrdTCPClient <> nil then
      Result := FTrdTCPClient.TextID
    Else
      Result := FSrver + ':' + IntToStr(FPort) + ' Not Connected';
  Except
    On E: Exception do
      ISIndyUtilsException(Self, E, 'TextId');
  End;
end;

function TNoWaitReturnThread.TrdTCPClient: TISIndyTCPClient;
Var
  KillClient: boolean;
begin
  FLock.Acquire;
  try
    if FTrdTCPClient <> nil then
    begin
      KillClient := (FTrdTCPClient.fServerAddress <> FSrver) or
        (FTrdTCPClient.fServerPort <> FPort);
      KillClient := KillClient or Not FTrdTCPClient.Activate;
      If KillClient then
      Begin
        FTrdTCPClient.FOnDestroy := nil;
        FTrdTCPClient.CloseGracefully;
        FTrdTCPClient := nil;
      End;
    end;

    If FTrdTCPClient = nil then
      if (FSrver <> '') and (FPort > 15) then
        try
          FTrdTCPClient := TISIndyTCPClient.StartAccess(FSrver, FPort);
          FTrdTCPClient.FOnDestroy := ChnlTerminating;
        Except
          On E: Exception do
          begin
            ISIndyUtilsException(Self, E, 'TrdTCPClient');
            FreeAndNil(FTrdTCPClient);
          end;
        End;
    Result := FTrdTCPClient;
  finally
    FLock.Release;
  end;
end;

{ TTimeRec }

function TTimeRec.AsString: string;
begin
  Result := FormatDateTime('yyyy-mmm-dd hh:mm:ss:zz', FDateTime);
end;

function TTimeRec.DelayOfLessThan(ATestMilliSecs: integer): boolean;
Var
  Delta: integer;
begin
  Delta := DeltaMilliSecs;
  if Delta < 0 then
    Result := false
  else
    Result := Delta < ATestMilliSecs;
end;

function TTimeRec.DeltaMilliSecs: integer;
Var
  SecDbl: Double;
  Time, TimeNow: TDateTime;
begin
  Time := FDateTime;
  if Time < 0.1 then
    Result := -1
  Else
  Begin
    TimeNow := now;
    Time := TimeNow - FDateTime;
    SecDbl := Time;
    if SecDbl < 0 then
      SecDbl := SecDbl;
    SecDbl := SecDbl * 24 * 60 * 60 * 1000;
    Result := Round(SecDbl);
  End;
end;

function TTimeRec.FromTransString(AData: ansistring): boolean;
Var
  i, IStrt, IEnd: integer;
{$IFDEF Nextgen}
  Sd: string;
{$ENDIF}
begin
  Result := false;
  FDateTime := 0.0;
  IStrt := Pos(cStartTimeStamp, AData);
  if IStrt < 1 then
    Exit;

  IStrt := IStrt + Length(cStartTimeStamp) - 1;
  i := 1;

  IEnd := Pos(cEndTimeStamp, AData);
  if (IEnd - IStrt) = 9 then
  begin
{$IFDEF Nextgen}
    Sd := AData;
    Dec(IStrt);
{$ENDIF}
    while i < 9 do
    Begin
      FData[i] := Byte(AData[i + IStrt]);
      Inc(i);
    End;
  end;
  Result := FDateTime > 5;
end;

procedure TTimeRec.SetValue(Val: TDateTime);
begin
  FDateTime := Val;
end;

function TTimeRec.TransString: ansistring;
begin
  Result := cStartTimeStamp + AnsiChar(FData[1]) + AnsiChar(FData[2]) +
    AnsiChar(FData[3]) + AnsiChar(FData[4]) + AnsiChar(FData[5]) +
    AnsiChar(FData[6]) + AnsiChar(FData[7]) + AnsiChar(FData[8]) +
    cEndTimeStamp;
end;

Procedure GblIndyComsObjectFinalize;
Var
  CWait: integer;
  Msg: string;
Begin
  GblIndyComsInFinalize := true;
  GLogISIndyUtilsException := false;
  Try
{$IFDEF Debug}
    CWait := 1;
{$ELSE}
    CWait := 2;

{$ENDIF}
    Msg := '#';
    if GlobalThreadCount > 0 then
      Msg := Msg + IntToStr(GlobalThreadCount) + ' TCP Threads left' + CRLF;
    Msg := Msg + IntToStr(GCountOfConnections) + ' TCP Objects left' + CRLF +
      ' at ' + FormatDateTime('hh:nn:ss', now);

    if GlobalThreadCount > 0 then
      ISIndyUtilsException('Finalization', Msg);

    if GCountOfConnections > 0 then
      sleep(5000);
    // give it time to close gracefully

    if GCountOfConnections > 0 then
    Begin
{$IFDEF MSWINDOWS}
      OutputDebugString(PChar(IntToStr(GCountOfConnections) +
        ' TCP Objects Created but not Destroyed'));
{$ENDIF}
      while ((GCountOfConnections > 0) or (GlobalThreadCount > 0)) And
        (CWait > 0) do
      begin
        Msg := IntToStr(GlobalThreadCount) + ' TCP Threads left' + CRLF +
          IntToStr(GCountOfConnections) + ' TCP Objects left' + CRLF +
          ' 5 Seconds later';
        ISIndyUtilsException('Finalization', '#' + Msg);
        sleep(5000);
{$IFDEF MSWINDOWS}
        OutputDebugString(PChar(IntToStr(GCountOfConnections) +
          'TCP Objects left 5 seconds later'));
        if (GlobalThreadCount > 0) then
          OutputDebugString(PChar(IntToStr(GlobalThreadCount) +
            'TCP Threads left 5 seconds later'));
{$ENDIF}
        Dec(CWait);
      end;
    End;
{$IFDEF MSWINDOWS}
    OutputDebugString(PChar(IntToStr(GCountOfHistoricalCons) +
      'Total TCP Objects Created'));
    if GCountOfConnections < 1 then
      OutputDebugString('All TCP Objects Destroyed')
    Else
      OutputDebugString(PChar(IntToStr(GCountOfConnections) +
        ' TCP Objects Created but not Destroyed'));
    if GlobalThreadCount > 0 then
      OutputDebugString(PChar(IntToStr(GlobalThreadCount) +
        'TCP Threads Created but not Destroyed'));
{$ENDIF}
    Msg := '#';
    if GlobalThreadCount > 0 then
      Msg := Msg + IntToStr(GlobalThreadCount) + ' TCP Threads left' + CRLF;
    if GCountOfConnections > 0 then

      Msg := Msg + ' TCP Threads left' + CRLF + IntToStr(GCountOfConnections) +
        ' TCP Objects left';

    ISIndyUtilsException('Finalization', Msg);
  Except
    on E: Exception do
      ISIndyUtilsException('Finalization', E, '#');
  End;
End;

{ TNoWaitRtnThrdData }

constructor TNoWaitRtnThrdData.Create(ACommand: ansistring;
  ARtn: TNoWaitTCPReturn; ANoWaitRtnLst: TStrings);
begin
  FData := ACommand;
  fNoWaitRtnFunctn := ARtn;
  fNoWaitRtnLst := ANoWaitRtnLst;
end;

function TNoWaitRtnThrdData.Push(AData: ansistring): integer;
begin
  raise Exception.Create('TNoWaitRtnThrdData.Push is illegal');
end;

function TNoWaitRtnThrdData.PushNoWait(ACommand: TNoWaitRtnThrdData): integer;
begin
  Result := 0;
  if ACommand.FNext <> nil then
    raise Exception.Create('TNoWaitRtnThrdData.PushNoWait bad Command');
  if FNext = nil then
  begin
    FNext := ACommand;
    Result := 2;
  end
  else if FNext is TNoWaitRtnThrdData then
    Result := TNoWaitRtnThrdData(FNext).PushNoWait(ACommand) + 1;
end;

Initialization

Finalization

GblIndyComsObjectFinalize;

end.
