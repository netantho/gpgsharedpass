#!/bin/bash

while test $# -gt 0; do
        case "$1" in
		--list)
                	if [ $# -gt 1 ]
			then
				gpg --status-fd 1 --list-only -vv $2
			else
				echo "Error: --list <myfile.gpg>"
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
