#!/bin/bash
for f in gnuplot/*.gnuplotscript
do
	echo "Plotto $f"
	cat $f | gnuplot -p
done
exit 0
