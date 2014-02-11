pldi2014-artifact
=================

Welcome to the artifact evaluation bundle for "Taming the Parallel
Effect Zoo".  There are three components to this bundle:

  * Benchmark results
  * LVish code examples
  * LVish documentation
  
_LVars_ are monotonically growing, lattice-based data structures for
deterministic parallel programming. _LVish_ is a Haskell library for
programming with LVars.
  
First, follow the
[instructions for downloading and building the artifact bundle](http://www.cs.indiana.edu/~lkuper/effectzoo/).
Doing so will install LVish and its dependencies, build the LVish
documentation and examples, and run the benchmarks.

## Benchmark results 

### PhyBin results

Benchmark results for _PhyBin_, the bioinformatics application
described in section 7.1 of the paper, should appear in
`phybin_results.txt`.

### Transformer results

Benchmark results for evaluating monad tranformer overhead, described
in section 7.2 of the paper, should appear in
`transformer_results.txt`.

### Merge sort results

Benchmark results for parallel merge sort in LVish, described in section 7.3 of
the paper, should appear in

  * `hs_mergesort_results.txt`
  * `c_mergesort_results.txt`
  
Each of those files will contain three numbers, one per line, which
are running times (in seconds) on 1, 2, and 4 cores, respectively.
`c_mergesort_results.txt` is the results from the version that bottoms
out with a library call to a sequential C sort (the version marked as
"ParST/C" in Figure 5 of the paper); `hs_mergesort_results.txt` is the
pure Haskell "ParST/HSonly" version in the table in Figure 5 of the
paper).

## LVish documentation

The Haddock-generated HTML documentation will appear in

  * `.cabal-sandbox/doc/html/Control-LVish.html`
  
## LVish code examples

The directory `LVish-examples/2.0/` contains a variety of toy examples
of LVish programs.  See `LVish-examples/2.0/README.md` for more
details.
