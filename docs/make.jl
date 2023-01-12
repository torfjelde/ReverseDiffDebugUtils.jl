using ReverseDiffDebugUtils
using Documenter

DocMeta.setdocmeta!(ReverseDiffDebugUtils, :DocTestSetup, :(using ReverseDiffDebugUtils); recursive=true)

makedocs(;
    modules=[ReverseDiffDebugUtils],
    authors="Tor Erlend Fjelde <tor.erlend95@gmail.com> and contributors",
    repo="https://github.com/torfjelde/ReverseDiffDebugUtils.jl/blob/{commit}{path}#{line}",
    sitename="ReverseDiffDebugUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://torfjelde.github.io/ReverseDiffDebugUtils.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/torfjelde/ReverseDiffDebugUtils.jl",
    devbranch="main",
)
