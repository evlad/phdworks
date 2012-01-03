all: thesis autoref

.PHONY: pictures thesis autoref clean clean-phd clean-autoref

pictures:
	@echo "Convert all eps files to pdf"
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

thesis: pictures eliseev_phd.pdf
#thesis: pictures eliseev_phd.ps
#thesis: pictures eliseev_phd.dvi
#thesis: pictures eliseev_phd.rtf

eliseev_phd.pdf: eliseev_phd.tex
	@echo "Make PDF version of thesis"
	pdflatex eliseev_phd.tex
	bibtex8 -H -c cp1251 eliseev_phd.aux
	pdflatex eliseev_phd.tex

eliseev_phd.ps: eliseev_phd.dvi
	@echo "Make PS version of thesis"
	dvips eliseev_phd.dvi

eliseev_phd.dvi: eliseev_phd.tex
	@echo "Make DVI version of thesis"
	latex eliseev_phd.tex
	bibtex8 -H -c cp1251 eliseev_phd.aux
	latex eliseev_phd.tex

eliseev_phd.rtf: eliseev_phd.tex
	@echo "Make RTF version of thesis"
	latex2rtf -i russian -M 12 -S eliseev_phd.tex

clean: clean-phd clean-autoref

clean-phd:
	@rm -f eliseev_phd.aux eliseev_phd.out eliseev_phd.log eliseev_phd.pdf  eliseev_phd.toc eliseev_phd.ps eliseev_phd.dvi eliseev_phd.bbl

clean-autoref:
	@rm -f eliseev_autoref.aux eliseev_autoref.out eliseev_autoref.log eliseev_autoref.pdf  eliseev_autoref.toc eliseev_autoref.ps eliseev_autoref.dvi
