# test/runtests.jl

using GeologicTime
using PyPlot
using Test
import Aqua

Aqua.test_all(GeologicTime)

@testset "constants" begin
	@test length(GeologicTime.UNITS) == 5
	@test size(GeologicTime.TIMESCALE) == (171, 4)
	@test length(GeologicTime.NAMEINDEX) == 171
	@test GeologicTime.NAMEINDEX["Furongian"] == 67
	@test length(GeologicTime.EARLIESTS) == 5
	@test length(GeologicTime.UNITSTARTS) == 5
	@test length(GeologicTime.UNITSTOPS) == 5
end

@testset "getunit" begin
	@test getunit("Furongian") == "Epoch"
	@test_throws KeyError getunit("Other")
end

@testset "getcolor" begin
	@test getcolor("Furongian") == "#B3E095"
	@test_throws KeyError getcolor("Other")
end

@testset "getstart" begin
	@test getstart("Holocene") == 0.0117
	@test getstart("Furongian") == 497.0
	@test getstart("Terreneuvian") == 538.8
	@test_throws KeyError getstart("Other")	
end

@testset "getstop" begin
	@test getstop("Phanerozoic") == 0.0
	@test getstop("Holocene") == 0.0
	@test getstop("Furongian") == 485.4
	@test getstop("Terreneuvian") == 521.0
	@test_throws KeyError getstop("Other")	
end

@testset "getspan" begin
	@test getspan("Furongian") == (497.0, 485.4)
	@test_throws KeyError getspan("Other")	
end

@testset "getgeotime" begin
	@test getgeotime(0.0, 4; bound=:forward) == "Holocene"
	@test getgeotime(0.0, 4; bound=:backward) == "Holocene"
	@test getgeotime(485.4, 4; bound=:forward) == "Early Ordovician"
	@test getgeotime(485.4, 4; bound=:backward) == "Furongian"
	@test getgeotime(486.0, 4; bound=:forward) == "Furongian"
	@test getgeotime(486.0, 4; bound=:backward) == "Furongian"
	@test getgeotime(497.0, 4) == "Furongian"
	@test getgeotime(497.0, 4; bound=:forward) == "Furongian"
	@test getgeotime(497.0, 4; bound=:backward) == "Miaolingian"
	@test getgeotime(538.8, 4; bound=:forward) == "Terreneuvian"
	@test getgeotime(538.8, 4; bound=:backward) == "Terreneuvian"
	@test getgeotime(539.0, 4; bound=:forward) == nothing
	@test getgeotime(539.0, 4; bound=:backward) == nothing
	@test_throws ArgumentError getgeotime(100.0, 6)
	@test_throws ArgumentError getgeotime(100.0, 6; bound=:forward)
	@test_throws ArgumentError getgeotime(100.0, 6; bound=:backward)
	@test_throws ArgumentError getgeotime(100.0, 4; bound=:middle)
	@test getgeotime(0.0; bound=:forward) == ["Eon" => "Phanerozoic", 
		"Era" => "Cenozoic", "Period" => "Quaternary", 
		"Epoch" => "Holocene", "Age" => "Meghalayan"]
	@test getgeotime(0.0; bound=:backward) == ["Eon" => "Phanerozoic", 
		"Era" => "Cenozoic", "Period" => "Quaternary", 
		"Epoch" => "Holocene", "Age" => "Meghalayan"]
	@test getgeotime(538.8; bound=:forward) == ["Eon" => "Phanerozoic", 
		"Era" => "Paleozoic", "Period" => "Cambrian", 
		"Epoch" => "Terreneuvian", "Age" => "Fortunian"]
	@test getgeotime(538.8; bound=:backward) == ["Eon" => "Proterozoic", 
		"Era" => "Neoproterozoic", "Period" => "Ediacaran", 
		"Epoch" => "Terreneuvian", "Age" => "Fortunian"]
	@test getgeotime(2500.0; bound=:forward) == ["Eon" => "Proterozoic", 
		"Era" => "Paleoproterozoic", "Period" => "Siderian"]
	@test getgeotime(2500.0; bound=:backward) == ["Eon" => "Archean", 
		"Era" => "Neoarchean", "Period" => "Siderian"]
	@test getgeotime(4567.3; bound=:forward) == ["Eon" => "Hadean"]
	@test getgeotime(4567.3; bound=:backward) == ["Eon" => "Hadean"]
	@test getgeotime(4567.8; bound=:forward) == []
	@test getgeotime(4567.8; bound=:backward) == []
end

@testset "prev" begin
	@test GeologicTime.prev("Hadean") == nothing
	@test GeologicTime.prev("Phanerozoic") == "Proterozoic"
end

@testset "next" begin
	@test GeologicTime.next("Hadean") == "Archean"
	@test GeologicTime.next("Phanerozoic") == nothing
end

@testset "drawtimescale" begin
	@test_throws ArgumentError drawtimescale(nothing, 100, 0, Int[])
	@test_throws ArgumentError drawtimescale(nothing, 100, 0, [3, 3])
	@test_throws ArgumentError drawtimescale(nothing, 100, 0, [4, 3])
	@test_throws ArgumentError drawtimescale(nothing, 100, 0, [3, 6])
	@test_throws ArgumentError drawtimescale(nothing, 100, 100)
	@test_throws ArgumentError drawtimescale(nothing, 100, 101)
	@test_throws ArgumentError drawtimescale(nothing, 1000, 0, [5])
	@test drawtimescale(100, 0, [3, 4]) == nothing
	PyPlot.close()
	ca = gca()
	@test drawtimescale(ca, 100, 0, [3, 4]) == nothing
	PyPlot.close()
	@test drawtimescale(100, 0, [3, 4]; fontsize=8, texts = Dict(
		"Cretaceous" => "Cretaceous", "Paleogene" => "Paleogene", 
		"Neogene" => "Neogene", "Quaternary" => "Q", 
		"Late Cretaceous" => "Late Cretaceous", "Paleocene" => "Paleoc.", 
		"Eocene" => "Eocene", "Oligocene" => "Oligoc.", "Miocene" => "Miocene", 
		"Pliocene" => "P", "Pleistocene" => "P")) == nothing
	PyPlot.close()
end
