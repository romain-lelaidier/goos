using LinearAlgebra:det

"""Ce sont des rectangles, dont les coins sont donnés par:
    x_left, x_right, y_bottom, y_top"""
struct GooPlatform
    x_left::Float64
    x_right::Float64
    y_bottom::Float64
    y_top::Float64
end

# utilitaire pour la création de liens avec les plateformes
"""
fonction projection(goo::Goo, platform::Platform)

Renvoie un couple de flottants représentant les coordonnées x,y du point de la plateforme
le plus proche du goo
"""
function projection((x,y)::Tuple{Float64,Float64}, p::GooPlatform)

    #gestion de la coordonnée x
    res_x = x < p.x_left ? p.x_left : (x > p.x_right ? p.x_right : x)

    #gestion de la coordonnée y
    res_y = y < p.y_bottom ? p.y_bottom : (y > p.y_top ? p.y_top : y)

    (res_x,res_y)
end


# vérification qu'un goo ou un lien ne se trouve pas à l'intérieur d'une plateforme
"""
fonction in_platform((x,y)::Tuple{Float64, Float64}, p::Platform)

renvoie true si la position (x,y) se trouve à l'intérieur de la plateforme p 
(bords inclus)
"""
function in_platform((x,y)::Tuple{Float64,Float64}, p::GooPlatform)
    p.x_left ≤ x ≤ p.x_right && p.y_bottom ≤ y ≤ p.y_top
end


"""
	function segment_se_croisent(segment1, segment2)
	
Renvoie un booléen, indiquant si les segments se croisent. Les segments sont représenté par un couple/tableau de positions
Les positions sont représentés par des couples ou des tableaux x,y
"""
function segment_se_croisent(segment1, segment2, bord_inclus=true)
	#Cf brouillon
	#On utilise la caractérisation du segement en at + (1-t) b
	p1s1, p2s1 = segment1
	p1s2, p2s2 = segment2
	matA = hcat(collect(p1s1 .- p2s1), collect(p2s2 .- p1s2))
	matB = collect(p2s2 .- p2s1)

    #cas parallèle
    if det(matA) == 0
        return false
    end

	#On résout matA X = mat B
	x = matA \ matB

	if bord_inclus
		0 ≤ x[1] ≤ 1 && 0 ≤ x[2] ≤ 1
	else
		0 < x[1] < 1 && 0 < x[2] < 1
	end
end

"""
	function intersection_segments(segment1, segment2)
	
    Si 2 segments se croisent, renvoie la coordonnée de l'intersection des 2 segments sous
    forme de liste de 2 éléments
    Sinon, renvoie nothing
"""
function intersection_segments(segment1, segment2)
	#Cf brouillon
	#On utilise la caractérisation du segement en at + (1-t) b
	p1s1, p2s1 = segment1
	p1s2, p2s2 = segment2
	matA = hcat(collect(p1s1 .- p2s1), collect(p2s2 .- p1s2))
	matB = collect(p2s2 .- p2s1)

    # cas parallèle
    if det(matA) == 0
        return nothing
    end

	#On résout matA X = mat B
	x = matA \ matB

	if 0 ≤ x[1] ≤ 1 && 0 ≤ x[2] ≤ 1
        println("proportion du segment 1 : ",x[1])
        println("proportion du segment 2 : ",x[2])
        println("point d'intersection :", x[1].*p1s1 .+ (1-x[1]).*p2s1)
        return collect(x[1].*p1s1 .+ (1-x[1]).*p2s1)
    else
        return nothing
    end
end



"""
fonction link_check_platform((x1,y1)::Tuple{Float64,Float64}, 
                             (x2,y2)::Tuple{Float64,Float64},
                             p::Platform)

Renvoie false si le lien entre (x1,y1) et (x2,y2) traverse la plateforme p
/!\\ (x1,y1) et (x2,y2) sont supposés en dehors de la plateforme p et pas sur les bords/!\

"""
function link_check_platform((x1,y1)::Tuple{Float64,Float64}, 
                             (x2,y2)::Tuple{Float64,Float64},
                             p::GooPlatform)
    !(
    segment_se_croisent(((x1,y1),(x2,y2)),((p.x_left,p.y_bottom),(p.x_right,p.y_top)))
    ||
    segment_se_croisent(((x1,y1),(x2,y2)),((p.x_left,p.y_top),(p.x_right,p.y_bottom)))
    )
end


# collision entre goo et plateforme
"""
fonction static_collision((x,y)::Tuple{Float64,Float64}, (vx,vy)::Tuple{Float64,Float64},
                          p::Platform, dt::Float64)

Entrée :
    - (x,y) : position d'un goo à l'instant t
    - (vx,vy) : vitesse d'un goo à l'instant t
    - p : plateforme avec laquelle vérifier la collision
    - dt : intervalle de temps

Sortie :
    S'il y a collision avec la plateforme :
        (xp,yp),(vxp,vyp) : position et vitesse du goo à l'instant t+dt
    Sinon :
        nothing
"""
function static_collision((x,y)::Tuple{Float64,Float64}, (vx,vy)::Tuple{Float64,Float64},
                          p::GooPlatform, dt::Float64)
    
    # Calcul de la position à l'instant t+dt
    xp,yp = x+dt*vx, y+dt*vy

    # cas 1 : hors de la boîte
    if !in_platform((xp,yp), p)
        return nothing
    else # la position d'arrivée est dans la boîte
        interpos = nothing
        bords = [((p.x_left, p.y_bottom),(p.x_right, p.y_bottom)), #bas
                 ((p.x_right, p.y_bottom),(p.x_right, p.y_top)), #droite
                 ((p.x_left, p.y_top),(p.x_right, p.y_top)), #haut
                 ((p.x_left, p.y_bottom),(p.x_left, p.y_top)) #gauche
                ]
        i = 0

        # trouver de quel bord il s'agit
        while isnothing(interpos) && i <= 4
            i += 1
            interpos = intersection_segments(((x,y),(xp,yp)),bords[i])
        end
        isnothing(interpos) && throw("erreur collision avec une plateforme")

        # calcul de la nouvelle vitesse
        if i ∈ [1,3] #collision avec un élément horizontal => on inverse vy
            vxp,vyp = vx,-vy
        else #collision avec un élément vertical => on inverse vx
            vxp,vyp = -vx,vy
        end

        # calcul de la nouvelle position
        d = [xp,yp] - interpos
        if i ∈ [1,3] #collision avec un élément horizontal
            xp,yp = interpos[1] + d[1], interpos[2] - d[2]
        else #collision avec un élément vertical
            xp,yp = interpos[1] - d[1], interpos[2] + d[2]
        end

        return (xp,yp),(vxp,vyp)
    end

end