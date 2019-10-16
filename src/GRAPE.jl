# module containing some ideas of how to implement grape

using QuantumOpticsBase
using OCToolbox

using ForwardDiff

# basic idea is to write a function called J
# which will take as input a vector of c_n
# and then compute the fidelity

# define a few things first of all
N = 5 # number of time slices
K = 2 # number of controls

b = SpinBasis(1//2)
sx = DenseOperator(sigmax(b)).data
sy = DenseOperator(sigmay(b)).data
sz = DenseOperator(sigmaz(b)).data

# defining the length of everything
T = 1
Δt = T/N
# so we know that we can work in some regime

H0 = 0.0 * sz
H_ctrl = [π * sx, π * sy]
R = 0.0 * H0

function propagator(c_n)
    # assuming that c_n is a row of
    exp( -1.0im*(H0 + 1.0im*R + (c_n * H_ctrl)[1])*Δt)
end

# so lets make a nice array of values
c_vec = rand(K, N)

function J2(c_vec)
    c_vec = reshape(c_vec, (K,N))
    # now we loop over each time slice and compute the propagators
    my_props = []
    for n = 1:N
        c_n = c_vec[:,n]
        # append!(my_props, propagator())
        append!(my_props, [propagator(reshape(c_vec[:,n], (1,K)))])
    end
    # initial state
    ρ0 = [1 + 0.0im, 0.0+0.0im]
    # target state
    σ0 = [0.0 + 0.0im, 1.0 + 0.0im]

    # now we time evolve our state
    test_forward = accumulate(*, reverse(my_props))[end]
    abs2(σ0' * test_forward * ρ0)
end

ForwardDiff.gradient(J2, c_vec)

# then use optim to LBFGS minimise functional


function derivative(H_k, P_n)
    Δt * commutator(H_k, P_n)
end
