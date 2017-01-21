#!/bin/bash
pwd
cd ./src

echo -e "\n" >>../latex/sections/code.tex
for f in * 
do
testo="\lstinputlisting[language=C++]{../src/${f}}"

echo $testo >>../latex/sections/code.tex

done

exit 0;

