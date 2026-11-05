@echo off
call nasm main
call nasm teclado
call nasm timer
call nasm mecanica
call nasm render
call nasm sprites

call freelink main teclado timer mecanica render sprites
echo Compilacao Concluida. Execute MAIN.EXE.