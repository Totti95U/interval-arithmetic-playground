using IntervalArithmetic
using CairoMakie
using IntervalArithmeticPlayground

# Plotting
function plot_roots(f, roots)
    fig = Figure()
    ax = Axis(fig[1, 1], title="Global Bisection Method", xlabel="x", ylabel="f(x)")

    for root in roots
        val = f(root)
        band!(ax, [inf(root), sup(root)], [inf(val), inf(val)], [sup(val), sup(val)])
    end

    hlines!(ax, [0], color=:gray, linestyle=:dash)

    xinf = minimum(inf, roots)
    xsup = maximum(sup, roots)
    xrange = xsup - xinf
    xs = LinRange(xinf - xrange * 0.05, xsup + xrange * 0.05, 1024)
    ys = f.(xs)
    lines!(ax, xs, ys, color=:blue)

    return fig
end

# Target function
# f(x) = x^3 - 2x^2 + x - 0.05
f(x) = (x - 1) * (x - 2) * (x - 3)

# Initial domain
dom = interval(Float64, 0, 3.5)

# Find the root
roots = rootfinding_with_bisection(f, dom, maxiter=6)

fig = plot_roots(f, roots)