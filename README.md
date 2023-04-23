# GeologicTime.jl

[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://Mikumikunisiteageru.github.io/GeologicTime.jl/stable)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://Mikumikunisiteageru.github.io/GeologicTime.jl/dev)
[![CI](https://github.com/Mikumikunisiteageru/GeologicTime.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/Mikumikunisiteageru/GeologicTime.jl/actions/workflows/CI.yml)
[![Codecov](https://codecov.io/gh/Mikumikunisiteageru/GeologicTime.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Mikumikunisiteageru/GeologicTime.jl)
[![Aqua.jl Quality Assurance](https://img.shields.io/badge/Aquajl-%F0%9F%8C%A2-aqua.svg)](https://github.com/JuliaTesting/Aqua.jl)

GeologicTime.jl is mainly designed to draw geologic time scale in a certain time interval using the function `drawtimescale`. This function relies on [PyPlot.jl](https://github.com/JuliaPy/PyPlot.jl), which needs to be manually installed and imported.

```julia
using GeologicTime
using PyPlot
figure(figsize=(5.4, 0.45))
drawtimescale(100, 0, [3, 4]; fontsize=8, texts = Dict(
	"Cretaceous" => "Cretaceous", "Paleogene" => "Paleogene", 
	"Neogene" => "Neogene", "Quaternary" => "Q.", 
	"Late Cretaceous" => "Late Cretaceous", "Paleocene" => "Paleoc.", 
	"Eocene" => "Eocene", "Oligocene" => "Oligoc.", "Miocene" => "Miocene", 
	"Pliocene" => "P.", "Pleistocene" => "P."))
gca().set_position([0.02, 0.05, 0.96, 0.9])
savefig("timescale.png", dpi=300)
```

The code above generates the following image.

![Geologic time scale from 100 Ma ago to now](https://github.com/Mikumikunisiteageru/GeologicTime.jl/blob/main/docs/illust/imggts.png)

In addition, the package also provides simple lookup functions such as `geounit`, `getcolor`, `getstart`, `getstop`, `getspan`, and `getgeotime`, whose usage is available in the [documentation](https://Mikumikunisiteageru.github.io/GeologicTime.jl/stable).

Code and documentation of GeologicTime.jl are released under the MIT License. However, all the data are based on materials from [Wikipedia](https://en.wikipedia.org/wiki/Geologic_time_scale) accessed on April 23, 2023, available under the CC-SA 3.0 License. Credit of relevant files including [data/wikipedia.html](https://github.com/Mikumikunisiteageru/GeologicTime.jl/blob/master/data/wikipedia.html) and its derivation [data/timescale.tsv](https://github.com/Mikumikunisiteageru/GeologicTime.jl/blob/master/data/timescale.tsv) is due to Wikipedia contributors.
