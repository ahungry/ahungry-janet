#!/bin/sh

top=$(pwd)

if [ ! -d deps/win32/iup ]; then

    mkdir -p deps/win32/iup
    cd deps/win32/iup

    # Get the Windows files

    # .a and .dll files
    #wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Static/iup-3.28_Win32_mingw6_lib.zip' -O iup.zip
    # wget 'https://github.com/ahungry/ahungry-janet/releases/download/0.0.1/iup.zip' -O iup.zip
    wget 'https://github.com/ahungry/ahungry-janet/releases/download/0.0.1/iup-3.28_Win32_dllw6_lib.zip' -O iup.zip

    unzip iup.zip

    # This one has all the dynamic DLL for linking on build + runtime requirements
    #wget 'https://sourceforge.net/projects/iup/files/3.28/Windows%20Libraries/Dynamic/iup-3.28_Win64_dllw6_lib.zip'
fi

cd $top

if [ ! -d deps/win32/im ]; then

    mkdir -p deps/win32/im
    cd deps/win32/im

    #wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Dynamic/im-3.13_Win32_dllw6_lib.zip' -O im.zip
    wget 'https://github.com/ahungry/ahungry-janet/releases/download/0.0.1/im32.zip' -O im.zip
    #wget 'https://sourceforge.net/projects/imtoolkit/files/3.13/Windows%20Libraries/Static/im-3.13_Win64_mingw6_lib.zip'

    unzip im.zip

    # wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Dynamic/cd-5.12_Win64_dllw6_lib.zip'
    # wget 'https://sourceforge.net/projects/canvasdraw/files/5.12/Windows%20Libraries/Static/cd-5.12_Win64_mingw6_lib.zip'
fi
