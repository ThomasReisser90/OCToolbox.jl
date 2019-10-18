# module containing some ideas of how to implement grape
using QuantumOpticsBase
using OCToolbox
using Optim
using AutoGrad

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

# taken from a pull request
function jacobian(f)
    x -> begin
        m = length(f(x))
        hcat([grad(x->f(x)[i])(x) for i=1:m]...)'
    end
end

# compute the propagator in a fairly stupid way but I was having trouble before.
function propagator(c_n)
    sum = 0.0 * sz
    for (c, h) in zip(c_n, H_ctrl)
        sum += c * h
    end
    exp(-1im * (H0 + 1im * R + sum) * Δt)
end

function clip_controls(c_n)
    # ideally here we clip controls that exceed 1.0, since we're dealing with
    # everything in cartesian coordinates at the moment
    # probably worth thinking about rewriting stuff to use amplitude and phase
    # instead but I'm on a train
end

# if we have a Rabi frequency of 1MHz and we distribute this over
# the two cartesian controls then life can get a bit easier
# so lets make a nice array of values
c_vec = rand(K, N) #.* 0.0 .+ 1/sqrt(2)/2

# functional for testing, just a simple evolution that will be solved by GRAPE
function J2(c_vec)
    # assuming a flat vector is passed in then this is reshaped, not really necessary
    c_vec = reshape(c_vec, (K,N))
    # now we loop over each time slice and compute the propagators
    my_props = []
    for n = 1:N
        c_n = c_vec[:,n]
        append!(my_props, [propagator(reshape(c_vec[:,n], (1,K)))])
    end
    # initial state
    ρ0 = [1 + 0.0im, 0.0+0.0im]
    # target state
    σ0 = [0.0 + 0.0im, 1.0 + 0.0im]
    # now we time evolve our state
    test_forward = accumulate(*, reverse(my_props))[end]
    # and then compute the infidelity
    1 - abs2(σ0' * test_forward  * ρ0)
end

# compute the jacobian of J2 and we are done
J2(c_vec)

# using the function above we can compute the propagator easily
t = jacobian(J2)
# I wrapped this to try and get things working
function g(x)
    reshape(t(x .+ 0im), (10))
end
# testing that it calls properly
g(c_vec .+ 0im)

# this is basically how we should optimise it eventually (might not use Optim??)
res = optimize(J2, reshape(c_vec, (10)); inplace = false)
# then just check out the optimal output
J2(res.minimizer)


###########
# testing stuff
###########

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

# so we can correctly compute the gradient here
f3(x) = exp(3im*x[1]) + exp(4im*x[2])
zfn3 = grad(f3)
zfn3([1.0 1.0 + 0.0im])

f4(x) = exp(2*x)
zfn4 = grad(f4)
zfn4(I(2))

# realistic tests
f(x) = exp(-1im * (H0 + 1im*R + (x[1] * H_ctrl[1] + x[2] * H_ctrl[2]))*Δt)
t = jacobian(f)
t([1.0 + 0.0im,2.0])
f([1.0, 2.0])

t = jacobian(propagator)
t([1.0 + 0.0im, 2.0])
c_vec

t = jacobian(J2)
t(c_vec .+ 0im)



#### test using Buffer in Zygote as suggested by Alex

using Zygote
Buffer(xs, 5)
Zygote.Buffer(, 5, 5)

xs = [1,2,3,4]
buf = Zygote.Buffer(xs, length(xs), 5)
for i = 1:5
    buf[:, 1] = xs
end

xs = propagator(c_vec[:,1])

buf = Zygote.Buffer(xs, , 5)

buf[:,1] = reshape(xs, (4))

println(buf)

Zygote.refresh()

propagator(c_vec[:,1])


# inner_buf = Zygote.Buffer(sx, size(sx))
# inner_buf[:,:] = sx
# outer_buf = Zygote.Buffer(sx, 1, 5)
# outer_buf[1,1] = inner_buf

function J3(c_vec)
    # c_vec = reshape(c_vec, (K,N))
    # my_props = Zygote.Buffer(sx, length(sx), N)
    for n = 1:N
        my_props[:, 1] =
        c_n = c_vec[:,n]

        append!(my_props, [propagator(reshape(c_vec[:,n], (1,K)))])
    end
    ρ0 = [1 + 0.0im, 0.0+0.0im]
    σ0 = [0.0 + 0.0im, 1.0 + 0.0im]
    test_forward = accumulate(*, reverse(my_props))[end]
    1 - abs2(σ0' * test_forward  * ρ0)
end


test = Zygote.Buffer(sx, 2,2)

test[:,:] = sx
test

Zygote.forward_jacobian(J2, c_vec)

# there's still this DiffEqDiffTools thing that we need to work on
# is AD noticeably faster than well implemented FD?

using DiffEqDiffTools
DiffEqDiffTools.finite_difference_jacobian(J2, reshape(c_vec, (10)))

c_vec

J2(c_vec)
