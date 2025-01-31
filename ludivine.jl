# Constantes du problème
g = 9.81 / 20  # Gravité 
k = 100.0      # Raideur du ressort (J/m²)
m = 0.4        # Masse des Goos (400 g)

# Structure pour représenter un Goo
mutable struct Goo
    position::Tuple{Float64, Float64}
    velocity::Tuple{Float64, Float64}
    neighbors::Vector{Tuple{Int, Float64}} # Liste des voisins et longueur à vide du ressort
end

"""
    function force(goos)
Calcule les forces s'appliquant sur une liste de goos.
Renvoie a, un tableau contenant l'accélération pour chaque Goo.
"""
function forces(goos)
    N = length(goos)
    a = [0.0 for _ in 1:N]  # Initialisation des forces
    
    for i in 1:N 
        goo = goos[i]

        # Gravité
        Fg = (0.0, -m*g)

        # Force des ressorts
        Fr = (0.0, 0.0)
        for (j, l0) in goo.neighbors
            neighbor = goos[j]
            d = (neighbor.position[1] - goo.position[1], neighbor.position[2] - goo.position[2])
            dist = sqrt(d[1]^2 + d[2]^2)

            if dist > 0
                f = k * (dist -l0)
                direction = (d[1] / dist, d[2] / dist)
                Fr = (Fr[1] + f * direction[1], Fr[2] + f * direction[2])
            end
        end

        # Mise à jour des équations du mouvement
        acc = ((Fg[1] + Fr[1]) / m, (Fg[2] + Fr[2]) / m)
        a[i] = acc

    end    
    
    a

end

function liens(goo:Goo)

end

