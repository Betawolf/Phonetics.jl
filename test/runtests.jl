using Phonetics
using Test

#Tests for correctness of Caverphone
@test caverphone("Lee") ==  "l11111"
@test caverphone("Thompson") ==  "tmpsn1"

##Tests for correctness of Soundex
@test soundex("Euler") == "e460"
@test soundex("Ellery") == "e460"
@test soundex("Gauss") == "g200"
@test soundex("Ghosh") == "g200"
@test soundex("Hilbert") ==  "h416"
@test soundex("Heilbronn") ==  "h416"
@test soundex("Kant") ==  "k530"
@test soundex("Knuth") ==  "k530"
@test soundex("Ladd") == "l300"
@test soundex("Lloyd") == "l300"
@test soundex("Christina") ==  "c623"
@test soundex("Kristina") ==  "k623"

#Tests for correctness of Metaphone
@test metaphone("School") ==  "skl"
@test metaphone("Shubert") ==  "xbrt"
@test metaphone("Bonner") ==  "bnr"
@test metaphone("Baymore") ==  "bmr"
@test metaphone("Smith") ==  "sm0"
@test metaphone("Saneed") ==  "snt"
@test metaphone("Aardvark") ==  "artf"
@test metaphone("persuade") ==  "prst"
@test metaphone("pressed") ==  "prst"

#NB: reference seemed confused about these two examples.
@test metaphone("Van Hoesen") ==  "fnhs"
@test metaphone("Vincenzo") ==  "fnsn"

#Tests for correctness of Phonex
@test phonex("Peter") ==  "b360"
@test phonex("Pete") ==  "b300"
@test phonex("Pedro") ==  "b360"
@test phonex("Stephen") ==  "s315"
@test phonex("Steve") ==  "s310"
@test phonex("Smythe") ==  "s530"
@test phonex("Smith") ==  "s530"
@test phonex("Gail") ==  "g400"
@test phonex("Gayle") ==  "g400"
@test phonex("Christina") ==  "c623"
@test phonex("Kristina") ==  "c623"

#Test for correctnes of Phonix
@test phonix("Peter") ==  "p300"
@test phonix("Pete") ==  "p300"
@test phonix("Pedro") ==  "p360"
@test phonix("Stephen") ==  "s375"
@test phonix("Steve") ==  "s370"
@test phonix("Smith") ==  "s530"
@test phonix("Smythe") ==  "s530"
@test phonix("Gail") ==  "g400"
@test phonix("Gayle") ==  "g400"
@test phonix("Christina") ==  "k683"
@test phonix("Kristina") ==  "k683"

#Test for correctness of NYSIIS
@test nysiis("Peter") ==  "patar"
@test nysiis("Pete") ==  "pat"
@test nysiis("Pedro") ==  "padr"
@test nysiis("Stephen") ==  "stafan"
@test nysiis("Steve") ==  "staf"
@test nysiis("Smith") ==  "snat"
@test nysiis("Smythe") ==  "snyt"
@test nysiis("Gail") ==  "gal"
@test nysiis("Gayle") ==  "gayl"
@test nysiis("Christina") ==  "chrast"
@test nysiis("Kristina") ==  "crasta"
@test nysiis("Lawson") ==  "lasan"
@test nysiis("Greene") ==  "gran"
@test nysiis("Lynch") ==  "lync"
@test nysiis("Wheeler") ==  "whalar"
@test nysiis("Mitchell") ==  "matcal"
@test nysiis("Anderson") ==  "andars"
@test nysiis("Truman") ==  "tranan"
@test nysiis("Jellyfish") ==  "jalyf"

#Test for correctness of Double-Metaphone
@test double_metaphone("Peter") == "ptr"
@test double_metaphone("Pete") ==  "pt"
@test double_metaphone("Pedro") ==  "ptr"
@test double_metaphone("Stephen") ==  "stfn"
@test double_metaphone("Steve") ==  "stf"
@test double_metaphone("Smith") ==  ["sm0","xmt"]
@test double_metaphone("Smythe") ==  ["sm0","xmt"]
@test double_metaphone("Gail") ==  "kl"
@test double_metaphone("Gayle") ==  "kl"
@test double_metaphone("Christina") ==  "krstn"
@test double_metaphone("Kristina") ==  "krstn"
@test double_metaphone("Whithers") ==  ["a0rs","atrs"]
@test double_metaphone("Wasserman") ==  ["asrmn","fsrmn"]
@test double_metaphone("Vasserman") ==  "fsrmn"
@test double_metaphone("Arnoff") ==  "arnf"
@test double_metaphone("Arnow") ==  ["arn","arnf"]
@test double_metaphone("Filipowicz") == ["flpts", "flpfx"]
@test double_metaphone("Wrainwright") ==  "rnrt"
@test double_metaphone("Hugh") ==  "h"
@test double_metaphone("Loughbridge") ==  "lfbrj"
@test double_metaphone("Edge") ==  "aj"
@test double_metaphone("Edgar") ==  "atkr"
@test double_metaphone("Pepsi") ==  "pps"
@test double_metaphone("Phillipa") ==  "flp"
@test double_metaphone("Xavier") ==  ["sf","sfr"]
@test double_metaphone("Hochmeier") ==  "hkmr"
@test double_metaphone("Caeser") ==  "ssr"
@test double_metaphone("Chianti") ==  "knt"
@test double_metaphone("Michael") ==  ["mkl","mxl"]
@test double_metaphone("Chemise") ==  "kms"
@test double_metaphone("McHugh") ==  "mkh"
@test double_metaphone("Czerny") ==  ["srn","xrn"]
@test double_metaphone("Focaccia") ==  ["fxx","fkx"]
@test double_metaphone("Bellaccio") ==  "blx"
@test double_metaphone("Bacchus") ==  "bkhs"
@test double_metaphone("Accident") ==  "akstnt"
@test double_metaphone("Succeed") ==  "skst"
@test double_metaphone("Belacqua") ==  "blk"
@test double_metaphone("Francia") ==  ["frns","frnx"]
@test double_metaphone("Mac Gregor") ==  "mkrkr"
@test double_metaphone("Mac Caffrey") ==  "mkfr"
@test double_metaphone("McLaughin") ==  "mklfn"
@test double_metaphone("Tagliaro") ==  ["tklr", "tlr"]
@test double_metaphone("Gelman") ==  ["klmn", "jlmn"]
@test double_metaphone("Knowles") ==  ["nls","nfls"]
@test double_metaphone("Jose") ==  "hs"
@test double_metaphone("Yankelofich") ==  "anklfx"
@test double_metaphone("Jankelowicz") ==  ["jnklts","anklfx"]
@test double_metaphone("Cabrillo") ==  ["kbrl","kbr"]

#Test for correctness of MRA
@test match_rating_encode("Smith") ==  "smth"
@test match_rating_encode("Smythe") ==  "smyth"
@test match_rating_encode("Christina") ==  "chrstn"
@test match_rating_encode("Kristina") ==  "krstn"
@test match_rating_encode("Catherine") ==  "cthrn"
@test match_rating_encode("Kathryn") ==  "kthryn"
@test match_rating_encode("Byrne") ==  "byrn"
@test match_rating_encode("Boern") ==  "brn"

@test match_rating("Byrne","Boern") == 5
@test meets_match_rating("Byrne","Boern")
@test match_rating("Smith","Smythe") == 5
@test meets_match_rating("Smith","Smythe")
@test match_rating("Catherine","Kathryn") ==  4
@test meets_match_rating("Catherine","Kathryn")

#Test for correctness of Fuzzy Soundex
@test fuzzy_soundex("Kristen") == "k6935"
@test fuzzy_soundex("Krissy") == "k6900"
@test fuzzy_soundex("Christen") == "k6935"

#Test some examples of code_similarity
@test code_similarity("Kristina", "Christina") == 1
@test code_similarity("Kristina", "Kristian") == 0.6
@test code_similarity("Kristian", "Kristina", phonix) == 1

#Test some examples of code_match
helpstrings = ["Halp", "Elf", "Hulk", "Heelp","Half", "Abba", "Any"]
@test code_match("Help", helpstrings) == ["Halp", "Heelp", "Half"]
@test code_match("Help", helpstrings, phonex) == ["Halp", "Elf", "Heelp", "Half", "Abba"]
@test code_match("Help", helpstrings, metaphone) == ["Halp", "Heelp"]
@test code_match("Help", helpstrings, double_metaphone) == ["Halp", "Heelp"]
@test code_match("Help", helpstrings, metaphone, 0.5) == ["Halp", "Hulk", "Heelp", "Half"]
@test code_match("Help", helpstrings, phonex, 0.1) == helpstrings

#Test some examples of code_cluster
strings = ["Sing", "Sink", "Song", "Sunk", "Sinking", "Singing", "Single"]
ccs1 = code_cluster(strings, phonix, 0.7, 0.9, false)
@test ccs1[1] == ["Sing","Sink","Song","Sunk","Sinking","Singing"]
@test ccs1[2] == ["Sinking","Singing"]
@test ccs1[3] == ["Single"]
@test length(ccs1) == 3
ccs2 = code_cluster(strings, phonix, 1, 1, false)
@test ccs2[1] == ["Sing","Sink","Song","Sunk"]
@test ccs2[2] == ["Sinking","Singing"]
@test ccs2[3] == ["Single"]
@test length(ccs2) == 3

#Test some examples for editex
@test editex("Hello", "Hullo") == 1
@test editex("Hellophant", "Hullo") == 10
@test editex("ello", "Hola") == 4
@test editex("lo", "Hola") == 6
@test editex("Singings", "Cingingz") == 2
@test editex("Singings", "Singjings") == 1
@test editex("Singings", "Singlings") == 2

#Test examples of syllable counts
@test syllable_count("syllable") == 3
@test syllable_count("syllables") == 3
@test syllable_count("Mary had a little lamb") == 7
@test syllable_count("calibre") == 3
@test syllable_count("sabre-toothed") == 4
@test syllable_count("are") == 1
@test syllable_count("area") == 2
@test syllable_count("underlies") == 3

#Test for correctness of Roger Root
@test roger_root("Johnson") == "32020"
@test roger_root("Williams") == "45300"
@test roger_root("Smith") == "00310"
@test roger_root("Jones") == "32000"
@test roger_root("Brown") == "09420"
@test roger_root("Davis") == "01800"
@test roger_root("Jackson") == "37020"
@test roger_root("Wilson") == "45020"
@test roger_root("Lee") == "05000"
@test roger_root("Thomas") == "01300"

@test spoken_length("Mary had a little lamb") ≈ 2.52064687529
@test spoken_length("Mary hatte ein kleines lamm", "de") ≈ 2.1091149688610002