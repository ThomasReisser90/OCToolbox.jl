# OCToolbox

OCToolbox.jl aims to be a collection of fast optimal control algorithms implemented in Julia.

## What is Optimal Control?

A selection of numerical methods which can be used to enhance our control of a quantum system in order to reach some goal.

## Why Julia?

Julia is a fast and flexible programming language designed for numerical computation making it an excellent candidate for this type of project. I think that it’ll be possible to leverage multiple dispatch to enhance things too.

## Why another package?

There are lots of groups that are interested in this and I feel it would be useful to have reference implementations of algorithms, that are fast, to compare them against one another.

## Roadmap

There are several algorithms that we would like to include:

- [ ] GRAPE
- [ ] GOAT
- [ ] GROUP
- [ ] dCRAB
- [ ] Krotov


## Can I help?

Yes! Please reach out to me either via email or on github if you can offer help or advice, we are new to all of this!

## Some Ideas/Discussions
 - Discuss general ideas around syntax, how do we structure the code and call algorithms?
 - Make sure everything works with SparseMatrices
 - Are there any useful benchmarks that we can run on a users computer when they install to estimate the algorithms that they can use?
 - Incorporating noise, Thomas has ideas? Base optimisation on S(ω)
 - Optimise the shit out of the code so that every algorithm is as fast as we can make it
 - Python bindings! Should offer these as soon as possible
 - Web interface? Add some backend so that you can monitor the progress of a running algorithm?
 - Switch algorithms mid optimisation? Start many algorithms at once?
 - Closed and open system simulators
 - DOCUMENTATION! Easier if we write something as we go instead of half ass it at the end!
 - SOMEONE NEEDS TO CLARIFY WITH ME WHEN WE USE RELATIVE IMPORT PATHS and when we use the whole module, then we can tidy stuff up!
 - Export in each module or not?
