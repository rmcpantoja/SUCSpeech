#include "Sintesizer-comaudio.au3"
func VoiceSpeak($text)
$vcname = IniRead(@ScriptDir &"\Config\config.st", "Sintesizer settings", "Voice", "")
if $vcname = "" then
MsgBox(16, "Error", "there is no setd independent voice.")
Return 0
EndIf
$vcpitch = ptr(IniRead(@ScriptDir &"\Config\config.st", "Sintesizer settings", "Pitch", ""))
if $vcpitch = "" then $vcpitch = 1
$vcvolume = ptr(IniRead(@ScriptDir &"\Config\config.st", "Sintesizer settings", "Volume", ""))
if $vcvolume = "" then $vcvolume = 1
$vcpunctuation = IniRead(@ScriptDir &"\Config\config.st", "Sintesizer settings", "Punctuation", "")
if $vcpunctuation = "" then $vcpunctuation = 1
If not FileExists(@scriptDir &"\Voicepacks\" &$vcname &".dat") then
msgBox(16, "Error", "this voice does not exist.")
return0
ENDIF
if StringInStr($vcname, "_hq") then
HablarEnSilabas($vcname, $text, $vcpitch, $vcvolume, $vcpunctuation)
Else
HablarEnLetras($vcname, $text, $vcpitch, $vcvolume, $vcpunctuation)
EndIF
EndFunc