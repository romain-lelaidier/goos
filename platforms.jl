

"""Ce sont des rectangles, dont les coins sont donnés par:
    x_left, x_right, y_bottom, y_top"""
struct Platform
    x_left::Float64
    x_right::Float64
    y_bottom::Float64
    y_top::Float64
end

"""
fonction projection(goo::Goo, platform::Platform)

Renvoie un couple de flottants représentant les coordonnées x,y du point de la plateforme
le plus proche du goo
"""
function projection((x,y)::Tuple{Float64,Float64}, p::Platform)

    #gestion de la coordonnée x
    res_x = x < p.x_left ? p.x_left : (x > p.x_right ? p.x_right : x)

    #gestion de la coordonnée y
    res_y = y < p.y_bottom ? p.y_bottom : (y > p.y_top ? p.y_top : y)

    (res_x,res_y)
end


"""
fonction in_platform((x,y)::Tuple{Float64, Float64}, p::Platform)

renvoie true si la position (x,y) se trouve à l'intérieur de la plateforme p 
(bords inclus)
"""
function in_platform((x,y)::Tuple{Float64,Float64}, p::Platform)
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
	matA = hcat(collect(p1s1 .- p1s2), collect(p2s2 .- p1s2))
	matB = collect(p2s2 .- p2s1)
	#On résout matA X = mat B
	x = matA \ matB

	if bord_inclus
		0 ≤ x[1] ≤ 1 && 0 ≤ x[2] ≤ 1
	else
		0 < x[1] < 1 && 0 < x[2] < 1
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
                             p::Platform)
    !(
    segment_se_croisent(((x1,y1),(x2,y2)),((p.x_left,p.y_bottom),(p.x_right,p.y_top)))
    ||
    segment_se_croisent(((x1,y1),(x2,y2)),((p.x_left,p.y_top),(p.x_right,p.y_bottom)))
    )
end