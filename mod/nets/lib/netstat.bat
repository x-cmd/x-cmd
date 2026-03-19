@echo off

REM using English
chcp 437
netstat.exe %* && exit 0 || exit 1
