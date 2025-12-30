library(hexSticker) # nolint: undesirable_function_linter.
imgurl <- system.file(file.path("man", "figures", "card.png"),
                      package = "mprcgenekeepr")
sticker(
  imgurl,
  package = "mprcgenekeepr",
  p_size = 17L,
  s_x = 1.0,
  s_y = 0.75,
  s_width = 0.5,
  filename = file.path("man", "figures", "logo.png")
)
