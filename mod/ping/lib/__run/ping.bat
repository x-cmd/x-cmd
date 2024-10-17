@echo off

REM using English
chcp 437
ping.exe %* && exit 0 || exit 1
