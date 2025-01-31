# imports
using GLMakie

goo_coords = 0,0
goo = Observable{Tuple{Float64,Float64}}(goo_coords)

HEIGHT,WIDTH = 400,400
area = Observable(Rect2{Int}(0,0,HEIGHT, WIDTH))


scene = Scene(camera = campixel!, viewport=area)


scatter!(scene, 200, 200; color=:black)


scene