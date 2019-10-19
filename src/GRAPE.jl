# module containing some ideas of how to implement grape
using QuantumOpticsBase
using OCToolbox
# YOU NEED TO USE ZYGOTE#MASTER
# add Zygote#master ZygoteRules#master IRTools#master
# otherwise the exp has problems
using Zygote
using Optim

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

# initial state
ρ0 = [1 + 0.0im, 0.0+0.0im]
# target state
σ0 = [0.0 + 0.0im, 1.0 + 0.0im]

# hard coded, needs to be changed!!
propagator(c_vec) = exp((c_vec[1] .* sx .+ c_vec[2] .* sy) .* (-Δt*π*im))

function J3(c_mat)
    c_mat = reshape(c_mat, (K, N))
    # for some reason Zygote really struggles with computing the gradient
    # if you don't do this fake complex number thing, thanks to Seth Axen
    # for this trick
    c_mat = complex.(real.(c_mat))
    test_forward = mapreduce(propagator, *, eachcol(c_mat))
    # and then compute the infidelity
    1 - abs2(σ0' * test_forward * ρ0)
end

# taken from this page
# https://fluxml.ai/Zygote.jl/dev/adjoints/
# this lets us compute the gradient without computing the Jacobian!
function my_func_with_grad(x)
    y, back = Zygote.pullback(J3, x)
    grady = back(1)[1]
    # reshape it for Optim!
    return reshape(grady, (K*N))
    # return y, grady
end

c_mat = rand(K, N) * 0.01
# this is an optimal solution so we can use it to test the functional works
# c_mat = c_mat .* 0 .+ 1/sqrt(2)/2
J3(c_mat)

# this command should work if everything is set up properly
my_func_with_grad(c_mat)
# set up the optimisation
res = optimize(J3, my_func_with_grad, reshape(c_mat, (10)) ,LBFGS(); inplace=false )
# run the optimisation
res.minimizer
# just a confirmation that it works!
J3(res.minimizer)

Zygote.refresh()
