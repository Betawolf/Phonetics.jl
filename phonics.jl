module phonics

" Looks up character against Soundex classes, returns integer code as Char, or
  else ' ' if character was not found. "
function table_lookup(chr, table)
  for pos in 1:length(table)
    if chr in table[pos]
        return Char('0'+(pos-1))
    end
  end
  return chr
end

" Replace all the 'find' patterns with the corresponding 'replace' strings. "
function replace_all(str, from, to)
  nstr = str
  for pos in 1:length(from)
    nstr = replace(nstr, from[pos], to[pos])
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
  nysiis_find = ["ev", r"[eiou]", 'q', 'z', r"m|kn", 'k', "sch", "ph", r"([^aeiou])h(.+)|(.+)h([^aeiou])", r"([^aeiou])h$", r"([aeiou])w", r"[as]$", r"ay$"]
  nysiis_repl = ["af", 'a', 'g', 's', 'n', 'c', "sss", "ff", s"\1\2", s"\1", s"\1a", "", "y"]
  body = replace_all(lstr[2:end], nysiis_find, nysiis_repl)
  
  #remove duplicates
  body = squash(body)

  #Add first letter back on
  return join([lstr[1], body[1:min(len-1,end)]])
end


export soundex, metaphone, phonex, phonix, nysiis

end
