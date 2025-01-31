struct Goo
    x::Float64
    y::Float64
end

struct Goos
    goos::Vector{Goo}
end

goos = Goos([
    Goo(1.0, 1.0);
    Goo(2.0, 3.0);
    Goo(1.0, 1.5)
])

function getGoos()
    goos
end

function addGoo(goo::Goo)
    push!(goos.goos, goo)
end