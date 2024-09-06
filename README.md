## Simulation of the Lorenz equations

Update of [original project](https://github.com/BuiltWithGenie/LorenzEquations) with fixed integrator indexing for new version of DifferentialEquations, faded markers, faster and less accurate solver (BS3)

https://github.com/user-attachments/assets/923cc9c9-60bc-4fc9-8033-847e5e20fd0f

## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`

