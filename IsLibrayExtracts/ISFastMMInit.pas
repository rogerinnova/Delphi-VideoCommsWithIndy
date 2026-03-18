unit ISFastMMInit;
// SetFastMMShare Compiler Variable to share Memory
{
  Attempt to package my understanding of FastMM5
  FastMM4 used an inc file to set the FastMM configuration at compile time.
  FastMM5 makes these runtime options????  but they can be set by compiler variables
  Eg.
  FastMM_EnableMemoryLeakReporting;
  FastMM_FullDebugModeWhenDLLAvailable;
  FastMM_ClearLogFileOnStartup;


  See  procedure FastMM_ApplyConditionalDefines;

  Auto Load can be blocked
  {$ifndef FastMM_DisableAutomaticInstall
  initialization
  FastMM_Initialize;

  finalization
  FastMM_Finalize;
  {$endif

}

(* Crash in FMX destructor TCustomForm.Destroy;

  {$IF not defined(X86ASMRTL)}
  procedure _BeforeDestruction(const Instance: TObject; OuterMost: ShortInt);
  begin
  if OuterMost > 0 then
  Instance.BeforeDestruction;
  end;
  {$ELSE !X86ASMRTL}
  function _BeforeDestruction(const Instance: TObject; OuterMost: ShortInt): TObject;
  // Must preserve DL on return!
  asm //StackAlignSafe
  { ->  EAX  = pointer to instance }
  {      DL  = dealloc flag        }
  { <-  EAX  = pointer to instance }  //  Result := Instance;
  TEST    DL,DL
  JG      @@outerMost                //  if OuterMost > 0 then Exit;
  RET
  @@outerMost:
  {$IFDEF ALIGN_STACK}
  PUSH    ECX     // 4 byte adjustment, and ECX is convenient
  {$ENDIF ALIGN_STACK}
  PUSH    EAX
*)

interface

uses
  {$IFDEF TestFastMM}
  FastMM5,
  // FastMM5 in 'Z:\ThirdPartyGitRepo\FastMM\FastMM5-master\FastMM5.pas',
  // ,FastMMInitSharing //FastMMInitSharing in 'Z:\ThirdPartyGitRepo\FastMM\FastMM5-master\Demos\Memory Manager Sharing\Statically Linked DLL\FastMMInitSharing.pas',
  // will be requiredd to suport shared memory with DLL
  // {$IFDEF SetFastMMShare}
  {$Endif}
  System.Classes, System.SysUtils  ;

Procedure LoadFastMMfromISLib(ADeletePrevLog: Boolean = True;
  AShowViaLog: Boolean = True; AShowViaDialog: Boolean = True;
  AShowViaDebugString: Boolean = False;
  AEnterDebugMode: Boolean = True);

procedure TestMemmoryCorruption;
procedure TestDoubleFree;

Type
  TErrorProc = Procedure (AMsg:String);
Var
  OnError: TErrorProc;

implementation

Procedure LoadFastMMfromISLib(ADeletePrevLog, AShowViaLog, AShowViaDialog,
 AShowViaDebugString,AEnterDebugMode : Boolean);
begin
  {$IFDEF TestFastMM}
  case FastMM_GetInstallationState of
    mmisDefaultMemoryManagerInUse:Exit;
    {Another third party memory manager has been installed.}
    mmisOtherThirdPartyMemoryManagerInstalled:Exit;
    {A shared memory manager is being used.}
    mmisUsingSharedMemoryManager:Exit;
    {This memory manager has been installed.}
    mmisInstalled:Begin
    if ADeletePrevLog then
      FastMM_DeleteEventLogFile;
    End;
  end;


if AEnterDebugMode then
  if FastMM_LoadDebugSupportLibrary then
    FastMM_EnterDebugMode
    Else
    Raise Exception.Create('You need FastMM_FullDebugMode.dll');


  if AShowViaLog then

  FastMM_LogToFileEvents := [
  { Another third party memory manager has already been installed. }
    mmetAnotherThirdPartyMemoryManagerAlreadyInstalled,
  { FastMM cannot be installed, because memory has already been allocated through the default memory manager. }
  mmetCannotInstallAfterDefaultMemoryManagerHasBeenUsed,
  { When an attempt is made to install or use a shared memory manager, but the memory manager has already been used to
    allocate memory. }
  mmetCannotSwitchToSharedMemoryManagerWithLivePointers,
  { Details about an individual memory leak. }
  mmetUnexpectedMemoryLeakDetail,
  { Summary of memory leaks }
  mmetUnexpectedMemoryLeakSummary,
  { When an attempt to free or reallocate a debug block that has already been freed is detected. }
  mmetDebugBlockDoubleFree, mmetDebugBlockReallocOfFreedBlock,
  { When a corruption of the memory pool is detected. }
  mmetDebugBlockHeaderCorruption, mmetDebugBlockFooterCorruption,
    mmetDebugBlockModifiedAfterFree,
  { When a virtual method is called on a freed object. }
  mmetVirtualMethodCallOnFreedObject]
  Else
    FastMM_LogToFileEvents := [];

  if AShowViaDialog then
  FastMM_MessageBoxEvents :=
    [mmetDebugBlockDoubleFree,
    mmetDebugBlockReallocOfFreedBlock, mmetDebugBlockHeaderCorruption,
    mmetDebugBlockFooterCorruption,
    mmetDebugBlockModifiedAfterFree, mmetVirtualMethodCallOnFreedObject,
    mmetAnotherThirdPartyMemoryManagerAlreadyInstalled,
    mmetCannotInstallAfterDefaultMemoryManagerHasBeenUsed,
    mmetCannotSwitchToSharedMemoryManagerWithLivePointers]
   Else
     FastMM_MessageBoxEvents := [];

  if AShowViaDebugString then

  FastMM_OutputDebugStringEvents :=
   [mmetDebugBlockDoubleFree,
    mmetDebugBlockReallocOfFreedBlock, mmetDebugBlockHeaderCorruption, mmetDebugBlockFooterCorruption,
    mmetDebugBlockModifiedAfterFree, mmetVirtualMethodCallOnFreedObject, mmetAnotherThirdPartyMemoryManagerAlreadyInstalled,
    mmetCannotInstallAfterDefaultMemoryManagerHasBeenUsed, mmetCannotSwitchToSharedMemoryManagerWithLivePointers]
    else
  FastMM_OutputDebugStringEvents := [];

  ReportMemoryLeaksOnShutDown:=true;
{$Endif}
end;


procedure TestMemmoryCorruption;
var
  LPointer: PByte;
  s:string;

begin
  Try
    { Allocate a 1 byte memory block. }
    GetMem(LPointer, 1);

    { Write beyond the end of the allocated memory block, thus corrupting the memory pool. }
    LPointer[1] := 0;

    { Now try to free the block.  FastMM will detect that the block has been corrupted and display an error report.  This
      error report will also be logged to a file in the same folder as the application. }
    FreeMem(LPointer);
  Except
    On E: Exception Do
    Begin
      s:='TestMemmoryCorruption Class='+  E.ClassName + ' :: ' + E.Message;
      if Assigned(OnError) then
          OnError(s);
    End;
  End;
end;

procedure TestDoubleFree;
var
  Tst: TStringList;
  s:string;

begin
  Try
    { Allocate a memory block. }
    Tst := TStringList.create;
    { Allocate a memory block. }
    Tst.Add('gghghgg');
    Tst.Free;
    Tst.Add('gghghgg');
  Except
    On E: Exception Do
    Begin
      s:='TestChangeFreedObj Class='+  E.ClassName + ' :: ' + E.Message;
      if Assigned(OnError) then
          OnError(s);
    End;
  End;

  Try
    Tst.Free;
  Except
    On E: Exception Do
    Begin
      s:='TestDoubleFree Class='+  E.ClassName + ' :: ' + E.Message;
      if Assigned(OnError) then
          OnError(s);
    End;
  End;
end;



{$IFDEF SetFastMMShare}

Share Mempry is a work in progress


initialization
  {First try to share this memory manager.  This will fail if another module is already sharing its memory manager.  In
  case of the latter, try to use the memory manager shared by the other module.}
  if FastMM_ShareMemoryManager then
  begin
    {Try to load the debug support library (FastMM_FullDebugMode.dll, or FastMM_FullDebugMode64.dll under 64-bit). If
    it is available, then enter debug mode.}
    if FastMM_LoadDebugSupportLibrary then
    begin
      FastMM_EnterDebugMode;
      {In debug mode, also show the stack traces for memory leaks.}
      FastMM_MessageBoxEvents := FastMM_MessageBoxEvents + [mmetUnexpectedMemoryLeakDetail];
    end;
  end
  else
  begin
    {Another module is already sharing its memory manager, so try to use that.}
    FastMM_AttemptToUseSharedMemoryManager;
  end;

 {From FastMM5
 Prevent a potential crash when the finalization code in system.pas tries to
 free PreferredLanguagesOverride after
 FastMM has been uninstalled:
 https://quality.embarcadero.com/browse/RSP-16796}

{$ENDIF}

end.
