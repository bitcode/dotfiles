# actively watch the 20 newer lines in the a log file
watch -n 1 'tail -n 10 app.log'
# refresh compton config
pkill picom && picom --config ~/.config/picom.conf
