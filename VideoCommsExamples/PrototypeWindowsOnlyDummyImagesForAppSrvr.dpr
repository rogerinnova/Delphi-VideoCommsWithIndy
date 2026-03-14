program PrototypeWindowsOnlyDummyImagesForAppSrvr;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmDummyCammeraImages in 'Z:\RogerHome\RepositoryHg\InnovaSolHomeOnSalmon\Delphi Projects\ADUGDemo\TempAdugDemoComms\FmDummyCammeraImages.pas' {FmDummyCamerraForTestingSrvr};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFmDummyCamerraForTestingSrvr, FmDummyCamerraForTestingSrvr);
  Application.Run;
end.
