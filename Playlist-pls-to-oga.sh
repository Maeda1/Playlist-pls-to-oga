#!/bin/bash
#Script to copy lossy files (and convert .flac files to .oga) from playlist (.pls file)
#.flac filed need to be in 1.3.1 revision and playlist in .pls
#It takes first image (bmp,png,jpg,jpeg) from the current file directory (and convert it as 300 pixels max) as cover, copy it as folder.jpg on destination.

#Lang test
lang=en
if [ $(echo $LANG | grep fr) ];then
	lang=fr	
fi
#Check if pre-requisites are good
if [ ! -f /usr/bin/mediainfo ];then
	if [ "$lang" == "fr" ];then
		echo "Il manque le paquet mediainfo. Merci de l'installer."
	elif [ "$lang" == "en" ];then
		echo "mediainfo package needed. Please install it."
	fi	
	
fi
if [ ! -f /usr/bin/oggenc ];then
	if [ "$lang" == "fr" ];then
		echo "Il manque le paquet oggenc. Merci de l'installer (paquet = vorbis-tools)."
	elif [ "$lang" == "en" ];then
		echo "oggenc package needed. Please install it (vorbis-tools)."
	fi	
fi
if [ ! -f /usr/bin/convert ];then
	if [ "$lang" == "fr" ];then
		echo "Il manque le paquet convert. Merci de l'installer (imagemagick)."
	elif [ "$lang" == "en" ];then
		echo "convert package needed. Please install it (imagemagick)."
	fi	
	
fi



#No args ? Let's explain
if [ $# -eq 0 ];then
	if [ "$lang" == "fr" ];then
		echo "Script pour copier (et convertir les .flac en .oga) le contenu d'une playlist .pls
Nécessite que les fichiers .flac soient en version 1.3.1 et que la playlist soit en .pls 

INFO : Le script peut être lancé plusieurs fois (un par terminal) avec la même playliste, même destination, tout se fera en parallèle et les CPU seront plus sollicités (ainsi que le stockage de destination)

==== Usage ====
1er argument = chemin vers la playliste (.pls) à convertir.
2ème argument = chemin du dossier de destination."
	elif [ "$lang" == "en" ];then
		echo "Script to copy (and convert .flac files to .oga files) content of a playlist .pls
.flac files need to be in 1.3.1 revision and playlist in .pls 

INFO : This script can be executed several times (one per console) with same playslit and same destination, all will be parallelized and CPUs will be more active (destination device too)

==== Usage ====
1st argument = full path to playliste (.pls) file containing files to convert.
2ème argument = full path to destination device."
	fi
	exit
fi
#Arguments
pls="$1"
dest="$2"
#Arguments tests
if [ ! -d "$dest" ];then
	if [ "$lang" == "fr" ];then
		echo "Erreur : le dossier de destination n'existe pas"
	elif [ "$lang" == "en" ];then
		echo "Error : folder's destination doesn't exists"
	fi
	exit 1
fi
if [ ! "$(echo "$pls" | grep ".pls$")" ];then
	if [ "$lang" == "fr" ];then
		echo "Erreur : la playlist n'est pas une playlist .pls"
	elif [ "$lang" == "en" ];then
		echo "Error : playlist file is not .pls file"
	fi
	exit 2
fi
#Question to know which folders level should be cut. As .pls could contain several path (if files are not stored on same folder tree)
nbexclu=0
chem=0
while [ "$chem" != "" ];do
	if [ "$lang" == "fr" ];then
		echo "Indiquer les dossiers à ne pas recréer sur la destination, par exemple :
Les fichiers (listés dans le fichier .pls) se trouvent tous dans '/home/login/Ma Musique/...' et on veut garder la structure à l'identique sur la destination de tout ce qu'il y a sous 'Ma Musique' (N.B. : ce dernier dossier est également exclu) -> indiquer dans ce cas '/home/login/Ma Musique/'

/!\ NE PAS indiquer de caractères d'échappement (ici le '\'), ni de chemin relatif (~/ ou ./) :
PAS BIEN : /home/login/Ma\ Musique/
BIEN : /home/login/Ma Musique/
PAS BIEN : ~/Ma Musique
/!\ 
ATTENTION : il ne faut pas de caractères de ce type dans les noms des fichiers ou dossiers :
- Point d'interrogation '?' et '~'
- Il NE faut PAS non plus de double espace

Entrer le chemin n°$(let "nbexclu += 1";echo $nbexclu) à exclure ? (taper juste ENTREE sans rien écrire quand terminé)"
	elif [ "$lang" == "en" ];then
		echo "Give folders that you don't want to be recreated on destination folder, example :
All files (in .pls file) are into /home/login/My music/... and we want to keep (on the destination folder) the folder tree but only subfolders of 'My music' not the upper folders ('My music, login and home')

N.B. : last folder written is excluded too) -> in this case, type '/home/login/My music', all those three folders will not be recreated on destination

/!\ DO NOT type escape characters (example the backslash  '\'), nor relative path (~/ or ./) :
NOT GOOD : /home/login/My\ music/
GOOD : /home/login/My music/
NOT GOOD : ~/My music
/!\
WARNING :
- files or folders name containing interrogative mark '?' or '~' will generate an error, and will not be copied/converted !
- NO double space in folders, neither in files name !

Enter folder path #$(let "nbexclu += 1";echo $nbexclu) to exclude : (just type ENTER when empty to finish)"
	fi
	read chem
	if [ ! -d "$chem" ];then
		if [ ! -z $chem ];then
			if [ "$lang" == "fr" ];then
				echo "Chemin non valide !"
			elif [ "$lang" == "en" ];then 
				echo "Invalid path !"
			fi
		fi
	else
		let "nbexclu += 1"
		suffix=$nbexclu
		eval "field$suffix=$chem"
	fi	
done
#BEGIN
if [ "$lang" == "fr" ];then
	echo -e "\e[1;36mINFO\033[0m : Playliste = $pls, dossier de sortie = $dest"
	echo -e "\e[1;36mDébut dans 10 sec\033[0m, tapez CTRL+C pour annuler"
elif [ "$lang" == "en" ];then
	echo -e "\e[1;36mINFO\033[0m : Playlist = $pls, destination folder = $dest"
	echo -e "\e[1;36mStarting in 10 sec\033[0m, type CTRL+C to abort"
fi
sleep 10
pid=$BASHPID
#.pls file reformatting for using by this script
sed '/^File/!d' "$pls" > /tmp/`basename "$pls"`
cat /tmp/`basename "$pls"` | cut -d "=" -f2 > /tmp/cut-$pid`basename "$pls"`
#In the case of this script is executed several times in parallel (multitasking), randomize .pls lines
sort --random-sort /tmp/cut-$pid`basename "$pls"` > /tmp/$pid`basename "$pls"`
#Counter files, for information
count=0
while read line; do
	let "count += 1"
	traitfic=0
	odir=""
	#Keep original folder location of the current file
	dir="$(dirname "$line")"
	#Delete folders that was indicated not to be recreated on destination, several possible, stop when match
	i=1
	while [ $i -le $nbexclu ];do
		suffix=$i
		odir=$(echo $dir | sed "s:$(eval echo \$field$suffix)::")
		let "i += 1"
		if [ "$dir" != "$odir" ];then
			break
		fi
	done
	#Test if current file already exists on destination
	if [ ! -r "$dest/$odir/`basename "${line%.*}.oga"`" -a ! -r "$dest/$odir/`basename "$line"`" ];then
		echo -e "\e[1;36m$count\033[0m:$line"
		#Test if destination folder exists, create it if needed
		if [ ! -d "$dest/$odir" ];then
			mkdir -p "$dest/$odir"
			if [ $? -eq 0 ];then
				if [ "$lang" == "fr" ];then
					echo -ne " Création dossier \e[32m[OK]\033[0m"
				elif [ "$lang" == "en" ];then
					echo -ne " Folder creation \e[32m[OK]\033[0m"
				fi
			else
				if [ "$lang" == "fr" ];then
					echo -ne " Création dossier \033[31m[ERREUR]\033[0m"
				elif [ "$lang" == "en" ];then
					echo -ne " Folder creation \033[31m[ERROR]\033[0m"
				fi
			fi
		else
			if [ "$lang" == "fr" ];then
				echo -ne " Dossier \e[32m[OK]\033[0m"
			elif [ "$lang" == "en" ];then
				echo -ne " Folder \e[32m[OK]\033[0m"
			fi
		fi
		#ENCODE (.flac source file) / COPY (lossy source file)
		if [ "$lang" == "fr" ];then
			echo -n " | Encodage"
		elif [ "$lang" == "en" ];then
			echo -n " | Encoding"
		fi
		#Test if source = .flac
		if [ "$(echo "$line" | grep -i ".flac$")" ];then
			#Test if it's 44.1KHz or 48KHz samples, if not resampling in 48KHz
			if [ "$(mediainfo "$line" | grep "Sampling rate" | cut -d ":" -f2 | tr -d " " | cut -d "." -f1 | grep -E '44|48')" ];then
				oggenc "$line" -o "$dest/$odir/`basename "${line%.*}.oga"`" -Q
				traitfic=1
			else
				if [ "$lang" == "fr" ];then
					echo -n " (conversion 48KHz)"
				elif [ "$lang" == "en" ];then
					echo -n " (resampling to 48KHz)"
				fi
				oggenc "$line" --resample=48000 -o "$dest/$odir/`basename "${line%.*}.oga"`" -Q
				traitfic=1
			fi	
		echo -en " \e[32m[OK]\033[0m"
		#If current file is not .flac, tests if it's lossy, then no need to encode, just direct copy
		elif [ "$(mediainfo "$line" | grep "Lossy")" ];then 
			if [ "$lang" == "fr" ];then
				echo -n " Compressé = copie directe"
			elif [ "$lang" == "en" ];then
				echo -n " Lossy = direct copy"
			fi
			cp "$line" "$dest/$odir/"
			traitfic=1
			echo -en " \e[32m[OK]\033[0m"
		fi
		#COVER
		#Test if cover already existants on destination
		traitcov=0
		if [ -r "$dest/$odir/folder.jpg" ];then
			if [ "$lang" == "fr" ];then
				echo -ne " | Cover existante \e[32m[OK]\033[0m"
			elif [ "$lang" == "en" ];then
				echo -ne " | Cover exists \e[32m[OK]\033[0m"
			fi
			traitcov=1
		else
			#Cover don't exists and current file encoded or copied = let's go for the cover
			if [ -r "$(echo "$(dirname "$line")/$(ls "$(dirname "$line")" | grep -i -m 1 -e ".jpg$\|.jpeg$\|.png$\|.bmp$")")" -a -d "$dest/$odir" -a $traitfic -eq 1 ];then
				#Test if dimension (W or H) is greater than 300 pixels, resize to 300 pixels
				if [ "$(mediainfo echo "$(dirname "$line")/$(ls "$(dirname "$line")" | grep -i -m 1 -e ".jpg$\|.jpeg$\|.png$\|.bmp$")" | grep Width | cut -d ":" -f2 | tr -d [a-z] | tr -d " ")" -gt 300 -o "$(mediainfo echo "$(dirname "$line")/$(ls "$(dirname "$line")" | grep -i -m 1 -e ".jpg$\|.jpeg$\|.png$\|.bmp$")" | grep Height | cut -d ":" -f2 | tr -d [a-z] | tr -d " ")" -gt 300 ];then
					convert -resize 300 "$(dirname "$line")/$(ls "$(dirname "$line")" | grep -i -m 1 -e ".jpg$\|.jpeg$\|.png$\|.bmp$")" "$dest/$odir/folder.jpg"
					if [ $? -eq 0 ];then
						if [ "$lang" == "fr" ];then
							echo -ne " | Redimensionnement cover \e[32m[OK]\033[0m"
						elif [ "$lang" == "en" ];then
							echo -ne " | Cover resize \e[32m[OK]\033[0m"
						fi
						traitcov=1
					else
						if [ "$lang" == "fr" ];then
							echo -ne " | Redimensionnement cover \033[31m[ERREUR]\033[0m"
						elif [ "$lang" == "en" ];then
							echo -ne " | Cover resize \033[31m[ERROR]\033[0m"
						fi
					fi
				else
				#Cover already OK, direct copy
				cp "$(dirname "$line")/$(ls "$(dirname "$line")" | grep -i -m 1 -e ".jpg$\|.jpeg$\|.png$\|.bmp$")" "$dest/$odir/folder.jpg"
				if [ $? -eq 0 ];then
					if [ "$lang" == "fr" ];then
						echo -ne " | Copie cover \e[32m[OK]\033[0m"
					elif [ "$lang" == "en" ];then
						echo -ne " | Cover copy \e[32m[OK]\033[0m"
					fi
					traitcov=1
				else
					if [ "$lang" == "fr" ];then
						echo -ne " | Copie cover \033[31m[ERREUR]\033[0m"
					elif [ "$lang" == "en" ];then
						echo -ne " | Cover copy \033[31m[ERROR]\033[0m"
					fi
				fi
				fi
			fi
			#Flag traitcov = 0 : no cover for this file
			if [ $traitcov -eq 0 ];then
				if [ "$lang" == "fr" ];then
					echo -ne " | Pas de cover \033[1;40m\033[1;33m[ATTENTION]\033[0m"
				elif [ "$lang" == "en" ];then
					echo -ne " | No cover \033[1;40m\033[1;33m[WARNING]\033[0m"
				fi
			fi
		fi
	fi
#traitfic = 1 then current file OK, let's write a separator
if [ $traitfic -eq 1 ];then
echo ""
echo "-----------------"
fi
done < /tmp/$pid`basename "$pls"`
#End of playlist, let's check and give files that don't are present in destination
if [ "$lang" == "fr" ];then
	echo -n "Vérifications des fichiers..."
elif [ "$lang" == "en" ];then
	echo -n "Checking files..."
fi
while read line; do
	if [ ! "$(find "$dest" -name "`basename "${line%.*}"`*")" ];then
		if [ "$lang" == "fr" ];then
			echo -e "\033[31mABSENT\033[0m : $line"
		elif [ "$lang" == "en" ];then
			echo -e "\033[31mMISSING\033[0m : $line"
		fi
	fi
done < /tmp/$pid`basename "$pls"`
if [ "$lang" == "fr" ];then
	echo -en "\e[32m[OK] Terminé\033[0m"
elif [ "$lang" == "en" ];then
	echo -en "\e[32m[OK] Finished\033[0m"
fi
echo -e
#Remove temp files
if [ "$lang" == "fr" ];then
	echo "Nettoyage des fichiers temporaires du script..."
elif [ "$lang" == "en" ];then
	echo "Removing script's temp files..."
fi
rm -v "/tmp/$pid`basename "$pls"`"
rm -v "/tmp/cut-$pid`basename "$pls"`"
#END
exit 0
