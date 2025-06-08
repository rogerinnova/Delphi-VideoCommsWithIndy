program VclImageDemo;

uses
  Vcl.Forms,
  FmVCLImageDemo in 'FmVCLImageDemo.pas' {FormVCLImageDemo},
  IsImageManagerVCL in '..\LibraryCode\IsImageManagerVCL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormVCLImageDemo, FormVCLImageDemo);
  Application.Run;
end.
