using DelimitedFiles, StatsBase

counts = countmap(vcat(readdlm("input.txt", ',', Int)...))

day_0 = zeros(Int, 9, 1)
for (index, count) in counts
    day_0[index+1, 1] = count
end

#=
Suppose we have one lanternfish in state '3' which reduces to '2' after a day.
In notation, this may be described as:
    D('3') = '2'
A lanternfish in state '0' creates two lanternfish:
    D('0') = '6' + '8'
Two lanternfish in state '3' both grow into state '2':
    D(2'3') = 2'2'
In general, if a lanternfish in state 'm' grows into state 'n', then k lanternfish
of state 'm' grow into k lanternfish of state 'n'.
    D(k'm') = k'n'

This property makes lanternfish breeding a linear process that can be described using
linear algebra. Each state is represented by a unique basis vector and a matrix can
transform the tally from one day to the next.
=#
mat = [
    0 1 0 0 0 0 0 0 0 # 0
    0 0 1 0 0 0 0 0 0 # 1
    0 0 0 1 0 0 0 0 0 # 2
    0 0 0 0 1 0 0 0 0 # 3
    0 0 0 0 0 1 0 0 0 # 4
    0 0 0 0 0 0 1 0 0 # 5
    1 0 0 0 0 0 0 1 0 # 6
    0 0 0 0 0 0 0 0 1 # 7
    1 0 0 0 0 0 0 0 0 # 8
]

day_80 = mat^80 * day_0
day_256 = mat^256 * day_0

println("Part 1: ", sum(day_80))
println("Part 2: ", sum(day_256))