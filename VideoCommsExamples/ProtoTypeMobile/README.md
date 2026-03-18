# Prototype Examples Of Mobile Video Communications

This directory contains a demonstration project to generate real or dummy camera images to exercise the sample program VCLApplicationSrver in the directory above. While Mobile "Prototype" demo applications are created as multi platform only the Windows platforms are included. To create an actual mobile application save the project files with a new name in an adjacent directory and then use your "Mobile Enabled" version of Delphi to add the Android platforms.
# Logic

I have long had problems when migrating mobile projects between Delphi versions. Once a mobile platform is included the .dprog file contains lots of information related to the specific versions of Delphi and Android SDK. An AndroidManifest.template.xml file is added to the directory and this is specific to the project and the versions of Delphi and Android SDK.

 Producing a "Prototype" Windows only project file seem to allow project to be Delphi Version independent and enable Mobile versions to be created in parallel directories. Bear in mind the Android manifest file requires a separate directory for each project.     

# Status

PrototypeWindowsOnlyDummyImagesForAppSrvr project is provided to generate Camera images and send them to the Demo Server Application.

When the code is compiled and run on Android devices real camera footage is used. 

On Windows the application uses a dummy test camera as I have not successfully accessed the camera on Windows 11. 
