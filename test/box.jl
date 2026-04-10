@testset "box operations" begin
    b1 = box(interval(-1, 1), interval(-2, 2))
    b2 = box(interval(0, pi), interval(0.5, pi))
    b3 = box(interval(10, 11), interval(20, 21))

    # construction
    @test b1 == box((interval(-1, 1), interval(-2, 2)))
    @test box(SVector(interval(-1, 1), interval(-2, 2))) == b1
    @test box(SVector(0.0, 1.0); radius=0.5) == box(interval(-0.5, 0.5), interval(0.5, 1.5))

    # indexing / basic array interface
    @test isequal_interval(b1[1], interval(-1, 1))
    @test isequal_interval(b1[2], interval(-2, 2))
    @test firstindex(b1) == 1
    @test lastindex(b1) == 2
    @test length(b1) == 2
    @test ndims(b1) == 2
    @test eltype(typeof(b1)) == Interval{Float64}
    @test all(isequal_interval.(collect(b1), [interval(-1, 1), interval(-2, 2)]))
    @test isequal_interval(b1[2], setindex(b2, interval(-2, 2), 2)[2])
    @test setindex(b1, interval(-3, 3), 2) == box(interval(-1, 1), interval(-3, 3))

    # show
    @test sprint(show, b1) == "Box{2, Float64}([-1.0, 1.0]_com ⨯ [-2.0, 2.0]_com)"
    @test occursin("Box{2, Float64}", sprint(show, b1))

    # isin
    @test in_box(SVector(0.0, 0.0), b1)
    @test in_box(SVector(0.5, 1.5), b1)
    @test !in_box(SVector(1.5, 0.0), b1)

    # box products
    @test b1 × interval(3, 4) == box(interval(-1, 1), interval(-2, 2), interval(3, 4))
    @test interval(3, 4) × b1 == box(interval(3, 4), interval(-1, 1), interval(-2, 2))
    @test b1 × b3 == box(interval(-1, 1), interval(-2, 2), interval(10, 11), interval(20, 21))

    # unit boxes and volume
    @test unitbox(Float64, 3) == box(interval(0.0, 1.0), interval(0.0, 1.0), interval(0.0, 1.0))
    @test unitbox(2) == box(interval(0.0, 1.0), interval(0.0, 1.0))
    @test isequal_interval(volume(b1), interval(8))

    # intersection
    @test box(interval(0, 1, trv), interval(0.5, 2, trv)) == intersect_box(b1, b2, dec=:default)
    @test box(interval(0, 1), interval(0.5, 2)) == intersect_box(b1, b2, dec=:auto)

    # subset
    @test issubset_box(box(interval(0, 0.5), interval(0.5, 1)), b1)
    @test !issubset_box(box(interval(-2, 0.5), interval(0.5, 1)), b1)

    # bisection
    left, right = bisect(b1, 1)
    @test left == box(interval(-1, 0), interval(-2, 2))
    @test right == box(interval(0, 1), interval(-2, 2))
    @test bisect(b1, 2, 0.25) == (
        box(interval(-1, 1), interval(-2, -1)),
        box(interval(-1, 1), interval(-1, 2)),
    )
    @test_throws DomainError bisect(b1, 1, -0.1)

    # mince along one axis
    mx = mince(b1, 1, 2)
    @test length(mx) == 2
    @test mx[1] == box(interval(-1, 0), interval(-2, 2))
    @test mx[2] == box(interval(0, 1), interval(-2, 2))
    @test_throws DomainError mince(b1, 0, 2)
    @test_throws DomainError mince(b1, 1, 0)

    # mince across all axes
    all_slices = mince(b1, 2)
    @test length(all_slices) == 4
    @test all_slices[1] == box(interval(-1, 0), interval(-2, 0))
    @test all_slices[2] == box(interval(-1, 0), interval(0, 2))
    @test all_slices[3] == box(interval(0, 1), interval(-2, 0))
    @test all_slices[4] == box(interval(0, 1), interval(0, 2))
end
