"""
  `code_similarity(onestr, twostr[, code=fuzzy_soundex])`

  Produce a similarity estimate based on string comparison of the result of
  coding the two input strings.

  `code` can be any of: `soundex`, `phonex`, `phonix`, `[fuzzy_soundex]`, `nysiis`,
  `metaphone` or `match_rating_encode`. Results from using `double_metaphone` may be
  misleading due to the double encoding of that system.

  This comparison function was originally used by the authors of Fuzzy Soundex. A similar
  but non-normalised comparison scheme exists for Soundex, see `editex`, and a specific
  comparison algorithm exists for `match_rating_encode`, see `match_rating`.
"""
function code_similarity(onestr::String, twostr::String, code=fuzzy_soundex)
  #encode strings
  ionestr = code(onestr)
  itwostr = code(twostr)

  return code_similarity_internal(ionestr, itwostr, code)
end

" Internal code similarity function (not for raw strings). "
function code_similarity_internal(ionestr::String , itwostr::String, code=fuzzy_soundex)

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
  `code_match(str, array[, code=fuzzy_soundex, permissive=0.0])`

  Returns those items in `array` which are phonetic matches to `str` according
  to the algorithm `code`.

  Matches are normally on exact codes. The `permissive` option allows you to set
  a lower threshold for comparison for most `code` options, using `code_similarity()`.
  The value should be in the range 0:1.  Permissive coding is not possible for
  `double_metaphone`.

  `match_rating_encode` will be treated like other codes rather than how it is used
  in the overall approach. Those wishing to match items according to that system can
  call

      filter(item -> meets_match_rating(str, item), array)

  instead.
"""
function code_match(str::String, array::Array{T,1}, code=fuzzy_soundex::Function, permissive=0.0::Float64) where {T<:String}

  #catch weird input
  if permissive > 1 || permissive < 0
    error("Permissive value must be in range 0:1")
  end

  #If partial matching
  if permissive > 0 && permissive < 1

    #catch attempt at double_metaphone (makes code messy)
    if code == double_metaphone
      error("Cannot currently code match with double_metaphone")
    end

    #returns any better matches than the set level
    return filter(array) do item
      sim_val = code_similarity(item, str, code)
      return sim_val > permissive
    end
  end

  #encode key
  encoded_key = code(str)

  #filter straight matches
  return filter(array) do item

    encoded_val = code(item)

    #handle double_metaphone
    if code == double_metaphone && isa(encoded_val, Array{String,1})
      return (encoded_key in encoded_val)
    else
      return encoded_key == encoded_val
    end
  end

end


"""
  `code_cluster(array[, code=phonix, lower_threshold=0.7, higher_threshold=0.9, stochastic=true])`

  Uses a phonetic similarity measure to cluster an array of strings.

  This function uses a canopy clustering method to group input strings based
  on their phonetic similarity, as judged by `code_similarity`. The phonetic
  coding method to be used can be specified, as can the upper and lower thresholds
  for similarity and whether or not to use randomly sampled centroids for the clusters.

  - Setting `higher_threshold=1` and `lower_threshold=1` will result in only exact
    code matches, which may be particularly sensible for coding schemes with variable
    length codes.

  - Setting `lower_threshold` to the same value as `higher_threshold` will result
    in cleanly separated clusters -- that is, each element of the original array
    will be assigned to one and only one cluster.

  - Setting `stochastic=false` will cause centroid to be selected from left to right
    rather than randomly, meaning that the output clusters will be deterministic. Behaviour
    without this setting is to select a centroid randomly, which can result in some clusters
    appearing or disappearing between runs on the same data where either threshold < 1.
"""
function code_cluster(array::Array{T, 1}, code=phonix::Function, lower_threshold=0.7, higher_threshold=0.9, stochastic=true) where {T<:String}

  #Sanity check
  if lower_threshold > higher_threshold
    error("Lower threshold cannot be greater than higher threshold.")
  end

  clusters = Vector[]

  #local copy of input array to shrink
  coderef = copy(array)

  #encoded version of input array
  inarray = map(code, array)

  while length(inarray) > 0

    if stochastic
      centroid = rand(inarray)
    else
      centroid = inarray[1]
    end

    #similarity of all items to selected centroid
    similarities = map(x -> code_similarity_internal(x, centroid), inarray)

    #select words which are greater than the lower threshold to add to this cluster
    incluster = filter(x -> similarities[findall(y -> y == x, coderef)[1]] >= lower_threshold, coderef)
    push!(clusters, incluster)

    #remove codes and words which are higher than the higher threshold from consideration
    inarray = filter(x -> similarities[findall(y -> y == x, inarray)[1]] < higher_threshold, inarray)
    coderef = filter(x -> similarities[findall(y -> y == x, coderef)[1]] < higher_threshold, coderef)
  end
  return clusters
end

export code_similarity, code_match, code_cluster
