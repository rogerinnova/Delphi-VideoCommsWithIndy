program FMXImageDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmFMXImageDemo in 'FmFMXImageDemo.pas' {TFormFMXImageDemo},
  IsImageManager in '..\LibraryCode\IsImageManager.pas';

{$R *.res}

begin
  Application.Initialize;
{$ifDef Debug}
  System.RandSeed:=0;
{$EndIf}
  Application.CreateForm(TTFormFMXImageDemo, TFormFMXImageDemo);
  Application.Run;
end.
