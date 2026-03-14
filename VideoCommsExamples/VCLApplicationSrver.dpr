program VCLApplicationSrver;

uses
  {$IFDEF TestFastMM}
  FastMM5 in 'Z:\ThirdPartyGitRepo\FastMM\FastMM5-master\FastMM5.pas',
  {$ENDIF }
  Vcl.Forms,
  FmVCLApplicationSrver in 'FmVCLApplicationSrver.pas' {ServerForm},
  IsIndyTCPApplicationServer in '..\LibraryCode\IsIndyTCPApplicationServer.pas',
  IsIndyUtils in '..\IsLibrayExtracts\IsIndyUtils.pas',
  IsObjectTimeSpanRecording in '..\IsLibrayExtracts\IsObjectTimeSpanRecording.pas';

{$R *.res}

begin
{$IFDEF TestFastMM}
  LoadFastMMfromISLib(True,True,false,false,True);
{$ELSE}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
