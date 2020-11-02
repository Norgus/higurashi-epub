Description
===
This collection of scripts attempts to automate the conversion of Higurashi PC version (sold on steam) script files into a passable epub ebook file.

The final goal is to support added richness from modified scripts which can be found at https://github.com/07th-mod

Epub template based on the files provided in "電書協 EPUB 3 制作ガイド ver.1.1.3 2015年1月1日版" at http://ebpaj.jp/counsel/guide
Guidance from http://k-airyuu.hatenablog.com/entry/2014/02/27/211823 was employed to understand how to adapt the template for my usage.


Requirements
===
cygwin (or general linux shell environment? untested)  
	zip  
	awk  
	sed

Instructions
===
- Ensure that all files from this prettify distribution are in the same directory as the game script files for the game you are converting.
- Update the information in metadata.txt
- run prettify_init.sh from the shell, i.e.
``` ./prettify_init.sh ```
- Optionally convert the epub to kindle format (mobi) using kindlegen.exe (drag-drop works)

Files
===
book-template/	files that constitute the template used to create an epub  
'KindleGen Legal Notices 2013-02-19 Windows.txt'  
kindlegen.exe	for generating a mobi file from the epub file  
metadata.txt	important information about book (title, filename, etc)  
prettify.awk	does the actual processing of the game scripts  
prettify_commandgen.awk	prepares a script which runs everything else  
prettify_init.sh	starts the process of conversion, this is the only script you have to run manually  
README_prettify.txt	this file

Changelog
===
Version 1.0
--
Fixed issue with censored/original text pairs all being appended to footnotes.  
Refactored some code a little.  
Improved pattern matching used for applying ruby tags.

Version 0.9
--
Added "Censorship level" variable to metadata.txt and finally got correct parsing and loading of external
txt files.  
Currently bodges loading tips files with vague filename pattern, which leads to all of the censorship text
ending up appended to the end of the footnotes where it is not very welcome.

Version 0.7
--
Character names nicely formatted.  
Still incomplete text (not yet handling ModCallScriptSection calls loading in external scripts)

Version 0.6
--
Include the name of the character who is speaking (when available in modded script)  
Doesn't yet deal with "ModCallScriptSection", so incomplete text on modded game scripts

Version 0.5
--
Creates an epub of the Japanese script only.  
Two formats of index (table of contents) are generated.  
Hints are presented using footnotes linked at the end of their respective chapters.
