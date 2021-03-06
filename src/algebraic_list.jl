abstract type AbstractElement end

# immutable list object that supports algebraic operations

struct AlgebraicList{T<:AbstractElement}
    parent::Vector{T}
end
function AlgebraicList(l)
    v::Vector{<:AbstractElement} = collect(l)
    return AlgebraicList(v)
end
AlgebraicList() = AlgebraicList(Union{}[])

Base.parent(v::AlgebraicList) = v.parent

Base.getindex(v::AlgebraicList, i::Int) = parent(v)[i]
Base.length(v::AlgebraicList) = length(parent(v))
Base.eltype(::Type{AlgebraicList{T}}) where {T} = T
Base.iterate(v::AlgebraicList, args...) = iterate(parent(v), args...)

function Base.:+(l1::AlgebraicList, l2::AlgebraicList)
    v1, v2 = parent(l1), parent(l2)
    return AlgebraicList(vcat(v1, v2))
end

function Base.:*(l1::AlgebraicList, l2::AlgebraicList)
    return AlgebraicList(el1 * el2 for el1 in l1 for el2 in l2)
end