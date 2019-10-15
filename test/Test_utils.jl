using OCToolbox
using QuantumOpticsBase
using Test

b = SpinBasis(1//2)
sx = sigmax(b)
sy = sigmay(b)
sz = sigmaz(b)

@testset "Test_utils.jl" begin
    @test commutator(sx, sx) == 0.0*sx
    @test commutator(sx, sy) == 2.0im*sz
end
