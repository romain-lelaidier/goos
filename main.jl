# imports
using GLMakie



scene = Scene(camera = campixel!)

goo_coords = 0.,0.
goo = Observable{Tuple{Float64,Float64}}(goo_coords)

scatter!(scene, goo_coords; color=:black)

scene