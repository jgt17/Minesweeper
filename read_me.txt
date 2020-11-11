Implementation of an AI for Minesweeper (As well as Minesweeper itself)

GeekPlayer is the final version of the AI, it works by collecting Facts about the board state,
and inferring new knowledge from what's known, just as a human does. It also plays out known
cells before attempting further inferences or guessing.

NerdPlayer was the first version of the AI, it uses the same internal logic, but uses a heap
to keep track of the known facts, instead of a pair of hashes, which dramatically increases
runtime. I abandoned NerdPlayer after noticing how poor the runtimes where and noting that I
didn't actually need all of the ordering the heap was maintaining. I originally started with
a heap because I wanted to always have the "safest guess" quickly available, when there were
no certain moves remaining, but maintaining the heap cost more runtime than it saved.

RandomPlayer is just that, an AI that plays randomly.

All three of the AI's are board-geometry-agnostic, though of course performance will likely
differ for different board geometries (eg, hexagonal cells) due to the difference in
available information.

A comprehensive benchmark (500 sets of 200 games each at each of the 3 standard difficulty
 levels) of GeekPlayer produced the following statistics:
Beginner (9x9 grid, 16 mines): Win rate: 0.9589, Std Dev: 0.0136
Intermediate (16x16 grid, 40 mines) Win rate: 0.8455, Std Dev: 0.0257
Expert (30x16 grid, 99 mines) Win rate: 0.3776, Std Dev: 0.0349

Timed runs (again at indicate 500 sets of 200 games each at each of the 3 standard difficulty
 levels) indicate good performance as well (Time in ms):
 Beginner (9x9 grid, 10 mines): Mean time to complete: 11.24 ms, Std Dev, 0.44 ms
 Intermediate (16x16 grid, 40 mines): Mean time to complete: 56.29 ms, Std Dev: 1.20 ms
 Expert (30x16 grid, 99 mines): Mean time to complete: 230.92 ms, Std Dev: 6.37 ms

 Expert in particular experienced spikes in time to complete, some runs would take significantly
 longer than most, most likely due to attempting several rounds of inference with the global
  fact.

  I'm happy with the results for now though. Further work includes implementing a less naive
  guessing strategy, preemptively identifying and processing forced guesses, and playing
  around with unusual board topologies, such as a hex grid, a tiling of regular octagons
  and squares, boards with cells with random neighbors, and n-dimensional boards.

 Raw results:
win rate:
{:Beginner=>{:Mean=>0.9588799999999993, :Sigma=>0.013606821818485028}, :Intermediate=>{:Mean=>0.8454700000000012, :Sigma=>0.02567156208725916}, :Expert=>{:Mean=>0.3776499999999999, :Sigma=>0.034880187786191744}}
time:
{:Beginner=>{:Mean=>0.011243451475000003, :Sigma=>0.00441090636270209}, :Intermediate=>{:Mean=>0.056291999274, :Sigma=>0.012041863296285264}, :Expert=>{:Mean=>0.2309295324299998, :Sigma=>0.06370965524441219}}
