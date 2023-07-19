TARGET    := main.pdf

IMAGE_DIR := images
TABLE_DIR := tables
CODE_DIR  := code
BUILD_DIR := build

IMAGES := $(shell find $(IMAGE_DIR) -name "*.tex")
TABLES := $(shell find $(TABLE_DIR) -name "*.tex")
CODES  := $(shell find $(CODE_DIR) -name "*.tex")
SOURCES   := deps/pkgs.tex deps/macros.tex main.tex $(CODES) $(TABLES) $(IMAGES)
RASTERIMG := $(wildcard images/*.png)
VECTORIMG := $(wildcard images/*.svg)


LATEX   = pdflatex -shell-escape -file-line-error -interaction=nonstopmode --output-directory=$(BUILD_DIR)
BIBTEX  = bibtex

.PHONY: all debug clean distclean .dirs

all: $(TARGET)

$(TARGET): .dirs $(SOURCES) $(RASTERIMG) $(patsubst %.svg,%.pdf,$(VECTORIMG))

.dirs:
	mkdir -p $(BUILD_DIR) $(IMAGE_DIR) $(TABLE_DIR) $(CODE_DIR)

%.pdf: %.tex %.bib
	($(LATEX) $<; \
	$(BIBTEX) $* > $(BUILD_DIR)/$(BIBTEX)_out.log; \
	$(LATEX) $<; \
	$(LATEX) $<;)
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $(BUILD_DIR)/$*.log) \
	do $(LATEX) $<; done
	$(RM) *.aux *.idx *.ind *.out *.toc *.log *.bbl *.blg *.brf
	mv $(BUILD_DIR)/$@ .

debug:
	-grep Warning *.log

clean:
	@ #$(RM) *.aux *.idx *.ind *.out *.toc *.log *.bbl *.blg *.brf
	$(RM) $(BUILD_DIR) -r

distclean: clean
	$(RM) *.pdf
