module IntervalArithmeticPlayground

using IntervalArithmetic
using StaticArrays

export rootfinding_with_bisection

export Box
export box, unitbox, ×,in_box, intersect_box, issubset_box, volume
export bisect, mince

export BoxSet
export boxset, in_boxset, issubset_boxset

const SVNT{N, T} = Union{SVector{N, T}, NTuple{N, T}}
const DEFAULT_FLOATTYPE = Float64

include("rootfinding.jl")
include("box.jl")
include("boxset.jl")

end # module
