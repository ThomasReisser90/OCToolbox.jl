using Zygote, Optim

"""
    GRAPE(function, Array, Int, Int)

    Function using automatic differentiation to compute the gradient of a given
    functional

"""
function GRAPE(functional, controls; g_tol=1e-6)
    K, N = size(controls)
    # here we use an inplace gradient update
    function g!(G, x)
        _, back = Zygote.pullback(functional, reshape(x, (K, N)))
        G .= reshape(back(1)[1], size(G))
    end

    f = x -> functional(reshape(x, (K, N)))

    res = optimize(f, g!, controls, LBFGS(), Optim.Options(g_tol=g_tol, show_trace=true, store_trace = true))
    return res
end

"""
    CRAB
"""

function CRAB(functional, controls, n_SI)
    # N is the number of SI

end

function GROUP()
    println("use AD to optimise coefficients of dCRAB")
end

function Krotov()
    println("how do I work with AD?")
end
