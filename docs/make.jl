using IntervalArithmeticPlayground
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(IntervalArithmeticPlayground, :DocTestSetup, :(using IntervalArithmeticPlayground); recursive=true)

makedocs(;
    modules=[IntervalArithmeticPlayground],
    authors="T. Usui",
    sitename="interval-arithmetic-playground",
    format=DocumenterVitepress.MarkdownVitepress(;
        repo="https://Totti95U.github.io/interval-arithmetic-playground",
        devbranch="main",
        devurl = "dev",
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

DocumenterVitepress.deploydocs(;
    repo="github.com/Totti95U/interval-arithmetic-playground",
    target=joinpath(@__DIR__, "build"),
    branch = "gh-pages",
    devbranch="main",
    push_preview=true,
)
