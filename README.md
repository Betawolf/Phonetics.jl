## Phonics

This `Julia` library implements some widely-used phonetic coding schemes, including:

+ Soundex
+ Phonex
+ Phonix
+ The New York State Identification and Intelligence System (NYSIIS)
+ Metaphone

### Phonetics 

Phonetic coding schemes are used to transform strings, particularly names, into 
representations which reflect how they might be pronounced or perceived to have
been pronounced. In essence, they map words to codes which should be resilient
to spelling variation.

For example:

```{julia}
using phonics

soundex("Smythe")
#"s530"

soundex("Smith")
#"s530"

soundex("Gail")
#"g400"

soundex("Gayle")
#"g400"
```
