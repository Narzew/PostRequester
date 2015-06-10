#HTTP Post Requester
HTTP Post Requester - Tool to send HTTP POST Requests

Usage:

		ruby postrequester.rb URL field=value field=value @flag=value

Available flags:

Connection options:

		@port=nr - Change port number

Splitting response

		@sc=pattern - Split center - remove all before first and after second pattern
		@sr=pattern - Split right - remove all before pattern
		@sl=pattern - Split left - remove all after pattern
		
Logging options 

		@nolog=1 - Do not log requests
		@log=file - Change logfile to file
		@respsave=filename - Change response save filename (Clear content)
		@resplog=filename - Change response log filename (Keep content)
		@binary=1 - Save responses in binary mode
 
Converting values

		@sha1=field=value - Hash value with SHA1
		@md5=field=value - Hash value with MD5
		@b64=field=value - Encode value with Base64
		@uue=field=value - Encode value with UUEncode
		@db64=field=value - Decode value with Base64
		@duue=field=value - Decode value with UUEncode
  
Working with files 

		@file=field=value - Replace value with file data
		@sha1file=field=value - Replace value with SHA1 file hash
		@md5file=field=value - Replace value with MD5 file hash
		@b64file=field=value - Replace value with Base64 encoded file data
		@uuefile=field=value - Replace value with UUEncode encoded file data
		@db64file=field=value - Replace value with Base64 decoded file data
		@duuefile=field=value - Replace value with UUEncode decoded file data
		@zlibfile=field=value - Replace value with Zlib encoded file data
		@dzlibfile=field=value - Replace value with Zlib decoded file data
		
Authors 

		Script created by Narzew using Ruby
