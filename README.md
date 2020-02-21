[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Bzzzt90.github.io/OCToolbox.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Bzzzt90.github.io/OCToolbox.jl/dev)
[![Build Status](https://travis-ci.com/Bzzzt90/OCToolbox.jl.svg?branch=master)](https://travis-ci.com/Bzzzt90/OCToolbox.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/Bzzzt90/OCToolbox.jl?svg=true)](https://ci.appveyor.com/project/Bzzzt90/OCToolbox-jl)
[![Codecov](https://codecov.io/gh/Bzzzt90/OCToolbox.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Bzzzt90/OCToolbox.jl)
[![Coveralls](https://coveralls.io/repos/github/Bzzzt90/OCToolbox.jl/badge.svg?branch=master)](https://coveralls.io/github/Bzzzt90/OCToolbox.jl?branch=master)
[![Build Status](https://api.cirrus-ci.com/github/Bzzzt90/OCToolbox.jl.svg)](https://cirrus-ci.com/github/Bzzzt90/OCToolbox.jl)


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

- [ x ] GRAPE
- [ ] GOAT
- [ ] GROUP
- [ ] dCRAB
- [ ] Krotov


## Can I help?

Yes! Please reach out to either of us via email or on github if you can offer help or advice, we are both new to all of this!

## Some Ideas/Discussions
 - Discuss general ideas around syntax, how do we structure the code and call algorithms?
 - Make sure everything works with SparseMatrices
 - Are there any useful benchmarks that we can run on a users computer when they install to estimate the algorithms that they can use?
 - Incorporating noise, Thomas has ideas? Base optimisation on S(ω)
 - Optimise the shit out of the code so that every algorithm is as fast as we can make it
 - Python bindings! Should offer these as soon as possible
 - Switch algorithms mid optimisation? Start many algorithms at once?
 - Open system simulators
 - DOCUMENTATION! Easier if we write something as we go instead of half ass it at the end!
