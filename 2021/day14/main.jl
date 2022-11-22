using StatsBase, LinearAlgebra
f = open("input.txt", "r")
initial = readline(f)
rest = strip.(readlines(f))[2:end]


# idxs is a dict that maps a char pair to an index for matrix math
# eg. ('H', 'T') => 3
idxs = Dict()
idx = 1

initial_pairs = []
for i in 1:length(initial)-1
    key = (initial[i], initial[i+1])
    push!(initial_pairs, key)
    if !(haskey(idxs, key))
        push!(idxs, key => idx)
        global idx += 1
    end
end

for line in rest
    key = (line[1], line[2])
    if !(haskey(idxs, key))
        push!(idxs, key => idx)
        global idx += 1
    end

    key = (line[1], line[end])
    if !(haskey(idxs, key))
        push!(idxs, key => idx)
        global idx += 1
    end

    key = (line[end], line[2])
    if !(haskey(idxs, key))
        push!(idxs, key => idx)
        global idx += 1
    end
end


# A dict of char pairs and initial count 
# Dict{Any, Int64}(('F', 'N') => 1, ('K', 'O') => 1, ...)
initial_counts = countmap(initial_pairs)

# A vec representing the initial state
# [1; 1; 1; 1; 1; ... 0; 0; 0; 0; 0; 0; ]
vec = zeros(Int, (length(idxs), 1))
for (key, count) in initial_counts
    vec[idxs[key], 1] = count
end

# A matrix mapping char pairs to char pairs
mat = Matrix{Int}(I, length(idxs), length(idxs))

for line in rest
    self_key = idxs[(line[1], line[2])]

    mat[self_key, self_key] = 0
    mat[idxs[(line[1], line[end])], self_key] = 1
    mat[idxs[(line[end], line[2])], self_key] = 1
end

function diff_at_n(n)
    vec_n = mat^n * vec
    count_n = Dict(initial[end] => 1)
    for (key, count) in idxs
        if haskey(count_n, key[1])
            count_n[key[1]] += vec_n[idxs[key]]
        else
            count_n[key[1]] = vec_n[idxs[key]]
        end
    end
    maximum(values(count_n)) - minimum(values(count_n))
end

println("Part 1: ", diff_at_n(10))
println("Part 2: ", diff_at_n(40))