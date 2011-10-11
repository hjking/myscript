#!/bin/csh -f

#
# Human readable password generator
#

alias random "head -c 200 < /dev/random | uuencode -m - | tail -n+2 | sed 's/[^0-9]//g' | head -c 5"


# Random prefixes
set prefix = ( aero anti auto bi bio cine deca demo dyna eco ergo geo gyno hypo kilo \
               mega tera mini duo an auto be counter de dis ex fore infra inter mal mis \
               neo non out pan post pre pseudo semi super trans twi vice )

# Random suffixes
set suffix = ( dom ity ment sion ness ence er ist tion or ance ive en ic al able y ous \
               ful ise ize ate ify fy ly )

# Vowel sounds
set vowels = ( a o e i u ou oo ae ea ie )

# Consonants
set consonants = (  r t p s d f g h j k l z x c v b n m qu th sw pl )


# Select random prefix
@ index = (`random` % $#prefix) + 1
set password = $prefix[$index]

# Select random suffix
@ index = (`random` % $#suffix) + 1
set password_suffix = $suffix[$index]


#Use 2 syllables = ~60 million combinations
set syllables = 2

set i = 0
while ( $i < $syllables )

    # selecting random consonant
    @ index = (`random` % $#consonants) + 1
    set password = $password""$consonants[$index]

    # selecting random vowel
    @ index = (`random` % $#vowels) + 1
    set password = $password""$vowels[$index]

    @ i ++

end

# if suffix begin with vovel..add another consonant
foreach v ( $vowels )
    if ($v == `echo $password_suffix | head -c 1` ) then
        @ index = (`random` % $#consonants) + 1
        set password = $password""$consonants[$index]       
        break
    endif
end

# add suffix
set password = $password""$password_suffix

echo $password

exit 0

