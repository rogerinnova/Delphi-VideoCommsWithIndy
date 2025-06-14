# Demonstation Applications VCL and FMX 
## Multiple Images Managed on a TPanel 

For a form to present a captured video stream it is necessary to route it to a TImage(VCL) or TImageControl(FMX).
The requirement was to display a variable number of video streams. These two projects demonstrate how 
the creation of two "Manager" objects (One for VCL and one for FMX) enables the required image components
to be managed within a single TPanel applied located on the form layout.

The "manager" creates the required number of TImageControls and then positions then with the panel component.

For FMX TImageControl is a native component while for VCL the library defines a descendant of TImage as 
a TImageControl to enable code written for FMX work with VCL forms.

The individual TImageControls are referenced by an incoming channel to display the video images. 

It is much easier to provide a location  (TPanel) on a form and create and manage a number of images within that panel. 

TImageCntrlManager (FMX) and TImageMngrVCL (VCL) provide this functionality. The Manager will create and allocate a TImageControl on the panel and re-size and relocate all images to fit on he panel.
