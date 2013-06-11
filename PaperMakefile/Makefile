
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


clean:
	rm -f ${BASENAME}.pdf ${BASENAME}.aux ${BASENAME}.bbl ${BASENAME}.blg ${BASENAME}.log ${BASENAME}.toc
