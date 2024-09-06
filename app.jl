module App
using GenieFramework, StippleLatex, DifferentialEquations, ModelingToolkit
using StaticArrays
@genietools

function define_ODE()
    @parameters t σ ρ β
    @variables x(t) y(t) z(t)
    D = Differential(t)

    eqs = [D(x) ~ σ * (y - x),
        D(y) ~ x * (ρ - z) - y,
        D(z) ~ x * y - β * z]
    @named sys = ODESystem(eqs, t, [x, y, z], [σ, ρ, β])
    sys = structural_simplify(sys)
    u0 = [x => 1.0,
        y => 0.0,
        z => 0.0]
    p = [σ => 10.0,
        ρ => 15.0,
        β => 5]

    tspan = (0.0, 100.0)
    ODEProblem(sys, u0, tspan, p, jac=true)
end

prob = define_ODE()

# Variables for line plotting
tail_size = 50
# tail_colors = @SVector[i / tail_size for i = tail_size:-1:1]
tail_colors = collect(range(1, 0, tail_size))
u_x = @MVector zeros(tail_size)
u_y = @MVector zeros(tail_size)

@handlers begin
    @private integrator = DifferentialEquations.init(prob, BS3())
    @in σ = 10.0
    @in ρ = 15.0
    @in β = 5.0
    @out t::Float32 = 0.0
    @in t_step = 0.1
    @in t_end = 10
    @in start = false
    @out solplot = PlotData()
    @out layout = PlotLayout(
        xaxis=[PlotLayoutAxis(xy="x", title="x", range=[-20, 20])],
        yaxis=[PlotLayoutAxis(xy="y", title="y", range=[-20, 20])])
    @private running = false
    @onchange start begin
        DifferentialEquations.reinit!(integrator)

        t = 0.0
        integrator = DifferentialEquations.init(prob, BS3())
        if running == false
            running = true
            @async begin
                while t <= t_end
                    sleep(t_step / 2)
                    solplot = PlotData(x=u_x, y=u_y, mode="lines+markers", plot=StipplePlotly.Charts.PLOT_TYPE_SCATTER, marker=PlotDataMarker(cmin=0, cmax=1, color=tail_colors, colorscale="Blues"))
                    integrator.p[1][3] = σ
                    integrator.p[1][1] = ρ
                    integrator.p[1][2] = β
                    step!(integrator, t_step, true)
                    circshift!(u_x, -1)
                    circshift!(u_y, -1)
                    u_x[end] = integrator.sol.u[end][1]
                    u_y[end] = integrator.sol.u[end][2]
                    t = integrator.sol.t[end]
                end
                running = false
            end
        end
    end
end


meta = Dict("og:title" => "Lorenz Chaotic Attractor", "og:description" => "Real-time simulation of a dynamic system with constant UI refresh.", "og:image" => "/preview.jpg")
layout = DEFAULT_LAYOUT(meta=meta)
@page("/", "app.jl.html", layout)
end
