module IntervalArithmeticPlayground

using IntervalArithmetic

export rootfinding_with_bisection

"""
    rootfinding_with_bisection(f, dom=entireinterval(Float64); maxiter=16)

Find the roots of a function ``f\\colon \\mathbb{R} \\to \\mathbb{R}`` in a given interval `dom` using the bisection method. 
The function returns a list of intervals that may contain the roots.

# Arguments

- `f`: The function for which to find roots.
- `dom`: The interval in which to search for roots. The default is the entire real line.
- `maxiter`: The maximum number of iterations for refining the intervals.

# Example

```julia
using IntervalArithmeticPlayground
f(x) = x^3 - 2x^2 + x - 0.05
dom = interval(Float64, -10, 10)
roots = rootfinding_with_bisection(f, dom, maxiter=10)
```
"""
function rootfinding_with_bisection(f, dom::Interval{<:Number} = entireinterval(Float64); maxiter=16)
    # Initial interval
    T = numtype(dom)
    bdd_intervals = Interval{T}[]
    unbd_intervals = Interval{T}[]

    # sanitize the initial interval
    if issubset_interval(entireinterval(T), dom)
        push!(bdd_intervals, interval(T, -1, 1))
        push!(unbd_intervals, interval(T, -Inf, -1))
        push!(unbd_intervals, interval(T, 1, Inf))
    elseif inf(dom) == -Inf
        if in_interval(0, dom)
            push!(unbd_intervals, interval(T, -Inf, -1))
            push!(bdd_intervals, interval(T, -1, sup(dom)))
        else
            push!(unbd_intervals, dom)
        end
    elseif sup(dom) == Inf
        if in_interval(0, dom)
            push!(unbd_intervals, interval(T, 1, Inf))
            push!(bdd_intervals, interval(T, inf(dom), 1))
        else
            push!(unbd_intervals, dom)
        end
    else
        push!(bdd_intervals, dom)
    end

    # Just iterate to shorten the intervals
    for _ in 1:maxiter
        new_bdd_intervals = Interval{T}[]
        for x in bdd_intervals
            # bisect the interval
            left, right = bisect(x)
            # Check if the function contains zero in the left and right intervals
            if in_interval(0, f(left))
                push!(new_bdd_intervals, left)
            end
            if in_interval(0, f(right))
                push!(new_bdd_intervals, right)
            end
        end
        bdd_intervals = new_bdd_intervals
        # Update the unbounded intervals
        new_unbd_intervals = Interval{T}[]
        for x in unbd_intervals
            if sup(x) == Inf
                left = interval(T, inf(x), 2*inf(x))
                right = interval(T, 2*inf(x), Inf)
                in_interval(0, f(left)) && push!(new_bdd_intervals, left)
                in_interval(0, f(right)) && push!(new_unbd_intervals, right)
            else
                left = interval(T, -Inf, sup(x))
                right = interval(T, 2*sup(x), sup(x))
                in_interval(0, f(left)) && push!(new_unbd_intervals, left)
                in_interval(0, f(right)) && push!(new_bdd_intervals, right)
            end
        end
        unbd_intervals = new_unbd_intervals
    end

    return [bdd_intervals; unbd_intervals...]
end

end
