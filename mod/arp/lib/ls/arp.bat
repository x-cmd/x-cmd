@echo off

REM using English
chcp 437
arp.exe %* && exit 0 || exit 1
