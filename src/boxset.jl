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
boxset(boxes::SVNT{M, Box{N, T}}) where {M, N, T<:AbstractFloat} = Box{N, T}[boxes...]
boxset(boxes::Box{N, T}...) where {N, T<:AbstractFloat} = boxset(collect(boxes))

boxset(points::Vector{T}; radius::T = zero(T)) where {T<:AbstractFloat} = boxset(box.(points; radius = radius))
boxset(points::SVNT{N, T}; radius::T = zero(T)) where {N, T<:AbstractFloat} = boxset(box(points; radius = radius))

"""
    in_boxset(point::SVNT{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat}

Check if a point is contained in any of the boxes in the `BoxSet`.
"""
in_boxset(point::SVNT{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat} = any(b -> in_box(point, b), bs)

issubset_boxset(bs::BoxSet{N, T}, b::Box{N, T}) where {N, T<:AbstractFloat} = all(bi -> issubset_box(bi, b), bs)
issubset_boxset(b::Box{N, T}, bs::BoxSet{N, T}) where {N, T<:AbstractFloat} = any(bi -> issubset_box(b, bi), bs)
issubset_boxset(bs1::BoxSet{N, T}, bs2::BoxSet{N, T}) where {N, T<:AbstractFloat} = all(bi -> issubset_boxset(bi, bs2), bs1)

volume(bs::BoxSet) = sum(volume.(bs))

function IntervalArithmetic.bisect(bs::BoxSet{N, T}, i::Int, α::Real = 0.5) where {N, T<:AbstractFloat}
    finer_bs = BoxSet{N,T}(undef, 2 * length(bs))
    for (j, b) in enumerate(bs)
        left, right = bisect(b, i, α)
        finer_bs[2j - 1] = left
        finer_bs[2j] = right
    end
    return finer_bs
end

function IntervalArithmetic.mince(bs::BoxSet{N,T}, i::Int, n::Int) where {N, T<:AbstractFloat}
    finer_bs = BoxSet{N,T}(undef, n * length(bs))
    for (j, b) in enumerate(bs)
        sub_boxes = mince(b, i, n)
        finer_bs[(j-1)*n + 1:j*n] = sub_boxes
    end
    return finer_bs
end

function IntervalArithmetic.mince(bs::BoxSet{N,T}, n::Int) where {N, T<:AbstractFloat}
    finer_bs = BoxSet{N,T}(undef, length(bs) * n^N)
    for (j, b) in enumerate(bs)
        sub_boxes = mince(b, n)
        finer_bs[(j-1)*n^N + 1:j*n^N] = sub_boxes
    end
    return finer_bs
end
