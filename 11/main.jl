using DSP

lines = readlines("input.txt")
energy_grid = zeros(Int, length(lines), length(lines[1]))
for (i, line) in enumerate(lines)
    for (j, char) in enumerate(line)
        energy_grid[i, j] = parse(Int, char)
    end
end

total_num_flashes = 0

# each flash induces energy in neighbouring cells represented as a kernel
kernel = [1 1 1; 1 0 1; 1 1 1]

for step_num = 1:1000
    global energy_grid, total_num_flashes
    energy_grid .+= 1

    flashes = Int.(energy_grid .> 9)
    induced_energy = conv(flashes, kernel)[2:end-1, 2:end-1]
    updated_flashes = Int.(energy_grid + induced_energy .> 9)

    # iterate until no more flashes are observed
    while flashes != updated_flashes
        flashes = updated_flashes
        induced_energy = conv(updated_flashes, kernel)[2:end-1, 2:end-1]
        updated_flashes = Int.(energy_grid + induced_energy .> 9)
    end

    energy_grid += induced_energy
    energy_grid[energy_grid.>9] .= 0

    total_num_flashes += sum(flashes)
    if step_num == 100
        println("Part 1: ", total_num_flashes)
    end
    if sum(flashes) == length(flashes)
        println("Part 2: ", step_num)
        break
    end
end