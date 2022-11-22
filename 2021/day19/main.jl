
raw_data = []

for line in eachline("sample.txt")
    if occursin("scanner", line)
        push!(raw_data, [])
    elseif line != ""
        push!(raw_data[end], parse.(Int16, split(line, ',')))
    end
end

function difference_hashes(scanner_data)
    dist_map = Dict()
    dist_set = Set()

    for (i, dataᵢ) in enumerate(scanner_data[1:end-1])
        for (j, dataⱼ) in scanner_data[i+1:end]
            dist = sum((dataᵢ - dataⱼ) .^ 2)
            push!(dist_map, dist, (i, j + 1))
            push!(dist_set, dist)
        end
    end
    (dist_map, dist_set)
end

merged = raw_data[1]
remaining_data = collect(2:length(raw_data), Set)

while remaining_data
    merged_dist_map, merged_dist_set = difference_hashes(merged)

    for idx in remaining_data
        dist_map, dist_set = difference_hashes(raw_data[idx])
    end

end