#include-once
#include "Bass.au3"
#include "GDIPlus.au3"

; #INDEX# =======================================================================================================================
; Title .........: BassExt.au3 BETA
; Description ...: Extended functions for bass.au3
;                  Callback routines, Peak & Loudness, Phasecorrelation, drawing Waveform, Binarybuffer, & more to come
; Author ........: Eukalyptus, Prog@ndy
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; Init
;			_BASS_EXT_Startup
;
; Level functions
;           _BASS_EXT_ChannelSetLevelDsp
;           _BASS_EXT_ChannelRemoveLevelDsp
;           _BASS_EXT_ChannelGetLevel
;           _BASS_EXT_ChannelGetPhaseData
;           _BASS_EXT_ChannelGetPhaseDataEx
;           _BASS_EXT_ChannelGetWaveform
;           _BASS_EXT_ChannelGetWaveformEx
;           _BASS_EXT_ChannelGetWaveformDecode
;           _BASS_EXT_GDIpBitmapCreateWaveform
;           _BASS_EXT_WaveformSetWidth
;           _BASS_EXT_CreateFFT
;           _BASS_EXT_ChannelGetFFT
;           _BASS_EXT_Level2dB
;           _BASS_EXT_dB2Level
;
; Buffer functions
;           _BASS_EXT_StreamPipeCreate
;           _BASS_EXT_MemoryBufferCreate
;           _BASS_EXT_MemoryBufferDestroy
;           _BASS_EXT_MemoryBufferGetSize
;           _BASS_EXT_MemoryBufferGetData
;           _BASS_EXT_MemoryBufferAddData
;           _BASS_EXT_StreamPutBufferData
;           _BASS_EXT_StreamPutFileBufferData
;
; Callback functions
;           $BASS_EXT_FILEPROCS
;           $BASS_EXT_FileSeekProc
;           $BASS_EXT_FileReadProc
;           $BASS_EXT_FileLenProc
;           $BASS_EXT_FileCloseProc
;           $BASS_EXT_StreamProc
;           $BASS_EXT_RecordProc
;           $BASS_EXT_EncodeProc
;           $BASS_EXT_DSPProc
;           $BASS_EXT_DownloadProc
;           $BASS_EXT_AsioProc
;           $BASS_EXT_BPMPROC
;           $BASS_EXT_BPMBEATPROC
;           $BASS_EXT_MidiInProc
;
; Misc functions
;           _BASS_EXT_SpVoice2Memory
;           _BASS_EXT_MakeWave
;           _BASS_EXT_LoadWave
;           _BASS_EXT_SaveWave
;           _BASS_EXT_Generator
;           _BASS_EXT_Note2Freq
;           _BASS_EXT_Freq2Note
;           _BASS_EXT_Note2Name
;           _BASS_EXT_Name2Note
;
; #INTERNAL_USE_ONLY#============================================================================================================
;			__BASS_EXT_GetCallBackPointer()
; ===============================================================================================================================


;Global $BASS_EXT_AsioNotifyProc = 0
;Global $BASS_EXT_SyncProc = 0
;Global $BASS_EXT_EncodeNotifyProc = 0
;Global $BASS_EXT_BPMPROCESSPROC = 0
Global $BASS_EXT_BPMPROC = 0
Global $BASS_EXT_BPMBEATPROC = 0
Global $tBASS_EXT_FILEPROCS = DllStructCreate("ptr;ptr;ptr;ptr")
Global $BASS_EXT_FILEPROCS = DllStructGetPtr($tBASS_EXT_FILEPROCS)
Global $BASS_EXT_FileSeekProc = 0
Global $BASS_EXT_FileReadProc = 0
Global $BASS_EXT_FileLenProc = 0
Global $BASS_EXT_FileCloseProc = 0
Global $BASS_EXT_StreamProc = 0
Global $BASS_EXT_RecordProc = 0
Global $BASS_EXT_EncodeProc = 0
Global $BASS_EXT_DSPProc = 0
Global $BASS_EXT_DownloadProc = 0
Global $BASS_EXT_AsioProc = 0
Global $BASS_EXT_MidiInProc = 0

Global $BASS_EXT_DspLevelProc = 0

Global Const $BASS_EXT_STREAMPROC_DUMMY = 0
Global Const $BASS_EXT_STREAMPROC_PUSH = -1
Global Const $BASS_EXT_STREAMFILE_BUFFERPUSH = 1
Global Const $BASS_EXT_STRUCT_BYTE = 2

Global $tagBPM = "dword Count;float BPM[99999];float Average"
Global $tagBPMBeat = "dword Count;double BeatPos[99999]"

Global $_ghBassEXTDll = -1
Global $BASS_EXT_DLL_UDF_VER = "1.0.2.0"
Global $BASS_EXT_UDF_VER = "10.0"

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Startup
; Description ...: Starts up BASS functions.
; Syntax ........: _BASS_EXT_Startup($sBassEXTDLL = "")
; Parameters ....: -	$sBassExtDLL	-	The relative path to BassEXT.dll.
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
Func _BASS_EXT_Startup($sBassEXTDLL = "")
	If $_ghBassEXTDll <> -1 Then Return True
	If Not $sBassEXTDLL Then $sBassEXTDLL = @ScriptDir & "\BassExt.dll"

	If Not FileExists($sBassEXTDLL) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)

	Local $sBit = __BASS_LibraryGetArch($sBassEXTDLL)
	Select
		Case $sBit = "32" And @AutoItX64
			ConsoleWrite(@CRLF & "!BassExt.dll is for 32bit only!" & @CRLF & "Run/compile Script at 32bit" & @CRLF)
		Case $sBit = "64" And Not @AutoItX64
			ConsoleWrite(@CRLF & "!BassExt.dll is for 64bit only!" & @CRLF & "use 32bit version of BassExt.dll" & @CRLF)
	EndSelect

	If $BASS_STARTUP_VERSIONCHECK Then
		If Not @AutoItX64 And _VersionCompare(FileGetVersion($sBassEXTDLL), $BASS_EXT_DLL_UDF_VER) <> 0 Then ConsoleWrite(@CRLF & "!This version of BASSEXT.au3 is made for BassEXT.dll V" & $BASS_EXT_DLL_UDF_VER & ".  Please update" & @CRLF)
		If $BASS_EXT_UDF_VER <> $BASS_UDF_VER Then ConsoleWrite("!This version of BASSEXT.au3 (v" & $BASS_EXT_UDF_VER & ") may not be compatible to BASS.au3 (v" & $BASS_UDF_VER & ")" & @CRLF)
	EndIf

	$_ghBassEXTDll = DllOpen($sBassEXTDLL)
	If Not @error Then ; Get Pointer to the callback functions
		$BASS_EXT_StreamProc = __BASS_EXT_GetCallBackPointer(1)
		If @error Then Return SetError(1, 1, 0)
		$BASS_EXT_RecordProc = __BASS_EXT_GetCallBackPointer(2)
		If @error Then Return SetError(1, 2, 0)
		$BASS_EXT_EncodeProc = __BASS_EXT_GetCallBackPointer(3)
		If @error Then Return SetError(1, 3, 0)
		$BASS_EXT_DSPProc = __BASS_EXT_GetCallBackPointer(4)
		If @error Then Return SetError(1, 4, 0)
		$BASS_EXT_DownloadProc = __BASS_EXT_GetCallBackPointer(5)
		If @error Then Return SetError(1, 5, 0)
		$BASS_EXT_AsioProc = __BASS_EXT_GetCallBackPointer(6)
		If @error Then Return SetError(1, 6, 0)
		$BASS_EXT_DspLevelProc = __BASS_EXT_GetCallBackPointer(7)
		If @error Then Return SetError(1, 7, 0)
		$BASS_EXT_FileCloseProc = __BASS_EXT_GetCallBackPointer(8)
		If @error Then Return SetError(1, 8, 0)
		$BASS_EXT_FileLenProc = __BASS_EXT_GetCallBackPointer(9)
		If @error Then Return SetError(1, 9, 0)
		$BASS_EXT_FileReadProc = __BASS_EXT_GetCallBackPointer(10)
		If @error Then Return SetError(1, 10, 0)
		$BASS_EXT_FileSeekProc = __BASS_EXT_GetCallBackPointer(11)
		If @error Then Return SetError(1, 11, 0)
		DllStructSetData($tBASS_EXT_FILEPROCS, 1, $BASS_EXT_FileCloseProc)
		DllStructSetData($tBASS_EXT_FILEPROCS, 2, $BASS_EXT_FileLenProc)
		DllStructSetData($tBASS_EXT_FILEPROCS, 3, $BASS_EXT_FileReadProc)
		DllStructSetData($tBASS_EXT_FILEPROCS, 4, $BASS_EXT_FileSeekProc)
		$BASS_EXT_BPMPROC = __BASS_EXT_GetCallBackPointer(12)
		If @error Then Return SetError(1, 12, 0)
		$BASS_EXT_BPMBEATPROC = __BASS_EXT_GetCallBackPointer(13)
		If @error Then Return SetError(1, 13, 0)
		$BASS_EXT_MidiInProc = __BASS_EXT_GetCallBackPointer(14)
		If @error Then Return SetError(1, 14, 0)
	EndIf
	Return $_ghBassEXTDll <> -1
EndFunc   ;==>_BASS_EXT_Startup


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_StreamPipeCreate
; Description ...: Set a Stream to use in a callbackfuntion
; Syntax ........: _BASS_EXT_StreamPipeCreate($hStream, $iType = 0)
; Parameters ....: -$hStream 			-	The handle of the stream
;                   -$iType             -   The type of the stream
;                                           - $BASS_EXT_STREAMPROC_DUMMY: 	Stream is STREAMPROC_DUMMY and the sampledata is feed through to apply DSP/FX
;                                           - $BASS_EXT_STREAMPROC_PUSH: 	Stream is STREAMPROC_PUSH and the sampledata is pushed to it by BASS_StreamPutData
;                                                                           In case of AsioOut and StreamProc: sampledata is get from it by _BASS_ChannelGetData
;                                           - $BASS_EXT_StreamPutFileData: 	Stream was created by BASS_StreamCreateFileUser and sampledata is pushed to it by BASS_StreamPutFileData
;
; Return values .: Success      - Returns If successful, then a array to pass as userdata is returned
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: BASS_ChannelGetData, BASS_StreamPutData, BASS_StreamPutFileData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_StreamPipeCreate($hStream, $iType = 0)
	If Not $hStream Then Return SetError(1, 0, 0)
	Local $tStruct = DllStructCreate("UINT_PTR;INT_PTR")
	DllStructSetData($tStruct, 1, $hStream)
	DllStructSetData($tStruct, 2, $iType)
	Local $aReturn[2]
	$aReturn[0] = DllStructGetPtr($tStruct)
	$aReturn[1] = $tStruct
	Return $aReturn
EndFunc   ;==>_BASS_EXT_StreamPipeCreate

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MemoryBufferGetSize
; Description ...: How many bytes are in the buffer?
; Syntax ........: _BASS_EXT_MemoryBufferGetSize($aBuffer)
; Parameters ....: -   $aBuffer           - Buffer as returned by _BASS_EXT_MemoryBufferCreate
; Return values .: Success      - Returns used buffer in bytes
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MemoryBufferCreate, Binary, BinaryLen, BinaryMid
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MemoryBufferGetSize($aBuffer)
	If Not IsArray($aBuffer) Or Not IsDllStruct($aBuffer[3]) Then Return SetError(1, 0, 0)
	Return DllStructGetData($aBuffer[3], 1)
EndFunc   ;==>_BASS_EXT_MemoryBufferGetSize

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MemoryBufferAddData
; Description ...: Adds binary data to the buffer
; Syntax ........: _BASS_EXT_MemoryBufferAddData($aBuffer, $bData)
; Parameters ....: -   $aBuffer           - Buffer as returned by _BASS_EXT_MemoryBufferCreate
;                   -   $bData             - Binarydata to add at the end of the buffer
; Return values .: Success      - Returns added bytes
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MemoryBufferCreate, Binary, BinaryLen, BinaryMid
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MemoryBufferAddData($aBuffer, $bData)
	If Not IsArray($aBuffer) Then Return SetError(1, 0, 0)
	Local $iLength = BinaryLen($bData)
	Local $tData = DllStructCreate("byte[" & $iLength & "]")
	DllStructSetData($tData, 1, $bData)
	Local $aRet = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_MemoryBufferAddData", "ptr", $aBuffer[2], "ptr", DllStructGetPtr($tData), "dword", $iLength)
	Switch @error
		Case True
			Return SetError(@error, 0, 0)
		Case Else
			Return SetError(0, 0, $aRet[0])
	EndSwitch
EndFunc   ;==>_BASS_EXT_MemoryBufferAddData

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MemoryBufferGetData
; Description ...: Returns bufferdata
; Syntax ........: _BASS_EXT_MemoryBufferGetData($aBuffer, $iLength, $iOffset = 0, $bRemove = True)
; Parameters ....: -   $aBuffer           - Buffer as returned by _BASS_EXT_MemoryBufferCreate
;                   -   $iLength           - Length of data in bytes
;                   -   $iOffset           - Offset of data in bytes
;                   -   $bRemove           - If True then the Data is removed from the buffer
; Return values .: Success      - Returns binary bufferdata
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MemoryBufferCreate, Binary, BinaryLen, BinaryMid
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MemoryBufferGetData($aBuffer, $iLength, $iOffset = 0, $bRemove = True)
	If Not IsArray($aBuffer) Then Return SetError(1, 0, 0)
	If $iLength <= 0 Or $iOffset < 0 Then Return SetError(1, 0, 0)
	Local $tData = DllStructCreate("byte[" & $iLength & "]")
	Local $aRet = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_MemoryBufferGetData", "ptr", $aBuffer[2], "ptr", DllStructGetPtr($tData), "dword", $iLength, "dword", $iOffset, "dword", $bRemove)
	Switch @error
		Case True
			Return SetError(@error, 0, 0)
		Case Else
			$iLength = $aRet[0]
			Local $bData = DllStructGetData($tData, 1)
			$bData = BinaryMid($bData, 1, $iLength)
			Return SetError(0, 0, $bData)
	EndSwitch
EndFunc   ;==>_BASS_EXT_MemoryBufferGetData

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_StreamPutBufferData
; Description ...: Puts the bufferdata to a STREAMPROC_PUSH stream
; Syntax ........: _BASS_EXT_StreamPutBufferData($hHandle, $aBuffer, $iBytes, $bRemove = True)
; Parameters ....: -   $hHandle           - The stream handle
;                   -   $aBuffer           - Buffer as returned by _BASS_EXT_MemoryBufferCreate
;                   -   $iBytes            - Number of bytes
;                   -   $bRemove           - If True then the Data is removed from the buffer
; Return values .: Success      - Returns amount of queued data
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MemoryBufferCreate, _BASS_StreamCreate, _BASS_StreamPutData, $STREAMPROC_PUSH
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_StreamPutBufferData($hHandle, $aBuffer, $iBytes, $bRemove = True)
	If Not IsArray($aBuffer) Then Return SetError(1, 0, 0)
	If Not $hHandle Then Return SetError(1, 0, 0)
	Local $iLength = _BASS_EXT_MemoryBufferGetSize($aBuffer)
	If $iLength < 1 Then Return SetError(0, 1, False)
	If $iBytes > $iLength Then $iBytes = $iLength
	Local $bData = _BASS_EXT_MemoryBufferGetData($aBuffer, $iBytes, 0, False)
	Local $tData = DllStructCreate("Byte[" & $iBytes & "]")
	DllStructSetData($tData, 1, $bData)
	$iBytes = _BASS_StreamPutData($hHandle, DllStructGetPtr($tData), $iBytes)
	If @error Then Return SetError(@error, 0, 0)
	If $bRemove And $iBytes Then _BASS_EXT_MemoryBufferGetData($aBuffer, $iBytes, 0, True)
	Return SetError(0, 0, $iBytes)
EndFunc   ;==>_BASS_EXT_StreamPutBufferData

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_StreamPutFileBufferData
; Description ...: Puts the bufferdata to a buffered _BASS_StreamCreateFileUser stream
; Syntax ........: _BASS_EXT_StreamPutFileBufferData($hHandle, $aBuffer, $iBytes, $bRemove = True)
; Parameters ....: -   $hHandle           - The stream handle
;                   -   $aBuffer           - Buffer as returned by _BASS_EXT_MemoryBufferCreate
;                   -   $iBytes            - Number of bytes
;                   -   $bRemove           - If True then the Data is removed from the buffer
; Return values .: Success      - Returns bytes read from buffer
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MemoryBufferCreate, _BASS_StreamCreateFileUser, _BASS_StreamPutFileData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_StreamPutFileBufferData($hHandle, $aBuffer, $iBytes, $bRemove = True)
	If Not IsArray($aBuffer) Then Return SetError(1, 0, 0)
	If Not $hHandle Then Return SetError(1, 0, 0)
	Local $iLength = _BASS_EXT_MemoryBufferGetSize($aBuffer)
	If $iLength < 1 Then Return SetError(0, 1, False)
	If $iBytes > $iLength Then $iBytes = $iLength
	Local $bData = _BASS_EXT_MemoryBufferGetData($aBuffer, $iBytes, 0, False)
	Local $tData = DllStructCreate("Byte[" & $iBytes & "]")
	DllStructSetData($tData, 1, $bData)
	$iBytes = _BASS_StreamPutFileData($hHandle, DllStructGetPtr($tData), $iBytes)
	If @error Then Return SetError(@error, 0, 0)
	If $bRemove And $iBytes Then _BASS_EXT_MemoryBufferGetData($aBuffer, $iBytes, 0, True)
	Return SetError(0, 0, $iBytes)
EndFunc   ;==>_BASS_EXT_StreamPutFileBufferData

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MemoryBufferCreate
; Description ...: Creates a binary buffer
; Syntax ........: _BASS_EXT_MemoryBufferCreate($iSize = 10000000)
; Parameters ....: -	$iSize		-	Size of memory to be use, max 100000000 (~100MB)
; Return values .: Success      - Returns an Array containing all necessary data
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MemoryBufferCreate($iSize = 10000000)
	If $iSize > 100000000 Then $iSize = 100000000 ; 100 MB max
	Local $tBuffer = DllStructCreate("dword;dword;byte[" & String($iSize) & "]")
	If @error Then Return SetError(1, 0, 0)
	DllStructSetData($tBuffer, 1, 0)
	DllStructSetData($tBuffer, 2, $iSize)
	Local $tUser = DllStructCreate("UINT_PTR;INT_PTR")
	DllStructSetData($tUser, 1, DllStructGetPtr($tBuffer))
	DllStructSetData($tUser, 2, $BASS_EXT_STRUCT_BYTE)
	Local $aReturn[4]
	$aReturn[0] = DllStructGetPtr($tUser)
	$aReturn[1] = $tUser
	$aReturn[2] = DllStructGetPtr($tBuffer)
	$aReturn[3] = $tBuffer
	Return $aReturn
EndFunc   ;==>_BASS_EXT_MemoryBufferCreate

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MemoryBufferDestroy
; Description ...: Creates a binary buffer
; Syntax ........: _BASS_EXT_MemoryBufferDestroy(ByRef $aBuffer)
; Parameters ....: -	$aBuffer		-	Buffer as returned by _BASS_EXT_MemoryBufferCreate
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MemoryBufferDestroy(ByRef $aBuffer)
	If Not IsArray($aBuffer) Then Return SetError(1, 0, 0)
	$aBuffer[1] = 0
	$aBuffer[3] = 0
	Local $aReturn = 0
	$aBuffer = $aReturn
	Return True
EndFunc   ;==>_BASS_EXT_MemoryBufferDestroy




; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetWaveform
; Description ...: Returns Waveform of a stream
; Syntax ........: _BASS_EXT_ChannelGetWaveform($handle, $samples, $flag = 3)
; Parameters ....: -	$handle		-	Handle The channel handle...
;										-	HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $samples    -   number of samples to return (min 32, max 2048)
;                   -   $flag       -   [0]: returns waveform of left channel
;                                       [1]: returns waveform of right channel
;                                       [2]: returns 2 arrays in the return array - see example
;                                       [3]: returns mono waveform left + right
; Return values .: Success      - Returns Array of waveform data.
;									- [0][0] = Number of elements.
;									- [1][0] = Sample 1 X-Value [-1..1]
;									- [1][1] = Sample 1 Y-Value [-1..1]
;                                   - [2][0] = Sample 2 X-Value [-1..1]
;									- [2][1] = Sample 2 Y-Value [-1..1]
;                                   - [n][0] = Sample n X-Value [-1..1]
;									- [n][1] = Sample n Y-Value [-1..1]
;                  Failure      - Returns 0 and sets @ERROR
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: calculate the coordinates for each sample:
;                                   For $i=1 To $aReturn[0][0]
;                                   	$aReturn[$i][0] = $aReturn[$i][0] * $SizeX + $OffsetX
;                                   	$aReturn[$i][1] = $aReturn[$i][1] * $SizeY + $OffsetY
;                                   Next
;                  and you can use $aReturn directly with:
;                                   _GDIPlus_GraphicsDrawClosedCurve
;                                   _GDIPlus_GraphicsDrawPolygon
;                                   _GDIPlus_GraphicsDrawCurve
;                                   _GDIPlus_GraphicsFillClosedCurve
;                                   _GDIPlus_GraphicsFillPolygon
;                  to draw the waveform
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetWaveform($handle, $samples, $flag = 3)
	If $samples < 32 Then $samples = 32
	If $samples > 2048 Then $samples = 2048
	Local $tStruct = DllStructCreate("float[" & $samples * 2 & "]")
	If Not $handle Then Return SetError(1, 0, 0)
	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_ChannelGetWaveform", "dword", $handle, "dword", $samples, "ptr", DllStructGetPtr($tStruct))
	If @error Then
		Return SetError(@error, 0, 0)
	Else
		Switch $flag
			Case 0 ;left
				Local $aReturn[$samples + 1][2]
				$aReturn[0][0] = $samples
				For $i = 1 To $samples
					$aReturn[$i][0] = $i / $samples
					$aReturn[$i][1] = DllStructGetData($tStruct, 1, $i * 2 - 1)
				Next
				Return SetError($bass_ext_ret[0] = False, 0, $aReturn)
			Case 1 ; right
				Local $aReturn[$samples + 1][2]
				$aReturn[0][0] = $samples
				For $i = 1 To $samples
					$aReturn[$i][0] = $i / $samples
					$aReturn[$i][1] = DllStructGetData($tStruct, 1, $i * 2)
				Next
				Return SetError($bass_ext_ret[0] = False, 0, $aReturn)
			Case 2 ; Array in Array
				Local $aReturn[2], $aReturnL[$samples + 1][2], $aReturnR[$samples + 1][2]
				$aReturnL[0][0] = $samples
				$aReturnR[0][0] = $samples
				For $i = 1 To $samples
					$aReturnL[$i][0] = $i / $samples
					$aReturnR[$i][0] = $aReturnL[$i][0]
					$aReturnL[$i][1] = DllStructGetData($tStruct, 1, $i * 2 - 1)
					$aReturnR[$i][1] = DllStructGetData($tStruct, 1, $i * 2)
				Next
				$aReturn[0] = $aReturnL
				$aReturn[1] = $aReturnR
				Return SetError($bass_ext_ret[0] = False, 0, $aReturn)
			Case Else ; mix
				Local $aReturn[$samples + 1][2]
				$aReturn[0][0] = $samples
				For $i = 1 To $samples
					$aReturn[$i][0] = $i / $samples
					$aReturn[$i][1] = (DllStructGetData($tStruct, 1, $i * 2 - 1) + DllStructGetData($tStruct, 1, $i * 2)) / 2
				Next
				Return SetError($bass_ext_ret[0] = False, 0, $aReturn)
		EndSwitch
	EndIf
EndFunc   ;==>_BASS_EXT_ChannelGetWaveform

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetWaveformEx
; Description ...: Returns Waveform of a stream
; Syntax ........: _BASS_EXT_ChannelGetWaveformEx($hHandle, $iSamples, $iXLeft, $iYLeft, $iWLeft, $iHLeft, $iXRight, $iYRight, $iWRight, $iHRight)
; Parameters ....: -	$hHandle     -  Handle The channel handle...
;                                       -  HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $iSamples    -  number of samples to return (min 32, max 2048)
;                   -   $iXLeft      -  X-Coordinate of left waveform
;                   -   $iYLeft      -  Y-Coordinate of left waveform
;                   -   $iWLeft      -  Width of left waveform
;                   -   $iHLeft      -  Height of left waveform
;                   -   $iXRight     -  X-Coordinate of right waveform
;                   -   $iYRight     -  Y-Coordinate of right waveform
;                   -   $iWRight     -  Width of right waveform
;                   -   $iHRight     -  Height of right waveform
; Return values .: Success      - Returns Array of waveform data.
;									- [0] Struct-Pointer of left waveform as used in
;                                           _GDIPlus_GraphicsDrawClosedCurve
;                                           _GDIPlus_GraphicsDrawPolygon
;                                           _GDIPlus_GraphicsDrawCurve
;                                           _GDIPlus_GraphicsFillClosedCurve
;                                           _GDIPlus_GraphicsFillPolygon
;									- [1]  Struct-Pointer of right waveform
;									- [2]  Number of elements in the struct
;                                   - [3]  The left dllstruct
;									- [4]  The right dllstruct
;                  Failure      - Returns 0 and sets @ERROR
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: You have to call the GDI+ function directly to draw the waveform:
;                  DllCall($ghGDIPDll, "int", "GdipDrawCurve", "handle", $hGraphics, "handle", $hPenLeft, "ptr", $aWave[0], "int", $aWave[2])
;                  DllCall($ghGDIPDll, "int", "GdipDrawCurve", "handle", $hGraphics, "handle", $hPenRight, "ptr", $aWave[1], "int", $aWave[2])
;                  this methode is faster than _BASS_EXT_ChannelGetWaveform & _GDIPlus_GraphicsDrawClosedCurve
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetWaveformEx($hHandle, $iSamples, $iXLeft, $iYLeft, $iWLeft, $iHLeft, $iXRight, $iYRight, $iWRight, $iHRight)
	If $iSamples < 32 Then $iSamples = 32
	If $iSamples > 2048 Then $iSamples = 2048
	Local $tStructL = DllStructCreate("float[" & $iSamples * 2 & "]")
	Local $tStructR = DllStructCreate("float[" & $iSamples * 2 & "]")
	Local $aReturn[5]
	$aReturn[0] = DllStructGetPtr($tStructL)
	$aReturn[1] = DllStructGetPtr($tStructR)
	$aReturn[3] = $tStructL
	$aReturn[4] = $tStructR
	If Not $hHandle Then Return SetError(1, 0, $aReturn)
	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_ChannelGetWaveformEx", "dword", $hHandle, "dword", $iSamples, "dword", $iXLeft, "dword", $iYLeft, "dword", $iWLeft, "dword", $iHLeft, "dword", $iXRight, "dword", $iYRight, "dword", $iWRight, "dword", $iHRight, "ptr", $aReturn[0], "ptr", $aReturn[1])
	If @error Or Not IsArray($bass_ext_ret) Then Return SetError(1, 1, $aReturn)
	$aReturn[2] = $bass_ext_ret[0]
	Return $aReturn
EndFunc   ;==>_BASS_EXT_ChannelGetWaveformEx

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetPhaseData
; Description ...: Retrieves phase data of a stream, MOD music or recording channel.
; Syntax ........: _BASS_EXT_ChannelGetPhaseData($handle, $samples)
; Parameters ....: -	$handle		-	Handle The channel handle...
;										-	HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $samples    -   number of samples to return (min 32, max 2048)
; Return values .: Success      - Returns Array of Phase information.
;									- [0][0] = Number of elements.
;									- [0][1] = phase correlation [-1..1] of max peak
;									- [1][0] = Sample 1 Vectorscope X-Value [-1..1]
;									- [1][1] = Sample 1 Vectorscope Y-Value [-1..1]
;                                   - [2][0] = Sample 2 Vectorscope X-Value [-1..1]
;									- [2][1] = Sample 2 Vectorscope Y-Value [-1..1]
;                                   - [n][0] = Sample n Vectorscope X-Value [-1..1]
;									- [n][1] = Sample n Vectorscope Y-Value [-1..1]
;                  Failure      - Returns empty array and sets @ERROR
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: calculate the coordinates for each sample:
;                                   For $i=1 To $aReturn[0][0]
;                                   	$aReturn[$i][0] = $aReturn[$i][0] * $SizeX + $OffsetX
;                                   	$aReturn[$i][1] = $aReturn[$i][1] * $SizeY + $OffsetY
;                                   Next
;                  and you can use $aReturn directly with:
;                                   _GDIPlus_GraphicsDrawClosedCurve
;                                   _GDIPlus_GraphicsDrawPolygon
;                                   _GDIPlus_GraphicsDrawCurve
;                                   _GDIPlus_GraphicsFillClosedCurve
;                                   _GDIPlus_GraphicsFillPolygon
;                  to draw the vectorscope
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetPhaseData($handle, $samples)
	If $samples < 32 Then $samples = 32
	If $samples > 2048 Then $samples = 2048
	Local $tStruct = DllStructCreate("float[" & $samples + 1 & "];float[" & $samples + 1 & "]")
	Local $aReturn[$samples + 2][2]
	$aReturn[0][0] = $samples
	If Not $handle Then Return SetError(1, 0, $aReturn)
	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_ChannelGetPhaseData", "dword", $handle, "dword", $samples, "ptr", DllStructGetPtr($tStruct))
	If @error Then
		Return SetError(@error, 0, $aReturn)
	Else
		For $i = 1 To $samples + 1
			$aReturn[$i - 1][0] = DllStructGetData($tStruct, 1, $i)
			$aReturn[$i - 1][1] = DllStructGetData($tStruct, 2, $i)
		Next
		Return SetError($bass_ext_ret[0] = False, 0, $aReturn)
	EndIf
EndFunc   ;==>_BASS_EXT_ChannelGetPhaseData

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetPhaseDataEx
; Description ...: Returns phase data of a stream, MOD music or recording channel to draw a vectorscope using GDI+
; Syntax ........: _BASS_EXT_ChannelGetPhaseDataEx($hHandle, $iSamples, $iX, $iY, $iW, $iH)
; Parameters ....: -	$hHandle		-	Handle The channel handle...
;											HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $iSamples       -   number of samples to return (min 32, max 2048)
;                   -   $iX             -   X-Coordinate of the waveform
;                   -   $iY             -   Y-Coordinate of the waveform
;                   -   $iW             -   Width of the waveform
;                   -   $iH             -   Height of the waveform
; Return values .: Success      - Returns Array of Phase information.
;                                   - [0] Struct-Pointer as used in
;                                           _GDIPlus_GraphicsDrawClosedCurve
;                                           _GDIPlus_GraphicsDrawPolygon
;                                           _GDIPlus_GraphicsDrawCurve
;                                           _GDIPlus_GraphicsFillClosedCurve
;                                           _GDIPlus_GraphicsFillPolygon
;                                   - [1] Number of elements in the struct
;                                   - [2] The dllstruct itself (must be returned, otherwise the struct will be deleted by AutoIt)
;                  Failure      - Returns empty array and sets @ERROR
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: You have to call the GDI+ function directly to draw the vectorscope:
;                  DllCall($ghGDIPDll, "int", "GdipDrawCurve", "handle", $hGraphics, "handle", $hPen, "ptr", $aPhase[0], "int", $aPhase[1])
;                  this methode is faster than _BASS_EXT_ChannelGetPhaseData & _GDIPlus_GraphicsDrawClosedCurve
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetPhaseDataEx($hHandle, $iSamples, $iX, $iY, $iW, $iH)
	If $iSamples < 32 Then $iSamples = 32
	If $iSamples > 2048 Then $iSamples = 2048
	Local $tStruct = DllStructCreate("float[" & $iSamples * 2 & "]")
	Local $aReturn[3]
	$aReturn[0] = DllStructGetPtr($tStruct)
	$aReturn[2] = $tStruct
	If Not $hHandle Then Return SetError(1, 0, $aReturn)
	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_ChannelGetPhaseDataEx", "dword", $hHandle, "dword", $iSamples, "dword", $iX, "dword", $iY, "dword", $iW, "dword", $iH, "ptr", $aReturn[0])
	If @error Then Return SetError(@error, 0, $aReturn)
	$aReturn[1] = $bass_ext_ret[0]
	Return $aReturn
EndFunc   ;==>_BASS_EXT_ChannelGetPhaseDataEx

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_CreateFFT
; Description ...: Creates a struct to draw a polyline with GDI+
; Syntax ........: _BASS_EXT_CreateFFT($iCnt, $iX, $iY, $iW, $iH, $iDistance = 1, $bMode = False)
; Parameters ....: -   $iCnt           -   number of bands
;                   -   $iX             -   X position
;                   -   $iY             -   Y position
;                   -   $iW             -   Width
;                   -   $iH             -   Height
;                   -   $iDistance      -   Distance between the bars
;                   -   $bMode          -   False : the band frequencies are logarithmic, but if you use to much bands, the frequencies may overlap
;                                           True : no overlapping of frequencies, but not exact logarithmic
; Return values .: Success      - Returns Array to use with _BASS_EXT_ChannelGetFFT
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_ChannelGetFFT
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_CreateFFT($iCnt, $iX, $iY, $iW, $iH, $iDistance = 1, $bMode = False)
	Local $aReturn[7]
	Local $iXPos, $nBarW = ($iW / $iCnt) - $iDistance
	Local $tStruct = DllStructCreate("float[" & $iCnt * 8 & "]")
	For $i = 1 To $iCnt
		$iXPos = Round(($nBarW * ($i - 1)) + ($iDistance * ($i - 1)) + $iX)
		DllStructSetData($tStruct, 1, $iXPos, ($i - 1) * 8 + 1) ; X1
		DllStructSetData($tStruct, 1, $iY + $iH, ($i - 1) * 8 + 2) ; Y1
		DllStructSetData($tStruct, 1, $iXPos, ($i - 1) * 8 + 3) ; X2
		DllStructSetData($tStruct, 1, $iY + $iH, ($i - 1) * 8 + 4) ; Y2
		DllStructSetData($tStruct, 1, Round($iXPos + $nBarW), ($i - 1) * 8 + 5) ; X3
		DllStructSetData($tStruct, 1, $iY + $iH, ($i - 1) * 8 + 6) ; Y3
		DllStructSetData($tStruct, 1, Round($iXPos + $nBarW), ($i - 1) * 8 + 7) ; X4
		DllStructSetData($tStruct, 1, $iY + $iH, ($i - 1) * 8 + 8) ; Y4
	Next
	$aReturn[0] = DllStructGetPtr($tStruct)
	$aReturn[1] = $iCnt * 4
	$aReturn[2] = $tStruct
	$aReturn[3] = $iCnt
	$aReturn[4] = $iY
	$aReturn[5] = $iH
	$aReturn[6] = $bMode
	Return $aReturn
EndFunc   ;==>_BASS_EXT_CreateFFT

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetFFT
; Description ...: Gets FFT data of a channel and sets the bands in the FFT struct for use with GDI+
; Syntax ........: _BASS_EXT_ChannelGetFFT($hHandle, $aFFT, $iFallOff = 6, $bUseMixer = False)
; Parameters ....: -   $hHandle        -   Handle The channel handle...
;                                             -   HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $aFFT           -   Array as returned by _BASS_EXT_CreateFFT
;                   -   $iFallOff       -   Falloff of the bands ((old - new) / $iFallOff)
; Return values .: Success      - Returns True
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: DllCall($ghGDIPDll, "int", "GdipFillPolygon", "handle", $hGraphics, "handle", $hBrushFFT, "ptr", $aFFT[0], "int", $aFFT[1], "int", "FillModeAlternate")
; Related .......: _BASS_EXT_CreateFFT
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetFFT($hHandle, $aFFT, $iFallOff = 6, $bUseMixer = False)
	If Not IsArray($aFFT) Or UBound($aFFT) <> 7 Or Not IsDllStruct($aFFT[2]) Or Not $hHandle Then Return SetError(1, 0, 0)
	If $iFallOff < 2 Then $iFallOff = 2
	Local $tFFT = DllStructCreate("float[4096]")
	Local $pFFT = DllStructGetPtr($tFFT)
	Local $iBytes
	Switch $bUseMixer
		Case False
			$iBytes = _BASS_ChannelGetData($hHandle, $pFFT, $BASS_DATA_FFT8192)
			If @error Or Not $iBytes Then Return SetError(1, 1, 0)
		Case Else
			Local $sCall = "_BASS_Mixer_ChannelGetData"
			$iBytes = Call($sCall, $hHandle, $pFFT, $BASS_DATA_FFT8192)
			If @error Or Not $iBytes Then Return SetError(1, 2, 0)
	EndSwitch
	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "bool", "_BASS_EXT_ChannelGetFFT", "dword", $hHandle, "dword", $aFFT[3], "dword", $aFFT[4], "dword", $aFFT[5], "dword", $iFallOff, "bool", $aFFT[6], "ptr", $aFFT[0], "ptr", $pFFT)
	If @error Then Return SetError(@error, 0, 0)
	Return $bass_ext_ret[0]
EndFunc   ;==>_BASS_EXT_ChannelGetFFT

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelSetLevelDsp
; Description ...: Sets a dsp-callback on the channel to get the channels (post play) sample data for use with _BASS_EXT_ChannelGetLevel
; Syntax ........: _BASS_EXT_ChannelSetLevelDsp($handle, $priority = 10)
; Parameters ....: -	$handle		-	Handle The channel handle...
;										-	HCHANNEL, HMUSIC, HSTREAM, HRECORD or HSAMPLE handles accepted.
;                   -   $priority   -   The priority of the new DSP, which determines its position in the DSP chain. DSPs with higher priority are called before those with lower.
; Return values .: Success      - Returns an Array containing all necessary data
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: a buffer of 15 seconds is created and it is filled by the DSP-callback
;                  5s (= max buffer of a channel) + 10s (10s of allready played samples)
; Related .......: _BASS_EXT_ChannelGetLevel, _BASS_EXT_ChannelRemoveLevelDsp
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelSetLevelDsp($handle, $priority = 10)
	Local $iBytes = _BASS_ChannelSeconds2Bytes($handle, 15) ; max channel buffer = 5s size + 10s max level window
	Local $aInfo = _BASS_ChannelGetInfo($handle)
	If @error Or Not IsArray($aInfo) Then Return SetError(1, 0, 0)
	Local $hStream
	Switch BitAND($aInfo[2], $BASS_SAMPLE_FLOAT)
		Case True
			$hStream = _BASS_StreamCreate($aInfo[0], $aInfo[1], BitOR($BASS_STREAM_DECODE, $BASS_SAMPLE_FLOAT), $STREAMPROC_PUSH)
		Case Else
			$hStream = _BASS_StreamCreate($aInfo[0], $aInfo[1], $BASS_STREAM_DECODE, $STREAMPROC_PUSH)
	EndSwitch
	If @error Or Not $hStream Then Return SetError(1, 0, 0)
	Local $aBuffer = _BASS_EXT_MemoryBufferCreate($iBytes)
	Local $tStruct = DllStructCreate("ptr;int")
	DllStructSetData($tStruct, 1, $aBuffer[2])
	DllStructSetData($tStruct, 2, 0)

	Local $hDsp = _BASS_ChannelSetDSP($handle, $BASS_EXT_DspLevelProc, DllStructGetPtr($tStruct), $priority)
	Switch @error
		Case True
			Return SetError(1, 0, 0)
		Case Else
			Local $aReturn[6]
			$aReturn[0] = $tStruct
			$aReturn[1] = $aBuffer
			$aReturn[2] = $hDsp
			$aReturn[3] = $handle
			$aReturn[4] = $hStream
			$aReturn[5] = $aInfo[0]
			Return SetError(0, 0, $aReturn)
	EndSwitch
EndFunc   ;==>_BASS_EXT_ChannelSetLevelDsp

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetLevel
; Description ...: Returns the loudness of a channel
; Syntax ........: _BASS_EXT_ChannelGetLevel($aLevel, $fWindow = 0.5, $iWeighting = 0, $iPeak = 0)
; Parameters ....: -	$aLevel		-	the variant as returned by _BASS_EXT_ChannelSetLevelDsp
;                   -   $fWindow    -   time window in seconds [0.1..10]
;                   -   $iWeighting -   frequency weighting of analyzed data (http://en.wikipedia.org/wiki/A-weighting)
;                                        - 0: no weighting
;                                        - 1: A - weighting
;                                        - 2: B - weighting
;                                        - 3: C - weighting
;                                        - 4: D - weighting
;                   -   $iPeak=0    -   0: calculate the RMS of the samples
;                                   -   1: find highes peak of the samples
; Return values .: Success      - Returns loudness as longword - use _BASS_LoWord to get the left / _BASS_HiWord to get the right channel
;                  Failure      - sets @error and returns zero
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_ChannelSetLevelDsp, _BASS_EXT_ChannelRemoveLevelDsp
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetLevel($aLevel, $fWindow = 0.5, $iWeighting = 0, $iPeak = 0)
	If Not IsArray($aLevel) Then Return SetError(1, 0, 0)
	Local $iBytesW, $iBytes, $tStruct, $aBuffer, $iOffset
	If $fWindow > 10 Then $fWindow = 10
	If $fWindow < 0.1 Then $fWindow = 0.1
	$iBytesW = _BASS_ChannelSeconds2Bytes($aLevel[3], $fWindow)
	$tStruct = $aLevel[0]
	$aBuffer = $aLevel[1]
	$iOffset = DllStructGetData($tStruct, 2)
	$iBytes = DllStructGetData($aBuffer[3], 1)
	If $iBytes - $iOffset > 0 Then
		Local $bass_ext_ret = DllCall($_ghBassEXTDll, "DWORD", "_BASS_EXT_ChannelGetLevel", "PTR", $aBuffer[2], "DWORD", $iOffset, "DWORD", $iBytesW, "DWORD", $aLevel[4], "DWORD", $iPeak, "DWORD", $iWeighting, "DWORD", $aLevel[5])
		If @error Then Return SetError(1, 0, 0)
		Return $bass_ext_ret[0]
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_BASS_EXT_ChannelGetLevel

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelRemoveLevelDsp
; Description ...: Removes the dsp-callback from the channel
; Syntax ........: _BASS_EXT_ChannelRemoveLevelDsp(ByRef $aLevel, $handle = 0)
; Parameters ....: -	$aLevel		-	the variant as returned by _BASS_EXT_ChannelSetLevelDsp
;                   -   $handle     -   optional: The channel handle the dsp is to be removed from, IF the handle has changed since _BASS_EXT_ChannelSetLevelDsp
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @error to 1
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_ChannelSetLevelDsp, _BASS_EXT_ChannelGetLevel
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelRemoveLevelDsp(ByRef $aLevel, $handle = 0)
	If Not IsArray($aLevel) Then Return SetError(1, 0, 0)
	Local $hHandle = $handle
	If Not $hHandle Then $hHandle = $aLevel[3]
	Local $aRet = _BASS_ChannelRemoveDSP($hHandle, $aLevel[2])
	Switch @error
		Case True
			Return SetError(1, 1, 0)
		Case Else
			$aLevel[0] = 0
			_BASS_EXT_MemoryBufferDestroy($aLevel[1])
			_BASS_StreamFree($aLevel[4])
			$aLevel[5] = 0
			Return SetError(0, 0, $aRet)
	EndSwitch
EndFunc   ;==>_BASS_EXT_ChannelRemoveLevelDsp


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Level2dB
; Description ...: Returns level as dB
; Syntax ........: _BASS_EXT_Level2dB($fLevel, $bFlag = True)
; Parameters ....: -	$fLevel  				-	linear level as returned by _BASS_ChannelGetLevel()
;					-	$bFlag                  -   False: returns real decibel [-90..0]
;                                                   True : returns db as float [0..1]
; Return values .: Success      - If successful, then the level as dB is returned
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Level2dB($fLevel, $bFlag = True)
	If $fLevel < 0 Then $fLevel = Abs($fLevel)
	If $fLevel > 1 Then $fLevel = 1
	Local $fReturn = 0
	Switch $fLevel
		Case 0
			Return 0
		Case 0 To 0.000030517
			$fLevel = 0.000030517
	EndSwitch
	$fReturn = 20 * Log($fLevel) / Log(10)
	If $bFlag Then $fReturn = $fReturn / 90.3089986991943 + 1
	Return $fReturn
EndFunc   ;==>_BASS_EXT_Level2dB

; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_dB2Level
; Description ...: Returns dB as linear level
; Syntax ........: _BASS_EXT_dB2Level($fdB, $bFlag = True)
; Parameters ....: -	$fdB  				    -	decibel level as returned by _BASS_EXT_Level2dB
;                   -   $bFlag                  -   False: $fdB is real decibel [-90..0]
;                                                   True : $fdB is float [0..1]
; Return values .: Success      - If successful, then the linear level is returned as floating point value
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_dB2Level($fdB, $bFlag = True)
	Local $fReturn = 0
	Switch $bFlag
		Case True
			If $fdB = 0 Then Return 0
			$fdB = ($fdB - 1) * 90.3089986991943
		Case Else
			If $fdB = 0 Then Return 1
	EndSwitch
	$fReturn = 10 ^ ($fdB / 20)
	Return $fReturn
EndFunc   ;==>_BASS_EXT_dB2Level












; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_WaveformSetWidth
; Description ...: sets new width of the waveform polygon
; Syntax ........: _BASS_EXT_WaveformSetWidth(ByRef $aWave, $iWidth)
; Parameters ....: -	$aWave  				    -	variant as returned by _BASS_EXT_ChannelGetWaveformDecode
;                   -   $iWidth                     -   new width of the polygon
; Return values .: Success      - Returns 1
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_WaveformSetWidth(ByRef $aWave, $iWidth)
	If Not IsArray($aWave) Then Return SetError(1, 1, 0)
	Local $iNodes = $aWave[2]
	For $i = 2 To $iNodes
		DllStructSetData($aWave[3], 1, $i * $iWidth / $iNodes, $i * 2 - 1)
		DllStructSetData($aWave[4], 1, $i * $iWidth / $iNodes, $i * 2 - 1)
	Next
	$aWave[5] = $iWidth
EndFunc   ;==>_BASS_EXT_WaveformSetWidth


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_GDIpBitmapCreateWaveform
; Description ...: Creates a gdiplus bitmap with the waveform polygon created by _BASS_EXT_ChannelGetWaveformDecode
; Syntax ........: _BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $aWave, $hBrushL, $hPenL, $hBrushR = 0, $hPenR = 0, $iBKColor = 0, $iSmooth = 0)
; Parameters ....: -   $hGraphics         -  gdiplus graphic context
;                   -   $aWave             -  variant as returned by _BASS_EXT_ChannelGetWaveformDecode
;                   -   $hBrushL           -  gdiplus brush handle for left channel
;                   -   $hPenL             -  gdiplus pen handle for left channel
;                   -   $hBrushR           -  gdiplus brush handle for right channel, if zero: $hBrushL will be used
;                   -   $hPenR             -  gdiplus pen handle for right channel, if zero: $hPenL will be used
;                   -   $iBKColor          -  backgroundcolor, if zero: transparent
;                   -   $iSmooth           -  graphics smoothing mode - see _GDIPlus_GraphicsSetSmoothingMode
; Return values .: Success      - If successful, then a bitmap handle is returned
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: set Pen to zero to draw a solid waveform.
;                  set brush to zero to draw an outlined waveform.
;                  if smoothingmode is set, the drawing takes much longer.
;                  it seems that gdiplus can´t draw a polygon on a bitmap greater than about 30000px width!?
; Related .......: _BASS_EXT_ChannelGetWaveformDecode
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $aWave, $hBrushL, $hPenL, $hBrushR = 0, $hPenR = 0, $iBKColor = 0, $iSmooth = 0)
	If $ghGDIPDll <= 0 Then Return SetError(1, 1, 0)
	If Not IsArray($aWave) Then Return SetError(1, 2, 0)
	Local $iW = $aWave[5]
	Local $iH = $aWave[6]
	If Not $hBrushR Then $hBrushR = $hBrushL
	If Not $hPenR Then $hPenR = $hPenL
	If $iW <= 30000 Then
		Return __BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $iW, $iH, $aWave[0], $aWave[1], $aWave[2], $hBrushL, $hPenL, $hBrushR, $hPenR, $iBKColor, $iSmooth)
	Else
		Local $hBmp = _GDIPlus_BitmapCreateFromGraphics($iW, $iH * 4, $hGraphics)
		Local $hGfx = _GDIPlus_ImageGetGraphicsContext($hBmp)
		_GDIPlus_GraphicsSetSmoothingMode($hGfx, 0)
		Local $iOffset = 0
		Local $iWidth = 30000
		Local $iPointCnt = Ceiling(30000 * $aWave[2] / $iW)
		$iPointCnt -= Mod($iPointCnt, 2)
		Local $tPointsL, $tPointsR, $hBmpWave, $pPointsL, $pPointsR
		For $i = 0 To $iW Step 30000
			If $iOffset + $iPointCnt >= $aWave[2] - 2 Then $iPointCnt = $aWave[2] - 2 - $iOffset
			$iPointCnt -= Mod($iPointCnt, 2)
			If $iWidth + $i > $iW Then $iWidth = $iW - $i
			$tPointsL = DllStructCreate("float[" & ($iPointCnt + 2) * 2 & "]", $aWave[0] + $iOffset * 8)
			$tPointsR = DllStructCreate("float[" & ($iPointCnt + 2) * 2 & "]", $aWave[1] + $iOffset * 8)
			For $j = 1 To $iPointCnt + 1
				DllStructSetData($tPointsL, 1, ($j - 1) * $iWidth / ($iPointCnt - 2), ($j + 1) * 2 - 1)
				DllStructSetData($tPointsR, 1, ($j - 1) * $iWidth / ($iPointCnt - 2), ($j + 1) * 2 - 1)
			Next
			DllStructSetData($tPointsL, 1, 0, 1)
			DllStructSetData($tPointsL, 1, 0, 2)
			DllStructSetData($tPointsL, 1, $iWidth, $iPointCnt * 2 + 1)
			DllStructSetData($tPointsL, 1, 0, $iPointCnt * 2 + 2)
			DllStructSetData($tPointsR, 1, 0, 1)
			DllStructSetData($tPointsR, 1, 0, 2)
			DllStructSetData($tPointsR, 1, $iWidth, $iPointCnt * 2 + 1)
			DllStructSetData($tPointsR, 1, 0, $iPointCnt * 2 + 2)
			$pPointsL = DllStructGetPtr($tPointsL)
			$pPointsR = DllStructGetPtr($tPointsR)
			$hBmpWave = __BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $iWidth, $iH, $pPointsL, $pPointsR, $iPointCnt + 1, $hBrushL, $hPenL, $hBrushR, $hPenR, $iBKColor, $iSmooth)
			_GDIPlus_GraphicsDrawImage($hGfx, $hBmpWave, $i, 0)
			$iOffset += $iPointCnt
			_GDIPlus_BitmapDispose($hBmpWave)
			$tPointsL = 0
			$tPointsR = 0
		Next
		_GDIPlus_GraphicsDispose($hGfx)
		Return $hBmp
	EndIf
EndFunc   ;==>_BASS_EXT_GDIpBitmapCreateWaveform



; #INTERNAL# ====================================================================================================================
; Name ..........: __BASS_EXT_GDIpBitmapCreateWaveform
; Description ...:
; Syntax ........: __BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $iW, $iH, $pPointsL, $pPointsR, $iPoints, $hBrushL, $hPenL, $hBrushR, $hPenR, $iBKColor, $iSmooth)
; Parameters ....:
; Return values .:
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __BASS_EXT_GDIpBitmapCreateWaveform($hGraphics, $iW, $iH, $pPointsL, $pPointsR, $iPoints, $hBrushL, $hPenL, $hBrushR, $hPenR, $iBKColor, $iSmooth)
	Local $hBmp = _GDIPlus_BitmapCreateFromGraphics($iW, $iH * 4, $hGraphics)
	Local $hGfx = _GDIPlus_ImageGetGraphicsContext($hBmp)
	_GDIPlus_GraphicsSetSmoothingMode($hGfx, 0)
	Local $hBmpL = _GDIPlus_BitmapCreateFromGraphics($iW, $iH + 1, $hGraphics)
	Local $hGfxL = _GDIPlus_ImageGetGraphicsContext($hBmpL)
	_GDIPlus_GraphicsSetSmoothingMode($hGfxL, $iSmooth)
	Local $hBmpR = _GDIPlus_BitmapCreateFromGraphics($iW, $iH + 1, $hGraphics)
	Local $hGfxR = _GDIPlus_ImageGetGraphicsContext($hBmpR)
	_GDIPlus_GraphicsSetSmoothingMode($hGfxR, $iSmooth)
	If $iBKColor Then _GDIPlus_GraphicsClear($hGfxL, $iBKColor)
	If $hBrushL Then DllCall($ghGDIPDll, "int", "GdipFillPolygon2", "handle", $hGfxL, "handle", $hBrushL, "ptr", $pPointsL, "int", $iPoints)
	If $hPenL Then DllCall($ghGDIPDll, "int", "GdipDrawPolygon", "handle", $hGfxL, "handle", $hPenL, "ptr", $pPointsL, "int", $iPoints)
	_GDIPlus_DrawImagePoints($hGfx, $hBmpL, 0, $iH, $iW, $iH, 0, 0)
	_GDIPlus_GraphicsDrawImageRectRect($hGfx, $hBmpL, 0, 1, $iW, $iH, 0, $iH, $iW, $iH)
	If $iBKColor Then _GDIPlus_GraphicsClear($hGfxR, $iBKColor)
	If $hBrushR Then DllCall($ghGDIPDll, "int", "GdipFillPolygon2", "handle", $hGfxR, "handle", $hBrushR, "ptr", $pPointsR, "int", $iPoints)
	If $hPenR Then DllCall($ghGDIPDll, "int", "GdipDrawPolygon", "handle", $hGfxR, "handle", $hPenR, "ptr", $pPointsR, "int", $iPoints)
	_GDIPlus_DrawImagePoints($hGfx, $hBmpR, 0, $iH * 3, $iW, $iH * 3, 0, $iH * 2)
	_GDIPlus_GraphicsDrawImageRectRect($hGfx, $hBmpR, 0, 1, $iW, $iH, 0, $iH * 3, $iW, $iH)
	_GDIPlus_GraphicsDispose($hGfxL)
	_GDIPlus_BitmapDispose($hBmpL)
	_GDIPlus_GraphicsDispose($hGfxR)
	_GDIPlus_BitmapDispose($hBmpR)
	_GDIPlus_GraphicsDispose($hGfx)
	Return $hBmp
EndFunc   ;==>__BASS_EXT_GDIpBitmapCreateWaveform




; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_ChannelGetWaveformDecode
; Description ...: Creates a waveform polygon of a decoding channel
; Syntax ........: _BASS_EXT_ChannelGetWaveformDecode($hHandle, $iWidth, $iHeight, $fStartSec = 0, $fEndSec = 0, $iNodesPerSeconds = 88, $Proc = 0)
; Parameters ....: -   $hHandle              - handle to a bass decoding stream
;                  -   $iWidth               - width of the waveform polygon
;                  -   $iHeight              - height of the waveform polygon
;                  -   $fStartSec            - startposition of the stream in seconds
;                  -   $fEndSec              - endposition of the stream in seconds
;                  -   $iNodesPerSeconds     - number of polygon segments per second
;                  -   $Proc                 - callback function to receive progress status
;                                                 "_My_WaveformProc"
;                                                 Func _My_WaveformProc($handle, $percent)
; Return values .: Success      - Returns Array: $aWaveform[0] = pointer of left polygon
;                                                $aWaveform[1] = pointer of right polygon
;                                                $aWaveform[2] = number of points in the polygon
;                                                $aWaveform[3] = struct of left polygon
;                                                $aWaveform[4] = struct of right polygon
;                                                $aWaveform[5] = width
;                                                $aWaveform[6] = height
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: use _BASS_EXT_GDIpBitmapCreateWaveform to draw the polygon or
;                  use gdiplus functions like:
;                  DllCall($ghGDIPDll, "int", "GdipDrawCurve3", "handle", $hGraphics, "handle", $hPen, "ptr", $aWaveform[0], "int", $aWaveform[2], "int", 1, "int", $aWaveform[2] - 3, "float", 0)
;                  DllCall($ghGDIPDll, "int", "GdipFillClosedCurve2", "handle", $hGraphics, "handle", $hBrush, "ptr", $aWaveform[0], "int", $aWaveform[2], "float", 0, "int", 1)
; Related .......: _BASS_EXT_GDIpBitmapCreateWaveform, _BASS_EXT_WaveformSetWidth
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_ChannelGetWaveformDecode($hHandle, $iWidth, $iHeight, $fStartSec = 0, $fEndSec = 0, $iNodesPerSeconds = 88, $Proc = 0)
	Local $pProc = -1
	If Not $hHandle Then Return SetError(1, 1, 0)
	Local $aInfo = _BASS_ChannelGetInfo($hHandle)
	If @error Or Not IsArray($aInfo) Then Return SetError(1, 2, 0)
	If Not BitAND($aInfo[2], $BASS_STREAM_DECODE) Then Return SetError(1, 3, 0)

	If $iNodesPerSeconds < 1 Then $iNodesPerSeconds = 1
	If $iNodesPerSeconds > $aInfo[0] Then $iNodesPerSeconds = $aInfo[0]

	Local $iBytes = _BASS_ChannelGetLength($hHandle, $BASS_POS_BYTE)
	If @error Or Not $iBytes Then Return SetError(1, 4, 0)

	Local $fSec = _BASS_ChannelBytes2Seconds($hHandle, $iBytes)

	If $fStartSec < 0 Then $fStartSec = 0
	If $fEndSec >= $fSec Then $fEndSec = $fSec
	If $fStartSec >= $fSec Then $fStartSec = $fSec
	If $fEndSec <= 0 Then $fEndSec = $fSec
	If $fEndSec <= $fStartSec Then Return SetError(1, 5, 0)

	$fSec = $fEndSec - $fStartSec
	Local $iNodes = Ceiling($fSec * $iNodesPerSeconds)
	If $iNodes > 99997 Then $iNodes = 99997

	Local $tStructL = DllStructCreate("float[" & ($iNodes + 2) * 2 & "]")
	Local $tStructR = DllStructCreate("float[" & ($iNodes + 2) * 2 & "]")

	$iHeight = Ceiling($iHeight / 4)

	If IsString($Proc) Then
		$pProc = DllCallbackRegister($Proc, "none", "dword;dword")
		$Proc = DllCallbackGetPtr($pProc)
	EndIf

	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "dword", "_BASS_EXT_ChannelGetWaveformDecode", "dword", $hHandle, "dword", $iWidth, "dword", $iHeight, "double", $fStartSec, "double", $fEndSec, "ptr", DllStructGetPtr($tStructL), "ptr", DllStructGetPtr($tStructR), "dword", $iNodes, "dword", $aInfo[1], "ptr", $Proc)
	If @error Or Not IsArray($bass_ext_ret) Then Return SetError(1, 6, 0)
	Switch $bass_ext_ret[0]
		Case 0
			If $pProc <> -1 Then DllCallbackFree($pProc)
			Return SetError(1, 7, 0)
		Case Else
			If $pProc <> -1 Then DllCallbackFree($pProc)
			DllStructSetData($tStructL, 1, DllStructGetData($tStructL, 1, 3), 1)
			DllStructSetData($tStructL, 1, 0, 2)
			DllStructSetData($tStructL, 1, DllStructGetData($tStructL, 1, ($iNodes + 1) * 2 - 1), ($iNodes + 2) * 2 - 1)
			DllStructSetData($tStructL, 1, 0, ($iNodes + 2) * 2)

			DllStructSetData($tStructR, 1, DllStructGetData($tStructR, 1, 3), 1)
			DllStructSetData($tStructR, 1, 0, 2)
			DllStructSetData($tStructR, 1, DllStructGetData($tStructR, 1, ($iNodes + 1) * 2 - 1), ($iNodes + 2) * 2 - 1)
			DllStructSetData($tStructR, 1, 0, ($iNodes + 2) * 2)

			Local $aReturn[7]
			$aReturn[0] = DllStructGetPtr($tStructL)
			$aReturn[1] = DllStructGetPtr($tStructR)
			$aReturn[2] = $iNodes + 2
			$aReturn[3] = $tStructL
			$aReturn[4] = $tStructR
			$aReturn[5] = $iWidth
			$aReturn[6] = $iHeight
			Return $aReturn
	EndSwitch
EndFunc   ;==>_BASS_EXT_ChannelGetWaveformDecode


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_SpVoice2Memory
; Description ...: Speaks a SpVoice text to memory
; Syntax ........: _BASS_EXT_SpVoice2Memory($sText, $iRate = 0, $iVolume = 100)
; Parameters ....: -   $sText                - The text to be spoken
;                  -   $iRate                - speaking rate of the voice; Values for the Rate property range from -10 to 10
;                  -   $iVolume              - sets the base volume (loudness) level of the voice; Values for the Volume property range from 0 to 100
; Return values .: Success      - Returns DllStruct $tWave containing a complete wav-file
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: $hStream = _BASS_StreamCreateFile(True, DllStructGetPtr($tWave), 0, DllStructGetData($tWave, "Len"), 0)
; Related .......: _BASS_EXT_MakeWave, _BASS_EXT_SaveWave
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_SpVoice2Memory($sText, $iRate = 0, $iVolume = 100)
	Local $oVoice = ObjCreate("Sapi.SpVoice")
	If @error Or Not IsObj($oVoice) Then Return SetError(1, 1, 0)

	Local $oMemStream = ObjCreate("SAPI.SpMemoryStream.1")
	If @error Or Not IsObj($oVoice) Then Return SetError(1, 2, 0)
	Local $vSpAudioFormat = $oMemStream.Format
	$vSpAudioFormat.Type = 0x00000023

	$oVoice.AudioOutputStream = $oMemStream
	$oVoice.Rate = $iRate
	$oVoice.Volume = $iVolume

	$oVoice.Speak($sText)

	Local $bData = $oMemStream.GetData()

	Local $tWave = _BASS_EXT_MakeWave($bData)
	Local $iSize = @extended
	Return SetError(0, $iSize, $tWave)
EndFunc   ;==>_BASS_EXT_SpVoice2Memory


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_MakeWave
; Description ...: Creates a wav-file in memory from binary sampledata
; Syntax ........: _BASS_EXT_MakeWave($bData, $iFreq = 44100, $iChan = 2, $iBits = 16, $iFormat = 1)
; Parameters ....: -   $bData                - binary sampledata
;                  -   $iFreq                - samplingfrequency
;                  -   $iChan                - number of channels (1/2)
;                  -   $iBits                - bits / sample (8/16/24)
;                  -   $iFormat              - sampleformat (1 = PCM)
; Return values .: Success      - Returns DllStruct $tWave containing a complete wav-file
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......: $hStream = _BASS_StreamCreateFile(True, DllStructGetPtr($tWave), 0, DllStructGetData($tWave, "Len"), 0)
; Related .......: _BASS_EXT_SpVoice2Memory, _BASS_EXT_SaveWave
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_MakeWave($bData, $iFreq = 44100, $iChan = 2, $iBits = 16, $iFormat = 1)
	If Not IsBinary($bData) Then Return SetError(1, 1, 0)
	Local $iSize = BinaryLen($bData)
	If $iSize <= 0 Then Return SetError(1, 2, 0)

	Switch $iBits
		Case 8, 16, 24
		Case Else
			Return SetError(1, 2, 0)
	EndSwitch

	Switch $iChan
		Case 1, 2
		Case Else
			Return SetError(1, 3, 0)
	EndSwitch

	Local $iBlock = Floor($iChan * ($iBits / 8))

	Local $tWave = DllStructCreate("char RIFF [4];uint FileSize;char WAVE [4];char fmt [4];uint fmt_len;word Format;word Channels;uint Samplerate;uint Bytes;word Block;word BitsPerSample;char DATA [4];uint Len;byte WAVDATA[" & $iSize & "]")
	DllStructSetData($tWave, "RIFF", "RIFF")
	DllStructSetData($tWave, "FileSize", $iSize + 44 - 8)
	DllStructSetData($tWave, "WAVE", "WAVE")
	DllStructSetData($tWave, "fmt", "fmt ")
	DllStructSetData($tWave, "fmt_len", 16)
	DllStructSetData($tWave, "Format", $iFormat)
	DllStructSetData($tWave, "Channels", $iChan)
	DllStructSetData($tWave, "Samplerate", $iFreq)
	DllStructSetData($tWave, "Bytes", $iFreq * $iBlock)
	DllStructSetData($tWave, "Block", $iBlock)
	DllStructSetData($tWave, "BitsPerSample", $iBits)
	DllStructSetData($tWave, "DATA", "data")
	DllStructSetData($tWave, "Len", $iSize)
	DllStructSetData($tWave, "WAVDATA", $bData)

	Return SetError(0, $iSize, $tWave)
EndFunc   ;==>_BASS_EXT_MakeWave



; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_SaveWave
; Description ...: Saves a _BASS_EXT_MakeWave generated waveform to disk
; Syntax ........: _BASS_EXT_SaveWave($tWave, $sPath, $bOverWrite = True)
; Parameters ....: -   $tWave                - struct as returned by _BASS_EXT_MakeWave
;                  -   $sPath                - path\filename to be written
;                  -   $bOverWrite           - True = overwrite existing file
; Return values .: Success      - Returns True
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MakeWave
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_SaveWave($tWave, $sPath, $bOverWrite = True)
	If Not IsDllStruct($tWave) Then Return SetError(1, 1, False)

	If Not $bOverWrite And FileExists($sPath) Then Return SetError(1, 2, False)

	Local $iSize = DllStructGetSize($tWave)
	Local $tData = DllStructCreate("byte[" & $iSize & "]", DllStructGetPtr($tWave))
	Local $bData = DllStructGetData($tData, 1)

	Local $hFile = FileOpen($sPath, BitOR(2, 8, 16))
	If @error Then Return SetError(@error, @extended, False)
	FileWrite($hFile, $bData)
	If @error Then Return SetError(@error, @extended, False)
	FileClose($hFile)

	Return True
EndFunc   ;==>_BASS_EXT_SaveWave


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_LoadWave
; Description ...: Loads a wavfile to memory
; Syntax ........: _BASS_EXT_LoadWave($sPath)
; Parameters ....: -   $sPath                - path\filename
; Return values .: Success      - Returns DllStruct $tWave containing a complete wav-file
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MakeWave
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_LoadWave($sPath)
	If Not FileExists($sPath) Then Return SetError(1, 1, False)

	Local $hFile = FileOpen($sPath, 16)
	If @error Then Return SetError(@error, @extended, False)
	Local $bData = FileRead($hFile)
	If @error Then Return SetError(@error, @extended, False)
	FileClose($hFile)

	Local $iSize = BinaryLen($bData)
	If $iSize <= 0 Then Return SetError(1, 2, False)

	Local $tData = DllStructCreate("byte[" & $iSize & "]")
	DllStructSetData($tData, 1, $bData)

	Local $tHeader = DllStructCreate("char RIFF [4];uint FileSize;char WAVE [4];char fmt [4];uint fmt_len;word Format;word Channels;uint Samplerate;uint Bytes;word Block;word BitsPerSample;char DATA [4];uint Len;", DllStructGetPtr($tData))
	Local $iFormat = DllStructGetData($tHeader, "Format")
	If $iFormat <> 1 Then Return SetError(1, 3, False)

	Local $iLen = DllStructGetData($tHeader, "Len")

	$tData = 0
	$tHeader = 0

	Local $tWave = DllStructCreate("char RIFF [4];uint FileSize;char WAVE [4];char fmt [4];uint fmt_len;word Format;word Channels;uint Samplerate;uint Bytes;word Block;word BitsPerSample;char DATA [4];uint Len;byte WAVDATA[" & $iLen & "];")
	$tData = DllStructCreate("byte[" & $iSize & "]", DllStructGetPtr($tWave))
	DllStructSetData($tData, 1, $bData)

	Return SetError(0, $iLen, $tWave)
EndFunc   ;==>_BASS_EXT_LoadWave



; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Generator
; Description ...: Sound Generator
; Syntax ........: _BASS_EXT_Generator($WaveType = "sine", $fHz = 440, $iDuration = 1000, $fLevel = 0.5, $iSamplerate = 44100, $iFadeIn = 10, $iFadeOut = 40)
; Parameters ....: -   $WaveType             - Type of waveform: "sine", "square", "triangle", "sawtooth up", "sawtooth down"
;                  -   $fHz                  - sound frequency in Hz
;                  -   $iDuration            - duration in ms
;                  -   $fLevel               - volume [0..1]
;                  -   $iSamplerate          - samplerate
;                  -   $iFadeIn              - fade-in ms
;                  -   $iFadeOut             - fade-out ms
; Return values .: Success      - Returns binary generated sampledata
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_MakeWave
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Generator($WaveType = "sine", $fHz = 440, $iDuration = 1000, $fLevel = 0.5, $iSamplerate = 44100, $iFadeIn = 10, $iFadeOut = 40)
	Local $iSamples = Ceiling($iSamplerate / 1000 * $iDuration)
	Local $iFI = Ceiling($iSamplerate / 1000 * $iFadeIn)
	Local $iFO = Ceiling($iSamplerate / 1000 * $iFadeOut)

	Local $tData = DllStructCreate("byte[" & $iSamples * 2 & "]")
	Local $tSamples = DllStructCreate("short[" & $iSamples & "]", DllStructGetPtr($tData))
	Local $iLevel = 32767 * $fLevel
	If $iLevel > 32767 Then $iLevel = 32767
	If $iLevel < 0 Then $iLevel = 0

	Switch $WaveType
		Case "sine", "1", 1
			$WaveType = 1
		Case "square", "2", 2
			$WaveType = 2
		Case "triangle", "3", 3
			$WaveType = 3
		Case "sawtooth down", "4", 4
			$WaveType = 4
		Case "sawtooth up", "sawtooth", "5", 5
			$WaveType = 5
		Case Else
			$WaveType = 1
	EndSwitch

	Local $bass_ext_ret = DllCall($_ghBassEXTDll, "bool", "_BASS_EXT_Generator", "dword", $WaveType, "float", $fHz, "ptr", DllStructGetPtr($tData), "dword", $iSamples, "dword", $iLevel, "dword", $iSamplerate, "dword", $iFI, "dword", $iFO)
	If @error Then Return SetError(1, 1, False)

	Local $bData = DllStructGetData($tData, 1)
	Return $bData
EndFunc   ;==>_BASS_EXT_Generator



; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Note2Freq
; Description ...: Returns frequency of a midinote
; Syntax ........: _BASS_EXT_Note2Freq($iNote, $iConcertPitch = 440)
; Parameters ....: -   $iNote                - midi note number
;                  -   $iConcertPitch        - pitch reference of note "a4" in Hz
; Return values .: Success      - Returns the frequency of the note
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_Generator
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Note2Freq($iNote, $iConcertPitch = 440)
	Return $iConcertPitch * 2 ^ (($iNote - 69) / 12)
EndFunc   ;==>_BASS_EXT_Note2Freq


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Freq2Note
; Description ...: Returns midinote of a frequency
; Syntax ........: _BASS_EXT_Freq2Note($fFreq, $iConcertPitch = 440)
; Parameters ....: -   $fFreq                - frequency in Hz
;                  -   $iConcertPitch        - pitch reference of note "a4" in Hz
; Return values .: Success      - Returns the midinote of the frequency
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_Generator
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Freq2Note($fFreq, $iConcertPitch = 440)
	Return (12 * (Log($fFreq / $iConcertPitch) / Log(2))) + 69
EndFunc   ;==>_BASS_EXT_Freq2Note


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Name2Note
; Description ...: Returns midinote of a notename
; Syntax ........: _BASS_EXT_Name2Note($sNote)
; Parameters ....: -   $sNote                - name of note ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"] + "octave" => "c#4"
; Return values .: Success      - Returns the midinote of a notename
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_Generator
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Name2Note($sNote)
	Local $aRegExp = StringRegExp($sNote, "([cdefgab])(\#?)([-1-9])", 3)
	If UBound($aRegExp) <> 3 Then Return SetError(1, 1, False)
	Local $iNote
	Switch $aRegExp[0]
		Case "d"
			$iNote = 2
		Case "e"
			$iNote = 4
			$aRegExp[1] = ""
		Case "f"
			$iNote = 5
		Case "g"
			$iNote = 7
		Case "a"
			$iNote = 9
		Case "b"
			$iNote = 11
			$aRegExp[1] = ""
		Case Else
	EndSwitch
	If $aRegExp[1] = "#" Then $iNote += 1
	Local $iOctave
	Switch $aRegExp[2]
		Case "-"
			$iOctave = 0
		Case Else
			$iOctave = Int($aRegExp[2]) + 1
	EndSwitch
	Return $iNote + 12 * $iOctave
EndFunc   ;==>_BASS_EXT_Name2Note


; #FUNCTION# ====================================================================================================================
; Name ..........: _BASS_EXT_Note2Name
; Description ...: Returns notename of a midinote
; Syntax ........: _BASS_EXT_Note2Name($iNote)
; Parameters ....: -   $iNote                - midinote
; Return values .: Success      - Returns a notename: ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"] + "octave" => "c#4"
;                  Failure      - Returns 0
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......: _BASS_EXT_Generator
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _BASS_EXT_Note2Name($iNote)
	Local $aNotes[12] = ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"]
	Local $iIndex = Mod($iNote, 12)
	Local $iOctave = Floor($iNote / 12) - 1
	If $iOctave < 0 Then $iOctave = "-"
	Local $sNote = $aNotes[$iIndex] & String($iOctave)
	Return $sNote
EndFunc   ;==>_BASS_EXT_Note2Name





; #INTERNAL# ====================================================================================================================
; Name ..........: __BASS_EXT_GetCallBackPointer
; Description ...:
; Syntax ........: __BASS_EXT_GetCallBackPointer($iCBFunc = 0)
; Parameters ....:
; Return values .:
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __BASS_EXT_GetCallBackPointer($iCBFunc = 0)
	Switch $iCBFunc
		Case 1 To 14
			Local $aResult = DllCall($_ghBassEXTDll, "ptr", "_BASS_EXT_GetCallBackPointer", "dword", $iCBFunc)
			If @error Then Return SetError(1, 0, 0)
			Return $aResult[0]
	EndSwitch
	Return 0
EndFunc   ;==>__BASS_EXT_GetCallBackPointer

; #SignalFlow# ===================================================================================================================
; Signalflow description
; ===============================================================================================================================
; AsioProc:
;
;
;
;