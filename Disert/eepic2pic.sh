#!/bin/sh

if [ -z "$*" ]
then
    filelist=*.eepic
else
    filelist=$*
fi

for eepic in $filelist
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
