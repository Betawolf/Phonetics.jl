module phonics

" Looks up character against Soundex classes, returns integer code as Char, or
  else ' ' if character was not found. "
function soundex_table(chr)
  table = ["aehiouwy", "bfpv", "cgjkqsxz", "dt", "l", "mn", "r"]
  for pos in 1:length(table)
    if chr in table[pos]
        return Char('0'+(pos-1))
    end
  end
  return ' '
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
 
"""
  soundex(str)

  Transforms a string into its Soundex code. """
function soundex(str)
  lstr = lowercase(str)

  #Look up soundex coding for 2:end
  body = map(soundex_table, lstr[2:end])
  
  #Remove 0's 
  body = join(split(body, '0')) 

  #Squash repetitions.
  body = squash(body)

  #Pad with 0's
  body = body * "000"
  
  #Join first letter with trimmed body.
  return join([string(lstr[1]), body[1:3]])
end

export soundex, squash

end
