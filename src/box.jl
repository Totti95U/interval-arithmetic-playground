"""
    Box{N, T<:AbstractFloat}

A `Box` is a Cartesian product of intervals, representing a hyperrectangle in N-dimensional space.

To construct a `Box`, use the `box` function, which takes a tuple of intervals as input.

# Example
```@doctest
using IntervalArithmeticPlayground, IntervalArithmetic
intervals = (interval(0.0, 1.0), interval(2.0, 3.0))
b = box(intervals)
b = box(interval(0.0, 1.0), interval(2.0, 3.0)) # equivalently

# output

Box{2, Float64}(([0.0, 1.0]_com, [2.0, 3.0]_com))
```
"""
struct Box{N, T <: AbstractFloat}
    intervals::SVector{N, Interval{T}}
end

function box(intervals::SVNT{N, Interval{T}}) where {N, T <: AbstractFloat}
    Box{N, T}(intervals)
end

function box(intervals::Vararg{Interval{T}, N}) where {T <: AbstractFloat, N}
    box(tuple(intervals...))
end

box(point::SVNT{N, T}; radius::T = zero(T)) where {N, T <: AbstractFloat} = box(ntuple(i -> interval(point[i] - radius, point[i] + radius), Val(N)))

function Base.show(io::IO, b::Box{N, T}) where {N, T <: AbstractFloat}
    if N <= 5
        print(io, "Box{$N, $T}(")
        for i in 1:N
            print(io, b.intervals[i])
            if i < N
                print(io, " ⨯ ")
            else
                print(io, ")")
            end
        end
    else
        print(io, "Box{$N, $T}(", b.intervals[1], " ⨯ ... ⨯ ", b.intervals[end], ")")
    end
end

Base.getindex(b::Box{N, T}, inds...) where {N, T <: AbstractFloat} = b.intervals[inds...]
Base.firstindex(::Box{N}) where {N} = 1
Base.lastindex(::Box{N}) where {N} = N

function Base.setindex(b::Box{N, T}, v::Interval{T}, i::Int) where {N, T <: AbstractFloat}
    new_intervals = ntuple(j -> j == i ? v : b.intervals[j], Val(N))
    Box{N, T}(new_intervals)
end

Base.length(::Box{N}) where {N} = N
Base.ndims(::Box{N}) where {N} = N
Base.eltype(::Type{Box{N, T}}) where {N, T} = Interval{T}

Base.iterate(b::Box, state::Int = 1) = state > length(b) ? nothing : (b[state], state + 1)

"""
    in_box(x::SVNT{N, T}, b::Box{N, T})

Check if the point `x` is contained within the box `b`.
This is done by verifying that each component of `x` lies within the corresponding interval of `b`.
"""
function in_box(x::SVNT{N, T}, b::Box{N, T}) where {N, T<:AbstractFloat}
    all(i -> in_interval(x[i], b[i]), 1:N)
end

"""
    intersect_box(b1::Box{N, T}, b2::Box{N, T}; dec=:default)

Returns the intersection of two boxes `b1` and `b2`, considerd as (extended) sets of the N-dimensional Euclidean space.
That is, the set of points that are contained in both `b1` and `b2`.

The keywork `dec` argument controls the decoration of the result.
It can be either a specific decoration, or one of two following options:
- `:default`: if at least one of the input boxes is `ill`, then the result is `ill`, otherwise it is `trv`.
- `:auto`: the output has the minimal decoration of the inputs.
"""
function intersect_box(b1::Box{N}, b2::Box{N}; dec=:default) where {N}
    new_intervals = ntuple(i -> intersect_interval(b1[i], b2[i], dec=dec), Val(N))
    box(new_intervals)
end

"""
    issubset_box(b1::Box{N, T}, b2::Box{N, T})

Test whether `b1` is contained in `b2`.
"""
function issubset_box(b1::Box{N}, b2::Box{N}) where {N}
    all(i -> issubset_interval(b1[i], b2[i]), 1:N)
end

volume(b::Box) = prod(2 .* radius.(b.intervals))

"""
        bisect(b::Box{N, T}, i::Int, α=0.5)
        bisect(b::Box{N, T}, α=0.5)

Split the box `b` at relative position `α` along the `i`-th dimension, where `α=0.5` corresponds to the midpoint.
"""
function IntervalArithmetic.bisect(b::Box, i::Int, α::Real = 0.5)
    0 <= α <= 1 || throw(DomainError(α, "bisect only accepts a relative position between 0 and 1"))
    x1, x2 = bisect(b[i], α)

    b1 = box(b[1:i-1]..., x1, b[i+1:end]...)
    b2 = box(b[1:i-1]..., x2, b[i+1:end]...)
    return b1, b2
end

"""
    dice(b::Box, α=0.5)

Split the box `b` into 2^N sub-boxes by bisecting each dimension at relative position `α`.
"""
function dice(b::Box{N,T}, α::Real = 0.5) where {N, T}
    bs = Vector{Box{N,T}}(undef, 2^N)

    for i in 1:N
        for j in 1:2^(i-1)
            idx = (j-1)*2^(N-i+1) + 1
            b1, b2 = bisect(bs[idx], i, α)
            bs[idx] = b1
            bs[idx + 2^(N-i)] = b2
        end
    end

    return boxset(bs)
end
