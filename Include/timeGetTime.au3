;Do not, I say not, name your variables like this. Heheh
$TimeDLLHandleWhateverSuperWeirdIKnow = DLLOpen("WinMM.dll")
Func TravelInTime()

$DragonNeedsVariableRightNow = DLLCall($TimeDLLHandleWhateverSuperWeirdIKnow,"long","timeGetTime")
return $DragonNeedsVariableRightNow[0]


EndFunc
func TravelOutTime($InitialValueThingieYouKnowWhatImOnAbout)

$DragonNeedsAnotherVariable = DllCall($TimeDLLHandleWhateverSuperWeirdIKnow,"long","timeGetTime")
return $DragonNeedsAnotherVariable[0]-$InitialValueThingieYouKnowWhatImOnAbout


EndFunc