distributions = [:Bernoulli,
                 :Normal,
                 :Categorical,
                 :MvNormal]

function parse_dist(d_expr)
    @capture(d_expr, Bernoulli(arg_)) && return quote $d.Bernoulli($arg) end
    @capture(d_expr, Normal(mean_, std_)) && return quote $d.Normal($mean, $std) end
    @capture(d_expr, MvNormal(loc_, cov_)) && return quote $d.MultivariateNormal(torch.tensor($loc), torch.tensor($cov)) end
    @capture(d_expr, Categorical(arr_)) && return quote $d.Categorical(torch.tensor($arr)) end
    error("Distribution not supported by the distribution parser.\nExpression failed: $d_expr.")
end

function _pyro(expr)
    
    # Sugar.
    trans = MacroTools.postwalk(expr) do s
        if @capture(s, val_ ~ d_)

            # Matches: x ~ distribution.
            if val isa QuoteNode
                k = quote rand($val, $d) end

                # Matches: x = (:x => 5) ~ distribution
            elseif val isa Expr
                k = quote rand($val, $d) end

                # Matches: x = (:x) ~ distribution
            else
                addr = QuoteNode(val)
                k = quote $val = rand($addr, $d) end
            end

            k
        else
            s
        end
    end

    # Transform distribution constructors.
    trans = MacroTools.postwalk(trans) do s
        if @capture(s, dist_(args__)) && dist in distributions
            new = parse_dist(s)
            new
        else
            s
        end
    end

    # Transform addresses.
    trans = MacroTools.postwalk(trans) do s
        if @capture(s, rand(addr_, dist_))
            quote sample(String($addr), $dist) end
        else
            s
        end
    end

    # Convert control flow.
    trans = MacroTools.postwalk(trans) do s
        if @capture(s, if cond_ ex1__ else ex2__ end)
            quote if convert(Bool, $cond)
                    $(ex1...)
                else
                    $(ex2...)
                end
            end
        elseif @capture(s, for k_ in l_ : u_
                            ex__
                        end)
            quote for $k in convert(Int, $l) : convert(Int, $u)
                    $(ex...)
                end
            end
        else
            s
        end
    end

    MacroTools.postwalk(rmlines ∘ unblock, trans)
end

macro pyro(expr)
    trans = _pyro(expr)
    println(trans)
    esc(trans)
end
