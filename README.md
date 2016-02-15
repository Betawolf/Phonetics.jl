# Phonetics

[![Build Status](https://travis-ci.org/Betawolf/Phonetics.jl.svg?branch=master)](https://travis-ci.org/Betawolf/Phonetics.jl)

This `Julia` library implements some widely-used phonetic coding schemes, including:

+ Soundex
+ Fuzzy Soundex
+ Phonex
+ Phonix
+ The New York State Identification and Intelligence System (NYSIIS)
+ The Match Rating Approach
+ Caverphone
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
functionality for phonetic codes. Note that this is _not_ string comparison.

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
```

