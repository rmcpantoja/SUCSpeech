#include-once

;Include Constants
#include "Bass.au3"
#include "BassEncConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: _BassEnc.au3
; Description ...: Almost all of BASSENC.DLL translated ready for easy use with AutoIt
;                  Bass.dll and Bass.au3 is needed
; Author ........: Eukalyptus, based on BASS.au3/Brett Francis (BrettF)
; Modified ......: BrettF
; ===============================================================================================================================

; #ToDo#=========================================================================================================================
;function BASS_Encode_GetACMFormat(handle:DWORD; form:Pointer; formlen:DWORD; title:PChar; flags:DWORD): DWORD;
;function BASS_Encode_StartACM(handle:DWORD; form:Pointer; flags:DWORD; proc:ENCODEPROC; user:Pointer): HENCODE;
;function BASS_Encode_StartACMFile(handle:DWORD; form:Pointer; flags:DWORD; filename:PChar): HENCODE; stdcall;
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;           _BASS_Encode_GetVersion()
;           _BASS_Encode_Start()
;           _BASS_Encode_IsActive()
;           _BASS_Encode_Stop()
;           _BASS_Encode_SetPaused()
;           _BASS_Encode_Write()
;           _BASS_Encode_SetNotify()
;           _BASS_Encode_GetCount()
;           _BASS_Encode_SetChannel()
;           _BASS_Encode_GetChannel()
;           _BASS_Encode_CastInit()
;           _BASS_Encode_CastSetTitle()
;           _BASS_Encode_CastGetStats()
; ===============================================================================================================================

Global $_ghBassEncDll = -1
Global $BASS_ENC_DLL_UDF_VER = "2.4.8.1"
Global $BASS_ENC_UDF_VER = "10.0"

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_Startup
; Description ...: Starts up BassCD functions.
; Syntax ........: _BASS_Encode_Startup($sBassEncDll = "")
; Parameters ....: -	$sBassEncDll	-	The relative path to BassEnc.dll.
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- $BASS_ERR_DLL_NO_EXIST	-	File could not be found.
; Author ........: Prog@ndy
; Modified ......: Eukalyptus
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_Startup($sBassEncDll = "")
	If $_ghBassEncDll <> -1 Then Return True
	If Not $sBassEncDll Then $sBassEncDll = @ScriptDir & "\BassEnc.dll"

	If Not FileExists($sBassEncDll) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)

	Local $sBit = __BASS_LibraryGetArch($sBassEncDll)
	Select
		Case $sBit = "32" And @AutoItX64
			ConsoleWrite(@CRLF & "!BassEnc.dll is for 32bit only!" & @CRLF & "Run/compile Script at 32bit" & @CRLF)
		Case $sBit = "64" And Not @AutoItX64
			ConsoleWrite(@CRLF & "!BassEnc.dll is for 64bit only!" & @CRLF & "use 32bit version of BassEnc.dll" & @CRLF)
	EndSelect

	If $BASS_STARTUP_VERSIONCHECK Then
		If Not @AutoItX64 And _VersionCompare(FileGetVersion($sBassEncDll), $BASS_ENC_DLL_UDF_VER) <> 0 Then ConsoleWrite(@CRLF & "!This version of BASSENC.au3 is made for BassENC.dll V" & $BASS_ENC_DLL_UDF_VER & ".  Please update" & @CRLF)
		If $BASS_ENC_UDF_VER <> $BASS_UDF_VER Then ConsoleWrite("!This version of BASSENC.au3 (v" & $BASS_ENC_UDF_VER & ") may not be compatible to BASS.au3 (v" & $BASS_UDF_VER & ")" & @CRLF)
	EndIf

	$_ghBassEncDll = DllOpen($sBassEncDll)
	Return $_ghBassEncDll <> -1
EndFunc   ;==>_BASS_Encode_Startup

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_GetVersion
; Description ...: Retrieves the version of BASSENC that is loaded.
; Syntax ........: _BASS_Encode_GetVersion()
; Parameters ....: $bass_dll	-	Handle to opened Bass.dll
;                  $_ghBassEncDll	-	Handle to opened Bassenc.dll
; Return values .: Success      -	Returns Version
;				   Failure      -	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_GetVersion()
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_GetVersion")
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_GetVersion

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_Start
; Description ...: Sets up an encoder on a channel.
; Syntax ........: _BASS_Encode_Start($handle, $cmdline, $flags, $proc = 0, $user = 0)
; Parameters ....: $handle 		-	The channel handle... a HSTREAM, HMUSIC, or HRECORD.
;				   $cmdline 	-	The encoder command-line, including the executable filename and any options. Or the output filename if the BASS_ENCODE_PCM flag is specified.
;				   $flags 		-	A combination of these flags:
;				   		|$BASS_ENCODE_PCM 		-	Write plain PCM sample data to a file, without an encoder. The output filename is given in the cmdline parameter.
;				   		|BASS_ENCODE_NOHEAD 	-	Don't send a WAVE header to the encoder. If this flag is used then the sample format must be passed to the encoder some other way, eg. via the command-line.
;				 		|$BASS_ENCODE_BIGEND 	-	Send big-endian sample data to the encoder, else little-endian. This flag is ignored unless the BASS_ENCODE_NOHEAD flag is used, as WAV files are little-endian.
;				  		|$BASS_ENCODE_FP_8BIT
;				  		|$BASS_ENCODE_FP_16BIT
;				  		|$BASS_ENCODE_FP_24BIT
;				  		|$BASS_ENCODE_FP_32BIT	-	When you want to encode a floating-point channel, but the encoder does not support 32-bit floating-point sample data, then you can use one of these flags to have the sample data converted to 8/16/24/32 bit integer data before it is passed on to the encoder. These flags are ignored if the channel's sample data is not floating-point.
;				   		|$BASS_ENCODE_PAUSE 	-	Start the encoder paused.
;				   		|$BASS_ENCODE_AUTOFREE 	-	Automatically free the encoder when the source channel is freed.
;				   		|$BASS_UNICODE 			-	cmdline is Unicode (UTF-16).
;				   $proc 		-	Optional callback function to receive the encoded data...To have the encoded data received by a callback function, the encoder needs to be told to output to STDOUT (instead of a file).
;                       |Callback function has the following paramaters:
;						|$handle	- 	The stream that needs writing.
;						|$buffer	-	Pointer to the buffer to write the sample data in.
;						|$length	- 	The maximum number of bytes to write.
;						|$user		-	The user instance data:
;				   $user 		-	User instance data to pass to the callback function.
; Return values .: Success      - 	Returns Encoder Handle
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_Start($handle, $cmdline, $flags, $proc = 0, $user = 0)
	Local $proc_s = -1
	If IsString($proc) Then
		$proc_s = DllCallbackRegister($proc, "ptr", "dword;dword;ptr;dword;ptr")
		$proc = DllCallbackGetPtr($proc_s)
	EndIf

	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "dword", "BASS_Encode_Start", "dword", $handle, "str", $cmdline, "dword", $flags, "ptr", $proc, "ptr", $user)
	If @error Then
		If $proc_s <> -1 Then DllCallbackFree($proc_s)
		Return SetError(@error, @extended, 0)
	EndIf

	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		If $proc_s <> -1 Then DllCallbackFree($proc_s)
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_Start

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_Stop
; Description ...: Stops an encoder or all encoders on a channel.
; Syntax ........: _BASS_Encode_Stop($handle)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
; Return values .: Success      - 	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_Stop($handle)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_Stop", "dword", $handle)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_Stop

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_IsActive
; Description ...: Checks if an encoder is running.
; Syntax ........: _BASS_Encode_IsActive($handle)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
; Return values .: Success		-	The return value is one of the following:
;				   		|$BASS_ACTIVE_STOPPED 	-	The encoder isn't running.
;				   		|BASS_ACTIVE_PLAYING 	-	The encoder is running.
;				   		|$BASS_ACTIVE_PAUSED 	-	The encoder is paused.
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_IsActive($handle)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "dword", "BASS_Encode_IsActive", "dword", $handle)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_IsActive

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_SetPaused
; Description ...: Pauses or resumes an encoder, or all encoders on a channel.
; Syntax ........: _BASS_Encode_SetPaused($handle, $paused)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
;                  $paused		-	True = paused, False = Not paused
; Return values .: Success		-	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_SetPaused($handle, $paused)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_SetPaused", "dword", $handle, "int", $paused)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_SetPaused

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_Write
; Description ...: Sends sample data to an encoder or all encoders on a channel.
; Syntax ........: _BASS_Encode_Write($handle, $buffer, $length)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
;                  $buffer		-	The buffer containing the sample data.
;                  $length		-	The number of BYTES in the buffer.
; Return values .: Success		-	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_Write($handle, $buffer, $length)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_Write", "dword", $handle, "ptr", $buffer, "DWORD", $length)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_Write

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_SetNotify
; Description ...: Sets a callback function on an encoder (or all encoders on a channel) to receive notifications about its status.
; Syntax ........: _BASS_Encode_SetNotify($handle, $proc, $puser)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
;                  $proc		-	Callback function to receive the notifications
;                       |Callback function has the following paramaters:
;						|$handle	- 	The stream that needs writing.
;						|$buffer	-	Pointer to the buffer to write the sample data in.
;						|$length	- 	The maximum number of bytes to write.
;						|$user		-	The user instance data:
;                  $user		-	User instance data to pass to the callback function
; Return values .: Success		-	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_SetNotify($handle, $proc, $puser)
	Local $proc_s = -1
	If IsString($proc) Then
		$proc_s = DllCallbackRegister($proc, "ptr", "dword;dword;ptr")
		$proc = DllCallbackGetPtr($proc_s)
	EndIf
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_SetNotify", "dword", $handle, "ptr", $proc, "ptr", $puser)
	If @error Then
		If $proc_s <> -1 Then DllCallbackFree($proc_s)
		Return SetError(@error, @extended, 0)
	EndIf
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		If $proc_s <> -1 Then DllCallbackFree($proc_s)
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_SetNotify

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_GetCount
; Description ...: Retrieves the amount data sent to or received from an encoder, or sent to a cast server.
; Syntax ........: _BASS_Encode_GetCount($handle, $count)
; Parameters ....: $handle 		-	The encoder handle
;                  $count		-	The count to retrieve. One of the following:
;                  		|$BASS_ENCODE_COUNT_IN 		-	Data sent to the encoder.
;                  		|$BASS_ENCODE_COUNT_OUT 	-	Data received from the encoder. This only applies when the encoder outputs to STDOUT or it is an ACM encoder.
;                  		|$BASS_ENCODE_COUNT_CAST 	-	Data sent to a cast server.
; Return values .: Success      - 	the requested count (in bytes) is returned
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_GetCount($handle, $count)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "dword", "BASS_Encode_GetCount", "dword", $handle, "dword", $count)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_GetCount

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_SetChannel
; Description ...: Moves an encoder (or all encoders on a channel) to another channel.
; Syntax ........: _BASS_Encode_SetChannel($handle, $channel)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
;                  $channel		-	The channel to move the encoder(s) to... a HSTREAM, HMUSIC, or HRECORD.
; Return values .: Success		-	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_SetChannel($handle, $channel)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_SetChannel", "dword", $handle, "dword", $channel)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_SetChannel

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_GetChannel
; Description ...: Retrieves the channel that an encoder is set on.
; Syntax ........: _BASS_Encode_GetChannel($handle)
; Parameters ....: $handle 		-	The encoder or channel handle... a HENCODE, HSTREAM, HMUSIC, or HRECORD.
; Return values .: Success      - 	the encoder's channel handle is returned
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_GetChannel($handle)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "dword", "BASS_Encode_GetChannel", "dword", $handle)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_GetChannel

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_CastInit
; Description ...: Initializes sending an encoder's output to a Shoutcast or Icecast server.
; Syntax ........: _BASS_Encode_CastInit($handle, $server, $pass, $content, $name, $url, $genre, $desc, $headers, $bitrate, $pub)
; Parameters ....: $handle 		-	The encoder handle.
;                  $server 		-	The server to send to, in the form of "address:port" (Shoutcast) or "address:port/mount" (Icecast).
;                  $pass 		-	The server password.
;                  $content 	-	The MIME type of the encoder output. This can be one of the following:
;                  		|$BASS_ENCODE_TYPE_MP3 	-	MP3.
;                  		|$BASS_ENCODE_TYPE_OGG 	-	OGG.
;                  		|$BASS_ENCODE_TYPE_AAC 	-	AAC.
;                  $name 		-	The stream name... NULL = no name.
;                  $url 		-	The URL, for example, of the radio station's webpage... NULL = no URL.
;                  $genre 		-	The genre... NULL = no genre.
;                  $desc 		-	Description... NULL = no description. This applies to Icecast only.
;                  $headers 	-	Other headers to send to the server... NULL = none. Each header should end with a carriage return and line feed ("\r\n").
;                  $bitrate 	-	The bitrate (in kbps) of the encoder output... 0 = undefined bitrate. In cases where the bitrate is a "quality" (rather than CBR) setting, the headers parameter can be used to communicate that instead, eg. "ice-bitrate: Quality 0\r\n".
;                  $pub 		-	Public? If TRUE, the stream is added to the public directory of streams, at shoutcast.com or dir.xiph.org (or as defined in the server config).
; Return values .: Success      - 	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_CastInit($handle, $server, $pass, $content, $name, $url, $genre, $desc, $headers, $bitrate, $pub)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_CastInit", "dword", $handle, "str", $server, "str", $pass, "str", $content, "str", $name, "str", $url, "str", $genre, "str", $desc, "str", $headers, "dword", $bitrate, "int", $pub)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_CastInit

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_CastSetTitle
; Description ...: Sets the title of a cast stream.
; Syntax ........: _BASS_Encode_CastSetTitle($handle, $title, $url)
; Parameters ....: $handle		-	The encoder handle
;                  $title		-	The title.
;                  $url			-	URL to go with the title... NULL = no URL. This applies to Shoutcast only.
; Return values .: Success		-	Returns True
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_CastSetTitle($handle, $title, $url)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "int", "BASS_Encode_CastSetTitle", "dword", $handle, "str", $title, "str", $url)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_CastSetTitle

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_Encode_CastGetStats
; Description ...: Retrieves stats from the Shoutcast or Icecast server.
; Syntax ........: _BASS_Encode_CastGetStats($handle, $stype, $pass)
; Parameters ....: $handle		-	The encoder handle
;                  $stype		-	The type of stats to retrieve. One of the following.
;                  		|$BASS_ENCODE_STATS_SHOUT 		-	Shoutcast stats, including listener information and additional server information.
;                  		|$BASS_ENCODE_STATS_ICE 		-	Icecast mount-point listener information.
;                  		|$BASS_ENCODE_STATS_ICESERV 	-	Icecast server stats, including information on all mount points on the server.
;                  $pass		-	Password when retrieving Icecast server stats... NULL = use the password provided in the _BASS_Encode_CastInit call.
; Return values .: Success		-	the stats are returned
;				   Failure      - 	Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_Encode_CastGetStats($handle, $stype, $pass)
	Local $BASSENC_ret_ = DllCall($_ghBassEncDll, "str", "BASS_Encode_CastGetStats", "dword", $handle, "dword", $stype, "str", $pass)
	If @error Then Return SetError(@error, @extended, 0)
	Local $_gBassEncError = _BASS_ErrorGetCode()
	If $_gBassEncError <> 0 Then
		Return SetError($_gBassEncError, "", 0)
	Else
		Return SetError(0, "", $BASSENC_ret_[0])
	EndIf
EndFunc   ;==>_BASS_Encode_CastGetStats