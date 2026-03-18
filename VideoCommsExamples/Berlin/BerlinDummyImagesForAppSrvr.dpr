program BerlinDummyImagesForAppSrvr;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmDummyCammeraImages in '..\FmDummyCammeraImages.pas' {FmDummyCamerraForTestingSrvr};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmDummyCamerraForTestingSrvr, FmDummyCamerraForTestingSrvr);
  Application.Run;
end.
