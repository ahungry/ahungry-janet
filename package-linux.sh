#!/bin/sh

dir=app-gnu-linux64

rm -fr $dir
rm $dir.tar.gz
mkdir $dir

cp ./*.janet $dir/
cp ./*.bin $dir/
cp ./*.so* $dir/
cp ./*.bat $dir/
cp -R ./lib $dir/
cp -R ./local-lib $dir/
cp -R ./examples $dir/

tar czvf $dir.tar.gz $dir
