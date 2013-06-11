
# configuration variables
BASENAME=mypaper




# (internal) derived variables

# (internal) tools
## recursive wildcard
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))



# (internal) Targets of the Makefile
$(BASENAME).pdf: ${BASENAME}.tex $(call rwildcard,,*.bib) $(call rwildcard,,*.tex)
	pdflatex $<
	test ${BASENAME}.bib && bibtex   ${BASENAME}
	pdflatex $<
	pdflatex $<
	@echo "Making some classical checks on the pdf"
	@echo "=> looking for '?' that might be a missing reference"
	@pdftotext $@ - | grep -Hrn '[?]' -  | awk '{print "? in PDF: " $$0}'
	@echo "=> looking for 'TODO'"
	@grep -Hrn TODO *.tex | awk '{print "TODO: " $$0}'


.PHONY: export clean latexdiff

clean:
	rm -f ${BASENAME}.pdf ${BASENAME}.aux ${BASENAME}.bbl ${BASENAME}.blg ${BASENAME}.log ${BASENAME}.toc

export:
	rm -rf export
	mkdir export
	cat ${BASENAME}.tex | awk '/\\listfiles/ {next} /\\documentclass.*/ {print; print "\\listfiles"; next} // {print}' > ,,.tex
	cp ${BASENAME}.tex export/
# adding the base tex file (as it is not listed)
# adding the bibs also (as it uses the bbl actually) as they are useful to rebuild from scratch
	for i in ${BASENAME}.tex $$(find -name \*.bib) $$(pdflatex ,,.tex | awk '/ *\*File List\*/ {show=1; next;} / \*\*\*\*\*+/ {show=0;next} // {if (show) {print}}') ; do test -f $$i && mkdir -p export/$$(dirname $$i) && cp $$i export/$$(dirname $$i)/; done
	rm -f ,,.tex
	echo > export/Makefile
	echo ${BASENAME}.pdf: >> export/Makefile
	echo "	"pdflatex ${BASENAME}.tex >> export/Makefile
	echo "	"bibtex ${BASENAME} >> export/Makefile
	echo "	"pdflatex ${BASENAME}.tex >> export/Makefile
	echo "	"pdflatex ${BASENAME}.tex >> export/Makefile
	echo .PHONY: ${BASENAME}.pdf >> export/Makefile



with=NONE
latexdiff:
	@test ${with} '!=' NONE || (echo -n "\n\nPlease check you saved/commited everything and use something like \n    make latexdiff with=HEAD^\n\n"; false)
	rm -rf ,,latexdiff
	mkdir ,,latexdiff
	git rev-parse --abbrev-ref HEAD  | sed 's@^refs/heads/@@g' > ,,latexdiff.br
	test $$(cat ,,latexdiff.br) '!=' "HEAD"
	git stash save "Before latexdiff"
	git checkout ${with}
	for i in $$(find -name \*.tex) ; do mkdir -p ,,latexdiff/$$(dirname $$i) && cp $$i ,,latexdiff/$$(dirname $$i)/ ; done
	cat ,,latexdiff.br | xargs git checkout
	rm -f ,,latexdiff.br
	(cd ,,latexdiff && for i in $$(find -name \*.tex) ; do latexdiff $$i ../$$i > diff; yes | mv diff ../$$i; done)
	make || (echo -n "\n\nCompilation of diff'ed latex failed.\nPlease fix it, make and do whatever you want with the pdf.\nTHEN, run:\n    git reset --hard ; git stash apply\n\n" ; false) 
	mv ${BASENAME}.pdf latexdiff.pdf
	rm -rf ,,latexdiff
	@echo "INFO: Your diff file is in latexdiff.pdf"
	@echo "now reseting and apply stash"
	git reset --hard
	git stash apply || echo "INFO: stash apply might fail if nothing was uncommited"

