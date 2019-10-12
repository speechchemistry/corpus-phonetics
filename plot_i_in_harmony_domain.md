---
output: 
  html_document:
    keep_md: true

---


```r
# Point working directory to a folder where there are TextGrid and wav files (usually from forced alignment)
knitr::opts_knit$set(root.dir = "C:\\Users\\Tim\\Documents\\Kera_NT\\original_data_for_paper_including_converted_mp3\\just_narrator")
```


```r
library(emuR)
```

```
## 
## Attaching package: 'emuR'
```

```
## The following object is masked from 'package:base':
## 
##     norm
```

```r
library(ggplot2)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```


```r
# Set up database
path2directory = file.path(getwd())
convert_TextGridCollection(path2directory, dbName = "actor", targetDir = tempdir())
```

```
## INFO: Loading TextGridCollection containing 4 file pairs...
##   |                                                                         |                                                                 |   0%  |                                                                         |================                                                 |  25%  |                                                                         |================================                                 |  50%  |                                                                         |=================================================                |  75%  |                                                                         |=================================================================| 100%
##   INFO: Rewriting 4 _annot.json files to file system...
##   |                                                                         |                                                                 |   0%  |                                                                         |================                                                 |  25%  |                                                                         |================================                                 |  50%  |                                                                         |=================================================                |  75%  |                                                                         |=================================================================| 100%
```

```r
path2db = file.path(tempdir(), "actor_emuDB")
db_handle = load_emuDB(path2db, verbose = FALSE)
# Set up word tier and phone tier
autobuild_linkFromTimes(db_handle, superlevelName = "word", sublevelName = "phone", convertSuperlevel = TRUE, newLinkDefType = "ONE_TO_MANY")
```

```
##   INFO: Rewriting 4 _annot.json files to file system...
##   |                                                                         |                                                                 |   0%  |                                                                         |================                                                 |  25%  |                                                                         |================================                                 |  50%  |                                                                         |=================================================                |  75%  |                                                                         |=================================================================| 100%
```

```r
features <- read.table("big_hayes_phone_list_utf8nfc.tsv",sep="\t", header=TRUE,encoding="UTF-8")
```


```r
## Define the phoneList function
phoneList <- function(type,value=NULL)
{
  # Function `phoneList` (c) Dave Lovell
  ## Produces a character vector of phones based on the class specified by the input which is a string
  ## Eg.  phoneList('delayed_release',-1)
  
  #Catch bad values ----------------------------------------------------------------------
  if(!is.null(value)&&!(value %in% c(F,T,1,0,-1)))  {stop('Unrecognised \'value\' argument (should be T/F or [-1:1])')}
  if(!(type %in% colnames(features)))               {stop('\'Type\' argument not in colnames(features)')}
  
  # Generate character vector ------------------------------------------------------------
  if(!is.null(value)&is.numeric(value))
    { return(as.vector(features$BruceHayes2007[features[[type]]==value]))
    } else {stop('integer \'value\' argument required with this phoneme type')}
}
```


```r
# Get a list of IPA non_high_vowels
vowels <- phoneList('syllabic',1)
non_high_phones <- phoneList('high',-1)
non_high_vowel_intersection <- intersect(vowels, non_high_phones)
```


```r
# Define an EMU label group called non_high_vowel
add_attrDefLabelGroup(db_handle,levelName = "phone",attributeDefinitionName = "phone",labelGroupName = "non_high_vowel", labelGroupValues = non_high_vowel_intersection)
```


```r
# This section finds all the high vowel harmony words.
# First get words with a non high vowel
words_with_non_high_vowel <- query(db_handle, query = "[word =~ .* ^ phone == non_high_vowel]")
# then take them away from the rest of the words, leaving only words with high_vowels (and periods of silence)
all_words <- query(db_handle,query = "[word =~ .*]")
words_without_non_high_vowels <- setdiff(all_words,words_with_non_high_vowel)
# Remove those empty words that correspond to periods of silence
high_vowel_harmony_words <- words_without_non_high_vowels[words_without_non_high_vowels$labels!="", ]
```



```r
# Get a big list of all corresponding phones for those high vowel harmony words - you'll get a warning that it's bigger list
high_vowel_harmony_phones <- requery_hier(db_handle,seglist = high_vowel_harmony_words, level = "phone", collapse = FALSE)
```

```
## Warning in requery_hier(db_handle, seglist = high_vowel_harmony_words,
## level = "phone", : Length of requery segment list (2542) differs from input
## list (788)!
```


```r
# Get all the i vowels that were found in the vowel height harmony domain 
i_vowel_harmony_words <- high_vowel_harmony_phones[high_vowel_harmony_phones$labels=="i", ]
i_long_vowel_harmony_words <- high_vowel_harmony_phones[high_vowel_harmony_phones$labels=="iː", ]
# Put them both together
i_all_vowel_harmony_words <- rbind(i_vowel_harmony_words, i_long_vowel_harmony_words)
# Just extract the short ones
short_i_all_vowel_harmony_words <- i_all_vowel_harmony_words[((i_all_vowel_harmony_words$end - i_all_vowel_harmony_words$start) < 50), ]
seglist_in <- short_i_all_vowel_harmony_words
```


```r
# Calculate formants
trackdata = get_trackdata(db_handle,
                          seglist = seglist_in,
                          onTheFlyFunctionName = "forest",
                          resultType = "tibble",
                          verbose = F)
# Get midpoint of trackdata so we just use the formant values at the midpoint
trackdata_norm=normalize_length(trackdata)
trackdata_norm_midpoint = trackdata_norm %>% filter(times_norm > 0.49 & times_norm < 0.51)
# check size - this should match the number of records in seglist_in
dim(trackdata_norm_midpoint)
```

```
## [1] 59 24
```


```r
# Print out statistical summary (I'm most interested
# in T1 and T2 which corresponds to F1 and F2)
summary(trackdata_norm_midpoint)
```

```
##    sl_rowIdx       labels              start             end        
##  Min.   : 1.0   Length:59          Min.   :  5345   Min.   :  5375  
##  1st Qu.:15.5   Class :character   1st Qu.: 65934   1st Qu.: 65964  
##  Median :30.0   Mode  :character   Median :148114   Median :148144  
##  Mean   :30.0                      Mean   :175845   Mean   :175880  
##  3rd Qu.:44.5                      3rd Qu.:291335   3rd Qu.:291375  
##  Max.   :59.0                      Max.   :487953   Max.   :487983  
##    db_uuid            session             bundle          start_item_id 
##  Length:59          Length:59          Length:59          Min.   : 261  
##  Class :character   Class :character   Class :character   1st Qu.: 866  
##  Mode  :character   Mode  :character   Mode  :character   Median :1525  
##                                                           Mean   :1778  
##                                                           3rd Qu.:2594  
##                                                           Max.   :4040  
##   end_item_id      level            attribute         start_item_seq_idx
##  Min.   : 261   Length:59          Length:59          Min.   :  23.0    
##  1st Qu.: 866   Class :character   Class :character   1st Qu.: 358.5    
##  Median :1525   Mode  :character   Mode  :character   Median : 829.0    
##  Mean   :1778                                         Mean   :1076.3    
##  3rd Qu.:2594                                         3rd Qu.:1720.5    
##  Max.   :4040                                         Max.   :3066.0    
##  end_item_seq_idx     type            sample_start        sample_end      
##  Min.   :  23.0   Length:59          Min.   :  235714   Min.   :  237036  
##  1st Qu.: 358.5   Class :character   1st Qu.: 2907667   1st Qu.: 2908989  
##  Median : 829.0   Mode  :character   Median : 6531827   Median : 6533149  
##  Mean   :1076.3                      Mean   : 7754754   Mean   : 7756292  
##  3rd Qu.:1720.5                      3rd Qu.:12847851   3rd Qu.:12849614  
##  Max.   :3066.0                      Max.   :21518727   Max.   :21520049  
##   sample_rate      times_orig       times_rel       times_norm 
##  Min.   :44100   Min.   :  5360   Min.   :15.00   Min.   :0.5  
##  1st Qu.:44100   1st Qu.: 65949   1st Qu.:15.00   1st Qu.:0.5  
##  Median :44100   Median :148129   Median :15.00   Median :0.5  
##  Mean   :44100   Mean   :175862   Mean   :17.46   Mean   :0.5  
##  3rd Qu.:44100   3rd Qu.:291355   3rd Qu.:20.00   3rd Qu.:0.5  
##  Max.   :44100   Max.   :487968   Max.   :25.00   Max.   :0.5  
##        T1              T2             T3             T4      
##  Min.   :  0.0   Min.   :   0   Min.   :   0   Min.   :   0  
##  1st Qu.:276.0   1st Qu.:1444   1st Qu.:2526   1st Qu.:3190  
##  Median :336.0   Median :1894   Median :2568   Median :3698  
##  Mean   :334.0   Mean   :1775   Mean   :2595   Mean   :3310  
##  3rd Qu.:386.8   3rd Qu.:2147   3rd Qu.:2699   3rd Qu.:3808  
##  Max.   :769.0   Max.   :2382   Max.   :3177   Max.   :4042
```


```r
#Plot on a formant chart
trackdata_norm_midpoint %>%
    filter((end - start)>0) %>%
    ggplot(aes(x=T2,y=T1,color=labels))+
    geom_text(aes(label = labels))+
    xlim(3000, 0)+ylim(1000,0)+xlab("F2(Hz)")+ylab("F1(Hz)")
```

![](plot_i_in_harmony_domain_files/figure-html/unnamed-chunk-12-1.png)<!-- -->
