---
title: "Extract /i/ tokens that are not in the harmony domain"
author: "Timothy Kempton"
date: 2020-06-09
output: 
  html_document:
    keep_md: true
---
This notebook uses EMU to extract acoustic vowel data from the Kera corpus. 
Only /i/ files that are not in the harmony domain are extracted in this 
particular notebook. The data is written to a text file, alongside a diagnostic
formant plot. For the other seven conditions the speaker, vowel, and harmony 
domains can be changed in the code below. 


```r
# Point working directory to a folder where there are TextGrid and wav files 
# (usually from forced alignment)
knitr::opts_knit$set(root.dir = 
        "/home/tim/Downloads/speakerAF_mark1_2_3_4_14_16")
```


```r
library(emuR)
library(ggplot2)
library(dplyr)
library(readr)
library(plotly)
```
Create the EMU database from the TextGrid and wav files

```r
# Set up database
path2directory = file.path(getwd())
convert_TextGridCollection(path2directory, dbName = "actor", 
                           targetDir = tempdir())
path2db = file.path(tempdir(), "actor_emuDB")
db_handle = load_emuDB(path2db, verbose = FALSE)
# Set up word tier and phone tier
autobuild_linkFromTimes(db_handle, superlevelName = "word", 
                        sublevelName = "phone", convertSuperlevel = TRUE,
                        newLinkDefType = "ONE_TO_MANY")
```
Read in the Hayes features

```r
# Note that this file is just a combination of the files at
# https://github.com/speechchemistry/phonemic-analysis/tree/master/resources/common
features <- read.table("big_hayes_phone_list_utf8nfc.tsv",sep="\t", 
                       header=TRUE,encoding="UTF-8")
```

Define the function for returning phones that match a particular feature

```r
# Function `phoneList` modified by Tim Kempton from an original function 
# `phonemeList` (c) Dave Lovell (MIT license) 
# Produces a character vector of phones based on the class specified by the input which is a string
# Eg.  phoneList('delayed_release',-1)
phoneList <- function(type,value=NULL)
{
  #Catch bad values ----------------------------------------------------------------------
  if(!is.null(value)&&!(value %in% c(F,T,1,0,-1)))  {stop('Unrecognised \'value\' argument (should be T/F or [-1:1])')}
  if(!(type %in% colnames(features)))               {stop('\'Type\' argument not in colnames(features)')}
  # Generate character vector ------------------------------------------------------------
  if(!is.null(value)&is.numeric(value))
    { return(as.vector(features$BruceHayes2007[features[[type]]==value]))
    } else {stop('integer \'value\' argument required with this phoneme type')}
}
```
Get a list of phones of features useful to our investigation

```r
# Get a list of IPA non_high_vowels
syllabic <- phoneList('syllabic',1)
non_syllabic <- phoneList('syllabic',-1)
non_high_phones <- phoneList('high',-1)
non_high_vowel_intersection <- intersect(syllabic, non_high_phones)
```
Convert these lists into EMU label groups 

```r
# Define an EMU label group called pg_vowel (phonological vowel)
add_attrDefLabelGroup(db_handle,levelName = "phone",
                      attributeDefinitionName = "phone",
                      labelGroupName = "pg_vowel", labelGroupValues = syllabic)
# Define an EMU label group called pg_consonant (phonological consonant)
add_attrDefLabelGroup(db_handle,levelName = "phone",
                      attributeDefinitionName = "phone",
                      labelGroupName = "pg_consonant", labelGroupValues = non_syllabic)
# Define an EMU label group called non_high_vowel
add_attrDefLabelGroup(db_handle,levelName = "phone",
                      attributeDefinitionName = "phone",
                      labelGroupName = "non_high_vowel", 
                      labelGroupValues = non_high_vowel_intersection)
```
We need to split up the vowel tokens into those that are in the vowel harmony 
domain and those that are not. For Kera, words in the vowel height harmony 
domain can be thought of as words that only have high vowels and that are 
polysyllabic. So first we find words that only contain only high vowels.

```r
# First get the universal set of all word tokens
all_words <- query(db_handle,query = "[word =~ .*]")
# Remove those empty words that correspond to periods of silence
all_words_trimmed <- filter(all_words,labels!= "")
# get words with a non high vowel
words_with_non_high_vowel <- query(db_handle, query = 
                                     "[word =~ .* ^ phone == non_high_vowel]")
# then take them away from the rest of the words, leaving only words with high_vowels
words_with_only_high_vowels <- setdiff(all_words_trimmed,words_with_non_high_vowel)
```
We now intersect this group with the polysyllabic words to give us the words 
that are in the vowel height harmony domain. Words that are not in the height
harmony are just all the remaining words

```r
#Start by retrieving all the words with 3 phones
words_more_than_three_phones <- query(db_handle, "[Num(word, phone) > 3]")
#Also need vcv words
vcv_words <- query(db_handle, 
                   paste0("[[[phone == pg_vowel & Start(word, phone) == TRUE ",
                          "-> phone == pg_consonant]", 
                          "-> phone == pg_vowel & End(word, phone) == TRUE] ",
                          "^ #word =~ .*]"))
# union them to have a set of polysyllabic word tokens 
# (probably could just userbind)
polysyllabic_words <- union(words_more_than_three_phones,vcv_words)
# find the set of high_vowel_harmony_words using set intersection so that we 
# don't have any monosyllabic words
high_vowel_harmony_words <- intersect(words_with_only_high_vowels,polysyllabic_words)
nonhvh_words <- setdiff(all_words_trimmed,high_vowel_harmony_words)
```
Retrieve all the phones from these words

```r
## Not needed in this script: Get a big list of all corresponding phones for those high vowel harmony words 
## Not needed in this script: you'll get a warning that it's bigger list
#high_vowel_harmony_phones <- requery_hier(db_handle,seglist = high_vowel_harmony_words, level = "phone", collapse = FALSE)
# Get a big list of all corresponding phones for those non-high-vowel-harmony words 
# you'll get a warning that it's bigger list
nonhvh_phones <- requery_hier(db_handle,seglist = nonhvh_words, level = "phone", collapse = FALSE)
```

```
## Warning in requery_hier(db_handle, seglist = nonhvh_words, level =
## "phone", : Length of requery segment list (5317) differs from input list
## (1612)!
```
Extract just the vowel under investigation

```r
# Get all the i vowels that were found in the non-high-vowel-harmony domain
# edit these two lines if another vowel is being investigated
i_nonhvh_words <- filter(nonhvh_phones,labels=="i"|labels=="iː")
seglist_in <- i_nonhvh_words
```
Calculate the formants of the midpoints of those vowels

```r
# Calculate formants
trackdata = get_trackdata(db_handle,
                          seglist = seglist_in,
                          onTheFlyFunctionName = "forest",
                          resultType = "tibble",
                          verbose = TRUE)
# Get midpoint of trackdata so we just use the formant values at the midpoint
trackdata_norm=normalize_length(trackdata)
trackdata_norm_midpoint = trackdata_norm %>% filter(times_norm > 0.49 & times_norm < 0.51)
#label formant columns more clearly
trackdata_norm_midpoint <- rename(trackdata_norm_midpoint,F1=T1,F2=T2,F3=T3,F4=T4)
```
Calculate the short-term power of the midpoints of those vowels (using 
root-mean-square amplitude)

```r
# we get the RMS values for adding to the existing formant values.
rms_trackdata = get_trackdata(db_handle,
                               seglist = seglist_in,
                               onTheFlyFunctionName = "rmsana",
                               resultType = "tibble",
                               verbose = TRUE)
# just get the midpoints like we did with the formant data
rms_trackdata_norm=normalize_length(rms_trackdata)
rms_trackdata_norm_midpoint = rms_trackdata_norm %>% filter(times_norm > 0.49 & times_norm < 0.51)
# be explicit about naming the final column as RMS (rather than the less descriptive "T1")
rms_trackdata_norm_midpoint <- rename(rms_trackdata_norm_midpoint,RMS=T1)
# now join the rms values with the formant values
joined_trackdata_norm_midpoint <- full_join(trackdata_norm_midpoint,rms_trackdata_norm_midpoint)
```
For each vowel, include the corresponding word where that vowel occured in

```r
# find the corresponding words of the phones of interest
corresponding_words <- requery_hier(db_handle,seglist = seglist_in, 
                                    level = "word", collapse = FALSE)
# trim the dataframe so it's just the words, label and bundle (i.e. audio filename)
corresponding_words_trimmed <- select(corresponding_words,labels,bundle,start,end)
# rename columns so there is no duplication when bound with the trackdata
# the bundle is just used as a sanity check in the dataframe to check all
# rows line up
corresponding_words_trimmed <- rename(corresponding_words_trimmed,
                                      word_label=labels,
                                      word_start=start,
                                      word_end=end,
                                      check_bundle=bundle)
bound_also_words <- cbind(joined_trackdata_norm_midpoint,corresponding_words_trimmed)
# at this point there should be some sort of check that the data lines up
```
Include an indication of where the vowel occured in the word (using a score of 
0 to 1)

```r
# we need to indicate which part of the word contains the phone in case
# there are multiple tokens of the same phones e.g. two tokens of [i]
# in the same word. One way to do this is to calculate the proportion of the
# word where the phone occurs e.g. 0.90 is the end of the word
with_col_position_in_word <- bound_also_words %>%
  mutate(position_in_word=((start+(end-start)/2)-word_start)/(word_end-word_start))
```
Save all the vowel data that has been calculated

```r
# edit this line if another vowel is being investigated
write_tsv(with_col_position_in_word, "i_all_durations_normal.tsv")
```
Display a formant plot with colours indicating the RMS amplitude

```r
#Plot on a formant chart
p<- with_col_position_in_word %>%
   filter((end - start)>0) %>%
   ggplot(aes(x=F2,y=F1,color=RMS,text = 
                paste("Word:",word_label,
                      "\nPosition in word",
                      round(position_in_word,2)*100,
                      "%\nFile:", bundle, "\nTime(s):",
                      round((start+times_rel)/1000,2),
                      "\nEnergy:",round(RMS,2))))+
   geom_text(aes(label = labels))+
   xlim(3000, 0)+ylim(1000,0)+xlab("F2(Hz)")+ylab("F1(Hz)")
p # for an interactive graph replace this with ggplotly(p, tooltip = "text") 
```

```
## Warning: Removed 1 rows containing missing values (geom_text).
```

![](extract_i_in_normal_domain_files/figure-html/unnamed-chunk-16-1.png)<!-- -->
