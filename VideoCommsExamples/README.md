# Examples Of Video Communications

This directory contains some demonstration projects for the Transission Of Video Images Via TCP/IP Using Indy.

# Status

The program VCLApplicationSrver is a single VCL form application which starts up two TIsIndyApplicationServer objects and will run a range of tests/demonstrations to interact with them. The application provides a primary server (Listener) function to enable tests to run within the application and a secondary server for some extended tests. The primary server will not start if another "Service Application" is already listening on the ports. 

PrototypeWindowsOnlyDummyImagesForAppSrvr project is provided to generate Camera images and send them to the Demo Server Application. For reasons explained there it is in a subdirectory "ProtoTypeMobile". It is an FMX project and I have successfully compiled it to run on Android devices in various versions of Delphi. See sub directory ReadMe.

TCPApplicationsDemoService is a Windows service application which provides the primary "Server" component or "Listener" provided in VCLApplicationSrver in a stand alone service application. To install as a Windows service run "TCPApplicationsDemoService /Install". The Listener Port is set in the ini file.

ConsoleAppDemoService compiles and runs the "Server Application" that is the "Listener" code in a console application enabling debugging of the code. Again the Listener Port is set in the ini file. Typically use the same port for both applications but you must stop the Windows service to allow the console to access the port. Use this application to set up an Auto Start server function on Linux
