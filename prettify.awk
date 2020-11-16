function htmlsanitise(a){
	result = gensub(/</, "\\&lt;", "g", a)
	result = gensub(/>/, "\\&gt;", "g", result)
	return result
}

# takes a spoken/printed line, returns formatted and ready text
function get_text(line){
	split(line,linearr,"\"")
	ln = linearr[2]
	if (ln ~ /[<>]/){
		ln = htmlsanitise(ln)
	}
	if (ln ~ /[（）]/){
		ln = gensub(/([一-龯]+)（([一-龯]+)）/, "<ruby>\\1<rt>\\2</rt></ruby>", "g", ln)
	}
	return "<p>" ln "</p>"
}

# takes line depicting character name in modded higurashi scripts, returns formatted name text
function get_charname(line){
	split(line, chararr, ">|<")
	sub("=", ":", chararr[2])
	return "<p style=\"font-weight: bold;\"> <span style=\"" chararr[2] "; \"> &#9830; </span>" chararr[3] "</p>"
}

# takes a filename and subroutine name & writes out the content of that sub to the output file
function get_external_text(ext_filename, ext_subname){
	# read until specified sub is encountered
	do {
		morelines = getline < ext_filename
		if ($0 ~ ext_subname){break}
	} while (morelines)
	hangingOpenBrackets = 0 
	hangingOpenBrackets += gsub("{","") # just in case the first bracket is opened on the sub name line
	hangingOpenBrackets -= gsub("}","")
	# read relevant lines into output text file until end of sub or file is encountered
	do {
		morelines = getline < ext_filename
		if ($0 ~ /ClearMessage/){
			print "\n<p><br/></p>\n" > outputtxt
			print " - break - "
		}
		if ($0 ~ /GADVMode.*OutputLine\>.+color=/){
			print get_charname($0) > outputtxt
			print get_charname($0)
		}
		if ($0 ~ /OutputLine\(NULL/){
			print get_text($0) > outputtxt
			print "line: " get_text($0) 
		}
		if ($0 ~ /^void dialog/){break}
		hangingOpenBrackets += gsub("{","")
		hangingOpenBrackets -= gsub("}","")
	} while (morelines && hangingOpenBrackets)
	close(ext_filename) # ensure file is re-opened and read from the beginning next time
}	
BEGIN {
	FS = "\""
	maintxtfile = "p-001.txt"
	mainxhtmlfile = "p-001.xhtml"
	maintxt = "book-template/item/xhtml/" maintxtfile
	tipstxtfile = "tips.txt"
	tipsxhtmlfile = "tips.xhtml"
	tipstxt = "book-template/item/xhtml/" tipstxtfile
	++tocid
	tocs[tocid] = "イントロ"
	print "<h2 class=\"oo-midashi\" id=\"toc-" tocid "\">" tocs[tocid] "</h2>\n<p><br/></p>" > maintxt 
}
BEGINFILE {
	if (tolower(FILENAME) ~ /^[^z].+tip.+txt$/){
		# file is a tips file, link to tip footnote & set output variable to footnote file
		outputtxt = tipstxt
		print "\n<br/>\n<aside class=\"footnote\" epub:type=\"footnote\" id=\"tip" ++tipno "\">" > outputtxt
	} else {
		# file is normal story script, set output variable to main body text file
		outputtxt = maintxt 
		print "\n<br/>\n" > outputtxt
	}
	found = 0
}

# skip files starting z, containing 'tip', and ending txt (original/censored text files from higurashi mod)
{if (tolower(FILENAME) ~ /^z.+tip.+txt$/) {nextfile}}

# get titles for table of contents (also format titles)
/■/{
        if (! found) {
                found = 1
                titletext = gensub(/.*■(.+).$/, "\\1", 1)
		if (tolower(FILENAME) ~ /tips/){
                	print "<h2 class=\"oo-midashi\">" titletext "</h2>\n<p><br/></p>" > outputtxt
			++tipno_backref_id
		} else {
	                print "<h2 class=\"oo-midashi\" id=\"toc-" ++tocid "\">" titletext "</h2>\n<p><br/></p>" > outputtxt
			tocs[tocid] = titletext
		}
        }
}

/ClearMessage/{
	print "\n<p><br/></p>\n" > outputtxt
}

# Include the name of the character who is speaking (when available in modded script)
/GADVMode.*OutputLine\>.+color=/{
	print get_charname($0) > outputtxt
}

/OutputLine\(NULL/{
	print get_text($0) > outputtxt
}

# retrieve content loaded from external scripts in 07th-mod modded version of higurashi
/ModCallScriptSection/ {
	if($2 ~ /&/){next} # filter out filenames containing "&" character
	gtet = strtonum(substr($1, match($1, "[0-9]"), 1))
	if (censor_level >= gtet) {
		ext_filename = $2 ".txt"
		ext_subname = $4
	}
	getline
	ltet = strtonum(substr($1, match($1, "[0-9]"), 1))
	if (censor_level <= ltet) {
		ext_filename = $2 ".txt"
		ext_subname = $4
	}
	print "mod ext file and sub name: " ext_filename " - " ext_subname  
	get_external_text(ext_filename, ext_subname) 
}

# place tip footnote link in main body text
/TIPS_NEW/{
	print "<p>Tip <a class=\"noteref\" epub:type=\"noteref\" id=\"tip_body-" ++tipno_body "\" href=\"" tipsxhtmlfile "#tip" tipno_body "\">" tipno_body "</a></p>" > outputtxt
}

ENDFILE {
	# assume tip files starting with "z" are in fact mod scripts
	if (tolower(FILENAME) ~ /^[^z].+tip.+txt$/){ 
		# place link back to main body text at end of tip footnote & close footnote aside tag
		print "<a href=\"" mainxhtmlfile "#tip_body-" tipno_backref_id "\">戻る</a></aside>" > outputtxt
		print "\n<br/>\n" > outputtxt
	}
}

END{
	for (i = 1; i <= tocid; ++i){
		print "<li><a href=\"xhtml/p-001.xhtml#toc-" i "\">" tocs[i] "</a></li>" > "book-template/item/navigation-documents.txt"
		print "<p><a href=\"p-001.xhtml#toc-" i "\">" tocs[i] "</a></p>" > "book-template/item/xhtml/p-toc.txt"
	}
}
