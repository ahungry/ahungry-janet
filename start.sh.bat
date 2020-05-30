echo \" <<'BATCH_SCRIPT' >/dev/null ">NUL "\" \`" <#"
@ECHO OFF
REM ===== Batch Script Begin =====
ECHO Starting janet.exe via bat
start "app" /max janet.exe -m ./lib app.janet
REM ====== Batch Script End ======
GOTO :eof
TYPE CON >NUL
BATCH_SCRIPT
#> | Out-Null


echo \" <<'POWERSHELL_SCRIPT' >/dev/null # " | Out-Null
# ===== PowerShell Script Begin =====
echo "Starting app.exe via powershell"
# ====== PowerShell Script End ======
while ( ! $MyInvocation.MyCommand.Source ) { $input_line = Read-Host }
exit
<#
POWERSHELL_SCRIPT


set +o histexpand 2>/dev/null
# ===== Bash Script Begin =====
echo "Starting ./janet.bin via sh"
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:. ./janet.bin -m ./lib app.janet
# ====== Bash Script End ======
case $- in *"i"*) cat /dev/stdin >/dev/null ;; esac
exit
#>
