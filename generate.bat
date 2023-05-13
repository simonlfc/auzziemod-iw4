@echo off

echo Updating submodules...
git submodule update --init --recursive

echo Cleaning old IWDs...
IF EXIST mod.iwd DEL /f mod.iwd
IF EXIST weapons.iwd DEL /f weapons.iwd

echo Generating new IWDs...
SET zip="C:\Program Files\7-Zip\7z.exe"
%zip% a -tzip mod.iwd ui_mp\ weapons\ > nul
%zip% a -tzip weapons.iwd images\ > nul