using OCToolbox
using QuantumOpticsBase
using Test

b = SpinBasis(1//2)
sx = sigmax(b)
sy = sigmay(b)
sz = sigmaz(b)
example_control = [0.810635963493793
, 0.46484987867321426
, 0.34970273151618936
, 0.7916035280985718
, 0.3613862392184721
, 0.619927796151712
, 0.6967410801849956
, 0.055413818931025594
, 0.5452231997511754
, 0.3901904774054561]

@testset "Test_utils.jl" begin
    @test commutator(sx, sx) == 0.0*sx
    @test commutator(sx, sy) == 2.0im*sz
    @test count(x->x==0.5, clip_controls(example_control, 0.5)) == 5


end
