#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
	SHRED=srm
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	SHRED=shred
fi

while test $# -gt 0; do
        case "$1" in
		--list)
                	if [ $# -gt 1 ]
			then
				gpg --status-fd 1 --list-only -vv $2
				gpg --verify ${2%.*}.sig $2
			else
				echo "Error: --list <myfile.gpg>"
			fi
			break
			;;
		--summary)
			find . -type file -name \*.gpg -print > .files.tmp
			while read line
			do
				echo $line
				gpg --status-fd 1 --list-only -vv $line
				gpg --verify ${line%.*}.sig $line
				echo ""
			done < .files.tmp
			$SHRED .files.tmp
			break
			;;
		--add-file)
                        if [ $# -gt 2 ]
                        then
				gpg -r $2 --encrypt $3
				gpg --output $3.sig -u $2 --detach-sign $3.gpg
				git add $3.gpg $3.sig
				git commit
				$SHRED $3
                        else
                                echo "Error: --add-file <mail@example.com> <myfile>"
                        fi
                        break
                        ;;
		--cat)
                        if [ $# -gt 1 ]
                        then
				gpg --verify ${2%.*}.sig $2
				gpg --decrypt $2
                        else
                                echo "Error: --cat <myfile.gpg>"
                        fi
                        break
                        ;;
		--add-key)
                        if [ $# -gt 3 ]
                        then
                                gpg --verify ${4%.*}.sig $3
				gpg --list-only -vv $4 2>> .list.tmp
				sed -n 's/.*public key is \(.*\).*/\1/p' .list.tmp > .keys.tmp
				echo $2 >> .keys.tmp
				$SHRED ${4%.*}.sig .list.tmp
				RECPT=""
                        	while read line
                        	do
                                	RECPT="$RECPT -r $line"
                        	done < .keys.tmp
				echo $RECPT
				gpg --decrypt $4 > ${4%.*}
				gpg `echo $RECPT`  --encrypt ${4%.*}
				gpg --output ${4%.*}.sig -u $3 --detach-sign $4
				$SHRED .keys.tmp ${4%.*}
                        else
                                echo "Error: --add-key <other@example.com> <me@example.com> <myfile.gpg>"
                        fi
			break
			;;
		*)
                        echo "GPG Shared Password Manager"
			echo "Anthony Verez (netantho) <netantho@nextgenlabs.net>"
                        echo " "
                        echo "-h, --help        					show brief help"
                        echo "--summary	<mysecretfolder>			show a summary of permissions on a folder"
			echo "--cat <myfile.gpg>					display the decrypted content of myfile.gpg"
			echo "--store <myfile.gpg>					temporary store myfile"
			echo "--list <myfile.gpg>					show permissions on a file"
			echo "--add-key	<alice@example.com> <myfile.gpg>	encrypt a file with adding a new key"
                        exit 0
                        ;;
        esac
done
