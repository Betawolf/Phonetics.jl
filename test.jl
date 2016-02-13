using phonics

function assert(v1, v2)
  prefix = "fail"
  if v1 == v2
    prefix = "pass"
  end
  println("$prefix: ", v1, ',', v2)
end

#Tests for correctness of Soundex
println("\nSoundex")
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
println("\nMetaphone")
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

#Tests for correctness of Phonex
println("\nPhonex")
assert(phonex("Peter"), "b360")
assert(phonex("Pete"), "b300")
assert(phonex("Pedro"), "b360")
assert(phonex("Stephen"), "s315")
assert(phonex("Steve"), "s310")
assert(phonex("Smythe"), "s530")
assert(phonex("Smith"), "s530")
assert(phonex("Gail"), "g400")
assert(phonex("Gayle"), "g400")
assert(phonex("Christina"), "c623")
assert(phonex("Kristina"), "c623")

#Test for correctnes of Phonix
println("\nPhonix")
assert(phonix("Peter"), "p300")
assert(phonix("Pete"), "p300")
assert(phonix("Pedro"), "p360")
assert(phonix("Stephen"), "s375")
assert(phonix("Steve"), "s370")
assert(phonix("Smith"), "s530")
assert(phonix("Smythe"), "s530")
assert(phonix("Gail"), "g400")
assert(phonix("Gayle"), "g400")
assert(phonix("Christina"), "k683")
assert(phonix("Kristina"), "k683")

#Test for correctness of NYSIIS
println("\nNYSIIS")
assert(nysiis("Peter"), "patar")
assert(nysiis("Pete"), "pat")
assert(nysiis("Pedro"), "padr")
assert(nysiis("Stephen"), "stafan")
assert(nysiis("Steve"), "staf")
assert(nysiis("Smith"), "snat")
assert(nysiis("Smythe"), "snyt")
assert(nysiis("Gail"), "gal")
assert(nysiis("Gayle"), "gayl")
assert(nysiis("Christina"), "chrast")
assert(nysiis("Kristina"), "crasta")
assert(nysiis("Lawson"), "lasan")
assert(nysiis("Greene"), "gran")
assert(nysiis("Lynch"), "lync")
assert(nysiis("Wheeler"), "whalar")
assert(nysiis("Mitchell"), "matcal")


