@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\pr_sm32\avr\labels.tmp" -fI -W+ie -o "E:\pr_sm32\avr\test.hex" -d "E:\pr_sm32\avr\test.obj" -e "E:\pr_sm32\avr\test.eep" -m "E:\pr_sm32\avr\test.map" "E:\pr_sm32\avr\test.asm"
