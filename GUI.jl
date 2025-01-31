using GLMakie
GLMakie.activate!() # hide

# PARAMETERS
Wm = 1          # game boundaries : width (meters)
dbd = 0.01       # game border length (meters)
W, H = 700, 700 # screen dimensions (pixels)

GoosRadius = 0.04
GoosInteractionDistance = 0.2

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
borders = [
    Border(-dbd,    0.0, -dbd, Hm+dbd),   # left border
    Border(  Wm, Wm+dbd, -dbd, Hm+dbd),   # right border
    Border(-dbd, Wm+dbd, -dbd,    0.0),   # bottom border
    Border(-dbd, Wm+dbd,   Hm, Hm+dbd),   # top border
]
platforms = [
    GooPlatform(0.0, 0.2, 0.2, 0.3),
    GooPlatform(0.8, 1.0, 0.7, 0.8)
]
collidable = [borders;platforms]

points = Observable(Point2f[])
segments = Observable(Point2f[])

scene = Scene(
    camera=campixel!,
    backgroundcolor=colors["yellow"],
    size=(W, H)
)

# drawing scene
for p in collidable
    x0, y0 = posToPixels((p.x_left, p.y_bottom))
    x1, y1 = posToPixels((p.x_right, p.y_top))
    poly!(scene, [ (x0, y0), (x0, y1), (x1, y1), (x1, y0) ], color=colors["red"])
end

linesegments!(scene, segments, color=colors["green"], linewidth=7)
scatter!(scene, points, color=colors["black"], markersize=GoosRadius*SCL)

on(events(scene).mousebutton) do event
    if event.button == Mouse.left
        if event.action == Mouse.release
            # adding a Goo
            mp = events(scene).mouseposition[]
            new_goos!(goos, platforms, borders, pixelsToPos(mp))
        end
    end
end

function updateGoos(dt)
    update_positions!(goos, collidable, dt)

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
        for (_, (x, y), _) in goo.plateform_n
            if segi+1 <= length(segments[])
                segments[][segi]   = screenPos[i]
                segments[][segi+1] = posToPixels((x, y))
            else
                push!(segments[], screenPos[i])
                push!(segments[], posToPixels((x, y)))
            end
            segi += 2
        end
    end
end

on(events(scene).tick) do tick
    try
        updateGoos(tick.delta_time)
        notify(points)
        notify(segments)
    catch e
        rethrow(e)
    end
end

scene