using DelimitedFiles

"""
This file contains a selection of tools to interact with this module to make optimisation
easier.

These include export functions for pulses an plotting functions
"""
function export_pulse(filename, pulse)
    open(filename, "w") do io
        writedlm(io, [pulse.T pulse.Ω pulse.ϕ])
    end
end

function export_pulse(filename, T, Ω, ϕ)
    open(filename, "w") do io
        writedlm(io, [T Ω ϕ])
    end
end

"""
Should really offer in place versions too but need to see how that works!
"""
function plot_pulse(pulse)
    # noice
end

function plot_pulse(T, Ω, ϕ; res = 1000)

end
