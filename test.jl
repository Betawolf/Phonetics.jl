using phonics

function assert(v1, v2)
  prefix = "fail"
  if v1 == v2
    prefix = "pass"
  end
  println("$prefix: ", v1, ',', v2)
end

#Tests for correctness of Soundex
println("Soundex")
assert(soundex("Euler"),"e460")
assert(soundex("Ellery"),"e460")
assert(soundex("Gauss"),"g200")
assert(soundex("Ghosh"),"g200")
assert(soundex("Hilbert"), "h416")
assert(soundex("Heilbronn"), "h416")
assert(soundex("Kant"), "k530")
assert(soundex("Knuth"), "k530")
assert(soundex("Ladd"),"l300")
assert(soundex("Lloyd"),"l300")
assert(soundex("Christina"), "c623")
assert(soundex("Kristina"), "k623")

#Tests for correctness of Metaphone
println("Metaphone")
assert(metaphone("School"), "skl")
assert(metaphone("Shubert"), "xbrt")
assert(metaphone("Bonner"), "bnr")
assert(metaphone("Baymore"), "bmr")
assert(metaphone("Smith"), "smø")
assert(metaphone("Saneed"), "snt")
assert(metaphone("Aardvark"), "artf")
assert(metaphone("persuade"), "prst")
assert(metaphone("pressed"), "prst")
#NB: reference seemed confused about these two examples. 
assert(metaphone("Van Hoesen"), "fnhs")
assert(metaphone("Vincenzo"), "fnsn")

