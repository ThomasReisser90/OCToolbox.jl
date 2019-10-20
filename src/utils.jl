# utility functions
# using LinearAlgebra
using .pulses
using .cl_sys_problems

# might want to store the Pauli matrices here
# also want a function to expand the control matrices properly

# might want to specify types here
function commutator(a, b)
    a * b - b * a
end

# function to plot a pulse, in theory all pulses should implement the same
# interface so we should be fine here. Might be worth seeing what the actual
# interface of Plots.jl is so that we adhere to things there
function plot(p::Pulse, res = 100)
    t = collect(range(0, p.duration, length = res))
    (amp, ph) = p.(t)
    plot(t, amp)
    plot!(t, ph)
end

# we could think about what you might want to plot when you plot a problem
# then design something to plot everything around that. I think you might want
# to plot the error as a function of iteration number, your pulse, etc.
function plot(p::Problem)
    println("I don't work yet")
end

# at some point we might want a pure Julia version of expm instead of just using exp
# function expm(A)
#     dim = size(A)[1]
#     I(dim) + A + A^2 ./2 + A^3 ./3
# end

function clip_controls(controls, clip_val, ub=false)
    # clip a vector of controls if they exceed the bound clip_val
    # if ub is true then clip values if the absolute value exceeds clip_val
    # interface definitely needs changed!
    map(x->(abs(x) <= clip_val) ?  x : clip_val, controls)
end
