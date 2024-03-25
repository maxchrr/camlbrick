%.cmo: %.ml
	ocamlc -c -I "+labltk" labltk.cma -I camlbrick %.ml

build-linux: camlbrick.cmo
	ocamlc -c camlbrick/camlbrick.ml
	ocamlc -c -I "+labltk" labltk.cma -I camlbrick camlbrick.cmo camlbrick/camlbrick_gui.ml
	ocamlc -c -I camlbrick camlbrick.cmo camlbrick_gui.cmo camlbrick/camlbrick_launcher.ml
	ocamlc -o bin/camlbrick -I "+labltk" labltk.cma -I camlbrick camlbrick.cmo camlbrick_gui.cmo camlbrick_launcher.cmo

build-mac:
	ocamlc -c camlbrick/camlbrick.ml
	ocamlc -c -I ~/.opam/4.13.1/lib/labltk labltk.cma -I camlbrick camlbrick.cmo camlbrick/camlbrick_gui.ml
	ocamlc -c -I camlbrick camlbrick.cmo camlbrick_gui.cmo camlbrick/camlbrick_launcher.ml
	ocamlc -o bin/camlbrick -I ~/.opam/4.13.1/lib/labltk labltk.cma -I camlbrick camlbrick.cmo camlbrick_gui.cmo camlbrick_launcher.cmo

html:
	ocamldoc -html -d docs -charset utf8 camlbrick/*.ml

compress:
	tar -czvf camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz camlbrick/*.ml docs tests/*.ml

clean:
	rm -r bin/*
	rm -r */*.cm*
