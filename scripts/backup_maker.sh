#!/bin/bash

#-------------------- VARIABLES -------------------
#Create the variables to format the text print easily.
RED="\e[31m"
BLUE="\e[34m"

LIGHTYELLOW="\e[1;33m"
LIGHTGREEN="\e[92m"
LIGHTBLUE="\e[96m"
LIGHTRED="\e[91m"

UNDERGREEN="\e[102m\e[30m"
UNDERRED="\e[101m\e[30m"
UNDERBLUE="\e[106m\e[30m"

BLINK="\e[5m"
BOLD="\e[1m"
DEFAULT="\e[0m"
HIDEN="\e[8m"

END="\e[0m"



# ----------------------- FUNCTIONS -------------------------
#This functions check if there is a mountpoint in the selected disk to print the UUID and tabulate to mantain the format of the table.
checkMount(){
	#If there isn't mountpoint...
	if [[ $mountdisk == '' ]];
	then
		#...prints the UUID of the disk with 3 tabulations
		echo -e "\t\t\t"$ptuuid
	#...but if there is a mountpoint,
	else
		#...prints the UUID of the disk with 2 tabulations
		echo -e "\t\t"$ptuuid
	fi
}

#This function prints the table with the disks and information of them with the correspond color
printDisks()
{
	#Saves the arguments with the colors to the colors variables.
	COLOR1=$1
	COLOR2=$2
	COLOR3=$3
	COLOR4=$4

	#Print the head of the table
	echo -e $LIGHTYELLOW$BOLD"\t\t""DISK""\t\t""SIZE""\t\t""TYPE""\t\t""MOUNTPOINT""\t\t""UUID"$END$END

	#Saves the output of the lsblk command in the temporary directory (/temp)
	sudo lsblk > /tmp/lsblk_tmp_file

	#Counts and saves the number of lines in the lsblk command in the file created in /temp
	linesnumber=`sudo cat /tmp/lsblk_tmp_file | grep disk | wc -l`

	#Creates a loop that repeats so many times as lines have the lsblk command
	for line in $(seq 1 $linesnumber);
	do
		#Saves the information of the target and source disks in the variables
		sourcediskUUID=`sudo cat /usr/include/backup_maker.conf | grep "SOURCE DISK: UUID=" | cut -f2 -d= 2> /dev/null`
		sourcediskSIZE=`sudo cat /usr/include/backup_maker.conf | grep "SOURCE DISK: Size=" | cut -f2 -d= 2> /dev/null`
		sourcediskNAME=`sudo cat /usr/include/backup_maker.conf | grep "SOURCE DISK: Name=" | cut -f2 -d= 2> /dev/null`

		targetdiskUUID=`sudo cat /usr/include/backup_maker.conf | grep "TARGET DISK: UUID=" | cut -f2 -d= 2> /dev/null`
		targetdiskSIZE=`sudo cat /usr/include/backup_maker.conf | grep "TARGET DISK: Size=" | cut -f2 -d= 2> /dev/null`
		targetdiskNAME=`sudo cat /usr/include/backup_maker.conf | grep "TARGET DISK: Name=" | cut -f2 -d= 2> /dev/null`

		#Saves the name of the last disk founded
		namedisk=`sudo cat /tmp/lsblk_tmp_file | grep disk | head -n $line | tail -n 1 | tr -s " " | cut -f1 -d" " | tr " " "\t"`
		#Saves the size of the last disk founded
		sizedisk=`sudo cat /tmp/lsblk_tmp_file | grep disk | head -n $line | tail -n 1 | tr -s " " | cut -f4 -d" " | tr " " "\t"`
		#Saves the type of the last disk founded
		typedisk=`sudo cat /tmp/lsblk_tmp_file | grep disk | head -n $line | tail -n 1 | tr -s " " | cut -f6 -d" " | tr " " "\t"`
		#Saves the mountpoint of the last disk founded
		mountdisk=`sudo cat /tmp/lsblk_tmp_file | grep part | head -n $line | tail -n 1 | tr -s " " | cut -f7-8 -d" " | tr " " "\t"`
		#Saves the PTUUID of the last disk founded
		ptuuid=`sudo blkid /dev/$namedisk | grep -wo PTUUID=\"[0-9a-z\-]*\" | cut -f2 -d'"'`


		#If the name of the disk in lsblk is equal to the target disk variables -> TARGET DISK
		if [[ $namedisk == $targetdiskNAME && $sizedisk == $targetdiskSIZE && $ptuuid == $targetdiskUUID ]];
		then
			#...prints the name and information of the disk in green.
			echo -ne $LIGHTGREEN$BLINK"Target    -> \t"$END$END$COLOR1$namedisk$END"\t\t"$sizedisk"\t\t"$typedisk"\t\t"$COLOR1$mountdisk$END

		#If the name of the disk in lsblk is equal to the source disk variables -> SOURCE DISK
		elif [[ $namedisk == $sourcediskNAME && $sizedisk == $sourcediskSIZE && $ptuuid == $sourcediskUUID ]];
		then
			#...prints the name and information of the disk in blue.
			echo -ne $LIGHTBLUE$BLINK"Source    -> \t"$END$END$COLOR2$namedisk$END"\t\t"$sizedisk"\t\t"$typedisk"\t\t"$COLOR2$mountdisk$END

		#...but if the disk doesn't match with the source or target disk...
		else
			#...prints the disk and the information in red and says to the user that this disk should not be touched
			echo -ne $COLOR4"No touch  -> \t"$END$COLOR3$namedisk$END"\t\t"$sizedisk"\t\t"$typedisk"\t\t"$COLOR3$mountdisk$END

		fi

		#...checks if the is a montpoint available in the actual disk
		checkMount
	done
}

#----------------------- THE PROGRAM -----------------------
#----------- Creating the config file -----------
#Clear the terminal
clear

#Start an infinite loop
while true;
do
	#Extract the content of the config file
	checkConfigContent=`cat /usr/include/backup_maker.conf 2> /dev/null`

	#If there is no content in the config file...
	if [[ $checkConfigContent == '' ]];
	then
		echo ""

		#Print the available disks and te information of it
		printDisks $DEFAULT $DEFAULT $DEFAULT $HIDEN


		echo ""
		echo ""
		echo ""
		echo -e $LIGHTYELLOW$BOLD"CONFIGURATION (avoid errors with colors :D)"$END$END
		echo ""
		#Ask for the UUID, Size and name of the source disk and saves it in the variables
		echo -e $LIGHTYELLOW$BOLD"Type the UUID (example a76ada7e-8910), the size (example 14.9G) and the name (example sda) of the source disk (the disk you want to backup)"$END$END
		echo ""

		echo -ne $BLINK">"$END" [ UUID ]: "$LIGHTGREEN
		read sourcediskUUIDwarning
		echo -ne $END

		echo -ne $BLINK">"$END" [ Size ]: "$LIGHTGREEN
		read sourcediskSIZEwarning
		echo -ne $END

		echo -ne $BLINK">"$END" [ Name ]: "$LIGHTGREEN
		read sourcediskNAMEwarning
		echo -ne $END


		echo ""

		#Ask for the UUID, Size and name of the destination disk and saves it in the variables
		echo -e $LIGHTYELLOW$BOLD"Type the UUID (example a76ada7e-8910), the size (example 14.9G) and the name (example sda) of the target disk (the disk where you want to save the backup)"$END$END
		echo -ne $BLINK">"$END" [ UUID ]: "$LIGHTGREEN
		read targetdiskwarning
		echo -ne $END

		echo -ne $BLINK">"$END" [ Size ]: "$LIGHTGREEN
		read targetdiskSIZEwarning
		echo -ne $END

		echo -ne $BLINK">"$END" [ Name ]: "$LIGHTGREEN
		read targetdiskNAMEwarning
		echo -ne $END

		echo ""

		#Saves the value of the variables with an identifier
		echo -e "SOURCE DISK: UUID="$sourcediskUUIDwarning >> /usr/include/backup_maker.conf
		echo -e "SOURCE DISK: Size="$sourcediskSIZEwarning >> /usr/include/backup_maker.conf
		echo -e "SOURCE DISK: Name="$sourcediskNAMEwarning >> /usr/include/backup_maker.conf

		echo -e "TARGET DISK: UUID="$targetdiskwarning >> /usr/include/backup_maker.conf
		echo -e "TARGET DISK: Size="$targetdiskSIZEwarning >> /usr/include/backup_maker.conf
		echo -e "TARGET DISK: Name="$targetdiskNAMEwarning >> /usr/include/backup_maker.conf

		#Clear the terminal
		clear

		#Break the infinite bucle
		break

	#but if there is content in the config file...
	else
		#Print the config file, ask the user if he wants to use that configuration and saves the response in the variable response
		echo ""
		echo -e $LIGHTYELLOW$BOLD"There is an existing configuration. Do yo want to continue with this configuration?"$END$END
		cat /usr/include/backup_maker.conf

		echo ""
		echo -ne $BLINK">"$END" [ y/n ]: "$LIGHTGREEN

		read response

		echo -ne $END

		#In the case that the user reponse...
		case $response in
			#...yes, clear the terminal and break the infinite bucle
			y)
				clear

				break
				;;
			#...no, clear the terminal and erase the content of the config file without breaking the infinite bucle,
			#so the script will return to the start of the bucle
			n)
				clear

				echo "" > /usr/include/backup_maker.conf
				;;
		esac
	fi
done


#----------- Creating the backup -----------
#Call the printDisks with the colors specified in the arguments
#		   $1		   $2		  $3	    $4
echo ""
printDisks $UNDERGREEN $UNDERBLUE $UNDERRED $LIGHTRED

#Ask for the source disk and saves the name of the disk in the variable sourcedisk
echo ""
echo ""
echo ""
echo -e $LIGHTYELLOW$BOLD"CREATE THE BACKUP (ok, be carefull pls)"$END$END
echo ""
echo -e $RED$BOLD"ATTENTION! "$END$END$LIGHTYELLOW$BOLD"Type the "$UNDERRED$LIGHTYELLOW"SOURCE"$END$LIGHTYELLOW"  device (the device you want to backup. Example /dev/sda)"$END$END
echo -ne $BLINK">"$END" /dev/"$LIGHTGREEN

read sourcedisk

echo -e $END

#Ask for the target disk and saves the name of the disk in the variable targetdisk
echo -e $RED$BOLD$"ATTENTION! "$END$END$LIGHTYELLOW$BOLD"Type the "$UNDERRED$LIGHTYELLOW"TARGET"$END$LIGHTYELLOW" device (the device where you want to save the backup. Example /dev/sdb)"$END$END
echo -ne $BLINK">"$END" /dev/"$LIGHTGREEN

read targetdisk

while true;
do
	#Ask the user to confirm that want to make the backup
	echo ""
	echo -e $RED$BOLD$"LAST CHANCE TO CANCEL! "$END$END$LIGHTYELLOW$BOLD"Let me ask you again. Really you want to copy all content from /dev/"$END$LIGHTBLUE$sourcedisk$END$LIGHTYELLOW" to /dev/"$END$LIGHTGREEN$targetdisk$END$END$LIGHTYELLOW" ???"$END
	echo -ne $BLINK">"$END" [ y/n ]: "$LIGHTGREEN

	read confirm

	#In case that user response...
	case $confirm in
		#...yes
		y)
			#Start the LIGHTYELLOW color
			echo -e $LIGHTYELLOW

			#Start the backup in background
			dd if=/dev/$sourcedisk of=/dev/$targetdisk &

			#Extract the PID of the process dd in background
			#The grep start with [0-9] to avoid the command be confused with grep's own pid
			#What should catch
			#       root     20914  8.9  0.0   3424   348 pts/1    D    00:58   0:53 dd if=/dev/mmcblk0 of=/dev/sda
			#What shouldn't catch
			#       pi        6141  0.0  0.2   4272  1960 pts/0    S+   01:06   0:00 grep --color=auto dd if=/dev/
			ddpid=`ps aux | grep "[0-9] dd if=/dev/$sourcedisk of=/dev/$targetdisk" | head -n 1 | tail -n 1 | tr -s " " | cut -f2 -d" "`

			#Create the variable loading
			loading=0

			#Starts another infinite bucle
			while true;
			do
				#Extract another time the PID of the process to compare with the first PID
				newddpid=`ps aux | grep "[0-9] dd if=/dev/$sourcedisk of=/dev/$targetdisk" | head -n 1 | tail -n 1 | tr -s " " | cut -f2 -d" "`

				#If the process is equal to the new process (dd is working in background yet)
				if [[ $ddpid == $newddpid ]];
				then
					#...sum 1 to the variable loading
					let loading=loading+1

					#...prints a dot without carriage return
					echo -ne "."

					#...wait a sec
					sleep 1

				#...but if the PID dosn't match with the new PID (dd is finished backuping)...
				else

					#...prints the time lapsed.
					echo ""
					TIME=$loading
					h=$(($loading/3600))
					m=$((($loading%3600)/60))
					s=$(($loading%60))

					echo -ne "Time lapsed: "
					echo -ne $h":"$m":"$s

					#...breaks the bucle
					break
				fi
			done

			#End the LIGHTYELLOW format
			echo ""
			echo -e $END$END

			#Breaks the infinite bucle
			break

			;;

		n)
			;;
	esac
done
