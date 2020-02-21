"""
A note on the thinking behind this module:

we want to make it as simple as possible to optimise stuff, thats the goal here
in order to do that is it worth adding in some helper structs that store bits
of information that are useful?

It's optional, we use multiple dispatch so that familiar users can do it manually
but if you want something fast then we handle everything internally?

Previously the big problem was trying to do too much. We should make it play
nicely with something like pulse_sim.jl but the two should be separate. Pulse_sim
is for the simulation of pulses and pulse sequences efficiently.

This is for numerical optimal control and not that. Definitely need to have interop though
    so that I can keep writing pulse sequences there but use this to optimise them
    as we see fit in future.
"""

#abstract type Problem end

# abstract type ClosedSystem <: Problem end

"""
Store some pieces of information about your problem in this handy
and barely typed struct. We need to keep things flexible but also pleasant to use
"""
struct ProblemInfo
    # dimensions of your quantum system, useful to know to verify Hams make sense
    dim::Int
    # whether you've tried to optimise it
    opt::Bool
    # result of the optimisation attempt, useful for obvious reasons
    res

    # nervous about including these, maybe its better that the user really defines
    # all this stuff themselves. Don't want to over engineer things
    # drift Hamiltonian/Hamiltonians
    H_drift
    # control Hamiltonian/Hamiltonians
    H_ctrl
    # # I would like to keep a space for a full time dependent Hamiltonian, so that we
    # # can integrate stuff nicely!
    # full_Hamiltonian
    # timestep? would make it possible to use integrator quickly
    timestep
    # total time
    T
    # functional, here we can assume that things work
    functional
end

"""
I'm not sure that this is actually the right way to go, unless we copy the values
out of this struct and into the code directly and just use this to sort of save
    the state of the code as it stands.
"""
