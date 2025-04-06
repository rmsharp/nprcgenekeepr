library(hexSticker)
imgurl <- system.file("man/figures/card.png", package = "nprcgenekeepr")
sticker(
  imgurl,
  package = "nprcgenekeepr",
  p_size = 17L,
  s_x = 1.0,
  s_y = 0.75,
  s_width = 0.5,
  filename = "man/figures/logo.png"
)
