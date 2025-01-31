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
"""
function in_platform((x,y)::Tuple{Float64,Float64}, p::Platform)
    p.x_left < x < p.x_right && p.y_bottom < y < p.y_top
end


"""
fonction link_check_platform((x1,y1)::Tuple{Float64,Float64}, 
                             (x2,y2)::Tuple{Float64,Float64},
                             p::Platform)

Renvoie false si le lien entre (x1,y1) et (x2,y2) traverse la plateforme p
"""
function link_check_platform((x1,y1)::Tuple{Float64,Float64}, 
                             (x2,y2)::Tuple{Float64,Float64},
                             p::Platform)

end