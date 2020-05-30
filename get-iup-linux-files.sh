#!/bin/sh

top=$(pwd)

if [[ ! -d deps/linux/iup ]]; then

    # GNU/Linux files
    mkdir -p deps/linux/iup
    cd deps/linux/iup

    # .a and .so files
    # wget 'https://sourceforge.net/projects/iup/files/3.28/Linux%20Libraries/iup-3.28_Linux50_64_lib.tar.gz' -O iup.tar.gz
    wget 'https://github.com/ahungry/ahungry-janet/releases/download/0.0.1/iup.tar.gz' -O iup.tar.gz

    tar xzvf iup.tar.gz
fi

cd $top

if [[ ! -d deps/linux/im ]]; then
    mkdir -p deps/linux/im
    cd deps/linux/im

    # wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Linux%20Libraries/im-3.13_Linux415_64_lib.tar.gz' -O im.tar.gz
    wget 'https://github.com/ahungry/ahungry-janet/releases/download/0.0.1/im.tar.gz' -O im.tar.gz

    tar xzvf im.tar.gz

    #wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Linux%20Libraries/cd-5.12_Linux44_64_lib.tar.gz'
fi
