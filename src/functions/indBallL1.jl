# indicator of the L1 norm ball with given radius

"""
  IndBallL1(r::Real=1.0)

Returns the function `g = ind{x : ‖x‖_1 ⩽ r}`, for a real parameter `r > 0`.
"""

immutable IndBallL1{R <: Real} <: IndicatorConvex
  r::R
  function IndBallL1(r::R)
    if r <= 0
      error("parameter r must be positive")
    else
      new(r)
    end
  end
end

IndBallL1{R <: Real}(r::R=1.0) = IndBallL1{R}(r)

function (f::IndBallL1){T <: RealOrComplex}(x::AbstractArray{T})
  if vecnorm(x,1) - f.r > 1e-14
    return +Inf
  end
  return 0.0
end

function prox!{T <: RealOrComplex}(f::IndBallL1, x::AbstractArray{T}, y::AbstractArray{T}, gamma::Real=1.0)
  # TODO: a faster algorithm
  if vecnorm(x,1) - f.r < 1e-14
    y[:] = x[:]
    return 0.0
  else # do a projection of abs(x) onto simplex then recover signs
    n = length(x)
    p = abs.(view(x,:))
    sort!(p, rev=true)
    s = 0.0
    @inbounds for i = 1:n-1
      s = s + p[i]
      tmax = (s - f.r)/i
      if tmax >= p[i+1]
        @inbounds for j in eachindex(x)
          y[j] = sign(x[j])*max(abs(x[j])-tmax, 0.0)
        end
        return 0.0
      end
    end
    tmax = (s + p[n] - f.r)/n
    @inbounds for j in eachindex(x)
      y[j] = sign(x[j])*max(abs(x[j])-tmax, 0.0)
    end
    return 0.0
  end
end

fun_name(f::IndBallL1) = "indicator of an L1 norm ball"
fun_dom(f::IndBallL1) = "AbstractArray{Real}, AbstractArray{Complex}"
fun_expr(f::IndBallL1) = "x ↦ 0 if ‖x‖_1 ⩽ r, +∞ otherwise"
fun_params(f::IndBallL1) = "r = $(f.r)"

function prox_naive{T <: RealOrComplex}(f::IndBallL1, x::AbstractArray{T}, gamma::Real=1.0)
  # do a simple bisection (aka binary search) on λ
  L = 0.0
  U = maximum(abs, x)
  λ = L
  v = 0.0
  maxit = 120
  for iter in range(1, maxit)
    λ = 0.5*(L + U)
    v = sum(max.(abs.(x) - λ, 0.0))
    # modify lower or upper bound
    (v < f.r) ? U = λ : L = λ
    # exit condition
    if abs(L - U) < 1e-15
      break
    end
  end
  return sign.(x).*max.(0.0, abs.(x)-λ), 0.0
end
