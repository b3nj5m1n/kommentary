printf "\n\nRunning Config Tests\n===============================================================\n"
lua5.3 test/test_config.lua -v
printf "\n\nRunning Kommentary Tests\n===============================================================\n"
lua5.3 test/test_kommentary.lua -v
printf "\n\nRunning Util Tests\n===============================================================\n"
lua5.3 test/test_util.lua -v
