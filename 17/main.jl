f = open(f -> read(f, String), "input.txt")
_, _, xstr, ystr = split(f)

# Converts "a=-3..45," into [-3, 45]
function str_to_range(s)
    s = rstrip(s[3:end], ',')
    parse.(Int, split(s, ".."))
end

x_low, x_high = str_to_range(xstr)
y_low, y_high = str_to_range(ystr)

# This solution takes advantage of  y(t) being a parabola
# .............#....#............
# .......#..............#........
# ...............................
# S........................#.....
# t₀                       tₙ

# Values of y′ at t₀ such that it falls through target area at tₙ₊₁
y′_max = -1 - y_low
y′_min = y_low

# Triangular number formula
max_height = y′_max * (y′_max + 1) ÷ 2

println("Part 1: Max height ", max_height)

# We analyse x and y coordinates separately and then combine them together
# to get the total number of velocity pairs, avoiding O(n²) search space

t_min = 1
t_max = 1 + y′_max - y′_min

# If y′ is in the target range at time t, then:
#   y′ in y′_times[t] == true
y′_times = [Set() for _ in t_min:t_max]

# Populate elements of y′_times
for y′₀ in y′_min:y′_max
    t = 0
    y = 0
    y′ = y′₀
    while y > y_low
        y += y′
        y′ -= 1
        t += 1
        if y in y_low:y_high
            push!(y′_times[t], y′₀)
        end
    end
end


# Likewise, if x′ is in the target range at time t, then:
#   x′ in x′_times[t] == true
x′_times = [Set() for _ in t_min:t_max]

# Populate elements of x′_times
for x′₀ in 0:x_high
    t = 0
    x = 0
    x′ = x′₀
    while t < t_max
        x += x′
        t += 1
        if x′ > 0
            x′ -= 1
        end
        if x in x_low:x_high
            push!(x′_times[t], x′₀)
        end
    end
end

# Set of velocity pairs which land in the target region
# {(23,-10),  (25,-9),  (27,-5 ) ...}
velocity_pairs = Set()

# A velocity pair is valid if x′ and y′ pass through the target area at the
# same time t.

for (x′_set, y′_set) in zip(x′_times, y′_times)
    for x′ in x′_set
        for y′ in y′_set
            push!(velocity_pairs, (x′, y′))
        end
    end
end

println("Part 2: Velocity Pairs ", length(velocity_pairs))