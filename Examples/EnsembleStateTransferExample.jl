using OCToolbox

using LinearAlgebra
using QuantumInformation

# in future this will be included in the pw_integrate function
function full_propagator(c_vec, H0)
    exp((H0 + π*(c_vec[1] .* sx .+ c_vec[2] .* sy)) .* (-Δt*im))
end

# not super happy about the way these are working right now
function stack_props(c_mat,H0)
    init = I(2)
    for i in 1:size(c_mat)[2]
        init = full_propagator(c_mat[:,i], H0) * init
    end
    init
end

i2 = Matrix{Complex{Float64}}(I, 2, 2)

# we define our initial and final states
Ψ = [1+0.0im, 0.0]
ρ = [0+0.0im, 1.0]

N_ensemble = 10
ΔRange = 10  * 2π
H_drift = collect(range(-ΔRange, ΔRange, length = N_ensemble)) .* [sz]


# we set up a functional for a robust pulse
function fn(controls)
    controls = complex.(real.(controls))
    err = 0
    for i = 1:N_ensemble
        U = stack_props(controls, H_drift[i])
        err += C2(ρ, U * Ψ)
    end
    err
end

K = 2
N = 20
T = 10
Δt = T/N

control_guess = rand(K, N).*0.001
fn(control_guess)

Zygote.gradient(fn, control_guess)


o = GRAPE(fn, control_guess, K, N)

fn(o.minimizer)
