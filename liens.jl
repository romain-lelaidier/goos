using LinearAlgebra: norm
include("dynamique.jl")
include("platforms.jl")

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
	function new_goos!(goos::Vector{Goo}, plateforms, obstacles pos_new)
Renvoie la liste des voisins du nouveau goos, placé en pos_new. Met à jour les voisins 
des goos pour éventuellement ajouter un lien vers le dernier. 
obstacles (pas encore implémenté) bloque la création de lien et le placement dessus

Si le goo peut être ajouté, il l'est et est renvoyé. Sinon on renvoie nothing (peut changer dans les versions futures)"""
function new_goos!(goos::Vector{Goo}, plateforms, obstacles, pos_new)
	#On vérifie qu'on n'est pas dans une plateforme
	for plateform ∈ plateforms
		!in_platform(pos_new, plateform) || return nothing #error("Vous avez essayé de mettre le goo dans une plateforme")
	end
	for plateform ∈ obstacles
		!in_platform(pos_new, plateform) || return nothing #error("Vous avez essayé de mettre le goo dans une plateforme")
	end

	#Vérification qu'on n'est pas trop proche
	for (_, goo) ∈ enumerate(goos)
		norm(pos_new .- goo.position) >=0.02 || return nothing # error("Pas de Goo sur un autre")
	end


	index_new_goo = length(goos) +1 #
	voisins = Tuple{Int, Float64}[]

	#On ajoute les liens vers les voisins
	for (i, goo) ∈ enumerate(goos)
		# Si la distance au goo est inférieure à 20 cm, l'ajouter en voisin
		if norm(pos_new .- goo.position) < 0.20

			croise_pas = true
			#On vérifie que les liens ne se croisent pas 


			#Pour les liens avec les goo, parfois ça marche, parfois pas...
			for (j, goo_autre) ∈ enumerate(goos)
				if j ≠ i #On élimine tous les liens partant du goo auquel on veut se lier, vu qu'il partage ce goo il y aurait problème
					for (goo_voisin_autre, _) in goo_autre.neighbors
						if goo_voisin_autre ≠ i && goo_voisin_autre < index_new_goo
							#Maintenant que l'on considère le bon lien, entre goo_autre et goo_voisin_autre, on vérifie qu'il croise pas
							croise_pas = !(segment_se_croisent((goo_autre.position, goos[goo_voisin_autre].position), (pos_new, goo.position)))
							croise_pas || break
						end
					end
				end
				croise_pas || break
			end

			#Vérification pas au travers plateformes
			for plat in plateforms
				croise_pas = link_check_platform(pos_new, goo.position, plat)
				croise_pas || break
			end

			#Vérification pas au travers des obstacles 
			for plat in obstacles
				croise_pas = link_check_platform(pos_new, goo.position, plat)
				croise_pas || break
			end

			#TODO : vérifier que ça croise pas aussi les liens vers les plateformes
			#TODO : vérifier aussi que ça croise pas les plateformes

			if croise_pas
				push!(voisins, (i, norm(pos_new .- goo.position)))
				push!(goo.neighbors, (index_new_goo, norm(pos_new .- goo.position)))
			end
		end
	end
	
	#On ajoute les liens vers les plateformes
	liens_plateformes = Tuple{Int, Tuple{Float64, Float64}, Float64}[]
	for (i, plateforme) in enumerate(plateforms)
		 closest = projection(pos_new, plateforme)
		 #S'accroche à la plateforme si elle est à moins de 10 cm
		if norm(closest .- pos_new) < 0.10
			push!(liens_plateformes, (i, closest, norm(closest .- pos_new)))
		end

	end
	
	if !(isempty(voisins) && isempty(liens_plateformes)) #TODO mettre la bonne condition
		nouveau = Goo(pos_new, (0.0,0.0), voisins, liens_plateformes)
		push!(goos, nouveau)
		return nouveau
	else
		return nothing # error("Pas le droit de mettre un goo ici, il ne crée pas de lien ! pos : $pos_new")
	end
end

