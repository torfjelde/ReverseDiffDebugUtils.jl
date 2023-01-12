# ReverseDiffDebugUtils

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://torfjelde.github.io/ReverseDiffDebugUtils.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://torfjelde.github.io/ReverseDiffDebugUtils.jl/dev/)
[![Build Status](https://github.com/torfjelde/ReverseDiffDebugUtils.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/torfjelde/ReverseDiffDebugUtils.jl/actions/workflows/CI.yml?query=branch%3Amain)

Some utilities for debugging ReverseDiff.

## Example

```julia
julia> using ReverseDiffDebugUtils

julia> f(a, b) = sum(a' * b + a * b')
f (generic function with 1 method)

julia> plothtml(f, randn(2, 2), randn(2, 2))
```

results in something like

![Screenshot_20230112_154728](https://user-images.githubusercontent.com/11074788/212113634-a9482df8-27fd-44de-b502-b0ca7456e95b.png)

and with GraphViz:

```julia
julia> plotgraphviz(f, randn(2, 2), randn(2, 2); display=true)
```

![graph dot](https://user-images.githubusercontent.com/11074788/212113704-633bc1c9-efa7-4b8b-aeed-f657d2fb7f0a.png)
