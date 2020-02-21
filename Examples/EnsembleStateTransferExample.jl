using OCToolbox

using LinearAlgebra
using QuantumInformation

# not super happy about the way these are working right now
function stack_props(c_mat,H0)
    init = I(2)
    for i in 1:size(c_mat)[2]
        init = pw_integrate(H0, H_ctrl, c_mat[:, i], Δt) * init
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
H_ctrl = [π * sx, π * sy]

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
