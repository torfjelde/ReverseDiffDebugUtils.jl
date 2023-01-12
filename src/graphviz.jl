export plotgraphviz4

plotgraphviz(f, args...; kwargs...) = plotgraphviz(make_graph(f, args...); kwargs...)
function plotgraphviz(g::MetaDiGraph; kwargs...)
    auto_kwargs = (
        labels=["\"$(x)\"" for x in nodelabels(g)],
        nodeedgecolors=nodecolors(g),
    )
    return to_graphviz(g; merge(auto_kwargs, kwargs)...)
end
