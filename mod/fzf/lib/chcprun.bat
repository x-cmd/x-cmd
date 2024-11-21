@echo off

REM using English
chcp 437 >nul
%* && exit 0 || exit 1
