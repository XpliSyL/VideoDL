on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

on findAndReplace(tofind, toreplace, TheString)
	set OldAppleTextitemDelimiters to text item delimiters
	set text item delimiters to tofind
	set textItems to text items of TheString
	set text item delimiters to toreplace
	if (class of TheString is string) then
		set FinalStringResult to textItems as string
	else
		set FinalStringResult to textItems as Unicode text
	end if
	set text item delimiters to OldAppleTextitemDelimiters
	return FinalStringResult
end findAndReplace

on AllCheck(YoutubedlPath, FfmpegPath, myURL)
	set FinalScript to quoted form of YoutubedlPath & " --no-playlist --newline -R 2 -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 --ffmpeg-location " & FfmpegPath & " -o '~/Downloads/VideoDL/%(title)s.%(ext)s' " & myURL & " > /tmp/progress.txt 2>&1 &"
	--set FinalScript to quoted form of YoutubedlPath & " -F -o '~/Downloads/YoutubeDL/%(title)s.%(ext)s' " & myURL & " | grep fps | grep mp4 | cut -d ' ' -f 19 | sed -e 's/$/ pixels/'"
	--tell application "System Events" to display dialog return & "T四残hargement en cours... " & return & "Merci de patienter" with icon file DownloadingPath buttons "Ok" default button "Ok" giving up after 2
	try
		--tell application "VideoDL" to activate
		set progress description to "T四残hargement..."
		set progress additional description to "Pr姿aration du fichier..."
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
	display dialog "Aucun naviguateur ouvert !"
end if


repeat while URLValide is false
	
	if NaviguateurOuvertTrue is "Safari" then
		set OpenBrowser to "Safari"
		tell application id "com.apple.Safari"
			set myURL to URL of front document
		end tell
		
	else if NaviguateurOuvertTrue is "Google Chrome" then
		tell application "Google Chrome"
			set OpenBrowser to "Google Chrome"
			set myURL to URL of active tab of front window
		end tell
		
	else if NaviguateurOuvertTrue is "Firefox" then
		set OpenBrowser to "Firefox"
		tell application id (id of application appName)
			activate
		end tell
		tell application "System Events"
			keystroke "l" using command down
			keystroke "c" using command down
		end tell
		delay 0.2
		set myURL to the clipboard
		
	else if NaviguateurOuvertTrue is "Opera" then
		set OpenBrowser to "Opera"
		tell application "Opera"
			activate
		end tell
		tell application "System Events"
			keystroke "l" using command down
			keystroke "c" using command down
		end tell
		delay 0.2
		set myURL to the clipboard
		else 
		display dialog "WOW"
	end if
	
	if AucunNaviguateur then
		tell application "System Events" to display dialog return & "Merci d'ouvir votre naviguateur !" buttons {"Quitter", "Continuer"} default button "Continuer" with icon file cancelledPath
		if the button returned of the result is "Quitter" then
			return
		else
			tell application id "com.apple.Safari"
				activate
				try
					set URLFromFrontDocument to URL of front document
					URLFromFrontDocument
				on error
					set URLFromFrontDocument to "test.com"
				end try
				set CountWindowSaf to count window
				if CountWindowSaf = 0 then
					make new document at end of documents with properties {URL:"http://www.youtube.com"}
				end if
				if URLFromFrontDocument does not contain URLYoutubeInitial then
					set the URL of the front document to "http://www.youtube.com"
				end if
			end tell
		end if
	end if
end repeat
if UrlTitle contains "&#39;" then
	set UrlTitle to findAndReplace("&#39;", "'", UrlTitle)
end if
if IsDefined then
	tell application "System Events" to display dialog "Voulez-vous vraiment t四残harger : " & return & UrlTitle buttons {"Quitter", "Continuer"} default button "Continuer" with icon file YoutubePath
	if the button returned of the result is "Quitter" then
		return
	end if
else
	set lastUrlTitle to text 1 thru -11 of UrlTitle
	tell application "System Events" to display dialog "Voulez-vous vraiment t四残harger : " & return & lastUrlTitle buttons {"Quitter", "Continuer"} default button "Continuer" with icon file YoutubePath
	if the button returned of the result is "Quitter" then
		return
	end if
end if
AllCheck(YoutubedlPath, FfmpegPath, myURL)