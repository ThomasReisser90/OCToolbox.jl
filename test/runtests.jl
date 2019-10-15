using SafeTestsets

@safetestset "utility tests" begin include("Test_utils.jl") end
@safetestset "Frechet tests" begin include("Test_Frechet.jl") end
@safetestset "Evolution tests" begin include("Test_Evolution.jl") end
# using OCToolbox
# using Test
#
# @testset "Frechet_Exponential.jl" begin
#     M = [log(1) 0 0; 0 log(1) 0; 0 0 log(1)]
#     @test OCToolbox.expm_frechet(M, M) ==
#     ([1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0],
#     [0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0])
#     # implement more and better tests here!!!
# end
