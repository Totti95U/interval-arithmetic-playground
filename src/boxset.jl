"""
    BoxSet{N, T<:AbstractFloat}

A `BoxSet` is a collection of `Box`es, representing a union of hyperrectangles in N-dimensional space.

To construct a `BoxSet`, use the `boxset` function, which takes a vector of `Box`es or a variable number of `Box`es as input.

# Example
```@doctest
using IntervalArithmeticPlayground, IntervalArithmetic
b1 = box(interval(0.0, 1.0), interval(2.0, 3.0))
b2 = box(interval(1.0, 2.0), interval(3.0, 4.0))
bs = boxset([b1, b2])
bs = boxset(b1, b2) # equivalently

# output

2-element Vector{Box{2, Float64}}:
 Box{2, Float64}(([0.0, 1.0]_com, [2.0, 3.0]_com))
 Box{2, Float64}(([1.0, 2.0]_com, [3.0, 4.0]_com))
"""
const BoxSet{N, T<:AbstractFloat} = Vector{Box{N, T}}

boxset(boxes::Vector{Box{N, T}}) where {N, T<:AbstractFloat} = Box{N, T}[boxes...]
boxset(boxes::Box{N, T}...) where {N, T<:AbstractFloat} = boxset(collect(boxes))

boxset(points::Vector{SVNT{N, T}}; radius::T = zero(T)) where {N, T<:AbstractFloat} = boxset(box.(points; radius = radius))

"""
    in_boxset(point::SVNT{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat}

Check if a point is contained in any of the boxes in the `BoxSet`.
"""
in_boxset(point::SVNT{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat} = any(b -> in_box(point, b), bs)

issubset_boxset(bs::BoxSet{N, T}, b::Box{N, T}) where {N, T<:AbstractFloat} = all(bi -> issubset_box(bi, b), bs)
issubset_boxset(b::Box{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat} = any(bi -> issubset_box(b, bi), bs)
issubset_boxset(bs1::BoxSet{N, T}, bs2::BoxSet{N, T}) where {N, T<:AbstractFloat} = all(bi -> issubset_boxset(bi, bs2), bs1)

volume(bs::BoxSet) = sum(volume.(bs))
