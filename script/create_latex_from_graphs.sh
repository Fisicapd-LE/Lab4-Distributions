#!/bin/bash

pwd
cd ./graphs

for f in *.tex
do
	testo="
	\begin{grafico}\n
	 \centering\n
	  \resizebox{\textwidth}{!}{\n
	   \input{../graphs/${f}}\n
	  }\n
	  \caption{Grafico ${f}}\n
	  \label{gr:${f}}\n
	\end{grafico}\n
	"
done

printf $testo > ../latex/graphs/${f}

exit 0;
