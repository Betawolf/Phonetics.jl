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
  

function phonix(str)
  phonix_table = ["aehiouwy", "bp", "cgjkq", "dt", "l", "mn", "r", "fv", "sxz"]
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
  

export soundex, metaphone, phonex

end
