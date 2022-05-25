#include-once
#include "synthesizer.au3"
#include "translator.au3"
Global $sucspeechSpeakManager_ver = "1.2", $ConfigPath = @ScriptDir & "\Config\config.st", $lng = "en"
local $isPro = true
; #FUNCTION# ====================================================================================================================
; Name ..........: VoiceSpeak
; Description ...: Speak the text with SucSpeech taking into account settings such as speed, pitch, voice, punctuation, etc.
; Syntax ........: VoiceSpeak($sText)
; Parameters ....: $sText                - the text to be spoken in a string.
; Return values .: 0 if not have a independent voice, -1 if the voice file does not exists.
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func VoiceSpeak($sText)
	local $sSpeechPath = ""
	$vcname = IniRead($ConfigPath, "Sintesizer settings", "Voice", "")
	If $vcname = "" Then
		MsgBox(16, translate($lng, "Error"), translate($lng, "there is no setd independent voice."))
		Return 0
	EndIf
	select
			case StringInStr($vcname, "_hq")
				$sSpeechPath = @ScriptDir & "\SucSpeech\Voicepacks_source_pro"
			case else
				$sSpeechPath = @ScriptDir & "\SucSpeech\Voicepacks_source"
		EndSelect
	$vcpitch = number(IniRead($ConfigPath, "Sintesizer settings", "Pitch", ""))
	If $vcpitch = "" Then $vcpitch = 1
	$vcvolume = number(IniRead($ConfigPath, "Sintesizer settings", "Volume", ""))
	If $vcvolume = "" Then $vcvolume = 1
	$vcpunctuation = IniRead($ConfigPath, "Sintesizer settings", "Punctuation", "")
	If $vcpunctuation = "" Then $vcpunctuation = 1
	If Not FileExists($sSpeechPath &"\" &$vcname) Then
		MsgBox(16, translate($lng, "Error"), translate($lng, "this voice does not exist."))
		Return -1
	EndIf
	If StringInStr($vcname, "_hq") Then
		If $isPro Then
			_SucSpeechSpeak2($vcname, $sText, $vcpitch, $vcvolume, $vcpunctuation)
		Else
			_SucSpeechSpeak2($vcname, translate($lng, "Please request a blind text pro activation to use this feature"), $vcpitch, $vcvolume, $vcpunctuation)
		EndIf
	Else
		_SucSpeechSpeak1($vcname, $sText, $vcpitch, $vcvolume, $vcpunctuation)
	EndIf
	return 1
EndFunc   ;==>VoiceSpeak
