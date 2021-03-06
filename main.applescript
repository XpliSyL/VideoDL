(*

Télécharger simplement vos vidéos
@File VideoDL.app
@author Sylvain S
@version 3.2
@date 03 12 2016

Programme qui amène une interface graphique pour télécharger des vidéos sur internet

 *)


on AllCheck(YoutubedlPath, FfmpegPath, myURL, ydlArgument, playlistSize, UrlTitle)
	
	## Le retour de youtubedl est copié dans /tmp/progress.txt 
	set FinalScript to quoted form of YoutubedlPath & " --newline -R 2 " & ydlArgument & " --ffmpeg-location " & FfmpegPath & " -o '~/Downloads/VideoDL/%(title)s.%(ext)s' " & quoted form of myURL & " > /tmp/progress.txt 2>&1 &"
	try
		## Activation de l'application pour que la barre de téléchargement s'affiche
		tell application "VideoDL" to activate
		set progress description to "⬇️ Téléchargement..."
		set progress additional description to "Préparation du fichier..."
		delay 0.2
		set progress total steps to 100
		set i to 0
		set x to 1
		repeat until (i > 99)
			try
				## Lors du premier tour, on execute le shell script
				## A ne pas mettre hors du repeat !!
				if x = 1 then
					do shell script FinalScript
					set x to x + 1
				end if
				## Si on télécharge une playlist, le calcul sera selon le nombre total de vidéo
				if playlistSize > 1 then
					## Retour de la valeur du nombre total de vidéo dans la playlist
					set TotalVideo to do shell script "cat /private/tmp/progress.txt | grep 'Downloading video' | grep of | cut -d ' ' -f 6- | tail -n 1"
					## Vidéo qui est en cours de téléchargement
					set VideoActuelle to do shell script "cat /private/tmp/progress.txt | grep 'Downloading video' | grep of | cut -d ' ' -f 4 | tail -n 1"
					
					## Calcul de pourcentage selon (VideoActuelle / TotalVideo) * 100
					## Ne pas diviser par une variable vide
					if TotalVideo = "" then
						set TotalVideo to 1
					end if
					set i to round ((VideoActuelle / TotalVideo) * 100)
					
					## On télécharge uniquement un fichier
				else
					## Reprise du % de téléchargement que procure youtubedl
					set i to do shell script "cat /private/tmp/progress.txt | grep % |  awk '{print $2}' | cut -d '%' -f 1 | cut -d '.' -f 1 |  tail -n 1"
				end if
				## Si la variable est vide, elle est éguale à 0
				if i = "" then
					set i to 0
				end if
				## Si le fichier est déjà télécharger, on le supprime et l'on relance le téléchargement
				set z to do shell script "cat /private/tmp/progress.txt | tail -n 1 | cut -d ':' -f 1"
				if z = "ERROR" then
					do shell script "rm /private/tmp/progress.txt"
					do shell script FinalScript
				end if
				
				## Test de "i" afin d'éviter de le calculer alors qu'il est vide
				try
					set i to i as integer
				on error
					exit repeat
				end try
				
				## On transmet i à la valeur du pourcentage de téléchargemnt actuel
				set progress additional description to i & " %"
				set progress completed steps to i
				
				delay 0.2
			on error thisErr
				display alert thisErr
				exit repeat
			end try
		end repeat
		## Attente que FFMPG fasse la conversion du fichier
		set progress description to "Conversion du fichier..."
		delay 3
		set progress total steps to 0
		set progress completed steps to 0
		set progress description to ""
		set progress additional description to ""
		
		## Suppression du ficher txt crée précedemment
		do shell script "rm /private/tmp/progress.txt"
		
		display notification UrlTitle with title "✅ Téléchargement terminé" subtitle " -> Téléchargements/VideoDL/"
		
	on error errorMessage number errorNumber
		display dialog errorMessage with title "❌ Echec du téléchargement"
	end try
end AllCheck

## Déclaration des variables
set AucunNaviguateur to false
set myPath to path to me
set YoutubedlPath to POSIX path of myPath & "Contents/Resources/youtube-dl"
set FfmpegPath to POSIX path of myPath & "Contents/Resources/ffmpeg"
set cancelledPath to myPath & "Contents:Resources:Cancelled.png.icns" as string
set DownloadingPath to myPath & "Contents:Resources:downloading_youtube_video__tile_by_dastileguy-daeexlu.jpg.icns" as string
set YoutubePath to myPath & "Contents:Resources:Youtube-icon.png.icns" as string
set appName to "Firefox"
set ListeNaviguateur to {"Google Chrome", "Safari", "Firefox", "Opera"}
set URLValide to false
set processusOuvert to {}
set playlistText1 to ""
set playlistText2 to ""
tell application "System Events" to set processusOuvert to name of every process
set NaviguateurOuvert to {}
set NaviguateurOuvertTrue to ""

## Vérification du(des) naviguateur(s) ouvert(s)
repeat with i in processusOuvert
	repeat with x in ListeNaviguateur
		if x is in i then
			if length of words of i = length of words of x then
				set end of NaviguateurOuvert to i as string
			end if
		end if
	end repeat
end repeat

## Demande du naviguateur qui contient la vidéo
if length of NaviguateurOuvert > 1 and length of NaviguateurOuvert < 4 then
	display dialog "Plusieurs naviguateurs ouverts !" & return & "Lequel voulez-vous utiliser ? " buttons NaviguateurOuvert
	set NaviguateurOuvertTrue to button returned of the result
	
	## Si un seul naviguateur ouvert
else if length of NaviguateurOuvert = 1 then
	set NaviguateurOuvertTrue to NaviguateurOuvert
	
	## Si aucun naviguateur ouvert
else
	display dialog "Aucun naviguateur ouvert !" with icon stop buttons {"Quitter"} default button 1
	if the button returned of the result is "Quitter" then
		return -128
	end if
end if

## Safari
if NaviguateurOuvertTrue contains "Safari" then
	tell application id "com.apple.Safari"
		try
			set myURL to URL of front document
		end try
	end tell
	
	## Googe Chrome
else if NaviguateurOuvertTrue contains "Google Chrome" then
	using terms from application "Google Chrome"
		tell application "Google Chrome"
			try
				set myURL to URL of active tab of front window as string
			end try
		end tell
	end using terms from
	
	## Firefox
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
	
	
	## Opera
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

## Afin d'éviter que la variable myURL soit vide, on la test avant 
try
	myURL
on error errorMessage number errorNumber
	display dialog "Aucune URL trouvée" with icon stop buttons {"Quitter"} default button 1
	if the button returned of the result is "Quitter" then
		return -128
	end if
end try

## Continue tant qu'auncun média n'est trouvé par youtubedl
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
					## Mise à jour de youtubedl
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

## Tout en gardant l'extensions finale, on supprime l'extension lors de l'affichage
set UrlTitle1 to do shell script "filename=\" " & UrlTitle & " \" ; filename=\"${filename%.*}\" ; echo $filename"

## Dans un cas ou le média est de l'audio uniquement (soundcloud, mixcloud etc)
set audioFile to do shell script "echo " & quoted form of UrlTitle & " | grep -qEi '.(mp4|flv|wmv|mov|avi|mpeg|mpg|m4v|mkv|divx|asf|webm)$'; echo $?"
set playlistSize to (count paragraphs in UrlTitle)
if playlistSize > 1 then
	set playlistText1 to "cette playlist "
	set playlistText2 to return & "etc..." & return
end if

## Média Vidéo
if audioFile is "0" then
	
	tell application "System Events" to display dialog "Sous quel format désirez vous télécharger " & playlistText1 & return & return & UrlTitle1 & playlistText2 buttons {"Audio", "Vidéo"} default button "Vidéo"
	if the button returned of the result is "Vidéo" then
		set ydlArgument to "-f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4"
	else if the button returned of the result is "Audio" then
		set ydlArgument to " --extract-audio --audio-format mp3 --audio-quality 0"
	end if
	
	## Média audio
else
	tell application "System Events" to display dialog "Voulez vous vraiment télécharger : " & playlistText1 & return & return & UrlTitle1 & ".mp3" & playlistText2 buttons {"Quitter", "Télécharger"} default button "Télécharger"
	if the button returned of the result is "Télécharger" then
		set ydlArgument to " --extract-audio --audio-format mp3 --audio-quality 0 "
	else if the button returned of the result is "Quitter" then
		return -128
	end if
end if




## Lancement du script final avec toute ses variable
AllCheck(YoutubedlPath, FfmpegPath, myURL, ydlArgument, playlistSize, UrlTitle)
