using LinearAlgebra: norm
using Ludivine

"""
	function segment_se_croisent(segment1, segment2)
	
Renvoie un booléen, indiquant si les segments se croisent. Les segments sont représenté par un couple/tableau de positions
"""
function segment_se_croisent(segment1, segment2)
	#Cf brouillon
	#On utilise la caractérisation du segement en at + (1-t) b
	p1s1, p2s1 = segment1
	p1s2, p2s2 = segment2
	matA = hcat(collect(p1s1 .- p1s2), collect(p2s2 .- p1s2))
	matB = collect(p2s2 .- p2s1)
	#On résout matA X = mat B
	x = matA \ matB

	0 ≤ x[1] ≤ 1 && 0 ≤ x[2] ≤ 1
end

"""
	function new_goos!(goos::Vector{Goo}, plateforms, pos_new)
Renvoie la liste des voisins du nouveau goos, placé en pos_new. Met à jour les voisins 
des goos pour éventuellement ajouter un lien vers le dernier. 

Les plateformes sont représentées par des indices négatifs, qui correspondent à l'opposé de leur index dans plateforms"""
function new_goos!(goos::Vector{Goo}, plateforms, pos_new)
	voisins = Tuple{Int, Float64}[]
	for (i, goo) ∈ enumerate(goos)
		#Si la distance au goo est inférieure à 20cm, l'ajouter en voisin
		if norm(pos_new .- goo.position)<0.20
			push!(voisins, (i, norm(pos_new .- goo.position)))
		end
	end


end

