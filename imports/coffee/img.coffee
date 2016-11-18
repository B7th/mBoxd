#####
# 
# Standardized JS-based image resolution resolution
# Default being smallest resolution
# When "@[2-9]\." matches an image,
# The number represent how many resolution there is for that small image
# Accessible under "@[2-9][a-i]\." where "a" represent the 2nd scope, "b" the 3rd scope etc.
# When a point is equivalent to a pixel, no change is made
# And JS will automatically reach for higher resolution by searching @3a.png or @3b.png
# @b3.png is the medium resolution of three images
# .svg.png is changed into .svg when available
# Automatically taken care of by JS
# checks both CSS and HTML
$('img[src~="@"]').each (el) ->
  # Checks the number
  # Checks the possible resolution
  # Changes the image
  # Listens to new image added later on
# SAME FOR CSS