Management of multi-user secret files with GPG 


Planned features
----------------

* Password management using GPG over git
	* encryption
	* signature
* Commands
	* --summary dir: Who has access to which file and last edited them
	* --list mysecretfile.gpg: list security information about an encrypted file including permissions
	* --cat mysecretfile.gpg: display the content of an encrypted file
	* --decrypt me@example.com mysecretfile.gpg: decrypt an encrypted file, wait for the user when they're finished and re-encrypt if the file was modified
	* --add-file me@example.com mysecretfile: Encrypt a file and add it to the repo
	* --add-key other@example.com me@example.com mysecretfile.gpg: Re-encrypt a file adding a new recipient
	* --scan dir: Scan for non .sig or .gpg files

