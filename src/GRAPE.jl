# module containing some ideas of how to implement grape
# YOU NEED TO USE ZYGOTE#MASTER
# add Zygote#master ZygoteRules#master IRTools#master
# otherwise the exp has more problems, it still has problems but it sort of works
using Zygote
using QuantumOpticsBase
using OCToolbox
using Optim

b = SpinBasis(1//2)
const sx = DenseOperator(sigmax(b)).data
const sy = DenseOperator(sigmay(b)).data
const sz = DenseOperator(sigmaz(b)).data
const i2 = DenseOperator(identity(b)).data

# want to use these definitions at some point!
# might also want to embrace StaticArrays wherever possible!
H0 = 0.0 * sz
H_ctrl = [π * sx, π * sy]
R = 0.0 * H0

# initial state
const ρ0 = [1 + 0.0im, 0.0+0.0im]
# target state
const σ0 = [0.0 + 0.0im, 1.0 + 0.0im]

# hardcoded propagator for the moment, need to fix this at some point...
propagator(c_vec) = exp((c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))

# functional to be minimised
function J3(c_mat)
    c_mat = complex.(real.(c_mat))
    # nice piece of code that Seth suggested to avoid mutating arrays internally!
    test_forward = mapreduce(propagator, *, eachcol(c_mat))
    # and then compute the infidelity
    abs(1 - abs2(σ0' * test_forward * ρ0))
end
# so thanks to Seth Axen for helping debug this issue, I think this is basically
# because Zygote decides that sensitivities should match the sensitivity
# of input, in this case everything should have sensitivies that are real
# at some point we deal with complex numbers so there was an inexact error
# by taking our drive and making it real + 0im we can avoid this issue!

N = 5 # number of time slices
K = 2 # number of controls

# defining the length of everything
T = 1
Δt = T/N

# generate some random initial guess
c_mat = rand(K, N)
c_mat = c_mat .* 0 .+ 1/sqrt(2)/2
J3(c_mat)

# taken from this page
# https://fluxml.ai/Zygote.jl/dev/adjoints/
# this lets us compute the gradient without computing the Jacobian!
function my_func_with_grad(x)
    y, back = Zygote.pullback(J3, x)
    grady = back(1)[1]
    # return y, grady
    return reshape(grady, (K*N))
end

my_func_with_grad(c_mat .* 0.001)

# handy to leave this sitting around!
Zygote.refresh()

# now we use the gradient to minimise the functional!
# we can probably rewrite the functional to include the reshape but doing this
# fast to show Thomas!
res = optimize(x->J3(reshape(x, (K,N))), my_func_with_grad, reshape(c_mat, (10)), LBFGS(); inplace=false)

# NOTE:
# this has worked to do GRAPE minimisation on several occasions...
# its also broken on several occasions when it says there is no method matching
# / for specific inputs that I guess are computed by Zygote.
# I've asked for help on the #autodiff channel of Julialang slack and hopefully
# will get a response at some point. Not sure if it's the expm that is a major
# problem.



#### MWE of problem with Zygote
using Zygote

const sx = reshape([0.0 + 0.0im 1.0+0.0im 1.0+0.0im 0.0+0.0im], (2,2))
const s = [1.0 + 0.0im, 0.0+0.0im]

function p(x)
    exp(1im*x * sx)
end

p(1.0)

function test(x)
    1 - abs2(s' * p(x) * s)
end

test(1.0)

function my_func_with_grad(x)
    y, back = Zygote.pullback(test, x)
    grady = back(1)[1]
    return y, grady
    # return reshape(grady, (K*N))
end

my_func_with_grad(1.0)
