using CLP2018
using Documenter

DocMeta.setdocmeta!(CLP2018, :DocTestSetup, :(using CLP2018); recursive=true)

makedocs(;
    modules=[CLP2018],
    authors="Vivan Sharma <vivan.sharma@sciencespo.fr> and contributors",
    sitename="CLP2018.jl",
    format=Documenter.HTML(;
        canonical="https://vivansharma2.github.io/CLP2018.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/vivansharma2/CLP2018.jl",
    devbranch="main",
)
