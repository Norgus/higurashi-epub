#!/usr/bin/awk -f
# 
# Retrieves script names from flow.txt to compile the runfile
#
# pass flow.txt as argument:
# awk -f prettify_commandgen.awk flow.txt
BEGIN {
	FS = "\t"
	while (getline < "metadata.txt"){
		if ($1 == "Title"){title = $2}
		if ($1 == "Title file as"){titlefa = $2}
		if ($1 == "Author"){author = $2}
		if ($1 == "Author file as"){authorfa = $2}
		if ($1 == "Modified"){modified = $2}
		if ($1 == "Unique ID"){uniqueid = $2}
		if ($1 == "Ebook filename"){ebookname = $2}
		if ($1 == "Censorship level"){censor_level = $2}
	}
	runfile = "prettify_run.sh"
	ORS = " "
	print "awk -f prettify.awk censor_level=" censor_level " " > runfile
	FS = "\""
}

/\<CallScript\>/{
	print $2 ".txt" > runfile
}

# skip over bad ending files
/\<GChoiceMode\>/{
	do{
		hangingOpenBrackets = 0 
		hangingOpenBrackets += gsub("{","")
		hangingOpenBrackets -= gsub("}","")
		getline
	} while (hangingOpenBrackets)
}

END {
	print "*tips*txt" > runfile
	ORS = "\n"
	print "" > runfile
	print "sed -i -e 's/TITLE HERE/" title "/g' book-template/item/standard.opf book-template/item/xhtml/*" > runfile
	print "sed -i -e 's/TITLE FILEAS HERE/" titlefa "/g' book-template/item/standard.opf" > runfile
	print "sed -i -e 's/AUTHOR HERE/" author "/g' book-template/item/standard.opf book-template/item/xhtml/*" > runfile
	print "sed -i -e 's/AUTHOR FILEAS HERE/" authorfa "/g' book-template/item/standard.opf" > runfile
	print "sed -i -e 's/UNIQUE ID HERE/" uniqueid "/g' book-template/item/standard.opf" > runfile
	print "sed -i -e 's/MODIFIED HERE/" modified "/g' book-template/item/standard.opf" > runfile
	print "sed -i -e '/INSERT HERE/r book-template/item/navigation-documents.txt' -e '/INSERT HERE/d' book-template/item/navigation-documents.xhtml" > runfile
	print "rm book-template/item/navigation-documents.txt" > runfile
	print "sed -i -e '/INSERT HERE/r book-template/item/xhtml/p-toc.txt' -e '/INSERT HERE/d' book-template/item/xhtml/p-toc.xhtml" > runfile
	print "rm book-template/item/xhtml/p-toc.txt" > runfile
	print  "sed -i -e '/INSERT HERE/r book-template/item/xhtml/p-001.txt' -e '/INSERT HERE/d' book-template/item/xhtml/p-001.xhtml" > runfile
	print "rm book-template/item/xhtml/p-001.txt" > runfile
	print  "sed -i -e '/INSERT HERE/r book-template/item/xhtml/tips.txt' -e '/INSERT HERE/d' book-template/item/xhtml/tips.xhtml" > runfile
	print "rm book-template/item/xhtml/tips.txt" > runfile
	print "cd book-template\nzip -X0 ../" ebookname " mimetype\nzip -Xr ../" ebookname " *" > runfile
	print "cd ..\nrm book-template -rf" > runfile
	system("chmod +x " runfile)
}
