## markdown-easy Makefile
##
## See installation targets at the bottom.
##-----------------------------------------------------------------------------

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c


##-----------------------------------------------------------------------------
## helpers and settings
##-----------------------------------------------------------------------------

## parse meta.yaml
DOC_TITLE := $(shell grep '^title:' meta.yaml | head -n1 | sed -e 's/title:[[:space:]]*//' | tr -d "'" | tr -d '"')
TEMPLATE_HTML := $(shell grep '^template_html:' meta.yaml | head -n1 | sed -e 's/template_html:[[:space:]]*//' | tr -d "'" | tr -d '"')
TEMPLATE_TEX := $(shell grep '^template_tex:' meta.yaml | head -n1 | sed -e 's/template_tex:[[:space:]]*//' | tr -d "'" | tr -d '"')
BACKMATTER_MD := $(shell grep '^backmatter_md:' meta.yaml | head -n1 | sed -e 's/backmatter_md:[[:space:]]*//' | tr -d "'" | tr -d '"')
BACKMATTER_TEX := $(shell grep '^backmatter_tex:' meta.yaml | head -n1 | sed -e 's/backmatter_tex:[[:space:]]*//' | tr -d "'" | tr -d '"')
OUTPUT := $(shell grep '^output:' meta.yaml | head -n1 | sed -e 's/output:[[:space:]]*//' | tr -d "'" | tr -d '"')

## set fixed variables
DATE_NOW := $(shell date +"%B %-d, %Y")
MD_FILES := $(filter-out README.md LICENSE.md VERSIONS.md, $(sort $(wildcard *.md)))
HTML_FILES := $(MD_FILES:%.md=%.html)
BIB_OPTIONS := --bibliography=bibs/mybib.bib --citeproc
BIB_TXT_FILES := $(sort $(wildcard bibs/*.txt))

## helpers ran within targets
PAGE_TITLE = $(shell (grep '^\#' $< | head -n1 | sed -e 's/^\#[[:space:]]*//')||(grep -B1 '====' $< | head -n1))
PRINT = @echo '==>  '


##-----------------------------------------------------------------------------
## main targets
##-----------------------------------------------------------------------------

.PHONY: all default html pdf install install_for_ubuntu install_for_mac clean realclean

default: html
all: html pdf
html: $(HTML_FILES)
pdf: $(OUTPUT).pdf
install: install_for_ubuntu


##-----------------------------------------------------------------------------
## file targets
##-----------------------------------------------------------------------------

## create html
%.html: %.md bibs/mybib.bib meta.yaml
	@pandoc \
		-f markdown+smart \
		-t html \
		--ascii \
		--standalone \
		--variable=date_now:"$(DATE_NOW)" \
		--variable=page_title:"$(PAGE_TITLE)" \
		--variable=doc_title:"$(DOC_TITLE)" \
		--template=$(TEMPLATE_HTML) \
		--mathjax \
		--filter pandoc-crossref \
		$(BIB_OPTIONS) \
		-o $@ $< $(BACKMATTER_MD) meta.yaml > pandoc-html.log 2>&1
	$(PRINT) "make $@ done."

## create tex with references replaced and bibliography created
$(OUTPUT).tex: $(MDP_FILES) bibs/mybib.bib meta.yaml
	@pandoc \
		-f markdown+smart \
		-t latex \
		--ascii \
		--standalone \
		--variable=date_now:"$(DATE_NOW)" \
		--template=$(TEMPLATE_TEX) \
		--filter pandoc-crossref \
		$(BIB_OPTIONS) \
		-o $@ $(MD_FILES) $(BACKMATTER_TEX) meta.yaml > pandoc-tex.log 2>&1
	$(PRINT) "make $@ done."

## create the pdf from tex
%.pdf: %.tex
	@pdflatex -interaction=nonstopmode $< > latex.log 2>&1
	@pdflatex -interaction=nonstopmode $< > latex.log 2>&1
	@pdflatex -interaction=nonstopmode $< > latex.log 2>&1
	$(PRINT) "make $@ done."

## create bibs/mybib.bib from bibs/*.txt
bibs/mybib.bib: $(BIB_TXT_FILES)
	@if [ -z "$(BIB_TXT_FILES)" ] ; \
	then \
		echo "==>   ERROR: No bibliography files found in bibs/." ; \
		exit 1 ; \
	else \
		python scripts/markdown2bib.py --out=bibs/mybib.bib $(BIB_TXT_FILES) ; \
	fi
	$(PRINT) "make $@ done."


##-----------------------------------------------------------------------------
## clean targets
##-----------------------------------------------------------------------------
JUNK = *.aux *.log *.out *.tex *.toc
OUTS = *.html *.pdf bibs/*.bib

## clean up (do this)
clean:
	@rm -f $(JUNK)
	$(PRINT) "make $@ done."

## clean up everything including the output
realclean: clean
	@rm -f $(OUTS)
	$(PRINT) "make $@ done."

## make realclean and make default again
over: realclean default


##-----------------------------------------------------------------------------
## Be careful using these destructive targets

destroy: realclean
	rm -f *.md
	$(PRINT) "make $@ done."

destroygit: 
	rm -rf .git
	$(PRINT) "make $@ done."

newdoc: destroy destroygit
	@echo "Introduction" > 01-introduction.md 
	@echo "===============================================================================" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "First subsection" >> 01-introduction.md 
	@echo "-------------------------------------------------------------------------------" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "Start writing..." >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "Conclusion" >> 01-introduction.md 
	@echo "===============================================================================" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "Ain't it something?" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "Acknowledgements {.unnumbered}" >> 01-introduction.md 
	@echo "===============================================================================" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "Thanks to everyone who helped with this manuscript." >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	@echo "" >> 01-introduction.md 
	$(PRINT) "make $@ done."


##-----------------------------------------------------------------------------
## install
## See: https://askubuntu.com/questions/1335772/using-pandoc-crossref-on-ubuntu-20-04
##-----------------------------------------------------------------------------

install_for_ubuntu:
	@echo "Installing for ubuntu..." ; \
	sudo apt-get -y update ; \
	if [ ! -f /usr/bin/pdflatex ]; then \
		echo "Installing texlive..." ; \
		sudo apt-get -y install texlive-latex-extra ; \
	fi ; \
	echo "which pdflatex: `which pdflatex`" ; \
	if [ ! -f /usr/bin/pandoc ]; then \
		echo "Installing pandoc..." ; \
		wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-1-amd64.deb ; \
		sudo dpkg -i pandoc-2.13-1-amd64.deb ; \
	fi ; \
	echo "which pandoc: `which pandoc`" ; \
	pandoc --version ; \
	if [ ! -f /usr/local/bin/pandoc-crossref ]; then \
		echo "Installing pandoc-crossref..." ; \
		wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.10.0a/pandoc-crossref-Linux.tar.xz ; \
		tar -xf pandoc-crossref-Linux.tar.xz ; \
		sudo mv pandoc-crossref /usr/local/bin/ ; \
		sudo chmod a+x /usr/local/bin/pandoc-crossref ; \
		sudo mkdir -p /usr/local/man/man1 ; \
		sudo mv pandoc-crossref.1  /usr/local/man/man1 ; \
	fi ; \
	echo "which pandoc-crossref: `which pandoc-crossref`" ; \
	echo "Installing other dependencies..." ; \
	pip install --upgrade pip ; \
	pip install -r requirements.txt ;
	$(PRINT) "make $@ done."

install_for_mac:
	@echo "Installing for mac..." ; \
	echo "Installing xcode..." ; \
	xcode-select --install ; \
	sudo xcodebuild -license accept ; \
	echo "Installing brew..." ; \
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ; \
	brew doctor ; \
	brew update ; \
	brew cleanup ; \
	if [ ! -f /usr/local/bin/pdflatex ]; then \
		echo "Installing texlive..." ; \
		brew install texlive ; \
	fi ; \
	echo "which pdflatex: `which pdflatex`" ; \
	if [ ! -f /usr/local/bin/pandoc ]; then \
		wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-macOS.pkg ; \
		echo "Installing pandoc..." ; \
		sudo installer -pkg pandoc-2.13-macOS.pkg -target / ; \
	fi ; \
	echo "which pandoc: `which pandoc`" ; \
	pandoc --version ; \
	if [ ! -f /usr/local/bin/pandoc-crossref ]; then \
		echo "Installing pandoc-crossref..." ; \
		wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.10.0a/pandoc-crossref-macOS.tar.xz ; \
		tar -xf pandoc-crossref-macOS.tar.xz ; \
		sudo mv pandoc-crossref /usr/local/bin/ ; \
		sudo chmod a+x /usr/local/bin/pandoc-crossref ; \
	fi ; \
	echo "which pandoc-crossref: `which pandoc-crossref`" ; \
	echo "Installing other dependencies..." ; \
	pip install --upgrade pip ; \
	pip install -r requirements.txt ;
	$(PRINT) "make $@ done."

install_for_windows:
	@echo "Installing for windows..." ; \
	choco install wget ; \
	wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe ; \
	./install-tl-windows.exe -gui text ; \
	echo "which pdflatex: `which pdflatex`" ;
	$(PRINT) "make $@ done."

#	if [ ! -f /usr/local/bin/pandoc ]; then \
#		wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-windows-x86_64.zip ; \
#		echo "Installing pandoc..." ; \
#		sudo installer -pkg pandoc-2.13-macOS.pkg -target / ; \
#	fi ; \
#	echo "which pandoc: `which pandoc`" ; \
#	pandoc --version ; \
#	if [ ! -f /usr/local/bin/pandoc-crossref ]; then \
#		echo "Installing pandoc-crossref..." ; \
#		wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.10.0a/pandoc-crossref-Windows.7z ; \
#		tar -xf pandoc-crossref-macOS.tar.xz ; \
#		sudo mv pandoc-crossref /usr/local/bin/ ; \
#		sudo chmod a+x /usr/local/bin/pandoc-crossref ; \
#	fi ; \
#	echo "which pandoc-crossref: `which pandoc-crossref`" ; \
#	echo "Installing other dependencies..." ; \
#	pip install --upgrade pip ; \
#	pip install -r requirements.txt ;
#	$(PRINT) "make $@ done."

