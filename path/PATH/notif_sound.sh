#!/bin/bash

if [ $(swaync-client -D) = "false" ]; then
	paplay ~/.config/swaync/Sounds/notification.wav &
fi

