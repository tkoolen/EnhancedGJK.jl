@pure dimension{N, T}(::Type{gt.AbstractGeometry{N, T}}) = Val{N}
@pure scalartype{N, T}(::Type{gt.AbstractGeometry{N, T}}) = T

@pure dimension{N, T, S}(::Type{gt.AbstractSimplex{S, gt.Vec{N, T}}}) = Val{N}
@pure scalartype{N, T, S}(::Type{gt.AbstractSimplex{S, gt.Vec{N, T}}}) = T

@pure dimension{N, T}(::Type{gt.HomogenousMesh{gt.Point{N, T}}}) = Val{N}
@pure scalartype{N, T}(::Type{gt.HomogenousMesh{gt.Point{N, T}}}) = T

@pure dimension{N, T}(::Type{gt.Vec{N, T}}) = Val{N}
@pure scalartype{N, T}(::Type{gt.Vec{N, T}}) = T

@pure dimension{M, N, T}(::Type{gt.Simplex{M, gt.Vec{N, T}}}) = Val{N}
@pure scalartype{M, N, T}(::Type{gt.Simplex{M, gt.Vec{N, T}}}) = T

@pure dimension{N, T}(::Type{SVector{N, T}}) = Val{N}
@pure scalartype{N, T}(::Type{SVector{N, T}}) = T