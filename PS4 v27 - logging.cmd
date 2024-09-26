@echo off

set mypath=%cd%
set mtee=%cd%\tools\mtee.exe

"PS4 v27.cmd" 2>&1 | "%mtee%" "%cd%\errors.log"