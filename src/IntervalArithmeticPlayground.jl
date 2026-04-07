module IntervalArithmeticPlayground

using IntervalArithmetic
using StaticArrays

export rootfinding_with_bisection

export Box
export box, in_box, intersect_box, issubset_box, volume
export bisect, dice

export BoxSet
export boxset, in_boxset, issubset_boxset

const SVNT{N, T} = Union{SVector{N, T}, NTuple{N, T}}

include("rootfinding.jl")
include("box.jl")
include("boxset.jl")

end # module
