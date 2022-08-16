#!/bin/bash
Rscript -e 'library(knitr)' -e 'knit("WOCAL2021_submission.Rmd", output="WOCAL2021_submission.md")'
pandoc WOCAL2021_submission.md --standalone --biblatex --bibliography localbibliography.bib --number-sections --pdf-engine=xelatex -V biblio-style:authoryear -V 'mainfont:Times New Roman' -V geometry:margin=2.5cm -V fontsize=11pt -V papersize=b5 -V secnumdepth=3 -H wocal_header.tex -o WOCAL2021_submission.tex
xelatex WOCAL2021_submission
biber WOCAL2021_submission
xelatex WOCAL2021_submission
xelatex WOCAL2021_submission
mv WOCAL2021_submission.pdf ../doc/
