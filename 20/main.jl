using DSP

f = open("sample.txt")

line = readline(f)
algorithm = .==(split(line, ""), "#")
readline(f)

grid = []
for line in readlines(f)
    push!(grid, .==(split(line, ""), "#"))
end
grid = reduce(hcat, grid)


println(conv(grid, [1 2 4; 8 16 32; 64 128 256]))
println(grid)