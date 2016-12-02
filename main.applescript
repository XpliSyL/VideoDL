on AllCheck(YoutubedlPath, FfmpegPath, myURL, ydlArgument)
	set FinalScript to quoted form of YoutubedlPath & " --no-playlist --newline -R 2 " & ydlArgument & " --ffmpeg-location " & FfmpegPath & " -o '~/Downloads/VideoDL/%(title)s.%(ext)s' " & quoted form of myURL & " > /tmp/progress.txt 2>&1 &"
	--set FinalScript to quoted form of YoutubedlPath & " -F -o '~/Downloads/YoutubeDL/%(title)s.%(ext)s' " & myURL & " | grep fps | grep mp4 | cut -d ' ' -f 19 | sed -e 's/$/ pixels/'"
	--tell application "System Events" to display dialog return & "Téléchargement en cours... " & return & "Merci de patienter" with icon file DownloadingPath buttons "Ok" default button "Ok" giving up after 2
	try
		--tell application "VideoDL" to activate
		set progress description to "Téléchargement..."
		set progress additional description to "Préparation du fichier..."
		delay 0.2
		set progress total steps to 100
		set i to 0
		set x to 1
		--tell application "Finder" to set the position of the front Finder window to {300, 240}
		repeat until (i > 99)
			try
				if x = 1 then
					--tell application "System Events" to set frontmost of processes whose bundle identifier is "com.apple.TextEdit" to true
					do shell script FinalScript
					--tell application "YoutubeDL" to activate
					set x to x + 1
				end if
				set i to do shell script "cat /private/tmp/progress.txt | grep % |  awk '{print $2}' | cut -d '%' -f 1 | cut -d '.' -f 1 |  tail -n 1"
				if i = "" then
					set i to 0
				end if
				set z to do shell script "cat /private/tmp/progress.txt | tail -n 1 | cut -d ':' -f 1"
				if z = "ERROR" then
					do shell script "rm /private/tmp/progress.txt"
					do shell script FinalScript
				end if
				try
					set i to i as integer
				on error
					exit repeat
				end try
				set progress additional description to i & " %"
				set progress completed steps to i
				
				delay 0.2
			on error thisErr
				display alert thisErr
				exit repeat
			end try
		end repeat
		set progress description to "Conversion du fichier..."
		delay 2
		set progress total steps to 0
		set progress completed steps to 0
		set progress description to ""
		set progress additional description to ""
		do shell script "rm /private/tmp/progress.txt"
		--set myFilenamesList to paragraphs of (do shell script FinalScript)
		--set selectedVoice to {choose from list myFilenamesList}
	on error errStr
		display dialog errStr
	end try
end AllCheck

set endOfRepeat to true
set rientrouverSaf to false
set rientrouverCh to false
set IsDefined to false
set rientrouverFirefox to false
set AucunNaviguateur to false
set OpenBrowser to "none"
set myPath to path to me
set YoutubedlPath to POSIX path of myPath & "Contents/Resources/youtube-dl"
set FfmpegPath to POSIX path of myPath & "Contents/Resources/ffmpeg"
set cancelledPath to myPath & "Contents:Resources:Cancelled.png.icns" as string
set DownloadingPath to myPath & "Contents:Resources:downloading_youtube_video__tile_by_dastileguy-daeexlu.jpg.icns" as string
set YoutubePath to myPath & "Contents:Resources:Youtube-icon.png.icns" as string
set YoutubeUrlFound to false
set appName to "Firefox"
set AppNameSaf to "Safari"
set ListeNaviguateur to {"Google Chrome", "Safari", "Firefox", "Opera"}
set URLValide to false
set processusOuvert to {}
set playlistText1 to ""
set playlistText2 to ""
tell application "System Events" to set processusOuvert to name of every process
set NaviguateurOuvert to {}
set NaviguateurOuvertTrue to ""
repeat with i in processusOuvert
	repeat with x in ListeNaviguateur
		if x is in i then
			if length of words of i = length of words of x then
				set end of NaviguateurOuvert to i as string
			end if
		end if
	end repeat
end repeat
if length of NaviguateurOuvert > 1 and length of NaviguateurOuvert < 4 then
	display dialog "Plusieurs naviguateurs ouverts !" & return & "Lequel voulez-vous utiliser ? " buttons NaviguateurOuvert
	set NaviguateurOuvertTrue to button returned of the result
else if length of NaviguateurOuvert = 1 then
	set NaviguateurOuvertTrue to NaviguateurOuvert
else
	display dialog "Aucun naviguateur ouvert !" with icon stop buttons {"Quitter"} default button 1
	if the button returned of the result is "Quitter" then
		return -128
	end if
end if
if NaviguateurOuvertTrue contains "Safari" then
	tell application id "com.apple.Safari"
		try
			set myURL to URL of front document
		end try
	end tell
	
else if NaviguateurOuvertTrue contains "Google Chrome" then
	using terms from application "Google Chrome"
		tell application "Google Chrome"
			try
				set myURL to URL of active tab of front window as string
			end try
		end tell
	end using terms from
	
else if NaviguateurOuvertTrue contains "firefox" then
	tell application id (id of application appName)
		activate
	end tell
	tell application "System Events"
		keystroke "l" using command down
		keystroke "c" using command down
	end tell
	delay 0.2
	set myURL to the clipboard
	
else if NaviguateurOuvertTrue contains "Opera" then
	tell application "Opera"
		activate
	end tell
	tell application "System Events"
		keystroke "l" using command down
		keystroke "c" using command down
	end tell
	delay 0.2
	set myURL to the clipboard
end if

try
	myURL
on error errorMessage number errorNumber
	display dialog "Aucune URL trouvée" with icon stop buttons {"Quitter"} default button 1
	if the button returned of the result is "Quitter" then
		return -128
	end if
end try

repeat while not URLValide
	try
		## get video filename for further checks
		set UrlTitle to do shell script YoutubedlPath & " -o '%(title)s.%(ext)s' --get-filename --playlist-end 2 " & quoted form of myURL
		set URLValide to true
		
	on error errorMessage number errorNumber
		if errorNumber is 1 then
			display dialog myURL & return & return & "Aucun média téléchargable trouvé sur cette URL." & return & return & "Si vous êtes sûr de l'URL, essayez de mettre à jour cette application !" with icon caution buttons {"Mettre à jour", "Quitter"} default button 2
			if the button returned of the result is "Quitter" then
				return -128
			else if the button returned of the result is "Mettre à jour" then
				try
					set updateResult to do shell script YoutubedlPath & " -U" with administrator privileges
					display alert updateResult buttons {"Réessayez le téléchargement"}
					
				on error errorMessage number errorNumber
					display dialog errorMessage with title "Echec de la mise à jour" with icon stop buttons {"Quitter"} default button 1
					if the button returned of the result is "Quitter" then
						return -128
					end if
				end try
			end if
		end if
	end try
end repeat

set UrlTitle1 to do shell script "filename=\" " & UrlTitle & " \" ; filename=\"${filename%.*}\" ; echo $filename"

## do not ask download type for audio-files (soundcloud, mixcloud etc)
set audioFile to do shell script "echo " & quoted form of UrlTitle & " | grep -qEi '.(mp4|flv|wmv|mov|avi|mpeg|mpg|m4v|mkv|divx|asf|webm)$'; echo $?"
set playlistSize to (count paragraphs in UrlTitle)
if playlistSize > 1 then
	set playlistText1 to "cette playlist "
	set playlistText2 to return & "etc..." & return
end if

if audioFile is "0" then
	
	tell application "System Events" to display dialog "Sous quel format désirez vous télécharger " & playlistText1 & return & return & UrlTitle1 & playlistText2 buttons {"Audio", "Vidéo"} default button "Vidéo"
	if the button returned of the result is "Vidéo" then
		set ydlArgument to "-f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --no-playlist"
	else if the button returned of the result is "Audio" then
		set ydlArgument to " -f 'bestaudio'"
	end if
	
else
	tell application "System Events" to display dialog "Sous quel format désirez vous télécharger " & playlistText1 & return & return & UrlTitle1 & playlistText2 buttons {"Format original", "MP3"} default button "MP3"
	if the button returned of the result is "MP3" then
		set extractAudio to " --extract-audio --audio-format mp3 --audio-quality 0 "
	else if the button returned of the result is "Format original" then
		set ydlArgument to " -f 'bestaudio[ext=m4a]'"
		
	end if
end if


##if answer is in {"MP3-audio only"} then
##	set extractAudio to " --extract-audio --audio-format mp3 --audio-quality 0 "
##	display notification UrlTitle with title "🎶 Extracting audio " subtitle "Check downloads folder for progress..."
##else if answer is in {"Video + extract audio"} then
##	set extractAudio to " --extract-audio --keep-video "
##	display notification UrlTitle with title "⬇️ Downloading video + audio " subtitle "Check downloads folder for progress..."
##else if answer is in {"Video"} then
##	display notification UrlTitle with title "⬇️ Downloading video " subtitle "Check downloads folder for progress..."
##else if answer is in {"Original audio format"} then
##	display notification UrlTitle with title "⬇️ Downloading audio " subtitle "Check downloads folder for progress..."
##end if
##try
##	do shell script shellPath & "cd " & dnPwd & " && " & ytCmd & ytArgs & extractAudio & quoted form of theURL
##	display notification UrlTitle with title "✅ Finished downloading" subtitle " -> " & downloadsFolder sound name "Pop"
##on error errorMessage number errorNumber
##	display notification errorMessage with title "❌ Download errors, see below" subtitle theURL sound name "Basso"
##end try

AllCheck(YoutubedlPath, FfmpegPath, myURL, ydlArgument)
