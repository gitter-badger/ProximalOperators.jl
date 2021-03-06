# Separable sum, using arrays of arrays as variables

immutable SeparableSum{S <: AbstractArray} <: ProximableFunction
	fs::S
end

function (f::SeparableSum{S}){S <: AbstractArray}(x::AbstractArray)
	sum = 0.0
  for k in eachindex(f.fs)
		sum += f.fs[k](x[k])
	end
	return sum
end

function prox!{S <: AbstractArray}(f::SeparableSum{S}, x::AbstractArray, y::AbstractArray, gamma::Real=1.0)
  sum = 0.0
  for k in eachindex(f.fs)
	  sum += prox!(f.fs[k], x[k], y[k], gamma)
  end
  return sum
end

function prox(f::SeparableSum, x::AbstractArray, gamma::Real=1.0)
	y = map(similar, x)
	fy = prox!(f, x, y, gamma)
	return y, fy
end

fun_name(f::SeparableSum) = "separable sum"
function fun_dom(f::SeparableSum)
	# s = ""
	# for k in eachindex(f.fs)
	# 	s = string(s, fun_dom(f.fs[k]), " × ")
	# end
	# return s
	return "n/a" # for now
end
fun_expr(f::SeparableSum) = "(x₁,…,xᵣ) ↦ f[1](x₁) + … + f[r](xᵣ)"
function fun_params(f::SeparableSum)
	# s = "r = $(size(f.fs)), "
	# for k in eachindex(f.fs)
	# 	s = string(s, "f[$(k)] = $(typeof(f.fs[k])), ")
	# end
	# return s
	return "n/a" # for now
end
