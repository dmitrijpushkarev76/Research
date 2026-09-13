PAPER = one-state-many-futures

.PHONY: all figure clean distclean

all: $(PAPER).pdf

# The figure coordinates are generated, not hand-written.  Regenerate them
# whenever the generator changes; the analytic constants in the text do not
# depend on this step.
figure-branches.tex: make_figure_data.py
	python3 make_figure_data.py

figure: figure-branches.tex

# Two passes so \ref and the theorem counters resolve.
$(PAPER).pdf: $(PAPER).tex figure-branches.tex
	pdflatex -interaction=nonstopmode -halt-on-error $(PAPER).tex
	pdflatex -interaction=nonstopmode -halt-on-error $(PAPER).tex

clean:
	rm -f $(PAPER).aux $(PAPER).log $(PAPER).out $(PAPER).synctex.gz *.log

distclean: clean
	rm -f $(PAPER).pdf figure-branches.tex
