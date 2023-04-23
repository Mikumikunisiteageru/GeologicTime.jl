# src/GeologicTime.jl

module GeologicTime
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end GeologicTime

using DelimitedFiles
using Requires

export getstart, getstop, getspan, getcolor, getunit
export getgeotime

UNITS = ["Eon", "Era", "Period", "Epoch", "Age"]

DATAPATH = joinpath(pkgdir(GeologicTime), "data")
TIMESCALE = readdlm(joinpath(DATAPATH, "timescale.tsv"), '\t')

allunique(TIMESCALE[:, 2]) || error("package data broken!")

NAMEINDEX = Dict(TIMESCALE[:, 2] .=> 1 : size(TIMESCALE, 1))
EARLIESTS = Dict(TIMESCALE[:, 1] .=> TIMESCALE[:, 4])
UNITSTARTS = Dict(TIMESCALE[end:-1:1, 1] .=> size(TIMESCALE, 1) : -1 : 1)
UNITSTOPS = Dict(TIMESCALE[:, 1] .=> 1 : size(TIMESCALE, 1))

"""
	getunit(name::AbstractString) :: String

Find the geochronologic unit of the geologic time.

# Example
```jldoctest
julia> getunit("Jurassic")
"Period"
```
"""
getunit(name::AbstractString) = UNITS[TIMESCALE[NAMEINDEX[name], 1]]

"""
	getcolor(name::AbstractString) :: String

Find the characteristic color (in hex value) for the geologic time.

# Example
```jldoctest
julia> getcolor("Jurassic")
"#34B2C9"
```
"""
getcolor(name::AbstractString) = TIMESCALE[NAMEINDEX[name], 3]

"""
	getstart(name::AbstractString) :: Float64

Find the start time (in million year) of the geologic time.

# Example
```jldoctest
julia> getstart("Jurassic")
201.4
```
"""
getstart(name::AbstractString) = TIMESCALE[NAMEINDEX[name], 4]

"""
	getstop(name::AbstractString) :: Float64

Find the stop time (in million year) of the geologic time.

# Example
```jldoctest
julia> getstop("Jurassic")
145.0
```
"""
getstop(name::AbstractString) = 
	next(name) == nothing ? 0.0 : TIMESCALE[NAMEINDEX[name]-1, 4]

"""
	getspan(name::AbstractString) :: NTuple{2, Float64}

Find the time span (both ends in million year) of the geologic time.

# Example
```jldoctest
julia> getspan("Jurassic")
(201.4, 145.0)
```
"""
getspan(name::AbstractString) = (getstart(name), getstop(name))

"""
	getgeotime(millionyears::Real, unit::Integer; bound=:forward) :: 
		Union{String, Nothing}
	getgeotime(millionyears::Real; bound=:forward) :: 
		Vector{Pair{String, String}}

Find the geologic time of a certain `unit` containing the given time moment 
(in million year). 

The argument `unit` must be `1` (eon), `2` (era), `3` (period), `4` (epoch), 
or `5` (age); `bound` must be `:forward` (default) or `:backward`. When `unit` 
is omitted, results of all possible units are packed up and returned.

When no geologic time contains the given time moment, `nothing` is returned 
if `unit` is specified, or the result is simply omitted in the returned vector. 

# Example
```jldoctest
julia> getgeotime(39, 3)
"Paleogene"

julia> getgeotime(39)
5-element Vector{Pair{String, String}}:
    "Eon" => "Phanerozoic"
    "Era" => "Cenozoic"
 "Period" => "Paleogene"
  "Epoch" => "Eocene"
    "Age" => "Bartonian"
``` 
"""
function getgeotime(millionyears::Real, unit::Integer; bound=:forward)
	1 <= unit <= 5 || throw(ArgumentError("`unit` must be " * 
		"`1` (eon), `2` (era), `3` (period), `4` (epoch), or `5` (age)."))
	bound in [:forward, :backward] || throw(ArgumentError(
		"`bound` must be `:forward` (default) or `:backward`."))
	gt = bound == :forward ? (>=) : (>)
	0.0 <= millionyears <= EARLIESTS[unit] || return nothing
	s = UNITSTARTS[unit]
	t = UNITSTOPS[unit]
	while t - s > 1
		m = (s + t) >> 1
		if gt(TIMESCALE[m, 4], millionyears)
			t = m
		else
			s = m
		end
	end
	return TIMESCALE[gt(TIMESCALE[s, 4], millionyears) ? s : t, 2]
end
function getgeotime(millionyears::Real; bound=:forward)
	kvpairs = Pair{String, String}[]
	for unit = 1:5
		geotime = getgeotime(millionyears, unit; bound=bound)
		geotime != nothing && push!(kvpairs, UNITS[unit] => geotime)
	end
	return kvpairs
end

"""
	prev(name::AbstractString) :: Union{String, Nothing}

Find the previous (earlier) geologic time of the same unit. When the specified 
geologic time has no predecessor, `nothing` is returned.

# Example
```jldoctest
julia> GeologicTime.prev("Phanerozoic")
"Proterozoic"

julia> GeologicTime.prev("Hadean")
``` 
"""
function prev(name::AbstractString)
	i = NAMEINDEX[name]
	return i == size(TIMESCALE, 1) || TIMESCALE[i+1, 1] != TIMESCALE[i, 1] ? 
		nothing : TIMESCALE[i+1, 2]
end

"""
	next(name::AbstractString) :: Union{String, Nothing}

Find the next (later) geologic time of the same unit. When the specified 
geologic time has no successor, `nothing` is returned.

# Example
```jldoctest
julia> GeologicTime.next("Phanerozoic")

julia> GeologicTime.next("Hadean")
"Archean"
``` 
"""
function next(name::AbstractString)
	i = NAMEINDEX[name]
	return i == 1 || TIMESCALE[i-1, 1] != TIMESCALE[i, 1] ? 
		nothing : TIMESCALE[i-1, 2]
end

function __init__()
    @require PyPlot="d330b81b-6aea-500a-939a-2ce795aea3ee" include("pyplot.jl")
end

end # module GeologicTime
