# src/GeologicTime.jl

module GeologicTime

using DelimitedFiles

export getstart, getstop, getspan, getcolor, getunit
export getgeotime

UNITS = ["Eon", "Era", "Period", "Epoch", "Age"]

DATAPATH = joinpath(pkgdir(GeologicTime), "data")
TIMESCALE = readdlm(joinpath(DATAPATH, "TIMESCALE.tsv"), '\t')

allunique(TIMESCALE[:, 2]) || error("package data broken!")

NAMEINDEX = Dict(TIMESCALE[:, 2] .=> 1 : size(TIMESCALE, 1))
EARLIESTS = Dict(TIMESCALE[:, 1] .=> TIMESCALE[:, 4])
UNITSTARTS = Dict(TIMESCALE[end:-1:1, 1] .=> size(TIMESCALE, 1) : -1 : 1)
UNITSTOPS = Dict(TIMESCALE[:, 1] .=> 1 : size(TIMESCALE, 1))

getunit(name::AbstractString) = UNITS[TIMESCALE[NAMEINDEX[name], 1]]

getcolor(name::AbstractString) = TIMESCALE[NAMEINDEX[name], 3]

getstart(name::AbstractString) = TIMESCALE[NAMEINDEX[name], 4]

function getstop(name::AbstractString)
	i = NAMEINDEX[name]
	return (i == 1 || TIMESCALE[i-1, 1] != TIMESCALE[i, 1]) ? 
		0.0 : TIMESCALE[i-1, 4]
end

getspan(name::AbstractString) = (getstart(name), getstop(name))

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

end # module GeologicTime
