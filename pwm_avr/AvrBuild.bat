@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\pr_sm32\avr_works\pwm_avr\labels.tmp" -fI -W+ie -o "E:\pr_sm32\avr_works\pwm_avr\pwm.hex" -d "E:\pr_sm32\avr_works\pwm_avr\pwm.obj" -e "E:\pr_sm32\avr_works\pwm_avr\pwm.eep" -m "E:\pr_sm32\avr_works\pwm_avr\pwm.map" "E:\pr_sm32\avr_works\pwm_avr\pwm.asm"
