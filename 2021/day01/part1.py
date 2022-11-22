total = 0

with open('input.txt') as f:
    lines = map(int, f.readlines())
    previous = None
    for current in lines:
        if previous and current > previous:
            total += 1
        previous = current


print(total)
