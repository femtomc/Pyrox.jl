module Pyrox

using Reexport
@reexport using PyCall
using Conda
using MacroTools
using MacroTools: @capture

# Install Pyro.
if PyCall.conda
    Conda.add("pip")
    pip = joinpath(Conda.BINDIR, "pip")
    run(`$pip install pyro-ppl`)
else
    try
        pyimport("pyro")
    catch ee
        typeof(ee) <: PyCall.PyError || rethrow(ee)
        warn("""
             Python Dependencies not installed
             Please either:
             - Rebuild PyCall to use Conda, by running in the julia REPL:
             - `ENV[PYTHON]=""; Pkg.build("PyCall"); Pkg.build("Pyro")`
             - Or install the depencences, eg by running pip
             - `pip install pyro-ppl`
             """
             )
    end
end

# DSL imports.
torch = pyimport("torch")
pyro = pyimport("pyro")
d = pyimport("pyro.distributions")
condition = (fn, data) -> pyro.condition(fn, data=data)
sample = pyro.sample

include("dsl.jl")

export @pyro, torch
export sample, condition

end # module
