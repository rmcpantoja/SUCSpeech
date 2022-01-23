#include "include\audio.au3"
#include <FileConstants.au3>
encrypt()
func encrypt()
$filetoencr = FileOpenDialog("Select zip or dat file containing the sounds", @scriptDir & "\", "Package files (*.dat;*.zip)|Sounds (*.flac;*.ogg;*.mp3;*.wav)")
If @error Then
MsgBox(16, "error", "you did not select any file.")
exit
EndIF
$savefile = FileSaveDialog("Save the encrypted file as...", "", "dat file (*.dat)|zip file (*.zip)|Flac file (*.flac)|MP3 file (*.mp3)|Ogg file (*.ogg)|Wav file (*.wav)", $FD_FILEMUSTEXIST)
if $savefile = "" then
MSGBox(16, "Error", "it is important that you choose a destination file before proceeding.")
Exit
EndIf
beep(2500, 100)
beep(2500, 75)
$gui = GuiCreate("working...")
GuiSetState(@SW_SHOW)
$comaudio.Encrypt($filetoencr, $savefile)
GuiDelete($gui)
beep(1250, 200)
msgBox(48, "Done", "File encripted")
FileDelete($filetoencr)
EndFunc