# module containing some ideas of how to implement grape
using QuantumOpticsBase
using OCToolbox

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
i2 = DenseOperator(identity(b)).data

# defining the length of everything
T = 1
Δt = T/N

# so we know that we can work in some regime
H0 = 0.0 * sz
H_ctrl = [π * sx, π * sy]
R = 0.0 * H0

# function propagator(c_n)
#     # assuming that c_n is a row of
#     exp(-1.0im.*(H0 + 1.0im.*R .+ (c_n .* H_ctrl)[1]).*Δt)
# end

function jacobian(f)
    x -> begin
        m = length(f(x))
        hcat([grad(x->f(x)[i])(x) for i=1:m]...)'
    end
end

function propagator(c_n)
    sum = 0.0 * sz
    for (c, h) in zip(c_n, H_ctrl)
        sum += c * h
    end
    exp(-1im * (H0 + 1im * R + sum) * Δt)
end

# so lets make a nice array of values
c_vec = rand(K, N) #.* 0.0 .+ 1/sqrt(2)/2

function J2(c_vec)
    c_vec = reshape(c_vec, (K,N))
    # now we loop over each time slice and compute the propagators
    my_props = []
    # my_props = [sx, sx, sx, sx, sx]
    for n = 1:N
        c_n = c_vec[:,n]
        # my_props[n] = propagator(reshape(c_vec[:,n], (1,K)))
        # append!(my_props, propagator())
        append!(my_props, [propagator(reshape(c_vec[:,n], (1,K)))])
    end
    # initial state
    ρ0 = [1 + 0.0im, 0.0+0.0im]
    # target state
    σ0 = [0.0 + 0.0im, 1.0 + 0.0im]
    # now we time evolve our state
    test_forward = accumulate(*, reverse(my_props))[end]
    1 - abs2(σ0' * test_forward  * ρ0)
end

# compute the jacobian of J2 and we are done
J2(c_vec)

using Optim
using AutoGrad
t = jacobian(J2)
function g(x)
    reshape(t(x .+ 0im), (10))
end
g(c_vec .+ 0im)

res = optimize(J2, reshape(c_vec, (10)); inplace = false)

J2(res.minimizer)
###########

# # then use optim to LBFGS minimise functional
# minmize(1 - J2, jacobian_func)

# playing around with some automatic differentiation stuff
using AutoGrad

f(x) = exp(1im * x * sx)
zfn = grad(f)
zfn(1)

# setting up a multi variable function like this
f2(x, y) = 3 * x + 4 * y
# then we can compute the jacobian
zfn2 = grad(x->f2(x[1], x[2]))
zfn2([1 1])

# so we can correctly compute the Jacobian here
f3(x) = exp(3im*x[1]) + exp(4im*x[2])
zfn3 = grad(f3)
zfn3([1.0 1.0 + 0.0im])

f4(x) = exp(2*x)
zfn4 = grad(f4)
zfn4(I(2))

# taken from that branch
function jacobian(f)
    x -> begin
        m = length(f(x))
        hcat([grad(x->f(x)[i])(x) for i=1:m]...)'
    end
end


# f(x) = exp(1im * x[1] * sx + x[2] * sy)
f(x) = exp(-1im * (H0 + 1im*R + (x[1] * H_ctrl[1] + x[2] * H_ctrl[2]))*Δt)
t = jacobian(f)
t([1.0 + 0.0im,2.0])
f([1.0, 2.0])

t = jacobian(propagator)
t([1.0 + 0.0im, 2.0])
c_vec

t = jacobian(J2)
t(c_vec .+ 0im)
