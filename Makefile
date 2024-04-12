CAMLC = ocamlc
CAMLDOC = ocamldoc

SRC = camlbrick.ml camlbrick_gui.ml camlbrick_launcher.ml
OBJ = $(SRC:.ml=.cmo)

# Définition du répertoire LablTk en fonction du système d'exploitation
ifeq ($(shell uname -s),Darwin)
	LABLTK_DIR = ~/.opam/4.13.1/lib/labltk
else
	LABLTK_DIR = +labltk
endif

.PHONY: all camlbrick test html compress clean cleanup

all: camlbrick

# Cible de build
camlbrick: $(OBJ)
	mkdir -p bin
	$(CAMLC) -o bin/$@ -I $(LABLTK_DIR) labltk.cma $^

# Règle implicite pour compiler les fichiers .ml en .cmo
%.cmo: %.ml
	$(CAMLC) -c -I $(LABLTK_DIR) labltk.cma $<

# Cible de test
test: camlbrick.cmo CPtest.cmo
	@echo "Iteration 1"
	ocaml tests_iteration1.ml
	@echo "\nIteration 2"
	ocaml tests_iteration2.ml
	@echo "\nIteration 3"
	ocaml tests_iteration3.ml
	@make clean

# Cible pour générer la documentation HTML
html: camlbrick.cmo camlbrick_gui.cmo $(SRC)
	$(CAMLDOC) -html -d docs -charset utf8 -I $(LABLTK_DIR) -g camlbrick.cmo $(SRC)

# Cible pour compresser les fichiers source et la documentation
compress:
	tar -czvf camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz *

# Cible pour nettoyer les fichiers générés lors de la compilation
clean:
	@rm -rf bin *.cm* camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz docs/*.{html,css}

# Cible pour nettoyer les fichiers générés lors de la compilation, hors binaires
cleanup:
	@rm -rf *.cm* camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz docs/*.{html,css}
