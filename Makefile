TARGET    := main.pdf
BUILD_DIR := build

IMAGES := $(shell find images -name "*.tex")
TABLES := $(shell find tables -name "*.tex")
CODE_SRCS := $(shell find code -name "*.tex")
SOURCES   := deps/pkgs.tex deps/macros.tex main.tex $(CODE_SRCS) $(TABLES) $(IMAGES)
RASTERIMG := $(wildcard images/*.png)
VECTORIMG := $(wildcard images/*.svg)


LATEX   = pdflatex -shell-escape -file-line-error -interaction=nonstopmode --output-directory=$(BUILD_DIR)
BIBTEX  = bibtex

.PHONY: all debug clean distclean

all: $(TARGET)

$(TARGET): $(SOURCES) $(RASTERIMG) $(patsubst %.svg,%.pdf,$(VECTORIMG))

%.pdf: %.tex %.bib
	mkdir -p $(BUILD_DIR)
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
