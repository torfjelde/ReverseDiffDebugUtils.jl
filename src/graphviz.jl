export plotgraphviz

using .ReverseDiffDebugUtils: ReverseDiffDebugUtils
using .GraphGraphviz

function ReverseDiffDebugUtils.plotgraphviz(g::MetaDiGraph; kwargs...)
    auto_kwargs = (
        labels=["\"$(x)\"" for x in ReverseDiffDebugUtils.nodelabels(g)],
        nodeedgecolors=ReverseDiffDebugUtils.nodecolors(g),
    )
    return to_graphviz(g; merge(auto_kwargs, kwargs)...)
end
