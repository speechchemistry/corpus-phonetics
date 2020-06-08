---
title: "Analysing the difference between long and short vowels: statistical tests"
author: "Timothy Kempton"
date: 2020-06-08
output: 
  html_document:
    keep_md: true
---
This is the code that is used for the statistical analysis in Section 3.3. in the paper [Corpus Phonetics for Under Documented Languages](http://journals.linguisticsociety.org/proceedings/index.php/amphonology/article/view/4682/4312). This particular notebook is for investigating tokens of /i/ not in the harmony domain for Speaker AF. No statistically significant difference in F1 between short
/i/ vowels and long /i/ vowels was found. A test on F2 is just added for completeness. For the other seven conditions the filenames below should be changed. 

```r
# Point working directory to a folder where there the vowel data has been saved for the particular speaker
knitr::opts_knit$set(root.dir = "/home/tim/Downloads/speakerAF_mark1_2_3_4_14_16")
```


```r
library(ggplot2)
library(plotly)
library(dplyr)
library(readr)
```

Load in list of loan words


```r
loan_words_tbl <- read_tsv("loan_words_to_exclude.txt")
loan_words <- pull(loan_words_tbl,loan_word)
loan_words
```

```
##  [1] "yeesu"      "zeruzalem"  "simoŋ"      "iskariyoti" "ziwifiŋa"  
##  [6] "dəmasiŋa"   "farisiyeŋ"  "matiye"     "nazareti"   "sidoŋaŋ"   
## [11] "zudasi"     "puranul"    "piyer"      "zaŋ"        "zaki"      
## [16] "galile"     "galileŋ"    "yeesuŋ"     "sataŋ"      "mari"      
## [21] "levi"       "alfeŋ"      "zurdeŋa"    "zebedeŋ"    "kapernam"  
## [26] "magdalaŋ"   "nazaretiŋ"
```

Remove these loan words as well as suspicious data points (where the formant tracker failed or where we have suspected elision). This particular example notebook investigates tokens of /i/ not in the harmony domain. For other vowel data, change the filename below.


```r
highvowel <- read_tsv("i_all_durations_normal.tsv") # CHANGE THIS FOR OTHER VOWEL DATA e.g. i_all_durations_harmony.tsv
# remove all formant values that are zero (where formant tracker got confused), low energy and loan words
highvowel_trimmed <- highvowel %>% filter(F1 != 0) %>% filter(F2 != 0) %>% filter(RMS > 60) %>% filter(!(word_label %in% loan_words))
highvowel_long <- highvowel_trimmed %>% 
   filter((end-start) > 71) # the reason this numbers are not round numbers is because earlier floating point 
highvowel_short <- highvowel_trimmed %>% # arithmetic was not rounded
   filter((end-start) > 39 & (end-start) < 51  )
```

Plot the trimmed down set of tokens as an interactive formant plot. This is a visual way of checking the difference between the short and long vowels which is formalised as a statistical test below.


```r
highvowel_all <- bind_rows("long" = highvowel_long, "short" = highvowel_short, .id = "duration")
##Plot on a formant chart
p<- highvowel_all %>%
   ggplot(aes(x=F2,y=F1,color=duration,text = paste("Word:",word_label,"\nPosition in word",round(position_in_word,2)*100,"%\nFile:", bundle, "\nTime(s):",round((start+times_rel)/1000,2),"\nEnergy:",round(RMS,2))))+
   geom_text(aes(label = labels))+
   xlim(3000, 0)+ylim(1000,0)+xlab("F2(Hz)")+ylab("F1(Hz)")
ggplotly(p, tooltip = "text") # if you just run ggplotly(p) it will include the redundant hover text
```

<!--html_preserve--><div id="htmlwidget-4ca333d5d24b52a74264" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-4ca333d5d24b52a74264">{"x":{"data":[{"x":[-1815.5,-1971.5,-1792.5,-1866.5,-2070.5,-1830.5,-2003,-1959,-1938.5,-1972,-2061,-1884,-2011.5,-1927.5,-1960,-2023,-2115,-2023,-1983.5,-1918.5,-2070,-1945,-1893,-1968,-1939.5,-2052,-2043.5,-1998,-1947,-1991.5,-1879.5,-2138.5,-1874,-1958.5,-1971,-2052,-1936.5,-2130,-2082.5,-1592,-2084.5,-1916],"y":[-283.5,-249.5,-258.5,-263,-310,-257.5,-289.5,-262,-275.5,-308,-305.5,-301.5,-318.5,-276,-278,-278,-322,-313,-386.5,-239,-254,-296,-285.5,-264.5,-280,-277.5,-318,-316,-316,-273.5,-271.5,-370,-300.5,-319,-297.5,-298,-326.5,-288,-271,-364.5,-242,-260],"text":["i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i"],"hovertext":["Word: cekiŋ <br />Position in word 69 %<br />File: mark02vox_ker <br />Time(s): 237.03 <br />Energy: 73.47","Word: meɗeɗɗeɗi <br />Position in word 85 %<br />File: mark02vox_ker <br />Time(s): 246.26 <br />Energy: 73.05","Word: tokiŋ <br />Position in word 68 %<br />File: mark03vox_ker <br />Time(s): 277.52 <br />Energy: 72.42","Word: tokiŋ <br />Position in word 62 %<br />File: mark03vox_ker <br />Time(s): 284.93 <br />Energy: 73.85","Word: ji <br />Position in word 67 %<br />File: mark03vox_ker <br />Time(s): 286.77 <br />Energy: 69.36","Word: tokiŋ <br />Position in word 64 %<br />File: mark03vox_ker <br />Time(s): 292.25 <br />Energy: 73","Word: səɓakiŋ <br />Position in word 86 %<br />File: mark03vox_ker <br />Time(s): 304.83 <br />Energy: 72.31","Word: rakiŋ <br />Position in word 67 %<br />File: mark04vox_ker <br />Time(s): 53.69 <br />Energy: 71.94","Word: faɗi <br />Position in word 79 %<br />File: mark04vox_ker <br />Time(s): 55.95 <br />Energy: 65.3","Word: keskeleki <br />Position in word 85 %<br />File: mark04vox_ker <br />Time(s): 58.38 <br />Energy: 70.05","Word: degeɓgeɓi <br />Position in word 88 %<br />File: mark04vox_ker <br />Time(s): 77.88 <br />Energy: 65.71","Word: faɗi <br />Position in word 82 %<br />File: mark04vox_ker <br />Time(s): 92.18 <br />Energy: 63.15","Word: di <br />Position in word 66 %<br />File: mark04vox_ker <br />Time(s): 173.07 <br />Energy: 71.13","Word: faɗi <br />Position in word 81 %<br />File: mark04vox_ker <br />Time(s): 174.13 <br />Energy: 66.46","Word: ji <br />Position in word 81 %<br />File: mark04vox_ker <br />Time(s): 194.77 <br />Energy: 73.73","Word: ji <br />Position in word 79 %<br />File: mark04vox_ker <br />Time(s): 198.47 <br />Energy: 75.86","Word: si <br />Position in word 80 %<br />File: mark04vox_ker <br />Time(s): 209.29 <br />Energy: 70.42","Word: faɗi <br />Position in word 81 %<br />File: mark04vox_ker <br />Time(s): 217.75 <br />Energy: 69.62","Word: ana'iŋ <br />Position in word 59 %<br />File: mark04vox_ker <br />Time(s): 227.1 <br />Energy: 75.3","Word: bi <br />Position in word 76 %<br />File: mark04vox_ker <br />Time(s): 234.14 <br />Energy: 71.71","Word: bi <br />Position in word 75 %<br />File: mark04vox_ker <br />Time(s): 239.73 <br />Energy: 71.23","Word: faɗi <br />Position in word 77 %<br />File: mark04vox_ker <br />Time(s): 312.63 <br />Energy: 69.38","Word: di <br />Position in word 67 %<br />File: mark04vox_ker <br />Time(s): 313.65 <br />Energy: 70.21","Word: faɗi <br />Position in word 78 %<br />File: mark04vox_ker <br />Time(s): 324.14 <br />Energy: 68.86","Word: diŋ <br />Position in word 44 %<br />File: mark04vox_ker <br />Time(s): 326.17 <br />Energy: 71.11","Word: bi <br />Position in word 70 %<br />File: mark04vox_ker <br />Time(s): 360.65 <br />Energy: 68.96","Word: ɗeketi <br />Position in word 81 %<br />File: mark04vox_ker <br />Time(s): 437.63 <br />Energy: 81.93","Word: faɗi <br />Position in word 80 %<br />File: mark14vox_ker <br />Time(s): 90.04 <br />Energy: 70.3","Word: saksaki <br />Position in word 89 %<br />File: mark14vox_ker <br />Time(s): 94.33 <br />Energy: 65.96","Word: diŋ <br />Position in word 45 %<br />File: mark14vox_ker <br />Time(s): 97.52 <br />Energy: 73.75","Word: bi <br />Position in word 62 %<br />File: mark14vox_ker <br />Time(s): 109.04 <br />Energy: 70.94","Word: mi <br />Position in word 66 %<br />File: mark14vox_ker <br />Time(s): 110.42 <br />Energy: 68.28","Word: saksaki <br />Position in word 91 %<br />File: mark14vox_ker <br />Time(s): 126.35 <br />Energy: 68.38","Word: vil <br />Position in word 57 %<br />File: mark14vox_ker <br />Time(s): 182.69 <br />Energy: 74.38","Word: faɗi <br />Position in word 83 %<br />File: mark14vox_ker <br />Time(s): 188.18 <br />Energy: 71.75","Word: pakiŋ <br />Position in word 76 %<br />File: mark14vox_ker <br />Time(s): 196.95 <br />Energy: 72.75","Word: faɗi <br />Position in word 79 %<br />File: mark14vox_ker <br />Time(s): 350.53 <br />Energy: 77.43","Word: ɓasiŋ <br />Position in word 74 %<br />File: mark14vox_ker <br />Time(s): 353.58 <br />Energy: 73.3","Word: kin <br />Position in word 47 %<br />File: mark14vox_ker <br />Time(s): 457.85 <br />Energy: 78.97","Word: ji <br />Position in word 70 %<br />File: mark14vox_ker <br />Time(s): 460.53 <br />Energy: 80","Word: ceki <br />Position in word 78 %<br />File: mark14vox_ker <br />Time(s): 461.44 <br />Energy: 69.46","Word: ɓasiŋ <br />Position in word 70 %<br />File: mark14vox_ker <br />Time(s): 832.67 <br />Energy: 73.23"],"textfont":{"size":14.6645669291339,"color":"rgba(248,118,109,1)"},"type":"scatter","mode":"text","hoveron":"points","name":"long","legendgroup":"long","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[-1990.5,-2009.5,-1983.5,-1973,-1665.5,-1808.5,-1874,-1949,-1925.5,-1762,-1869,-2030,-2064.5,-2036,-1856.5,-1989.5,-1933,-853,-2461.5,-2018.5,-2024,-1851.5,-1980.5,-1931.5,-2080],"y":[-252.5,-274.5,-200.5,-268.5,-428,-275,-282.5,-271.5,-292.5,-271,-284,-325,-270.5,-271,-257.5,-317.5,-274,-372,-339,-234,-242.5,-255,-266.5,-232,-299.5],"text":["i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i","i"],"hovertext":["Word: ji <br />Position in word 87 %<br />File: mark02vox_ker <br />Time(s): 81.3 <br />Energy: 71.11","Word: ɓasiŋa <br />Position in word 72 %<br />File: mark02vox_ker <br />Time(s): 83.57 <br />Energy: 69.68","Word: abiyatar <br />Position in word 38 %<br />File: mark02vox_ker <br />Time(s): 309.08 <br />Energy: 64.99","Word: ji <br />Position in word 86 %<br />File: mark03vox_ker <br />Time(s): 382.95 <br />Energy: 73.31","Word: faɗi <br />Position in word 92 %<br />File: mark03vox_ker <br />Time(s): 388.2 <br />Energy: 74.83","Word: ciməcimiŋa <br />Position in word 21 %<br />File: mark04vox_ker <br />Time(s): 72.64 <br />Energy: 73.68","Word: ciməcimiŋa <br />Position in word 54 %<br />File: mark04vox_ker <br />Time(s): 72.84 <br />Energy: 74.2","Word: kirka <br />Position in word 27 %<br />File: mark04vox_ker <br />Time(s): 89.54 <br />Energy: 76.31","Word: faɗiŋ <br />Position in word 67 %<br />File: mark04vox_ker <br />Time(s): 166.59 <br />Energy: 69.75","Word: ciməcimiŋa <br />Position in word 21 %<br />File: mark04vox_ker <br />Time(s): 212.2 <br />Energy: 75.34","Word: ciməcimiŋa <br />Position in word 55 %<br />File: mark04vox_ker <br />Time(s): 212.41 <br />Energy: 76.86","Word: kirka <br />Position in word 26 %<br />File: mark04vox_ker <br />Time(s): 254.88 <br />Energy: 70.93","Word: iskiyaŋ <br />Position in word 50 %<br />File: mark04vox_ker <br />Time(s): 261.4 <br />Energy: 71.84","Word: kinaŋ <br />Position in word 36 %<br />File: mark04vox_ker <br />Time(s): 294.02 <br />Energy: 74.62","Word: si <br />Position in word 88 %<br />File: mark04vox_ker <br />Time(s): 302.95 <br />Energy: 74.39","Word: ji <br />Position in word 86 %<br />File: mark04vox_ker <br />Time(s): 304.75 <br />Energy: 72.08","Word: kirka <br />Position in word 33 %<br />File: mark04vox_ker <br />Time(s): 320.5 <br />Energy: 74.74","Word: saksaki <br />Position in word 95 %<br />File: mark14vox_ker <br />Time(s): 103.08 <br />Energy: 66.02","Word: ji <br />Position in word 88 %<br />File: mark14vox_ker <br />Time(s): 237.2 <br />Energy: 75.72","Word: akolokiŋ <br />Position in word 87 %<br />File: mark14vox_ker <br />Time(s): 264.83 <br />Energy: 70.95","Word: kir <br />Position in word 61 %<br />File: mark14vox_ker <br />Time(s): 464.63 <br />Energy: 71.5","Word: ji <br />Position in word 87 %<br />File: mark14vox_ker <br />Time(s): 470.42 <br />Energy: 72.85","Word: kina <br />Position in word 35 %<br />File: mark14vox_ker <br />Time(s): 498.24 <br />Energy: 75.3","Word: bi <br />Position in word 85 %<br />File: mark14vox_ker <br />Time(s): 713.17 <br />Energy: 73.21","Word: goglokiŋ <br />Position in word 79 %<br />File: mark14vox_ker <br />Time(s): 831.8 <br />Energy: 69.84"],"textfont":{"size":14.6645669291339,"color":"rgba(0,191,196,1)"},"type":"scatter","mode":"text","hoveron":"points","name":"short","legendgroup":"short","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":40.1826484018265,"l":48.9497716894977},"plot_bgcolor":"rgba(235,235,235,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-3150,150],"tickmode":"array","ticktext":["0","1000","2000","3000"],"tickvals":[0,-1000,-2000,-3000],"categoryorder":"array","categoryarray":["0","1000","2000","3000"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"F2(Hz)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-1050,50],"tickmode":"array","ticktext":["0","250","500","750","1000"],"tickvals":[0,-250,-500,-750,-1000],"categoryorder":"array","categoryarray":["0","250","500","750","1000"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"F1(Hz)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895},"y":0.93503937007874},"annotations":[{"text":"duration","x":1.02,"y":1,"showarrow":false,"ax":0,"ay":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xref":"paper","yref":"paper","textangle":-0,"xanchor":"left","yanchor":"bottom","legendTitle":true}],"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","showSendToCloud":false},"source":"A","attrs":{"ac22edcbd9c":{"label":{},"x":{},"y":{},"colour":{},"text":{},"type":"scatter"}},"cur_data":"ac22edcbd9c","visdat":{"ac22edcbd9c":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
List durations (in ms) of all the tokens as a sanity check for the duration categories:

Short should be durations of 30ms and 40ms 


```r
highvowel_short$end-highvowel_short$start
```

```
##  [1] 40.00 40.00 40.00 40.00 40.00 50.00 40.02 49.98 50.00 40.00 40.00 40.00
## [13] 50.00 40.00 40.00 40.00 49.98 40.00 40.00 50.00 40.00 40.00 40.00 50.00
## [25] 50.00
```

Long should be over 70 ms


```r
highvowel_long$end-highvowel_long$start
```

```
##  [1] 130.00 190.00 100.00  90.00 250.00 110.00  80.00 100.00 140.00 230.00
## [11] 159.98 120.00 150.00 139.98 100.00  90.00 100.00 140.00  90.00  80.00
## [21]  80.00 190.00 130.02 150.00 160.02 170.00 260.00 119.98 120.00  90.00
## [31] 240.00 190.00  90.00  80.00 110.00  90.00 150.00 110.02 100.00 130.00
## [41] 150.00  90.00
```

### Testing for a difference in F1

We need to test for normality before using a t-test.


```r
# if p is low then data is unlikely to be normally distributed
shapiro.test(highvowel_short$F1)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  highvowel_short$F1
## W = 0.88238, p-value = 0.007741
```

```r
# if p is low then data is unlikely to be normally distributed
shapiro.test(highvowel_long$F1)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  highvowel_long$F1
## W = 0.94035, p-value = 0.0294
```

If p<0.05 for at least one distribution then we reject the null hypothesis (that the data is normally distributed). Then it is safer to run a Wilcoxon rank sum test (equivalent to the Mann-Whitney test).


```r
## check difference for F1
## if p-value is less than 0.05 is could be said to be different distributions but matt said it
## the p-value should really be less than 0.01 for a robust finding.
#t.test(pull(highvowel_short,F1),pull(highvowel_long,F1))
wilcox.test(highvowel_short$F1,highvowel_long$F1)
```

```
## Warning in wilcox.test.default(highvowel_short$F1, highvowel_long$F1): cannot
## compute exact p-value with ties
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  highvowel_short$F1 and highvowel_long$F1
## W = 397, p-value = 0.09832
## alternative hypothesis: true location shift is not equal to 0
```
**This above p-value is the main finding of this notebook. If p<0.01 there is a statistically significant difference between the distributions.**

### Testing for a difference in F2

We need to test for normality before using a t-test. 


```r
# if p is low then data is unlikely to be normally distributed
shapiro.test(highvowel_short$F2)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  highvowel_short$F2
## W = 0.68439, p-value = 4.526e-06
```


```r
# if p is low then data is unlikely to be normally distributed
shapiro.test(highvowel_long$F2)
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  highvowel_long$F2
## W = 0.93508, p-value = 0.01929
```


```r
## check difference for F2
## if p-value is less than 0.05 is could be said to be different distributions but matt said it
## the p-value should really be less than 0.01 for a robust finding.
#t.test(highvowel_short$F2,highvowel_long$F2)
wilcox.test(highvowel_short$F2,highvowel_long$F2)
```

```
## Warning in wilcox.test.default(highvowel_short$F2, highvowel_long$F2): cannot
## compute exact p-value with ties
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  highvowel_short$F2 and highvowel_long$F2
## W = 461, p-value = 0.4104
## alternative hypothesis: true location shift is not equal to 0
```
If p<0.01 there is a statistically significant difference between the distributions.
