# Phonetics

[![Build Status](https://travis-ci.org/Betawolf/Phonetics.jl.svg?branch=master)](https://travis-ci.org/Betawolf/Phonetics.jl)

This `Julia` library implements some widely-used phonetic coding schemes, including:

+ Soundex
+ Fuzzy Soundex
+ Phonex
+ Phonix
+ The New York State Identification and Intelligence System (NYSIIS)
+ The Census Modified Statistics Canada procedure
+ The Match Rating Approach
+ Lein
+ Caverphone
+ Roger Root
+ Metaphone
+ Double Metaphone


Phonetic coding schemes are used to transform strings, particularly names, into
representations which reflect how they might be pronounced or perceived to have
been pronounced. In essence, they map words to codes which should be resilient
to spelling variation.

For example:

```{julia}
using Phonetics

soundex("Smythe")
#"s530"

soundex("Smith")
#"s530"

soundex("Gail")
#"g400"

soundex("Gayle")
#"g400"
```

As well as the encoding schemes themselves, this package includes some comparison
functionality for phonetic codes. Note that this is _not_ edit-distance-style string comparison,
but a measure of the phonetic similarity of the two strings according to a particular
coding system (except for `editex`, which is both).

```{julia}
using Phonetics

#Fuzzy Soundex method of comparing codes
code_similarity("Kristina", "Christina")
#1.0

code_similarity("Kristina", "Kristian")
#0.6

#Can use different coding methods to make the comparison, with different results
code_similarity("Kristian", "Kristina", phonix)
#1.0

#The match rating approach quantifies similarity as an integer.
match_rating("Smith", "Smythe")
#5

match_rating("Smith", "Bobby")
#2

#This is compared automatically to a threshold value if a binary judgement is required.
meets_match_rating("Smith", "Smythe")
#true

meets_match_rating("Smith", "Bobby")
#false

editex("Hello", "Hullo")
#1

editex("Hellophant", "Hullo")
#10
```

There is a function `code_match`, which performs phonetic matching on an array
of strings (such as might be the `collect(keys())` to a `Dict`), so that sound-alike options are
selected and returned.

```{julia}
#some strings
helpstrings = ["Halp", "Elf", "Hulk", "Heelp","Half", "Abba", "Any"]

code_match("Help", helpstrings)
#["Halp", "Heelp", "Half"] <- matches under the default coding scheme, fuzzy_soundex.

code_match("Help", helpstrings, double_metaphone)
#["Halp", "Heelp"] <- More reasonable matches from the better algorithm.

#You can also set a permissive value to get more matches within a system.
code_match("Help", helpstrings, fuzzy_soundex, 0.5)
#["Halp", "Elf", "Hulk", "Heelp", "Half"]

code_match("Help", helpstrings, fuzzy_soundex, 0.1)
#["Halp", "Elf", "Hulk", "Heelp","Half", "Abba", "Any"] <- lower values are more permissive
```

There is also a clustering function `code_cluster` which groups strings which are similar
according to their phonetic codes.

```{julia}
strings = ["Sing", "Sink", "Song", "Sunk", "Sinking", "Singing", "Single"]

code_cluster(strings)
#3-element Array{Array{T,1},1}:
# ["Sing","Sink","Song","Sunk","Sinking","Singing"]
# ["Sinking","Singing"]
# ["Single"]
# ^ - note that clusters can be fairly wide, and that by default items appear in multiple clusters
# The number of clusters is organically suited to the diversity of the input set.

#clusters can be made to use only exact matches by setting both thresholds to 1.
code_cluster(strings, phonix, 1, 1)
#3-element Array{Array{T,1},1}:
# ["Sing","Sink","Song","Sunk"]
# ["Sinking","Singing"]
# ["Single"]
```

Finally, there are some functions for measuring more general phonetic qualities of strings.

```{julia}
#count the number of syllables in a word
syllable_count("Syllable")
# 3

#also works with sentences (and other languages, if rules are defined).
syllable_count("Mary had a little lamb")
# 7

#estimate how long it would take to say something
spoken_length("Mary had a little lamb")
#2.52064687529
#in seconds

#also in some other languages
spoken_length("Mary hatte ein kleines lamm", "de")
#2.10911496886
```
