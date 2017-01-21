#!/bin/bash

pwd
cd ./latex/sections/chapters

text="%%chapters"

for f in *[!.backup]
do
	text="$text\n\n\input{sections/chapters/$f}\n\\\\FloatBarrier\n"
done

printf $text > ../chapters.tex


