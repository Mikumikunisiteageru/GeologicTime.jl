# src/pyplot.jl

export drawtimescale

"""
	drawtimescale(ax, 
		s::Real, t::Real=0.0, units::AbstractVector{<:Integer}=[3,4]; 
		facealpha=1.0, facezorder=-10, fillkwargs=Dict(), 
		edgealpha=1.0, lw=0.8, ls="-", edgecolor="k", 
			edgezorder=0, plotkwargs=Dict(), 
		texts=Dict(), ha="center", va="center", fontsize=10, textcolor="k", 
			textzorder=10, textkwargs=Dict()) :: Nothing
	drawtimescale(s::Real, t::Real=0.0, 
		units::AbstractVector{<:Integer}=[3,4]; kwargs...) :: Nothing

Draw a geologic time scale from `s` Ma ago to `t` Ma ago (default `0`, i.e. 
now) of specified `units` (default `[3, 4]`, i.e. period and epoch).

The first argument `ax` refers to a set of axes from PyPlot.jl. When it is 
omitted, current axes are applied.
"""
function drawtimescale(ax, 
		s::Real, t::Real=0.0, units::AbstractVector{<:Integer}=[3,4]; 
		facealpha=1.0, facezorder=-10, fillkwargs=Dict(), 
		edgealpha=1.0, lw=0.8, ls="-", edgecolor="k", 
			edgezorder=0, plotkwargs=Dict(), 
		texts=Dict(), ha="center", va="center", fontsize=10, textcolor="k", 
			textzorder=10, textkwargs=Dict())
	!isempty(units) && issorted(units; lt=<=) && issubset(units, 1:5) || 
		throw(ArgumentError(
			"`units` must be a non-empty sorted subset of `1:5`!"))
	s > t || throw(ArgumentError("`s` has to be greater (earlier) than `t`!"))
	sn = getgeotime.(s, units; bound=:forward)
	tn = getgeotime.(t, units; bound=:backward)
	all(sn .!= nothing) && all(tn .!= nothing) || 
		throw(ArgumentError(
			"geologic time scale of some `units` undefined on `[s,t]`!"))
	l = length(units)
	for i = 1:l
		name = sn[i]
		flag = false
		while !flag
			flag = name == tn[i]
			start = min(getstart(name), s)
			stop = max(getstop(name), t)
			ax.fill_between([start, stop], [i, i], [i+1, i+1]; 
				lw=0, fc=getcolor(name), alpha=facealpha, 
				zorder=facezorder, fillkwargs...)
			flag || ax.plot([stop, stop], [i, i+1]; 
				ls=ls, lw=lw, color=edgecolor, alpha=edgealpha, 
				zorder=edgezorder, plotkwargs...)
			haskey(texts, name) && ax.text((start+stop)/2, i+1/2, texts[name], 
				ha=ha, va=va, fontsize=fontsize, color=textcolor, 
				zorder=textzorder, textkwargs...)
			name = next(name)
		end
		i > 1 && ax.plot([s, t], [i, i]; 
			ls=ls, lw=lw, color=edgecolor, alpha=edgealpha, 
			zorder=edgezorder, plotkwargs...)
	end
	ax.plot([(s+t)/2, s, s, t, t, (s+t)/2], [1, 1, 1+l, 1+l, 1, 1]; 
		ls=ls, lw=lw, color=edgecolor, alpha=edgealpha, 
		zorder=edgezorder, plotkwargs...)
	ax.set_xlim(s, t)
	ax.set_ylim(1+l, 1)
	ax.set_xticks([])
	ax.set_yticks([])
	ax.grid("off")
end
drawtimescale(s::Real, t::Real=0.0, units::AbstractVector{<:Integer}=[3,4]; 
	kwargs...) = drawtimescale(PyPlot.gca(), s, t, units; kwargs...)
