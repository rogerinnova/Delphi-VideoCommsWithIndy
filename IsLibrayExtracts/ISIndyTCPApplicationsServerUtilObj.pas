unit ISIndyTCPApplicationsServerUtilObj;
{$IFDEF FPC}
{$MODE Delphi}
// {$I InnovaLibDefsLaz.inc}
{$H+}
{$DEFine UseVCLBITMAP}
{$ELSE}
{$I InnovaLibDefs.inc}
{$ENDIF}

interface
 Uses
{$IFDEF MSWINDOWS}
  WinApi.Windows, FMX.Dialogs,
{$ENDIF}
{$IFDEF NextGen}
  IsNextGenPickup,
{$ENDIF}
  Classes, SysUtils, UITypes, DateUtils, SyncObjs,
  IsIndyUtils,
//  IsLogging, ISProcCl,
{$IFDEF FPC}
  Graphics, StdCtrls, ExtCtrls, IsImageManagerVCL,
{$ELSE}
  IoUtils,
{$IFDEF UseVCLBITMAP}
  VCL.Graphics, VCL.StdCtrls, VCL.ExtCtrls,
{$ELSE}
  FMX.Graphics, FMX.StdCtrls,
{$ENDIF}
{$ENDIF}
  ISRemoteConnectionIndyTCPObjs;

  Type
  TAddSrvRef =Procedure (AHost: String; APort: Integer) of Object;

  TCommsServerObj = class(TObject) // ?? TISMultiUserDBRemote
  private
    FOnAddNewServer:TAddSrvRef;
    FServerName: AnsiString;
    FServerPort: Integer;
    FCurrentLinks: TStringlist;
    FOwner: TObject;
  public
    Constructor Create(AOwner: TObject);
    Destructor Destroy; override;
    function ConfirmServer: Boolean;
    function CurrentLinks: TStringlist;
    function ListText: string;
    Procedure SetData(AUrl: string; APort: Integer);
    Procedure SetStdData(AUrl_Port: string);
    class function StdText(ASrv: String; APort: Integer): string;
    Property OnAddNewServer:TAddSrvRef read FOnAddNewServer write FOnAddNewServer;
    Property ServerName:AnsiString read FServerName;
    Property ServerPort:Integer read FServerPort;
  end;

  TCommsServerlist = class(TObject) // singleton
  private
    FlistOfServers: TStringlist; // of TCommsServerObj
    Function GetChkSrv(AServerString: String): TCommsServerObj;
  public
    Class Function GetCheckServer(AServerString: String { Url:port } )
      : TCommsServerObj;
    Class Procedure EndService;
    Constructor Create;
    Destructor Destroy; override;
  end;

Var
  GlbSrverObj: TCommsServerlist;

implementation

{ TCommsServerObj }
function TCommsServerObj.ConfirmServer: Boolean;
Var
  Tst: TISIndyTCPClient;
  SList: TStringlist;
begin
  Result := False;
  Tst := nil;
  Try
    Tst := TISIndyTCPClient.StartAccess(FServerName, FServerPort);
    Try
      Result := Tst.Active;
      if Result then
        try
          SList := TStringlist.Create;
          Tst.ServerConnections(SList, '');
          CurrentLinks.AddStrings(SList);
        finally
          SList.Free;
        end;
    Except
      Result := False;
    End;
  Finally
    Tst.Free;
  End;
  if Result then
    if Assigned(OnAddNewServer) then
      OnAddNewServer (FServerName, FServerPort);
end;

constructor TCommsServerObj.Create(AOwner: TObject);
begin
  if AOwner <> nil then
    if not(AOwner is TCommsServerlist) then
      raise Exception.Create('not (AOwner is TCommsServerlist)');
  inherited Create;

  FOwner := AOwner;
end;

function TCommsServerObj.CurrentLinks: TStringlist;
begin
  if FCurrentLinks = nil then
    FCurrentLinks := TStringlist.Create;
  Result := FCurrentLinks;
end;

destructor TCommsServerObj.Destroy;
begin
  FreeSListWObjects(FCurrentLinks);
  inherited;
end;

function TCommsServerObj.ListText: string;
begin
  Result := StdText(FServerName, FServerPort);
end;

procedure TCommsServerObj.SetData(AUrl: string; APort: Integer);
begin
  FServerName := AUrl;
  FServerPort := APort;
end;

procedure TCommsServerObj.SetStdData(AUrl_Port: string);
Var
  Port, idx: Integer;
  Url, PString: String;
begin
  idx := Pos(':', AUrl_Port);
  if idx < 3 then
    exit;
  PString := Copy(AUrl_Port, idx + 1, 99);
  SetLength(AUrl_Port, idx - 1);
  SetData(AUrl_Port, StrToInt(PString));
end;

class function TCommsServerObj.StdText(ASrv: String; APort: Integer): string;
begin
  Result := LowerCase(trim(ASrv) + ':' + IntToStr(APort));
end;

{ TCommsServerlist }

constructor TCommsServerlist.Create;
begin
  if GlbSrverObj <> nil then
    raise Exception.Create('GlbSrverObj <> nil in TCommsServerlist.Create');
  inherited Create;
  FlistOfServers := TStringlist.Create;
  FlistOfServers.Duplicates := dupError;
  FlistOfServers.Sorted := True;
end;

destructor TCommsServerlist.Destroy;
begin
  if GlbSrverObj = self then
    GlbSrverObj := nil;
  FreeSListWObjects(FlistOfServers);
  inherited;
end;

class procedure TCommsServerlist.EndService;
begin
  GlbSrverObj.Free;
  // Destroy Will Nil The GBL
end;

class function TCommsServerlist.GetCheckServer(AServerString: String)
  : TCommsServerObj;
begin
  if GlbSrverObj = nil then
    GlbSrverObj := TCommsServerlist.Create;
  Result := GlbSrverObj.GetChkSrv(AServerString);
end;

function TCommsServerlist.GetChkSrv(AServerString: String): TCommsServerObj;
Var
  PortStr, Url: String;
  Port, idx: Integer;
  SrvChk: TCommsServerObj;
begin
  Result := nil;
  Url := LowerCase(trim(AServerString));
  idx := Pos(':', Url);
  if idx < 3 then
    raise Exception.Create('Requires <Domain:Port>');
  PortStr := Copy(Url, idx + 1, 255);
  Port := StrToIntDef(PortStr, -1);
  if Port < 1 then
    raise Exception.Create('Requires <Domain:Port>');

  SetLength(Url, idx - 1);
  if not FlistOfServers.Find(TCommsServerObj.StdText(Url, Port), idx) then
  begin
    Try
      SrvChk := TCommsServerObj.Create(self);
      SrvChk.SetData(Url, Port);
      if not SrvChk.ConfirmServer then
        FreeAndNil(SrvChk)
      else
        FlistOfServers.AddObject(SrvChk.ListText, SrvChk);
    Except
      SrvChk := nil;
    End;
  end;
  if FlistOfServers.Find(TCommsServerObj.StdText(Url, Port), idx) then
    Result := FlistOfServers.Objects[idx] as TCommsServerObj;
end;

end.
