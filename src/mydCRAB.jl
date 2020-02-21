# my second attempt at writing a dCRAB alg
using OCToolbox
using Optim
using QuantumInformation

n_SI = 10
# generate frequency components
ω = rand(n_SI)

# we could write lots of these functions for any choice of basis
# there's already a library we could use I think
function gen_basis_fns(ω)
    f(A, B, t) = A * cos(2π * ω * t/T) + B * sin(2π * ω * t/T)
end

# sim stuff
K = 2
N = 10
T = 2
Δt = T/N

coeffs = zeros(N, K)

# functional that you want to minimise
function test(controls)
    controls = reshape(controls, (K, N))
    U = stack_props(controls, 0 * sz)
    C2(ρ, U * Ψ)
end

function full_propagator(c_vec, H0)
    exp((H0 + c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))
end

function stack_props(c_mat,H0)
    init = I(2)
    for i in 1:size(c_mat)[2]
        init = full_propagator(c_mat[:,i], H0) * init
    end
    init
end

# we need some way to turn the continuous functions into something
# piecewise for now
function discretise(fn_list, coeffs, T, Δt)
    # fn_list contains a list of the functions
    discrete_time = range(0, (N-1) * Δt, step = Δt)
    envelope = zeros(length(discrete_time))
    for (i, fn) in enumerate(fn_list)
        envelope += fn.(coeffs[i, :]..., discrete_time)
    end
    envelope
end



fn_list = []
coeffs .* 0
for iteration in 1:n_SI
    @show iteration
    append!(fn_list, [gen_basis_fns(ω[iteration])])

    function fn_to_minimize(x)
        coeffs[iteration:iteration, :] = x
        control1 = discretise(fn_list, coeffs[1:iteration, :], T, Δt)
        # we use the same controls for both x and y because we are lazy
        controls = transpose(hcat(control1, control1))
        test(controls)
    end
    o = optimize(fn_to_minimize, [0.5, 0.5], NelderMead(), Optim.Options(show_trace = true))
    coeffs[iteration:iteration, :] = o.minimizer
end

coeffs

control1 = discretise(fn_list, coeffs, T, Δt)
controls = transpose(hcat(control1, control1))
test(controls)
