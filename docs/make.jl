# docs/make.jl

using GeologicTime

using Documenter
using PyPlot

makedocs(
	sitename = "GeologicTime.jl",
	pages = [
		"GeologicTime.jl" => "index.md",
		],
)

deploydocs(
    repo = "github.com/Mikumikunisiteageru/GeologicTime.jl.git",
	versions = ["stable" => "v^", "v#.#.#"]
)
