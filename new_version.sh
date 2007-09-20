#!/bin/bash

FILES=PxlPkg.plist
VERSION=`grep VERSION= Makefile | sed 's/VERSION=//'`

echo "Updating to $VERSION..."

for f in $FILES; do
    echo "$f.in -> $f"
    sed "s/##VERSION##/$VERSION/g" $f.in > $f
done
