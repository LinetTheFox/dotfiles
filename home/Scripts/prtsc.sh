#!/bin/sh

scr_path="/home/linet/.screen.png"

if [[ $1 == "full" ]]; then
    scrot -f $scr_path
else
    scrot -s -l style=solid,width=1,color="cyan" -f $scr_path
fi
   
xclip -selection clipboard -t image/png -i $scr_path
test -e $scr_path && rm $scr_path

