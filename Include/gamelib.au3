#include-once
Func number_to_filename($num, $ext = "wav")
	$numberstring = _N2T($num)
	$test = StringRight($numberstring, 1)
	If $test = " " Then $numberstring = StringTrimRight($numberstring, 1)
	$numberarray = StringSplit($numberstring, " ")
	$length = $numberarray[0]
	$pos = 0
	$file = ""
	While 1
		$pos = $pos + 1
		If $pos > $length Then ExitLoop
		$current = $numberarray[$pos]
		$current = convert_to_filename($current)
		$file = $file & $current & "." & $ext & ","
	WEnd
	Return $file
EndFunc   ;==>number_to_filename
Func convert_to_filename($txt)
	If $txt = "Cero" Then Return "0"
	If $txt = "Uno" Then Return "1"
	If $txt = "Dos" Then Return "2"
	If $txt = "Tres" Then Return "3"
	If $txt = "Cuatro" Then Return "4"
	If $txt = "Cinco" Then Return "5"
	If $txt = "Seis" Then Return "6"
	If $txt = "Siete" Then Return "7"
	If $txt = "Ocho" Then Return "8"
	If $txt = "Nueve" Then Return "9"
	If $txt = "Diez" Then Return "10"
	If $txt = "Once" Then Return "11"
	If $txt = "Doce" Then Return "12"
	If $txt = "Trece" Then Return "13"
	If $txt = "Catorce" Then Return "14"
	If $txt = "Quince" Then Return "15"
	If $txt = "Diezyseis" Then Return "16"
	If $txt = "Diezysiete" Then Return "17"
	If $txt = "Diezyocho" Then Return "18"
	If $txt = "Diezynueve" Then Return "19"
	If $txt = "Beinte" Then Return "20"
	If $txt = "Treinta" Then Return "30"
	If $txt = "Cuarenta" Then Return "40"
	If $txt = "Cincuenta" Then Return "50"
	If $txt = "Sesenta" Then Return "60"
	If $txt = "Setenta" Then Return "70"
	If $txt = "Ochenta" Then Return "80"
	If $txt = "Noventa" Then Return "90"
	If $txt = "Cien" Then Return "cien"
	If $txt = "mil" Then Return "mil"
	If $txt = "Millón" Then Return "millón"
EndFunc   ;==>convert_to_filename
Func _N2T($iNum)
	Dim $lenNum, $arrNum, $chgNum, $numTxt
	Dim $boolTeens

	If Not IsInt($iNum) Then
		SetError(1)
		;Return
	EndIf

	$lenNum = StringLen($iNum)
	$arrNum = StringSplit($iNum, "")

	If $lenNum = 1 Then
		If $arrNum[1] = 0 Then Return "Cero"
		If $arrNum[1] = 1 Then Return "Uno"
		If $arrNum[1] = 2 Then Return "Dos"
		If $arrNum[1] = 3 Then Return "Tres"
		If $arrNum[1] = 4 Then Return "Cuatro"
		If $arrNum[1] = 5 Then Return "Cinco"
		If $arrNum[1] = 6 Then Return "Seis"
		If $arrNum[1] = 7 Then Return "Siete"
		If $arrNum[1] = 8 Then Return "Ocho"
		If $arrNum[1] = 9 Then Return "Bueve"
	EndIf

	;Assign $chgNum the length so the it can be changed.
	$chgNum = $lenNum

	For $i = 1 To $lenNum Step 1
		If Mod($chgNum, 3) = 0 Then ;Divisible by 3
			$numTxt &= _Ones($arrNum[$i])
			If $chgNum >= 3 And Not ($arrNum[$i] = 0) Then $numTxt &= "Cien "
			$chgNum -= 1
		ElseIf Mod($chgNum, 3) = 2 Then
			If $arrNum[$i] = 1 Then
				If $arrNum[$i + 1] = 0 Then $numTxt &= "Diez "
				If $arrNum[$i + 1] = 1 Then $numTxt &= "Once "
				If $arrNum[$i + 1] = 2 Then $numTxt &= "Doce "
				If $arrNum[$i + 1] = 3 Then $numTxt &= "Trece "
				If $arrNum[$i + 1] = 4 Then $numTxt &= "Catorce "
				If $arrNum[$i + 1] = 5 Then $numTxt &= "Quince "
				If $arrNum[$i + 1] = 6 Then $numTxt &= "Diezyseis "
				If $arrNum[$i + 1] = 7 Then $numTxt &= "Diezysiete "
				If $arrNum[$i + 1] = 8 Then $numTxt &= "diezyocho "
				If $arrNum[$i + 1] = 9 Then $numTxt &= "Diezynueve "
				$chgNum -= 1
				$boolTeens = 1
			Else
				$numTxt &= _Tens($arrNum[$i])
				$chgNum -= 1
			EndIf
		ElseIf Mod($chgNum, 3) = 1 Then
			If Not ($boolTeens) Then $numTxt &= _Ones($arrNum[$i])
			$chgNum -= 1
			$boolTeens = 0
		EndIf

		If $lenNum = 9 And $i = 3 Then $numTxt &= "Millón "
		If $lenNum = 8 And $i = 2 Then $numTxt &= "Millón "
		If $lenNum = 7 And $i = 1 Then $numTxt &= "Millón "
		If Not ($arrNum[$i] = 0) And $lenNum = 9 And $i = 6 Then $numTxt &= "Mil "
		If Not ($arrNum[$i] = 0) And $lenNum = 8 And $i = 5 Then $numTxt &= "Mil "
		If Not ($arrNum[$i] = 0) And $lenNum = 7 And $i = 4 Then $numTxt &= "Mil "
		If $lenNum = 6 And $i = 3 Then $numTxt &= "Mil "
		If $lenNum = 5 And $i = 2 Then $numTxt &= "Mil "
		If $lenNum = 4 And $i = 1 Then $numTxt &= "Mil "

	Next

	Return $numTxt
EndFunc   ;==>_N2T

Func _Ones($oNum)
	Select
		Case $oNum = 0
			Return ""
		Case $oNum = 1
			Return "Uno "
		Case $oNum = 2
			Return "Dos "
		Case $oNum = 3
			Return "Tres "
		Case $oNum = 4
			Return "Cuatro "
		Case $oNum = 5
			Return "Cinco "
		Case $oNum = 6
			Return "Seis "
		Case $oNum = 7
			Return "Siete "
		Case $oNum = 8
			Return "Ocho "
		Case $oNum = 9
			Return "Nueve "
	EndSelect
EndFunc   ;==>_Ones

Func _Tens($tNum)
	Select
		Case $tNum = 0
			Return ""
		Case $tNum = 1
			Return "Diez "
		Case $tNum = 2
			Return "Beinte "
		Case $tNum = 3
			Return "Treinta "
		Case $tNum = 4
			Return "Cuarenta "
		Case $tNum = 5
			Return "Cincuenta "
		Case $tNum = 6
			Return "Sesenta "
		Case $tNum = 7
			Return "Setenta "
		Case $tNum = 8
			Return "Ochenta "
		Case $tNum = 9
			Return "Noventa "
	EndSelect
EndFunc   ;==>_Tens
