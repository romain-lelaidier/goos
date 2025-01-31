using GLMakie
GLMakie.activate!() # hide

# PARAMETERS
Wm = 4          # game boundaries : width (meters)
dbd = 0.2       # game border length (meters)
W, H = 900, 700 # screen dimensions (pixels)

# don't touch this !!
SCL = W / (Wm+2*dbd)
Hm = (Wm+2*dbd) * H/W - 2*dbd

pixelsToPos((px, py)) = (px/SCL-dbd, py/SCL-dbd)
posToPixels((px, py)) = ((px+dbd) * SCL, (py+dbd) * SCL)

include("platforms.jl")
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
platforms = [
    Platform(-dbd,    0.0, -dbd, Hm+dbd),   # left border
    Platform(  Wm, Wm+dbd, -dbd, Hm+dbd),   # right border
    Platform(-dbd, Wm+dbd, -dbd,    0.0),   # bottom border
    Platform(-dbd, Wm+dbd,   Hm, Hm+dbd),   # top border

    Platform(0.5, 1.0, 0.5, 1.0)
]

points = Observable(Point2f[])
segments = Observable(Point2f[])

scene = Scene(
    camera=campixel!,
    backgroundcolor=colors["yellow"],
    size=(W, H)
)

# drawing scene
for p in platforms
    x0, y0 = posToPixels((p.x_left, p.y_bottom))
    x1, y1 = posToPixels((p.x_right, p.y_top))
    poly!(scene, [ (x0, y0), (x0, y1), (x1, y1), (x1, y0) ], color=colors["red"])
end

linesegments!(scene, segments, color=colors["green"], linewidth=7)
scatter!(scene, points, color=colors["black"], markersize=20)

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