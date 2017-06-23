" Returns the difference between two strings, in
  reverse order to the input. "
function reversed_non_matching(ionestr::String, itwostr::String)
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
 

" Table lookup which builds an array, checking all the bins. "
function table_lookup_plural(chr::Char, table::Array{String, 1})
  return map(x -> '0'+x, filter(pos -> chr in table[pos], 1:length(table)))
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
function match_rating(onestr::String, twostr::String)

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
  `meets_match_rating(onestr, twostr)`

  Returns a Bool indicating whether two strings are sufficiently similar to be
  matched, according the the Match Rating Approach. 

  A match rating value from `match_rating(onestr, twostr)` is compared to a minimum 
  rating threshold based on the combined length of the input strings.

  - For the actual similarity measure, use `match_rating(onestr, twostr)`.
  - For the encoding used by the system, call `match_rating_encode(str)` 
"""
function meets_match_rating(onestr::String, twostr::String)

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
  `editex(onestr, twostr)`

  Return the Editex distance between two strings.

  Editex is an approximate phonetic string comparison algorithm. It can be 
  thought of as a kind of combination of Soundex and edit distance, though
  the table used differs from that of Soundex and the edit distance cost is
  calculated differently.

  In brief, a dynamic programming solution is used to minimise the edit cost,
  which is comprised at base of:

  - `0` where two characters are the same.
  - `1` where two characters are from the same phonetic group.
  - `2` otherwise.

  Complexity will be `O(mn)` for lengths `m` and `n` of input strings.

  See also: `code_similarity`.
"""
function editex(onestr::String, twostr::String)
  
  #Prepare soundexily
  ionestr = prep(onestr)
  itwostr = prep(twostr)

  l1 = length(ionestr)
  l2 = length(itwostr)

  editcost = editex_internal(l1, l2, ionestr, itwostr)
  return editcost
end

editex_table = ["aeiouwy", "bp", "ckq", "dt", "lr", "mn", "gj", "fpv", "sxz", "csz"]

" r-hand-side of editex internals "
function editex_r(charone, chartwo)
  if charone == chartwo
    return 0
  elseif length(intersect(table_lookup_plural(charone, editex_table), table_lookup_plural(chartwo, editex_table))) > 0
    return 1
  else 
    return 2
  end
end

" d-hand side of editex internals. Mostly identical."
function editex_d(charone, chartwo)
  if charone == chartwo
    return 0
  elseif charone in "hw" || length(intersect(table_lookup_plural(charone, editex_table), table_lookup_plural(chartwo, editex_table))) > 0
    return 1
  else 
    return 2
  end
end

" Dynamic programming implementation. "
function editex_internal(i, j, onestr, twostr)
  #terminate at start of strings
  if i == j && i == 1
    # Cost of both deletions (other move) would always be >= cost of comparison. 
    return editex_r(onestr[i], twostr[j]) 
  #finished one string, eat other
  elseif j == 1
    return editex_internal(i - 1, 1, onestr, twostr) + editex_d(onestr[i-1], onestr[i])
  #finished the other
  elseif i == 1
    return editex_internal(1, j - 1, onestr, twostr) + editex_d(twostr[j-1], twostr[j])
  # minimum of deleting from either string or cost of cross-comparison
  else
    return min(editex_internal(i - 1, j, onestr, twostr) + editex_d(onestr[i-1], onestr[i]),
               editex_internal(i, j - 1, onestr, twostr) + editex_d(twostr[j-1], twostr[j]),
               editex_internal(i - 1, j - 1 , onestr, twostr) + editex_r(onestr[i], twostr[j]))
  end
end

export match_rating, meets_match_rating, editex
