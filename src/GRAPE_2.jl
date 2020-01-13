using Zygote
using QuantumOpticsBase
using Optim

# so the idea here is to set up a function that does everything and takes a
# functional as input

function GRAPE(functional, controls, K, N)
    # autodiff the given functional
    # assume that everything is always flat

    function ∇(x)
        y, back = Zygote.pullback(functional, x)
        grady = back(1)[1]
        return reshape(grady, (K*N))
    end

    f = x -> functional(reshape(x, (K, N)))
    g = x -> ∇(reshape(x, (K, N)))

    res = optimize(f, g, controls, LBFGS(); inplace = false)
    return res.minimizer
end


b = SpinBasis(1//2)
const sx = DenseOperator(sigmax(b)).data
const sy = DenseOperator(sigmay(b)).data
const sz = DenseOperator(sigmaz(b)).data
const i2 = DenseOperator(identity(b)).data

ρ0 = [1 + 0.0im, 0.0+0.0im]
# target state
σ0 = [0.0 + 0.0im, 1.0 + 0.0im]

# hardcoded propagator for the moment, need to fix this at some point...
propagator(c_vec) = exp((c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))

function J3(x)
    x = complex.(real.(x))
    test_forward = mapreduce(propagator, *, eachcol(x))
    1 - abs2(σ0' * test_forward * ρ0)
end

N = 5 # 5 time steps
K = 2 # 2 controls

T = 1
Δt = T/N


c_mat = 1/1000 * (rand(K, N) .* 2 .- 1)

J3(c_mat)

out = GRAPE(J3,c_mat, K, N)

J3(out)

H_drift = [-10*sz, 0*sz, 10*sz]
ρ0_ens = [ρ0, ρ0, ρ0]
σ0_ens = [ρ0, σ0, ρ0]

function full_propagator(c_vec, H0)
    exp((H0 + c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))
end

N_ensemble = 3
weights = ones(N_ensemble)

function J3_ensemble(x)
    err = 0
    x = complex.(real.(x))
    for i = 1:N_ensemble
        # U = full_propagator(x, H_drift[i])
        U = mapreduce(c->full_propagator(c, H_drift[i]), *, eachcol(x))
        err += 1 - abs2(σ0_ens[i]' * U * ρ0_ens[i])
    end
    err
end

J3_ensemble(c_mat)

out = GRAPE(J3_ensemble, c_mat, K, N)

J3_ensemble(out)

i=3
U = mapreduce(c->full_propagator(c, H_drift[i]), *, eachcol(out))
U*ρ0_ens[i]

using BenchmarkTools

@benchmark GRAPE(J3_ensemble, c_mat, K, N)
