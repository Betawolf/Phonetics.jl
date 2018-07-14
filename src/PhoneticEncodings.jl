
" Looks up character against input classes, returns integer code as Char, or
  else the input if the character was not found. "
function table_lookup(chr::Char, table::Array{String, 1})
  for pos in 1:length(table)
    if chr in table[pos]
        return Char('0'+(pos-1))
    end
  end
  return chr
end

" Replace all the 'find' patterns with the corresponding 'replace' strings. "
function replace_all(str::String, from::Array{Regex,1}, to::Array{Base.SubstitutionString{String}, 1}, display=false::Bool)
  nstr = str
  for pos in 1:length(from)
    nstr = replace(nstr, from[pos] => to[pos])
    if display
      println(nstr, " = ", from[pos], " :: ", to[pos])
    end
  end
  return nstr
end

" 'Squashes' a string by reducing any repeated characters to only one instance. "
function squash(str::String)
  lc = '\0'
  return filter(str) do x
          if x != lc
           lc = x
           return true
          end
          return false
         end
end

" Lowercase and strip non-alpha chars from a word. Naturally asciifies it. "
function prep(str::String)
  return ascii(replace(lowercase(str), r"[^a-z]" => ""))
end




"""
  `soundex(str)`

  Transforms a string into its Soundex code.

  The Russell Soundex code is designed primarily for use with English names and has some
  known drawbacks, including a sensitivity to the first letter of a name (Christina is `c623`
  and similar Kristina is `k623`) and loss of some audible differences (Kant and Knuth, `k530`).
  The resulting code is always 1-letter and 3-digits.
 """
function soundex(str::String)
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
function fuzzy_soundex(str::String)

  lstr = prep(str)

  #replace digrams
  fs_find = [r"ca", r"c[ck]", r"ce",r"ch$",r"ch?l",r"ch?r",r"ci",r"co",r"^[ct][sz]",r"cu",r"cy",r"dg",r"gh",r"^gn",r"^[hw]r", r"^hw", r"^kn|ng", r"ma?c",r"nst",r"^nt",r"p[fh]",r"rd?t$",r"sch",r"ti[ao]",r"tch"]
  fs_repl = [s"ka", s"kk", s"se",s"kk", s"kl",s"kr",s"si",s"ko",s"ss",s"ku",s"sy",s"gg",s"hh",s"nn",s"rr",s"ww",s"nn",s"mk",s"nss",s"tt",s"ff",s"rr",s"sss",s"sio",s"chh"]
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
  return join([string(lstr[1]), body[1:min(4,end)]])
end


"""
  `phonex(str)`

  Transforms a string into its Phonex code.

  Lait & Randell's Phonex encoding scheme can be viewed as an improved version
  of Soundex. Like Soundex, it produces a 1-letter 3-digit code, but a range
  of modifications make it more resiliant to encoding errors involving the first
  character of a word, as well as other issues caused by interactions between
  characters within the rest of the word. """
function phonex(str::String)

  lstr = prep(str)

  # remove trailing s
  if lstr[end] == 's'
    lstr = lstr[1:end-1]
  end

  #Remove duplicates
  lstr = squash(lstr)

  #Find/replace leading patterns
  phonex_pre_find = [r"^kn", r"^ph", r"^wr", r"^h", r"^[eiouy]", r"^p", r"^v", r"^[kq]", r"^j", r"^z"]
  phonex_pre_repl = [s"n", s"f", s"r", s"", s"a", s"b", s"f", s"c", s"g",s"s"]
  lstr = replace_all(lstr, phonex_pre_find, phonex_pre_repl)

  #Preparatory find/replace for main coding.
  phonex_main_find = [r"[dt]c",r"[lr]([^aeiou$])",r"([mn])g",r"a|e|h|i|o|u|w|y",r"a+"]
  phonex_main_repl = [s"c",s"\1", s"\1",s"a",s""]
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
  `phonix(str)`

  Transforms a string into its Phonix code.

  T. N. Gadd's Phonix encoding scheme is based on the Soundex scheme, and is
  similar to the related Phonex scheme. The Phonix scheme uses a large set of
  hand-crafted rules specific to English text and pronunciation. A performance
  penalty might be expected as a result of this large ruleset.
"""
function phonix(str::String)

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
  body = replace(body, r"0+" => "")

  #Pad with 0's
  body = body * "000"

  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:3]])
end


"""
  `nysiis(str[, len=6])`

  Transform a string according to the New York State Identification and
  Intelligence System (NYSIIS) encoding scheme.

  Taft's NYSIIS scheme is reputed to be fairly popular. It is designed for
  English names, using a strict application of 1,2 and 3-letter substitutions.
  While simple enough, it does not appear particularly robust to common
  variations (Peter/Pete = `patar`/`pat`; Christina/Kristina = `chrast`/`crasta`).
"""
function nysiis(str::String, len=6)

  lstr = prep(str)

  #Find/replace some initial leading/closing patterns.
  nysiis_pre_find = [r"^mac", r"^kn", r"^k", r"p[hf]", r"^sch", r"e[ie]$", r"[drn]t$|[rn]d$"]
  nysiss_pre_repl = [s"mcc", s"n", s"c", s"ff", s"sss", s"y", s"d"]
  lstr = replace_all(lstr, nysiis_pre_find, nysiss_pre_repl)


  #Find/replace rest of rules.
  #Oddly, these duplicate some work which is done in the prefix.
  nysiis_find = [r"ev", r"[eiou]", r"q", r"z", r"m|kn", r"k", r"sch", r"ph", r"([^aeiou])h(.)|(.)h([^aeiou])", r"([^aeiou])h$", r"([aeiou])w", r"s$", r"a$", r"as$",r"ay$"]
  nysiis_repl = [s"af", s"a", s"g", s"s", s"n", s"c", s"sss", s"ff", s"\1\2", s"\1", s"\1a", s"", s"", s"", s"y"]
  body = replace_all(lstr[2:end], nysiis_find, nysiis_repl)

  #remove duplicates
  body = squash(body)

  #Add first letter back on
  return join([lstr[1], body[1:min(len-1,end)]])
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
function caverphone(str::String)

  lstr = prep(str)

  #Apply the caverphone replacements
  cp_find = [r"^([crt]|en)ough", r"^gn", r"mb$", r"cq", r"c([iey])", r"tch", r"[cqx]", r"v", r"dg", r"ti([ao])", r"d", r"ph", r"b", r"sh", r"z", r"[eioua]", r"^3",  r"3gh3", r"gh", r"g", r"([stkfmn])+", r"w(h?[3y])", r"w",r"^h", r"h", r"r([3y])", r"r", r"l([3y])", r"l", r"j", r"y3", r"y"]
  cp_repl = [ s"\g<1>u2f", s"2n", s"m2", s"2q", s"s\1", s"2ch", s"k", s"f", s"2g", s"si\1", s"t", s"fh", s"p", s"s2", s"s", s"3", s"a", s"3kh3", s"22", s"k", s"\1", s"W\1", s"2", s"a", s"2", s"R\1", s"2", s"L\1", s"2", s"y",s"Y3",s"2"]
  lstr = replace_all(lstr, cp_find, cp_repl)

  #re-lower the string for consistency
  lstr = lowercase(lstr)

  #remove 2/3
  lstr = replace(lstr, r"[23]+" => "")

  #pad
  lstr = lstr * "111111"

  #return first 6
  return lstr[1:6]
end


"""
  `metaphone(str[, len=4])`

  Transforms a word into its Metaphone reresentation.

  Lawrence Phillips' Metaphone technique is applicable to a range of sound-alike
  words. It produces a code which uses a sixteen-character alphabet, with 'x' for
  'sh' sounds and 'ø' for 'th' sounds, and no vowels apart from where they are the
  first letter. In some cases, such as the word 'persuade', its representation may
  be unintuitive regarding pronunciation.

  For comparison purposes, 4 characters are usually used, but you may vary the
  returned length `len` if you wish for a longer representation.
"""
function metaphone(str::String,len::Int=4)

  lstr = prep(str)

  #substitution rules
  metaphone_find = [r"^x",  r"x",  r"mb",  r"sch",  r"t?ch|sh",  r"cia|[st]i[ao]",  r"s?c([eiy])(.+)",  r"(.+)dg([eiy])",  r"d", r"gh([^aeiou$])",  r"gn$",  r"gned$",  r"c|g|q",  r"ph|v",  r"th",  r"^wh",  r"[wy]([^aeiou])",  r"z",  r"^[gk]n",  r"^pm"]
  metaphone_repl = [s"s",  s"ks",  s"m",  s"sk",  s"x",  s"xa",  s"s\1\2", s"\1j\2",  s"t", s"h\1",  s"n",  s"ned", s"k",  s"f", s"0", s"w", s"\1", s"s",  s"n",  s"m"]
  lstr = replace_all(lstr, metaphone_find, metaphone_repl)

  #remove duplicates
  lstr = squash(lstr)

  #remove vowels apart from the first
  lstr = replace(lstr, r"([^^])[aeiou]+" => s"\1")

  #return first len letters (if that many)
  return lstr[1:min(len,end)]
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

  As such, this function returns either an `String[rep1, rep2]`, or a single
  `String`.

  NB: This implementation is based on another implementation in a different
  language, and some of the logic is speculative. It has been tested,
  but probably not enough.
"""
function double_metaphone(str::String)

  lstr = prep(str)

  #Table of search patterns
  s_find = [r"^ps|^x", r"^sugar", r"sh(o[le][mzk]|eim)", r"sh", r"si[oa]", r"^sm", r"^s([nlw])", r"sz|sc[eiy]", r"sche([rn])", r"sch([aeiou])", r"^sch([^aeiouw])", r"sc"]
  j_find = [r"^jose", r"^ja", r"j$", r"j", r"^[gkp]n",r"wr",r"mb"]
  c_find = [r"([^aeiou]a)ch([^ie])",r"^cae",r"^chia",r"chae",r"^ch(arac|aris|or[^e]|ym|ia|em)",r"([ao]r)ch(.[std])", r"([aoue]|^)ch([nrlmbhfvw])",r"^mc", r"wi[ct]z", r"cz", r"ccia",  r"(^a|u)cc([eih][^u])", r"cc([eih][^u])",r"c[ckgq]", r"ci([aeo])", r"c([iey])", r"ch",r"([^^][^m])c", r"c"]
  d_find = [r"dg[iey]", r"dg",r"d[dt]?", r"([^m][^ae])ier",r"([yi])sl"]
  g_find = [r"([^aeiou])gh", r"^ghi", r"^gh", r"([bhd].{1,3})gh", r"([trlcg].u)gh", r"([^^i])gh", r"gh", r"^ogn", r"gn(e?y)", r"gn", r"gli",r"^g[eiy]([spblyn])",r"([drm][aou])ng(er|e?y)", r"([or])gy", r"g(e?[ry])",r"gier",r"g([iey])t", r"g([iey])", r"g"]
  h_find = [r"([^^aeiou])h([^aeiou])", r"([ia])ll([eao])$", r"ph", r"pb", r"q"]
  dbmeta_find = vcat(j_find, s_find, c_find, d_find , g_find, h_find, [r"([oa]i)s", r"tion", r"tia|tch", r"^th([oa])m", r"th", r"v", r"^w[aeiou]", r"^wh", r"([aeiou])w(sk[iy]|$)?",  r"([ie][oa]u)x", r"zh", r"z([oia])"])


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
  lstr = replace(lstr, r"^[aeiouy]" => "a")
  astr = replace(astr, r"^[aeiouy]" => "a")
  lstr = replace(lstr, r"([^^])[aeiouyw]+" => s"\1")
  astr = replace(astr, r"([^^])[aeiouyw]+" => s"\1")

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
function match_rating_encode(str::String)
  lstr = prep(str)

  #replace non-leading vowels
  lstr = string(lstr[1], replace(lstr[2:end], r"[aeiou]+" => ""))

  #remove duplicate consonants
  lstr = squash(lstr)

  #return 6 chars, 1:3 and end-3:end (if there are 6 chars).
  if length(lstr) > 6
   lstr = join([lstr[1:3],lstr[end-3:end]])
  end
  return lstr
end


"""
  `lein(str)`

  Transform a string into its Lein Technique representation.

  I could not find much on the origins of this technique, but
  from inspection of the algorithm it appears to be an early
  competitor of Soundex. Like Soundex, it uses no bigram information,
  and produces a 1-letter 3-number code.
"""
function lein(str::String)
  lstr = prep(str)

  #replace vowels and 'hwy'
  lstr = join([lstr[1], replace(lstr[2:end], r"[aeiouhwy]+" => "")])

  #remove duplicates and truncate
  lstr = squash(lstr)[1:min(4,end)]

  #perform table lookup
  lein_table = ["", "dt", "mn", "lr", "bfpv", "cjkgqs", "xz"]
  lstr = string(lstr[1], map(x -> table_lookup(x, lein_table), lstr[2:end]))

  #pad with 0s
  lstr = lstr * ("0" ^ max(0, 4 - length(lstr)))

  return lstr
end


"""
  `roger_root(str)`

  Transforms a string into its Roger Root representation.

  A rather mysterious encoding scheme, somewhat more exotic than the
  similarly-sourced `lein` algorithm. The Roger Root maps a combination
  of bigrams and single characters to one or two digit codes, resulting
  in a 5-digit code for each word.
"""
function roger_root(str::String)

  lstr = prep(str)

  rr_find = [r"^[aiou]", r"^[bp]", r"^(c[eiy]|t?s|z)", r"^t?[sc]{1,2}h", r"^([ckqx]|d?g)", r"^[dt]", r"^([gp]?f|ph|v)", r"^g?m", r"^[kgp]?n", r"^h", r"^j", r"^l", r"^w?r", r"^w", r"^y", r"[bp]+", r"(c[iey]|t?s|z)+", r"(t?[sc]{1,2}h|j)+", r"([ckqx]|d?g)+", r"([dt])+", r"([fv]|ph)+", r"l+", r"m+", r"n+", r"r+"]
  rr_repl = [s"1", s"09", s"00", s"06", s"07", s"01", s"08", s"03", s"02", s"2", s"3", s"05", s"04", s"4", s"5", s"9", s"0", s"6", s"7", s"1", s"8", s"5", s"3", s"2", s"4"]

  lstr = replace_all(lstr, rr_find, rr_repl)

  lstr = replace(lstr, r"[aeiouhwy]+" => "")

  lstr = lstr * "00000"

  return lstr[1:5]
end


"""
  `canada(str)`

  Transforms a string into its Census Modified Statistics Canada representation.

  This is an extremely simple code, merely removing vowels and squashing letters,
  with no replacements or mapping to digits.
"""
function canada(str::String)

  lstr = prep(str)

  lstr = squash(lstr)

  body = replace(lstr[2:end], r"[aeiouy]+" => "")

  return string(lstr[1], body)
end

export soundex, metaphone, phonex, phonix, nysiis, double_metaphone, match_rating_encode, fuzzy_soundex, caverphone, lein, roger_root, canada
