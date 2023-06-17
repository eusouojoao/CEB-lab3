#!/bin/bash

for file in *.png; do
	# get the image height in px
	height=$(identify -format "%h" "$file")

	# resize the image
	new_height=$((height - 60))
	convert "$file" -crop x$new_height+0+0 "${file%.png}_cropped.png"
done
