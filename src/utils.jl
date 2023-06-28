module Utils

export save
export load_traj
export derivative
export integral

using JLD2

using ..StructNamedTrajectory
using ..StructKnotPoint

function JLD2.save(filename::String, traj::NamedTrajectory)
    @assert split(filename, ".")[end] == "jld2"
    save(filename, "traj", traj)
end

function load_traj(filename::String)
    @assert split(filename, ".")[end] == "jld2"
    return load(filename, "traj")
end

function derivative(X::AbstractMatrix, Δt::AbstractVecOrMat)
    if Δt isa AbstractMatrix
        @assert size(X, 1) == 1 "X must be a row vector if Δt is a matrix"
        Δt = Δt[1, :]
    end
    @assert size(X, 2) == length(Δt) "number of columns of X ($(size(X, 2))) must equal length of Δt ($(length(Δt))"
    dX = similar(X)
    dX[:, 1] = zeros(size(X, 1))
    for t = axes(X, 2)[2:end]
        Δx = X[:, t] - X[:, t - 1]
        h = Δt[t - 1]
        dX[:, t] .= Δx / h
    end
    return dX
end

derivative(X::AbstractMatrix, Δt::Float64) = derivative(X, fill(Δt, size(X, 2)))

function integral(X::AbstractMatrix, Δt::AbstractVector)
    ∫X = similar(X)
    ∫X[:, 1] = zeros(size(X, 1))
    for t = 2:size(X, 2)
        # trapezoidal rule
        ∫X[:, t] = ∫X[:, t-1] + (X[:, t] + X[:, t-1])/2 * Δt[t-1]
    end
    return ∫X
end

integral(X::AbstractMatrix, Δt::Float64) = integral(X, fill(Δt, size(X, 2)))


end
