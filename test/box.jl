using IntervalArithmetic, StaticArrays
using Test

using IntervalArithmeticPlayground

@testset "box operations" begin
    b1 = box(interval(-1, 1), interval(-1, 1))
    b2 = box(interval(0, pi), interval(0.5, pi))
    b3 = box(interval(10, 11), interval(20, 21))

    @test b1[1] == interval(-1, 1)
    @test b1[2] == interval(-1, 1)

    # isin
    @test in_box(SVector(0.0, 0.0), b1)
    @test in_box(SVector(0.5, 0.5), b1)
    @test !in_box(SVector(1.5, 0.0), b1)

    # intersection
    @test box(interval(0, 1, trv), interval(0.5, 1, trv)) == intersect_box(b1, b2, dec=:default)
    @test box(interval(0, 1), interval(0.5, 1)) == intersect_box(b1, b2, dec=:auto)

    # subset
    @test issubset_box(box(interval(0, 0.5), interval(0.5, 1)), b1)
    @test !issubset_box(box(interval(-2, 0.5), interval(0.5, 1)), b1)
end
