FROM continuumio/anaconda3:5.3.0

RUN apt-get update && \
  	apt-get install -y --no-install-recommends wget build-essential hdf5-tools && \
  	rm -rf /var/lib/apt/lists/* 

# install Julia

ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.3

RUN mkdir /opt/julia-${JULIA_VERSION} && \
	cd /tmp && \
	wget -q --no-check-certificate https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
	tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# install and precompile Julia packages

RUN julia -e 'import Pkg; Pkg.update()' && \
	julia -e 'import Pkg; Pkg.add("IJulia")' && \
	julia -e 'import Pkg; Pkg.add("HDF5")' && \
	julia -e 'import Pkg; Pkg.add("JLD")' && \
	julia -e 'import Pkg; Pkg.add("JSON")' && \
	julia -e 'import Pkg; Pkg.add("Plots")' && \
	julia -e 'import Pkg; Pkg.add("PyPlot")' && \
	julia -e 'import Pkg; Pkg.add("ProgressMeter")' && \
	julia -e 'import Pkg; Pkg.add("Clustering")' && \
	julia -e 'import Pkg; Pkg.add("StatsBase")' && \
	julia -e 'import Pkg; Pkg.add("Interpolations")' && \
	julia -e 'import Pkg; Pkg.add("IterTools")'

RUN julia -e 'using IJulia; IJulia.installkernel("Julia nodeps", "--depwarn=no")' && \
	julia -e 'using HDF5' && \
	julia -e 'using JLD' && \
	julia -e 'using JSON' && \
	julia -e 'using Plots' && \
	julia -e 'using PyPlot' && \
	julia -e 'using ProgressMeter' && \
	julia -e 'using Clustering' && \
	julia -e 'using StatsBase' && \
	julia -e 'using Interpolations' && \
	julia -e 'using IterTools'

# install Clp solver and JuMP for PL problems

RUN julia -e 'import Pkg; Pkg.add("Clp")' && \
	julia -e 'using Clp' && \
	julia -e 'import Pkg; Pkg.add("JuMP")' && \
	julia -e 'using JuMP'