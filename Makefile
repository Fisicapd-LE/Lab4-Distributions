SHELL=/bin/bash -O extglob -c

# IL file in latex della relazione
FILE_REL_TEX = $(wildcard ./latex/*.tex)
FILE_SLIDE_TEX = $(wildcard ./latex/*.tex)
# Crea il nome del file .pdf da produrre dal nome del .tex
PDF_RELAZIONE = $(patsubst %.tex, %.pdf, $(FILE_REL_TEX) )
BASENAME_TEX = $(shell basename -a $(FILE_REL_TEX))
BASENAME_PDF = $(patsubst %.tex, %.pdf, $(BASENAME_TEX) )

GRAPHS_RAW = $(shell ./script/glob "./graphs/*.!(txt)")
GRAPHS_NOEXT = $(foreach graph, $(GRAPHS_RAW), $(subst ./, ./latex/, $(graph)))
GRAPHS_WITH_RULES = $(patsubst %.pdf, %.tex, $(patsubst %.png, %.tex, $(GRAPHS_NOEXT)))
GRAPHS = $(subst _nofloat,, $(GRAPHS_WITH_RULES))

HISTS_RAW = $(shell ./script/glob "./hist/*.!(txt)")
HISTS_NOEXT = $(foreach hist, $(HISTS_RAW), $(subst ./, ./latex/, $(hist)))
HISTS_WITH_RULES = $(patsubst %.pdf, %.tex, $(patsubst %.png, %.tex, $(HISTS_NOEXT)))
HISTS = $(subst _nofloat,, $(HISTS_WITH_RULES))

IMGS_RAW = $(shell ./script/glob "./img/*.!(txt)")
IMGS_NOEXT = $(foreach img, $(IMGS_RAW), $(subst ./, ./latex/, $(img)))
IMGS_WITH_RULES = $(patsubst %.pdf, %.tex, $(patsubst %.png, %.tex, $(IMGS_NOEXT)))
IMGS = $(subst _nofloat,, $(subst _nolarge,,$(foreach img, $(IMGS_WITH_RULES), $(subst $(shell echo $(img) | grep -o -P "_sub[0-9]"),,$(img)))))

rel: $(PDF_RELAZIONE)
	@echo "Building thesis..."
	cp $(PDF_RELAZIONE) ./
	cp $(PDF_RELAZIONE) ./other/

# Da aggiungere le tabelle
$(PDF_RELAZIONE): graphs img hist chapters appendix
	@echo "Building pdf..."
#Ogni riga viene eseguita in una subshell diversa, quindi se faccio cd devo mettere sulla stessa linea gli altri comandi che necessitano dell'effetto di cd
	cd ./latex;	pwd; latexmk -pdf $(BASENAME_TEX)
	
./latex/sections/chapters.tex: ./latex/sections/chapters
	@echo "Adding chapters"
	./script/add_sections/add_chapters.sh

./latex/sections/appendix.tex: ./latex/sections/appendix
	@echo "Adding appendix"
	./script/add_sections/add_appendix.sh

.PHONY: clean graphs img hist chapters appendix

clean:
# @echo fa in modo che make non "echi" anche echo "Faccio il clean..."
	@echo "Cleaning..."
	-cd ./latex; pwd; latexmk -C -pdf $(BASENAME_TEX)
	-rm ./latex/graphs/*.tex
	-rm ./latex/hist/*.tex
	-rm ./latex/img/*.tex
	-rm ./latex/sections/chapters.tex
	-rm ./latex/sections/appendix.tex
	-rm $(BASENAME_PDF)
	
graphs: graphlog $(GRAPHS)

graphlog:
	@echo "Formatting graphs..."
	@echo $(GRAPHS_RAW)
	@echo $(GRAPHS)

hist: histlog $(HISTS)

histlog:
	@echo "Formatting histograms..."
	
img: imglog $(IMGS)

imglog:
	@echo "Formatting images..."
	
chapters: ./latex/sections/chapters.tex

appendix: ./latex/sections/appendix.tex
	
.SECONDEXPANSION:
	
$(GRAPHS): ./latex/graphs/%.tex: $$(shell ./script/glob "./graphs/%*(_nofloat).tex") $$(shell ./script/glob "./graphs/%*(_nofloat).pdf")  $$(shell ./script/glob "./graphs/%*(_nofloat).png") $$(wildcard ./graphs/%.txt) ./script/to_latex/graph_to_latex.sh
	./script/to_latex/graph_to_latex.sh $* $(filter %.tex %.pdf %.png, $<)
	
$(HISTS): ./latex/hist/%.tex: $$(shell ./script/glob "./hist/%*(_nofloat).tex") $$(shell ./script/glob "./hist/%*(_nofloat).pdf") $$(shell ./script/glob "./hist/%*(_nofloat).png") $$(wildcard ./hist/%.txt) ./script/to_latex/hist_to_latex.sh
	./script/to_latex/hist_to_latex.sh $* $(filter %.tex %.pdf %.png, $<)

$(IMGS): ./latex/img/%.tex: $$(shell ./script/glob "./img/%*(_nofloat).tex") $$(shell ./script/glob "./img/%*(_nofloat|_nolarge|_sub[0-9]).pdf") $$(shell ./script/glob "./img/%*(_nofloat).png") $$(shell ./script/glob "./img/%*(_nofloat|_nolarge|_sub[0-9]).jpg") $$(wildcard ./img/%.txt) ./script/to_latex/img_to_latex.sh
	./script/to_latex/img_to_latex.sh $* $(filter %.tex %.pdf %.png %.jpg, $<) 
