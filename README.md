Management of multi-user secret files with GPG 


Planned features
----------------

* Password management using GPG over git
* Commands
	* summary: Who has access to which file
	* list <mysecretfile.gpg>: list security information about an encrypted file including permissions
	* cat <mysecretfile.gpg>: display the content of an encrypted file
	* decrypt <mysecretfile.gpg>: decrypt an encrypted file, wait for the user when they're finished and re-encrypt if the file was modified
	* add-file <mail@example.com> <mysecretfile>: Encrypt a file and add it to the repo
	* add-key <mail@example.com> <mysecretfile.gpg>: Re-encrypt a file adding a new recipient

