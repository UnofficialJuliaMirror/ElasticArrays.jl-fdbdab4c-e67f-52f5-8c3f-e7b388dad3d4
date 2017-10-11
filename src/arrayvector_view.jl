# This file is a part of ElasticArrays.jl, licensed under the MIT License (MIT).


doc"""
    ArrayVectorView{T,N,M} <: AbstractVector{T}

Represents a view of an `ArrayVectorView{T,N}` as a vector of array with
dimension `M = N - 1` that all have equal size.

Constructors:

    ArrayVectorView(parent::AbstractArray)
    ArrayVectorView{T}(dims::Integer...)
"""
struct ArrayVectorView{
    T, N, M,
    P<:AbstractArray{T,N}
} <: AbstractVector{AbstractArray{T,M}}
    data::P

    function ArrayVectorView(parent::AbstractArray{T,N}) where {T,N}
        kernel_size = Base.front(size(parent))
        M = length(kernel_size)
        P = typeof(parent)
        new{T,N,M,P}(parent)
    end
end

export ArrayVectorView


import Base.==
(==)(A::ArrayVectorView, B::ArrayVectorView) =
    A.data == B.data

Base.parent(A::ArrayVectorView) = A.data

Base.size(A::ArrayVectorView{T,N}) where {T,N} = (size(parent(A), N),)

Base.getindex(A::ArrayVectorView{T,N,M}, i::Integer) where {T,N,M} =
    @view parent(A)[_ncolons(M)..., i]

Base.setindex!(A::ArrayVectorView{T,N,M}, x::AbstractArray{U,M}, i::Integer) where {T,N,M,U} =
    parent(A)[_ncolons(M)..., i] = x


function Base.push!(dest::ArrayVectorView{T,N,M}, src::AbstractArray{U,M}) where {T,N,M,U}
    size(src) != Base.front(size(parent(dest))) && throw(DimensionMismatch("Can't push, shape source and elements of dest are incompatible"))
    append!(parent(dest), src)
    dest
end


function Base.unshift!(dest::ArrayVectorView{T,N,M}, src::AbstractArray{U,M}) where {T,N,M,U}
    size(src) != Base.front(size(parent(dest))) && throw(DimensionMismatch("Can't unshift, shape source and elements of dest are incompatible"))
    prepend!(parent(dest), src)
    dest
end


function Base.append!(dest::ArrayVectorView{T,N,M}, src::ArrayVectorView{U,N,M}) where {T,N,M,U}
    Base.front(size(parent(src))) != Base.front(size(parent(dest))) && throw(DimensionMismatch("Can't append, shape source and elements of dest are incompatible"))
    append!(parent(dest), parent(src))
    dest
end


# ToDo: Add Base.append!(dest::ArrayVectorView{T,N,M}, src::AbstactVector{<:AbstractArray{U,M}}) where {T,N,M,U}


function Base.prepend!(dest::ArrayVectorView{T,N,M}, src::ArrayVectorView{U,N,M}) where {T,N,M,U}
    Base.front(size(parent(src))) != Base.front(size(parent(dest))) && throw(DimensionMismatch("Can't prepend, shape source and elements of dest are incompatible"))
    prepend!(parent(dest), parent(src))
    dest
end


# ToDo: Add Base.prepend!(dest::ArrayVectorView{T,N,M}, src::AbstactVector{<:AbstractArray{U,M}}) where {T,N,M,U}
