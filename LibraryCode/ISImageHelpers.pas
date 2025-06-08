unit ISImageHelpers;

interface

uses
{$IFDEF FPC}
  Graphics, Classes, SysUtils;
{$ELSE}
{$IFDEF UseVCLBITMAP}
    System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage;
{$ELSE}
   only for Vcl ? ? ? ?
{$ENDIF}
{$ENDIF}

Type
  { TVclImageTypeDecode }
  /// <summary>From Helper class for BitmapCodec.</summary>
  TGraphicsClass = Class of TGraphic;

  TVclImageTypeDecode = class
  private type
    TImageData = record
      ObjectType: TGraphicsClass;
      Length: Integer;
      Header: array [0 .. 3] of Byte;
    end;
  public
    /// <summary>Analyzes the header to guess the image format of he given stream.</summary>
    class function GetVclGraphicObjFromStream(AStm: TStream): TGraphic;
  end;
  {$IfDef FPC}
  TPngImage = class(TPortableNetworkGraphic)
  end;

  TMetaFile = class(TGraphic)
  //Dummy

    end;

  {$Endif}

implementation

{ TVclImageTypeDecode }

class function TVclImageTypeDecode.GetVclGraphicObjFromStream(AStm: TStream)
  : TGraphic;
var
  LBuffer: TBytes;
  Rptr: PAnsiChar;
  I: Integer;
const
  MaxImageDataLength = 4;
  ImageData: array [0 .. 6] of TImageData = ((ObjectType: TGraphic;
    { SGIFImageExtension; } Length: 3; Header: (71, 73, 70, 0)),
    // gif                                       G   I   F
    (ObjectType: TBitmap; Length: 2; Header: (66, 77, 0, 0)),
    // bmp                                    B   M
    (ObjectType: TPngImage; { SPNGImageExtension; } Length: 4;
    Header: (137, 80, 78, 71)),
    // png        P    N   G
    (ObjectType: TGraphic; { STIFFImageExtension; } Length: 3;
    Header: (73, 73, 42, 0)),
    // tiff  I    I   *
    (ObjectType: TGraphic; { STIFFImageExtension; } Length: 3;
    Header: (77, 77, 42, 0)),
    // tiff 2 M   M   *
    (ObjectType: TJPEGImage; { SJPGImageExtension; } Length: 4;
    Header: (255, 216, 255, 224)),
    // jpg
    (ObjectType: TJPEGImage; { SJPGImageExtension; } Length: 4;
    Header: (255, 216, 255, 225))
    // jpg (canon)
    // TMetafile  ENHMETA_SIGNATURE = $464D4520;  FDE' ' { Enhanced metafile constants. }
    // TIcon       if not (IconType in [RC3_STOCKICON, RC3_ICON]) then InvalidIcon;
    // TWICImage
    // TPicture.LoadFromStream(Stream: TStream);
    // TWICImage.LoadFromStream(Stream);
    // procedure TJPEGImage.LoadFromStream(Stream: TStream);   VCL.imaging.JPeg
    // TGIFImage.LoadFromStream(Stream: TStream);  Vcl.Imaging.GIFImg;
    // TPngImage.LoadFromStream Vcl.Imaging.pngimage;

    );
begin
  Result := nil;
  SetLength(LBuffer, MaxImageDataLength);
  Rptr:= PAnsiChar(LBuffer);


  AStm.Position := 0;
  try
    if AStm.Read(Rptr[0], MaxImageDataLength) = MaxImageDataLength then
    begin
      for I := Low(ImageData) to High(ImageData) do
      begin
        if (CompareMem(@ImageData[I].Header[0], @LBuffer[0], ImageData[I].Length))
        then
        begin
          Result := ImageData[I].ObjectType.Create;
          Break;
        end;
      end;
    end;
  finally
    AStm.Position := 0;
  end;
end;

end.
