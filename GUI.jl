using GLMakie
GLMakie.activate!() # hide

SCL = 400.
pixelsToPos((px, py)) = (px / SCL, py / SCL)
posToPixels((px, py)) = (px * SCL, py * SCL)

include("ludivine.jl")
include("mathis.jl")

colors = Dict(
    "yellow" => "#E9C46A",
    "orange" => "#F4A261",
    "red"    => "#E76F51",
    "green"  => "#2A9D8F",
    "black"  => "#264653"
)

goos = Goo[]

points = Observable(Point2f[])
segments = Observable(Point2f[])

scene = Scene(camera = campixel!, backgroundcolor=colors["yellow"])
linesegments!(scene, segments, color=colors["green"], linewidth=10)
scatter!(scene, points, color=colors["black"], markersize=30)

on(events(scene).mousebutton) do event
    if event.button == Mouse.left
        if event.action == Mouse.release
            # adding a Goo
            mp = events(scene).mouseposition[]
            new_goos!(goos, [], pixelsToPos(mp))
        end
    end
end

function updateGoos(dt)
    update_positions!(goos, dt)

    screenPos = [ posToPixels(goo.position) for goo in goos ]

    ptsi = 1
    segi = 1
    for (i, goo) in enumerate(goos)
        if ptsi <= length(points[])
            points[][ptsi] = screenPos[i]
        else
            push!(points[], screenPos[i])
        end
        ptsi += 1

        for (j, _) in goo.neighbors
            if (i < j)
                if segi+1 <= length(segments[])
                    segments[][segi]   = screenPos[i]
                    segments[][segi+1] = screenPos[j]
                else
                    push!(segments[], screenPos[i])
                    push!(segments[], screenPos[j])
                end
                segi += 2
            end
        end
    end
end

on(events(scene).tick) do tick
    try
        updateGoos(tick.delta_time)
        notify(points)
        notify(segments)
    catch e
        println("error", e)
    end
end

scene