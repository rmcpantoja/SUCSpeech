;This is my Spanish voice synthesizer.
#include-once
#include "audio.au3"
#include "timeGetTime.au3"
;Comments on how this UDF works: English	spanish.
dim $characters[2048] ;2048 character limit for standard version. For the pro version it will be unlimited.
$textstring = "equis"
$speaktimer=0
$sleeptime=0
;The next function is "HablarEnLetras" (in Spanish) which corresponds to speaking a sentence, concatenating phonemes depends on each letter of the string. La siguiente función es "HablarEnLetras" (en español) que corresponde a pronunciar una oración, la concatenación de fonemas depende de cada letra de la cadena.
;Function: Speak in letters (hablar en letras).
;parameters: $Voice: The name of a voice that has been created. You can also create your own voice, package it and put it in the Voicepacks folder. parámetros: $Voice: el nombre de una voz que se ha creado. También puede crear su propia voz, empaquetarla y ponerla en la carpeta Voicepacks.
;$STR: The text to be spoken. $STR: el texto a ser hablado.
;$VoicePitch: The pitch and speed of the voice. 0.50 very slow, 1 normal, 1.50 fast and 2:00 very fast. The default parameter is 1. $VoicePitch: el tono y la velocidad de la voz. 0.50 muy lento, 1 normal, 1.50 rápido y 2:00 muy rápido. El parámetro predeterminado es 1.
;$VoiceVolume: The volume of the voice. between 0.01 and 1.00. The default parameter is 1.00. $VoiceVolume: el volumen de la voz. entre 0.01 y 1.00. El parámetro predeterminado es 1.00.
;$VoicePunctuation: This is to speak punctuation marks in the string or in the text being spoken if it contains them. There are four modes of scoring reading: 0 none, 1 some, 2 almost all, and 3 all. The default parameter is 0 (do not read any punctuation). $VoicePunctuation: Esto es para verbalizar signos de puntuación en la cadena o en el texto que se está pronunciando si los contiene. Hay cuatro modos de lectura de puntuación: 0 ninguna, 1 alguna, 2 casi toda y 3 toda. El parámetro predeterminado es 0 (no leer ningún signo de puntuación).
func HablarEnLetras($voice, $str, $Voicepitch = 1, $Voicevolume = 1, $Voicepunctuation = "0")
FileChangeDir(@scriptDir &"\voicepacks")
global $svoice = $voice
global $vpitch = $voicepitch
global $vvolume = $voicevolume
global $letters= "b,c,d,f,g,h,j,k,l,m,n,ñ,p,q,r,s,t,v,w,x,y,z"
;spanish letters with their respective rules: letras en español con sus respectivas reglas:
global $lspeak = "be,ce,de,efe,ge,a$e,jota,ka,ele,eme,ene,enie,pe,ku,erre,ese,te,uve,doblebe,eqis,igriega,ceta"
;Detecting if the text contains vowels a, e, i, o, u. And if the text doesn't have vowels anywhere, then read the letters. It's a common thing for synthesizers. Detectando si el texto contiene vocales a, e, i, o, u. Y si el texto no tiene vocales en ninguna parte, lee entonces las letras. Es algo común de los sintetizadores.
Select
case not StringInStr($str, "a") and not StringInStr($str, "e") and not StringInStr($str, "i") and not StringInStr($str, "o") and not StringInStr($str, "u")
$lreplace = StringSplit($letters, ",")
$sreplace = StringSplit($lspeak, ",")
for $I = 1 to $lreplace[0]
If StringInStr($str, $lreplace[$i]) then
$str = StringReplace($str, $lreplace[$i], $sreplace[$i])
EndIf
Next
EndSelect
;Applying dictionary corrections, a few things according to the punctuation: Aplicando correcciones de diccionario, algunas cosas de acuerdo a la puntuación:
if $voicepunctuation = "2" or $voicepunctuation = "3" then
$str = StringReplace($str, ":", "Dos puntos.")
Else
$str = StringReplace($str, ":", ".")
EndIf
$str = StringReplace($str, "ca", "qa")
$str = StringReplace($str, "co", "qo")
$str = StringReplace($str, "cu", "qu")
$str = StringReplace($str, "ch", "$")
$str = StringReplace($str, "cl", "kl")
$str = StringReplace($str, "cr", "kr")
$str = StringReplace($str, "ct", "kt")
$str = StringReplace($str, "sh", "$")
$str = StringReplace($str, "ge", "je")
$str = StringReplace($str, "gé", "gé")
$str = StringReplace($str, "gi", "ji")
$str = StringReplace($str, "gí", "jí")
$str = StringReplace($str, "gue", "ge")
$str = StringReplace($str, "gué", "gé")
$str = StringReplace($str, "gui", "gi")
$str = StringReplace($str, "guí", "gí")
$str = StringReplace($str, "h", "")
$str = StringReplace($str, "ll", "y")
$str = StringReplace($str, "qu", "q")
if $voicepunctuation = "1" or $voicepunctuation = "2" or $voicepunctuation = "3" then
$str = StringReplace($str, "/", "barra")
Else
$str = StringReplace($str, "/", "'")
EndIf
$str = StringReplace($str, "<", "menorqe")
$str = StringReplace($str, ">", "mayorqe")
$str = StringReplace($str, "	", "tav")
if $voicepunctuation = "2" or $voicepunctuation = "3" then
$str = StringReplace($str, "{", "abreyabe")
$str = StringReplace($str, "}", "cierrayabe")
Else
$str = StringReplace($str, "{", "")
$str = StringReplace($str, "{", "}")
EndIf
if $voicepunctuation = "3" then
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
$str = StringReplace($str, "#", "número")
$str = StringReplace($str, "&", "and")
if $voicepunctuation = "2" or $voicepunctuation = "3" then
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
if $voicepunctuation = "2" or $voicepunctuation = "3" then
$str = StringReplace($str, "[", "abreqor$ete")
$str = StringReplace($str, "]", "cierraqor$ete")
$str = StringReplace($str, "°", "grados")
$str = StringReplace($str, "_", "subrayado")
$str = StringReplace($str, ";", "puntoycoma")
$str = StringReplace($str, "^", "circunflejo")
$str = StringReplace($str, "`", "grave")
else
$str = StringReplace($str, "[", "")
$str = StringReplace($str, "]", "")
$str = StringReplace($str, "°", "")
$str = StringReplace($str, "_", "")
$str = StringReplace($str, ";", ",")
$str = StringReplace($str, "^", "")
$str = StringReplace($str, "`", "")
endIf
$str = StringReplace($str, @crlf, ".")
$str = StringReplace($str, " ", "")
$str = StringReplace($str, "ä", "a")
$str = StringReplace($str, "à", "a")
$str = StringReplace($str, "ë", "e")
$str = StringReplace($str, "è", "e")
$str = StringReplace($str, "ï", "i")
$str = StringReplace($str, "ì", "i")
$str = StringReplace($str, "ö", "o")
$str = StringReplace($str, "ò", "o")
$str = StringReplace($str, "ü", "u")
$str = StringReplace($str, "ù", "u")
$str = StringReplace($str, "¨", "diéresis")
$str = StringReplace($str, "´", "Agudo")
$str = StringReplace($str, "*", "asterisqo")
$str = StringReplace($str, "\", "'invertida")
$str = StringReplace($str, "@", "arroba")
$str = StringReplace($str, "ç", "cecedilla")
$str = StringReplace($str, "×", "signodemultiplicación")
$str = StringReplace($str, "÷", "signodedivisión")
$str = StringReplace($str, "·", "puntocentrado")
$str = StringReplace($str, "º", "masculino")
$str = StringReplace($str, "ª", "femenino")
$str = StringReplace($str, "¼", "unqarto")
$str = StringReplace($str, "½", "unmedio")
$str = StringReplace($str, "¬", "nolójico")
$str = StringReplace($str, "§", "seqción")
$str = StringReplace($str, "£", "libras")
$str = StringReplace($str, "±", "+o-")
$str = StringReplace($str, "~", "tilde")
$str = StringReplace($str, "€", "euro")
$str = StringReplace($str, "á", "a")
$str = StringReplace($str, "é", "e")
$str = StringReplace($str, "í", "i")
$str = StringReplace($str, "ó", "o")
$str = StringReplace($str, "ú", "u")
$str = StringReplace($str, "ñ", "ni")
;Get the number of characters in the string: Obtener el número de caracteres de la cadena:
$length=StringLen($str)
;The next variable is an indicator, it will be modified to carry out the character-by-character concatenation. La siguiente variable es un indicador, este será modificado para que realice la concatenación carácter por carácter.
$remove = -1
$remover = $length
;The next for is to display character by character in the array $ characters [$ iString]. $ iString is the base of the for, which means that the array element will increment for each character and concatenates the voice data according to the array and the characters. El siguiente for es para mostrar caracter por caracter en la matriz $characters[$iString]. $iString es la base del for, lo que significa que el elemento del array aumentará por cada carácter y concatena los datos de voz de acuerdo al array y los caracteres.
for $iString = 1 to $length
$remove = $remove +1
$remover = $remover -1
$characters[$iString] = StringTrimLeft(StringTrimRight($str, $remover), $remove)
VoicePlay($characters[$iString])
Next
FileChangeDir(@scriptDir)
EndFunc
;The next function is HablarEnSilabas (in Spanish) it has the same parameters as the previous function, unlike that instead of concatenating character by character it concatenates into syllables, which gives a more human result to the voice. Warning: To create these types of voices we will require a lot of time and effort... La siguiente función es hablar En Sílabas (en español) cuenta con los mismos parámetros que la función anterior, a diferencia de que en lugar de concatenar carácter por carácter concatena en sílabas, lo que da un resultado más humano a la voz. Advertencia: Para crear este tipo de voces requeriremos de mucho tiempo y esfuerzo...
Func HABLARENSilabas($voice, $str, $Voicepitch = "1", $Voicevolume = "1", $Voicepunctuation = "0")
FileChangeDir(@scriptDir &"\voicepacks")
global $svoice = $voice
global $vpitch = $voicepitch
global $vvolume = $voicevolume
global $letters= "b,c,d,f,g,h,j,k,l,m,n,ñ,p,q,r,s,t,v,w,x,y,z"
;spanish letters with their respective rules: letras en español con sus respectivas reglas:
global $lspeak = "be,ce,de,efe,ge,a$e,jota,ka,ele,eme,ene,enie,pe,ku,erre,ese,te,uve,doblebe,eqis,igriega,ceta"
;Detectando si el texto contiene vocales a, e, i, o, u. Y si el texto no tiene vocales en ninguna parte, lee entonces las letras. Es algo común de los sintetizadores.
Select
case not StringInStr($str, "a") and not StringInStr($str, "e") and not StringInStr($str, "i") and not StringInStr($str, "o") and not StringInStr($str, "u")
$lreplace = StringSplit($letters, ",")
$sreplace = StringSplit($lspeak, ",")
for $I = 1 to $lreplace[0]
If StringInStr($str, $lreplace[$i]) then
$str = StringReplace($str, $lreplace[$i], $sreplace[$i])
EndIf
Next
EndSelect
;Aplicando correcciones de diccionario, algunas cosas de acuerdo a la puntuación:
$str = StringReplace($str, "ge", "je")
$str = StringReplace($str, "gé", "gé")
$str = StringReplace($str, "gi", "ji")
$str = StringReplace($str, "gí", "jí")
$str = StringReplace($str, "qu", "q")
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
$str = StringReplace($str, @crlf, ".")
$str = StringReplace($str, " ", "")
$str = StringReplace($str, "á", "a")
$str = StringReplace($str, "é", "e")
$str = StringReplace($str, "í", "i")
$str = StringReplace($str, "ó", "o")
$str = StringReplace($str, "ú", "u")
$str = StringReplace($str, "ñ", "ni")

$length=StringLen($str)
$remove = "-2"
$remover = $length
for $iString = 1 to $length /2
$remove = $remove +2
$remover = $remover -2
;;$characters[$iString] = StringTrimLeft(StringTrimRight($string, 17), 0)
$characters[$iString] = StringTrimLeft(StringTrimRight($str, $remover), $remove)
;MsgBox(0, "Result", $characters[$iString])
VoicePlay($characters[$iString])
Next
VoicePlay(StringRight($str, 1))
sleep(50)
FileChangeDir(@scriptDir)
EndFunc
func getLength($sound)
$length = $sound.Length
return $length
EndFunc
func getSampleRate($sound)
$srate = $sound.sampleRate
return $srate
EndFunc
func Voiceplay($SToPlay)
$played = 0
$soundToPlay = $device.opensound($svoice &"/" &$SToPlay &random(1, 3, 1) &".wav", 0)
$soundToPlay.pitchshift = $vpitch
$soundToPlay.volume = $vvolume
$milis = getLength($soundToPlay)
$samplerate = getSampleRate($soundToPlay)  /1000
$milis2 = int($milis /$samplerate)
;$milis2 = $milis2 -1
$soundToPlay.play
while 1
IF TRAVELOUTTIME($speaktimer) >= $milis2 THEN
$speaktimer=TRAVELINTIME()
$played=1
exitLoop
EndIf
wend
;This is the old while that... It's not that bad, but it does make voices choppy. Este es el antiguo while que... No está tan mal, pero genera entrecortes en las voces.
;while $soundToPlay.playing = 1
;sleep(1)
;Wend
EndFunc
func SoundFade($sound)
for $fade=1 to 18
$sound.volume=$sound.volume-0.05
sleep(25)
next
$sound.stop()
EndFunc
func SoundFadeIn($sound)
$sound.play
$sound.volume = 0
for $fade=1 to 18
$sound.volume=$sound.volume+0.05
sleep(25)
next
EndFunc