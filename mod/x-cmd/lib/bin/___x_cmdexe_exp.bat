@echo off
setlocal
REM Copyright 2022-? Li Junhao (l@x-cmd.com). Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE, Version 3.

set gitbash=%___X_CMD_RCPWSH_MSYSBASH_PATH%
if EXIST "%gitbash%"        goto :start-gitbash

set gitbash=%USERPROFILE%\.x-cmd.root\data\git-for-windows\bin\bash.exe
if EXIST "%gitbash%"        goto :start-gitbash

set gitbash=%PROGRAMFILES%\Git\bin\bash.exe
if EXIST "%gitbash%"        goto :start-gitbash

set gitbash=%USERPROFILE%\scoop\apps\git\current\bin\bash.exe
if EXIST "%gitbash%"        goto :start-gitbash

set gitbash=%USERPROFILE%\AppData\Local\Programs\Git\bin\bash.exe
if EXIST "%gitbash%"        goto :start-gitbash

set gitbash=C:\scoop\apps\git\current\bin\bash.exe
if EXIST "%gitbash%"        goto :start-gitbash

echo ERROR: Fail to install git-for-windows. Press any key to exit.
exit 1

:start-gitbash
if NOT EXIST "%USERPROFILE%\.x-cmd.root\bin\___x_cmdexe" (
    echo ERROR: Not found ___x_cmdexe
    exit 1
)

"%gitbash%" -i "%USERPROFILE%\.x-cmd.root\bin\___x_cmdexe_exp" %*  && exit 0 || exit 1
