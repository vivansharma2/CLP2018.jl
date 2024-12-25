using New_package
using Documenter

DocMeta.setdocmeta!(New_package, :DocTestSetup, :(using New_package); recursive=true)

makedocs(;
    modules=[New_package],
    authors="Vivan Sharma <vivan.sharma@sciencespo.fr> and contributors",
    sitename="New_package.jl",
    format=Documenter.HTML(;
        canonical="https://vivansharma2.github.io/New_package.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/vivansharma2/New_package.jl",
    devbranch="main",
)
