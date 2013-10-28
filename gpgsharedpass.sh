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
		--scan)
                        if [ $# -gt 1 ]
                        then
				find $2 -path ./.git -prune -o ! -name '*.gpg' ! -name '*.sig' -type f -print
			else
				echo "Error: --scan <dir>"
			fi
			break
			;;
		--summary)
			if [ $# -gt 1 ]
			then
				find . -type file -name '*.gpg' -print > .files.tmp
				while read line
				do
					echo $line
					gpg --list-only -vv $line
					gpg --verify ${line%.*}.sig $line
					echo ""
				done < .files.tmp
				$SHRED .files.tmp
			else
				echo "Error: --summary <dir>"
			fi
			break
			;;
		--add-file)
                        if [ $# -gt 2 ]
                        then
				for file in $(find $3 -type file)
				do
					gpg -r $2 --encrypt $file
					gpg --output $file.sig -u $2 --detach-sign $file.gpg
					git add $file.gpg $file.sig
					git commit -m "$file added by $2"
				done
				$SHRED $file
                        else
                                echo "Error: --add-file <me@example.com> <myfile_OR_mydirectory>"
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
				gpg --decrypt $4 > ${4%.*}
				gpg `echo $RECPT`  --encrypt ${4%.*}
				gpg --output ${4%.*}.sig -u $3 --detach-sign $4
				$SHRED .keys.tmp
				git add ${4%.*}.sig $4
				git commit
				$SHRED ${4%.*}
                        else
                                echo "Error: --add-key <other@example.com> <me@example.com> <myfile.gpg>"
                        fi
			break
			;;
		--decrypt)
                        if [ $# -gt 2 ]
                        then
                                gpg --verify ${3%.*}.sig $3
				gpg --list-only -vv $3 2>> .list.tmp
                                sed -n 's/.*public key is \(.*\).*/\1/p' .list.tmp > .keys.tmp
                                $SHRED .list.tmp
                                RECPT=""
                                while read line
                                do
                                        RECPT="$RECPT -r $line"
                                done < .keys.tmp
                                gpg --decrypt $3 > ${3%.*}
				shasum ${3%.*} > .shasum.tmp
				echo "The file has been decrypted"
				echo "Press [Enter] to encrypt it again and delete the decrypted file"
				echo "A new signature and a new commit will be done if the file has changed"
				# stop
				read -p ""
				shasum ${3%.*} > .shasum.new.tmp
				if [ "`cmp ".shasum.new.tmp" ".shasum.tmp"`" != "" ]
				then
                                	gpg `echo $RECPT`  --encrypt ${3%.*}
					$SHRED ${3%.*}.sig
                                	gpg --output ${3%.*}.sig -u $2 --detach-sign $3
                                	$SHRED .keys.tmp
                                	git add ${3%.*}.sig $3
                                	git commit
				fi
                                $SHRED ${3%.*} .shasum.tmp .shasum.new.tmp
                        else
                                echo "Error: --decrypt <me@example.com> <mysecretfile.gpg>"
                        fi
			break;;
		--edit)
			if [ $# -gt 2 ]
                        then
                                gpg --verify ${3%.*}.sig $3
				gpg --list-only -vv $3 2>> .list.tmp
                                sed -n 's/.*public key is \(.*\).*/\1/p' .list.tmp > .keys.tmp
                                $SHRED .list.tmp
                                RECPT=""
                                while read line
                                do
                                        RECPT="$RECPT -r $line"
                                done < .keys.tmp
                                gpg --decrypt $3 > ${3%.*}
				shasum ${3%.*} > .shasum.tmp
				echo "The file has been decrypted"
				echo "Press [Enter] to encrypt it again and delete the decrypted file"
				echo "A new signature and a new commit will be done if the file has changed"
				# stop
				if [ -z "${EDITOR}" ] 
				then
					if ! which vim >/dev/null;
					then
						if ! which nano >/dev/null;
						then
							open ${3%.*}
						else
							nano ${3%.*}
						fi
					else
						vim ${3%.*}
					fi
				else
					$EDITOR ${3%.*}
				fi
				shasum ${3%.*} > .shasum.new.tmp
				if [ "`cmp ".shasum.new.tmp" ".shasum.tmp"`" != "" ]
				then
                                	gpg `echo $RECPT`  --encrypt ${3%.*}
					$SHRED ${3%.*}.sig
                                	gpg --output ${3%.*}.sig -u $2 --detach-sign $3
                                	$SHRED .keys.tmp
                                	git add ${3%.*}.sig $3
                                	git commit
				fi
                                $SHRED ${3%.*} .shasum.tmp .shasum.new.tmp
                        else
                                echo "Error: --edit <me@example.com> <mysecretfile.gpg>"
                        fi
			break;;
	
		*)
                        echo "GPG Shared Password Manager"
			echo "Anthony Verez (netantho) <netantho@nextgenlabs.net>"
                        echo " "
                        echo "-h, --help        						Show brief help"
                        echo "--summary <dir>							Who has access to which file and last edited them"
			echo "--list <myfile.gpg>						List security information about an encrypted file including permissions"
			echo "--cat <myfile.gpg>						Display the content of an encrypted file"
			echo "--decrypt <me@example.com> <myfile.gpg>				Decrypt an encrypted file, wait for the user when they're finished and re-encrypt if the file was modified"
			echo "--edit <me@example.com> <myfile.gpg>				Decrypt an encrypted file, open an editor to modify it and re-encrypt if the file was modified"
			echo "--add-file <me@example.com> <myfile_OR_mydirectory> 		Encrypt all files into a directory and add all to the repo"
			echo "--add-key <other@example.com> <me@example.com> <myfile.gpg>	Reencrypt a file adding a new recipient"
			echo "--scan <dir>							Scan a directory for non .sig or .gpg files"
                        exit 0
                        ;;
        esac
done
