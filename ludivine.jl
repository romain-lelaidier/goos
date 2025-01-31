using LinearAlgebra: norm

# Constantes du problème
g = 9.81 / 20  # Gravité 
k = 100.0      # Raideur du ressort (J/m²)
m = 0.4        # Masse des Goos (400 g)
fr = 1         # Constante 

# Structure pour représenter un Goo
mutable struct Goo
    position::Tuple{Float64, Float64}
    velocity::Tuple{Float64, Float64}
    neighbors::Vector{Tuple{Int, Float64}} # Liste des voisins et longueur à vide du ressort
    plateform_n::Vector{Tuple{Int, Tuple{Float64, Float64}, Float64}} # Liste des plateformes voisines, les positions des liens sur la plateforme, et longueur à vide du ressort
end

"""
    function force(goos)
Calcule les forces s'appliquant sur une liste de goos.
Renvoie a, un tableau contenant l'accélération pour chaque Goo.
"""
function forces(goos)
    N = length(goos)
    a = [(0.0,0.0) for _ in 1:N]  # Initialisation des forces
    
    for i in 1:N 
        goo = goos[i]

        # Gravité
        Fg = (0.0, -m*g)
        
        # Force de frottements
        Ff = - fr .* goo.velocity

        # Force des ressorts & répulsion entre les Goos lorsqu'ils sont trop proches (modélisation des collisions)
        Fr = (0.0, 0.0)
        F_repulsion = (0.0, 0.0)

        for (j, l0) in goo.neighbors
            neighbor = goos[j]
            d = (neighbor.position[1] - goo.position[1], neighbor.position[2] - goo.position[2])
            dist = sqrt(d[1]^2 + d[2]^2)

            if dist > 0
                f = k * (dist - l0)
                direction = (d[1] / dist, d[2] / dist)
                Fr = (Fr[1] + f * direction[1], Fr[2] + f * direction[2])
            end

            if dist < 0.4
                repulsion = -1/dist^3
                F_repulsion =(F_repulsion[1] + repulsion * direction[1], F_repulsion[2] +  repulsion * direction[2])
            end

        end

        # Force des ressorts des plateformes
        Fp = (0.0, 0.0)

        for (j, (x,y), l0) in goo.plateform_n
            d = (x - goo.position[1], y - goo.position[2])
            dist = sqrt(d[1]^2 + d[2]^2)

            if dist > 0
                f = k * (dist - l0)
                direction = (d[1] / dist, d[2] / dist)
                Fp = (Fp[1] + f * direction[1], Fp[2] + f * direction[2])
            end
        end


        # Mise à jour des équations du mouvement
        # acc = ((Fg[1] + Fr[1] + Fp[1] + Ff[1]) / m, (Fg[2] + Fr[2] + Fp[2] + Ff[2]) / m)
        acc = ((Fg[1]) / m, (Fg[2]) / m)
        a[i] = acc

    end    
    
    a
end


function liens(goo::Goo)

end

"""
    function update_positions(goos, dt)
Met à jour la position et la vitesse des goos après un pas de temps dt.
"""
function update_positions!(goos, platforms, dt)
    a = forces(goos)

    for i in 1:length(goos)
        goo = goos[i]
        collision = nothing
        for p in platforms
            if isnothing(collision)
                collision = static_collision(goo.position, goo.velocity, p, dt)
            end
        end

        if isnothing(collision) #pas de collision avec une plateforme
            acc = a[i]

            # Mise à jour de la vitesse (Euler)
            new_velocity = (goo.velocity[1] + acc[1] * dt, goo.velocity[2] + acc[2] * dt)
        
            # Mise à jour de la position (Euler)
            new_position = (goo.position[1] + new_velocity[1] * dt, goo.position[2] + new_velocity[2] * dt)

            # Appliquer la mise à jour
            goo.velocity = new_velocity
            goo.position = new_position
        else
            goo.position = collision[1]
            goo.velocity = collision[2]
        end
    end
end


"""
    function ajouter_goo!(goos, plateformes, position)
FONCTION TEST EN BACK-UP.
"""
function ajouter_goo!(goos, plateformes, position)
    velocity = (0.0, 0.0)
    neighbors = Vector{Tuple{Int, Float64}}()
    plateform_n = Vector{Tuple{Int, Tuple{Float64, Float64}, Float64}}()

    # Ajouter les Goos voisins et les plateformes liées avec la fonction lien


    # Vérification : un Goo doit avoir au moins un lien
    if isempty(neighbors) && isempty(plateform_n)
        println("Impossible d'ajouter le Goo : aucun lien possible !")
        return
    end

    # Ajouter le Goo à la liste
    push!(goos, Goo(position, velocity, neighbors, plateform_n))
end

