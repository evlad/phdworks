#!/bin/sh

for eepic in *.eepic
do
    pic=${eepic%%.eepic}.pic
    echo "$eepic -> $pic"
    sed 's/\$\\backslash\$/\\/g' $eepic | \
    sed 's/\$\\{\$/{/g' | \
    sed 's/\$\\}\$/}/g' | \
    sed 's/\\\$/$/g' | \
    sed 's/\\\^{}/^/g' | \
    sed 's/\\_/_/g' \
    >$pic
done

# End of file
