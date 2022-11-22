using DSP, SparseArrays

lines = readlines("input.txt")
heightmap = zeros(Int, length(lines), length(lines[1]))
mat = zeros(Int, length(lines), length(lines[1]))
for (i, line) in enumerate(lines)
    for (j, char) in enumerate(line)
        heightmap[i, j] = parse(Int, char)
        # inverted so that greatest height is -1, lowest is -10
        # this makes convolution math play well with the edges, which are 0
        mat[i, j] = parse(Int, char) - 10
    end
end


# four kernels to check whether a cell is low in four directions
k_left = [0 0 0; -1 1 0; 0 0 0]
k_right = [0 0 0; 0 1 -1; 0 0 0]
k_up = [0 -1 0; 0 1 0; 0 0 0]
k_down = [0 0 0; 0 1 0; 0 -1 0]

function is_low(i)
    i < 0
end

low_points = trues(length(lines) + 2, length(lines[1]) + 2)

for kernel in [k_left, k_right, k_up, k_down]
    global low_points .&= is_low.(conv(mat, kernel))
end

# convolution increases the size of the matrix, this step returns
# us to the same initial dimensions
low_points = low_points[2:end-1, 2:end-1]
println("Part 1: ", sum(map(prod, zip(heightmap .+ 1, low_points))))


# 'convolution' of bitmatrix with kernel [0, 1, 0; 1, 1, 1; 0, 1, 0]
function conv_set!(set)
    add = Set()
    for (i, j) in set
        if i > 1
            push!(add, (i - 1, j))
        end
        if i < size(low_points, 1)
            push!(add, (i + 1, j))
        end
        if j > 1
            push!(add, (i, j - 1))
        end
        if j < size(low_points, 2)
            push!(add, (i, j + 1))
        end
    end
    push!(set, add...)
end

basin_lens = []
for j = 1:size(heightmap, 2)
    for i = 1:size(heightmap, 1)
        if !low_points[i, j]
            continue
        end
        # A set is a better representation of a sparse bitmatrix
        in_basin = Set()
        push!(in_basin, (i,j))
        for h = (heightmap[i, j]+1):8
            # find neighbouring points to those in basin
            conv_set!(in_basin)
            # filter for points where height <= h
            filter!(p -> heightmap[p[1], p[2]] <= h, in_basin)
        end
        push!(basin_lens, length(in_basin))
    end
end
sort!(basin_lens)
println("Part 2: ", basin_lens[end-2:end])