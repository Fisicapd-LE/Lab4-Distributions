#!/bin/bash

pwd
cd ./latex/sections/appendix

text="%%appendix"

for f in *
do
	text="$text\n\n\input{sections/appendix/$f}\n\\\\FloatBarrier\n\\\\newpage"
done

printf $text > ../appendix.tex

