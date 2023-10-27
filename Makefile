## markdown-easy Makefile
##
## See installation targets at the bottom.
##-----------------------------------------------------------------------------

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

#export TEXINPUTS := .//:./templates//:./tex//:${TEXINPUTS}


##-----------------------------------------------------------------------------
## helpers and settings
##-----------------------------------------------------------------------------

DATE_NOW := $(shell date +"%B %-d, %Y")
DOC_TITLE := $(shell grep '^title:' meta.yaml | head -n1 | sed -e 's/title:\s*//' | tr -d "'" | tr -d '"')
OUTPUT := $(shell grep '^output:' meta.yaml | head -n1 | awk '{ print $$2}')
MD_FILES := $(filter-out README.md LICENSE.md VERSIONS.md, $(sort $(wildcard *.md)))
HTML_FILES := $(MD_FILES:%.md=%.html)
TEMPLATE1 := $(shell grep '^template:' meta.yaml | head -n1 | sed -e 's/template:\s*//' | tr -d "'" | tr -d '"')
TEMPLATE := templates/book.tex
BACKMATTER_HTML := templates/refs_subsection.md
#BACKMATTER_TEX := templates/refs_section.tex
BACKMATTER_TEX := templates/refs_chapter.tex
BIB_OPTIONS := --bibliography=bibs/mybib.bib --citeproc
BIB_TXT_FILES := $(sort $(wildcard bibs/*.txt))

PAGE_TITLE = $(shell (grep -e '^\#' $< | head -n1 | sed -e 's/^\#\s*//')||(grep -B1 '====' $< | head -n1))
PRINT = @echo '==>  '


##-----------------------------------------------------------------------------
## main targets
##-----------------------------------------------------------------------------

.PHONY: all default html pdf install install_for_linux install_for_mac clean realclean

default: html
all: html pdf
html: $(HTML_FILES)
pdf: $(OUTPUT).pdf


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
		--template=./templates/book_chapter.html \
		--mathjax \
		--filter pandoc-crossref \
		$(BIB_OPTIONS) \
		-o $@ $< $(BACKMATTER_HTML) meta.yaml > pandoc-html.log 2>&1
	$(PRINT) "make $@ done."

## create tex with references replaced and bibliography created
$(OUTPUT).tex: $(MDP_FILES) bibs/mybib.bib meta.yaml
	@pandoc \
		-f markdown+smart \
		-t latex \
		--ascii \
		--standalone \
		--variable=date_now:"$(DATE_NOW)" \
		--template=$(TEMPLATE1) \
		--filter pandoc-crossref \
		$(BIB_OPTIONS) \
		-o $@ $(MD_FILES) $(BACKMATTER_TEX) meta.yaml > pandoc-tex.log 2>&1
	$(PRINT) "template1  $(TEMPLATE1)"
	$(PRINT) "template  $(TEMPLATE)"
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
		echo "==>   ERROR: No bibliography files found in bibs/. Set dorefs=false in meta.yaml." ; \
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
## install
## See: https://askubuntu.com/questions/1335772/using-pandoc-crossref-on-ubuntu-20-04
##-----------------------------------------------------------------------------

install: install_for_linux
	$(PRINT) "make $@ done."

install_for_linux:
	@echo "Installing for linux..." ; \
    sudo apt-get -y update ; \
	if [ ! -f /usr/bin/pdflatex ]; then \
		echo "Installing texlive-latex-extra..." ; \
    	sudo apt-get -y install texlive-latex-extra ; \
	fi ; \
	echo `which pdflatex` ; \
	if [ ! -f /usr/bin/pandoc ]; then \
		echo "Installing pandoc..." ; \
		wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-1-amd64.deb ; \
		sudo dpkg -i pandoc-2.13-1-amd64.deb ; \
	fi ; \
	echo `which pandoc` ; \
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
	echo `which pandoc-crossref` ; \
	echo "Installing other dependencies..." ; \
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
	echo "Installing texlive..." ; \
	brew install texlive ; \
	echo `which pdflatex` ; \
	echo "Installing sublime..." ; \
	brew cask install sublime-text ; \
	echo "Installing pandoc..." ; \
	wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-macOS.pkg ; \
	sudo installer -pkg pandoc-2.13-macOS.pkg -target / ; \
	pandoc --version ; \
	if [ ! -f /usr/local/bin/pandoc-crossref ]; then \
		echo "Installing pandoc-crossref..." ; \
		wget -c https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.10.0a/pandoc-crossref-macOS.tar.xz ; \
    	tar -xf pandoc-crossref-macOS.tar.xz ; \
    	sudo mv pandoc-crossref /usr/local/bin/ ; \
    	sudo chmod a+x /usr/local/bin/pandoc-crossref ; \
	fi ; \
	echo `which pandoc-crossref` ; \
	echo "Installing other dependencies..." ; \
	pip install -r requirements.txt ;
	$(PRINT) "make $@ done."

