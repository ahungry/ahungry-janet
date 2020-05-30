echo \" <<'BATCH_SCRIPT' >/dev/null ">NUL "\" \`" <#"
@ECHO OFF
REM ===== Batch Script Begin =====
ECHO Starting app.exe via bat
start "app" /min app.exe
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
echo "Starting ./app.bin via sh"
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:. ./app.bin
# ====== Bash Script End ======
case $- in *"i"*) cat /dev/stdin >/dev/null ;; esac
exit
#>
