wget https://download.savannah.gnu.org/releases/freetype/ft291.zip -OutFile ./ft291.zip
Remove-Item -Path "freetype-2.9.1" -Recurse -Force 
Expand-Archive -Path ft291.zip -DestinationPath .
cmd compile_ft.bat