function htmlsanitise(a){
	result = gensub(/</, "\\&lt;", "g", a)
	result = gensub(/>/, "\\&gt;", "g", result)
	return result
}

function get_text(line){
	split(line,linearr,"\"")
	ln = linearr[2]
	if (ln ~ /[<>]/){
		ln = htmlsanitise(ln)
	}
	if (ln ~ /[（）]/){
		ln = gensub(/([亜-熙纊-黑]{1,4})（([ぁ-ゔァ-ヺ]+)）/, "<ruby>\\1<rt>\\2</rt></ruby>", "g", ln)
	}
	printf "<p>" ln "</p>" > outputtxt
}

function get_charname(line){
	split(line, chararr, ">|<")
	sub("=", ":", chararr[2])
	print "<p style=\"font-weight: bold;\"> <span style=\"" chararr[2] "; \"> &#9830; </span>" chararr[3] "</p>" > outputtxt
}

function get_external_text(ext_filename, ext_subname){
	do {
		morelines = getline < ext_filename
		if ($0 ~ ext_subname){break}
	} while (morelines)
	do {
		morelines = getline < ext_filename
		if ($0 ~ /ClearMessage/){
			print "\n<p><br/></p>\n" > outputtxt
			print "line!!"
		}
		if ($0 ~ /GADVMode.*OutputLine\>/){
			get_charname($0)
			print "character name!"
		}
		if ($0 ~ /OutputLine\(NULL/){
			get_text($0)
			print "text line!"
		}
		if ($0 ~ /^void dialog/){break}
	} while (morelines)
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
	if (tolower(FILENAME) ~ /tips/){
		outputtxt = tipstxt
		print "\n<br/>\n<aside class=\"footnote\" epub:type=\"footnote\" id=\"tip" ++tipno "\">" > outputtxt
	} else {
		outputtxt = maintxt 
		print "\n<br/>\n" > outputtxt
	}
	found = 0
}
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
/GADVMode.*OutputLine\>/{
	get_charname($0)
}

/OutputLine\(NULL/{
	get_text($0)
}

# potential location to insert new lines
#/OutputLineAll/{
#	print "\n<br/>\n" > outputtxt
#}

# retrieve content loaded from external scripts in 07th-mod modded version of higurashi
/ModCallScriptSection/ {
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

/TIPS_NEW/{
	print "<p>Tip <a class=\"noteref\" epub:type=\"noteref\" id=\"tip_body-" ++tipno_body "\" href=\"" tipsxhtmlfile "#tip" tipno_body "\">" tipno_body "</a></p>" > outputtxt
}

ENDFILE {
	if (tolower(FILENAME) ~ /tips/){
		print "<a href=\"" mainxhtmlfile "#tip_body-" tipno_backref_id "\">戻る</a></aside>" > outputtxt
	}
	print "\n<br/>\n" > outputtxt
}

END{
	for (i = 1; i <= tocid; ++i){
		print "<li><a href=\"xhtml/p-001.xhtml#toc-" i "\">" tocs[i] "</a></li>" > "book-template/item/navigation-documents.txt"
		print "<p><a href=\"p-001.xhtml#toc-" i "\">" tocs[i] "</a></p>" > "book-template/item/xhtml/p-toc.txt"
	}
}
