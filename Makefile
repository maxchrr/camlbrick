# Définition du répertoire LablTk en fonction du système d'exploitation
ifeq ($(shell uname -s),Darwin)
	LABLTK_DIR = ~/.opam/4.13.1/lib/labltk
else
	LABLTK_DIR = +labltk
endif

SRC = camlbrick.ml camlbrick_gui.ml camlbrick_launcher.ml

OBJ = $(SRC:.ml=.cmo)

# Règle implicite pour compiler les fichiers .ml en .cmo
%.cmo: %.ml
	ocamlc -c -I $(LABLTK_DIR) labltk.cma $<

# Cible de build
build: $(OBJ)
	mkdir -p bin
	ocamlc -o bin/camlbrick -I $(LABLTK_DIR) labltk.cma $^

# Cible de test
test: camlbrick.cmo CPtest.cmo
	utop tests_iteration1.ml
	@make clean

# Cible pour générer la documentation HTML
html:
	ocamldoc -html -d docs -charset utf8 $(SRC)

# Cible pour compresser les fichiers source et la documentation
compress:
	tar -czvf camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz *

# Cible pour nettoyer les fichiers générés lors de la compilation
clean:
	@rm -rf bin *.cm* camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz

.PHONY: build test html compress clean
