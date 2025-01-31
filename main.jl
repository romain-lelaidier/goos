# imports
using GLMakie
GLMakie.activate!() # hide

# modules internes
using goosInterface



goo = Observable{Goo}(0.,0.)


# A MODIFIER
scene = Scene(camera = campixel!)
linesegments!(scene, points, color = :black)
scatter!(scene, points, color = :gray)

on(events(scene).mousebutton) do event
    if event.button == Mouse.left
        if event.action == Mouse.press || event.action == Mouse.release
            mp = events(scene).mouseposition[]
            push!(points[], mp)
            notify(points)
        end
    end
end

scene