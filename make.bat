@echo off
call nasm main
call nasm teclado
call nasm timer
call nasm mecanica
call nasm render

call freelink main teclado timer mecanica render
echo Compilacao Concluida. Execute MAIN.EXE.