```
] add Pyrox
```

A convenient DSL interface to [Pyro](https://pyro.ai/) through [PyCall.jl](https://github.com/JuliaPy/PyCall.jl).

```julia
using Pyrox

@pyro function model()
    x = rand(:x, Bernoulli(0.6))
    y = rand(:y, Normal(0.3, 1.0))
    y
end

# OR.

@pyro function model()
    x ~ Bernoulli(0.6)
    y ~ Normal(0.3, 1.0)
    y
end

conditioned = condition(model, Dict("y" => 4.0))
sample = conditioned()
println(sample)

```
