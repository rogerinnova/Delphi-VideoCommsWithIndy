program Alex64DummyImagesForAppSrvr;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmDummyCammeraImages in '..\FmDummyCammeraImages.pas' {FmDummyCamerraForTestingSrvr},
  CommsDemoCommonValues in '..\CommsDemoCommonValues.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmDummyCamerraForTestingSrvr, FmDummyCamerraForTestingSrvr);
  Application.Run;
end.
