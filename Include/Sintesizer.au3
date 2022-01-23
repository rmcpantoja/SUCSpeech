;This speech synthesizer engine is outdated, the sound playback is based on the sound.au3 UDF but it was making a lot of choppiness in the audio when synthesizing text. Therefore, it uses the latest engine file (Sintesizer-comaudio.au3).
#include <Sound.au3>
#include <file.au3>
dim $characters[2048]
$textstring = "equis"
$voice = ""
func HablarEnLetras($voice, $str)
global $svoice = $voice
;Aplicando correcciones de diccionario:
$str = StringReplace($str, ":", ".")
$str = StringReplace($str, "ca", "qa")
$str = StringReplace($str, "co", "qo")
$str = StringReplace($str, "cu", "qu")
$str = StringReplace($str, "ch", "$")
$str = StringReplace($str, "cl", "kl")
$str = StringReplace($str, "cr", "kr")
$str = StringReplace($str, "ct", "kt")
$str = StringReplace($str, "sh", "$h")
$str = StringReplace($str, "ge", "je")
$str = StringReplace($str, "gé", "jé")
$str = StringReplace($str, "gi", "ji")
$str = StringReplace($str, "gí", "jí")
$str = StringReplace($str, "gue", "ge")
$str = StringReplace($str, "gué", "gé")
$str = StringReplace($str, "gui", "gi")
$str = StringReplace($str, "guí", "gí")
$str = StringReplace($str, "h", "")
$str = StringReplace($str, "ll", "y")
$str = StringReplace($str, "qu", "q")
$str = StringReplace($str, "/", "'")
$str = StringReplace($str, "<", "menorqe")
$str = StringReplace($str, ">", "mayorqe")
$str = StringReplace($str, "	", "tav")
$str = StringReplace($str, "{", "abreyabe")
$str = StringReplace($str, "}", "cierrayabe")
$str = StringReplace($str, "¿", ".")
$str = StringReplace($str, "?", ",")
$str = StringReplace($str, "¡", ".")
$str = StringReplace($str, "!", ".")
$str = StringReplace($str, "#", "número")
$str = StringReplace($str, "&", "and")
$str = StringReplace($str, "(", "abrirparéntesis")
$str = StringReplace($str, ")", "cerrarparéntesis")
$str = StringReplace($str, "=", "igual")
$str = StringReplace($str, "|", "'")
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
$str = StringReplace($str, "[", "abreqor$ete")
$str = StringReplace($str, "]", "cierraqor$ete")
$str = StringReplace($str, "°", "grados")
$str = StringReplace($str, "_", "subrayado")
$str = StringReplace($str, ";", "puntoycoma")
$str = StringReplace($str, "^", "circunflejo")
$str = StringReplace($str, "`", "grave")
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
$str = StringReplace($str, "\", "/invertida")
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
$length=StringLen($str)
$remove = -1
$remover = $length
for $iString = 1 to $length
$remove = $remove +1
$remover = $remover -1
;$characters[$iString] = StringTrimLeft(StringTrimRight($string, 17), 0)
$characters[$iString] = StringTrimLeft(StringTrimRight($str, $remover), $remove)
VoicePlay($characters[$iString])
;MsgBox(0, "Result", $characters[$iString])
Next
;msgbox(0, "Finished", "finished")
EndFunc
Func Silabas($str)
$length=StringLen($str)
$remove = "-2"
$remover = $length
for $iString = 1 to $length
$remove = $remove +2
$remover = $remover -2
;;$characters[$iString] = StringTrimLeft(StringTrimRight($string, 17), 0)
$characters[$iString] = StringTrimLeft(StringTrimRight($str, $remover), $remove)
MsgBox(0, "Result", $characters[$iString])
Next
msgbox(0, "Finished", "finished")
EndFunc

func Voiceplay($SToPlay)
$soundToPlay = _soundOpen("voicepacks_source\" &$svoice &"\" &$sToPlay &random(1, 3, 1) &".wav")
_soundPlay ($soundToPlay, 0)
while _soundLength ($soundToPlay, 2) - _soundPos ($soundToPlay, 2) > 30
wend
EndFunc