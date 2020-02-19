using QuantumOpticsBase
using StaticArrays
using LinearAlgebra

# using BenchmarkTools
# using Dates

include("./functions.jl")
using .functions

# piecewise constant propagator
function full_propagator(c_vec, H0)
    exp((H0 + c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))
end

# note the definitions that follow are mostly const, this means that they are
# considered constant and should have no performance impact, globals will
# considerably slow performance.

# construct a spin basis
b = SpinBasis(1//2)
# gather the Pauli matrices
const sx = SMatrix{2,2}(DenseOperator(sigmax(b)).data)
const sy = SMatrix{2,2}(DenseOperator(sigmay(b)).data)
const sz = SMatrix{2,2}(DenseOperator(sigmaz(b)).data)
const i2 = SMatrix{2,2}(DenseOperator(identity(b)).data)

# define two spin states
const ρ0 = @SVector [1 + 0.0im, 0.0+0.0im]
# target state
const σ0 = @SVector [0.0 + 0.0im, 1.0 + 0.0im]

# for use with the ensemble
const N_ensemble = 3
# define the weight array
const weights = @SArray ones(N_ensemble)
const weights = weights/sum(weights)

# define a list of drift Hamiltonians
const H_drift = collect(range(-100, 100, length = N_ensemble)) .* [sz]
# define a list of target states
const σ0_ens = repeat([ρ0], N_ensemble)
# specify some states that we want to flip
σ0_ens[Int(floor(N_ensemble/2))] = σ0
σ0_ens[Int(floor(N_ensemble/4))] = σ0
σ0_ens[Int(floor(N_ensemble/4*3))] = σ0

const N = 5 # number of time slices
const K = 2 # number of controls

const T = 2 # total duration of the sequence in us
const Δt = T/N # time step

# initial random controls
c_mat = (rand(K, N) .* 2 .- 1)*10

# functional that maps control vector x into fidelity, here averaged over the ensemble
function J4(x)
    err = 0
    x = complex.(real.(x))
    for i = 1:N_ensemble
        U = stack_props(x, H_drift[i])
        err += (1 - abs2(σ0_ens[i]' * U * ρ0)) * weights[i]
    end
    err
end

# function that computes the propagator across many time slices
# ends up being faster than using mapreduce
function stack_props(c_mat,H0)
    init = I(2)
    for i in 1:size(c_mat)[2]
        init = init * full_propagator(c_mat[:,i], H0)
    end
    init
end

J4(c_mat)

using Zygote
Zygote.gradient(J4, c_mat)


# Zygote.refresh() # useful to have laying around

# optimise
out = GRAPE(J4, c_mat*0.01, K, N)

J4(c_mat)


# make some quick plots to check the output looks okay
using Plots

x = out.minimizer #c_mat * 0.1
res = 501
dist = 100
z = []
z2 = []
for i = -res:res
    i = i/res * dist
    H0 = -i * sz
    #U = mapreduce(c->full_propagator(c, H0), *, eachcol(x))
    U = stack_props(x, H0)
    state = U * ρ0
    append!(z, real(state' * sz * state))
end

x = range(-dist, dist, length = length(z))
plot(x, z, xlabel = "Detuning (MHz)", ylabel = "z projection", label = "State")
x2 = range(-dist, dist, length = N_ensemble)
z45 = [real(i[1]) for i in σ0_ens]
plot!(x2, z45.*2 .-1, label = "Ideal state")
