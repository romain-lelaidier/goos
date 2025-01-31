# Constantes du problème
g = 9.81       # Gravité 
k = 100.0      # Raideur du ressort (J/m²)
m = 0.4        # Masse des Goos (400 g)

# Structure pour représenter un Goo
mutable struct Goo
    position::Tuple{Float64, Float64}
    velocity::Tuple{Float64, Float64}
    neighbors::Vector{Int}
end

function forces()

end

function liens(goo:Goo)

end

