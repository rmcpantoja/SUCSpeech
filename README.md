# SUCSpeech
Spanish text-to-speech (TTS) synthesizer made in autoit for now!

# english:

## Introduction:

SucSpeech is a free text-to-speech synthesizer that currently has two synthesis modes: Simple (letters) and Advanced (syllables). These syntheses use the unit selection method, concatenating audio files that correspond to letters or syllables. It is made in [autoit](http://autoitscript.com/) which means it supports only Windows. In fact, the program [Blind Text](https://github.com/rmcpantoja/Blind-Text) has clear examples of how this synthesizer is used in the program.
The synthesizer.au3 file is the main engine or base of the synthesizer. You can explore it and see how it is made. Don't worry, there are comments on the necessary lines.

## instructions for creating voices:

1. [Download the Sucspeech repository](https://github.com/rmcpantoja/SUCSpeech) or clone it using Git clone or the URL in your browser.
2. Download [AutoIt](https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe) to run.
3. To create a voice, in simple synthesis mode, keep in mind that we must record the phonemes and letters as they sound (this can record words that contain a sound for a specific letter or vowel and cut with an editor audio).
4. In the case of the advanced synthesis mode (syllables) we must record longer sentences or phrases and cut each syllable of that sentence, but there must not be clips left and we must cut very carefully so that the voice can come out as correctly as possible.
There are samples in the voicepacks_source folder, with 108 .wav files with the sounds and phonemes recorded in each voice. For each letter, vowel or sign, three audios are needed. For example, if we want to record the sound of the vowel a, then we have to record an a1.wav, a2.wav and a3.wav, the three vowels with different pitches or else the voice sounds monotonous when processing text. Apply the same to the Voicepacks_source_pro folder, but in this case it's syllables.
Note: There should be no silence in the files.
simple mode:
To start making the voice, we simply create a new folder in voicepack_sources with the name of the language, an underscore, and the name of the voice. For example Is_So-and-so. "Es" from Spanish, "Fulano" the name of the voice. From that folder we can make our recordings. We can build on the structure of the voices that are already integrated in the repository. Basically there are three sounds from a to z, phonemes like ch, sh, etc.
Advanced mode:
To create a more advanced and high-quality voice, we also create a subfolder in Voicepacks_source_pro with the language name, an underscore, the voice name, underscore, and hq, for example: Es_carla_hq. It should be noted that this mode is still in beta, but it can be recorded following the structure of the es_default_hq voice, which is a few steps away from being completed.
Then we can make a script as an example to see how our voice turned out or to test an existing voice.You must include the include\synthesizer.au3 file.

### example:

_SucSpeechSpeak1("Es_default (wisper)", "This is an example of speech synthesis. My name is whisper and I am going to tell you a secret: Yesterday I went to the store and bought ten apples.", 1, 0.75)

#### Explanation:

The function is _SucSpeechSpeak1, followed by the parameters. The first is the name of the voice (es_default (wisper)), the second is the string or text "This is an example of voice synthesis. My name is whisper and I'm going to tell you a secret: Yesterday I went to the store and I bought ten apples.", third volume (1) and fourth speed (0.75).
In this way, executing the script, the test of our voice among all the available ones would come out.

### example using advanced synthesis:

_SucSpeechSpeak2("Es_default_hq", "La risa dejaba un buen rato de felicidad.", 1, 0.75)

#### Explanation:

_SucSpeechSpeak2: is the function that performs the synthesis between syllables.
"Es_default_hq": name of the voice.
"La risa dejaba un buen rato de felicidad.": the text to be synthesized.

## Collaboration

If you have any suggestions that help improve this project, do not hesitate to make a request (pull request) your help and suggestions are welcome!

# spanish:

## Introducci??n:

SucSpeech es un sintetizador de texto a voz gratuito que por ahora posee dos modos de s??ntesis: Simple (letras) y avanzado (s??labas). Estas s??ntesis usan el m??todo de selecci??n de unidades, concatenando archivos de audio que corresponden a las letras o s??labas. Est?? hecho en [autoit](http://autoitscript.com/) por lo que significa que soporta solo Windows. De hecho, el programa [Blind Text (texto a ciegas)](https://github.com/rmcpantoja/Blind-Text) tiene claros ejemplos de c??mo se usa este sintetizador en el programa.
El archivo synthesizer.au3 es el motor o la base principal del sintetizador. Puedes explorarlo y ver c??mo est?? hecho. No te preocupes, hay comentarios en las l??neas necesarias.

## instructivo para crear voces:
1. [Descarga el repositorio de Sucspeech](https://github.com/rmcpantoja/SUCSpeech) o cl??nalo usando Git clone o la URL en tu navegador.
2. Descarga [AutoIt](https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe) para la ejecuci??n.
3. Para crear una voz, en modo de s??ntesis simple, hay que tener en cuenta que debemos grabar los fonemas y las letras tal y como suenan (esto pueden grabar palabras que contengan un sonido para una letra o vocal espec??fica y cortar con alg??n editor de audio).
4. En el caso del modo de s??ntesis avanzado (s??labas) debemos grabar oraciones m??s largas o frases e ir cortando cada s??laba de esa horaci??n, pero no tienen que quedar clips y debemos cortar con mucho cuidado para que la voz pueda salir lo m??s correcta posible.
Hay ejemplos en la carpeta voicepacks_source, con 108 archivos .wav con los sonidos y fonemas grabados en cada voz. Para cada letra, vocal o signo se necesitan tres audios. Por ejemplo si queremos grabar el sonido de la vocal a, entonces tenemos que grabar un a1.wav, a2.wav y a3.wav, las tres vocales con tonos diferentes o si no, la voz al procesar texto se escucha mon??tona. Aplica lo mismo en la carpeta Voicepacks_source_pro, pero en este caso son s??labas.
Nota: No deben quedar silencios en los archivos.
Modo simple:
Para comenzar a hacer la voz, simplemente creamos una nueva carpeta en voicepack_sources con el nombre del idioma, un subrayado y el nombre de voz. Por ejemplo Es_Fulano. "Es" de Espa??ol, "Fulano" el nombre de la voz. Desde esa carpeta podemos hacer nuestras grabaciones. Podemos basarnos en la estructura de las voces que ya est??n integradas en el repositorio. B??sicamente son tres sonidos de a a z, fonemas como ch, sh, etc.
Modo avanzado:
Para crear una voz m??s avanzada y de alta calidad, creamos as?? mismo una subcarpeta en Voicepacks_source_pro con el nombre del idioma, un subrayado, el nombre de voz, subrayado y hq, por ejemplo: Es_carla_hq. Cabe aclarar que este modo todav??a est?? en beta, pero se puede grabar siguiendo la estructura de la voz es_default_hq que est?? a pasos de completarse.
Despu??s podemos hacer un script como ejemplo para ver c??mo qued?? nuestra voz o para probar una voz existente. Debes incluir el archivo include\synthesizer.au3.

### ejemplo:

_SucSpeechSpeak1("Es_default (wisper)", "Este es un ejemplo de s??ntesis de voz. Me llamo susurro y te voy a contar un secreto: El d??a de ayer fui a la tienda y me compr?? diez manzanas.", 1, 0.75)

#### Explicaci??n:

La funci??n es _SucSpeechSpeak1, seguido de los par??metros. El primero el nombre de la voz (es_default (wisper)), el segundo la cadena o texto "Este es un ejemplo de s??ntesis de voz. Me llamo susurro y te voy a contar un secreto: El d??a de ayer fui a la tienda y me compr?? diez manzanas.", tercero volumen (1) y cuarto velocidad (0.75).
De este modo, ejecutando el script ya saldr??a la prueba de nuestra voz entre todas las disponibles.

### ejemplo usando s??ntesis avanzada:

_SucSpeechSpeak2("Es_default_hq", "La risa dejaba un buen rato de felicidad.", 1, 0.75)

#### explicaci??n:

_SucSpeechSpeak2: es la funci??n que realiza la s??ntesis entre s??lavas.
"Es_default_hq": nombre de la voz.
"La risa dejaba un buen rato de felicidad.": el texto a ser sintetizado.

## Colaboraci??n

Si tienes alguna sugerencia que ayude a mejorar este proyecto, no dudes en hacer una solicitud (pull request) tu ayuda y sugerencias son bienvenidas!
