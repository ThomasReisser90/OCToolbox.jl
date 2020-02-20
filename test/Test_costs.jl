using OCToolbox

using Test
using QuantumInformation
using LinearAlgebra

# initial states
ψi = [1.0+0im, 0 + 0]
ψT = [0.0+0im, 1 + 0]

# initial unitary
Ui = Matrix{ComplexF64}(I, 2, 2)
# spin flip unitary
Uf = Matrix{ComplexF64}(I, 2, 2)
Uf[1,1] = Uf[2,2] = cos(π/2)
Uf[1,2] = -sin(π/2)
Uf[2,1] = sin(π/2)

@testset "Test_utils.jl" begin
    @test C1(Ui, Ui, 2) == 0
    @test C1(Ui, Uf, 2) == 1
    @test C2(ψT, ψT) == 0
    @test C2(ψT, ψi) == 1
end
