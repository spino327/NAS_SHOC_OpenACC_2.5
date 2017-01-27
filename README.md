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
