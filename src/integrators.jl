"""
Wouldn't it be nice if we had a selection of integrators, like Thomas and I
discussed all those months ago!
"""

"""
Compute the piecewise constant propagator for a single time slice of duration
    dt. The function makes certain assumptions about the input arguments as described
    below.

    In order to make the multiplication easy the Hctrl array should be of the form:
    Hctrl = [sx, sy]
    and the control array should be an array of the corresponding length.

    The return type of this function will be the same type as the static Hamiltonian provided.
    We also assume that internally that everything maintains the same dimensions
"""
function pw_integrate(H0::T, Hctrl, control, dt)::T where T
    H::T = H0
    for i = 1:length(control)
        H += (Hctrl[i] .* control[i])
    end
    exp((-im*dt) .* H)
end


# we should write this to use concrete_solve so it'll work with Zygote in future
function ode_integrate()

end

# include an example of a master equation solver
function me_integrate()

end
