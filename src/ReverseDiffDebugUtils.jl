module ReverseDiffDebugUtils

using ReverseDiff
using Graphs, MetaGraphs
using GraphPlot

using GraphGraphviz

using OrderedCollections: OrderedDict

export make_graph, plothtml, plotgraphviz

variable_label(x, index) = "x$(index)\n$(typeof(x))"
variable_label(x::Real, index) = "x$(index)\n$(typeof(ReverseDiff.value(x)))"
variable_label(x::AbstractArray, index) = "x$(index)\n$(typeof(ReverseDiff.value(x)))\nSize: $(size(x))"
instruction_label(instruction) = string(instruction.func)

hasorigin(x) = false
hasorigin(x::ReverseDiff.TrackedReal) = ReverseDiff.hasorigin(x)
hasorigin(x::AbstractArray{<:ReverseDiff.TrackedReal}) = any(hasorigin, x)

getorigins(x::ReverseDiff.TrackedReal) = [x.origin]
getorigins(x::AbstractArray{<:ReverseDiff.TrackedReal}) = map(Base.Fix2(getproperty, :origin),filter(hasorigin, x))

function make_gradient_tape(f, inputs...)
    return ReverseDiff.GradientTape(f, inputs)
end

function add_instruction!(g::MetaDiGraph, instruction, instruction_to_index)
    add_vertex!(g)
    index = nv(g)
    set_prop!(g, index, :nodetype, :instruction)
    set_prop!(g, index, :label, instruction_label(instruction))
    set_prop!(g, index, :instruction, instruction)
    return index
end

function get_or_add_variable!(g::MetaDiGraph, x, variable_to_index; kwargs...)
    return haskey(variable_to_index, objectid(x)) ? variable_to_index[objectid(x)] : add_variable!(g, x, variable_to_index; kwargs...)
end
function add_variable!(g::MetaDiGraph, x, variable_to_index)
    add_vertex!(g)
    index = length(vertices(g))
    variable_to_index[objectid(x)] = index
    set_prop!(g, index, :nodetype, :variable)
    set_prop!(g, index, :label, variable_label(x, index))
    set_prop!(g, index, :variable, x)
    set_prop!(g, index, :is_input, false)
    set_prop!(g, index, :is_output, false)

    if hasorigin(x)
        for origin in getorigins(x)
            origin_index = get_or_add_variable!(g, origin, variable_to_index)
            add_edge!(g, origin_index, index)
        end
    end

    return index
end

# TODO: Handle the case of length 0 tape, i.e. something like `f(x) = x[1]` results in
# just an output with an `origin`.
make_graph(g, inputs...) = make_graph(make_gradient_tape(g, inputs...))
function make_graph(tape::ReverseDiff.GradientTape)
    instructions = tape.tape

    # Construct graph.
    g = MetaDiGraph()

    # Build the edges and add instructions as vertices.
    # TODO: Use `WeakRefDict`?
    variable_to_index = OrderedDict()
    instruction_to_index = OrderedDict()

    # Add the original function.
    # v = add_instruction!(g, tape, instruction_to_index)

    # Add the inputs.
    base_input = tape.input
    base_input = base_input isa Tuple ? base_input : (base_input,)
    for input in base_input
        index = add_variable!(g, input, variable_to_index)
        set_prop!(g, index, :is_input, true)
    end

    # Add the outputs.
    base_output = tape.output
    base_output = base_output isa Tuple ? base_output : (base_output,)
    for output in base_output
        index = add_variable!(g, output, variable_to_index)
        set_prop!(g, index, :is_output, true)
    end

    # Go over all the instructions.
    for instruction in instructions
        # Add the instruction vertex.
        v = add_instruction!(g, instruction, instruction_to_index)

        # TODO: Connect `TrackedReal` to `TrackedArray` if it has an origin.
        input = instruction.input
        input = input isa Tuple ? input : (input,)
        for i in input
            index = get_or_add_variable!(g, i, variable_to_index)
            add_edge!(g, index, v)
        end

        output = instruction.output
        output = output isa Tuple ? output : (output,)
        for o in output
            index = get_or_add_variable!(g, o, variable_to_index)
            add_edge!(g, v, index)
        end
    end

    return g
end

variables(g::MetaDiGraph) = [v for v in vertices(g) if get_prop(g, v, :nodetype) == :variable]

nodelabels(g::MetaDiGraph) = [get_prop(g, v, :label) for v in vertices(g)]
function nodecolors(
    g::MetaDiGraph;
    input_color="green", output_color="red", variable_color="black", instruction_color="white"
)
    colors = []
    for v in vertices(g)
        if get_prop(g, v, :nodetype) == :variable
            if get_prop(g, v, :is_input)
                push!(colors, input_color)
            elseif get_prop(g, v, :is_output)
                push!(colors, output_color)
            else
                push!(colors, variable_color)
            end
        else
            push!(colors, instruction_color)
        end
    end

    return colors
end

function plothtml(f, args...; kwargs...)
    return plothtml(make_graph(f, args...); kwargs...)
end
function plothtml(g::MetaDiGraph; kwargs...)
    return gplothtml(
        g;
        nodelabel=nodelabels(g),
        arrowlengthfrac=0.025,
        kwargs...
    )
end

plotgraphviz(f, args...; kwargs...) = plotgraphviz(make_graph(f, args...); kwargs...)
function plotgraphviz(g::MetaDiGraph; kwargs...)
    auto_kwargs = (
        labels=["\"$(x)\"" for x in nodelabels(g)],
        nodeedgecolors=nodecolors(g),
    )
    return to_graphviz(g; merge(auto_kwargs, kwargs)...)
end

end
