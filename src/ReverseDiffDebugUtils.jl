module ReverseDiffDebugUtils

using ReverseDiff
using Graphs, MetaGraphs
using GraphPlot

using OrderedCollections: OrderedDict

export make_graph, plothtml

variable_label(x, index) = "x$(index)"
variable_label(x::AbstractArray, index) = "x$(index)\n$(typeof(ReverseDiff.value(x)))\nSize: $(size(x))"
instruction_label(instruction) = string(instruction.func)

function make_gradient_tape(f, inputs...)
    return ReverseDiff.GradientTape(f, inputs).tape
end

make_graph(g, inputs...) = make_graph(make_gradient_tape(g, inputs...))
make_graph(gradient_tape::ReverseDiff.GradientTape) = make_graph(gradient_tape.tape)
function make_graph(instructions::AbstractVector)
    # Construct graph.
    g = MetaDiGraph()

    # Build the edges and add instructions as vertices.
    variable_to_index = OrderedDict()
    instruction_to_index = OrderedDict()
    index_to_label = OrderedDict()
    for instruction in instructions
        # Add the instruction vertex.
        v = (add_vertex!(g); nv(g))
        set_prop!(g, v, :type, :instruction)
        set_prop!(g, v, :label, instruction_label(instruction))
        # set_prop!(g, v, :instruction, instruction)

        input = instruction.input
        input = input isa Tuple ? input : (input,)
        for i in input
            if !haskey(variable_to_index, i)
                add_vertex!(g)
                i_idx = nv(g)
                variable_to_index[i] = i_idx
                variable_index = length(variable_to_index)

                set_prop!(g, i_idx, :type, :variable)
                set_prop!(g, i_idx, :label, variable_label(i, variable_index))
                # set_prop!(g, i_idx, :variable, i)
            end
            add_edge!(g, variable_to_index[i], v)
        end

        output = instruction.output
        output = output isa Tuple ? output : (output,)
        for o in output
            if !haskey(variable_to_index, o)
                add_vertex!(g)
                o_idx = nv(g)
                variable_to_index[o] = o_idx
                variable_index = length(variable_to_index)

                set_prop!(g, o_idx, :type, :variable)
                set_prop!(g, o_idx, :label, variable_label(o, variable_index))
                # set_prop!(g, o_idx, :variable, o)
            end
            add_edge!(g, v, variable_to_index[o])
        end
    end

    return g
end


function plothtml(f, args...; kwargs...)
    plothtml(make_graph(f, args...); kwargs...)
end
function plothtml(g::MetaDiGraph; kwargs...)
    nodelabels = [get_prop(g, v, :label) for v in vertices(g)]
    return gplothtml(
        g;
        nodelabel=nodelabels,
        arrowlengthfrac=0.025,
        kwargs...
    )
end

end
