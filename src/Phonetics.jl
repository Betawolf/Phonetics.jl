module Phonetics

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
  `soundex(str)`

  Transforms a string into its Soundex code.

  The Russell Soundex code is designed primarily for use with English names and has some
  known drawbacks, including a sensitivity to the first letter of a name (Christina is `c623`
  and similar Kristina is `k623`) and loss of some audible differences (Kant and Knuth, `k530`).
  The resulting code is always 1-letter and 3-digits. 
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
  fuzzy_soundex(str)

  Transforms a string into its Fuzzy Soundex code.

  The Fuzzy Soundex was an attempt to improve the reliability of Soundex. Like
  Phonex, it introduces some multi-character replacements as a prelude to a lookup
  table. Unlike Soundex, Phonex or Phonix, Fuzzy Soundex has a 1-letter 4-digit key.
"""
function fuzzy_soundex(str)

  lstr = prep(str)
  
  #replace digrams
  fs_find = ["ca", r"c[ck]", "ce",r"ch$",r"ch?l",r"ch?r","ci","co",r"^[ct][sz]","cu","cy","dg","gh",r"^gn",r"^[hw]r", r"^hw", r"^kn|ng", "ma?c","nst",r"^nt",r"p[fh]",r"rd?t$","sch",r"ti[ao]","tch"]
  fs_repl = [s"ka", s"kk", s"se","kk", s"kl","kr","si","ko","ss","ku","sy","gg","hh","nn","rr","ww","nn","mk","nss","tt","ff","rr","sss","sio","chh"]
  lstr = replace_all(lstr, fs_find, fs_repl)

  #crazy-ass fuzzy soundex table
  fuzzy_soundex_table = ["aehiouwy", "bfpv", "", "dt", "l", "mn", "r", "gkjqx", "", "csz"]
  body = map(x -> table_lookup(x, fuzzy_soundex_table), lstr[2:end])
  
  #remove duplicates
  body = squash(body)

  #Remove 0's 
  body = join(split(body, '0')) 

  #Pad with 0's
  body = body * "000"
 
  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:4]])
end
  


"""
  `code_similarity(onestr, twostr, code=fuzzy_soundex)`

  Produce a similarity estimate based on string comparison of the result of
  coding the two input strings.
  
  `code` can be any of: `soundex`, `phonex`, `phonix`, `[fuzzy_soundex]`, `nysiis`,
  `metaphone`, `match_rating_encode`

  This comparison function was originally used by the authors of Fuzzy Soundex.
"""
function code_similarity(onestr, twostr, code=fuzzy_soundex)
  #encode strings
  ionestr = code(onestr)
  itwostr = code(twostr)

  l1 = length(ionestr)
  l2 = length(itwostr)

  common = 0
  for i in 1:min(l1,l2)
    if ionestr[i] == itwostr[i]
      common += 1
    end
  end
  
  ð = (2*common)/(l1+l2)
  return ð
end



"""
  `phonex(str)`
  
  Transforms a string into its Phonex code.

  Lait & Randell's Phonex encoding scheme can be viewed as an improved version
  of Soundex. Like Soundex, it produces a 1-letter 3-digit code, but a range
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
  phonex_pre_repl = [s"n", s"f", s"r", s"", s"a", s"b", s"f", s"c", s"g","s"]
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
  `metaphone(str, len=4)`

  Transforms a word into its Metaphone reresentation.

  Lawrence Phillips' Metaphone technique is applicable to a range of sound-alike
  words. It produces a code which uses a sixteen-character alphabet, with 'x' for
  'sh' sounds and 'ø' for 'th' sounds, and no vowels apart from where they are the
  first letter. In some cases, such as the word 'persuade', its representation may 
  be unintuitive regarding pronunciation. 

  For comparison purposes, 4 characters are usually used, but you may vary the 
  returned length `len` if you wish for a longer representation. 
"""
function metaphone(str,len=4)
  
  lstr = prep(str)
  
  #substitution rules
  metaphone_find = [r"^x",  r"x",  r"mb",  r"sch",  r"t?ch|sh",  r"cia|[st]i[ao]",  r"s?c([eiy])(.+)",  r"(.+)dg([eiy])",  r"d", r"gh([^aeiou$])",  r"gn$",  r"gned$",  r"c|g|q",  r"ph|v",  r"th",  r"^wh",  r"[wy]([^aeiou])",  r"z",  r"^[gk]n",  r"^pm"]
  metaphone_repl = [s"s",  s"ks",  s"m",  s"sk",  s"x",  s"xa",  s"s\1\2", s"\1j\2",  s"t", s"h\1",  s"n",  s"ned", s"k",  s"f", s"0", s"w", s"\1", s"s",  s"n",  s"m"]
  lstr = replace_all(lstr, metaphone_find, metaphone_repl)
  
  #remove duplicates
  lstr = squash(lstr)

  #remove vowels apart from the first
  lstr = replace(lstr, r"([^^])[aeiou]+", s"\1")

  #fix theta
  lstr = replace(lstr, "0", "ø")
  
  #return first len letters (if that many)
  return lstr[1:min(len,end)]
end
  

"""
  `phonix(str)`

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
  `nysiis(str, len=6)`
  
  Transform a string according to the New York State Identification and 
  Intelligence System (NYSIIS) encoding scheme. 

  Taft's NYSIIS scheme is reputed to be fairly popular. It is designed for
  English names, using a strict application of 1,2 and 3-letter substitutions.
  While simple enough, it does not appear particularly robust to common 
  variations (Peter/Pete = `patar`/`pat`; Christina/Kristina = `chrast`/`crasta`).
"""
function nysiis(str, len=6)

  lstr = prep(str)
  
  #Find/replace some initial leading/closing patterns.
  nysiis_pre_find = [r"^mac", r"^kn", r"^k", r"p[hf]", r"^sch", r"e[ie]$", r"[drn]t$|[rn]d$"]
  nysiss_pre_repl = [s"mcc", s"n", s"c", s"ff", s"sss", s"y", s"d"]
  lstr = replace_all(lstr, nysiis_pre_find, nysiss_pre_repl)
  

  #Find/replace rest of rules.
  #Oddly, these duplicate some work which is done in the prefix.
  nysiis_find = ["ev", r"[eiou]", 'q', 'z', r"m|kn", 'k', "sch", "ph", r"([^aeiou])h(.)|(.)h([^aeiou])", r"([^aeiou])h$", r"([aeiou])w", r"s$", r"a$", r"as$",r"ay$"]
  nysiis_repl = [s"af", s"a", s"g", s"s", s"n", s"c", s"sss", s"ff", s"\1\2", s"\1", s"\1a", s"", s"", s"", s"y"]
  body = replace_all(lstr[2:end], nysiis_find, nysiis_repl)
  
  #remove duplicates
  body = squash(body)

  #Add first letter back on
  return join([lstr[1], body[1:min(len-1,end)]])
end


"""
  `double_metaphone(str)`

  Transforms a word into its Double-Metaphone reresentation.

  One of the issues often noted with Metaphone (and indeed other phonetic
  encoding schemes) is the dubious applicability to non-English names. The 
  Double-Metaphone scheme tries to account for this, using a very large set
  of hand-crafted rules to reflex a varied set of European and Asian 
  pronunciations.

  The technique is known as the 'Double' because it uses two alternative 
  strings to represent a word. If the two representations turn out to be
  equivalent, both are returned, and should used as alternate keys.

  As such, this function returns either a `UTF8String[rep1, rep2]`, or a single
  `UTF8String`. 
  
  NB: This implementation is based on another implementation in a different 
  language, and some of the logic is speculative. It has been tested,
  but probably not enough. 
"""
function double_metaphone(str)

  lstr = prep(str)

  #Table of search patterns
  s_find = [r"^ps|^x", r"^sugar", r"sh(o[le][mzk]|eim)", "sh", r"si[oa]", r"^sm", r"^s([nlw])", r"sz|sc[eiy]", r"sche([rn])", r"sch([aeiou])", r"^sch([^aeiouw])", r"sc"]
  j_find = [r"^jose", r"^ja", r"j$", 'j', r"^[gkp]n",r"wr","mb"]
  c_find = [r"([^aeiou]a)ch([^ie])",r"^cae",r"^chia",r"chae",r"^ch(arac|aris|or[^e]|ym|ia|em)",r"([ao]r)ch(.[std])", r"([aoue]|^)ch([nrlmbhfvw])",r"^mc", r"wi[ct]z", r"cz", "ccia",  r"(^a|u)cc([eih][^u])", r"cc([eih][^u])",r"c[ckgq]", r"ci([aeo])", r"c([iey])", "ch",r"([^^][^m])c", "c"]
  d_find = [r"dg[iey]", "dg",r"d[dt]?", r"([^m][^ae])ier",r"([yi])sl"]
  g_find = [r"([^aeiou])gh", r"^ghi", r"^gh", r"([bhd].{1,3})gh", r"([trlcg].u)gh", r"([^^i])gh", "gh", r"^ogn", r"gn(e?y)", "gn", "gli",r"^g[eiy]([spblyn])",r"([drm][aou])ng(er|e?y)", r"([or])gy", r"g(e?[ry])","gier",r"g([iey])t", r"g([iey])", 'g']
  h_find = [r"([^^aeiou])h([^aeiou])", r"([ia])ll([eao])$", "ph", "pb", 'q']
  dbmeta_find = vcat(j_find, s_find, c_find, d_find , g_find, h_find, [r"([oa]i)s", "tion", r"tia|tch", r"^th([oa])m", "th", "v", r"^w[aeiou]", r"^wh", r"([aeiou])w(sk[iy]|$)?",  r"([ie][oa]u)x", "zh", r"z([oia])"])


  #Table of replacements
  s_repl = [s"s", s"sugar", s"s\1", s"x", s"s", s"sm", s"s\1", s"s", s"xe\1", s"sk\1", s"x\1", s"sk"]
  j_repl = [s"hose", s"ja", s"j", s"j", s"n", s"r", s"m"]
  c_repl = [s"\1k\2", s"sae", s"kia", s"kae",s"k\1",s"\1k\2", s"\1k\2", s"mk", s"ts", s"s", s"xa", s"\1ks\2", s"x\1", s"k", s"s\1", s"s", s"x", s"\1x", s"k"]
  d_repl = [s"j",s"tk",s"t", s"\1ie", s"\1l"]
  g_repl = [s"\1k", s"ji", s"k", s"\1", s"\1f", s"\1k", s"", s"okn", s"kn\1", s"n", s"kli", s"k\1", s"\1nj\2", s"\1jy", s"k\1",s"jier", s"k\1t", s"j\1", s"k"]
  h_repl = [s"\1\2", s"\1l\2", s"f",s"p",s"k"]
  dbmeta_repl = vcat(j_repl, s_repl, c_repl, d_repl, g_repl, h_repl, [s"\1", s"xn", s"x", s"t\1m", s"0", s"f", s"a", s"a", s"",  s"", s"\1ks", s"j", s"ts\1"])
  
  #Table of alternative replacements
  s_alt = [s"s", s"xugar", s"s\1", s"x", s"x", s"xm", s"x\1", s"s", s"ske\1", s"sk\1", s"s\1", s"sk"]
  j_alt = [s"hose", s"a", s"", s"h", s"n",s"r",s"m"]
  c_alt = [s"\1k\2", s"sae", s"kia", s"xae", s"k\1", s"\1k\2", s"\1k\2", s"mk", s"fx", s"x", s"xa", s"\1ks\2", s"x\1", s"k", s"x\1",s"s", s"x", s"\1k", s"k"]
  d_alt = [s"j",s"tk",s"t", s"\1ier", s"\1l"]
  g_alt = [s"\1k", s"ji", s"k", s"\1", s"\1f", s"\1k", s"", s"on", s"kn\1", s"kn", s"li", s"j\1", s"\1nj\2", s"\1jy", s"k\1", s"jier", s"k\1t", s"k\1", s"k"]
  h_alt = [s"\1\2", s"\1\2", s"f",s"p",s"k"]
  dbmeta_altr = vcat(j_alt, s_alt, c_alt, d_alt, g_alt, h_alt, [s"s", s"xn", s"x", s"t\1m", s"t",s"f", s"f", s"a", s"f", s"\1ks", s"j", s"s\1"])

  #Apply replacements
  astr = replace_all(lstr, dbmeta_find, dbmeta_altr)
  lstr = replace_all(lstr, dbmeta_find, dbmeta_repl)

  lstr = squash(lstr)
  astr = squash(astr)
                                   
  #Handle leading and other vowels
  lstr = replace(lstr, r"^[aeiouy]", "a")
  astr = replace(astr, r"^[aeiouy]", "a")
  lstr = replace(lstr, r"([^^])[aeiouyw]+", s"\1")
  astr = replace(astr, r"([^^])[aeiouyw]+", s"\1")

  #fix theta
  lstr = replace(lstr, "0", "ø")

  #If the results are the same, return only one string.
  cmbi = [lstr, astr]
  if cmbi[1] == cmbi[2]
    return cmbi[1]
  end
  #Else, return both options.
  return cmbi
end


"""
  `match_rating_encode(str)`

  Transform a string into the representation used for the Match Rating Approach.

  This is the string encoding system used within the Western Airlines 'Match Rating'
  algorithm. It is a small set of simple transforms, most of which appear in other
  schemes.

  - For the similarity measure between two strings, use `match_rating(onestr, twostr)`

  - For an automatic binary response about the closeness of strings, call 
  `meets_match_rating(onestr, twostr)`
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
  `match_rating(onestr, twostr)`

  Return the similarity measure between two strings as an integer `0:6`.

  The higher output is better. Typically, it would be compared against a table
  of minimum match ratings, based on the original length of the strings. This
  is implemented in `meets_match_rating(onestr, twostr)`.

  If the length of the two strings differs by more than `2`, the result will be
  `-1`.

  - For the encoding used by the system, call `match_rating_encode(str)` 

  - For an automatic binary response about the closeness of strings, call 
    `meets_match_rating(onestr, twostr)`
"""
function match_rating(onestr, twostr)

  #encode input
  ionestr = match_rating_encode(onestr)
  itwostr = match_rating_encode(twostr)

  #If length difference is 3 or greater, no comparison.
  if abs(length(ionestr) - length(itwostr)) > 2
    return -1
  end

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
  `meets_match_rating(onstr, twostr)`

  Returns a Bool indicating whether two strings are sufficiently similar to be
  matched, according the the Match Rating Approach. 

  A match rating value from `match_rating(onestr, twostr)` is compared to a minimum 
  rating threshold based on the combined length of the input strings.

  - For the actual similarity measure, use `match_rating(onestr, twostr)`.
  - For the encoding used by the system, call `match_rating_encode(str)` 
"""
function meets_match_rating(onestr, twostr)

  ionestr = match_rating_encode(onestr)
  itwostr = match_rating_encode(twostr)

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


"""
  `caverphone(str)`

  Transforms a string into its Caverphone representation.

  David Hood's Caverphone algorithm was designed to assist in matching between
  electoral rolls in New Zealand, and is optimised for local accents. The output
  of the algorithm is a six-character code, with the final characters being padded
  with '1's in the case where the transformed string would otherwise have been 
  shorter. 
"""
function caverphone(str)

  lstr = prep(str)

  #Apply the caverphone replacements
  cp_find = [r"^([crt]|en)ough", r"^gn", r"mb$", "cq", r"c([iey])", "tch", r"[cqx]", "v", "dg", r"ti([ao])", "d", "ph", "b", "sh", "z", r"[eioua]", r"^3",  "3gh3", "gh", "g", r"([stkfmn])+", r"w(h?[3y])", "w",r"^h", "h", "r([3y])", "r", r"l([3y])", "l", "j", "y3", "y"]
  cp_repl = [ s"\g<1>u2f", s"2n", s"m2", s"2q", s"s\1", s"2ch", s"k", s"f", s"2g", s"si\1", s"t", s"fh", s"p", s"s2", s"s", s"3", s"a", s"3kh3", s"22", s"k", s"\1", s"W\1", s"2", s"a", s"2", s"R\1", s"2", s"L\1", s"2", s"y",s"Y3",s"2"]
  lstr = replace_all(lstr, cp_find, cp_repl)

  #re-lower the string for consistency
  lstr = lowercase(lstr)
  
  #remove 2/3
  lstr = replace(lstr, r"[23]+", "")
  
  #pad
  lstr = lstr * "111111"

  #return first 6
  return lstr[1:6]
end

export soundex, metaphone, phonex, phonix, nysiis, double_metaphone, match_rating_encode, match_rating, meets_match_rating, fuzzy_soundex, code_similarity, caverphone

end
