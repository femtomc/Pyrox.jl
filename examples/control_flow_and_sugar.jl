module ControlFlowWithSugar

include("../src/Pyrox.jl")
using .Pyrox

@pyro function model()
    x ~ Bernoulli(0.6)
    z ~ MvNormal([1.0, 3.0], [1.0 0.0; 0.0 1.0])
    if x
        y ~ Normal(0.3, 1.0)
    else
        y ~ Normal(0.3, 1.0)
    end

    for i in 1 : (:count ~ Categorical([0.1, 0.3, 0.1, 0.5]))
        println("Hi!")
    end
    y
end

conditioned = condition(model, Dict("y" => 4.0))
tr = conditioned()
println(tr)

end # module
