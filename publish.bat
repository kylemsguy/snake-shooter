@echo off

echo bining Shooty Snake...

if exist bin rd /S /Q bin
md bin

xcopy /E /I bgm bin\bgm
xcopy /E /I data bin\data
xcopy /E /I effects bin\effects
xcopy /E /I entities bin\entities
xcopy /E /I particles bin\particles
xcopy /E /I scenes bin\scenes
xcopy /E /I soundfx bin\soundfx

copy app.enml bin
copy *.dll bin
copy LICENSE bin
copy README.md bin
copy shooty-snake.exe bin
copy game.bin bin

echo Done!
pause