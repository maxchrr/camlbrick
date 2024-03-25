# Définition du répertoire LablTk en fonction du système d'exploitation
ifeq ($(shell uname -s),Darwin)
	LABLTK_DIR := ~/.opam/4.13.1/lib/labltk
else
	LABLTK_DIR := +labltk
endif

# Répertoire contenant les fichiers source OCaml
SRC_DIR := camlbrick
TEST_DIR := test

# Règle implicite pour compiler les fichiers .ml en .cmo
%.cmo: %.ml
	@ocamlc -c -I $(LABLTK_DIR) labltk.cma -I $(SRC_DIR) $<

# Cible de build
build: $(SRC_DIR)/camlbrick.cmo $(SRC_DIR)/camlbrick_gui.cmo $(SRC_DIR)/camlbrick_launcher.cmo
	mkdir -p bin
	ocamlc -o bin/camlbrick -I $(LABLTK_DIR) labltk.cma -I $(SRC_DIR) $^

# Cible de test
test: $(SRC_DIR)/camlbrick.cmo $(TEST_DIR)/CPtest.cmo $(TEST_DIR)/tests_iteration1.ml
	@mkdir -p bin
	@ocamlc -o bin/test_exe -I $(SRC_DIR) -I $(TEST_DIR) $^
	@./bin/test_exe
	@make clean

# Cible pour générer la documentation HTML
html:
	ocamldoc -html -d docs -charset utf8 $(SRC_DIR)/*.ml

# Cible pour compresser les fichiers source et la documentation
compress:
	tar -czvf camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz $(SRC_DIR)/*.ml docs test/*.ml

# Cible pour nettoyer les fichiers générés lors de la compilation
clean:
	@rm -rf bin */*.cm* camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz

.PHONY: build test html compress clean
