type NeighborMesh{MeshType <: gt.AbstractMesh}
    mesh::MeshType
    neighbors::Vector{Set{Int}}
end

function plane_fit(data)
    centroid = mean(data, 2)
    U, s, V = svd(data .- centroid)
    i = indmin(s)
    normal = U[:,i]
    offset = dot(normal, centroid)
    normal, offset
end

function NeighborMesh{N, T}(mesh::gt.AbstractMesh{gt.Point{N, T}})
    neighbors = Set{Int}[Set{Int}() for vertex in gt.vertices(mesh)]
    for face in gt.faces(mesh)
        for i in 1:length(face)
            for j in i+1:length(face)
                if face[i] != face[j]
                    push!(neighbors[gt.onebased(face, i)], gt.onebased(face, j))
                    push!(neighbors[gt.onebased(face, j)], gt.onebased(face, i))
                end
            end
        end
    end

    # The enhanced GJK algorithm is susceptible to becoming stuck in local minima
    # if all of the neighbors of a given vertex are coplanar. It also benefits from
    # having some distant neighbors for each node, to avoid having to always take the
    # long way around the mesh to get to the other side.
    # To try to fix this, we will compute a fitting plane for all of the existing
    # neighbors for each vertex. We will then add neighbors corresponding to the
    # vertices at the maximum distance on each side of that plane.
    verts = gt.vertices(mesh)
    for i in eachindex(neighbors)
        @assert length(neighbors[i]) >= 2
        normal, offset = plane_fit(reinterpret(T,
            [verts[n] for n in neighbors[i]], (N, length(neighbors[i]))))
        push!(neighbors[i], indmin(map(v -> dot(convert(gt.Point{N, T}, normal), v), verts)))
        push!(neighbors[i], indmax(map(v -> dot(convert(gt.Point{N, T}, normal), v), verts)))
    end
    NeighborMesh{typeof(mesh)}(mesh, neighbors)
end

any_inside(mesh::NeighborMesh) = Tagged(svector( first(gt.vertices(mesh.mesh))), 1)

function support_vector_max(mesh::NeighborMesh, direction,
                                  initial_guess::Tagged)
    verts = gt.vertices(mesh.mesh)
    best = Tagged(svector(verts[initial_guess.tag]), initial_guess.tag)
    score = dot(direction, best.point)
    while true
        candidates = mesh.neighbors[best.tag]
        neighbor_index, best_neighbor_score = gt.argmax(n -> dot(direction, convert(SVector, verts[n])), candidates)
        if best_neighbor_score > score || (best_neighbor_score == score && neighbor_index > best.tag)
            score = best_neighbor_score
            best = Tagged(convert(SVector, verts[neighbor_index]), neighbor_index)
        else
            break
        end
    end
    best
end

@pure dimension{M}(::Type{NeighborMesh{M}}) = dimension(M)
@pure scalartype{M}(::Type{NeighborMesh{M}}) = scalartype(M)