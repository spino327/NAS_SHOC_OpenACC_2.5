# NAS_NPB_OpenACC_2.5

Code repository for the benchmarks discussed in our paper "Exploring translation of OpenMP to OpenACC 2.5: Lessons Learned"

## Cloning the repo

We use git-submodules to checkout the the individual benchmark suites into the global project. For more info in what this means at <a href="https://git-scm.com/book/en/v2/Git-Tools-Submodules" target="blank">Git-Tools-Submodules</a>. Thus, to successfully checkout all the required files to compile and run the benchmarks you need to do:

* You can clone recursively the repo:

> $ git clone --recursive https://github.com/spino327/NAS_SHOC_OpenACC_2.5  

or 

* You can clone the repo as always and execute a couple more git commands:

> $ git clone https://github.com/spino327/NAS_SHOC_OpenACC_2.5  
> $ cd NAS_SHOC_OpenACC_2.5  
> $ git submodule init  
> $ git submodule update  

## Make individual benchmarks

You can pass to the make command the following variables. Alternatively, you can export the env.

* CC: compiler to use.  
* DEFINES: string to be passed to make (assuming you have a DEFINES variable within your makefile).  
* TA: architecture for OpenACC (as the -ta flag for pgi). E.g. `TA=multicore` or `TA=nvidia,cc35`.  
* EXTRA_CFLAGS: extra flags to pass to the c compiler.  
* EXTRA_CLINKFLAGS: extra flags to pass to linker.
* PXM: Program execution model to use. E.g. `PXM=acc`, `PXM=omp`

### NAS
Compiling OpenACC for multicore: `make CC=pgcc TA=multicore CLASS=A`.
Compiling OpenACC for GPU: `make CC=pgcc CLASS=A`.
Compiling OpenMP: `make CC=pgcc CLASS=A`.

### SHOC
Compiling the OpenACC version for the multicore: `make -f Makefile.acc CC=pgc++ TA=multicore`.
Compiling the OpenACC version for the GPU: `make -f Makefile.acc CC=pgc++`.
Compiling the OpenMP version: `make -f Makefile.omp CC=pgc++`.

### NPB-CUDA
Compile with `make`

### NPB-OMP-C
Compile with `make CC=pgcc CLASS=A`
