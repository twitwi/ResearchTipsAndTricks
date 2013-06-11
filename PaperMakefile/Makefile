
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


.PHONY: export clean

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

