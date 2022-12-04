with open("input.txt") as f:
    buf = f.read()

coords, instructions = buf.split("\n\n")

coords = coords.split()
# set in {(6,10), (0,14)} format
coords = {(int(x), int(y)) for x, y in [pair.split(",") for pair in coords]}


instructions = instructions.split()[2::3]
# list in [('y', 7), ('x', 5)] format
instructions = [(c, int(i)) for c, i in [pair.split("=") for pair in instructions]]


def reflect_coords(coords, line):
    transformed = set()
    index = line[1]

    if line[0] == "x":
        for x, y in coords:
            transformed.add((2 * index - x, y) if x > index else (x, y))
    elif line[0] == "y":
        for x, y in coords:
            transformed.add((x, 2 * index - y) if y > index else (x, y))
    return transformed


print("Part 1:", len(reflect_coords(coords, instructions[0])))

for line in instructions:
    coords = reflect_coords(coords, line)

x_max = max(x for x, y in coords) + 1
y_max = max(y for x, y in coords) + 1

# Did you know [[" "] * x_max] * y_max reuses the same instance of
# [" "] * x_max for each row? This means that every row gets modified
# every time we modify arr[y][x] for no apparent reason...

arr = [[" "] * x_max for i in range(y_max)]

for x, y in coords:
    arr[y][x] = "#"

print("Part 2:")
print("\n".join("".join(row) for row in arr))
