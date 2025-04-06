output=bin/windows
game_exe=game.exe
program=bin/client.hl

if [ ! -f bin/hl-windows.zip ]; then
	curl -sL https://github.com/HaxeFoundation/hashlink/releases/download/latest/hashlink-2800270-win64.zip -o bin/hl-windows.zip
fi

# clean up
rm -rf $output $output.zip

mkdir -p $output

# extract binaries into $output
unzip -j bin/hl-windows.zip -x "*.c" "*.h" "*.lib" -d $output

# rename hl to $game_exe
mv $output/hl.exe $output/$game_exe

# rename client.hl to hlboot.dat
cp $program $output/hlboot.dat

#copy resources
cp -r res $output/res
cp bin/steam.hdll $output
cp steam_api64.dll $output

output_zip=$PWD/$output.zip

cd $output

zip $output_zip -r .
