#!/bin/bash

filename=$1

if [ ${2//nofloat} == $2 ]
then
	float="h"
else
	float="H"
fi

if [ ${2//_sub} == $2 ]
then
testo="\begin{figure}[$float]\centering"
sub=1
else
sub=$(echo $2 | grep -o -P "sub\K[0-9]")
testo="\begin{subfigure}[h]{\textwidth/\numexpr$sub\relax}\centering"
fi

if [ ${2//nolarge} == $2 ]
then
	#if [ $2 =~ tex ] 
	#then
	# testo=$testo"\resizebox{\textwidth}{!}{\input{../../$2}}"
	#else
	 testo=$testo"\includegraphics[width=0.9\textwidth]{../../$2}"
	#fi
else
	 testo=$testo"\includegraphics{../../$2}"
fi

if [ -f ./img/$filename.txt ]
then
	testo=$testo"\caption{$(cat ./img/$filename.txt)}"
else
	testo=$testo"\caption{${filename//_/ }}"
fi

if [ ${2//_sub} == $2 ]
then
testo=$testo"\label{fig:$filename}\end{figure}"
else
testo=$testo"\label{fig:$filename}\end{subfigure}%"
fi

echo $testo > ./latex/img/$filename.tex

exit 0;
