#!/bin/bash
pwd
cd ./img

for f in *[!.txt]
do
	testo="
	\begin{figure}
	 \centering 
	 \includegraphics[width=\textwidth]{${f}}
	 \caption{$(basename $f)} 
	 \label{fig:${f}}
	\end{figure}
	"
done

echo $testo > ../latex/img/${f}

exit 0;
