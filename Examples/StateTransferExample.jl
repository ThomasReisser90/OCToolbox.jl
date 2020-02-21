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
H_drift = 0*sz
H_ctrl = [π*sx, π * sy]

# we define our initial and final states
Ψ = [1+0.0im, 0.0]
ρ = [0+0.0im, 1.0]

# we set up a functional
function fn(controls)
    controls = complex.(real.(controls))
    U = stack_props(controls, H_drift)
    C2(ρ, U * Ψ)
end

K = 2
N = 10
T = 2
Δt = T/N

control_guess = rand(K, N).*0.001
fn(control_guess)

o = GRAPE(fn, control_guess, K, N)

fn(o.minimizer)
