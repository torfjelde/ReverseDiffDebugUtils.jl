export plotgraphviz

using .ReverseDiffDebugUtils: ReverseDiffDebugUtils
using .GraphGraphviz

function ReverseDiffDebugUtilsplotgraphviz(g::MetaDiGraph; kwargs...)
    auto_kwargs = (
        labels=["\"$(x)\"" for x in ReverseDiffDebugUtilsnodelabels(g)],
        nodeedgecolors=ReverseDiffDebugUtilsnodecolors(g),
    )
    return to_graphviz(g; merge(auto_kwargs, kwargs)...)
end
