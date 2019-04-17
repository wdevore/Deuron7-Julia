# Deuron7-Julia
Julia implementation of a digital neuron simulation. Originally done in Dart and then Go.

# Linux setup

First run `>Julia` and `add`

* ] add CSyntax
* ] add CImGui

To make sure **CImGui** can run, go and git-clone [CImGui](https://github.com/ocornut/imgui). Then change into the examples directory and the run `demo.jl`. **CImGui** will install **ImGui** if needed. **Warning**! This could take 3-5 minutes for an initial compilation.

Next you need to `add` so that the server (aka simulation) and client can communicate.

* ] add HTTP
* ] add WebSockets


