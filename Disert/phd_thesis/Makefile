all: thesis autoref

# Date as YYYY-MM-DD
THISDATE=$(shell date '+%F')

.PHONY: pictures thesis autoref clean clean-phd clean-autoref

pictures:
	@echo ">>> Convert all eps files to pdf"
	@for f in `ls *.eps| sed 's/\.eps$$//g'` ; do \
	  if [ "$$f.eps" -nt "$$f-eps-converted-to.pdf" ] ; then \
	    echo "$$f.eps -> $$f-eps-converted-to.pdf" ; \
	    epstopdf --outfile="$$f-eps-converted-to.pdf" "$$f.eps" ; \
	  fi; \
	done

autoref: pictures eliseev_autoref.pdf

eliseev_autoref.pdf: eliseev_autoref.tex
	@echo "Make PDF version of autoreferat"
	pdflatex eliseev_autoref.tex

thesis: pictures eliseev_phd-$(THISDATE).pdf eliseev_phd_gost-$(THISDATE).pdf
#thesis: pictures eliseev_phd.ps
#thesis: pictures eliseev_phd.dvi
#thesis: pictures eliseev_phd.rtf

eliseev_phd.aux: eliseev_phd.tex
	@echo ">>> Make PDF version of thesis (1st run)"
	pdflatex eliseev_phd.tex </dev/null >eliseev_phd.1st.log

eliseev_phd.pdf: eliseev_phd.tex eliseev_phd.bbl
	@echo ">>> Make PDF version of thesis (2nd run)"
	pdflatex eliseev_phd.tex </dev/null >eliseev_phd.2nd.log
	@echo ">>> Make PDF version of thesis (3rd run - put bibliography to TOC)"
	pdflatex eliseev_phd.tex </dev/null >eliseev_phd.3rd.log

eliseev_phd-$(THISDATE).pdf: eliseev_phd.pdf
	cp eliseev_phd.pdf eliseev_phd-$(THISDATE).pdf

eliseev_phd_gost.pdf: eliseev_phd.pdf
	@echo ">>> Make PDF version of thesis (4th run - single side gost version)"
	mv eliseev_phd.pdf eliseev_phd.pdf.BAK
	mv eliseev_phd.tex eliseev_phd.tex.BAK
	sed 's/left=[0-9.]*cm/left=2.5cm/g; s/right=[0-9.]*cm/right=1cm/g' eliseev_phd.tex.BAK >eliseev_phd.tex
	pdflatex eliseev_phd.tex </dev/null >eliseev_phd.4th.log
	mv eliseev_phd.pdf eliseev_phd_gost.pdf
	mv eliseev_phd.pdf.BAK eliseev_phd.pdf
	mv eliseev_phd.tex.BAK eliseev_phd.tex

eliseev_phd_gost-$(THISDATE).pdf: eliseev_phd_gost.pdf
	cp eliseev_phd_gost.pdf eliseev_phd_gost-$(THISDATE).pdf

eliseev_phd.bbl: eliseev_phd.aux
	@echo ">>> Make bibliography"
	-bibtex8 -H -c cp1251 eliseev_phd.aux

eliseev_phd.ps: eliseev_phd.dvi
	@echo ">>> Make PS version of thesis"
	dvips eliseev_phd.dvi

eliseev_phd.dvi: eliseev_phd.tex
	@echo ">>> Make DVI version of thesis"
	latex eliseev_phd.tex
	-bibtex8 -H -c cp1251 eliseev_phd.aux
	latex eliseev_phd.tex

eliseev_phd.rtf: eliseev_phd.tex
	@echo ">>> Make RTF version of thesis"
	latex2rtf -i russian -M 12 -S eliseev_phd.tex

clean: clean-phd clean-autoref

clean-phd:
	@rm -f eliseev_phd.aux eliseev_phd.out eliseev_phd.log eliseev_phd.pdf  eliseev_phd.toc eliseev_phd.ps eliseev_phd.dvi eliseev_phd.bbl

clean-autoref:
	@rm -f eliseev_autoref.aux eliseev_autoref.out eliseev_autoref.log eliseev_autoref.pdf  eliseev_autoref.toc eliseev_autoref.ps eliseev_autoref.dvi
