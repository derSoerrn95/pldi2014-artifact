
MONAD_PAR_PKGS=monad-par/monad-par monad-par/monad-par-extras monad-par/abstract-par monad-par/examples/

LVISH_PKGS=LVish_repo/haskell/par-classes LVish_repo/haskell/lvish LVish_repo/haskell/par-transformers LVish_repo/haskell/par-collections LVish_repo/haskell/par-transformers/bench

PHYBIN=PhyBin/

CABAL_ARGS= --enable-documentation --disable-library-profiling --disable-executable-profiling -j

SANDBOX=$(shell pwd)/.cabal-sandbox/

BIN=$(SANDBOX)/bin/

default: rebuild

build: submod sandbox
	cabal install $(CABAL_ARGS) -O2  vector vector-algorithms
	$(MAKE) rebuild

rebuild:
	cabal install $(CABAL_ARGS) --reinstall --force-reinstall -f-fusion -f-hydra ./HSBencher ${LVISH_PKGS} ${MONAD_PAR_PKGS} ${PHYBIN} 

examples:
	cabal install LVish-examples/2.0

# This takes a while.
everything: build examples phybin_bench mergesort_bench transformer_bench

#------------------------------------------------------------
# Bench 1: Phybin

PHYBIN_CMD=$(BIN)/phybin-par -n150 --single --rfdist ./hashrf/30.hashrf-6.0.0-dist-seed-option/examples/150-taxa-1000-trees.tre +RTS -K100M -RTS

phybin_bench:
#	for ((i=1; i<=4; i++)); do $(PHYBIN_CMD) +RTS -N1 > ./PhyBin/phybin_out1.txt; done
	$(PHYBIN_CMD) +RTS -N1 > ./PhyBin/phybin_out1.txt
	$(PHYBIN_CMD) +RTS -N2 > ./PhyBin/phybin_out2.txt
	$(PHYBIN_CMD) +RTS -N3 > ./PhyBin/phybin_out3.txt
	$(PHYBIN_CMD) +RTS -N4 > ./PhyBin/phybin_out4.txt
#	cat ./PhyBin/phybin_out?.txt | grep "Time to compute" > phybin_results.txt
	cat ./PhyBin/phybin_out1.txt | grep "Time to compute" > phybin_results.txt
	cat ./PhyBin/phybin_out2.txt | grep "Time to compute" >> phybin_results.txt
	cat ./PhyBin/phybin_out3.txt | grep "Time to compute" >> phybin_results.txt
	cat ./PhyBin/phybin_out4.txt | grep "Time to compute" >> phybin_results.txt

#------------------------------------------------------------
# Bench 2: Transformer overheads

transformer_bench: 
	(cd monad-par/examples; ./generate_cabal.sh)
	(cd monad-par/examples; $(BIN)/run_benchmark_monadpar --keepgoing --desktop --lvish --lvish-state --lvish-cancel --nproc=4)
	cp monad-par/examples/results_*.dat transformer_results.txt


#------------------------------------------------------------
# Bench 3: Mergesort

MERGESORT_BENCH=$(BIN)/run_benchmark_mergesort

MERGESORT_CMD=$(BIN)/test-mergesort-parST 25 8192 8192 
HS_MERGESORT_CMD=$(MERGESORT_CMD) VAMSort MPMerge
C_MERGESORT_CMD=$(MERGESORT_CMD) CSort CMerge

PKG=

mergesort_setup:
	mkdir -p mergesort/
	cabal install LVish_repo/haskell/par-transformers/bench/
	cabal install LVish_repo/haskell/par-transformers/bench/mergesort/

mergesort_bench: mergesort_setup
	$(HS_MERGESORT_CMD) +RTS -N1 > mergesort/hs_mergesort1.txt
	$(HS_MERGESORT_CMD) +RTS -N2 > mergesort/hs_mergesort2.txt
	$(HS_MERGESORT_CMD) +RTS -N4 > mergesort/hs_mergesort4.txt
	$(C_MERGESORT_CMD) +RTS -N1 > mergesort/c_mergesort1.txt
	$(C_MERGESORT_CMD) +RTS -N2 > mergesort/c_mergesort2.txt
	$(C_MERGESORT_CMD) +RTS -N4 > mergesort/c_mergesort4.txt
	cat ./mergesort/hs_mergesort*.txt | grep "SELF" > hs_mergesort_results.txt
	cat ./mergesort/c_mergesort*.txt | grep "SELF" > c_mergesort_results.txt

mergesort_bench_large: mergesort_setup
	$(MAKE) mergesort_bench_large_hs
	$(MAKE) mergesort_bench_large_c
	cat ./mergesort/hs_mergesort*.txt | grep "SELF" > hs_mergesort_results.txt
	cat ./mergesort/c_mergesort*.txt | grep "SELF" > c_mergesort_results.txt

mergesort_bench_large_hs:
	$(HS_MERGESORT_CMD) +RTS -N1 > mergesort/hs_mergesort1.txt
	$(HS_MERGESORT_CMD) +RTS -N2 > mergesort/hs_mergesort2.txt
	$(HS_MERGESORT_CMD) +RTS -N4 > mergesort/hs_mergesort4.txt
	$(HS_MERGESORT_CMD) +RTS -N6 > mergesort/hs_mergesort6.txt
	$(HS_MERGESORT_CMD) +RTS -N8 > mergesort/hs_mergesort8.txt
	$(HS_MERGESORT_CMD) +RTS -N10 > mergesort/hs_mergesort10.txt
	$(HS_MERGESORT_CMD) +RTS -N12 > mergesort/hs_mergesort12.txt
mergesort_bench_large_c:
	$(C_MERGESORT_CMD) +RTS -N1 > mergesort/c_mergesort1.txt
	$(C_MERGESORT_CMD) +RTS -N2 > mergesort/c_mergesort2.txt
	$(C_MERGESORT_CMD) +RTS -N4 > mergesort/c_mergesort4.txt
	$(C_MERGESORT_CMD) +RTS -N6 > mergesort/c_mergesort6.txt
	$(C_MERGESORT_CMD) +RTS -N8 > mergesort/c_mergesort8.txt
	$(C_MERGESORT_CMD) +RTS -N10 > mergesort/c_mergesort10.txt
	$(C_MERGESORT_CMD) +RTS -N12 > mergesort/c_mergesort12.txt

#------------------------------------------------------------

sandbox:
	# cabal sandbox init
	./link_sandboxes.sh $(SANDBOX)

clean: submod clean-sandbox 

submod:
	git submodule init
	git submodule update --recursive

clean-sandbox:
	cabal sandbox delete

really-clean:
	(cd monad-par && git clean -fxd)
	(cd LVish-examples && git clean -fxd)
	(cd LVish_repo && git clean -fxd)
	(cd PhyBin && git clean -fxd)
	(cd HSBencher && git clean -fxd)
	(cd hashrf && git clean -fxd)
	(cd dpj_cilk_run && git clean -fxd)
	git clean -fxd

redo_docker:
	docker build --no-cache -t iuparfunc/pldi2014-artifact:checkout - < Dockerfile.checkout
	docker build --no-cache -t iuparfunc/pldi2014-artifact:build - < Dockerfile.build
	docker build --no-cache -t iuparfunc/pldi2014-artifact:bench - < Dockerfile.bench
