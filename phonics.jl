module phonics

" Looks up character against input classes, returns integer code as Char, or
  else the input if the character was not found. "
function table_lookup(chr, table)
  for pos in 1:length(table)
    if chr in table[pos]
        return Char('0'+(pos-1))
    end
  end
  return chr
end

" Replace all the 'find' patterns with the corresponding 'replace' strings. "
function replace_all(str, from, to, display=false)
  nstr = str
  for pos in 1:length(from)
    nstr = replace(nstr, from[pos], to[pos])
    if display
      println(nstr, " = ", from[pos], " :: ", to[pos])
    end
  end
  return nstr
end

" 'Squashes' a string by reducing any repeated characters to only one instance. "
function squash(str)
  nstr = ""
  lc = 0
  for c in str
    if c != lc
      nstr = nstr * string(c)
      lc = c
    end
  end
  return nstr
end

" Lowercase and strip non-alpha chars from a word. "
function prep(str)
  return replace(lowercase(str), r"[^a-z]", "")
end

" Returns the difference between two strings, in
  reverse order to the input. "
function reversed_non_matching(ionestr, itwostr)
  unmatchedone = ""
  unmatchedtwo = ""

  l1 = length(ionestr)
  l2 = length(itwostr)

  #Comparison part, build strings of non-matches 
  lrcmplen = min(l1, l2)
  for i in 1:lrcmplen
    if ionestr[i] != itwostr[i]
      unmatchedone = string(ionestr[i]) * unmatchedone
      unmatchedtwo = string(itwostr[i]) * unmatchedtwo
    end
  end

  #Round off longer string with remaining characters
  for i in lrcmplen+1:max(l1,l2)
    if i <= l1
      unmatchedone = string(ionestr[i]) * unmatchedone
    elseif i <= l2
      unmatchedtwo = string(itwostr[i]) * unmatchedtwo
    end
  end
  return [unmatchedone,unmatchedtwo]
end
 




"""
  soundex(str)

  Transforms a string into its Soundex code.

  The Russell Soundex code is designed primarily for use with English names and has some
  known drawbacks, including a sensitivity to the first letter of a name (Christina is c623
  and similar Kristina is k623) and loss of some audible differences (Kant and Knuth, k530).
 """
function soundex(str)
  lstr = prep(str)

  #Squash repetitions.
  lstr = squash(lstr)

  soundex_table = ["aehiouwy", "bfpv", "cgjkqsxz", "dt", "l", "mn", "r"]

  #Look up soundex coding for 2:end
  body = map(x -> table_lookup(x, soundex_table), lstr[2:end])
  
  #Remove 0's 
  body = join(split(body, '0')) 

  #Pad with 0's
  body = body * "000"
  
  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:3]])
end


"""
  phonex(str)
  
  Transforms a string into its Phonex code.

  Lait & Randell's Phonex encoding scheme can be viewed as an improved version
  of Soundex. Like Soundex, it produces a 1-letter 3-number code, but a range
  of modifications make it more resiliant to encoding errors involving the first
  character of a word, as well as other issues caused by interactions between
  characters within the rest of the word. """
function phonex(str)

  lstr = prep(str)
  
  # remove trailing s
  if lstr[end] == 's'
    lstr = lstr[1:end-1]
  end
  
  #Remove duplicates
  lstr = squash(lstr)

  #Find/replace leading patterns
  phonex_pre_find = [r"^kn", r"^ph", r"^wr", r"^h", r"^[eiouy]", r"^p", r"^v", r"^[kq]", r"^j", r"^z"]
  phonex_pre_repl = ['n', 'f', 'r', "", 'a', 'b', 'f', 'c', 'g','s']
  lstr = replace_all(lstr, phonex_pre_find, phonex_pre_repl)
  
  #Preparatory find/replace for main coding.
  phonex_main_find = [r"[dt]c",r"[lr]([^aeiou$])",r"([mn])g",r"a|e|h|i|o|u|w|y",r"a+"]
  phonex_main_repl = ['c',s"\1", s"\1",'a',""]
  body = replace_all(lstr[2:end], phonex_main_find, phonex_main_repl)

  #look up phonex coding for 2:end
  phonex_table = ["","bfpv", "cgjkqsxz", "dt", "l", "mn", "r"]
  body = map(x -> table_lookup(x, phonex_table), body)

  #Pad with 0's
  body = body * "000"
  
  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:3]])
end
  

"""
  metaphone(str, len=4)

  Transforms a word into its Metaphone reresentation.

  Lawrence Phillips' Metaphone technique is applicable to a range of sound-alike
  words. It produces a code which uses a sixteen-character alphabet, with 'x' for
  'sh' sounds and 'ø' for 'th' sounds, and no vowels apart from where they are the
  first letter. In some cases, such as the word 'persuade', its representation may 
  be unintuitive regarding pronunciation. 

  For comparison purposes, 4 characters are usually used, but you may vary the 
  returned length if you wish for a longer representation. 
"""
function metaphone(str,len=4)
  
  lstr = prep(str)
  
  #substitution rules
  metaphone_find = ["^x",  "x",  "mb",  "sch",  r"t?ch|sh",  r"cia|[st]i[ao]",  r"s?c([eiy])(.+)",  r"(.+)dg([eiy])",  "d", r"gh([^aeiou$])",  r"gn$",  r"gned$",  r"c|g|q",  r"ph|v",  "th",  r"^wh",  r"[wy]([^aeiou])",  "z",  r"^[gk]n",  r"^pm"]
  metaphone_repl = ["s",  "ks",  "m",  "sk",  'x',  "xa",  s"s\1\2",  s"\1j\2",  't',  s"h\1",  "n",  "ned",  "k",  "f",  "ø",  "w",  s"\1", "s",  "n",  "m"]
  lstr = replace_all(lstr, metaphone_find, metaphone_repl)
  
  #remove duplicates
  lstr = squash(lstr)

  #remove vowels apart from the first
  lstr = replace(lstr, r"([^^])[aeiou]+", s"\1")
  
  #return first len letters (if that many)
  return lstr[1:min(len,end)]
end
  

"""
  phonix(str)

  Transforms a string into its Phonix code.

  T. N. Gadd's Phonix encoding scheme is based on the Soundex scheme, and is 
  similar to the related Phonex scheme. The Phonix scheme uses a large set of
  hand-crafted rules specific to English text and pronunciation. A performance
  penalty might be expected as a result of this large ruleset. 
"""
function phonix(str)
  
  lstr = prep(str)

  #Apply this giant list of rules.
  phonix_find = [r"dg", r"c([oau])", r"c[yi]", r"ce", r"^cl([aeiou])", r"ck", r"[gj]c$", r"^ch?r([aeiou])", r"^wr", r"nc", r"ct", r"ph", r"aa", r"sch", r"btl", r"ght", r"augh", r"([aeiou])lj([aeiou])", r"lough", r"^q", r"^kn", r"^gn|gn$", r"(\w)gn([^aeiou])", r"ghn", r"gne$", r"ghne", r"gnes$", r"^ps", r"^pt", r"^cz", r"([aeiou]})wz(\w)", r"(\w)cz(\w)", r"lz", r"rz", r"(\w)z([aeiou])", r"zz", r"([aeiou])z(\w)", r"hrough", r"ough", r"([aeiou]})q([aeiou])", r"([aeiou])j([aeiou])", r"^yj([aeiou])", r"^gh", r"([aeiou])e$", r"^cy", r"nx", r"^pf", r"dt$", r"([td])l$", r"yth", r"^ts?j([aeiou])", r"^ts([aeiou])", r"tch", r"([aeiou])wsk", r"^[pm]n([aeiou])", r"([aeiou])stl", r"tnt$", r"eaux$", r"exci", r"x", r"ned$", r"jr", r"ee$", r"zs", r"([aeiou])h?r([^aeiou]|$)", r"re$", r"lle", r"([^aeiou])le(s?)$", r"e$", r"es$", r"([aeiou])ss", r"([aeiou])mb$", r"mpts", r"mps", r"mpt", r"^[aeiou]"]
  phonix_repl = [s"g", s"k", s"si", s"se", s"kl", s"k", s"k", s"kr", s"r", s"nk", s"kt", s"f", s"ar", s"sh", s"tl", s"t", s"arf", s"ld", s"low", s"kw", s"n", s"n", s"n", s"n", s"n", s"ne", s"ns", s"s", s"t", s"c", s"z", s"ch", s"lsh", s"rsh", s"s", s"ts", s"ts", s"rew", s"of", s"kw", s"y", s"y", s"g", s"gh", s"s", s"nks", s"f", s"t", s"il", s"ith", s"ch", s"t", s"ch", s"vsike", s"n", s"sl", s"ent", s"oh", s"ecs", s"ecs", s"nd", s"dr", s"ea", s"s", s"ah", s"ar", s"le", s"ile\1", s"", s"s", s"as", s"m", s"mps", s"ms", s"mt", s"v"]
  lstr = replace_all(lstr, phonix_find, phonix_repl)

  #remove duplicates
  lstr = squash(lstr)

  #look up phonix encoding for 2:end
  phonix_table = ["aehiouwy", "bp", "cgjkq", "dt", "l", "mn", "r", "fv", "sxz"]
  body = map(x -> table_lookup(x, phonix_table), lstr[2:end])

  #remove vowels
  body = replace(body, r"0+", "")
  
  #Pad with 0's
  body = body * "000"
  
  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:3]])
end


"""
  nysiis(str, len=6)
  
  Transform a string according to the New York State Identification and 
  Intelligence System (NYSIIS) encoding scheme. 

  Taft's NYSIIS scheme is reputed to be fairly popular. It is designed for
  English names, using a strict application of 1,2 and 3-letter substitutions.
  While simple enough, it does not appear particularly robust to common 
  variations (Peter/Pete = patar/pat; Christina/Kristina = chrast/crasta).
"""
function nysiis(str, len=6)

  lstr = prep(str)
  
  #Find/replace some initial leading/closing patterns.
  nysiis_pre_find = [r"^mac", r"^kn", r"^k", r"p[hf]", r"^sch", r"e[ie]$", r"[drn]t$|[rn]d$"]
  nysiss_pre_repl = ["mcc", "n", "c", "ff", "sss", "y", "d"]
  lstr = replace_all(lstr, nysiis_pre_find, nysiss_pre_repl)
  

  #Find/replace rest of rules.
  #Oddly, these duplicate some work which is done in the prefix.
  nysiis_find = ["ev", r"[eiou]", 'q', 'z', r"m|kn", 'k', "sch", "ph", r"([^aeiou])h(.+)|(.+)h([^aeiou])", r"([^aeiou])h$", r"([aeiou])w", r"[as]{1,2}$", r"ay$"]
  nysiis_repl = ["af", 'a', 'g', 's', 'n', 'c', "sss", "ff", s"\1\2", s"\1", s"\1a", "", "y"]
  body = replace_all(lstr[2:end], nysiis_find, nysiis_repl)
  
  #remove duplicates
  body = squash(body)

  #Add first letter back on
  return join([lstr[1], body[1:min(len-1,end)]])
end


"""
  double_metaphone(str)

  Transforms a word into its Double-Metaphone reresentation.

  One of the issues often noted with Metaphone (and indeed other phonetic
  encoding schemes) is the dubious applicability to non-English names. The 
  Double-Metaphone scheme tries to account for this, using a very large set
  of hand-crafted rules to reflex a varied set of European and Asian 
  pronunciations.

  The technique is known as the 'Double' because it uses two alternative 
  strings to represent a word. If the two representations turn out to be
  equivalent, both are returned, and should used as alternate keys.

  As such, this function returns either a UTF8String[rep1, rep2], or a single
  UTF8String. 
  
  NB: This implementation is based on another implementation in a different 
  language, and some of the logic is speculative. It has been tested,
  but probably not enough. 
"""
function double_metaphone(str)

  lstr = prep(str)

  #Table of search patterns
  s_find = [r"^ps|^x", r"^sugar", r"sh(o[le][mzk]|eim)", "sh", r"si[oa]", r"^sm", r"^s([nlw])", r"sz|sc[eiy]", r"sche([rn])", r"sch([aeiou])", r"^sch([^aeiouw])", r"sc"]
  j_find = [r"^jose", "r^ja", r"j$", 'j', r"^[gkp]n",r"wr","mb"]
  c_find = [r"([^aeiou]a)ch([^ie])",r"^cae",r"^chia",r"chae",r"^ch(arac|aris|or[^e]|ym|ia|em)",r"([ao]r)ch(.[std])|([aoue^])ch(.[ts])",r"^ch([nrlmbhfvw])",r"^mc", r"cz", "ccia",  r"(^a|u)cc([eih][^u])", r"cc([eih][^u])",r"c[ckgq]", r"ci([aeo])", r"c([iey])", r"([^^][^m])c","ch", "c"]
  d_find = [r"dg[iey]", "dg",r"d[dt]?",]
  g_find = [r"([^aeiou])gh", r"^ghi", "^gh", r"([bhd].{1,3})gh", r"([trlcg].u)gh", r"([^^])gh([^i])",r"^ogn", r"gn(e?y)", "gn", "gli",r"^g[eiy]([spblyn])",r"([drm][aou])ng(er|e?y)", r"([or])gy", r"g(e?[ry])","gier",r"g([iey])t", r"g([iey])", 'g']
  h_find = [r"([^^aeiou])h([^aeiou])", r"([ia])ll([eao])$", "ph", "pb", 'q']
  dbmeta_find = vcat(j_find, s_find, c_find, d_find , g_find, h_find, [r"([^m][^ae])ier",r"([yi])sl",  r"([oa]i)s", "tion", r"tia|tch", r"^th([oa])m", "th", "v", r"^w[aeiou]", r"([aeiou])w(sk[iy]|$)?", r"wi[ct]z", r"([ie][oa]u)x", "zh", r"z([oia])"])


  #Table of replacements
  s_repl = ["s", "sugar", s"s\1", "x", "s", "sm", s"s\1", "s", s"xe\1", s"sk\1", s"x\1", "sk"]
  j_repl = ["hose", "ja", "j", "j","n","r","m"]
  c_repl = [s"\1k\2","sae","kia","kae",s"k\1",s"\1k\2", s"kr", "mk","s","xa", s"\1ks\2", s"x\1", "k", s"s\1","s", s"\1x","x","k"]
  d_repl = ["j","tk","t"]
  g_repl = [s"\1k", "ji", "k", s"\1", s"\1f", s"\1k\2","okn", s"kn\1", "n", "kli", s"k\1", s"\1nj\2", s"\1jy", s"k\1","jier", s"k\1t", s"j\1", "k"]
  h_repl = ["", s"\1l\2", "f","p","k"]
  dbmeta_repl = vcat(j_repl, s_repl, c_repl, d_repl, g_repl, h_repl, [s"\1ie", s"\1l", s"\1", "xn", "x", s"t\1m", "ø", "f", "a", "", "ts", "", s"\1ks", "j", "ts\1"])
  
  #Table of alternative replacements
  s_alt = ["s", "xugar", s"s\1", "x", "x", "xm", s"x\1", "s", s"ske\1", s"sk\1", s"s\1", "sk"]
  j_alt = ["hose", "a", "", "h", "n","r","m"]
  c_alt = [s"\1k\2", "sae", "kia", "xae", s"k\1", s"\1k\2", s"kr", "mk", "x", "xa", s"\1ks\2", s"x\1", "k", s"x\1","s", s"\1k", "x", "k"]
  d_alt = ["j","tk","t"]
  g_alt = [s"\1k", "ji", "k", s"\1", s"\1f", s"\1k\2","on", s"kn\1", "kn", "li", s"j\1", s"\1nj\2", s"\1jy", s"k\1", "jier", s"k\1t", s"k\1", "k"]
  h_alt = ["", s"\1\2", "f","p","k"]
  dbmeta_altr = vcat(j_alt, s_alt, c_alt, d_alt, g_alt, h_alt, [s"\1ie", s"\1l",  "s", "xn", "x", s"t\1m", "t","f", "f", "f", "fx", s"\1ks", "j", "s\1"])

  #Apply replacements
  astr = replace_all(lstr, dbmeta_find, dbmeta_altr)
  lstr = replace_all(lstr, dbmeta_find, dbmeta_repl)
                                   
  #Handle leading and other vowels
  lstr = replace(lstr, r"^[aeiouy]", "a")
  astr = replace(astr, r"^[aeiouy]", "a")
  lstr = replace(lstr, r"([^^])[aeiouyw]+", s"\1")
  astr = replace(astr, r"([^^])[aeiouyw]+", s"\1")

  #If the results are the same, return only one string.
  cmbi = [lstr, astr]
  cmbi = map(squash, cmbi)
  if cmbi[1] == cmbi[2]
    return cmbi[1]
  end
  #Else, return both options.
  return cmbi
end


"""
  match_rating_encode(str)

  Transform a string into the representation used for the Match Rating Approach.

  This is the string encoding system used within the Western Airlines 'Match Rating'
  algorithm. It is a small set of simple transforms, most of which appear in other
  schemes.

  - For a similarity measure between two strings, use match_rating(onestr, twostr).
  - For an automatic binary response about the closeness of strings, call 
"""
function match_rating_encode(str)
  lstr = prep(str)
  
  #replace non-leading vowels
  lstr = join([lstr[1], replace(lstr[2:end], r"[aeiou]+", "")])

  #remove duplicate consonants
  lstr = squash(lstr)
  
  #return 6 chars, 1:3 and end-3:end (if there are 6 chars). 
  if length(lstr) > 6
   lstr = join([lstr[1:3],lstr[end-3:end]])
  end
  return lstr
end


"""
  match_rating(onestr, twostr)

  Return the similarity measure between two strings as an integer 0:6.

  The higher output is better. Typically, it would be compared against a table
  of minimum match ratings, based on the original length of the strings. This
  is implemented in meets_match_rating(onestr, twostr).

  - For the encoding used by the system, call match_rating_encode(str) 
  - For an automatic binary response about the closeness of strings, call 
    meets_match_rating(onestr, twostr)
"""
function match_rating(onestr, twostr)

  #encode input
  ionestr = match_rating_encode(onestr)
  itwostr = match_rating_encode(twostr)

  #Remove identical characters in encoded string
  unmatchedone, unmatchedtwo = reversed_non_matching(ionestr, itwostr)

  #Remove identical characters in leftovers
  reunmatchedone, reunmatchedtwo = reversed_non_matching(unmatchedone, unmatchedtwo)

  #Pick longest string
  cmpstr = reunmatchedone 
  if length(reunmatchedone) < length(reunmatchedtwo)
    cmpstr = reunmatchedtwo
  end
  
  #Return 6-remaining error count
  return 6-length(cmpstr)
end
    

"""
  meets_match_rating(onstr, twostr)

  Returns a Bool indicating whether two strings are sufficiently similar to be
  matched, according the the Match Rating Approach. 

  A match rating value from match_rating(onestr, twostr) is compared to a minimum 
  rating threshold based on the combined length of the input strings.

  - For the actual similarity measure, use match_rating(onestr, twostr).
  - For the encoding used by the system, call match_rating_encode(str) 
"""
function meets_match_rating(onestr, twostr)

  ionestr = match_rating_encode(onestr)
  itwostr = match_rating_encode(twostr)

  #If length difference is 3 or greater, no comparison.
  if abs(length(ionestr) - length(itwostr)) > 2
    return -1
  end

  rating(x) = if x <= 4
      return 5
    elseif x <= 7
      return 4
    elseif x <= 12
      return 3
    else
      return 2
  end
  
  #calculate minimum rating based on length
  lensum = length(ionestr) + length(itwostr)
  minrating = rating(lensum)
  
  #get similarity of strings
  similarity = match_rating(onestr, twostr)
  
  #return comparison
  return similarity >= minrating
end


export soundex, metaphone, phonex, phonix, nysiis, double_metaphone, match_rating_encode, match_rating, meets_match_rating, reversed_non_matching

end
