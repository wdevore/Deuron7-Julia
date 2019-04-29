# Deuron7-Julia
Julia implementation of a digital neuron simulation. Originally done in Dart and then Go.

# Linux setup

First run `>Julia` and `add`

* ] add CSyntax
* ] add CImGui
* ] add JSON
* ] add RandomNumbers

To make sure **CImGui** can run, go and git-clone [CImGui](https://github.com/ocornut/imgui). Then change into the examples directory and the run `demo.jl`. **CImGui** will install **ImGui** if needed. **Warning**! This could take 3-5 minutes for an initial compilation.

# Howto run Deuron
Start the server first:

```
> julia server.jl 127.0.0.1 2001
```

# com_protocol_base.json
```
{
  "From": "",   Client|Server
  "To": "",     Client|Server
  "Type": "",   Msg|Cmd
  "Message": ""
}
```

# app.json
```
{
    "Duration": 2000, // How long to sum for
    "RangeEnd": 1000, // Data view window
    "RangeStart": 0,
    "Simulation": "sim_1", // Sim json file
    "TimeStep": 100, // Time step in micro seconds
    "DataPath": "../data/"
}
```

# sim_x.json
```
{
  "Firing_Rate": 0.005, // Poisson firing rate
  "Hertz": 20, // aka ISI
  "Neuron": {
    "Dendrites": {
      "Compartments": [
        {
          "Synapses": [
            {
              "alpha": 1.05,
              "ama": 1.2,
              "amb": 10.8,
              "id": 0,
              "lambda": 1,
              "learningRateFast": 0.32,
              "learningRateSlow": 0.21,
              "mu": 0.32,
              "taoI": 10,
              "taoN": 33,
              "taoP": 17,
              "distance": 1.0,
              "w": 5.669624142019883
            },
            ...
      ],
      "length": 1.0,
      "taoEff": 10.0,
      "id": 0
    },
    "RefractoryPeriod": 3,
    "APMax": 20,
    "Threshold": 39,
    "id": 0,
    "nFastSurge": 8,
    "nSlowSurge": 8,
    "ntao": 10,
    "ntaoJ": 10,
    "ntaoS": 50,
    "wMax": 10,
    "wMin": 0
  },
  "Poisson_Pattern_max": 300,
  "Poisson_Pattern_min": 50,
  "Poisson_Pattern_spread": 50,
  "RefractoryPeriod": 3,
  "StimulusScaler": 9,
  "threshold": 39
}
```

# **Deprecated**
Next you need to `add` so that the server (aka simulation) and client can communicate.

* ] add HTTP
* ] add WebSockets
# **Deprecated**



