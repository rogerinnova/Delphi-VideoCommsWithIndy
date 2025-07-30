unit ServerInitializeCode;

interface

uses
 {$IFDEF NEXTGEN}
  IsNextGenPickup,
 {$EndIF}
  classes, Sysutils, inifiles,IsGblLogCheck;

Procedure CreateInitTextFile(AAdditionalMessage: AnsiString);
Function GeneralIniFileName: String;

implementation

Procedure CreateInitTextFile(AAdditionalMessage: AnsiString);
Var
  TxtFile: TFileStream;
  IniFile: TIniFile;
  LName: String;
  Port: Integer;

  Procedure WriteTxtln(AVal: AnsiString);
  Var
    x: AnsiString;
    Len: Integer;
    Buf:pointer;
  Begin
  x := AVal + #13#10;
  {$IfDef NextGen}
    Len := x.Length;
    Buf:=x;
    TxtFile.Write(Buf, Len);
  {$Else}
    Len := Length(x);
    //PtrX:=x;
    TxtFile.Write(x[1], Len);
  {$Endif}
  End;

begin
  LName := GeneralIniFileName;
  IniFile := TIniFile.Create(LName);
  Try
    LName := ChangeFileExt(LName, '.txt');
    if FileExists(LName) then
      DeleteFile(LName);
    if FileExists(LName) then
      Exit;
    TxtFile := TFileStream.Create(LName, fmCreate);
    Try
      WriteTxtln('Last started ' + FormatDateTime(' dd/mm/yy hh:nn ', now));
      WriteTxtln('Message:: ' + AAdditionalMessage);
      WriteTxtln(ReportLoggingStatus);
      Port := IniFile.ReadInteger('TCP', 'Port', 0);
      if Port > 0 then
        WriteTxtln('Listening on ' + IntToStr(Port));
      WriteTxtln('LogFile:' + IniFile.ReadString('Files', 'Logfilename',
        'no entry'));
      WriteTxtln('CGILogFileName:' + IniFile.ReadString('Files',
        'CGILogFileName', 'no entry'));
      WriteTxtln('DatabaseName:' + IniFile.ReadString('DbForms', 'DatabaseName',
        'no entry'));
      WriteTxtln('DatabaseServer:' + IniFile.ReadString('DbForms',
        'DatabaseServer', 'no entry'));
      Port := IniFile.ReadInteger('DbForms', 'DBServerPort', 0);
      if Port > 0 then
        WriteTxtln('DBServerPort: ' + IntToStr(Port));

      WriteTxtln('CGIEmailServer:' + IniFile.ReadString('EmailServer',
        'CGIEmailServer', 'no entry'));
      WriteTxtln('EmailServer:' + IniFile.ReadString('EmailServer',
        'EmailServer', 'no entry'));
      WriteTxtln('EmailAccount:' + IniFile.ReadString('EmailServer',
        'EmailAccount', 'no entry'));
      WriteTxtln('EmailPassword:' + IniFile.ReadString('EmailServer',
        'EmailPassword', 'no entry'));
      WriteTxtln('EmailEncPassword:' + IniFile.ReadString('EmailServer',
        'EmailEncPassword', 'no entry'));
      if IniFile.ReadBool('EmailServer', 'EmailUseSSL', false) then
        WriteTxtln('EmailUseSSL:' + 'true')
      Else
        WriteTxtln('EmailUseSSL:' + 'False');
      Port := IniFile.ReadInteger('EmailServer', 'SmtpPort', 0);
      if Port > 0 then
        WriteTxtln('EmailServer Port: ' + IntToStr(Port));
    Finally
      TxtFile.Free;
    End;

  Finally
    IniFile.Free;
  End;

end;

Function GeneralIniFileName: String;
Begin
  Result := ChangeFileExt(ParamStr(0), '.ini');
End;

end.
