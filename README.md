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
Process(`xdg-open /tmp/jl_7IzAZEdqtg.html`, ProcessExited(0))
```

results in something like

![Screenshot_20230112_151610](https://user-images.githubusercontent.com/11074788/212105118-577c23a6-37a8-4ebd-96c9-99cfb28e8edd.png)
