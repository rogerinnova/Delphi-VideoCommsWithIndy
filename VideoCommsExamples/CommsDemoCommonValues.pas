unit CommsDemoCommonValues;

interface

Uses SysUtils, Classes;

Const
  CServiceListeningPort = 1777; // any value you choose
  CListeningPort = 1559; // any value you choose

  { These ports are available as LocalHost:Port but
    if windows Firewall is active and
    you wish to connect from another machine or
    via the IPAddress
    You need to add the Firewall Rule

    Windows Firewall>
    Advanced Settings>
    inbound rules>
    new rule>
    port>
    TCP and Specific Local Port=1777
    Allow the connection
  }
  CCameraLink =  'CameraPics';
  CDummyCameraLink =  CCameraLink + 'Dummy';

Function TestFileName: string;
Procedure CreateTestFile;

implementation

Uses
{$IFDEF FPC}
  IsLazarusPickup,
{$ELSE}
  System.IOUtils,
{$ENDIF}
  ISProcCl;

Function TestFileName: string;
Var
  FileName: String;
Begin
  FileName := TPath.Combine('TestDir', 'FileTransfer.txt');
  Result := TPath.Combine(ExeFileDirectory, FileName);
End;

Procedure CreateTestFile;
Var
  I: integer;
  FileName: String;
  Strm: TFileStream;
  LineData: AnsiString;
  Data: PAnsiChar;
Begin
  FileName := TestFileName;
  if FileExists(FileName) then
    DeleteFile(FileName)
  Else
    ForceDirectories(ExtractFileDir(FileName));
  Strm := TFileStream.Create(FileName, fmCreate);
  Try
    LineData := 'The Quick Brown Fox Jumps Over The Lazy Dogs Back' + #13#10;
    Data := PAnsiChar(LineData);
    for I := 0 to 50000 do
      Strm.Write(Data[0], Length(LineData));
  Finally
    Strm.Free;
  End;
End;

end.
