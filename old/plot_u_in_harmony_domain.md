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
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |================                                                 |  25%
  |                                                                       
  |================================                                 |  50%
  |                                                                       
  |=================================================                |  75%
  |                                                                       
  |=================================================================| 100%
##   INFO: Rewriting 4 _annot.json files to file system...
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |================                                                 |  25%
  |                                                                       
  |================================                                 |  50%
  |                                                                       
  |=================================================                |  75%
  |                                                                       
  |=================================================================| 100%
```

```r
path2db = file.path(tempdir(), "actor_emuDB")
db_handle = load_emuDB(path2db, verbose = FALSE)
# Set up word tier and phone tier
autobuild_linkFromTimes(db_handle, superlevelName = "word", sublevelName = "phone", convertSuperlevel = TRUE, newLinkDefType = "ONE_TO_MANY")
```

```
##   INFO: Rewriting 4 _annot.json files to file system...
## 
  |                                                                       
  |                                                                 |   0%
  |                                                                       
  |================                                                 |  25%
  |                                                                       
  |================================                                 |  50%
  |                                                                       
  |=================================================                |  75%
  |                                                                       
  |=================================================================| 100%
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
# Get all the u vowels that were found in the vowel height harmony domain 
u_vowel_harmony_words <- high_vowel_harmony_phones[high_vowel_harmony_phones$labels=="u", ]
u_long_vowel_harmony_words <- high_vowel_harmony_phones[high_vowel_harmony_phones$labels=="uː", ]
# put them both together
u_all_vowel_harmony_words <- rbind(u_vowel_harmony_words, u_long_vowel_harmony_words)
# just extract the short ones
short_u_all_vowel_harmony_words <- u_all_vowel_harmony_words[((u_all_vowel_harmony_words$end - u_all_vowel_harmony_words$start) < 50), ]
seglist_in <- short_u_all_vowel_harmony_words
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
## [1] 67 24
```


```r
# Print out statistical summary (I'm most interested
# in T1 and T2 which corresponds to F1 and F2)
summary(trackdata_norm_midpoint)
```

```
##    sl_rowIdx       labels              start             end        
##  Min.   : 1.0   Length:67          Min.   :  7225   Min.   :  7255  
##  1st Qu.:17.5   Class :character   1st Qu.: 96166   1st Qu.: 96201  
##  Median :34.0   Mode  :character   Median :159214   Median :159244  
##  Mean   :34.0                      Mean   :193192   Mean   :193228  
##  3rd Qu.:50.5                      3rd Qu.:278646   3rd Qu.:278686  
##  Max.   :67.0                      Max.   :488323   Max.   :488353  
##    db_uuid            session             bundle          start_item_id   
##  Length:67          Length:67          Length:67          Min.   : 292.0  
##  Class :character   Class :character   Class :character   1st Qu.: 980.5  
##  Mode  :character   Mode  :character   Mode  :character   Median :1677.0  
##                                                           Mean   :1897.2  
##                                                           3rd Qu.:2544.0  
##                                                           Max.   :4046.0  
##   end_item_id        level            attribute         start_item_seq_idx
##  Min.   : 292.0   Length:67          Length:67          Min.   :  54      
##  1st Qu.: 980.5   Class :character   Class :character   1st Qu.: 470      
##  Median :1677.0   Mode  :character   Mode  :character   Median :1024      
##  Mean   :1897.2                                         Mean   :1188      
##  3rd Qu.:2544.0                                         3rd Qu.:1709      
##  Max.   :4046.0                                         Max.   :3072      
##  end_item_seq_idx     type            sample_start        sample_end      
##  Min.   :  54     Length:67          Min.   :  318622   Min.   :  319944  
##  1st Qu.: 470     Class :character   1st Qu.: 4240898   1st Qu.: 4242440  
##  Median :1024     Mode  :character   Median : 7021337   Median : 7022659  
##  Mean   :1188                        Mean   : 8519777   Mean   : 8521369  
##  3rd Qu.:1709                        3rd Qu.:12288266   3rd Qu.:12290029  
##  Max.   :3072                        Max.   :21535044   Max.   :21536366  
##   sample_rate      times_orig       times_rel       times_norm 
##  Min.   :44100   Min.   :  7240   Min.   :15.00   Min.   :0.5  
##  1st Qu.:44100   1st Qu.: 96183   1st Qu.:15.00   1st Qu.:0.5  
##  Median :44100   Median :159229   Median :20.00   Median :0.5  
##  Mean   :44100   Mean   :193210   Mean   :18.06   Mean   :0.5  
##  3rd Qu.:44100   3rd Qu.:278666   3rd Qu.:20.00   3rd Qu.:0.5  
##  Max.   :44100   Max.   :488338   Max.   :25.00   Max.   :0.5  
##        T1              T2             T3             T4      
##  Min.   :252.5   Min.   :   0   Min.   :2136   Min.   :   0  
##  1st Qu.:307.5   1st Qu.:1088   1st Qu.:2468   1st Qu.:3164  
##  Median :349.0   Median :1186   Median :2506   Median :3576  
##  Mean   :351.3   Mean   :1216   Mean   :2506   Mean   :3407  
##  3rd Qu.:388.0   3rd Qu.:1356   3rd Qu.:2561   3rd Qu.:3816  
##  Max.   :530.5   Max.   :1824   Max.   :2688   Max.   :4105
```


```r
#Plot on a formant chart
trackdata_norm_midpoint %>%
    filter((end - start)>0) %>%
    ggplot(aes(x=T2,y=T1,color=labels))+
    geom_text(aes(label = labels))+
    xlim(3000, 0)+ylim(1000,0)+xlab("F2(Hz)")+ylab("F1(Hz)")
```

![](plot_u_in_harmony_domain_files/figure-html/unnamed-chunk-12-1.png)<!-- -->
