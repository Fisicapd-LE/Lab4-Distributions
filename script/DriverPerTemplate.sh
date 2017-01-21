#!/bin/bash
# Script che da n file .fdat e m file di template, produce n*m file generati
# Però modificato per il volano, qua. Ha più senso modificarlo ogni volta alla fine

# If it is set, then an unmatched glob is swept away entirely -- 
# replaced with a set of zero words -- 
# instead of remaining in place as a single word.
# shopt -s nullglob


# da http://stackoverflow.com/questions/2937407/test-whether-a-glob-has-any-matches-in-bash
if test -n "$(shopt -s nullglob; echo ../gnuplot/*.templatescript)"
then
    echo "Trovati file di template"
else
    echo "[WARNING]: File di template non trovati"
    exit 0; # 0 Perchè non lo considero un errore, solo un warning
fi

# Fallo per l'andata
for filedati in ../dati_formattati/v{0..9}.fdat
do
	for template in ../gnuplot/*_acc.templatescript
	do
		echo "filedati: $filedati"
		echo "template: $template"
		echo '' | ./IstanziaFileDiTemplate.pl $filedati $template | gnuplot -p
	done
done

# Fallo per il ritorno
for filedati in ../dati_formattati/v{0..9}r.fdat
do
	for template in ../gnuplot/*_dec.templatescript
	do
		echo "filedati: $filedati"
		echo "template: $template"
		echo '' | ./IstanziaFileDiTemplate.pl $filedati $template | gnuplot -p
	done
done
exit 0
