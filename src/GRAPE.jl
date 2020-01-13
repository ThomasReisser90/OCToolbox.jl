# module containing some ideas of how to implement grape
# YOU NEED TO USE ZYGOTE#MASTER
# add Zygote#master ZygoteRules#master IRTools#master
# otherwise the exp has more problems, it still has problems but it sort of works
using Zygote
using QuantumOpticsBase
# using OCToolbox
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
    1 - abs2(σ0' * test_forward * ρ0)
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
c_mat = 1/1000 * (rand(K, N) .* 2 .- 1)
c_mat = c_mat * 0 .+ 1/sqrt(2)/2
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

my_func_with_grad(c_mat)
# handy to leave this sitting around!
Zygote.refresh()
# now we use the gradient to minimise the functional!
# we can probably rewrite the functional to include the reshape but doing this
# fast to show Thomas!
using Optim
#res = optimize(x->J3(reshape(x, (K,N))), my_func_with_grad, reshape(c_mat, (K * N)), LBFGS(); inplace=false)
# optimize(x->J3(reshape(x, (K,N))), c_mat, LBFGS())#, my_func_with_grad, reshape(c_mat, (K * N)))
f = x -> J3( reshape(x, (K, N) ) ) # functional
g = x -> my_func_with_grad(reshape(x, (K,N))) # automatic differentiated version of functional

# optimise
res = optimize(f, g, reshape(c_mat, (K * N)), LBFGS(); inplace=false)

J3(reshape(res.minimizer, (K, N)))
