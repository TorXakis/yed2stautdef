# yed2stautdef

`Torxakis` is a tool for model-based testing. Models represent state-transition systems,
which can intuitively be visualized as graphs.
[yEd](https://www.yworks.com/products/yed) is a powerfull, freely available graph editor
that can be used to edit and (automatically) layout graphs, and that runs on various
platforms. `yed2stautdef` provides a transformation from yEd-graphs to TorXakis models.


## Installation

`yed2stautdef` is provided as a zipped-executable for various platforms in the [releases] section.


## Usage

Construct or edit a graph with `yEd`.
Nodes in the graph represent states of the state-transition system and edges represent the transitions.
The labels in the nodes representing states are the state names;
the labels on the transitions specify actions in the TorXakis modelling language `TXS`.
There shall be one node, without edges, that gives the declaration.
The declaration shall be given as a TorXakis State Automation `STAUTDEF`,
giving the name of the state automaton, its channels with message types between `[` and `]`,
and optionally some parameters between `(` and `)`.
Moreover, there must be a list of all states following `STATE`,
`VAR` shall declare the state variables with their types,
and `INIT` shall give the initial state with initial values for the state variables.
Nodes and edges can be formatted as wished (colour, shape, lining, shadow, $\ldots$);
it does not matter for the transformation to TXS;
see the example of the state automation for `HelloWorld`.

![Hello World!](images/hwstaut.pdf)

The graph edited in yEd shall be saved in `Trivial Graph Format` (.tgf);
`yed2stautdef` transforms a file in TGF-format to a TXS-file:

```
yed2stautdef <file>.tgf
```

The produced .txs-file contains a STAUTDEF and can be included in a TorXakis model file,
or the file can be used as additional input file for TorXakis; TorXakis allows multiple
.txs input files.

Note that the graph should ``also`` be saved in the standard `GRAPHML` format (.graphml)
because the TGF-format does not preserve graph layout and formatting.
So, editing in yEd should be done on the .graphml-file.

`yed2stautdef` just transforms the .tgf-file and does not check any syntax or static semantics.
Checking is only done on the .txs-file, where error messages might appear.
Finding the corresponding error spot in the .graphml-file is currently not supported.

