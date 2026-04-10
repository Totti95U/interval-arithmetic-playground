@testset "boxset operations" begin
    b1 = box(interval(-1, 1), interval(-2, 2))
    b2 = box(interval(0, 1), interval(1, 3))
    b3 = box(interval(10, 11), interval(20, 21))

    # construction
    @test boxset([b1, b2]) == [b1, b2]
    @test boxset(b1, b2) == [b1, b2]
    @test boxset(SVector(0.0, 0.0, 1.0, 2.0), radius=0.5) == [
        box(interval(-0.5, 0.5), interval(-0.5, 0.5),
            interval(0.5, 1.5),  interval(1.5, 2.5)),
    ]

    # containment
    @test in_boxset(SVector(0.0, 0.0), boxset(b1, b2))
    @test in_boxset(SVector(0.75, 2.5), boxset(b1, b2))
    @test !in_boxset(SVector(5.0, 5.0), boxset(b1, b2))

    # subset
    @test issubset_boxset(boxset(box(interval(-0.5, 0.5), interval(-1, 1))), b1)
    @test issubset_boxset(b1, boxset(box(interval(-2, 2), interval(-3, 3)), b3))
    @test !issubset_boxset(b1, boxset(b2, b3))
    @test issubset_boxset(boxset(b1), boxset(box(interval(-2, 2), interval(-3, 3)), b1, b2))

    # volume
    @test isequal_interval(volume(boxset(b1, b2)), volume(b1) + volume(b2))

    # bisection
    left_right = bisect(boxset(b1, b2), 1)
    @test left_right == boxset(
        box(interval(-1, 0), interval(-2, 2)),
        box(interval(0, 1), interval(-2, 2)),
        box(interval(0, 0.5), interval(1, 3)),
        box(interval(0.5, 1), interval(1, 3)),
    )
    @test bisect(boxset(b1), 2, 0.25) == boxset(
        box(interval(-1, 1), interval(-2, -1)),
        box(interval(-1, 1), interval(-1, 2)),
    )

    # mincing
    @test mince(boxset(b1), 1, 2) == boxset(
        box(interval(-1, 0), interval(-2, 2)),
        box(interval(0, 1), interval(-2, 2)),
    )
    @test mince(boxset(b1), 2) == boxset(
        box(interval(-1, 0), interval(-2, 0)),
        box(interval(-1, 0), interval(0, 2)),
        box(interval(0, 1), interval(-2, 0)),
        box(interval(0, 1), interval(0, 2)),
    )
    @test length(mince(boxset(b2), 2)) == 4
end
