;This is my Spanish voice synthesizer.
#include-once
#include <AutoItConstants.au3>
#include <Bass.au3>
#include<BassConstants.au3>
#include <BassEnc.au3>
#include <BassExt.au3>
#include <fileConstants.au3>
#include "gamelib.au3"
#include "timeGetTime.au3"
;Comments on how this UDF works: English	spanish.
local $characters[] ;2048 character limit for standard version. For the pro version it will be unlimited.
Global $sucSpeech_ver = "1.0b2"
$sSucspeechLogPath = @ScriptDir &"\sucSpeech\logs"
__Bass_Start()
func _SucSpeech_Apply_Rules($sText, $sLang)
$aDict = FileReadToArray(@ScriptDir &"\Sucspeech\Dicts\" &$sLang &"\rules.dic")
$iCount = @extended
If @error Then return @error
For $i = 0 To $iCount - 1
$aRule = StringSplit($aDict[$I], "|")
If StringInStr($sText, $aRule[1]) then $sText = StringReplace($sText, $aRule[1], $aRule[2])
Next
return $sText
EndFunc
func _SucSpeech_Apply_simbols($sText, $sLang)
$sSimPath = @ScriptDir &"\Sucspeech\Dicts\" &$sLang &"\simbols.dic"
if not FileExists($sSimPath) then return 0
$hFile = FileOpen($sSimPath, $FO_READ)
If $hFile = -1 Then return -1
$sData = FileRead($hFile)
FileClose($hFile)
;Process:
$aSimbol = stringSplit($sData, ",")
for $I = 1 to $aSimbol[0]
$aSim2Word = StringSplit($aSimbol[$I], "|")
$sSimbolWord = _SucSpeech_Apply_Rules($aSim2Word[2], $sLang)
If StringInStr($sText, $aSim2Word[1]) then $sText = StringReplace($sText, $aSim2Word[1], $sSimbolWord &" ")
Next
return $sText
EndFunc

func __Bass_Start()
_BASS_Startup()
_BASS_ENCODE_Startup()
_BASS_EXT_STARTUP()
_BASS_Init(0, -1, 48000, 0, "")
If @error Then
	MsgBox(16, "Error", "Could not initialize audio ENGINE")
	Exit
EndIf
EndFunc
;The next function is _SucSpeechSpeak1, which corresponds to speaking a sentence, concatenating phonemes depends on each letter of the string. La siguiente función es _SucSpeechSpeak1, que corresponde a pronunciar una oración, la concatenación de fonemas depende de cada letra de la cadena.
;Function: _SucSpeechSpeak1
;parameters: $Voice: The name of a voice that has been created. You can also create your own voice, package it and put it in the Voicepacks folder. parámetros: $Voice: el nombre de una voz que se ha creado. También puede crear su propia voz, empaquetarla y ponerla en la carpeta Voicepacks.
;$STR: The text to be spoken. $STR: el texto a ser hablado.
;$VoicePitch: The pitch and speed of the voice. 0.50 very slow, 1 normal, 1.50 fast and 2:00 very fast. The default parameter is 1. $VoicePitch: el tono y la velocidad de la voz. 0.50 muy lento, 1 normal, 1.50 rápido y 2:00 muy rápido. El parámetro predeterminado es 1.
;$VoiceVolume: The volume of the voice. between 0.01 and 1.00. The default parameter is 1.00. $VoiceVolume: el volumen de la voz. entre 0.01 y 1.00. El parámetro predeterminado es 1.00.
;$VoicePunctuation: This is to speak punctuation marks in the string or in the text being spoken if it contains them. There are four modes of scoring reading: 0 none, 1 some, 2 almost all, and 3 all. The default parameter is 0 (do not read any punctuation). $VoicePunctuation: Esto es para verbalizar signos de puntuación en la cadena o en el texto que se está pronunciando si los contiene. Hay cuatro modos de lectura de puntuación: 0 ninguna, 1 alguna, 2 casi toda y 3 toda. El parámetro predeterminado es 0 (no leer ningún signo de puntuación).

Func _SucSpeechSpeak1($voice, $str, $Voicepitch = 1, $Voicevolume = 1, $Voicepunctuation = "0", $bInterrupt = false, $bSabeWav = false, $sWavFilename = @scriptdir &"\sucspeech\Audio\sucSpeechOutput_" &@year &@mon &@mday &".wav", $bWriteLog = true)
	If @Compiled Then
		FileChangeDir(@ScriptDir & "\sucspeech\voicepacks")
	Else
		FileChangeDir(@ScriptDir & "\sucSpeech\voicepacks_source")
	EndIf
	Global $svoice = $voice
	Global $vpitch = $Voicepitch
	Global $vvolume = $Voicevolume
	Global $letters = "b,c,d,f,g,h,j,k,l,m,n,ñ,p,q,r,s,t,v,w,x,y,z"
	;spanish letters with their respective rules: letras en español con sus respectivas reglas:
	Global $lspeak = "be,ce,de,efe,ge,a$e,jota,ka,ele,eme,ene,eñe,pe,ku,erre,ese,te,uve,doblebe,eqis,igriega,ceta"
	;Detecting if the text contains vowels a, e, i, o, u. And if the text doesn't have vowels anywhere, then read the letters. It's a common thing for synthesizers. Detectando si el texto contiene vocales a, e, i, o, u. Y si el texto no tiene vocales en ninguna parte, lee entonces las letras. Es algo común de los sintetizadores.
	Select
		Case Not StringInStr($str, "a") And Not StringInStr($str, "e") And Not StringInStr($str, "i") And Not StringInStr($str, "o") And Not StringInStr($str, "u")
			$lreplace = StringSplit($letters, ",")
			$sreplace = StringSplit($lspeak, ",")
			For $I = 1 To $lreplace[0]
				If StringInStr($str, $lreplace[$I]) Then
					$str = StringReplace($str, $lreplace[$I], $sreplace[$I])
				EndIf
			Next
	EndSelect
	;Applying dictionary corrections, a few things according to the punctuation: Aplicando correcciones de diccionario, algunas cosas de acuerdo a la puntuación:
	If $Voicepunctuation = "2" Or $Voicepunctuation = "3" Then
		$str = StringReplace($str, "/", "barra")
		$str = StringReplace($str, ":", "Dos puntos.")
		$str = StringReplace($str, "{", "abreyabe")
		$str = StringReplace($str, "}", "cierrayabe")
	Else
		$str = StringReplace($str, "/", "")
		$str = StringReplace($str, ":", ".")
		$str = StringReplace($str, "{", "")
		$str = StringReplace($str, "{", "")
	EndIf
	If $Voicepunctuation = "3" Then
		$str = StringReplace($str, "¿", "Abrir interrogación")
		$str = StringReplace($str, "?", "Cerrar interrogación")
		$str = StringReplace($str, "¡", "Abrir exclamación")
		$str = StringReplace($str, "!", "Cerrar exclamación")
	Else
		$str = StringReplace($str, "¿", ".")
		$str = StringReplace($str, "?", ",")
		$str = StringReplace($str, "¡", ".")
		$str = StringReplace($str, "!", ".")
	EndIf
	If $Voicepunctuation = "2" Or $Voicepunctuation = "3" Then
		$str = StringReplace($str, "(", "abrirparéntesis")
		$str = StringReplace($str, ")", "cerrarparéntesis")
		$str = StringReplace($str, "=", "igual")
		$str = StringReplace($str, "|", "'")
	Else
		$str = StringReplace($str, "(", ",")
		$str = StringReplace($str, ")", ".")
		$str = StringReplace($str, "=", "")
		$str = StringReplace($str, "|", "")
	EndIf
	$str = StringReplace($str, "1", "uno")
	$str = StringReplace($str, "2", "dos")
	$str = StringReplace($str, "3", "tres")
	$str = StringReplace($str, "4", "quatro")
	$str = StringReplace($str, "5", "cinqo")
	$str = StringReplace($str, "6", "seis")
	$str = StringReplace($str, "7", "siete")
	$str = StringReplace($str, "8", "o$o")
	$str = StringReplace($str, "9", "nueve")
	$str = StringReplace($str, "0", "cero")
	If $Voicepunctuation = "2" Or $Voicepunctuation = "3" Then
		$str = StringReplace($str, "[", "abreqor$ete")
		$str = StringReplace($str, "]", "cierraqor$ete")
		$str = StringReplace($str, "°", "grados")
		$str = StringReplace($str, "_", "subrayado")
		$str = StringReplace($str, ";", "puntoycoma")
		$str = StringReplace($str, "^", "circunflejo")
		$str = StringReplace($str, "`", "grave")
	Else
		$str = StringReplace($str, "[", "")
		$str = StringReplace($str, "]", "")
		$str = StringReplace($str, "°", "")
		$str = StringReplace($str, "_", "")
		$str = StringReplace($str, ";", ",")
		$str = StringReplace($str, "^", "")
		$str = StringReplace($str, "`", "")
	EndIf
	$str = StringReplace($str, @CRLF, ".")
	$str = StringReplace($str, " ", "")
	;process pronunciation arrangements
	$sNewStr = _SucSpeech_Apply_Rules($str, "es")
	$sNewStr = _SucSpeech_Apply_simbols($sNewStr, "es")
	;Get the number of characters in the string: Obtener el número de caracteres de la cadena:
	$length = StringLen($sNewStr)
	;The next variable is an indicator, it will be modified to carry out the character-by-character concatenation. La siguiente variable es un indicador, este será modificado para que realice la concatenación carácter por carácter.
	$remove = -1
	$remover = $length
	$hStream = _BASS_StreamCreate(96000, 1, 0, $STREAMPROC_PUSH, 0)
	if $bSabeWav then
		$hEncoder = _BASS_Encode_Start($hStream, $sWavFilename, $BASS_ENCODE_PCM)
	EndIf
	local $bData[]
	local $aBuffer[]
	;The next for is to display character by character in the array $ characters [$ iString]. $ iString is the base of the for, which means that the array element will increment for each character and concatenates the voice data according to the array and the characters. El siguiente for es para mostrar caracter por caracter en la matriz $characters[$iString]. $iString es la base del for, lo que significa que el elemento del array aumentará por cada carácter y concatena los datos de voz de acuerdo al array y los caracteres.
	For $iString = 1 To $length
		$remove = $remove + 1
		$remover = $remover - 1
		$characters[$iString] = StringTrimLeft(StringTrimRight($sNewStr, $remover), $remove)
		$aBuffer[$iString] = _BASS_EXT_MemoryBufferCreate()
		$sSpeechFile = $svoice & "/" & $characters[$iString] & Random(1, 3, 1) & ".wav"
		if not FileExists($sSpeechFile) then
			if $bWriteLog then
				if not FileExists($sSucspeechLogPath) then DirCreate($sSucspeechLogPath)
				$sLogFile = FileOpen($sSucspeechLogPath &"\sucspeech_log.log", 1)
				fileWriteLine($sLogFile, "warning! concatenating speech process has an warning: the file " &$sSpeechFile &" does not exist, so when trying to play TTS the results will not be correct.")
			EndIf
		Else
			$hFile = FileOpen($sSpeechFile, 16)
			If $hFile = -1 Then
				if $bWriteLog then
					if not FileExists($sSucspeechLogPath) then dirCreate($sSucspeechLogPath)
					$sLogFile = FileOpen($sSucspeechLogPath &"\sucspeech_log.log", 1)
					fileWriteLine($sLogFile, "warning! concatenating speech process has an error: the file " &$sSpeechFile &" could not be processed, so when generating tts you will not get good results.")
				EndIf
			else
			$bData[$iString] = FileRead($hFile)
			FileClose($hFile)
			EndIf
		EndIf
		_BASS_EXT_MemoryBufferAddData($aBuffer[$iString], $bData[$iString])
	Next
	if $bWriteLog then
		if IsDeclared("sLogFile") then FileClose($sLogFile)
	EndIf
	$hChan = _voicePlay($hStream)
	if $bSabeWav then _BASS_Encode_SetChannel($hEncoder, $hChan)
	for $II = 0 to ubound($bData)
		$iQueued = _BASS_EXT_StreamPutBufferData($hStream, $aBuffer[$II], 96000, False)
	Next
	if $bSabeWav then
		_BASS_Encode_Write($hEncoder, $hStream, "")
		sleep(5000)
		_BASS_Encode_Stop($hEncoder)
	Endif
EndFunc   ;==>HablarEnLetras
;The next function is HablarEnSilabas (in Spanish) it has the same parameters as the previous function, unlike that instead of concatenating character by character it concatenates into syllables, which gives a more human result to the voice. Warning: To create these types of voices we will require a lot of time and effort... La siguiente función es hablar En Sílabas (en español) cuenta con los mismos parámetros que la función anterior, a diferencia de que en lugar de concatenar carácter por carácter concatena en sílabas, lo que da un resultado más humano a la voz. Advertencia: Para crear este tipo de voces requeriremos de mucho tiempo y esfuerzo...
; #FUNCTION# ====================================================================================================================
; Name ..........: HABLARENSilabas
; Description ...: concatenates the voice into syllables
; Syntax ........: HABLARENSilabas($voice, $str [, $Voicepitch = "1" [, $Voicevolume = "1" [, $Voicepunctuation = "0"]]])
; Parameters ....: $voice               - A variant value.
;                  $str                 - A string value.
;                  $Voicepitch          - [optional] A variant value. Default is "1".
;                  $Voicevolume         - [optional] A variant value. Default is "1".
;                  $Voicepunctuation    - [optional] A variant value. Default is "0".
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SucSpeechSpeak2($voice, $str, $Voicepitch = "1", $Voicevolume = "1", $Voicepunctuation = "0", $bInterrupt = false, $bSabeWav = false, $sWavFilename = @scriptdir &"\SucSpeech\Audio\sucSpeechOutput_" &@year &@mon &@mday &".wav", $bWriteLog = true)
	If @Compiled Then
		FileChangeDir(@ScriptDir & "\SucSpeech\voicepacks")
	Else
		FileChangeDir(@ScriptDir & "\sucSpeech\voicepacks_source_pro")
	EndIf
	Global $svoice = $voice
	Global $vpitch = $Voicepitch
	Global $vvolume = $Voicevolume
	Global $letters = "b,c,d,f,g,h,j,k,l,m,n,ñ,p,q,r,s,t,v,w,x,y,z"
	;spanish letters with their respective rules: letras en español con sus respectivas reglas:
	Global $lspeak = "be,ce,de,efe,ge,a$e,jota,ka,ele,eme,ene,enie,pe,ku,erre,ese,te,uve,doblebe,eqis,igriega,ceta"
	;Detectando si el texto contiene vocales a, e, i, o, u. Y si el texto no tiene vocales en ninguna parte, lee entonces las letras. Es algo común de los sintetizadores.
	Select
		Case Not StringInStr($str, "a") And Not StringInStr($str, "e") And Not StringInStr($str, "i") And Not StringInStr($str, "o") And Not StringInStr($str, "u")
			$lreplace = StringSplit($letters, ",")
			$sreplace = StringSplit($lspeak, ",")
			For $I = 1 To $lreplace[0]
				If StringInStr($str, $lreplace[$I]) Then
					$str = StringReplace($str, $lreplace[$I], $sreplace[$I])
				EndIf
			Next
	EndSelect
	;Aplicando correcciones de diccionario, algunas cosas de acuerdo a la puntuación:
	$str = StringReplace($str, "1", "uno")
	$str = StringReplace($str, "2", "dos")
	$str = StringReplace($str, "3", "tres")
	$str = StringReplace($str, "4", "cuatro")
	$str = StringReplace($str, "5", "cinqo")
	$str = StringReplace($str, "6", "seis")
	$str = StringReplace($str, "7", "siete")
	$str = StringReplace($str, "8", "ocho")
	$str = StringReplace($str, "9", "nueve")
	$str = StringReplace($str, "0", "cero")
	$str = StringReplace($str, @CRLF, ".")
	$str = StringReplace($str, " ", "")
	$sNewStr = _SucSpeech_Apply_Rules($str, "es")
	$sNewStr = _SucSpeech_Apply_simbols($sNewStr, "es")
	;Get the number of characters in the string: Obtener el número de caracteres de la cadena:
	$length = StringLen($sNewStr)
	$remove = "-2"
	$remover = $length
	$hStream = _BASS_StreamCreate(96000, 1, 0, $STREAMPROC_PUSH, 0)
	if $bSabeWav then
		$hEncoder = _BASS_Encode_Start($hStream, $sWavFilename, $BASS_ENCODE_PCM)
	EndIf
	local $bData[]
	local $aBuffer[]
	;The next for is to display character by character in the array $ characters [$ iString]. $ iString is the base of the for, which means that the array element will increment for each character and concatenates the voice data according to the array and the characters. El siguiente for es para mostrar caracter por caracter en la matriz $characters[$iString]. $iString es la base del for, lo que significa que el elemento del array aumentará por cada carácter y concatena los datos de voz de acuerdo al array y los caracteres.
	For $iString = 1 To $length / 2
		$remove = $remove + 2
		$remover = $remover - 2
		$characters[$iString] = StringTrimLeft(StringTrimRight($sNewStr, $remover), $remove)
		$aBuffer[$iString] = _BASS_EXT_MemoryBufferCreate()
		$sSpeechFile = $svoice & "/" & $characters[$iString] & Random(1, 3, 1) & ".wav"
		if not FileExists($sSpeechFile) then
			if $bWriteLog then
				if not FileExists($sSucspeechLogPath) then DirCreate($sSucspeechLogPath)
				$sLogFile = FileOpen($sSucspeechLogPath &"\sucspeech_log.log", 1)
				FileWriteLine($sLogFile, "warning! concatenating speech process has an warning: the file " &$sSpeechFile &" does not exist, so when trying to play TTS the results will not be correct.")
			EndIf
		Else
			$hFile = FileOpen($sSpeechFile, 16)
			If $hFile = -1 Then
				if $bWriteLog then
					if not FileExists($sSucspeechLogPath) then DirCreate($sSucspeechLogPath)
					$sLogFile = FileOpen($sSucspeechLogPath &"\sucspeech_log.log", 1)
					FileWriteLine($sLogFile, "warning! concatenating speech process has an error: the file " &$sSpeechFile &" could not be processed, so when generating tts you will not get good results.")
				EndIf
			else
				$bData[$iString] = FileRead($hFile)
				FileClose($hFile)
			EndIf
		EndIf
		_BASS_EXT_MemoryBufferAddData($aBuffer[$iString], $bData[$iString])
	Next
	if $bWriteLog then
		if IsDeclared("sLogFile") then FileClose($sLogFile)
	EndIf
	$hChan = _voicePlay($hStream)
	if $bSabeWav then _BASS_Encode_SetChannel($hEncoder, $hChan)
	for $II = 0 to ubound($bData)
		$iQueued = _BASS_EXT_StreamPutBufferData($hStream, $aBuffer[$II], 96000, False)
	Next
	if $bSabeWav then
		_BASS_Encode_Write($hEncoder, $hStream, "")
		sleep(5000)
		_BASS_Encode_Stop($hEncoder)
	Endif
EndFunc   ;==>HABLARENSilabas
func _voicePlay($hStream)
return _BASS_ChannelPlay($hStream, 1)
EndFunc
Func _VoiceStop($hChan, $hStream)
_BASS_ChannelStop($hChan)
_BASS_StreamFree($hStream)
EndFunc
Func _VoicePlayResumeSwitch($handle)
If _Get_playstate($Handle) = 2 Then
$BASS_PAUSE_POS = _BASS_ChannelGetPosition($Handle, $BASS_POS_BYTE)
_BASS_ChannelPause($Handle)
ElseIf _Get_playstate($Handle) = 3 Then
_Audio_play($Handle)
_BASS_ChannelSetPosition($Handle, $BASS_PAUSE_POS, $BASS_POS_BYTE)
EndIf
EndFunc
Func getLength($sound)
	$length = $sound.Length
	Return $length
EndFunc   ;==>getLength
; #FUNCTION# ====================================================================================================================
; Name ..........: getSampleRate
; Description ...: get the sample rate of an audio file
; Syntax ........: getSampleRate($sound)
; Parameters ....: $sound               - A string value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func getSampleRate($sound)
	$srate = $sound.sampleRate
	Return $srate
EndFunc   ;==>getSampleRate
Func SoundFade($sound)
	For $fade = 1 To 18
		$sound.volume = $sound.volume - 0.05
		Sleep(25)
	Next
	$sound.stop()
EndFunc   ;==>SoundFade
; #FUNCTION# ====================================================================================================================
; Name ..........: SoundFadeIn
; Description ...: "fade in" effect
; Syntax ........: SoundFadeIn($sound)
; Parameters ....: $sound               - A string value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func SoundFadeIn($sound)
	if not $sound.playing then $sound.play
	$sound.volume = 0
	For $fade = 1 To 18
		$sound.volume = $sound.volume + 0.05
		Sleep(25)
	Next
EndFunc   ;==>SoundFadeIn

Func _FreeBass()
	_BASS_StreamFree($hStream)
	_BASS_Free()
EndFunc   ;==>_FreeBass
