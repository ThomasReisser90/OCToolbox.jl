using Documenter, OCToolbox

makedocs(;
    modules=[OCToolbox],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/Bzzzt90/OCToolbox.jl/blob/{commit}{path}#L{line}",
    sitename="OCToolbox.jl",
    authors="Thomas Reisser",
    assets=String[],
)

deploydocs(;
    repo="github.com/Bzzzt90/OCToolbox.jl",
)
