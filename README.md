Management of multi-user secret files with GPG 


Features
--------

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
	* --scan dir: Scan a directory for non .sig or .gpg files

Todo
----

* Add configuration files for each secret repo
	* init command to create them
	* my recipient address
	* default recipients addresses to encrypt the files with
