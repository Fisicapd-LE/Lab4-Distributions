#!/bin/bash

filename=$1

if [ ${2//_nofloat} == $2 ]
then
	float="h"
else
	float="H"
fi

testo="
	 \begin{figure}[$float]
	  \centering"
	  
#if [ $2 =~ "tex" ] 
#then
#	testo=$testo"\resizebox{\textwidth}{!}{\input{../../$2}}"
#else
	testo=$testo"\includegraphics[width=0.9\textwidth]{../../$2}"
#fi
if [ -f ./graphs/$filename.txt ]
then
	testo=$testo"\caption{$(cat ./graphs/$filename.txt)}"
else
	testo=$testo"\caption{${filename//_/ }}"
fi
testo=$testo"\label{gr:$filename}
	 \end{figure}
	"
	
echo $testo > ./latex/graphs/$filename.tex

exit 0;
