FROM continuumio/anaconda3:5.3.0

RUN apt-get update && \
  	apt-get install -y --no-install-recommends wget hdf5-tools && \
  	rm -rf /var/lib/apt/lists/* 


# install Julia

ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=0.6.4

RUN mkdir /opt/julia-${JULIA_VERSION} && \
	cd /tmp && \
	wget -q --no-check-certificate https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
	tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# install and precompile Julia packages

RUN julia -e 'Pkg.init()' && \
	julia -e 'Pkg.add("IJulia")' && \
	julia -e 'Pkg.add("HDF5")' && \
	julia -e 'Pkg.add("JLD")' && \
	julia -e 'Pkg.add("Plots")' 

RUN julia -e 'using IJulia' && \
	julia -e 'using HDF5' && \
	julia -e 'using JLD' && \
	julia -e 'using Plots'
