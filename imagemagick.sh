#! /bin/bash
# About: Sample functions for the ImageMagick library
# Requires: sudo apt-get install imagemagick -y

function convert_cropResizeBulk {
  # Quickly modify a group of images in place. Backup first!
  mogrify -gravity center -crop 1:1 -resize 400x400 *.webp
}
function convert_cropResize {
  # Loop this function over an image set to convert individually
  convert -gravity center -crop 1:1 -resize 400x400 *.webp image-%d.webp
}
function identify_image {
  # Get an image's width and height
  identify -format "%wx%h" image.jpg
}