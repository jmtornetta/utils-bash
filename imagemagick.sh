#! /bin/bash
# About: Sample functions for the ImageMagick library
# Requires: sudo apt-get install imagemagick -y

# NOTE: 'mogrify' handles bulk operations, 'convert' handles individual operations.

function resizeConvert {
  # Quickly modify a group of images in place. Backup first!
  # Resize can also specifiy pixel width/height, i.e.: `-resize 400x400`
  mogrify -format webp -resize 20% ./*.jpg
}
function cropPixels {
  # Remove 30 pixels from left, 50 from top, 20 from right, 40 from bottom. Repage clears the "cache" basically.
  mogrify -crop +30+50 -crop -20-40 +repage
}
function cropPercentage {
  # Remove half of the image, measured from the top.
  mogrify -gravity north -crop 100%x50% ./*png
}
function identifyImage {
  # Get an image's width and height
  identify -format "%wx%h" image.jpg
}
function convertRename {
  # Loop this function over an image set to convert individually
  convert -gravity center -crop 1:1 -resize 400x400 ./*.webp image-%d.webp
}