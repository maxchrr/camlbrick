compress:
	tar -czvf camlbrick_CHARRIER_OURLIAC_ABRANE_DE-LES-CHAMPS--VIEIRA.tar.gz camlbrick/*.ml docs tests/*.ml

clean:
	rm -r bin/*
	rm -r */*.cm*
